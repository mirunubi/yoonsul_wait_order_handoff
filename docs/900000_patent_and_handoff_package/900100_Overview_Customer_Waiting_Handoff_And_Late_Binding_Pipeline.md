# 900100_Overview_Customer_Waiting_Handoff_And_Late_Binding_Pipeline

Status: In_Progress
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

This Overview maps the implementation context for the Customer Waiting Handoff
and KDS Late Binding pipeline.

It identifies which policy documents, SQL migration files, RPC functions,
Flutter screens, Realtime channels, ledger events, and evidence artifacts
must be reviewed together before implementing or modifying this pipeline.

This document does not define SQL, code, or API contracts.
Those belong in Logic (900101), Spec, and Module documents respectively.

### 핵심 비즈니스 클레임

```text
Patent 1: Wait/Order Handoff
  고객이 대기 등록부터 착석까지 단일 세션으로 추적된다.
  대기 중 메뉴를 선택할 수 있다.

Patent 2: KDS Late Binding
  결제 확인 전까지 KDS는 HOLD 상태를 유지한다.
  결제 확인 후 KDS는 COMMITTED로 전환되어 조리가 시작된다.

Patent 1+2 Combined: pre_order_while_waiting
  고객이 대기 중에 메뉴를 선택한다.
  착석 후 결제하면 즉시 조리가 시작된다.
  신선한 음식이 최단 시간 내 제공된다.

기존 흐름 (경쟁사):
  착석 → 주문 → 조리 → 10분 대기

Catch Menu 흐름:
  대기 중 주문 → 착석 → 결제(30초) → 조리 시작 → 3분 내 제공
```

---

## 1. Source Policy Documents

이 파이프라인의 정책 정의 원본 문서:

| 문서 | 역할 |
|---|---|
| docs/005020_Guide_User_Flow.md | 고객 흐름 원본 정의 |
| docs/005025_Index_Customer_Runtime_Lane_Document_Map... | Customer Runtime 거버넌스 인덱스 |

---

## 2. SQL Migration Files

이 파이프라인을 구성하는 핵심 migration 파일 목록.
하나를 변경할 때 나머지를 함께 검토해야 한다.

| Migration | 핵심 내용 |
|---|---|
| 0097 | auth_sessions, staff_login, Zero Trust 디바이스 인증 |
| 0098 | confirm_payment, release_kds_after_payment — KDS Late Binding 핵심 |
| 0099 | Realtime 채널, broadcast_store_event, get_kds_realtime_state |
| 0100 | bootstrap_staff_app, open_store, close_store, change_store_mode |
| 0114 | kiosk_configs, kiosk_sessions, bootstrap_kiosk, place_kiosk_order |
| 0115 | register_waiting, call_waiting_customer, pre_order_while_waiting, seat_waiting_customer, cancel_waiting, mark_no_show |
| 0116 | bootstrap_customer_app_v2, qr_scan_action, get_order_tracking |
| 0117 | bootstrap_did_app, get_did_display_state, get_did_waiting_numbers |
| 0128 | order_sessions 컬럼 보완, kds_tickets 컬럼 보완, did_devices, did_display_queue |

---

## 3. RPC Function Map

### 3.1 고객 진입

| RPC | 역할 |
|---|---|
| qr_scan_action(WAITING_REGISTER) | QR 스캔 → 대기 등록 자동 호출 |
| qr_scan_action(TABLE_ORDER) | QR 스캔 → 테이블 주문 모드 |
| bootstrap_customer_app_v2 | 고객 앱 전체 초기화 |

### 3.2 대기 파이프라인 (Patent 1 핵심)

| RPC | 역할 | 상태 전이 |
|---|---|---|
| register_waiting | 대기 등록 | null → WAITING |
| call_waiting_customer | 호출 | WAITING → ARRIVAL_PENDING |
| confirm_arrival | 도착 확인 | — |
| pre_order_while_waiting | 사전 주문 + KDS HOLD 생성 | Patent 1+2 결합 |
| seat_waiting_customer | 착석 처리 | ARRIVAL_PENDING → SEATED |
| cancel_waiting | 취소 | any → CANCELLED |
| mark_no_show | 노쇼 | ARRIVAL_PENDING → NO_SHOW |

### 3.3 결제 + KDS 해제 (Patent 2 핵심)

| RPC | 역할 | 상태 전이 |
|---|---|---|
| confirm_payment | 결제 확인 | → PAID |
| release_kds_after_payment | KDS 해제 (내부 자동 호출) | HOLD → COMMITTED |

### 3.4 KDS 진행

| RPC | 역할 | 상태 전이 |
|---|---|---|
| transition_kds_ticket | KDS 상태 수동 전환 | COMMITTED → COOKING → READY → SERVED |
| get_kds_realtime_state | KDS 현재 상태 조회 | — |

### 3.5 DID 디스플레이

| RPC | 역할 |
|---|---|
| bootstrap_did_app | DID 전체 초기화 |
| get_did_display_state | 현재 호출 큐 |
| get_did_waiting_numbers | 대기 번호 목록 (최대 20개) |
| dismiss_did_call | 호출 해제 (착석 후 자동) |

### 3.6 조회

| RPC | 역할 |
|---|---|
| get_waiting_status | 고객 앱 대기 현황 |
| get_waiting_admin_view | 직원 앱 대기 관리 뷰 |
| get_order_tracking | 주문 추적 (고객 앱) |

---

## 4. DB Tables

