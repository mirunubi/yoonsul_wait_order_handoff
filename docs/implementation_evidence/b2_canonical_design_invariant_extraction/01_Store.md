# 01_Store.md

Status: Active
Lifecycle: Evidence
DocumentType: Evidence
Last Updated: 2026-09-27

## 0. 성격 · provenance

Canonical Migration B2 의 Canonical Design Invariant 원문 발췌 중 Store 모듈이다 (5개 모듈 중 2번째).

이 문서는 설계도 구현도 아니다.
"현재 승인된 설계가 실제로 무엇이라고 말하는가" 의 증거다.

**발췌 기준**

```text
발췌 시각      2026-09-27 10:22 KST
Git HEAD      fa34f7a (origin/main 과 동일 · ahead 0 · behind 0)
working tree  clean (이 문서 생성 전)
Governance    TOTAL 509
```

**evidence ID 규칙**

```text
S-N          Store 모듈 current-authority evidence
             (INCLUDED · POLICY_INCLUDED_BY_REFERENCE)
CS-N         Store 모듈 CONDITIONAL evidence
XREF (T-N)   00_Tenant.md 의 current-authority evidence 를 Store 판정 근거로 참조
XREF (C-N)   00_Tenant.md 의 CONDITIONAL evidence 를 참조 (CONDITIONAL 근거로만)
OBSERVATION_ONLY
             AUTHORITY_UNVERIFIED · DOCUMENT_SCOPE_FACT 후보.
             ID 를 발급하지 않고 §6 에만 기록한다.
             §3 · §4 의 FOUND · CONDITIONAL 근거와 conflict 대조에 쓰지 않는다.
T-N 접두어는 이 문서에서 새로 발급하지 않는다.
```

**인용 표기 규칙**

```text
인용 블록의 각 줄은 원문 줄에 "> " 접두만 붙여 그대로 옮겼다.
원문 빈 줄은 ">" 로 옮겼다.
떨어진 줄을 하나의 인용으로 합치지 않았다.
00_Tenant.md 의 인용문은 복제하지 않고 XREF 로만 참조한다 (§8).
```

### Authority 지위 정의

출처: `00_Tenant.md` §0 `### Authority 지위 정의` (L46-L81). 정의를 변경하지 않고 그대로 옮긴다.


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


### Authority 결정 확인

`000752_Register_Current_Project_Baseline.md` §3 원문:

> HD-AMB-01 · 2026-09-26 KST · APPROVED

— L117

> HD-AMB-02 · 2026-09-26 KST · APPROVED

— L174

두 HD 모두 APPROVED 이다. AUTHORITY_DECISION_MISSING 없음.

### Tenant 모듈 handoff 출처

`00_Tenant.md` §7.4 L1007 원문:

> | DEFERRED_TO_MODULE (Store) | 601702 §1.26 L552-L562 (구조 경로 Tenant → MerchantAccount → Store) · L566-L569 (모든 Store 는 Tenant scope 를 보유하고 검증) · §1.24 · §1.27 · 010004 §29 L762 · 010640 §2 L26 |

**handoff 처리 결과 (6항목 · 누락 0)**

| # | handoff 항목 | 처리 결과 | 비고 |
|---|---|---|---|
| H1 | 601702 §1.26 L552-L562 | S-6 | — |
| H2 | 601702 §1.26 L566-L569 | S-7 | 사이의 L564 는 XREF (T-18) |
| H3 | 601702 §1.24 (L497-L513) | S-5 (L504) | L499-L511 의 나머지는 NOT_A_NORMATIVE_RULE (근거 성격 구분표 · 601501 배경 서술). L512-L513 은 NOT_A_NORMATIVE_RULE (확정 범위 한정 서술 — cardinality · 시점 이력은 2단계 ERD 로 넘김) |
| H4 | 601702 §1.27 (L586-L634) | S-10 (L588-L597) | L599-L612 NOT_A_NORMATIVE_RULE (000170 예시 인용). L615-L624 NOT_A_NORMATIVE_RULE (확정하지 않는 범위 서술). L626-L633 NOT_A_NORMATIVE_RULE (현재 physical schema 사실 기록) |
| H5 | 010004 §29 L762 | S-12 | — |
| H6 | 010640 §2 L26 | S-13 | — |

