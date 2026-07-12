# 900162_Logic_POS_Integration_Level_Based_Mode_Transition_System

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 POS 주문 이벤트 기반 구두주문 후행 바인딩 결제 시스템의
설계 로직을 정의한다.

```text
내부 기술명: POS Event Based Verbal Order Late Binding Payment
제품명:      구두주문 자리결제 바인딩
최소 구현:   Level 2 POS 단방향 연동 (Level 1 비연동 폐기)
목표:        Level 3 POS 양방향 완전 연동
```

핵심 원칙:

```text
직원은 기존처럼 POS 에만 입력한다.
Catch Menu 에 별도 재입력 금지.
Catch Menu 는 POS 데이터를 받아와서
고객 결제 경험을 붙이는 구조다.

주문 원장 = POS
고객 바인딩/결제 경험 = Catch Menu
```

Related Overview:
  900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md

---

## 1. Level 1 폐기 선언

```text
폐기: POS 비연동 이중 입력 모드

이유:
  직원이 POS 에도 입력하고
  Catch Menu 에도 다시 입력해야 함
  "편하자고 만든 기능인데 더 불편함"
  현장에서 사용 안 함

Catch Menu MVP 최소 기준:
  POS/KDS/주방프린터/로컬DB 중 하나에서
  주문 이벤트 자동 수신 = Level 2 이상
```

---

## 2. 최소 MVP: Level 2 단방향 연동

### 2.1 핵심 구조

```text
[직원]
  POS 에만 입력 (기존 그대로)
        ↓
[POS 주문 데이터 추출]
        ↓
[Catch Menu POS Gateway]
  POS 주문 → 표준 이벤트 변환
  pos.order.created 생성
        ↓
[Unbound Order 생성]
  고객 식별 정보 없는 비식별 주문
        ↓
[고객 테이블 QR 접속]
  table_id 기반 바인딩 후보 주문 매칭
        ↓
[주문 확인 + 후행 바인딩]
  고객이 주문 내역 확인
  order_fingerprint 검증
        ↓
[테이블 결제]
  PG 승인
        ↓
[POS 결제 반영 또는 직원 알림]
```

---

### 2.2 POS 데이터 수신 4가지 루트

```text
A. 공식 API/Webhook (최우선)
   POS 주문 생성 → POS Webhook → Catch Menu Gateway
   장점: 안정적, 실시간
   단점: POS 사가 API 열어줘야 함

B. 로컬 DB/파일 연동
   POS 로컬 DB (SQLite/MSSQL) 또는 마감 파일
   → Store Local Agent 가 읽음
   → Catch Menu Gateway 로 전송
   현실적인 대안. 단, 읽기 권한/POS 사 계약 필요

C. 주방프린터/KDS 출력 데이터 복제
   POS → 주방프린터/KDS 출력 데이터
   → 중간 중계 장치가 수신
   → 주문 텍스트 파싱 → Catch Menu 주문 생성
   공식 API 없을 때 우회 루트

D. KDS 연동
   POS → KDS → Catch Menu Gateway
   KDS 주문 데이터는 이미 구조화된 경우 많음

지원 POS 우선순위:
  1순위: 공식 API 제공 POS (OKpos, 토스POS)
  2순위: KDS/주방프린터 데이터 수신 가능 POS
  3순위: 로컬 DB/마감파일 조회 가능 POS
  4순위: 제휴 불가 POS 는 제외

선언:
  "지원 POS 에서만 구두주문 후행 바인딩 결제를 제공한다."
  모든 POS 를 처음부터 지원하지 않는다.
```

---

### 2.3 최소 필수 데이터

```text
필수:
  store_id
  pos_order_id
  table_no
  order_items        (menu_name, qty, price, options)
  total_amount
  order_status
  payment_status
  created_at
  updated_at
  order_version      또는 updated_at 기반 fingerprint

선택 (가능하면):
  staff_id
  pos_terminal_id
  kitchen_status
  void_cancel_flag
  discount
  tax
  service_charge
  payment_split_allowed
```

---

### 2.4 Level 2 두 가지 케이스

