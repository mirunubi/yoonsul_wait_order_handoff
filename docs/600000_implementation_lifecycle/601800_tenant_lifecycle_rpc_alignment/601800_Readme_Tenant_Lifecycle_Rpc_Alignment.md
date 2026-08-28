# 601800_Readme_Tenant_Lifecycle_Rpc_Alignment.md

Status: Active
Lifecycle: Readme
Last Updated: 2026-08-27

## §1 Purpose

0단계 운영 권위 기반 하위 나선 **0-A-2** 워크패킷이다.

**Tenant lifecycle 축과 RPC · batch 정합을 확정한다.**

```text
tenant_status     계약 · 고객 lifecycle
isolation_state   보안 · 장애 대응을 위한 기술적 격리
```

**두 축의 독립성과 그에 따른 RPC 책임 분리가 이 나선의 중심이다.**

## §2 나선 식별자

**`0-A-2` 는 `601502` §3.2 의 범위 절단으로 분리된 파생 워크패킷이며
`000701` §47.3 원문에는 없다**(`600010` §2).

> ⚠️ **식별자를 유지하는 것과 과거 결론을 복원하는 것은 다르다.**
>
> ```text
> 식별자        트래커 · 금지조항 · 감사기록을 연결하는 주소
> 권위보류 대상  그 주소에서 내린 과거 판단
> ```
>
> `600020` 이 정지시킨 것은 후자다. **상세는 `000221` §3.2.**

### ⛔ `601500` 대역을 답안지로 사용하지 않는다

```text
601502 · 601503 · 601505 · 601510 · 601511

  추적 · 충돌 · 미완료 범위의 evidence 로 인용한다
  그 설계 결론을 현재 authority 로 자동 승계하지 않는다
```

**candidate scope 를 그대로 복사해 확정하지 않는다.**
**final scope 는 신규 ImpactScope 와 Human declaration 에서 재검증한다.**

## §3 착수 근거

**선행 나선**

```text
0-A 재수행   601700   Stage 12 CONDITIONAL ACCEPT (2026-08-24)
             0170 · 0171 적용 완료. 구현 결함 0
```

**선행 게이트 — Human Gate A**

```text
tenant ACTIVE + ISOLATED 동시상태의 과금 · 서비스 정책
status      RESOLVED (2026-08-27)
authority   601801 §1.1~§1.9 (HG-A-1 ~ HG-A-9)
```

> ⚠️ **canonical identifier 는 `HG-A-N` 이다**(`601801` §0.1).
> `§1.N` 만으로 인용하지 않는다 — 문서 재구성 시 위치 번호는 움직인다.

**순서 근거**

```text
000221 §3     Human Gate A → 0-A-2 → 0-A-3 → 0-B → 0-C → Phase 0 Exit Demo
601505 §8A    0-A-2 는 0-B 보다 우선   — 권위보류. evidence 로만 인용
```

## §4 착수 순서 (`000701` §47.1)

```text
[1단계] 업무규칙 선언        — Human 전담, AI 위임 불가
[2단계] ERD 초안
[3단계] 인접 도메인 대조      — 반드시 새 세션(사전 맥락 0)
[4단계] 설계문서 정합화        — §46 근거 문서 목록 의무
[5단계] SQL 구현 + 이중검증
[6단계] 나선 종료 판정        — Human
```

**현재 위치**

```text
1단계   완료 후 제한적 재개방 (2026-08-28)
        601801 HG-A-1 ~ HG-A-12
        HD-0-A-2-1 A급 판정 / HD-0-A-2-2 재개방 범위
2단계   완료 — 601803 (Active). 601808 대조표 30건 반영
3단계   완료 — 601804 ~ 601807. Blocker 10 / informational 23
영향 대조  완료 — 601808. HUMAN 0건
4단계   진행중 — 601809 Overview
        다음 601810 Logic · 601811 TestPlan · 601812 ChangeContract
```

