# 601900_Readme_Tenant_Isolation_Axis_V2.md

Status: Active
Lifecycle: Readme
Last Updated: 2026-08-31

## §1 Purpose

0단계 운영 권위 기반 하위 나선 **0-A-2 의 재수행** 워크패킷이다.

**Tenant lifecycle 축과 격리 축을 확정한다.**

```text
tenant_status     계약 · 고객 lifecycle
isolation_state   보안 · 장애 대응을 위한 기술적 격리
```

## §2 왜 재수행인가

`601800`(1차 0-A-2)은 2026-08-31 **AUTHORITY SUSPENDED** 판정을 받았다.

| 사유 | 근거 |
|---|---|
| `601801` 이 `010004` · `010640` 을 한 번도 인용하지 않았다 | 실측 — `601801` 전문에 0회 |
| `601809` · `601810` 이 `601702` §1.N 을 1건만 인용했다 | 실측 |
| `601801` 및 4단계 산출물에서 `000150` · `000170` 인용 0건 | 실측 |
| 4단계 착수 전 evidence pack 부재 | `601708` · `601709` 대조 |

**판정 전문** — `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md`

> ⚠️ **`010004` 는 파일명 자체가
> `Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam` 이며
> 29개 절이 격리 규칙이다.**
> **격리를 설계하면서 격리 정책 문서를 보지 않았다.**

### ⛔ `601800` 을 답안지로 사용하지 않는다

```text
승계한다
  finding — 600021 §1.1 대조 21건
  finding — 601816 Stage 6 blocking 15 · informational 25
  finding — 601804 · 601805 · 601806 원본

승계하지 않는다
  HG-A-1 ~ HG-A-16
  HD-0-A-2-1 ~ HD-0-A-2-11
  601803 상태 전이 모델
  601809 ~ 601812 설계 결론
```

**새 선언이 결과적으로 같아지는 것은 허용한다.**
**다만 독립적으로 도출해야 한다.**

## §3 착수 순서 (`000701` §47.1 + §48)

```text
[Stage 0] 증거수집 — A~E 5단계 분류, 표 형식 필수
[1단계]   업무규칙 선언        — Human 전담, AI 위임 불가
[2단계]   ERD 초안             — Cursor 조사 + Claude Code 작성
[3단계]   인접 도메인 대조      — Opus / Fable. 새 세션, 사전 맥락 0
[4단계 전] evidence pack       — 601708 · 601709 형식
[4단계]   설계문서 정합화        — §46 근거 문서 목록 의무
[5단계]   SQL 구현 + 이중검증
[6단계]   나선 종료 판정        — Human
```

**현재 위치**

```text
Stage 0   착수 전
```

## §4 `600021` §2 구속

**아래를 반드시 수행한다.**

```text
1  Stage 0 증거수집에 상위 정책 5건을 포함한다

     010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md
     010640_Policy_Tenant_Scope_Envelope.md
     000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md
     000170_Policy_Merchant_Account_Company_And_Store_Context.md
     000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md

2  1단계 선언을 상위 정책 위에서 도출한다

3  4단계 착수 전 evidence pack 을 만든다
     상위 정책과 인접 도메인을 조사해 바운더리를 먼저 확정한다

4  010004 §24 11항 선언 여부를 판정한다
     적용된다면 그 11항을 선언한다
     적용되지 않는다면 그 사유를 기록한다
```

> ⚠️ **4번이 Stage 7 승인 조건일 수 있다.**
> **`010004` §26 · §29 가 runtime 구현을 유보하고
> §24 가 11항 선언을 해제 조건으로 요구한다.**

### §4.1 In Scope — 산출물

**이 나선이 만들 문서다.**

```text
Stage 0   증거수집 — §48 A~E 5분류
1단계     업무규칙 선언 — Human 산출물
2단계     ERD
3단계     인접 도메인 대조
4단계 전   evidence pack
4단계     Overview · Logic · TestPlan · ChangeContract
Stage 7   Human Approval 기록
구현 후    Module · VerificationResult · AuditReview
```