handoff 항목도 중복 검사를 거쳤다. 6항목 모두 T-1 ~ T-42 · C-1 ~ C-4 의 라인 범위와 겹치지 않는다.

## 1. Verbatim Evidence (S-1 ~ S-15)

### S-1

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 절: §1.8 TI-8
- 라인: L383
- 출처: STEP 2-B
- Authority: INCLUDED (601902 §0.3)
- Authority 근거: 601902 §0.3 L60 "TI-1 ~ TI-15 는 정책 계약으로 확정한다" — §1.8 TI-8 (L362) 본문
- Evidence type: B/E
- 대조 결과: VERIFIED (원문 직접 인용)

> **`store` · legal entity · provider 는 해당 사건이 실제 그 scope 에 걸릴 때 필수가 된다.**

### S-2

- 문서번호: 601902
- 파일: `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md`
- 절: §1.12 TI-12
- 라인: L507-L518
- 출처: STEP 2-B
- Authority: INCLUDED (601902 §0.3)
- Authority 근거: 601902 §0.3 L60 — §1.12 TI-12 (L484) 본문
- Evidence type: B
- 대조 결과: VERIFIED (원문 직접 인용)

> **나머지 4축**
>
> ```text
> MerchantAccountStatus
> StoreServiceStatus
> StoreOperatingStatus
> TrialStatus
>
> 이 나선의 직접 변경 대상이 아니다
> 두 소유 축에서 자동으로 파생되지 않는다
> 접근 판단에서 참조가 필요하면 명시적 precondition 으로만 사용한다
> ```

### S-3

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.14
- 라인: L248-L249
- 출처: STEP 2-B
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B/C
- 대조 결과: VERIFIED (원문 직접 인용)

> - 한 MerchantAccount가 여러 브랜드의 Store를 포함할 수 있다
>   (`020320` §40: *merchant account scope may include multiple stores*)

### S-4

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.23
- 라인: L473
- 출처: STEP 2-B
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B/C
- 대조 결과: VERIFIED (원문 직접 인용)

> **하나의 MerchantAccount 는 서로 다른 LegalEntity 가 운영하는 복수 Store 를 포함할 수 있다.**

### S-5

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.24
- 라인: L504
- 출처: STEP 2-A handoff (§1.24)
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/B
- 대조 결과: VERIFIED (원문 직접 인용)

> | Human Business Rule | **각 Store 는 현재 시점의 법적 운영주체를 명시적으로 가져야 한다** |

### S-6

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.26
- 라인: L552-L562
- 출처: STEP 2-A handoff (§1.26 L552-L562)
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B/C
- 대조 결과: VERIFIED (원문 직접 인용)

> **Conceptual 구조 경로는 하나로 둔다.**
>
> ```text
> Tenant
>   │ 1:1 (§1.22, 이번 나선)
>   ▼
> MerchantAccount
>   │ 1:N
>   ▼
> Store
> ```

### S-7

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.26
- 라인: L566-L569
- 출처: STEP 2-A handoff (§1.26 L566-L569)
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B/C
- 대조 결과: VERIFIED (원문 직접 인용)

> > **Invariant**: 모든 Store 는 Tenant scope 를 보유하고 검증해야 한다.
> > 물리 스키마가 `stores.tenant_id` 를 직접 보유하는 것은
> > 격리·RLS·조회 효율을 위한 것이며,
> > **개념적 두 번째 소유 계층을 만들지 않는다.**

### S-8

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.26
- 라인: L571-L573
- 출처: STEP 2-B
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: C
- 대조 결과: VERIFIED (원문 직접 인용)

