# 00_Tenant.md

Status: Active
Lifecycle: Evidence
DocumentType: Evidence
Last Updated: 2026-09-27

## §0 성격

Canonical Migration B2 의 Canonical Design Invariant 원문 발췌 중 Tenant 모듈이다.

이 문서는 설계도 구현도 아니다.
"현재 승인된 설계가 실제로 무엇이라고 말하는가" 의 증거다.

1차 발췌 시점에는 `HD-AMB-01` · `HD-AMB-02` 반영 delta 가 적용되지 않은 상태였다.
현재는 §7 Tenant Delta 로 적용되었다.

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

### T-15

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.22
- 라인: L439-L440
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> `Tenant` 는 CatchMenu 의 **SaaS 고객조직 및 최상위 데이터 격리 경계**다
> (`010640` §4: *SaaS tenant/customer organization*).

### T-16

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.22
- 라인: L445
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/B
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> **두 개념은 동일하지 않다.** 그러나 **이번 나선에서는 1:1 로 확정한다.**

### T-17

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.22
- 라인: L465
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> > **`Tenant` 는 보안상 같은 고객조직을 뜻하며 "같은 브랜드 식구들"을 뜻하지 않는다.**

### T-18

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.26
- 라인: L564
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> **Tenant 는 Store 의 두 번째 구조 부모가 아니라 필수 격리 scope 다.**

### T-19

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.36
- 라인: L908-L916
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> 매장 양수도가 **운영주체 변경**인지 **Tenant 이전**인지 구분한다.
>
> ```text
> LegalEntity 변경   같은 Tenant 안에서 법적 운영주체가 바뀜
> Tenant 이전        직원·회원·주문·권한·정산의 귀속 자체가
>                    다른 고객으로 넘어감
> ```
>
> **둘을 같은 사건으로 취급하지 않는다.**

### T-20

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.40
- 라인: L1081
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> **멀티테넌시는 나중에 붙일 수 있는 기능이 아니라 데이터 모델의 뼈대다.**

### T-21

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.40
- 라인: L1086-L1099
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> **1호점부터 반드시 SaaS 구조로 만드는 것**
>
> ```text
> tenant / store
> 사용자 계정 · 로그인
> tenant_id · store_id
> Role / Permission / Scope
> 직원이 어느 tenant/store 소속인지
> 고객·멤버십 데이터의 tenant 귀속
> 메뉴·재고·직원·KDS 데이터의 tenant/store 귀속
> Tenant 간 데이터 격리
> 외부 시스템 credential 및 merchant/store mapping
> 모든 핵심 객체의 ownership boundary
> ```

### T-22

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.41
- 라인: L1142-L1143
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> 이는 tenant 격리 경계와 같은 선이다.
> `tenant_id = YOONSUL` 인 데이터가 윤슬 것이고, 그것을 담는 스키마가 CatchMenu 것이다.

### T-23

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.44
- 라인: L1275
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> | Tenant 참조 | **필수** | §1.22 — Tenant ↔ MerchantAccount 1:1 |

### T-24

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.45
- 라인: L1305
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B/E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> **Tenant 만 존재하고 MerchantAccount 가 없는 상태를 정상 운영 상태로 허용하지 않는다.**

### T-25

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.45
- 라인: L1314-L1317
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> 신규 Tenant
>    │ tenant provisioning transaction
>    ├── Tenant 생성
>    └── MerchantAccount 생성      ← 같은 transaction

### T-26

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.45
- 라인: L1346
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> merchant_accounts.tenant_id   NOT NULL UNIQUE FK → tenants

### T-27

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.45
- 라인: L1349-L1350
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> 이것만으로 1:1 이 강제된다.
> `tenants.merchant_account_id` 를 두어 **순환 참조를 만들지 않는다.**

### T-28

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §19 Audit Isolation Rule
- 라인: L525-L527
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1118 `| `010004` | §7 — `TI-13` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |`
- Evidence type: E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Cross-tenant access attempts must be auditable.
>
> Failed access is also security evidence.

### T-29

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §20 Cross-Tenant Containment Rule
- 라인: L533
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1118 `| `010004` | §7 — `TI-13` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |`
- Evidence type: E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> If cross-tenant contamination is suspected, containment must trigger.

### T-30

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §20 Cross-Tenant Containment Rule
- 라인: L560
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1118 `| `010004` | §7 — `TI-13` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |`
- Evidence type: E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Containment is not resolution.