> ⚠️ **무엇을 설계할 것인가는 여기서 정하지 않는다.**
> **이 나선의 범위는 1단계와 4단계가 새로 정한다** — §6.
>
> **`601800` §5 는 candidate scope 를 `601502` 에서 직접 복사하지 않았다고
> 명시하고 `600010` §2 를 출발점으로 삼았다.**
> **그러나 `600010` §2 의 candidate scope 는 권위보류된 `601502` §3.2 가
> `0-A-2` 로 이월한 항목과 실질적으로 중첩된다.**
>
> ```text
> 601502 §3.2   old 0-A 가 후속 0-A-2 항목을 지정
>       ↓
> 600010 §2     candidate scope
>       ↓
> 601800 §5     「600010 §2 를 출발점으로 삼았다」
> ```
>
> **직접 복사는 입증되지 않는다. 추이적 provenance 오염이다.**
>
> ⚠️ **`600010` 은 이름과 진행상태를 추적하는 주소록이며
> 업무 범위의 설계 authority 가 아니다.**
> **「트래커에 0-A-2 가 이렇게 적혀 있으니 이것을 한다」도 하지 않는다.**
>
> **이 나선은 원천 정책 · 신규 실측 · `601800` finding 에서
> scope 를 다시 도출한다.**

## §5 승계할 finding — 주요 4건

**`600021` §1.1 이 기록한 대조 결과 중 설계에 직접 영향을 주는 것.**

| # | 내용 |
|---|---|
| C-1 | `010004` §24 11항 게이트 — §4 의 4번 |
| C-2 | `010004` §20 이 surface 별 부분 containment 를 정의하고 `010640` §6 이 `SCOPE_PARTIAL_VALID` 를 상태로 요구한다. `isolation_state` 값역을 2값으로 닫으면 표현할 수 없다 |
| M-9 | `010004` §20 이 containment 1차 발동 사유로 cross-tenant contamination 을 지정한다 |
| R-6 | `010004` §19 audit event 필드 집합 |

**전문은 Stage 0 증거수집이 승계한다.**

## §6 Out of Scope

```text
provisioning RPC 재설계 · C-3          0-A-3
User / Auth / Session                  0-B
Role / Permission / RLS policy         0-C
과금 금액 계산 · 정산                   별도
manage_subscription 상태 전이           Subscription Lifecycle
```

> ⚠️ **`601800` 이 정한 범위 절단을 그대로 승계하지 않는다.**
> **`HD-0-A-2-7` · `HD-0-A-2-10` 은 승계 대상이 아니다.**
> **이 나선의 범위는 1단계와 4단계가 새로 정한다.**

## §7 Boundary Reference Documents

| 문서 | 지위 | 용도 |
|---|---|---|
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | ACTIVE | 격리 정책 원천 |
| `010640_Policy_Tenant_Scope_Envelope.md` | ACTIVE | tenant scope envelope |
| `000150` · `000170` · `000190` | ACTIVE | 조직 · merchant · 경계 정책 |
| `601702_Register_Stage1_Business_Rules.md` | ACTIVE | 0-A 선언 45건 — 상위 근거 |
| `601700` 대역 | ACTIVE | 0-A 완료 산출물 |
| `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` | ACTIVE | 이 재수행의 근거 |
| `601800` 대역 | ⛔ **AUTHORITY SUSPENDED** | finding 만 승계 |
| `601502` · `601503` · `601505` · `601510` · `601511` | ⛔ **권위보류** | evidence 로만 인용 |

## §8 Owned Number Band

```text
601900 ~ 601999
```

### §8.1 Add / Move Rule

```text
번호는 601900 부터 순차 배정한다
파일 생성과 동시에 §9 File List 에 등재한다
000005 · 000007 삼중 갱신은 별도 지시에서 수행한다
```

## §9 File List

| 번호 | 파일 | 상태 |
|---|---|---|
| 601900 | `601900_Readme_Tenant_Isolation_Axis_V2.md` | Active — 이 문서 |

## §10 Non-Implementation Boundary

**이 Readme 는 구현을 승인하지 않는다.**

**`601505` §4 의 금지 조항은 이 나선 완료까지 계속 유효하다**(`600010` §1.1).

## §11 Actor 배정 규칙 (`000701` §34 / §37 / §47.1)

| 단계 | Actor |
|---|---|
| Stage 0 증거수집 | Cursor 또는 Codex |
| 1단계 업무규칙 선언 | Human 전담 |
| 2단계 ERD | Cursor 조사 + Claude Code 작성 |
| 3단계 인접 도메인 대조 | Opus / Fable — 새 세션 · 사전 맥락 0 |
| 4단계 전 evidence pack | Cursor · Codex |
| 4단계 설계문서 | Claude Code |
| Stage 6 계약 검증 | 원작자 배제 — 3주체 |
| Stage 8 구현 | Codex |
| Stage 9 검증 | Claude Code + Cursor |
| Stage 11A 감사 | Claude |
| Stage 11B 블라인드 | ChatGPT — 사전 맥락 없는 새 대화창 |
| Stage 11C · 12 | Human |
