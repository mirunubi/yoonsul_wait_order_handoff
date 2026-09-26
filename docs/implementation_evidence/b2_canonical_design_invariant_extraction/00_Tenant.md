# 00_Tenant.md

Status: Active
Lifecycle: Evidence
DocumentType: Evidence
Last Updated: 2026-09-27

## §0 성격

Canonical Migration B2 의 Canonical Design Invariant 원문 발췌 중 Tenant 모듈이다.

이 문서는 설계도 구현도 아니다.
"현재 승인된 설계가 실제로 무엇이라고 말하는가" 의 증거다.

`HD-AMB-01` · `HD-AMB-02` 반영 delta 는 아직 적용되지 않았다 (다음 단계).

### 복원 provenance

T-1 ~ T-14 의 번호와 source index 는 2026-09-26 채팅 보고에서 회수한 navigation index 다.

이 index 자체를 normative evidence 로 사용하지 않았다.
각 evidence 의 인용문 · 실제 line range · type · authority 근거까지
본 문서 생성 시 repository 원문을 다시 읽어 검증했다.

따라서 이 문서는 과거 채팅 출력의 단순 복사본이 아니라
repository source 에서 재검증해 재구성한 evidence baseline 이다.

**검증 기준 시점**

```text
Git HEAD        65bf936 (origin/main 과 동일 · ahead 0 · behind 0)
working tree    clean (이 문서 생성 전)
601902 · 010004 는 9252491 → 65bf936 사이에 변경 없음 (git diff --quiet 실측)
```

**인용 표기 규칙**

```text
인용 블록의 각 줄은 원문 줄에 "> " 접두만 붙여 그대로 옮겼다.
원문의 코드 펜스(```) 줄이 인용 범위 밖이면 포함하지 않았다.
떨어진 줄을 하나의 인용으로 합치지 않았다.
```

### Authority 지위 정의

```text
DOCUMENT_SCOPE_FACT

의미:
  source 문서 자신의 scope / omission / handoff 를
  원문에서 직접 확인한 사실.

허용:
  - 해당 문서가 무엇을 정하지 않았는지 설명
  - 어떤 항목을 다른 stage / module 로 넘겼는지 설명
  - source coverage / exclusion 판단

금지:
  - current-authority source 로 취급
  - Target Specification 의 normative 근거
  - Coverage Matrix 의 FOUND 근거
  - Required Invariant 의 FOUND 근거
  - B2 구현 의무를 도출하는 근거

DOCUMENT_SCOPE_FACT ∉ current-authority

