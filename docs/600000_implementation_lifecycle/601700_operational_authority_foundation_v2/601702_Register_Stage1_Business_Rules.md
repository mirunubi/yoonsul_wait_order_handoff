# 601702_Register_Stage1_Business_Rules.md

Status: Draft
Lifecycle: Register
Last Updated: 2026-08-13

## §0 성격

`000701` §47.1의 **1단계 업무규칙 선언** 산출물이다.
Human 전담이며 AI 위임 불가다. 아래는 Human이 확정한 내용을 그대로 기록한 것이다.

**이 문서는 "무엇을 사실로 삼을지"를 선언한다.** 설계도 구현도 아니다.
테이블·컬럼·값 이름의 구체적 결정은 2단계(ERD) 이후의 일이다.

**선행 증거**: `601701_Register_Stage0_Evidence_Collection.md` (§48 증거수집 A~E, 5개 대상)

## §1 확정 (2026-08-13, Human)

### §1.1 자연인은 `Person`이다

`catchmenu_hq.owners` 테이블이 담는 것은 **자연인**이다.
SaaS 계정 소유자도 아니고 지분 보유자도 아니다(`601501` §2.4.1).
따라서 `owners`라는 이름은 내용과 어긋난다.

이 개념의 명칭은 **`Person`** 으로 한다.

### §1.2 무수식 `Owner`를 금지한다

`Owner`는 **경제적·법적 소유권** 의미에만 예약한다.

```text
사람이라는 이유로 Owner라 부르지 않는다.
대표자라는 이유로 Owner라 부르지 않는다.
관리자라는 이유로 Owner라 부르지 않는다.
책임자라는 이유로 Owner라 부르지 않는다.
로그인 계정이라는 이유로 Owner라 부르지 않는다.
```

무엇의 owner인지 명시하지 않은 `Owner` 단독 표기는 사용하지 않는다.

**근거**: `601701` §4.2 A-4에 `owner` 어휘가 6중으로 충돌한다
(자연인 / 계정 / 책임주체 / RBAC 역할 / 문서 메타 / `role_type` 값).

### §1.3 조직역할과 지분소유는 별개 개념이다

`legal_entity_person_roles.ownership_percent` 는 **역할 테이블에 소유권 컬럼이 얹힌 개념 혼재**다.

문서는 사용 금지 상태로 서술하나(`601501` §2.3.1),
실측에서는 컬럼과 `chk_lepr_ownership_percent`(0~100) 제약이 모두 실재한다
(`601701` §4.2 B-1, C-1 「초과구현」).

지분구조를 모델링한다면 별도 축으로 분리한다. 이번 나선에서 모델링할지는 2단계에서 정한다.

### §1.4 매장의 법적 운영주체와 시스템 권한은 다른 축이다

매장의 법적·계약상 운영 주체는 **LegalEntity 관계로 표현**한다.

RBAC role은 **시스템 권한만** 표현하며, 경제적 소유권이나 가맹계약상 지위를 의미하지 않는다.

직영점과 가맹점의 구분을 사람의 role로 표현하지 않는다.
role 값에서 직영/가맹을 추론하지 않는다.

### §1.5 네 축은 서로 독립이다

```text
                    ┌─ Representative ─ Person
                    │
Store ─ LegalEntity ├─ Person Role ──── Person
                    │
                    └─ Franchise Agreement ─ Brand/HQ LegalEntity

User ───── Store RBAC Role
```

| 축 | 질문 |
|---|---|
| Store → LegalEntity | 누가 이 매장을 법적으로 운영하는가 |
| Representative | 그 사업주체를 법적으로 대표하는 사람은 누구인가 |
| Person Role | 그 사업주체에서 이 사람의 조직적 위치는 무엇인가 |
| Ownership | 누가 그 사업주체의 경제적 지분을 가지고 있는가 |
| Franchise Agreement | 본사와 가맹사업자의 계약관계는 무엇인가 |
| Store RBAC | 누가 시스템에서 이 매장에 무엇을 할 수 있는가 |

**어느 하나로 다른 축을 대체하거나 추론하지 않는다.**

