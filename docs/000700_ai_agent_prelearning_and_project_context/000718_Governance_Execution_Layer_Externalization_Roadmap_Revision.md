# 000718_Governance_Execution_Layer_Externalization_Roadmap_Revision.md

Status: Active
Lifecycle: Governance
Last Updated: 2026-08-22

## §0 판정 요약

**`000705` 로드맵의 실행 계층(Execution Layer) 자체 개발 범위를 축소한다.**

KDS / DID / CMS / Kiosk 화면과 배달 채널 수집을 **외부 provider 에 위임**하고,
Core 는 **Kitchen Dispatch Contract 까지만** 책임진다.

```text
변경 전   Core 가 주문 → 주방 실행 화면까지 전부 소유
변경 후   Core 는 주문의 의미를 소유
          실행 provider 가 주방 실행을 소유
          경계는 Kitchen Dispatch Contract
```

**자체 KDS 개발 가능성은 닫히지 않는다.** Adapter 교체로 열려 있다.

## §1 변경 대상

### §1.1 `000705` §2 요약표

| phase | 기존 서술 | 변경 |
|---|---|---|
| Phase 1 | *basic KDS* 포함 | 자체 KDS 미개발. 실행 provider 위임 |
| Phase 3 | *Full Kiosk / KDS / DID / CMS / POS integration* | 실행 계층 자체 개발 제외. provider 연동으로 대체 |
| Phase 3-B | *Delivery app, external order channel, KDS-DID omnichannel expansion* | 배달 채널 직접 통합 제외. 실행 provider 수신분 활용 |

### §1.2 `000705` §7 Phase 3 Key Runtime Domains

아래 항목이 **자체 개발 범위에서 제외**된다.

```text
Kiosk and Mini Kiosk enhancement
KDS kitchen display and station routing
DID pickup callout and customer display
CMS content and menu synchronization
```

아래는 **유지**된다.

```text
Order, payment, cancel/refund state consistency
Retry, idempotency, degraded mode, audit, and evidence
```

### §1.3 `000705` §8 Phase 3-B

배달앱·외부 주문 채널을 **우리가 각각 직접 연동하지 않는다.**
실행 provider 가 이미 다수 채널을 수신하는 경우 그것을 활용한다.

> ⚠️ **외부 채널 주문을 우리 시스템이 받지 않는 것은 Deferred 이지 불필요가 아니다.**
> 재고 차감·통합 매출·메뉴 분석·자동 발주가 전부 외부 채널 판매를 필요로 한다
> (`601710` §3.1).

## §2 변경 사유

### §2.1 개발 안정성

1호점 오픈이 실행 계층 개발 일정에 묶이지 않는다.
검증된 실행 계층을 사용해 오픈 위험을 낮춘다.

### §2.2 레퍼런스 확보

실제 운영 중인 KDS 도메인 모델을 참조해
**향후 자체 개발의 기준**으로 삼는다.

백지에서 설계하면 실제 주방과 어긋날 수 있다.
현장에서 돌아가는 모델을 보고 우리 개념으로 번역하는 편이 빠르고 정확하다.

### §2.3 범위 축소

지금 만들지 않는 것.

```text
KDS UI / station routing / cooking timer / KDS device 관리
DID 화면 / 호출
CMS 콘텐츠 동기화
배달 채널별 API 연동
POS 벤더별 KDS protocol
```

### §2.4 선례

외부 실행 계층을 사용하면서 **자체 운영·재고 시스템과 연동하는 구조**는
국내 프랜차이즈에서 이미 운영되고 있다.
기존 POS 를 교체하지 않고 주문 통합·주방 실행만 외부에 두는 형태다.

**우리가 하려는 것이 검증되지 않은 패턴은 아니다.**

## §3 유지되는 것

**Core 의 책임은 줄지 않는다.**

```text
Canonical Menu
Canonical Modifier
Canonical Order
Payment Authority
Inventory
Business Policy
```

**provider 식별자를 canonical 식별자로 사용하지 않는다**(`601702` §1.43).

```text
canonical id
      │ mapping
      ▼
provider id
```

provider 를 교체해도 canonical 의미는 바뀌지 않는다. 매핑만 추가한다.

## §4 Core 의 경계 — Kitchen Dispatch Contract

Core 가 책임지는 마지막 지점이다.

```text
Order → Payment Authority → Kitchen Dispatch
                                  │
                     ┌────────────┼────────────┐
                     ▼            ▼            ▼
                 Adapter A    Adapter B    자체 KDS Adapter
```

**Adapter 내부만 provider 를 안다.** Core 는 모른다.

이 구조가 **향후 자체 KDS 개발을 가능하게 만드는 Foundation** 이다.

## §5 영향 대역

아래 문서군은 실행 계층 자체 개발을 전제로 작성되었다.
**삭제하지 않는다.** 본 판정 이후 인용 시 범위를 확인한다.

| 대역 | 건수 | 성격 |
|---|---:|---|
| `docs/750000_delivery_app_channel_integration_kds_did_and_order_ingestion_runtime/` | 19 | 배달 채널 + KDS/DID + 주문 수집 |
| `docs/004000_store_runtime_pos_kds_operations/` | 47 | 매장 런타임 POS/KDS 운영 |
| `000708_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md` | 1 | Phase 3 사전학습 |
| `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` | 1 | Phase 1 사전학습 (basic KDS 언급 확인 필요) |

> ⚠️ **개별 문서 배너 부착은 이번 판정에 포함되지 않는다.**
> 66건 이상 규모이며, 각 문서가 실제로 무엇을 규정하는지 확인 없이
> 일괄 배너를 붙이면 유효한 내용까지 권위가 흐려진다.
>
> **각 대역을 실제로 사용하는 시점에 그 문서를 확인하고 처분한다.**

## §6 미결

| 항목 | 상태 |
|---|---|
| 실행 provider 계약·API | 미확보. `601702` §1.43 Deferred 유지 |
| 확인 항목 | `601710` §3.1 에 provider 유형별로 기록됨 |
| `000705` 본문 정정 | 본 판정 이후 별도 작업 |
| 영향 대역 개별 처분 | §5 — 사용 시점에 확인 |

## §7 이 판정이 뒤집는 것과 뒤집지 않는 것

**뒤집는 것**

```text
실행 계층을 우리가 만든다는 전제
배달 채널을 우리가 각각 연동한다는 전제
```

**뒤집지 않는 것**

```text
멀티테넌시를 처음부터 구조에 넣는다        601702 §1.40
canonical 식별자가 최상위다                601702 §1.43
provider 를 교체할 수 있어야 한다          §4
자체 KDS 를 만들 수 있어야 한다            §4
```

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 역할 |
|---|---|---|
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | §2, §5, §7, §8 | 변경 대상 로드맵 |
| `601702_Register_Stage1_Business_Rules.md` | §1.40, §1.42, §1.43 | provider boundary · 역할 어휘 |
| `601710_Overview_Operational_Authority_Foundation_V2.md` | §3.1 | Deferred Boundary · 확인 항목 |
| `600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | 전체 | 판정 문서 형식 선례 |

## §9 판정

```text
판정:     정영석
일자:     2026-08-22
결정:     [x] 실행 계층 외부 위임 — 로드맵 범위 축소
범위:     000705 Phase 1 / Phase 3 / Phase 3-B
유지:     Core 책임 · canonical 우위 · Adapter 교체 가능성
미결:     provider 계약 미확보. 영향 대역 개별 처분은 사용 시점
```