이 지위는 승격 대기 상태가 아니다.
AUTHORITY_UNVERIFIED 와 다르다.
authority 를 확인하지 못한 것이 아니라,
authority 축에 속하지 않는 종류의 사실이다.
```

지위 결정 provenance:

```text
Human approval in ChatGPT conversation, 2026-09-27 KST
exact quote / exact time: UNVERIFIED_BY_REPOSITORY
정식 HD 번호 부여는 000752 SESSION END 갱신에서 수행한다
```

### Authority 확인 — 601902 §0.3

`601902_Register_Stage1_Business_Rules.md` L54-L62 원문:

> ### §0.3 계약 동결 — 2026-09-08
>
> ```text
> 상태   SCOPE REDUCED / CONTRACT FROZEN
>        IMPLEMENTATION DEFERRED TO 0-C
>
> TI-1 ~ TI-15 는 정책 계약으로 확정한다
> 이 나선은 더 이상 TI-N 을 추가하거나 수정하지 않는다
> ```

적용 범위 — L60 문구의 대상은 `TI-1 ~ TI-15` 다.

```text
T-1 ~ T-11   TI-2 · TI-3 · TI-4 · TI-8 · TI-12 · TI-13 · TI-14 본문 안   → INCLUDED
T-12         §0.3 절 자체 (L54 ~ L76) 안                                  → INCLUDED
T-13         §5 (L1075) — TI-N 도 §0.3 도 아니다                           → DOCUMENT_SCOPE_FACT
```

T-13 은 §0.3 L60 의 적용 범위에 들어가지 않는다.
601902 L3 `Status: Active` 는 문서 lifecycle 표기이며 §5 의 authority 를 따로 확정하는 문구가 아니다.
T-13 은 DOCUMENT_SCOPE_FACT 로 분류한다 — 위 "Authority 지위 정의" 참조.

### Authority 확인 — 000752 (T-14)

`000752_Register_Current_Project_Baseline.md` 원문:

> 이 저장소의 "현재 상태" 를 Git 안에 둔다.

— L5 (§0)

> Repository Baseline (이 문서) = 정답

— L555 (§9 권위 순서)

000752 는 커밋 `65bf936` 기준 tracked · origin/main 반영 상태다.
위 두 줄로 Repository Baseline 성격이 원문 확인되므로
T-14 는 `A overlay (Repository Baseline)` 로 기록한다. INCLUDED 로 기록하지 않는다.

T-14 가 속한 블록의 상태 원문은 L289-L290 다.

> Rebuild Feasibility Spike
>   STATUS: PENDING

T-14 는 설계 규정이 아니라 PENDING 인 Spike 의 검증 조건이다.

## §1 Verbatim Evidence — Tenant 1차 baseline

### T-1

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L104-L109
- Authority: INCLUDED
- Authority 근거: 601902 L60 "TI-1 ~ TI-15 는 정책 계약으로 확정한다" — §1.2 TI-2 (L102) 본문
- Evidence type: A
- 대조 결과: VERIFIED

> **`tenant.isolation_state` 는 tenant 전체에 적용되는 tenant-wide isolation 만 표현한다.**
>
> ```text
> NONE
> ISOLATED
> ```

### T-2

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L111-L112
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.2 TI-2 (L102) 본문
- Evidence type: A
- 대조 결과: VERIFIED

> **store · route · device · actor · session · provider 등
> 부분 containment 를 `tenant.isolation_state` 에 추가 enum 값으로 넣지 않는다.**

### T-3

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L497-L505
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.12 TI-12 (L484) 본문
- Evidence type: A/B
- 대조 결과: VERIFIED

> **각 계층은 자신의 상태를 갖는다.**
> **상위 상태를 하위 상태의 대체물로 사용하지 않는다.**
>
> **이 나선이 소유하는 축**
>
> ```text
> tenant_status
> isolation_state
> ```

### T-4

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L153-L164
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.3 TI-3 (L151) 본문
- Evidence type: D
- 대조 결과: VERIFIED

> **tenant-wide isolation 은 아래 두 주체만 발동할 수 있다.**
>
> ```text
> 1  Automatic platform / security system
>    policy-defined trigger + evidence + tenant scope +
>    idempotency + audit 조건 아래 발동 가능
>
> 2  Authorized platform-security Human
>    수동 발동 가능
> ```
>
> **일반 tenant user · store staff · support 는 tenant-wide isolation 발동 권한이 없다.**

### T-5

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L191
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.3 TI-3 (L151) 본문
- Evidence type: D/E
- 대조 결과: VERIFIED

> **따라서 `AUTHORITY_ALLOWED` 가 아닌 모든 상태에서 실행하지 않는다.**

### T-6

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L219-L232
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.4 TI-4 (L217) 본문
- Evidence type: D
- 대조 결과: VERIFIED

> **tenant-wide isolation 의 자동 단독 해제를 허용하지 않는다.**
>
> **해제에는 아래가 필요하다.**
>
> ```text
> 원인 · 위험 해소 evidence
> explicit Human authority
> tenant scope 검증
> audit
> 필요 시 independent / multi-party approval
> ```
>
> **수동으로 격리를 발동한 동일 actor 가
> 자기 단독 승인만으로 release 하지 못한다.**

### T-7

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L574-L591
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.13 TI-13 (L560) 본문. L571 "**`010004` §7 Deny-By-Default Rule 이 정한다.**" 로 TI-13 이 채택한 원문이다
- Evidence type: C/D/E
- 대조 결과: VERIFIED

> Every tenant-scoped object must default to
> DENY_UNLESS_CONTEXT_MATCHES
>
> Allowed access requires
>   authenticated actor
>   resolved tenant context
>   resolved store context if applicable
>   valid role
>   valid authority
>   valid surface/device context if applicable
>   policy permission
>   Safe Projection rule
>   audit requirement if sensitive
>   no containment block
>   no suspension block
>
> If context cannot be resolved, access must fail closed
> Fail closed is mandatory

### T-8

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L594-L597
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.13 TI-13 (L560) 본문
- Evidence type: E
- 대조 결과: VERIFIED

> **tenant 가 `ISOLATED` 이면 containment block 이 존재한다.**
>
> **따라서 그 tenant 의 tenant-scoped object 접근은
> 허용 조건 중 「no containment block」을 통과하지 못하고 거부된다.**

### T-9

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L599
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.13 TI-13 (L560) 본문
- Evidence type: E
- 대조 결과: VERIFIED

> **격리 상태 자체를 관리하는 전이는 이 거부의 대상이 아니다.**

### T-10

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L680-L681
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.14 TI-14 (L660) 본문
- Evidence type: B
- 대조 결과: VERIFIED

> TI-14.1  isolation_state 변경은 그 자체로
>          tenant_status 또는 subscription lifecycle 을 변경하지 않는다

### T-11

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L365-L369
- Authority: INCLUDED
- Authority 근거: 601902 L60 — §1.8 TI-8 (L362) 본문
- Evidence type: E
- 대조 결과: VERIFIED — 색인 L364-L369 범위 안. L364 는 코드 펜스 여는 줄이라 인용에서 제외했다

> scope envelope 존재                       MUST
> 해당 action 에 필요한 scope dimension      MUST
> 010640 §5 의 모든 후보 필드를 무조건 보유    NOT REQUIRED
> applicable 하지 않은 dimension             생략 가능
> 필요한 scope 가 빠진 경우                   처리 · mutation 금지

### T-12

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L64-L71
- Authority: INCLUDED
- Authority 근거: §0.3 계약 동결 절 (L54 ~ L76) 자체의 본문
- Evidence type: F — 명시적 비범위
- 대조 결과: VERIFIED

> **이 나선이 하지 않는 것**
>
> ```text
> caller identity 해석
> tenant_status · isolation_state 의 업무 RPC gate
> runtime 접근 거부의 구현
> 그 어떤 SQL 도 이 나선은 만들지 않는다
> ```

### T-13

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 라인: L1075-L1100
- Authority: DOCUMENT_SCOPE_FACT
- Authority 근거: 601902 §5 (L1075) "이 나선이 정하지 않는 것" 은 601902 자신의 범위 선언이다. §0.3 L60 이 동결한 TI-1 ~ TI-15 범위 밖이며 §5 의 authority 를 따로 정한 원문은 없다. 상위 authority 를 요구하는 정책 주장이 아니라 601902 를 읽으면 확인되는 문서 범위 사실이므로 DOCUMENT_SCOPE_FACT 로 분류한다. 사용 제한 — "601902 는 테이블 · 컬럼 · 제약명 · 인덱스명 · 함수 signature · role ID · EXECUTE ACL · containment block 판정 위치 · policy permission 모델을 정하지 않았고 Stage 4 · 0-C 로 이월했다" 의 근거로만 사용한다. Coverage Matrix · Required Invariant 의 FOUND 근거로 사용하지 않는다
- Evidence type: A — 명시적 비범위
- 대조 결과: VERIFIED (내용 · 라인 · 000752 §4 규칙 ③ 이 지정한 L1075 제목 + L1077-L1098 목록 + L1100 모두 원문과 일치)

> ## §5 이 나선이 정하지 않는 것
>
> ```text
> 테이블 · 컬럼 · 제약명 · 인덱스명
> 함수 signature · 파라미터명 · 타입
> scoped containment 의 물리 표현
> role ID · approver 수 · EXECUTE ACL
> hash 조합 · policy_version 의 형태
> provider merchant mapping 의 물리 구조
>
> 구독료 · 사용량 산정 · 환불 · 크레딧 정책   Subscription Lifecycle
> 귀책별 보상 기준 · SLA credit               Billing Review
> 격리 시간 임계값                            위 둘이 생긴 뒤
>
> cross-business link 의 물리 표현              별도
> federation 설계 — 000190 §20 7요건            별도
> business scope 의 role 모델                   0-C
> link 상태의 값 집합                           별도
>
> containment block 판정 위치                0-C
> Safe Projection rule 의 구체 내용           별도
> policy permission 의 모델                  0-C
> surface · device context 의 표현            별도
> ```
>
> **Stage 4 · `0-C` 가 정한다.**

### T-14

- 문서번호: 000752
- 파일: `docs/000700_ai_agent_prelearning_and_project_context/000752_Register_Current_Project_Baseline.md`
- 라인: L303
- Authority: A overlay (Repository Baseline)
- Authority 근거: 000752 L5 · L555 (위 §0 Authority 확인). 블록 상태 L290 `STATUS: PENDING`
- Evidence type: E
- 대조 결과: LINE_SHIFTED — 채팅 보고 당시 L140 → 현재 L303 (내용 동일)

>   3. isolated tenant A → API     → DENY

## §2 CONDITIONAL Evidence

010004 source resolution — `find docs -name "*010004*"` 결과 1개:
`docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`

010004 L13 원문:

> This document is planning-only.

### C-1

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 라인: L27 (§2 Core Principle)
- Authority: CONDITIONAL
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 미수행
- Evidence type: A/C
- 대조 결과: VERIFIED

> Every object must know its tenant.  

### C-2

- 문서번호: 010004
- 파일: 위와 같음
- 라인: L39 (§2 Core Principle)
- Authority: CONDITIONAL
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 미수행
- Evidence type: C/E
- 대조 결과: VERIFIED

> No tenant may ever see, infer, retrieve, aggregate, search, export, or act upon another tenant’s data unless a separately authorized cross-tenant governance role exists.

### C-3

- 문서번호: 010004
- 파일: 위와 같음
- 라인: L43 (§2 Core Principle)
- Authority: CONDITIONAL
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 미수행
- Evidence type: E
- 대조 결과: VERIFIED

> `CROSS_TENANT_ACCESS_DENIED`

### C-4

- 문서번호: 010004
- 파일: 위와 같음
- 라인: L78 (§4 Mandatory Context Fields)
- Authority: CONDITIONAL
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 미수행
- Evidence type: A/B
- 대조 결과: VERIFIED

> | `tenant_id` | Required for all tenant-owned objects |

## §3 Coverage Matrix — Tenant 행 (1차 판정)

| Module | A Entity | B Constraint | C Ownership | D Authority | E Failure | F API Boundary |
|---|---|---|---|---|---|---|
| Tenant | FOUND | FOUND | CONDITIONAL | FOUND | FOUND | NOT_FOUND |

| 칸 | 근거 |
|---|---|
| A Entity | T-1 · T-3 (INCLUDED). T-13 은 테이블 구조를 비범위로 명시하나 DOCUMENT_SCOPE_FACT 이며 current-authority 가 아니므로 Coverage Matrix · Required Invariant 의 FOUND 근거로 사용하지 않는다 — §0 Authority 지위 정의 참조 |
| B Constraint | T-3 · T-10 |
| C Ownership | INCLUDED 근거는 T-7 의 "tenant-scoped object" 뿐이다. 객체 소유 규칙은 C-1 · C-4 (CONDITIONAL) 에만 있다 |
| D Authority | T-4 · T-5 · T-6 |
| E Failure | T-5 · T-7 · T-8 · T-11 |
| F API Boundary | NOT_FOUND — T-12 (명시적 비범위) |

1차 판정과 달라진 칸 없음.

## §4 Required Invariant — Tenant 해당 행 (1차 판정)

| # | Required invariant | Status | Source | Lines |
|---|---|---|---|---|
| 1 | Tenant identity / tenant boundary | CONDITIONAL | 010004 (CONDITIONAL) C-1 · C-2. INCLUDED 쪽은 601902 T-7 을 조합해야만 성립 | 010004 L27 · L39 / 601902 L574-L575 |
| 5 | Tenant lifecycle / isolation deny rule | FOUND | 601902 (INCLUDED) T-8 · T-7 | L594-L597 · L574-L591 |
| 9 | fail-closed behavior | FOUND | 601902 (INCLUDED) T-7 | L590-L591 |

1차 판정과 달라진 Status 없음.

## §5 미결 사항

- HD-AMB-01 · HD-AMB-02 반영 delta 미수행
- 601702 Tenant 선언 미발췌
- POLICY_INCLUDED_BY_REFERENCE 채택 범위 중 Tenant 미반영 evidence 미확인
- T-13 (601902 §5) 지위 DOCUMENT_SCOPE_FACT — 정식 HD 번호 부여는 000752 SESSION END 갱신에서 수행
- 최종 상태: SCAN_IN_PROGRESS · NOT YET EVALUATED

## §6 근거

| 문서 | 인용 | 비고 |
|---|---|---|
| `000752_Register_Current_Project_Baseline.md` | §7 next ONE action · §4 Canonical Design Invariant 발췌 판정 규칙 ①②③ · §0 L5 · §9 L555 · L290 · L303 | A overlay |
| `601902_Register_Stage1_Business_Rules.md` | §0.3 L54-L62 계약 동결 (본 문서 생성 시 원문 확인) · §1.2 · §1.3 · §1.4 · §1.8 · §1.12 · §1.13 · §1.14 · §5 | INCLUDED (T-13 제외) |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | L13 · L27 · L39 · L43 · L78 | CONDITIONAL |