```text
Case 2-A: 주문 조회만 가능 (결제 반영 불가)

  POS → Catch Menu: 주문 데이터 수신
  Catch Menu → POS: 결제 반영 불가

  결제 완료 후:
    직원 단말에 알림
    "7번 테이블 결제 완료 / 18,000원
     POS 에서 외부결제 마감 처리 필요"
    직원이 POS 에서 수동 마감

  허용 범위:
    직원 주문 재입력 없음
    결제 마감 버튼만 사람이 누름
    현장에서 수용 가능

Case 2-B: 주문 조회 + 외부결제 코드 반영 가능

  POS → Catch Menu: 주문 데이터 수신
  Catch Menu → POS: 결제 완료 코드/승인번호 반영

  결제 완료 후:
    Catch Menu PG 승인
    → POS 에 외부결제 완료 자동 등록
    → POS 주문 PAID 처리

  이것이 상용 MVP 목표.
```

---

## 3. 주문 버전 검증 (가장 중요한 안전장치)

```text
문제:
  직원이 POS 에서 주문을 수정하는 동안
  고객이 결제 버튼을 누르면 사고 발생

해결: order_version 또는 order_fingerprint

order_version 방식:
  주문 생성        = version 1
  음료 추가        = version 2
  라면 취소        = version 3

  고객이 결제 버튼 누를 때:
  customer_seen_version == current_pos_version
  불일치 → 결제 중단

order_fingerprint 방식 (version 없을 때):
  fingerprint = hash(items + amount + discount + tax + status)
  결제 직전 재계산 후 비교
  불일치 → 결제 중단

불일치 시 고객 화면:
  "주문이 변경되었습니다. 다시 확인해주세요."
  변경된 주문 내역 재표시
  고객이 다시 확인 후 결제 진행

이것이 없으면 반드시 사고가 난다.
```

---

## 4. 결제 잠금 3단계

```text
고객이 결제 단계 진입 시 POS 주문 잠금:

Hard Lock (POS 가 잠금 API 지원 시):
  POS 가 주문 수정 자체를 차단
  가장 안전

Soft Lock (POS 미지원 시):
  Catch Menu 직원 화면에 "결제 중" 표시
  POS 변경 이벤트 감지 시 결제 차단

No Lock (연동 없을 때):
  결제 직전/직후 fingerprint 비교만으로 보호
  Level 2-A 에서 사용

특허 실시예로 세 가지 모두 등록 가능
```

---

## 5. 표준 이벤트 모델

```text
POS 사마다 API 가 달라도
Catch Menu 내부는 표준 이벤트만 처리:

pos.order.created
pos.order.updated
pos.order.cancelled
pos.order.table_moved
pos.order.merged
pos.order.split
pos.payment.requested
pos.payment.locked
pos.payment.completed
pos.payment.failed
pos.payment.cancelled

번역 예시:
  A POS: "SALE_OPEN"          → pos.order.created
  B POS: "ORDER_NEW"          → pos.order.created
  C POS: "TABLE_ORDER_INSERT" → pos.order.created

이 표준화가 없으면 POS 연동이 계속 망가진다.
```

---

## 6. POS Gateway 역할

```text
단순 API 중계기가 아니다.

1. POS 주문 수신
2. POS 주문 → Catch Menu 표준 이벤트 변환
3. 주문 변경 이벤트 감지
4. order_version / fingerprint 관리
5. 결제 잠금 요청 전달
6. 결제 완료 이벤트 전달
7. POS 응답 실패 시 재시도
8. 중복 결제 방지
9. 장애 시 보류 큐 저장
10. 모든 이벤트 감사 로그
```

---

## 7. 결제 완료 후 POS 반영 2가지 모델

### 모델 A: Catch Menu 가 결제 주체

```text
고객 → Catch Menu 결제창 (토스페이먼츠)
      → PG 승인
      → Catch Menu 결제 완료
      → POS 에 외부결제 완료 반영

POS 에 들어가는 데이터:
  payment_method = EXTERNAL_MOBILE_PAYMENT
  approval_no    = PG 승인번호
  amount         = 18000
  paid_at        = 결제시간

조건: POS 가 외부결제 등록 API 지원 필요
```

### 모델 B: POS 가 결제 주체

```text
고객 결제 요청
  → Catch Menu
  → POS Gateway
  → POS 결제 세션 생성
  → POS/PG 결제 처리
  → 완료 이벤트 → Catch Menu 수신

장점: 더 깔끔
단점: POS 사 협조 필요
```

---

## 8. MVP 최소 조건 확정