> `010640` 은 Tenant isolation 과 Store isolation 을 별도의 강제 scope boundary 로 요구한다(§7·§8).
> `010004` §4는 tenant-owned 객체에 `tenant_id` 를 필수로 요구한다.
> **이 요건들은 격리 invariant 로 유지되며 구조 관계와 구분한다.**

### S-9

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.26
- 라인: L578-L581
- 출처: STEP 2-B
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/C
- 대조 결과: VERIFIED (원문 직접 인용)

> | 관계 | 답하는 질문 |
> |---|---|
> | MerchantAccount → Store | 어느 CatchMenu 고객 관리범위에 속하는가 |
> | LegalEntity → Store | 누가 이 Store 의 법적 운영주체인가 |

### S-10

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.27
- 라인: L588-L597
- 출처: STEP 2-A handoff (§1.27)
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: A/B
- 대조 결과: VERIFIED (원문 직접 인용)

> Store 의 상태를 하나의 범용 `store_status` 로 표현하지 않는다.
> 최소한 아래 **세 의미축을 서로 독립된 개념**으로 구분한다.
>
> | 축 | 묻는 질문 |
> |---|---|
> | **Store Service Status** | 해당 Store 에 대한 CatchMenu 서비스 제공 상태는 무엇인가 |
> | **Store Operating Status** | 실제 음식점이 영업 중인가 |
> | **Trial Status** | CatchMenu 체험·전환 lifecycle 이 어디까지 갔는가 |
>
> **한 축의 값으로 다른 축의 상태를 추론하지 않는다.**

### S-11

- 문서번호: 601702
- 파일: `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md`
- 절: §1.45
- 라인: L1352-L1356
- 출처: STEP 2-B
- Authority: INCLUDED (HD-AMB-01)
- Authority 근거: 000752 L117 `HD-AMB-01 · 2026-09-26 KST · APPROVED` · L128-L129 "601700 / 601702 는 600020 §2 가 요구한 재검증 절차에 따라 수행되는 새 0-A authority path" · L136 "현재 설계 evidence 로서의 authority 를 인정한다"
- Evidence type: B/C
- 대조 결과: VERIFIED (원문 직접 인용)

> Store 는 §1.26 의 축을 따른다.
>
> ```text
> Store → MerchantAccount → Tenant
> ```

### S-12

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §29 Final Rule
- 라인: L762
- 출처: STEP 2-A handoff (010004 §29 L762)
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 · 601902 §7 L1118 `| `010004` | §7 — `TI-13` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |`
- Evidence type: C/E
- 대조 결과: VERIFIED (원문 직접 인용)

> A Store A record must never appear in Store B context.

### S-13

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §2 Core Position
- 라인: L26
- 출처: STEP 2-A handoff (010640 §2 L26)
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …`
- Evidence type: E
- 대조 결과: VERIFIED (원문 직접 인용)

> No store scope for store-level action, no processing.

### S-14

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §4 Scope Dimension Catalog
- 라인: L92
- 출처: STEP 2-B
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …`
- Evidence type: A
- 대조 결과: VERIFIED (원문 직접 인용)

> | `store_id` | Individual store or outlet |

### S-15

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §42 Final Rule
- 라인: L1014
- 출처: STEP 2-B
- Authority: POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02)
- Authority 근거: 000752 L174 `HD-AMB-02 · 2026-09-26 KST · APPROVED` · L187-L189 · 601902 §7 L1119 `| `010640` | §2 · §4 · §5 · §6 · §42. …`
- Evidence type: C
- 대조 결과: VERIFIED (원문 직접 인용)

> Scope must include tenant, store, legal entity, provider, device, actor, role, surface, authority, visibility, policy, and data classification context as applicable.

## 2. CONDITIONAL Evidence (CS-1 ~ CS-5)

### CS-1

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §2 Core Principle
- 라인: L28
- 출처: STEP 2-B
- Authority: CONDITIONAL
- Authority 근거: 010004 L13 "This document is planning-only." · §2 는 601902 §7 L1118 채택 절(§7 · §19 · §20 · §24 · §26 · §29) 밖
- Evidence type: A/C
- 대조 결과: VERIFIED (원문 직접 인용)