### T-31

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §29 Final Rule
- 라인: L760
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1118 `| `010004` | §7 — `TI-13` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |`
- Evidence type: C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Every MD object, query, command, projection, admin view, support view, provider event, device record, CMS target, financial record, AI context, pgvector source, analytics report, export, audit event, fallback record, and reconciliation process must carry and enforce tenant/store scope.

### T-32

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §29 Final Rule
- 라인: L764
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1118 `| `010004` | §7 — `TI-13` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |`
- Evidence type: C/E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Tenant A data must never appear in Tenant B context.

### T-33

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §29 Final Rule
- 라인: L766
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1118 `| `010004` | §7 — `TI-13` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |`
- Evidence type: E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Cross-tenant access is denied by default.

### T-34

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §2 Core Position
- 라인: L25
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> No tenant scope, no processing.  

### T-35

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §2 Core Position
- 라인: L35-L37
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Tenant isolation is not a database feature only.
>
> It is an envelope that wraps every data movement.

### T-36

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §4 Scope Dimension Catalog
- 라인: L91
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: A
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> | `tenant_id` | SaaS tenant/customer organization |

### T-37

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §4 Scope Dimension Catalog
- 라인: L114
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: B
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Scope dimensions may be nullable only if the object type explicitly does not require them.

### T-38

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §5 Mandatory Envelope Fields
- 라인: L120-L145
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: A/B
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Every scoped object should carry:
>
> | Field | Meaning |
> |---|---|
> | `scope_envelope_id` | Unique envelope id |
> | `scope_version` | Envelope schema version |
> | `tenant_id` | Tenant scope |
> | `store_id` | Store scope if applicable |
> | `brand_id` | Brand scope if applicable |
> | `operating_group_id` | Operating group if applicable |
> | `legal_entity_id` | Legal/accounting scope if applicable |
> | `franchise_group_id` | Franchise group if applicable |
> | `provider_id` | Provider scope if applicable |
> | `device_id` | Device scope if applicable |
> | `actor_id` | Acting identity if applicable |
> | `role_id` | Role context if applicable |
> | `surface_id` | Source surface |
> | `session_id` | Session context |
> | `authority_scope` | Action authority scope |
> | `visibility_scope` | Projection/query visibility |
> | `data_class` | Data classification |
> | `masking_class` | Masking class |
> | `policy_version` | Policy version |
> | `scope_hash` | Hash of scope fields for tamper detection |
> | `scope_validated_at` | Scope validation timestamp |
> | `scope_validation_status` | Validation result |

### T-39

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §5 Mandatory Envelope Fields
- 라인: L147
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Envelope must be attached before routing, projection, or mutation.

### T-40

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §42 Final Rule
- 라인: L1012
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Every data object, command, query, projection, event, evidence packet, audit record, reconciliation case, DLQ record, export, AI context, vector record, analytics aggregate, provider callback, device event, sensor observation, physical command, financial ledger line, and policy decision must carry a tenant scope envelope.

### T-41

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §42 Final Rule
- 라인: L1016
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: E
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> If scope is missing, mismatched, dropped, unverifiable, or cross-tenant unsafe, the object must be denied, quarantined, or routed to DLQ.

