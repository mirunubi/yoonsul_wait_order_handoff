# 601801_Register_Stage1_Business_Rules.md

Status: Active
Lifecycle: Register
Last Updated: 2026-08-27

## §0 성격

`000701` §47.1 의 **1단계 업무규칙 선언** 산출물이다.
Human 전담이며 AI 위임 불가다. 아래는 Human 이 확정한 내용을 그대로 기록한 것이다.

**이 문서는 「무엇을 사실로 삼을지」를 선언한다.** 설계도 구현도 아니다.
테이블 · 컬럼 · 값 이름의 구체적 결정은 2단계(ERD) 이후의 일이다.

> ✅ **Human Gate A — RESOLVED (2026-08-27)**
>
> `600010` §1.1 이 `0-A-2` 착수 전 결정을 요구한
> **tenant `ACTIVE` + `ISOLATED` 동시상태의 과금 · 서비스 정책**을 확정한다.
>
> **선언 8건 — `HG-A-1` ~ `HG-A-8`.**

### §0.1 식별자 규칙

```text
§1.N        문서 내 위치 · 구조
HG-A-N      업무규칙의 영구 식별자
```

**canonical identifier 는 `HG-A-N` 이다.**

```text
정식 최초 인용   601801 §1.N (HG-A-N)
이후 내부 추적    HG-A-N
```

> ⚠️ **`§1.N` 만으로 인용하지 않는다.**
> 앞 절이 추가되거나 문서를 재구성하면 위치 번호는 움직이지만
> **`HG-A-N` 은 계속 같은 규칙을 뜻해야 한다.**

**추적 구조**

```text
Business Rule     HG-A-3
Logic invariant   I-xx  → HG-A-3
TestPlan          TP-xx → HG-A-3
ChangeContract    D-xx  → HG-A-3
Audit             HG-A-3 충족 여부
```

**상위 근거**

```text
601702_Register_Stage1_Business_Rules.md   0-A 선언 45건
000221_Guide_Post_0A_Spiral_Sequence.md    나선 순서 · 권위보류 경계
```

> ⚠️ **`601502` · `601503` · `601505` · `601510` · `601511` 은 권위보류 대역이다.**
> **evidence 로만 인용하며 그 설계 결론을 승계하지 않는다**(`000221` §3.2).

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-27 | 초안 — `HG-A-1`~`HG-A-8` (Human Gate A) |

## §1 Human Gate A Business Rules

### §1.1 HG-A-1 — 상태축 독립성

**`tenant_status` 와 `isolation_state` 는 서로 독립된 축이다.**

```text
tenant_status     계약 · 고객 lifecycle
isolation_state   보안 · 장애 대응을 위한 기술적 격리
```

**`ACTIVE` + `ISOLATED` 는 유효한 동시상태다.**

| 조합 | 의미 |
|---|---|
| `ACTIVE` + `NONE` | 정상 영업 |
| `ACTIVE` + `ISOLATED` | 계약은 유효하나 시스템 사용이 격리됨 |
| `SUSPENDED` + `NONE` | 계약 · 운영상 서비스 정지 |
| `SUSPENDED` + `ISOLATED` | 서비스 정지 상태에서 추가 보안 격리 |

### §1.2 HG-A-2 — ACTIVE + ISOLATED 의 의미

**계약과 기본 구독이 유효하지만
tenant 의 일반 runtime 접근과 영업 데이터 처리가 fail-closed 로 차단된 상태다.**

| 기능 | 정책 |
|---|---|
| 고객 · 직원 로그인 | 차단 |
| 주문 · 대기 · 멤버십 · 재고 쓰기 | 차단 |
| 일반 tenant 조회 | 차단 |
| 신규 store · user 생성 | 차단 |
| 외부 POS · KDS 명령 전송 | 차단 |
| 외부 webhook | 직접 반영 금지. `HG-A-7` 을 따른다 |
| 시스템 감사 · 보안 조사 | 플랫폼 특권 경로만 허용 |
| 격리 해제 작업 | 승인된 복구 경로만 허용 |
| 계약 · 구독 정보 조회 | 플랫폼 관리 경로만 허용 |

**고객 관점에서는 서비스가 멈추지만 증거와 외부 이벤트를 버리지 않는다.**

### §1.3 HG-A-3 — 격리와 상업 상태의 분리

**`isolate_tenant` 는 아래를 자동 변경하지 않는다.**

```text
tenant_status
subscription 상태
청구조건
```

> ⚠️ **사고 처리 함수가 상업 계약을 임의로 바꾸면 안 된다.**

### §1.4 HG-A-4 — 기본료 · 사용량 과금

**격리만으로 기본 구독료를 자동 중단하지 않는다.**

```text
격리는 보안 · 운영 조치이며 계약 해지나 구독 취소가 아니다
```

**격리 중 차단된 신규 사용량은 사용량 과금에 포함하지 않는다.**

```text
격리 전 확정 사용량        정상 청구
격리 중 차단된 요청        사용량 미산정
격리 큐에 보존된 이벤트    복구 후 확정된 경우에만 산정
```

> ⚠️ **격리와 동시에 자동으로 과금을 멈추면
> 격리를 유발해 과금을 회피하는 경로가 생긴다.**

### §1.5 HG-A-5 — Human 과금 검토