> Every store-scoped object must know its store.

### CS-2

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §4 Mandatory Context Fields
- 라인: L79
- 출처: STEP 2-B
- Authority: CONDITIONAL
- Authority 근거: 010004 L13 "This document is planning-only." · §4 는 601902 §7 L1118 채택 절 밖
- Evidence type: A/B
- 대조 결과: VERIFIED (원문 직접 인용)

> | `store_id` | Required for store-scoped objects |

### CS-3

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §8 Store Isolation Rule
- 라인: L249-L251
- 출처: STEP 2-B
- Authority: CONDITIONAL
- Authority 근거: 010004 L13 "This document is planning-only." · §8 은 601902 §7 L1118 채택 절 밖
- Evidence type: C
- 대조 결과: VERIFIED (원문 직접 인용)

> Within the same tenant, store isolation still matters.
>
> A tenant may operate multiple stores.

### CS-4

- 문서번호: 010004
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md`
- 절: §8 Store Isolation Rule
- 라인: L276
- 출처: STEP 2-B
- Authority: CONDITIONAL
- Authority 근거: 010004 L13 "This document is planning-only." · §8 은 601902 §7 L1118 채택 절 밖
- Evidence type: C/E
- 대조 결과: VERIFIED (원문 직접 인용)

> Store scope must be explicit.

### CS-5

- 문서번호: 010640
- 파일: `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md`
- 절: §8 Store Isolation Boundary
- 라인: L204-L216
- 출처: STEP 2-B
- Authority: CONDITIONAL
- Authority 근거: 010640 L13 "This document is planning-only." · §8 은 601902 §7 L1119 채택 절(§2 · §4 · §5 · §6 · §42) 밖
- Evidence type: C/E
- 대조 결과: VERIFIED (원문 직접 인용)

> Store isolation is mandatory inside a tenant.
>
> Store A order must not appear in Store B staff surface.
>
> Store A POS event must not update Store B KDS.
>
> Store A settlement line must not appear in Store B payout.
>
> Store A no-show penalty must not affect Store B customer policy.
>
> Store A device must not issue commands for Store B.
>
> Store A local mesh event must not sync into Store B.

## 3. Coverage Matrix — Store row

| Module | A Entity | B Constraint | C Ownership | D Authority | E Failure | F API Boundary |
|---|---|---|---|---|---|---|
| Store | FOUND | FOUND | FOUND | FOUND | FOUND | NOT_FOUND |

| 칸 | 근거 |
|---|---|
| A Entity | S-5 · S-9 · S-10 · S-14 |
| B Constraint | S-2 · S-3 · S-4 · S-5 · S-6 · S-7 · S-10 · S-11 |
| C Ownership | S-6 · S-7 · S-8 · S-11 · S-12 · S-15 · XREF (T-18) · XREF (T-31) |
| D Authority | XREF (T-7) — 허용 조건 "resolved store context if applicable". store authority 판정 지점 자체는 Authority Kernel 모듈 (§4 Required 8) |
| E Failure | S-1 · S-12 · S-13 · XREF (T-41) |
| F API Boundary | NOT_FOUND — Store 범위의 Public API ↔ internal function 경계 원문 없음 |

CONDITIONAL 근거 (CS-1 ~ CS-5) 는 FOUND 근거로 쓰지 않았다.
OBSERVATION_ONLY 항목은 어느 칸의 근거로도 쓰지 않았다.

### 3.1 STEP 5 · STEP 5-A — Conflict 및 최종 확정

**CONFLICT: NONE**

대조 대상 — S-1 ~ S-15 와 current-authority XREF (T-2 · T-3 · T-7 · T-11 · T-18 · T-19 · T-21 · T-31 · T-38 · T-41).
같은 주제에 서로 다른 normative rule 을 말하는 쌍을 찾지 못했다.
S-6 · S-7 · S-11 · T-18 은 모두 "구조 부모 = MerchantAccount · Tenant = 필수 격리 scope" 로 일치한다.

잠정값 = 최종값. §3 · §4 에 기록한 값이 STEP 5-A 최종값이다.

## 4. Required Invariant

| # | Required invariant | Status | Source | Lines |
|---|---|---|---|---|
| 2 | Store → Tenant ownership | FOUND | 601702 (INCLUDED · HD-AMB-01) S-6 · S-7 · S-11 · XREF (T-18) | 601702 L552-L562 · L566-L569 · L1352-L1356 · L564 |
| 4 | Actor → Store access 또는 그 규칙 | NOT YET EVALUATED (Actor / Access Membership) | 근거 후보: 010004 §8 L253 · L274 (CONDITIONAL) · 010640 §8 L218 (CONDITIONAL) · 601702 §1.14 L252-L253 (INCLUDED · HD-AMB-01) | — |
| 8 | store authority resolution | NOT YET EVALUATED (Authority Kernel) | 근거 후보: XREF (T-7) · 010640 §6 L164 `SCOPE_STORE_MISMATCH` (POLICY_INCLUDED_BY_REFERENCE 채택 절 · Authority Kernel 로 이관) | — |

Required 2 판정 원문 구조 — 601702 는 Store 의 구조 부모를 MerchantAccount 로 두고 (S-6 · S-11),
Tenant 를 "두 번째 구조 부모가 아니라 필수 격리 scope" 로 둔다 (XREF T-18).
모든 Store 가 Tenant scope 를 보유하고 검증해야 한다는 invariant 는 S-7 이다.

## 5. 미결 사항

- 000170 (`Policy_Merchant_Account_Company_And_Store_Context`) 의 authority —
  601902 §7 L1121 이 `ACTIVE — mandatory` 로 인용하지만 HD-AMB-02 대상 문서(000752 L182) 에 없다.
  current authority 결정 근거가 없어 OBSERVATION_ONLY 로 두었다 (§6). Human 판정 필요
- 같은 이유로 601902 §7 L1120 · L1122 의 000150 · 000190 도 HD-AMB-02 대상 밖이다 (이번 Store 발췌에서 사용하지 않음)
- Required 4 · 8 은 각각 Actor / Access Membership · Authority Kernel 모듈에서 판정한다
- 최종 상태: SCAN_IN_PROGRESS · NOT YET EVALUATED

## 6. 근거 문서 목록 · authority 확정 표

| 문서 | 절 | authority | ID 발급 | 근거 원문 | 라인 |
|---|---|---|---|---|---|
| 601902 | TI-1 ~ TI-15 (§1.1 ~ §1.15) | INCLUDED (601902 §0.3) | S-N | "TI-1 ~ TI-15 는 정책 계약으로 확정한다" | 601902 L60 |
| 601902 | §0.3 밖 (예: §5) | DOCUMENT_SCOPE_FACT | 미발급 | §0.3 L60 의 적용 범위 밖 | 601902 L1075 |
| 601702 | 전체 | INCLUDED (HD-AMB-01) | S-N | "HD-AMB-01 · 2026-09-26 KST · APPROVED" · "현재 설계 evidence 로서의 authority 를 인정한다" | 000752 L117 · L136 |
| 010004 | §7 · §19 · §20 · §24 · §26 · §29 | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) | S-N | `| \`010004\` | §7 — \`TI-13\` · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |` | 601902 L1118 · 000752 L174 · L187-L189 |
| 010004 | 그 외 절 (§2 · §4 · §8 등) | CONDITIONAL | CS-N | "This document is planning-only." | 010004 L13 |
| 010640 | §2 · §4 · §5 · §6 · §42 | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) | S-N | `| \`010640\` | §2 · §4 · §5 · §6 · §42. …` | 601902 L1119 · 000752 L174 · L187-L189 |
| 010640 | 그 외 절 (§8 등) | CONDITIONAL | CS-N | "This document is planning-only." | 010640 L13 |
| 010630 | 채택 범위 전체 | POLICY_INCLUDED_BY_REFERENCE (HD-AMB-02) | 미발급 — Authority Kernel guard | 601902 L1123 | — |

