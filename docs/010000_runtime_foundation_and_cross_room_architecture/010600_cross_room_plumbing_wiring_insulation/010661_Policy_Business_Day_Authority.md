# 010661_Policy_Business_Day_Authority.md

## Purpose

This document defines the Business Day Authority Policy.

The previous artifact `010660 Idempotency Retry Replay Reconciliation Policy` defined how repeated, delayed, duplicated, retried, replayed, out-of-order, offline-synced, and batch-reprocessed events must be handled without duplicating money movement or overwriting history.

This document defines who decides `business_day`, which timezone value is authoritative, what happens when the owning tenant/store cannot be resolved, how offline resubmission is bounded, how derived records inherit or recompute the business day, and why recorded business day values are immutable.

The purpose is to ensure that the business day is a server-derived fact with a single resolver, not a caller-supplied value, a session clock artifact, or a hardcoded timezone constant.

## 0 Scope

이 문서는 `business_day` 결정 권위 · timezone 권위 · 파생 기록 영업일 · 역사값 불변을 정한다.

구현(SQL · migration · 함수)은 포함하지 않는다.

## 1 계보와 근거

`601919` `H-02` → `H-02-3` UNIQUE `(store_id, business_day, order_number)` 의 follow-up evidence 로 `business_day` 부여 경로를 실측했다 (실측 2026-09-21, read-only).

`014019` §6 · §9 가 날짜 축을 구분하고 "explicit policy" 를 요구하나 그 정책이 없었다. 이 문서가 그 정책이다.

관련 finding — `RG-F9` (`flush_offline_queue` payload `business_day`) · `RG-F15`.

실측 요지 (사실만)

```text
서버 TimeZone = UTC, role 별 TimeZone 설정 0건
orders writer 8개가 business_day 식 4종을 사용한다
business_timezone 26개 컬럼은 stores.timezone 복사형이다
business_day 를 가진 파생 기록 23쌍 중 부모 상속 2건
business_day · business_timezone UPDATE SET 경로 0건 · 보호 장치 0건
```

실측 결과를 담은 evidence 문서는 아직 없다 — 구현 착수 시 RG 문서에서 작성한다.

## 2 결정 — 2026-09-21, Human 확정

### 2.1 `BDA-1` 영업일 결정 권위

`business_day` 는 caller 가 결정하지 않는다.

서버의 단일 resolver 가 결정한다.

resolver 입력은 `(tenant_id, store_id, occurred_at)` 이다.

resolver 는 내부에서 `now()` 를 읽지 않는다. 시각은 호출자가 명시한다.

```text
일반 주문    서버 수신 시각
offline     BDA-4 로 검증된 occurred_at
재처리       원래 event 시각
```

현재 경계는 매장 timezone 기준 `00:00` 이다.

resolver 계약은 향후 매장별 `day_start` 를 받을 수 있게 한다.

세션 TimeZone · `current_date` · `now()::date` 는 영업일 계산에 쓰지 않는다.

### 2.2 `BDA-2` timezone 권위

`stores.timezone` 이 새 event 계산의 권위값이다.

`row.business_timezone` 은 생성 당시 snapshot 이며 두 번째 권위값이 아니다.

하드코딩 `'Asia/Seoul'` 은 resolver 로 대체한다.

근거 — `business_timezone` 26개 컬럼은 전부 `stores.timezone` 복사형으로 실측됐다.

### 2.3 `BDA-3` 조회 실패 — fail closed

tenant/store 조회 0행 · store 부재 · timezone 0행이면 resolver 는 raise 한다.

NULL 반환 · fallback timezone 반환을 하지 않는다.

timezone fallback 은 편의 기능이 아니며 authorization failure 를 가릴 수 있다.

`H-03` tenant/store consistency 에서 파생된다.

### 2.4 `BDA-4` offline 재전송 — 현재 MVP 기준

payload 의 `business_day` 는 권위값으로 쓰지 않는다.

`business_day = resolver(tenant_id, store_id, occurred_at)`.

`occurred_at` 허용 범위

```text
과거  서버 최초 수신 시각 − 24h 이상
미래  서버 최초 수신 시각 + 5분 이하
```

기준 시각은 재시도해도 변하지 않는 서버 최초 수신 시각이다.

flush 시점의 `now()` 는 기준으로 쓰지 않는다 — 재시도마다 판정이 바뀌기 때문이다.

어느 컬럼이 그 값인지는 구현 Logic 단계에서 실측으로 확정한다 (후보 `catchmenu_common.offline_queue.queued_at`).

범위 밖이면 거부하고 예외로 기록한다.

`occurred_at` 과 서버 수신 시각은 둘 다 보존한다.

retry 우선순위

```text
같은 request_id 의 기존 성공 결과가 있으면 그 결과를 반환한다.
영업일 · 허용창 재검증으로 기존 성공 주문을 실패시키지 않는다.
idempotency 조회가 business_day 검증보다 먼저다 (RG-05 와 충돌 금지).
```

`24h` · `5분` 은 현재 MVP 값이며 영구 정책이 아니다.

### 2.5 `BDA-5` 파생 기록의 영업일

**5a** 주문에서 파생된 기록(KDS ticket · payment intent · 결제 확정 등)은 `orders.business_day` 를 상속한다.

실제 발생 시각(PG 승인 등)은 별도 축으로 보존한다 (`014019` §6 · §9).

**5b** 환불 · 취소는 자기 발생 시각으로 resolver 계산한 `business_day` 를 가진다.

원주문 `business_day` 는 변경하지 않는다.

환불 · 취소는 원거래를 FK 또는 reference 로 보존한다.

```text
예  9/20 주문 · 9/21 환불
    → 매출 발생일 9/20 · 환불 거래일 9/21 · 원거래 참조 9/20 주문
```

**5c** 부모 거래가 없는 독립 event 는 resolver 로 직접 계산한다.

### 2.6 `BDA-6` 역사값 불변

`business_day` · `business_timezone` 은 생성 후 UPDATE 로 바꾸지 않는다.

store timezone 변경은 미래 event 에만 적용한다.

정당한 정정은 UPDATE 가 아니라 보정 event 로 한다.

근거 — UPDATE SET 경로 0건 · 보호 장치 0건으로 실측됐다 (위반 없음 · 강제 없음).

## 3 구현 선행 조건 (mandatory precondition)

```text
P1  RG-F15 — W5 · W6 에 명시적 tenant/store 게이트가 resolver 도입 전에 존재해야 한다.

P2  RG-F11 ~ F14 runtime 스키마 불일치가 남아 있으면
    해당 writer 의 BDA runtime 증거는 UNVERIFIABLE 이 된다. 착수 순서에 반영한다.

P3  BDA 구현이 orders writer 를 수정하면 RG-05 회귀 검증을 다시 실행한다.
    이는 RG-05 재개방이 아니다.
```

## 4 범위 밖

```text
order_number_allocators 명칭 — 문서 정정 대상 없음
  (H-02-4 원문은 테이블명을 지정하지 않는다)

W1 · W2 when others 의 무기록 에러 흡수 — 감사 관점 별도 검토 후보

RG-07 신설 여부와 600023 §5 개정은 구현 착수 시 별도 Human Decision
```

## 5 Current Status

```text
Status        Active
Lifecycle     Policy
Owner         TBD
Last Updated  2026-09-21
```