### T-42

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §42 Final Rule
- 라인: L1018
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 "다만 600021 / 601902 가 명시적으로 채택 · 구속한 section / scope 에 한해 POLICY_INCLUDED_BY_REFERENCE 로 취급한다." · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …` 
- Evidence type: C
- 대조 결과: VERIFIED (신규 발췌 · 원문 직접 인용)

> Tenant isolation is not optional.

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
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 완료 (Tenant Delta · §7) — §2 Core Principle 은 601902 §7 L1118 의 010004 채택 절(§7 · §19 · §20 · §24 · §26 · §29) 밖
- Evidence type: A/C
- 대조 결과: VERIFIED

> Every object must know its tenant.  

### C-2

- 문서번호: 010004
- 파일: 위와 같음
- 라인: L39 (§2 Core Principle)
- Authority: CONDITIONAL
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 완료 (Tenant Delta · §7) — §2 Core Principle 은 601902 §7 L1118 의 010004 채택 절(§7 · §19 · §20 · §24 · §26 · §29) 밖
- Evidence type: C/E
- 대조 결과: VERIFIED

> No tenant may ever see, infer, retrieve, aggregate, search, export, or act upon another tenant’s data unless a separately authorized cross-tenant governance role exists.

### C-3

- 문서번호: 010004
- 파일: 위와 같음
- 라인: L43 (§2 Core Principle)
- Authority: CONDITIONAL
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 완료 (Tenant Delta · §7) — §2 Core Principle 은 601902 §7 L1118 의 010004 채택 절(§7 · §19 · §20 · §24 · §26 · §29) 밖
- Evidence type: E
- 대조 결과: VERIFIED

> `CROSS_TENANT_ACCESS_DENIED`

### C-4

- 문서번호: 010004
- 파일: 위와 같음
- 라인: L78 (§4 Mandatory Context Fields)
- Authority: CONDITIONAL
- 사유: planning-only (L13) · HD-AMB-02 채택 범위 대조 완료 (Tenant Delta · §7) — §4 Mandatory Context Fields 는 601902 §7 L1118 의 010004 채택 절(§7 · §19 · §20 · §24 · §26 · §29) 밖
- Evidence type: A/B
- 대조 결과: VERIFIED

> | `tenant_id` | Required for all tenant-owned objects |

## §3 Coverage Matrix — Tenant 행 (1차 판정)

| Module | A Entity | B Constraint | C Ownership | D Authority | E Failure | F API Boundary |
|---|---|---|---|---|---|---|
| Tenant | FOUND | FOUND | FOUND | FOUND | FOUND | NOT_FOUND |

| 칸 | 근거 |
|---|---|
| A Entity | T-1 · T-3 (INCLUDED). T-13 은 테이블 구조를 비범위로 명시하나 DOCUMENT_SCOPE_FACT 이며 current-authority 가 아니므로 Coverage Matrix · Required Invariant 의 FOUND 근거로 사용하지 않는다 — §0 Authority 지위 정의 참조 |
| B Constraint | T-3 · T-10 |
| C Ownership | CONDITIONAL → FOUND (Tenant Delta · §7). T-18 · T-21 · T-22 (INCLUDED · HD-AMB-01) · T-31 · T-32 · T-35 · T-40 (POLICY_INCLUDED_BY_REFERENCE · HD-AMB-02) · T-7. C-1 · C-4 는 여전히 CONDITIONAL 이라 근거로 쓰지 않았다 |
| D Authority | T-4 · T-5 · T-6 |
| E Failure | T-5 · T-7 · T-8 · T-11 |
| F API Boundary | NOT_FOUND — T-12 (명시적 비범위) |

1차 판정 대비 변경: C Ownership CONDITIONAL → FOUND (Tenant Delta · §7.7). 그 외 칸 변경 없음.

## §4 Required Invariant — Tenant 해당 행 (1차 판정)

| # | Required invariant | Status | Source | Lines |
|---|---|---|---|---|
| 1 | Tenant identity / tenant boundary | FOUND (CONDITIONAL → FOUND · Tenant Delta §7) | 601702 (INCLUDED · HD-AMB-01) T-15 · 010640 (POLICY_INCLUDED_BY_REFERENCE · HD-AMB-02) T-36 · 010004 (POLICY_INCLUDED_BY_REFERENCE · HD-AMB-02) T-32 | 601702 L439-L440 · 010640 L91 · 010004 L764 |
| 5 | Tenant lifecycle / isolation deny rule | FOUND | 601902 (INCLUDED) T-8 · T-7 | L594-L597 · L574-L591 |
| 9 | fail-closed behavior | FOUND | 601902 (INCLUDED) T-7 | L590-L591 |

1차 판정 대비 변경: Required 1 CONDITIONAL → FOUND (Tenant Delta · §7.7). 5 · 9 변경 없음.

## §5 미결 사항

- RESOLVED (§7 Tenant Delta) — HD-AMB-01 · HD-AMB-02 반영 delta 수행 (§7.1 ~ §7.7)
- RESOLVED (§7 Tenant Delta) — 601702 Tenant 선언 발췌 (T-15 ~ T-27 · §7.3)
- RESOLVED (§7 Tenant Delta) — POLICY_INCLUDED_BY_REFERENCE 채택 범위 Tenant evidence 확인 (C-1 ~ C-4 재판정 §7.2 · T-28 ~ T-42 §7.3)
- T-13 (601902 §5) 지위 DOCUMENT_SCOPE_FACT — 정식 HD 번호 부여는 000752 SESSION END 갱신에서 수행
- 최종 상태: SCAN_IN_PROGRESS · NOT YET EVALUATED

## §6 근거

| 문서 | 인용 | 비고 |
|---|---|---|
| `000752_Register_Current_Project_Baseline.md` | §7 next ONE action · §4 Canonical Design Invariant 발췌 판정 규칙 ①②③ · §0 L5 · §9 L555 · L290 · L303 | A overlay |
| `601902_Register_Stage1_Business_Rules.md` | §0.3 L54-L62 계약 동결 (본 문서 생성 시 원문 확인) · §1.2 · §1.3 · §1.4 · §1.8 · §1.12 · §1.13 · §1.14 · §5 | INCLUDED (T-13 제외) |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | L13 · L27 · L39 · L43 · L78 | CONDITIONAL |

## 7. Tenant Delta (HD-AMB-01 / HD-AMB-02)

### 7.1 Provenance

작업 기준 — HEAD `e6e6c51` · ahead 0 · behind 0 · working tree clean · Check-Governance TOTAL 509 (작업 시작 시 실측).

`000752_Register_Current_Project_Baseline.md` §3 원문:

> | `HD-AMB-01` | 2026-09-26 KST | provenance: Human approval in ChatGPT conversation, 2026-09-26 KST · 확인: Claude Chat conversation record, 2026-09-26 08:49 KST · 사용자 문장 "제가 확인하고 승인했습니다" | 0-A authority 판정 범위 — 전문은 아래 `HD-AMB-01` 블록 |

— L110

> HD-AMB-01 · 2026-09-26 KST · APPROVED

— L117

> | `HD-AMB-02` | 2026-09-26 KST | provenance: Human approval in ChatGPT conversation, 2026-09-26 KST · 확인: Claude Chat conversation record, 2026-09-26 08:49 KST · 사용자 문장 "제가 확인하고 승인했습니다" | POLICY_INCLUDED_BY_REFERENCE 지위 신설 — 전문은 아래 `HD-AMB-02` 블록 |

— L111

> HD-AMB-02 · 2026-09-26 KST · APPROVED

— L174

두 HD 모두 STATUS = APPROVED 이다. AUTHORITY_DECISION_MISSING 없음.

601702 authority 판정 — HD-AMB-01 (L128-L136) 이 601702 를 새 0-A authority path 로 두고
"현재 설계 evidence 로서의 authority 를 인정한다" (L136). 따라서 601702 Tenant evidence = `INCLUDED (HD-AMB-01)`.

HD-AMB-02 채택 범위 — 000752 L203-L213 · 601902 §7 L1118 (010004) · L1119 (010640).

### 7.2 STEP 2-A — C-1 ~ C-4 재판정

| C-N | 출처 절 | 이전 | 이후 | 근거 |
|---|---|---|---|---|
| C-1 | 010004 §2 L27 | CONDITIONAL | CONDITIONAL | §2 는 601902 §7 L1118 채택 절(§7 · §19 · §20 · §24 · §26 · §29) 밖 |
| C-2 | 010004 §2 L39 | CONDITIONAL | CONDITIONAL | 같음 |
| C-3 | 010004 §2 L43 | CONDITIONAL | CONDITIONAL | 같음 |
| C-4 | 010004 §4 L78 | CONDITIONAL | CONDITIONAL | §4 는 채택 절 밖 |

C-N 의 인용문 · 라인은 바꾸지 않았다. §2 의 "사유" 필드만 대조 완료로 갱신했다.

### 7.3 STEP 2-B — 신규 evidence · ALREADY_COVERED

**신규 evidence (§1 T-15 ~ T-42 · 28건)**

| ID | 출처 | 라인 | type | Authority |
|---|---|---|---|---|
| T-15 | 601702 §1.22 | L439-L440 | A/C | INCLUDED (HD-AMB-01) |
| T-16 | 601702 §1.22 | L445 | A/B | INCLUDED (HD-AMB-01) |
| T-17 | 601702 §1.22 | L465 | A/C | INCLUDED (HD-AMB-01) |
| T-18 | 601702 §1.26 | L564 | C | INCLUDED (HD-AMB-01) |
| T-19 | 601702 §1.36 | L908-L916 | A/C | INCLUDED (HD-AMB-01) |
| T-20 | 601702 §1.40 | L1081 | A/C | INCLUDED (HD-AMB-01) |
| T-21 | 601702 §1.40 | L1086-L1099 | A/C | INCLUDED (HD-AMB-01) |
| T-22 | 601702 §1.41 | L1142-L1143 | C | INCLUDED (HD-AMB-01) |
| T-23 | 601702 §1.44 | L1275 | B | INCLUDED (HD-AMB-01) |
| T-24 | 601702 §1.45 | L1305 | B/E | INCLUDED (HD-AMB-01) |
| T-25 | 601702 §1.45 | L1314-L1317 | B | INCLUDED (HD-AMB-01) |
| T-26 | 601702 §1.45 | L1346 | B | INCLUDED (HD-AMB-01) |
| T-27 | 601702 §1.45 | L1349-L1350 | B | INCLUDED (HD-AMB-01) |
| T-28 | 010004 §19 | L525-L527 | E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-29 | 010004 §20 | L533 | E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-30 | 010004 §20 | L560 | E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-31 | 010004 §29 | L760 | C | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-32 | 010004 §29 | L764 | C/E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-33 | 010004 §29 | L766 | E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-34 | 010640 §2 | L25 | E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-35 | 010640 §2 | L35-L37 | C | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-36 | 010640 §4 | L91 | A | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-37 | 010640 §4 | L114 | B | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-38 | 010640 §5 | L120-L145 | A/B | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-39 | 010640 §5 | L147 | E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-40 | 010640 §42 | L1012 | C | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-41 | 010640 §42 | L1016 | E | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |
| T-42 | 010640 §42 | L1018 | C | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) |

T-21 의 목록에는 사용자 계정 · 직원 소속 · Role 등 다른 모듈 항목이 함께 있다.
원문 한 덩어리이므로 쪼개지 않고 인용했으며, Tenant 판정에는 tenant 귀속 · 격리 · ownership boundary 항목만 쓴다.

**ALREADY_COVERED**

| 원문 | 판정 | 사유 |
|---|---|---|
| 601702 §1.28 L638-L647 | ALREADY_COVERED (T-3) | 601902 TI-12 가 §1.28 을 승계했다 (601902 L545). 601702 L647 과 T-3 (601902 L497-L498) 이 같은 문장이다 |
| 010004 §7 L223-L243 | ALREADY_COVERED (T-7) | 601902 TI-13 이 L571 에서 010004 §7 을 채택해 같은 규칙을 인용했다 (T-7) |

### 7.4 DEFERRED_TO_MODULE

| 모듈 | 원문 위치 |
|---|---|
| DEFERRED_TO_MODULE (Store) | 601702 §1.26 L552-L562 (구조 경로 Tenant → MerchantAccount → Store) · L566-L569 (모든 Store 는 Tenant scope 를 보유하고 검증) · §1.24 · §1.27 · 010004 §29 L762 · 010640 §2 L26 |
| DEFERRED_TO_MODULE (Actor / Access Membership) | 601702 §1.14 L252-L253 · §1.16 · §1.17 · T-21 목록의 사용자 계정 · 직원 소속 항목 |
| DEFERRED_TO_MODULE (Authority Kernel) | 601702 §1.15 · §1.19 · §1.20 · §1.42 L1171-L1172 · §1.45 L1380-L1416 (fail-closed posture · 0-C 책임) · 010630 채택 범위 전체 (authority gate family · SCOPE_GATE · multi-party · §6 · §28) · 010640 §2 L31 · §6 · 010650 §35 |
| DEFERRED_TO_MODULE (register_waiting) | 없음 |

**모듈 배정 없음 — 이번 5개 모듈 발췌 범위 밖**

```text
601702 §1.23 · §1.25 · §1.31 · §1.34 · §1.35   LegalEntity · 금전 축
601702 §1.43                                  외부 provider 연동 (POS · 결제 범위 제외)
010660 §4 · §5 · §6                           idempotency — 이번 5개 모듈에 직접 해당 없음
010004 §24 · §26 · §29 L768 · L770            coding authorization / runtime deferral 절차 규칙
010640 §42 L1020                              같은 성격
010650 "circuit breaker scope"                채택 범위가 절 번호로 특정되지 않음.
                                              결론은 601902 TI-2 (T-1 · T-2) 가 담고 있다