**OBSERVATION_ONLY**

| 문서 | 절 | 라인 | base status | 사유 |
|---|---|---|---|---|
| 000170 `Policy_Merchant_Account_Company_And_Store_Context` | §3 · §4 | 601902 L1121 (인용 행) | AUTHORITY_UNVERIFIED | 601902 §7 L1121 이 `ACTIVE — mandatory` 로 인용하나 HD-AMB-02 대상 문서 목록(000752 L182: 010004 · 010630 · 010640 · 010650 · 010660)에 없다. 000170 자체에 Status 줄이 없고, L385 에 `AUTHORITY SUSPENDED` 블록 · L402 에 §14 ~ §16 상태 어휘 SUPERSEDED 표기가 있다 |

AUTHORITY_UNVERIFIED 1건 · DOCUMENT_SCOPE_FACT 0건.

## 7. DEFERRED_TO_MODULE 목록

| 모듈 | 원문 위치 |
|---|---|
| DEFERRED_TO_MODULE (Actor / Access Membership) | 010004 §8 L253 · L274 · 010640 §8 L218 · 601702 §1.14 L252-L253 |
| DEFERRED_TO_MODULE (Authority Kernel) | 010640 §6 L164 (`SCOPE_STORE_MISMATCH`) · store authority resolution 전체 · 010630 채택 범위 전체 |
| DEFERRED_TO_MODULE (register_waiting) | 없음 |