```text
아래를 모두 충족해야 구두주문 후행 바인딩 결제 기능 출시 가능:

[ ] POS/KDS/주방프린터/로컬DB 중 하나에서 주문 이벤트 자동 수신
[ ] 직원의 Catch Menu 중복 입력 없음
[ ] 고객 테이블 QR 을 통한 주문 확인
[ ] 결제 전 order_version 또는 fingerprint 검증
[ ] 결제 완료 후 직원 단말 또는 POS 에 반영

하나라도 미충족 시 출시 불가.
Level 1 이중 입력 모드는 영구 폐기.
```

---

## 9. Level 3: 양방향 완전 연동 (목표)

```text
POS → Catch Menu:
  주문 생성/수정/취소/테이블 이동/합석/분리/금액 변경

Catch Menu → POS:
  고객 바인딩/결제 잠금/결제 완료/부분결제/취소/환불

구조 원칙:
  고객 앱 ↔ POS 직접 통신 절대 금지
  반드시 Catch Menu 서버 경유

  [고객 앱]
    ↕
  [Catch Menu Cloud]
    ↕
  [Store Local Agent / POS Gateway]
    ↕
  [POS]
```

---

## 10. 구현 로드맵

```text
Phase 1 (서울 1호점 MVP):
  OKpos 또는 토스POS 단방향 연동 (Level 2-A)
  주문 자동 수신
  고객 QR 결제
  직원 단말 결제 완료 알림
  POS 수동 마감 (2-A)

Phase 2 (상용화):
  외부결제 자동 반영 (Level 2-B)
  order_fingerprint 검증 완성
  Soft Lock 구현

Phase 3 (고도화):
  양방향 POS 연동 (Level 3)
  Hard Lock
  부분결제/환불 자동화
  표준 이벤트 모델 기반 다중 POS 지원

특허 출원:
  Phase 1 시작 전 선출원 권장
```

---

## 11. 변리사 전달용 특허 문장

### 독립항 (핵심)

```text
직원에 의해 POS 에 입력된 구두 주문에 대응하는
주문 이벤트를 POS 시스템, KDS 시스템,
주방프린터 출력 신호 또는 POS 로컬 데이터 저장소 중
적어도 하나로부터 수신하는 단계;

상기 주문 이벤트에 기초하여 고객 식별 정보가 결여된
비식별 주문 객체를 생성하는 단계;

고객 단말이 테이블 식별 정보를 포함하는 QR 또는 링크를
통해 접속하면, 상기 테이블 식별 정보와 상기 비식별
주문 객체를 매칭하여 바인딩 후보 주문을 산출하는 단계;

고객 단말로부터 주문 내역 확인 입력을 수신하여
상기 비식별 주문 객체를 고객 세션에 후행 바인딩하는 단계;

결제 전 상기 주문 객체의 주문 버전 또는 주문 지문을
재검증하는 단계;

재검증 결과가 일치하는 경우 고객 단말에서 결제를 수행하고,
결제 결과를 POS 시스템 또는 직원 확인 단말 중
적어도 하나에 반영하는 단계를 포함하는 것을 특징으로 하는
구두 주문 후행 바인딩 결제 방법.
```

### 시스템 청구항 보완

```text
본 발명은 직원이 구두로 접수하여 POS 에 입력한 주문을
별도의 중복 입력 없이 POS 주문 이벤트, KDS 주문 이벤트,
주방프린터 출력 데이터 또는 POS 로컬 데이터 중 적어도
하나를 통해 수신하고, 이를 고객 식별 정보가 없는
비식별 주문으로 등록한 뒤, 고객 단말의 테이블 QR 접속을
통해 해당 주문을 후행 바인딩하고 테이블 결제를 수행하며,

POS 연동 가능 수준에 따라 결제 완료 정보를
POS 에 자동 반영하거나 직원 확인 단말 또는 일일 대사를
통해 정산하는 것을 특징으로 하는
POS 주문 이벤트 기반 구두주문 후행 바인딩 결제 시스템.
```

---

## 12. Related Documents

| 문서 | 역할 |
|---|---|
| 900100: Patent 1+2 Overview | Wait/Order Handoff + KDS Late Binding |
| 900160: Patent A+B+C Overview | 운영 이벤트 기반 제어 |
| 900161: Patent A+B+C Logic | 이벤트 제어 상세 로직 |
| 900162: 이 문서 | POS 연동 후행 바인딩 결제 |