## §5 In Scope — candidate

```text
isolate_tenant             기술적 containment
tenant_status 조회 · 접근 판단
tenant_status 필터          조회 · 배치 경로
is_registered              판정 기준
601505 §4 호출 금지 해제조건 검증
```

> ⚠️ **`manage_subscription` 은 `HD-0-A-2-7` 로 범위에서 절단됐다.**
>
> ```text
> 사유   T-2~T-7 구독 전이의 허용조건 · 수행 주체 ·
>        과금 및 entitlement 효과가 선언되지 않았다
>        HG-A-10 이 2~4단계의 추론 보충을 금지한다
>
> 이월   별도 Subscription Lifecycle 워크패킷
>
> 이월 기간   기존 함수는 호출 금지를 유지한다
>            0-A-2 는 권한 · 본문 불변만 회귀검사한다
> ```
>
> **`tenant_status` 는 범위에 남는다.**
> **`0-A-2` 가 접근 판단을 위해 읽으며 변경하지 않는다.**

> ⚠️ **candidate 다. `601502` 에서 복사한 것이 아니라
> 트래커 §2 가 기록한 범위를 출발점으로 삼은 것이다.**
> **final scope 는 1~4단계가 확정한다.**

## §6 Out of Scope

```text
provisioning RPC 재설계          0-A-3
C-3 tenant 일치 강제              0-A-3
User / Auth / Session            0-B
Role / Permission / RLS policy   0-C
과금 금액 계산 · 정산             별도
UI                               Phase 0 Exit Demo
manage_subscription 상태 변경        HD-0-A-2-7
T-2~T-7 구독 전이 · 요금제 · 갱신 · 해지 · 만료 · entitlement
```

## §7 Boundary Reference Documents

| 문서 | 지위 | 용도 |
|---|---|---|
| `000221_Guide_Post_0A_Spiral_Sequence.md` | ACTIVE | 나선 순서 · 등급 기준 · 권위보류 경계 |
| `000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md` | ACTIVE | Foundation 9축 |
| `601702_Register_Stage1_Business_Rules.md` | ACTIVE | 0-A 선언 45건 — 상위 근거 |
| `601746_Report_Stage11C_Conflict_Analysis.md` | ACTIVE | C-3 · 후속 이관 |
| `601748_Evidence_Stage12_Human_Merge_Decision.md` | ACTIVE | Mandatory Gates |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | ACTIVE | 나선 식별자 · 금지 조항 |
| `601502` §3.2 · `601505` §4 · §8A | ⛔ **권위보류** | evidence 로만 인용 |

## §8 Owned Number Band

```text
601800 ~ 601899
```

### §8.1 Add / Move Rule

**이 대역에 파일을 추가할 때**

```text
번호는 601800 부터 순차 배정한다
파일 생성과 동시에 §9 File List 에 등재한다
000005 · 000007 삼중 갱신은 별도 지시에서 수행한다
```

**이 대역 밖으로 옮길 때**

```text
번호를 바꾸지 않는다 — 000002 §1.2 가 소급 개명을 금지한다
  reference integrity 가 naming consistency 보다 우선한다
이동 사유와 이동 후 경로를 이 절에 기록한다
```

> ⚠️ **`601722` 처럼 예약 번호를 두는 경우
> §9 File List 에 예약 사실을 명시한다.**
> **결번으로 보이면 나중에 누락으로 오인된다.**

## §9 File List