**범위 밖 (모듈 배정 없음)**

```text
601702 §1.23 L482-L484     LegalEntity scope 금전 최종성 — 금전 축
601702 §1.34 · §1.35       LegalEntity 시점 관계 · 금전 snapshot
601702 §1.43 L1204-L1212   외부 provider 연동 예시 (POS · 결제 범위 제외)
```

## 8. XREF 목록

| XREF | 00_Tenant.md 소재 | 원 출처 | 참조 이유 |
|---|---|---|---|
| XREF (T-2) | §1 `### T-2` | 601902 L111-L112 | store 부분 containment 를 tenant.isolation_state 에 넣지 않는다 — Store 격리의 책임 분리 |
| XREF (T-3) | §1 `### T-3` | 601902 L497-L505 | 상위 상태로 하위 상태를 대신하지 않는다 — Store 상태축 (S-2 · S-10) 의 상위 규칙 |
| XREF (T-7) | §1 `### T-7` | 601902 L574-L591 | 허용 조건 "resolved store context if applicable" — D Authority 근거 · Required 8 후보 |
| XREF (T-11) | §1 `### T-11` | 601902 L365-L369 | scope envelope 의무 강도 — S-1 (같은 TI-8) 의 앞 문맥 |
| XREF (T-18) | §1 `### T-18` | 601702 L564 | Tenant 는 Store 의 두 번째 구조 부모가 아니라 필수 격리 scope — Required 2 |
| XREF (T-19) | §1 `### T-19` | 601702 L908-L916 | Store 의 LegalEntity 변경과 Tenant 이전은 다른 사건 |
| XREF (T-21) | §1 `### T-21` | 601702 L1086-L1099 | tenant_id · store_id 및 tenant/store 귀속 목록 |
| XREF (T-31) | §1 `### T-31` | 010004 L760 | 모든 객체가 tenant/store scope 를 보유 · 강제 |
| XREF (T-38) | §1 `### T-38` | 010640 L120-L145 | `store_id` 행 (L127) 포함. 00_Tenant.md CONFLICT-01 에 따라 효력은 T-11 범위까지 |
| XREF (T-41) | §1 `### T-41` | 010640 L1016 | scope 누락 · 불일치 시 거부 · 격리 · DLQ |

XREF (C-N) 는 없다 — 010004 L28 (CS-1) · L79 (CS-2) 는 C-1 (L27) · C-4 (L78) 과 다른 줄이다.

전체 상태: SCAN_IN_PROGRESS · Final status NOT YET EVALUATED
