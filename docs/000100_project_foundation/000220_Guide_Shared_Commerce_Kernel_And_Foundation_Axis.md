# 000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md

Status: Active
Lifecycle: Guide
Last Updated: 2026-08-22

## 1. Purpose

윤슬 OS 와 CatchMenu 의 관계, 그리고 두 제품이 공유하는 Foundation 축을 정의한다.

**이 문서는 물리 스키마를 정의하지 않는다.** 축과 경계만 정한다.
테이블·컬럼·구현 순서는 각 워크패킷에서 정한다.

## 2. Shared Commerce Kernel

**윤슬 OS 와 CatchMenu 는 상하관계가 아니다.**

```text
CatchMenu 가 윤슬 OS 위에서 도는 것이 아니다
윤슬 OS 가 CatchMenu 위에서 도는 것도 아니다
```

**공통 Kernel 위에 서로 다른 Product Module 이 올라간다.**

```text
           Shared Commerce Kernel
     ┌───────────────────────────────┐
     │ Tenant / Store                │
     │ Menu                          │
     │ Modifier                      │
     │ Order                         │
     │ Payment                       │
     │ Provider Boundary             │
     │ Event / Audit                 │
     └───────────────┬───────────────┘
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
      윤슬 OS                CatchMenu
   ─────────────          ─────────────
   Membership             Waiting
   Staff                  Preorder
   Inventory              Visit Session
   Store Ops              Personalization
```

### 2.1 판별 기준

어떤 산출물이 Kernel 인지 Product Module 인지 판별할 때
`601702` §1.41 의 기준을 적용한다.

```text
두 번째 음식점이 들어오는 순간 그대로 쓸 수 있는가?

쓸 수 있다  →  Kernel 또는 CatchMenu 플랫폼 구조
못 쓴다     →  윤슬 tenant 데이터 또는 윤슬 전용 Module
```

**구조는 공유하고 내용은 tenant 에 귀속된다.**

## 3. Foundation 축

**미래를 막지 않는 최소 Foundation 은 아래 9축이다.**

| # | 축 | 내용 |
|---|---|---|
| 1 | Canonical Identity | Tenant / LegalEntity / Store / Person |
| 2 | Canonical Catalog | Menu / Modifier |
| 3 | Canonical Commerce | Cart / Order / OrderLine / Fulfillment |
| 4 | Financial Authority | PaymentIntent / Ledger / LegalEntity binding |
| 5 | Kitchen Boundary | Kitchen Dispatch Contract |
| 6 | External Provider Boundary | provider 식별자 ≠ canonical 식별자. mapping / adapter |
| 7 | Reliability | idempotency / retry / outbox / audit |
| 8 | Future Inbound Boundary | 외부 판매·주문·이벤트를 Canonical Event 로 받는 구조 |
| 9 | Inventory Event Boundary | 판매 채널이 아니라 consumption event 로 재고 반영 |

### 3.1 축별 설명

**① Canonical Identity**

`601702` §1.1~§1.43 이 이 축을 선언했다.
외부 시스템이 이 축에 들어오지 않는다. CatchMenu 전체의 canonical authority 다.

**② Canonical Catalog**

외부 시스템의 메뉴가 기준이 되지 않는다.

```text
        canonical menu id
               │
   ┌───────────┼───────────┐
   ▼           ▼           ▼
provider A  provider B  provider C
```

실행 provider 를 교체해도 canonical id 는 그대로 살아 있어야 한다.

Modifier 는 단순 옵션 문자열이 아니라 의미를 유지한다.

```text
modifier_id
action        ADD / REMOVE / REPLACE / SET
quantity
unit
display_text
```

`display_text` 를 structured data 와 **별도로** 둔다.
provider 가 구조화 modifier 를 지원하면 전자를,
부족하면 후자를 표시 문자열로 전달한다.

**③ Canonical Commerce**

**앱별 Order 를 만들지 않는다.**

```text
금지   membership_orders / catchmenu_orders /
       provider_orders / delivery_orders 가 각각 다른 세계

원칙            Canonical Order
                  ▲       ▲
                  │       │
             Membership  CatchMenu
```

외부 주문을 나중에 받을 때도 Adapter 를 거쳐 Canonical Order 로 들어온다.

**④ Financial Authority**

```text
Order → PaymentIntent → Payment Confirm → ledger
                                            │
                                    dispatch authorized
```

**결제가 완료되었다고 앱이 주장한다고 주방으로 보내지 않는다.**
서버의 payment authority 가 승인을 만들어야 Kitchen 으로 간다.

`601702` §1.35 가 금전 객체의 LegalEntity snapshot 을 규정한다.

**⑤ Kitchen Boundary**

**Core 가 책임지는 마지막 지점이다.**

```text
Kitchen Dispatch Contract
       │
       ├── Adapter A
       ├── Adapter B
       └── 자체 KDS Adapter
```

**Adapter 내부만 provider 를 안다. Core 는 모른다.**

이 경계가 향후 자체 KDS 개발을 가능하게 만든다(`000718` §4).

**⑥ External Provider Boundary**

```text
canonical id
     │ mapping
     ▼
provider id
```

`601702` §1.43 이 이 축을 선언했다.
물리 mapping 구조는 provider 계약 확보 후 별도 워크패킷에서 설계한다
(`601710` §3.1 — Deferred).

**⑦ Reliability**

자체 채널에서 주문을 보낼 때 네트워크 재시도로 주문이 두 번 들어가면 안 된다.

```text
DB transaction
      ↓
  outbox event
      ↓
provider dispatch
```

RPC 하나에서 전부 처리하지 않는다.
그래야 **결제는 성공하고 provider 전송만 실패한 경우 재전송**이 가능하다.

**⑧ Future Inbound Boundary**

지금 endpoint 를 만들자는 것이 아니다. **경계만 남겨둔다.**

```text
provider
   ↓
Webhook / API
   ↓
Provider Inbox
   ↓
Canonical Event
```

**⑨ Inventory Event Boundary**

재고가 order 테이블을 직접 읽어 차감하는 방식이면 나중에 꼬인다.

```text
Order / External Sale
        ↓
  Consumption Event
        ↓
   Inventory Core
```

그래야 미래에 여러 판매 채널을 하나의 재고로 모을 수 있다.

## 4. 축별 나선 배정

| 축 | 나선 | 상태 |
|---|---|---|
| ① Canonical Identity | 0-A (`601700`) | 진행 중 |
| ②~⑨ | 미배정 | — |

**②~⑨ 의 나선 배정은 이 문서가 정하지 않는다.**
각 축의 착수 시점에 워크패킷을 열고 `600010` 트래커에 등재한다.

## 5. 이 문서가 정하지 않는 것

```text
물리 스키마 · 테이블 · 컬럼
구현 순서
provider 계약 및 mapping 구조
각 축의 나선 번호
```

provider 관련 미결은 `000718` §6 / `601702` §1.43 / `601710` §3.1 을 따른다.

## 6. 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 역할 |
|---|---|---|
| `000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | §10, §11, §21 | CatchMenu ↔ Franchise OS 경계 |
| `000718_Governance_Execution_Layer_Externalization_Roadmap_Revision.md` | §3, §4 | 실행 계층 외부 위임 · Core 경계 |
| `601702_Register_Stage1_Business_Rules.md` | §1.40, §1.41, §1.43, §1.35 | SaaS 구조 선행 · 판별 기준 · provider boundary |
| `601710_Overview_Operational_Authority_Foundation_V2.md` | §3.1 | Deferred Boundary |