**환불 · 크레딧 · 청구중단은 격리 원인과 책임을 검토한
별도 Human 승인으로만 처리한다.**

**다만 검토 누락을 방지한다.**

```text
격리가 발생하면 billing review 대상 여부를 자동 판정한다
플랫폼 귀책 격리 또는 장기 격리는 review task 와 감사 기록을 생성한다
미처리 review 가 존재하면 다음 청구 확정 전에 경고한다
```

**자동화 경계**

```text
자동화 가능   검토 작업 생성 · 알림 · 청구 전 경고
자동화 금지   환불 · 크레딧 · 청구중단 결정
```

**review task 생성은 금전 조작이 아니다.**

> ⚠️ **「장기 격리」의 시간 기준은 이 나선이 임의로 정하지 않는다.**
> 구독 · SLA 정책에서 확정하며, 그전까지는
> **모든 플랫폼 귀책 격리에 review 를 생성한다.**

### §1.6 HG-A-6 — 구독 변경과 격리 해제의 분리

**`manage_subscription` 은 `isolation_state` 를 변경하지 않는다.**
**구독 변경만으로 격리가 해제되지 않는다.**

```text
isolate_tenant        기술적 containment
manage_subscription   상업적 계약 lifecycle
```

### §1.7 HG-A-7 — 외부 이벤트 수신과 side effect 격리

**격리 중에도 외부 provider 의 확정 사실과 raw event 는
검증 · 수신 · 불변 증거로 보존한다.**

| 동작 | 격리 중 정책 |
|---|---|
| 외부 승인 사실 수신 · 원문 보존 | **해야 한다** |
| 중복 검증 · 서명 검증 | **해야 한다** |
| 영업 주문 상태 진행 | 보류 |
| KDS release | 금지 |
| 멤버십 · 재고 변경 | 보류 |
| 이벤트 폐기 | **금지** |
| 응답 실패 반복 | **금지** |

**side effect 는 quarantine 또는 pending review 상태로 둔다.**

**격리 해제 후 재처리는 동일 이벤트의 중복 적용을 방지하는
idempotency 계약을 따른다.**

> ⚠️ **`catchmenu_common.offline_queue` 재사용은 여기서 승인하지 않는다.**
>
> ```text
> offline_queue     네트워크 단절 후 재전송 목적
> isolation queue   보안 · 운영 격리 중 side effect 보류 목적
> ```
>
> **실패 원인과 해제 권한이 다르다.**
> **구조 · 권한 · 보존기간을 조사한 뒤 2~4단계가 재사용 여부를 결정한다.**

### §1.8 HG-A-8 — 격리 해제 승인

**격리 해제는 별도 복구 동작으로 수행한다.**

```text
원인 해소 확인
Human 승인
감사 기록
```

**세 요건을 모두 거친다.**

## §2 격리 원인별 처분

| 격리 원인 | 기본 구독료 | 후속 조치 |
|---|---|---|
| 보안 침해 의심 | 유지 | 조사 후 Human 판단 |
| 고객의 약관 위반 | 유지 | 계약 상태 별도 전이 |
| 플랫폼 장애 | 유지 후 크레딧 검토 | Human 보상 결정 |
| 법적 · 행정 명령 | 유지 원칙 | 계약 · 법무 판단 |
| 고객의 자발적 사용 중지 | — | **`ISOLATED` 사용 금지** |

> ⚠️ **마지막 행이 중요하다.**
> **고객이 잠시 서비스를 쉬는 것을 `ISOLATED` 로 표현하지 않는다.**
> 그것은 `SUSPENDED` 또는 별도 구독 상태의 문제다.
>
> **격리를 편의상 재사용하면 축이 오염된다.**

## §3 Human Decision — Gate A

```text
Human Decision — Gate A

HG-A-1 through HG-A-8 are approved, subject to the following
clarifications:

1. Isolation never automatically changes tenant lifecycle,
   subscription state, billing terms, refunds, credits, or suspension.

2. Platform-caused or prolonged isolation must automatically create
   a billing review task and pre-invoice warning, but no monetary
   adjustment may execute without Human approval.

3. External provider facts must still be validated and preserved
   during isolation. Tenant business side effects are quarantined
   and later replayed only under an idempotent recovery contract.

4. Reuse of catchmenu_common.offline_queue is not approved here.
   Its suitability must be decided during 0-A-2 design.
```

**판정자** — 정영석, 2026-08-27

## §4 후속 설계 의무

**2단계 ERD 이후가 정한다.**

```text
테이블 · 컬럼 · 값 이름
isolation queue 의 물리 구조
「장기 격리」의 시간 기준
격리 해제 복구 경로의 구현
billing review task 의 물리 표현
과금 금액 계산 · 정산 로직
```

**각 산출물은 자신이 어느 `HG-A-N` 에서 나왔는지 명시한다**(§0.1).

## §5 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `600010_Tracker_Spiral_Workpacket_Progress.md` | §1.1 — Gate A 요구 | ACTIVE |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §3 · §3.2 · §4.1 | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | 선언 45건 — 상위 근거 | ACTIVE |
| `601800_Readme_Tenant_Lifecycle_Rpc_Alignment.md` | §3 · §5 | ACTIVE |
| `601511` | Gate A 발생 경위 | ⛔ **권위보류. evidence 로만** |
| `601505` §4 | 호출 금지 조항 | ⛔ **권위보류. evidence 로만** |