### §1.6 가맹계약은 독립 개념이다

가맹계약의 당사자는 **LegalEntity 간**이다. Store와 Person 사이 관계가 아니다.

`franchise_brands` 는 가맹계약을 대신할 수 없다.
브랜드는 "어느 브랜드인가"이고, 가맹계약은
"누가 누구에게 어떤 조건으로 그 브랜드·사업모델을 운영할 권리를 줬는가"다.

**가맹계약과 Store가 1:1이라고 전제하지 않는다.**
한 가맹사업자가 계약 하나로 여러 점포를 가질 수 있고, 점포별 계약도, 지역개발권 계약도 가능하다.
`Store.franchise_contract_id` 같은 구조를 1단계에서 확정하지 않는다.

## §2 이번 나선에서 정하지 않는 것

### §2.1 과금과 운영권한의 관계

**정하지 않는다.**

`ACTIVE`+`ISOLATED` 상태의 과금 처리는 미결이며 **사업 정책 결정 사항**이다.
기술 결정이 아니다(`601601` §5 Open Item (a)).

이번 나선은 **상태를 기록하는 데까지만** 하고 해석하지 않는다.
"격리 중 과금 중단/계속" 같은 판단을 코드에 넣지 않는다(`601601` §5.1).

이 제약을 어기면 미확정 사업 정책이 코드에 암묵적으로 확정된다.

### §2.2 2단계 이후로 넘기는 항목

| 항목 | 사유 |
|---|---|
| `primary_owner_user_id` 새 이름 | `merchant_account` 자체가 미구현(`601701` §4.3 C-1) |
| `role_type = 'OWNER'` 값의 새 이름 | §1.2에서 도출되나 구체적 값은 설계 영역 |
| RBAC 역할값 체계 전체 | 2단계 ERD |
| 직영/가맹 구분의 표현 방식 | 2단계 ERD |
| `FranchiseAgreement` 엔티티 존재 여부 | 구조 없음. 2단계 |
| 지분소유 모델링 여부 | §1.3에서 분리만 확정. 모델링은 2단계 |

### §2.3 미조사 대상

`601701` §48.2가 지정한 14개 대상 중 **5개(Company/Owner/Tenant/HQ/Store)만 조사**되었다.
아래 9개는 미조사이며, 본 선언의 범위 밖이다.

User identity / Customer identity / Staff identity / Session / Role /
Permission / Membership / Menu seed / Dining table

**진행 중**: HQ 정의 확정과 로그인 세션 구조를 위해
HQ / Staff identity / Session / Role / Permission 5개에 대한 A단계 조사가 별도 진행 중이다.
그 결과가 나오면 본 선언에 항목을 추가한다.

## §3 601500과의 관계

`601500`(1차 0-A)은 **AUTHORITY SUSPENDED** 상태다(`600020` §1.1).

본 선언은 `601500`의 설계 결론을 답안지로 사용하지 않는다.
`601501`/`601503` 등을 인용한 것은 **그 문서가 무엇을 서술했는가**를 사실로 기록하기 위함이며,
그 서술이 옳다고 승인한 것이 아니다.

## §4 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 역할 |
|---|---|---|
| `601701_Register_Stage0_Evidence_Collection.md` | §4.1~§4.5 A-4/B-1/C-1, §4.15 | §48 증거수집 결과 |
| `601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | §5, §5.1 | 과금 로직 의존 금지 제약 |
| `600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | §1.1, §2 | 601500 사용 제약 |
| `601700_Readme_Operational_Authority_Foundation_V2.md` | §3, §5, §6 | 착수 순서, Out of Scope |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §46, §47.1, §48 | 1단계 규격 |

`601501`/`601503`은 §3에 따라 **사실 기록 목적으로만** 인용했다.

## §5 확정 기록

```text
확정:     정영석
일자:     2026-08-13
범위:     Owner 축 (§1.1~§1.6)
미결:     HQ 3갈래 / Staff·Session·Role·Permission (조사 진행 중)
          과금 관계 (§2.1 — 이번 나선에서 정하지 않음)
```