| Table | Schema | 역할 |
|---|---|---|
| order_sessions | catchmenu_pos | 대기 세션 원장. wait_number, session_status |
| orders | catchmenu_pos | 주문 원장. order_source=PRE_ORDER 구분 |
| order_items | catchmenu_pos | 주문 항목 |
| kds_tickets | catchmenu_kds | KDS 티켓. kds_status=HOLD/COMMITTED/COOKING/READY |
| payment_ledger | catchmenu_payment | 결제 원장 |
| did_devices | catchmenu_store | DID 디바이스 설정 |
| did_display_queue | catchmenu_store | DID 호출 큐 |
| realtime_channels | catchmenu_common | Realtime 채널 레지스트리 |
| events | catchmenu_ledger | 감사 원장. 전 상태 변경 기록 |

---

## 5. Realtime Channels

| 채널 | 구독자 | 주요 이벤트 |
|---|---|---|
| waiting:{store_id} | 직원 앱, DID, 고객 앱 | waiting_session_created, waiting_called, waiting_session_seated |
| kds:{store_id} | KDS 디스플레이, 직원 앱 | kds_tickets_released, kds_ticket_updated |
| did:{store_id} | DID 디스플레이 | WAITING_CALL, call_dismissed |
| staff:{store_id} | 직원 앱 | staff_task_assigned, staff_memo_received |
| customer_app:{store_id} | 고객 앱 | order_status_changed, stamp_added |

---

## 6. Ledger Events

Patent 1 증빙의 핵심.
모든 상태 전이는 catchmenu_ledger.events에 기록되어야 한다.

| event_type | from_state | to_state | 트리거 RPC |
|---|---|---|---|
| waiting_registered | null | WAITING | register_waiting |
| pre_order_registered | WAITING | PRE_ORDER | pre_order_while_waiting |
| waiting_called | WAITING | ARRIVAL_PENDING | call_waiting_customer |
| arrival_confirmed | — | — | confirm_arrival |
| customer_seated | ARRIVAL_PENDING | SEATED | seat_waiting_customer |
| waiting_cancelled | any | CANCELLED | cancel_waiting |
| no_show_marked | ARRIVAL_PENDING | NO_SHOW | mark_no_show |
| kds_released_after_payment | HOLD | COMMITTED | release_kds_after_payment |

---

## 7. Flutter Screen Map

### 7.1 직원 앱 (STAFF_APP)

| 화면 | Primary RPC | Realtime 구독 |
|---|---|---|
| 대기 관리 화면 | get_waiting_admin_view | waiting:{store_id} |
| 호출 액션 | call_waiting_customer | — |
| 착석 처리 액션 | seat_waiting_customer | — |
| 노쇼 처리 액션 | mark_no_show | — |
| KDS 뷰 (직원용) | get_kds_realtime_state | kds:{store_id} |

### 7.2 KDS 디스플레이 (KDS_DISPLAY)

| 화면 | Primary RPC | Realtime 구독 |
|---|---|---|
| KDS 메인 | get_kds_realtime_state | kds:{store_id} |
| 상태 전환 | transition_kds_ticket | — |

### 7.3 미니 키오스크 (MINI_KIOSK)

| 화면 | Primary RPC | Realtime 구독 |
|---|---|---|
| 부트스트랩 | bootstrap_kiosk | store:{store_id} |
| 메뉴 화면 | get_kiosk_menu | — |
| 주문 완료 | place_kiosk_order | — |
| 결제 | confirm_payment + 토스페이먼츠 위젯 | — |

### 7.4 DID 디스플레이 (DID_DISPLAY)

| 화면 | Primary RPC | Realtime 구독 |
|---|---|---|
| 부트스트랩 | bootstrap_did_app | did:{store_id}, waiting:{store_id} |
| 대기 번호 표시 | get_did_waiting_numbers | waiting:{store_id} |
| 호출 표시 | get_did_display_state | did:{store_id} |

### 7.5 고객 앱 (CUSTOMER_APP)

| 화면 | Primary RPC | Realtime 구독 |
|---|---|---|
| 홈 | bootstrap_customer_app_v2 | customer_app:{store_id} |
| QR 스캔 | qr_scan_action | — |
| 대기 현황 | get_waiting_status | waiting:{store_id} |
| 주문 추적 | get_order_tracking | customer_app:{store_id} |

---

## 8. Related Documents In This Package

| 번호 | 문서 | 역할 |
|---|---|---|
| 900100 | 이 문서 | Overview — 구현 컨텍스트 맵 |
| 900101 | Logic | 제어 로직 + 상태 전이 상세 |
| 900200 | Overview (Patent 2 단독) | KDS Late Binding 단독 분석 (예정) |
| 900300 | Overview (Combined) | Patent 1+2 결합 흐름 (예정) |
| 900400 | Flutter Handoff | Flutter 외주 핸드오프 패킷 (예정) |

---

## 9. Out Of Scope

- SQL 구현 상세 → migration 파일 직접 참조
- Flutter 위젯 구현 상세
- 토스페이먼츠 API 계약 상세
- OKpos / VAN API 연동 상세
- 멤버십 포인트 적립 로직
- 재고 차감 로직

---

## 10. Implementation Readiness Checklist

이 파이프라인을 구현하거나 수정하기 전 확인 항목:

- [ ] 005020_Guide_User_Flow.md 검토 완료
- [ ] 0115 migration 전체 RPC 이해 완료
- [ ] 0098 confirm_payment + release_kds_after_payment 이해 완료
- [ ] Realtime 채널 5개 구독 구조 이해 완료
- [ ] ledger event 전체 목록 확인 완료
- [ ] 영향받는 Flutter 화면 목록 확인 완료
- [ ] KDS HOLD → COMMITTED 전환 조건 확인 완료
- [ ] 노쇼/취소 시 KDS CANCELLED 처리 확인 완료
- [ ] 900101 Logic 문서 검토 완료