```

### 7.5 STEP 3 · STEP 4 잠정값

| Coverage | 1차 | 잠정 | 근거 |
|---|---|---|---|
| A Entity | FOUND | 변경 없음 | T-1 · T-3 · T-15 · T-36 |
| B Constraint | FOUND | 변경 없음 | T-3 · T-10 · T-16 · T-23 · T-24 · T-25 · T-26 · T-27 · T-37 · T-38 |
| C Ownership | CONDITIONAL | FOUND | T-18 · T-21 · T-22 · T-31 · T-32 · T-35 · T-40 · T-7 |
| D Authority | FOUND | 변경 없음 | T-4 · T-5 · T-6 |
| E Failure | FOUND | 변경 없음 | T-5 · T-7 · T-8 · T-11 · T-24 · T-28 · T-29 · T-30 · T-33 · T-34 · T-39 · T-41 |
| F API Boundary | NOT_FOUND | 변경 없음 | T-12 (명시적 비범위). delta 에서 Tenant 범위 F evidence 없음 — 601702 §1.15 는 Authority Kernel 로 이관 |

| Required | 1차 | 잠정 | 근거 |
|---|---|---|---|
| 1 Tenant identity / tenant boundary | CONDITIONAL | FOUND | T-15 · T-36 · T-32 |
| 5 Tenant lifecycle / isolation deny rule | FOUND | 변경 없음 | T-8 · T-7 |
| 9 fail-closed behavior | FOUND | 변경 없음 | T-7 · T-34 · T-41 |

### 7.6 STEP 5 — CONFLICT

```text
CONFLICT-01
  주제        scope envelope 필드 보유 의무의 강도
  evidence A  T-38 (010640 §5 L120 · POLICY_INCLUDED_BY_REFERENCE)
              "Every scoped object should carry:" + 필드 22개 표
  evidence B  T-11 (601902 TI-8 L367 · INCLUDED)
              "010640 §5 의 모든 후보 필드를 무조건 보유    NOT REQUIRED"
  판정        PRECEDENCE_RESOLVED (우선 authority = T-11)
  사유        T-11 (601902) 과 T-38 (010640) 은 모두 B tier 문서이므로
              B 내부 우열로 결정되지 않는다.

              결정 근거는 A overlay 이다.
                HD-AMB-02 (000752 L187-L189 · L195) 가
                채택 문서의 효력 범위를
                "601902 가 채택한 section / scope 까지" 로 한정했다.
                  L187-L189  "다만 600021 / 601902 가 명시적으로 채택 · 구속한
                              section / scope 에 한해
                              POLICY_INCLUDED_BY_REFERENCE 로 취급한다."
                  L195       "- 상위 문서가 실제로 채택한 section / scope 까지만 효력 인정"

                그 601902 가 TI-8 (L367) 에서
                010640 §5 를 직접 지목해 의무 강도를 정했다.
                  L367       "010640 §5 의 모든 후보 필드를 무조건 보유    NOT REQUIRED"

              따라서 T-11 이 우선한다.
              T-38 의 효력은 T-11 이 정한 범위까지다.