| 번호 | 파일 | 상태 |
|---|---|---|
| 601800 | `601800_Readme_Tenant_Lifecycle_Rpc_Alignment.md` | Active — 이 문서 |
| 601801 | `601801_Register_Stage1_Business_Rules.md` | Active — 1단계 선언 14건(`HG-A-1`~`HG-A-14`). Human Gate A + `HD-0-A-2-1`~`HD-0-A-2-8`. 2026-08-28 제한적 재개방 · 08-29 제품 경계 복원 및 `manage_subscription` 절단 |
| 601802 | `601802_Register_Stage0_Evidence_Collection.md` | Active — §48 증거수집. 사실 등록부 |
| 601803 | `601803_Diagram_Tenant_Lifecycle_State_Machine.md` | Active — 2단계 ERD. 상태 전이 모델. `601808` 대조표 30건 반영 완료 |
| 601804 | `601804_Audit_Stage3_Adjacent_Domain_Codex.md` | Active — 3단계 실측 축. Blocker 3 |
| 601805 | `601805_Audit_Stage3_Adjacent_Domain_Cowork.md` | Active — 3단계 문서 축. Blocker 2 |
| 601806 | `601806_Audit_Stage3_Adjacent_Domain_Claude.md` | Active — 3단계 인접 도메인 축. **§47.1 지정 actor.** Blocker 7 |
| 601807 | `601807_Report_Stage3_Integration.md` | Active — 3단계 통합. Blocker 10 / informational 23 |
| 601808 | `601808_Report_Stage3_Impact_Reconciliation.md` | Active — 3단계 영향 대조. RESOLVED 7 / STAGE_4 23 / HUMAN 0 / OUT_OF_SCOPE 3 |
| 601809 | `601809_Overview_Tenant_Lifecycle_Rpc_Alignment.md` | Active — 4단계 Overview. `isolate_tenant` **수리 판정**. `601505` §4 해제 1건 |

## §10 Non-Implementation Boundary

**이 Readme 는 구현을 승인하지 않는다.**

```text
허용 파일과 금지 조작   ChangeContract 가 정한다
착수 권한               Stage 7 이 정한다
```

**`601505` §4 의 금지 조항 — 호출 금지 · `ACTIVE` 승격 금지 ·
신규 호출자 배포 금지 — 은 이 나선 완료까지 계속 유효하다**(`600010` §1.1).

## §11 Actor 배정 규칙 (`000701` §34 / §37)

| 단계 | Actor |
|---|---|
| 1단계 업무규칙 선언 | Human 전담 |
| 2단계 ERD | Claude Code |
| 3단계 인접 도메인 대조 | 새 세션 · 원작자 배제 |
| 4단계 설계문서 | Claude Code |
| Stage 6 계약 검증 | Cursor · Codex — 원작자 배제 |
| Stage 8 구현 | Codex |
| Stage 9 검증 | Claude Code + Cursor |
| Stage 11A 감사 | Claude |
| Stage 11B 블라인드 | ChatGPT — 사전 맥락 없는 새 대화창 |
| Stage 11C · 12 | Human |

> ⚠️ **`000701` §47.1 actor 지정과 실제 수행의 차이 — 2건**
>
> ```text
> §47.1 2단계   ERD 초안 — Cursor 조사 + Claude Code 작성
> 실제           Codex 증거수집(601802) + Claude Code 작성(601803)
>
> §47.1 3단계   인접 도메인 대조 — Opus / Fable
> 실제           Codex(601804) · Cowork(601805) · Claude/Opus(601806)
>               → Claude 가 지정 actor 요건을 충족한다
> ```
>
> **Human 판정 (2026-08-29) — 기록하고 진행한다.**
>
> ```text
> 2단계   601802 가 §48 A~E 를 전건 채웠고
>         3단계 세 검증자가 그 위에서 Blocker 10건을 찾았다
>         Cursor 가 조사했어도 다른 결과였을 근거가 없다
>
> 3단계   Claude(601806)가 §47.1 지정 actor 요건을 충족한다
>         Codex · Cowork 은 실무 보강이다
> ```
>
> ⚠️ **`601700` 3단계도 §47.1 을 충족하지 않았고 당시 검증되지 않았다.**
> **`AC-13` · DocumentType 과 같은 계열의 spec conflict 이며
> `601746` §4 가 governance 로 이관했다.**