```

그 외 current-authority evidence 사이의 충돌은 발견하지 못했다.

### 7.7 STEP 5-A — 최종값

CONFLICT-01 은 PRECEDENCE_RESOLVED 이며 우선 authority T-11 은 이미 E Failure 근거에 있다.
B Constraint 의 최종 근거에서 T-38 을 뺀다 (필드 보유 의무 강도가 T-11 로 한정되므로). FOUND 판정은 T-38 없이도 유지된다.

| 항목 | 잠정 | 최종 | 변경 사유 |
|---|---|---|---|
| A Entity | FOUND | FOUND | — |
| B Constraint | FOUND | FOUND | 근거에서 T-38 제외 (CONFLICT-01) · 값 동일 |
| C Ownership | FOUND | FOUND | — |
| D Authority | FOUND | FOUND | — |
| E Failure | FOUND | FOUND | — |
| F API Boundary | NOT_FOUND | NOT_FOUND | — |
| Required 1 | FOUND | FOUND | — |
| Required 5 | FOUND | FOUND | — |
| Required 9 | FOUND | FOUND | — |

§3 · §4 에는 이 최종값을 기록했다. 값이 바뀐 칸은 §3 C Ownership (CONDITIONAL → FOUND) 과 §4 Required 1 (CONDITIONAL → FOUND) 두 곳이다.

UNRESOLVED conflict 0건.

### 7.8 이전 절 표기와의 관계

§0 "HD-AMB-01 · HD-AMB-02 반영 delta 는 아직 적용되지 않았다" 와
§5 미결 사항의 첫 세 항목 (delta 미수행 · 601702 미발췌 · 채택 범위 미확인) 은
이 §7 로 수행되었다. Tenant Delta 작성 시점에는 기존 절의 문구를 고치지 않았고,
이후 커밋 전 정합화에서 §0 문장은 시점을 명시한 서술로, §5 세 항목은 RESOLVED 표기로 바꿨다.

전체 상태: SCAN_IN_PROGRESS · Final status NOT YET EVALUATED
