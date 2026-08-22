# 601702_Register_Stage1_Business_Rules.md

Status: Active
Lifecycle: Register
Last Updated: 2026-08-13

## §0 성격

`000701` §47.1의 **1단계 업무규칙 선언** 산출물이다.
Human 전담이며 AI 위임 불가다. 아래는 Human이 확정한 내용을 그대로 기록한 것이다.

> ✅ **1단계 완료 — 3단계 대조 반영 (2026-08-13)**
>
> 선언 30건(§1.1~§1.30). 2단계 ERD(`601705`)와 3단계 독립 대조
> (`601706` Cursor / `601707` Codex)를 거쳐 §1.25~§1.30이 추가되었다.
>
> **1단계 선언은 이후 나선의 상위 근거다.** 변경하려면 그 사유를 개정 이력에 남기고,
> 이미 이 선언을 근거로 만들어진 산출물(`601705` 이하)의 재검토 범위를 함께 판정한다.

**이 문서는 "무엇을 사실로 삼을지"를 선언한다.** 설계도 구현도 아니다.
테이블·컬럼·값 이름의 구체적 결정은 2단계(ERD) 이후의 일이다.

**선행 증거**: `601701_Register_Stage0_Evidence_Collection.md` (§48 증거수집 A~E, 5개 대상)

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-13 | 초안 — §1.1~§1.6 (Owner 축) |
| 2026-08-13 | §1.7~§1.24 추가 (조직 경계 · Identity · Role/Scope · cardinality) |
| 2026-08-13 | 3단계 대조 반영 — §1.25~§1.30 추가. Status Draft → Active |

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

### §1.7 고객사 내부 권한과 프랜차이즈 횡단 권한은 분리한다

Merchant/Store RBAC은 **해당 MerchantAccount·Store 내부의 시스템 권한만** 표현한다.

프랜차이즈 본사의 다점포·다가맹사업자 접근을 **Merchant 역할의 확장으로 구현하지 않는다.**

가맹점 A의 관리자 역할을 얻어서 가맹점 B를 보는 구조를 만들지 않는다.

`020320` §14: *Merchant role never grants access to other merchants by default.*
`020320` §41: store scope는 account scope로 조용히 확장되면 안 된다.

### §1.8 Franchise HQ의 권한은 계약 기반 Scope이다

프랜차이즈 본사가 가맹사업자 데이터에 접근하는 권한은
**유효한 가맹계약과 명시적 Franchise Scope**에 근거한다.

`010640` §11: *Franchise scope is contract-scoped.*

허용 범위는 계약이 정한 데이터·행동·Store 범위로 한정한다.
**가맹사업자의 사적 재무 상세·개인정보·비계약 데이터를 자동 포함하지 않는다**
(`010640` §11 명시적 금지 목록).

### §1.9 `HQ` 어휘는 CatchMenu 관리 인터페이스에만 사용한다

`000150` §28: *CatchMenu HQ is the administrative interface for this company model.*

`020320` §22 `HQ Admin` 의 권한이 `merchant.create` / `merchant.update` /
`service_status.update` / `service_status.terminate` 인 것과 정합한다.
고객사를 생성·해지할 수 있는 주체는 **SaaS 제공자**다.

따라서 프랜차이즈 본사를 `HQ`로 부르지 않는다. 세 층위를 다른 어휘로 표기한다.

```text
CatchMenu HQ   → Platform / Platform Admin
프랜차이즈 본사 → Franchise HQ
윤슬 그룹      → Group / Group Office
```

`010640` §4의 `franchise_hq_id` 와 `020310` §8의 `HQ_ADMIN_SESSION` 은 어휘 정정 대상이다.
정정 방식은 2단계에서 정한다.

### §1.10 세 세계를 하나의 조직도로 합치지 않는다

```text
[A. Group World]        소유·전략 포트폴리오
윤슬 그룹
 ├─ 윤슬김밥
 ├─ 윤슬보울
 ├─ 윤슬커피
 └─ CatchMenu SaaS

[B. Franchise OS World] 외식사업 운영
윤슬김밥 Franchise OS
 ├─ Franchise HQ / 가맹계약 / 직영점 / 가맹점
 └─ HR·급여·시프트·SOP·교육·SCM

[C. CatchMenu World]    SaaS 제공자와 고객
CatchMenu Platform
 ├─ 고객: 윤슬김밥
 ├─ 고객: 윤슬보울
 ├─ 고객: 외부 프랜차이즈
 └─ 고객: 개인 식당
```

`000150` §11: 프랜차이즈 본사 거버넌스·가맹운영·매장 인사·급여·SOP·재고SCM은
**Franchise OS 소관**이다.

> Franchise OS may use CatchMenu.
> **Franchise OS does not own CatchMenu by default.**

**CatchMenu는 복수의 브랜드·프랜차이즈·개인식당을 고객으로 수용한다.**
윤슬 계열도 그중 하나이며, `000150` §13에 따라
외부 고객사가 자동으로 윤슬 가맹점이 되지 않는다.

### §1.11 그룹 계열 관계는 SaaS 권한이 아니다

`000150` §5: *Parent group is an ownership or strategy context.
**It is not automatic access authority.***

윤슬 그룹의 소유·계열 관계는 CatchMenu의 tenant·merchant·store·role·permission·scope를
**자동으로 생성하거나 확장하지 않는다.**

그룹 계열 사업도 CatchMenu에서는 **독립된 고객**으로 취급한다.
계열사라는 이유로 다른 고객보다 높은 시스템 권한을 갖지 않는다.

### §1.12 같은 실체가 두 시스템에서 다른 정체성을 가진다

`000150` §12: *Same physical store may have different system identities
in different business contexts.*

매장뿐 아니라 조직과 사람에도 적용된다.

```text
윤슬김밥   Group Context   = 그룹이 보유한 프랜차이즈 사업
           CatchMenu       = 서비스를 이용하는 고객

한 사람    Group           = 그룹 경영자
           Franchise OS    = Franchise Admin
           CatchMenu       = Platform Operator 또는 고객측 사용자
```

**Person은 같아도 Role·Scope·Session은 각 세계에서 별도로 판정한다.**
로그인 한 번으로 여러 세계의 권한이 자동 합쳐지지 않는다.

연결은 **명시적 링크**(`cross_business_link`)로만 한다.
`000150` §33: *Allow explicit links. **Deny implicit authority.***
`020310` §29: *Shared authentication is not shared authorization.*

### §1.13 LegalEntity는 브랜드를 넘을 수 있다

한 LegalEntity가 여러 브랜드의 매장을 운영할 수 있다.
실제 사업 형태이므로 구조적으로 막지 않는다.

**브랜드별 조회·운영 경계를 만들기 위해 LegalEntity를 복제하지 않는다.**

브랜드 때문에 LegalEntity를 쪼개면 법적 정체성이 브랜드 모델에 종속되는 역전이 생긴다.
`601501` §2.1.1: 동일성 판단 기준은 `business_registration_number`가 아니라
`legal_entities.id` 다.
`010640` §9: LegalEntity는 정산·세무·KYC·회계의 기준이며,
LegalEntity 컨텍스트 없는 금전 객체는 확정되면 안 된다.

브랜드 경계는 **계약이 만든다.** 한 가맹사업자가 여러 브랜드를 운영하더라도
각 브랜드 본사는 자기 계약 범위 밖의 매장·데이터를 볼 수 없다.
`010640` §11: *Franchise HQ must not automatically access unrelated brand data.*

가맹사업자 본인은 자기 범위에서 자신의 모든 매장을 본다.
브랜드가 다르다는 이유로 자기 데이터가 갈리지 않는다.

### §1.14 MerchantAccount 경계는 다른 축의 경계와 같다고 가정하지 않는다

MerchantAccount는 **CatchMenu의 SaaS 계약·관리 단위**다.
LegalEntity 경계와도, Brand 경계와도, User Identity와도 **독립이다.**

- 한 LegalEntity가 여러 MerchantAccount를 가질 수 있다
- 한 MerchantAccount가 여러 브랜드의 Store를 포함할 수 있다
  (`020320` §40: *merchant account scope may include multiple stores*)
- **MerchantAccount 개수를 전역 규칙으로 고정하지 않는다.** 계약·관리 단위가 결정한다

**하나의 User는 재로그인 없이, 명시적으로 부여된 여러 MerchantAccount·Store Scope를
전환할 수 있다.**

`020310`은 User Account와 Role을 별개로 정의하고,
`020320`은 `User → RoleAssignment → Scope` 구조를 전제한다.
따라서 계정 분리와 로그인 분리는 별개 문제다.

> **Identity 통합 ≠ Authority 통합**

Store는 세 축이 만나는 지점이다.

```text
강남점   legal_entity = 김철수사업자 / merchant_account = 김철수 Account / brand = 윤슬김밥
역삼점   legal_entity = 김철수사업자 / merchant_account = 김철수 Account / brand = 윤슬커피
```

같은 MerchantAccount 안에 있어도 브랜드가 다르면 **본사 조회 경계는 갈린다.**
조회 경계는 MerchantAccount 구조에서 자동 도출되지 않는다(§1.8).

### §1.15 신원은 JWT에서 해석하고 권한은 DB에서 확인한다

호출자가 파라미터로 보낸 `actor_id` 는 **조기 불일치 차단에만** 사용하고
실제 조회 키로 사용하지 않는다. 신뢰 근거는 항상 **JWT에서 해석한 값**이다.

로그인 상태와 고용 상태는 **서로 다른 사실**이며 둘 다 확인한다(AND 조건).
해고된 직원의 JWT가 여전히 유효하더라도 고용 상태로 차단되어야 한다.

`020320`: Role assignment status 와 Account status 는 별도다.

### §1.16 Person · User · Staff 는 서로 다른 개념이다

```text
Person       누구인가            — 자연인
User         누가 로그인하는가   — 앱 로그인 주체
Staff        그 사람이 어느 매장에서 어떤 상태로 일하는가 — 고용·배정 관계
```

`staff.id` 는 특정 Tenant/Store에서의 근무·운영 관계 식별자일 수 있으나,
**자연인 또는 전역 로그인 신원의 canonical identifier 로 사용하지 않는다.**

현재 구조에서 한 사람이 여러 매장에서 일하면 `staff` 행이 여러 개이며,
그 행들이 같은 사람이라는 것을 아는 축이 없다.

`JWT.sub` 를 특정 매장의 `staff.id` 에 종속시키면,
매장 컨텍스트 전환 시 로그인 정체성이 함께 바뀌게 되어 §1.14와 충돌한다.

### §1.17 Person 의 존재론적 경계

```text
Person 은 자연인을 식별하는 안정된 주체다.
Store/Tenant/고용 관계에 종속되지 않는다.
로그인 계정 그 자체가 아니다.
staff row 그 자체가 아니다.
```

`Person ↔ User` 를 1:1로 전제하지 않는다.
Person 은 있으나 로그인하지 않을 수 있고(예: 시스템을 쓰지 않는 가맹점주),
시스템 actor 는 Person 이 아닐 수도 있다(`020310` §12 `SYSTEM_JOB`).

인증 credential(`auth.users`)도 Person 그 자체가 아니다.
그것은 인증 시스템이 아는 로그인 subject 다.

### §1.18 0-B 인계 조건 (Interface Contract)

**0-B(Staff identity / session) 설계는 아래를 충족해야 한다.**

1. `Person` – `User`/Auth Identity – Staff Assignment 간
   **명시적 연결을 정의해야 한다.**
2. 하나의 `User` 가 **복수 Store/Scope 를 가질 수 있어야 한다**(§1.14).
3. **JWT authentication subject 를 특정 Store의 `staff.id` 에 종속시키지 않는다**(§1.16).
4. 커스텀 세션이 **별도의 인증 세계로 동작하지 않아야 한다.**
   세션은 애플리케이션 세션 층(session class, device, active context,
   timeout/reauth/revocation)에 속하며 인증 주체를 대체하지 않는다.

**구체적인 테이블·FK·cardinality·session bridge 는 0-B ERD 에서 결정한다.**

0-A는 `Person` 이라는 기준점과 불변조건까지만 책임진다.
`staff` 테이블 재구조화, `person_id`/`user_id` FK 추가 여부,
`auth_sessions` 존치 여부는 0-A 범위 밖이다.

> **이 절의 제약이 0-B 1단계 업무규칙에 재선언되지 않으면 착수 검증에서 반려한다.**
> (`601601` §5.1이 0-A-2에 대해 둔 것과 같은 형식의 인계 조건이다.)

### §1.18.1 근거 — 현재 실측 상태

`601211`(2026-07-18, 권위보류) 최종 상태 기록:

> `staff_login()`(`0097`)의 커스텀 세션 시스템(`auth_sessions`)과
> Supabase JWT/`current_actor_id()`(`0022`) 사이에
> **이 프로젝트 어디에도 연결이 없다.**

그 결과 `resolve_store_staff_actor()` 설계가 전제한 `JWT.sub = staff.id` 가
성립할 근거가 없으며, 그대로 구현하면
**"항상 실패하거나 우연의 일치로만 성공하는" 함수**가 된다.
해당 워크패킷은 2026-07-18에 여기서 멈췄다.

`601211` §3.2: `staff.id` 하나는 "이 사람"이 아니라
**"이 사람의 이 매장에서의 고용 기록"** 을 가리킨다.
`staff_store_assignments` 류 N:M 조인 테이블은 라이브 스키마 전수 검색 결과 없다.

`601211` §4: `current_actor_id()` 는 `auth.uid()` 와 기능적으로 동일하며
안전하게 구현되어 있으나, 486개 RPC 중 **`0143` 하나에서만 호출**된다.

**위 인용은 `600020` §3에 따라 사실 기록 목적이며,
`601211`/`601212`의 설계 결론을 승인한 것이 아니다.**

### §1.19 Role · Permission · Scope 는 삼각으로 평가한다

Authorization 은 `Role + Permission + Scope` 의 결합으로 평가한다.

- **Role 은 Scope 없이 독립적으로 권한을 만들지 않는다**(`020320` §8: *Role must be evaluated with scope*).
- **Permission 은 구체적인 resource/action 단위로 정의한다**(§9: *Permission should be action-specific*).
- **Scope 없는 Permission 은 허용하지 않는다**(§10: *Permission without scope is unsafe*).

Role 을 universal power 또는 소유권·조직지위를 대신하는 포괄 권한으로 사용하지 않는다
(`020320` §8: *Role should not be universal power*).

이는 §1.4·§1.7과 같은 방향이다 — RBAC role 은 시스템 권한만 표현하며
소유권이나 계약상 지위를 의미하지 않는다.

### §1.20 Scope Type 과 Scope Level 의 혼합을 현재 정답으로 사용하지 않는다

`020320` §10의 Scope Types 와 §11의 Scope Levels 는 **서로 다른 목록**이며
명칭·구성도 일치하지 않는다.

| | 목록 |
|---|---|
| §10 Scope Types (18) | `platform` `company` `business_unit` `team` `operator` `merchant_account` `merchant_store` `menu_context` `request` `support_case` `evidence_packet` `entry_media` `entry_media_mapping` `trial` `service_status` `billing` `audit` `cross_business_link` |
| §11 Scope Levels (11) | `GLOBAL_PLATFORM` `COMPANY` `BUSINESS_UNIT` `TEAM` `MERCHANT_ACCOUNT` `MERCHANT_STORE` `CASE` `ASSET` `REQUEST` `MENU_CONTEXT` `SELF` |

**현재 문서는 두 목록의 의미적 차이, 계층 관계, 변환 규칙을 정의하지 않는다.**

§10을 "권한이 적용되는 대상 종류", §11을 "권한 범위의 계층적 넓이"로
해석할 가능성은 있으나, **이는 현재 단계의 해석일 뿐 source fact 로 승격하지 않는다.**

아래와 같은 대응도 지금 확정하지 않는다.

```text
platform      ↔ GLOBAL_PLATFORM ?
support_case  ↔ CASE ?
entry_media   ↔ ASSET ?
```

통합된 Scope taxonomy 및 hierarchy 는 후속 ERD/Authorization 설계에서 명시적으로 재정의한다.

### §1.21 `company` / `business_unit` 은 CatchMenu 내부 조직축이다

**0-A에서는 `company` 와 `business_unit` 을 `000150` 에서 정의된
CatchMenu 내부 조직축으로 해석한다.**

`000150` §4: *Company boundary defines who operates CatchMenu as a platform.*
`000150` §6: *Business unit defines operating responsibility inside CatchMenu.*

`000150` §4가 나열하는 company 유형은 CatchMenu SaaS 회사 / CatchMenu 운영 부문 /
CatchMenu 사업 단위 / 윤슬 그룹 소유의 SaaS 자회사 / 법적 분리 이전의 내부 제품 회사이며,
company types 도 `SAAS_COMPANY` / `BUSINESS_UNIT` / `OPERATING_DIVISION` /
`SUBSIDIARY` / `INTERNAL_PRODUCT_UNIT` 로 전부 CatchMenu 쪽이다.

**따라서 이 둘을 아래 의미로 사용하지 않는다.**

```text
외부 고객사의 상위 그룹
Franchise HQ
Franchise Network
MerchantAccount 상위 고객집단
```

> ⚠️ **이 판정의 성격**: `020320` §10·§11의 `company` / `business_unit` 도
> 0-A에서는 이 의미로 정규화하여 해석한다.
> 다만 이는 **`020320` 자체의 명시 정의가 아니다.** `020320` 은 두 어휘를
> 목록에만 두고 의미를 설명하지 않는다.
> 상위 조직 정의(`000150`)를 기준으로 용어 충돌을 해소하기 위한
> **Human Business Rule** 이다.

**이 선언이 닫는 설계 경로**

```text
COMPANY scope → Franchise HQ → 여러 merchant_account 횡단 조회
```

`COMPANY` 가 CatchMenu 내부 운영회사 축이므로
프랜차이즈 본사의 가맹점 횡단 권한을 여기 얹을 수 없다.
프랜차이즈 본사의 CatchMenu 접근이 필요하면 §1.8(계약 기반 Scope)과
§1.10(세 세계 분리)에 따라 별도의 cross-business / franchise-derived scope 로 해결한다.

### §1.22 Tenant 와 MerchantAccount 는 다른 개념이며 1:1 로 시작한다

`Tenant` 는 CatchMenu 의 **SaaS 고객조직 및 최상위 데이터 격리 경계**다
(`010640` §4: *SaaS tenant/customer organization*).

`MerchantAccount` 는 **CatchMenu 서비스 계약·관리·권한 scope** 다
(`020320` §40: merchant account scope 는 여러 store 를 포함할 수 있다).

**두 개념은 동일하지 않다.** 그러나 **이번 나선에서는 1:1 로 확정한다.**

> ⚠️ **1:N 을 선택하지 않은 이유**
>
> 어느 문서도 Tenant 와 MerchantAccount 의 cardinality 를 규정하지 않는다
> (2026-08-13 조사: 「추정만 가능」).
> 1:N 이 필요한 실제 사례가 아직 확인되지 않았으며,
> 1:N 을 허용하면 아래 오용 경로가 열린다.
>
> ```text
> 윤슬김밥 Tenant
>  ├─ 가맹점주 A MerchantAccount
>  ├─ 가맹점주 B MerchantAccount
>  └─ 가맹점주 C MerchantAccount
> ```
>
> 독립된 가맹사업자를 같은 브랜드라는 이유로 동일 Tenant 에 배치하면
> `010640` 의 cross-tenant 기본 거부가 무력화된다.
> 1:1 이면 이 경로가 구조적으로 막힌다.
>
> **`Tenant` 는 보안상 같은 고객조직을 뜻하며 "같은 브랜드 식구들"을 뜻하지 않는다.**
> 프랜차이즈 횡단은 §1.8의 계약 기반 scope 로 해결한다.

향후 1:N 이 필요해지면 **실제 사례를 근거로** 스키마 변경으로 연다.
가정만으로 미리 열지 않는다(`000701` §47.2).

### §1.23 MerchantAccount 와 LegalEntity 는 독립이다

**하나의 MerchantAccount 는 서로 다른 LegalEntity 가 운영하는 복수 Store 를 포함할 수 있다.**

```text
MerchantAccount M1
 ├─ Store A → LegalEntity L1
 ├─ Store B → LegalEntity L1
 └─ Store C → LegalEntity L2
```

단, **각 Store 는 자신의 법적 운영주체를 명시해야 하며**,
모든 금전·정산·세무 행위는 **해당 LegalEntity scope 로 최종성이 검증**되어야 한다
(`010640` §9: LegalEntity 컨텍스트 없는 금전 객체는 확정되면 안 된다).

위 예에서 정산은 이렇게 갈린다.

```text
Store A 매출 → L1
Store B 매출 → L1
Store C 매출 → L2
```

**MerchantAccount 공유를 LegalEntity 간 법적·재무 권한 공유로 해석하지 않는다.**
`M1` 이라는 이유로 `L1` 과 `L2` 의 재무가 하나의 장부가 되지 않는다.

### §1.24 각 Store 는 현재 시점의 법적 운영주체를 명시한다

**Human Decision.** 근거의 성격을 아래와 같이 구분한다.

| 구분 | 내용 |
|---|---|
| Source Evidence | `003020` §2 — Store 와 LegalEntity 사이에 관계가 존재하며 *may link* 라고만 서술 |
| Human Business Rule | **각 Store 는 현재 시점의 법적 운영주체를 명시적으로 가져야 한다** |

> ⚠️ `601501`(권위보류)이 `stores.legal_entity_id` 단일 FK 로 설계했다는 사실은
> **이 판정의 근거가 아니다.** `600020` §2에 따라 `601500` 을 답안지로 사용하지 않는다.
> 살아있는 상위 문서(`003020`)는 관계의 존재만 서술하고 cardinality 를 규정하지 않는다.

이 규칙은 §1.4(매장의 법적 운영주체는 LegalEntity 관계로 표현)의 구체화다.

**Store 당 LegalEntity 가 하나인지 여럿인지, 시점 이력을 어떻게 표현하는지는
2단계 ERD 에서 결정한다.** "현재 시점의 운영주체가 명시되어야 한다"까지만 확정한다.

### §1.25 `Merchant Company` 용어 정규화

`000170` §6의 `Merchant Company` 는 **0-A 모델에서 독립적인 canonical entity 로 사용하지 않는다.**

> ⚠️ **"Merchant Company = LegalEntity" 라고 단순 등치하지 않는다.**
> 이 개념에는 **두 종류의 책임이 혼재**되어 있다.

| 성격 | `000170` §6의 항목 | 정규화 대상 |
|---|---|---|
| **A. 법적 identity** | `legal_name` / `business_registration_ref` / tax invoice reference / contract reference | **`LegalEntity`** |
| **B. 관리·접근 grouping** | owner access grouping / `billing_contact` / `contract_contact` / multi-store grouping | **`MerchantAccount`** 및 후속 Role/Scope 모델 |

**법적·세무·정산·계약 주체는 `LegalEntity` 로 정규화한다**
(`000150` §7, `010640` §9 — LegalEntity 컨텍스트 없는 금전 객체는 확정되면 안 된다).

**merchant 관리범위 및 사용자 접근범위는 `MerchantAccount` 와
후속 Role/Scope 모델에서 표현한다**
(`020320` §40 — merchant account scope 는 여러 store 를 포함하나 permission 은 별도).

`Merchant Company` 는 **legacy composite terminology** 로 분류하며,
`000170` 을 후속 상위문서 정합화 대상에 포함한다.

> **`merchant_company` 를 `legal_entity` 로 단순 rename 하지 않는다.**
> 개념을 분해하고 각 책임을 해당 축으로 옮긴다.

**3층 구조(Account → MerchantCompany → Store)를 도입하지 않는다.**
`MerchantCompany ↔ LegalEntity` 의 cardinality, 한 운영회사가 여러 법인을 묶을 수 있는지,
`MerchantAccount` 와 별도로 grouping 이 필요한 이유 —
**어느 것도 현재 source evidence 가 답하지 못한다.**
근거 없는 축을 추가하지 않는다.

### §1.26 Store 의 구조 부모는 MerchantAccount 이며 Tenant 는 격리 scope 다

`601705` 초안이 `TENANT → STORE` 와 `MERCHANT_ACCOUNT → STORE` 를
모두 구조 관계로 그렸다. §1.22가 Tenant ↔ MerchantAccount 를 1:1로 확정한 동안
**같은 SaaS 고객 계층을 두 경로로 표현**하게 된다.

**Conceptual 구조 경로는 하나로 둔다.**

```text
Tenant
  │ 1:1 (§1.22, 이번 나선)
  ▼
MerchantAccount
  │ 1:N
  ▼
Store
```

**Tenant 는 Store 의 두 번째 구조 부모가 아니라 필수 격리 scope 다.**

> **Invariant**: 모든 Store 는 Tenant scope 를 보유하고 검증해야 한다.
> 물리 스키마가 `stores.tenant_id` 를 직접 보유하는 것은
> 격리·RLS·조회 효율을 위한 것이며,
> **개념적 두 번째 소유 계층을 만들지 않는다.**

`010640` 은 Tenant isolation 과 Store isolation 을 별도의 강제 scope boundary 로 요구한다(§7·§8).
`010004` §4는 tenant-owned 객체에 `tenant_id` 를 필수로 요구한다.
**이 요건들은 격리 invariant 로 유지되며 구조 관계와 구분한다.**

**한편 `MerchantAccount → Store` 와 `LegalEntity → Store` 는 문제가 아니다.**
서로 다른 축이다.

| 관계 | 답하는 질문 |
|---|---|
| MerchantAccount → Store | 어느 CatchMenu 고객 관리범위에 속하는가 |
| LegalEntity → Store | 누가 이 Store 의 법적 운영주체인가 |

`000170` §7이 `merchant_store` 에 `merchant_account_id` 와 `merchant_company_id` 를
둘 다 두라고 한 것도 같은 구조다(§1.25에 따라 후자는 `LegalEntity` 로 정규화).

### §1.27 Store 상태는 서로 다른 의미축으로 분리한다

Store 의 상태를 하나의 범용 `store_status` 로 표현하지 않는다.
최소한 아래 **세 의미축을 서로 독립된 개념**으로 구분한다.

| 축 | 묻는 질문 |
|---|---|
| **Store Service Status** | 해당 Store 에 대한 CatchMenu 서비스 제공 상태는 무엇인가 |
| **Store Operating Status** | 실제 음식점이 영업 중인가 |
| **Trial Status** | CatchMenu 체험·전환 lifecycle 이 어디까지 갔는가 |

**한 축의 값으로 다른 축의 상태를 추론하지 않는다.**

`000170` §15 예시:

```text
store_operating_status = OPEN
service_status = SUSPENDED
→ 식당은 영업 중인데 CatchMenu 서비스는 정지
```

`000170` §14가 Store 별 service status 를 따로 둔 이유:

> 한 merchant account 가 여러 store 를 가질 수 있다.
> 한 store 는 활성인데 다른 store 는 정지일 수 있다.
> 한 store 는 체험이고 다른 store 는 유료일 수 있다.

이는 §1.14(MerchantAccount → Store 1:N)와 직접 연결된다.

> ⚠️ **이번 나선에서 확정하지 않는 것**
>
> `000170` §14~§16의 상태값 목록은 **각 축의 정책 의도를 확인하는 근거로 보존**하되,
> **canonical enum · 상태전이 · 과금/권한 효과는 확정하지 않는다.**
>
> 특히 `STORE_ACTIVE_PAID` 처럼 **과금 상태와 서비스 상태를 한 값에 결합한 명칭**은
> §2.1(과금과 운영권한 관계 미결)에 걸린다.
> 향후 `ServiceStatus = ACTIVE` / `BillingStatus = PAID` 로 분리될 수도 있다.
>
> 상세 설계는 후속 단계에서 결정한다.

**현재 physical schema 에 대한 사실 기록**

현재 스키마는 세 상태축을 명시적으로 각각 표현하지 않는다.
`stores.store_status` / `tenants.tenant_status` / `tenants.isolation_state` 가
따로 존재하나 `000170` 의 세 Store 축과 정확히 대응하지 않는다.

> ⚠️ **기존 SQL 에는 Store-level Trial Status 를 독립적으로 표현하는 축이 관측되지 않는다.**
> Tenant-level `TRIAL` 값이 존재하지만 **이를 Store Trial Status 와 동일시할 근거는 없다.**
> 둘을 대응시키는 것은 과거 구현을 설계 근거로 승격시키는 것이다(`600020` §2).

### §1.28 상위 객체 상태로 하위 객체 상태를 대신하지 않는다

```text
TenantStatus
  ≠ MerchantAccountStatus
  ≠ StoreServiceStatus
  ≠ StoreOperatingStatus
  ≠ TrialStatus
  ≠ IsolationState
```

각 계층은 자신의 상태를 갖는다. 상위 상태를 하위 상태의 대체물로 사용하지 않는다.

예:

```text
Tenant = ACTIVE
 ├─ 강남점: service ACTIVE   / operating OPEN
 ├─ 서초점: service SUSPENDED / operating OPEN
 └─ 잠실점: service TRIAL     / operating PRE_OPEN
```

Tenant 가 활성이라는 사실이 모든 Store 가 활성이라는 뜻이 아니다.

**enum 을 이번 나선에서 만들지 않는다.** 원칙만 확정한다.

### §1.29 `company` 어휘의 두 층위를 구분하고 고객사-side 의미를 정규화한다

`company` 는 문서군에서 서로 다른 의미로 사용되었다.

**(a) `000150` §4 Company**

CatchMenu 플랫폼을 운영하는 **내부 회사 조직축**이다. §1.21의 정의를 따른다.

**(b) `009070` §2 / `003020` 의 company, `000170` §6 의 Merchant Company**

고객사 측 **운영회사·사업자·브랜드·multi-store grouping 성격이 혼재된
legacy terminology 군**이다.

> ⚠️ **`009070` 을 "company = LegalEntity" 의 근거로 사용하지 않는다.**
>
> `009070` Purpose 는 `tenant / company / legal_entity / operating_group / store` 를
> **distinct context axes** 로 규정하고, *prematurely collapsing context axes* 를
> 막는 것을 목적으로 명시한다.
>
> §3의 `company/legal_entity` 슬래시 표기는 **같은 종류의 상위 context 군을 묶은 표기**이며
> 동일성 선언이 아니다. 이를 동일시하면 문서 내부와 충돌한다.

**0-A Human Decision**: 고객사-side company 에 혼재된 책임을
아래 canonical 축으로 분해·정규화한다.

| 혼재된 책임 | 정규화 대상 |
|---|---|
| 법적·세무·정산·계약 identity | **LegalEntity** |
| 브랜드 identity | **Brand** (§1.13) |
| CatchMenu SaaS 계약·관리 grouping | **MerchantAccount** (§1.14) |
| 운영상 Store grouping | 필요한 경우 **OperatingGroup** (§1.30) |

**고객사-side `company` / `Merchant Company` 를
새로운 독립 canonical Core entity 로 승격하지 않는다.**

해당 용어는 후속 상위문서 정합화 대상으로 기록한다(§1.25와 같은 처리).

### §1.30 OperatingGroup 은 독립 운영 grouping 축이며 persistence 는 미결이다

`OperatingGroup` 은 **지역·프랜차이즈·기타 운영 목적에 따라 Store 를 묶는 운영 context** 다
(`009070` §2 — *Regional, franchise, or operational grouping*).

**LegalEntity, Brand, MerchantAccount, CatchMenu 내부 Company 와 동일시하지 않는다.**

`009070` §3: *operating_group and company/legal_entity are parallel/context axes.*

**OperatingGroup 은 법적 소유권·세무·정산 identity 를 나타내지 않으며,
그 존재만으로 금전권한이나 시스템 권한을 생성하지 않는다.**

`010640` §10: 운영 그룹을 법적 소유권과 혼동하면 안 된다.
자동으로 금전 권한을 뜻하지 않는다.

> ⚠️ **persistence 는 미결이다.**
>
> | 문서 | 서술 |
> |---|---|
> | `009070` §2 | *Persistence depth open for MVP* |
> | `009070` §6 | *whether operating_group is persisted in MVP* |
> | `003020` §6 | *whether operating_group exists in MVP data* |
> | `000150` §26 | *Actual schema may be designed later* |
>
> **살아있는 ACTIVE 문서 넷이 모두 미결로 남겼다.**
> 0-A 가 물리 persistent entity 로 확정하지 않는다.

0-A ERD 에서는 **Candidate / conceptual axis** 로 유지하며,
persistence 와 구체 cardinality 는 후속 설계에서 결정한다.

### §1.31 LegalEntity 의 business identity source 는 검증된 영업 intake 다

`010901` §11 Business Registration Intake 는 아래를 수집한다.

```text
business registration number / legal entity name / representative name /
business address / business category / tax invoice email /
settlement/billing owner / contract signer /
verification state / review actor / audit reference
```

이는 LegalEntity 를 식별·검증하는 **원천 business identity 정보**다.

`010901` §4: sales lead / tenant candidate / tenant / brand candidate /
store candidate / store profile draft / owner contact / hq contact /
onboarding case / activation candidate 는 **서로 다른 lifecycle 객체**이며
*These objects must not be collapsed into one uncontrolled record.*

특히 `tenant_candidate` 와 `tenant` 는 **승인 전후의 다른 lifecycle state** 를 표현한다.

> **0-A Human Decision**
>
> canonical `LegalEntity` 는 **검증되지 않은 설계값이나 구현상 synthetic identity 로
> 생성하지 않는다.** 검증된 business-registration / onboarding evidence 를 근거로
> 생성·연결한다.
>
> 따라서 Store 의 LegalEntity mapping 도 authoritative business identity 가
> 확보된 이후 수행하며, **임의의 placeholder LegalEntity 를 만들어
> `stores.legal_entity_id` 를 채우지 않는다.**

> ⚠️ **현재 `legal_entities` 가 0행이라는 physical fact 만으로 모델 결함이라고 판정하지 않는다.**
> 실제 원인이 intake 미수행인지 여부는 onboarding evidence 로 확인한다.
> `010901` 은 intake 필드를 규정하나, 0행의 원인을 서술하지 않는다.

### §1.32 `store_operator_type` 은 LegalEntity 와 별개 축이다

`010901` §10 Franchise And HQ Relationship Intake 가 아래를 수집한다.

| 필드 | 필수 | 의미 |
|---|---|---|
| `franchise_flag` | yes | 프랜차이즈 후보 여부 |
| `store_operator_type` | conditional | Direct / franchisee / agency |
| `hq_tenant_candidate_id` | conditional | HQ 후보 |
| `contract_relationship_state` | conditional | Draft / verified |

**두 축을 섞지 않는다.**

```text
Store
 ├─ legal operator → LegalEntity        누가 법적 운영주체인가
 └─ operator_type  → DIRECT / FRANCHISEE / AGENCY   어떤 형태로 운영되는가
```

**`FRANCHISEE` 라는 이유로 LegalEntity 를 추론하지 않는다.**
**`DIRECT` 라는 이유로 그룹 본사 LegalEntity 를 자동 배정하지 않는다.**

§1.5의 축 간 추론 금지 원칙이 그대로 적용된다.

> ⚠️ `hq_tenant_candidate_id` 의 존재만으로
> **"프랜차이즈 본사는 반드시 별도 Tenant 다"를 확정하지 않는다.**
> 이름 그대로 `candidate` 단계의 관계이며,
> 실제 tenant 생성·연결 규칙은 확인되지 않았다.

### §1.33 cross-business link 는 참조이며 권한이 아니다

`000190` 이 CatchMenu ↔ Franchise OS 경계를 전담하는 문서다.
§1.10~§1.12는 `000150` §11·§12·§33 을 근거로 선언했으나,
**`000190` 이 같은 주제를 더 직접적으로 규정한다.**

`000190` §10 Cross-Business Link:

```text
cross_business_link_id / source_system / source_entity_type / source_entity_id /
target_system / target_entity_type / target_entity_id /
relationship_type / status / created_by / created_at / trace_id
```

예시:

```text
source: Franchise OS / store / franchise_store_001
target: CatchMenu / merchant_store / catchmenu_store_001
relationship_type: YOONSUL_AFFILIATED_STORE
```

> **Cross-business link is reference. Cross-business link is not permission.**

`000190` §11 Cross-Business User Link:

> **Same human does not mean same authority.**
>
> A person may be Franchise OS Store Manager but not CatchMenu HQ Admin
> unless explicitly assigned.

`000190` §21 Source Of Truth Rule:

```text
Franchise OS owns  Yoonsul store HR / franchise payroll / internal store SOP
CatchMenu owns     Entry Media mapping / merchant service status /
                   request runtime evidence
```

> **Every shared data element needs a source of truth.**

**§1.10~§1.12의 선언 내용은 `000190` 과 일치한다.** 근거를 보강한 것이며 변경이 아니다.

### §1.34 Store 의 법적 운영주체는 시점 관계다

매장 매매·양수도·가맹점주 교체·법인 전환으로 운영주체가 바뀐다.
**현재 값만 유지하면 과거 거래의 귀속이 소실된다.**

**Store–LegalEntity 배정은 유효기간을 갖는 시점 관계로 표현한다.**

```text
2027-01-01 ~ 2029-05-31   강남점 → 김철수 개인사업자
2029-06-01 ~              강남점 → 이영희 개인사업자
```

`legal_entity_person_roles` / `legal_entity_representatives` 가 이미
`effective_from` / `effective_to` / `is_active` 구조를 갖는 것과 같은 축이다
(`601714`/`601715` 실측).

Store 에 현재 운영주체를 가리키는 값을 두더라도
그것은 **권위 원본이 아니라 현재 포인터**다.

```text
시점 관계        authoritative
Store 의 현재값   current pointer / cache
```

**유효기간이 겹치는 두 운영주체가 동시에 존재하면 안 된다.**

```text
금지   김철수 : 2028-01-01 ~ 2029-08-31
       이영희 : 2029-06-01 ~ NULL          ← 기간 중첩

정상   김철수 : 2028-01-01 ~ 2029-05-31
       이영희 : 2029-06-01 ~ NULL
```

검증 방식(exclusion constraint 등)은 물리 설계에서 정한다.

**물리 구조는 2단계 ERD 및 ChangeContract 에서 정한다.**
별도 테이블인지, 현재 포인터를 어디에 둘지는 여기서 확정하지 않는다.

### §1.35 금전 객체는 LegalEntity snapshot 을 보유한다

**금전 객체는 생성 또는 확정 시점의 LegalEntity 를 자체적으로 보유한다.**

`010640` §9 가 열거하는 대상:

```text
정산 / 지급 / 세무·신고 / 플랫폼 수수료 청구 /
분할지급 / 로열티 / KYC / 계좌 소유 / 회계 분개
```

> LegalEntity 컨텍스트가 없는 금전 객체는 확정(final)되면 안 된다.

**주문과 같이 금전 객체의 상위 비즈니스 객체도
거래 귀속의 안정성과 downstream financial binding 을 위해
LegalEntity snapshot 을 보유하는 것을 원칙으로 한다.**

> ⚠️ **이것은 `010640` §9 의 직접 강제가 아니라 0-A Human Decision 이다.**
> §9 가 열거하는 것은 financial object 이며 주문은 포함되지 않는다.
> 정책을 확대해석하지 않되 설계 방향은 유지한다.

**배정 이력을 매번 역참조해서 과거 귀속을 계산하지 않는다.**
이력 테이블이 잘못 수정되거나 삭제되면
이미 확정된 회계 사실까지 달라지는 위험이 생긴다.

```text
이력 테이블   왜 이 LegalEntity 였는가 를 설명한다
거래 객체     실제로 누구의 거래였는가 를 확정한다
```

주문·정산 객체의 구현은 0-A 범위 밖이다(`601710` §3). 여기서는 원칙만 선언한다.

### §1.36 Store 의 LegalEntity 변경과 Tenant 이전은 다른 사건이다

매장 양수도가 **운영주체 변경**인지 **Tenant 이전**인지 구분한다.

```text
LegalEntity 변경   같은 Tenant 안에서 법적 운영주체가 바뀜
Tenant 이전        직원·회원·주문·권한·정산의 귀속 자체가
                   다른 고객으로 넘어감
```

**둘을 같은 사건으로 취급하지 않는다.**

§1.22 가 Tenant ↔ MerchantAccount 를 1:1 로 두었으므로
Tenant 이전은 MerchantAccount 경계까지 걸린다.

Tenant 이전의 절차·데이터 처리·권한 승계는 **0-A 범위 밖**이다.
여기서는 **두 사건이 다르다는 것만** 확정한다.

### §1.37 `owners` 를 `persons` 로, `owner_id` 를 `person_id` 로 정규화한다

§1.1 이 자연인의 canonical 명칭을 `Person` 으로 확정했다.
**테이블명만 바꾸고 참조 컬럼을 남기면 §1.2(무수식 `Owner` 금지)를 절반만 지키는 것이다.**

```text
owners.id                                  → persons.id
legal_entity_person_roles.owner_id         → legal_entity_person_roles.person_id
legal_entity_representatives.owner_id      → legal_entity_representatives.person_id
```

FK 제약명·인덱스명도 `person` 기준으로 정렬한다.

**`legal_entity_representatives` 명칭은 유지한다.**
이름만으로 "LegalEntity 의 representative 관계"라는 의미가 충분하며,
`legal_entity_person_representatives` 는 길어질 뿐 정보가 늘지 않는다.

**현 상태의 어긋남**: 테이블명은 이미 `legal_entity_person_roles` 인데
참조 컬럼은 `owner_id` 다. `0168` 시점에 혼재가 들어갔다.

**영향 범위**(`601711`/`601712` scan 실측)

```text
FK 2건      legal_entity_person_roles_owner_id_fkey
            legal_entity_representatives_owner_id_fkey
INDEX       idx_lepr_owner
UNIQUE      uq_lepr_active / uq_ler_active
TRIGGER     trg_owners_updated_at → set_updated_at()
데이터      전 테이블 0행
```

물리 변경 방법(rename 인지 신규 생성 후 교체인지)은 **ChangeContract 가 판정한다**(`601713` §1.1).

### §1.38 `is_active` 를 사람 레코드에서 제거한다

`owners.is_active` 는 **무엇을 뜻하는지 어디에도 규정되어 있지 않다.**
`601714`/`601715` 실측: `owners` 의 CHECK 제약 **0건**.

§1.37 을 적용하면 질문이 선명해진다 — **`persons.is_active` 가 무슨 뜻인가.**

**사람의 존재 자체가 active/inactive 일 수는 없다.**

이 boolean 하나로는 아래를 구분할 수 없다.

```text
탈퇴한 사람인가?
법인과 관계가 끝난 사람인가?
개인정보 삭제 대상인가?
계정이 정지된 사람인가?
```

**각 책임 영역으로 분리한다.**

| 의미 | 소관 |
|---|---|
| 로그인 가능 여부 | Identity / Account — 0-B(§1.18) |
| LegalEntity 와 현재 관계 유무 | relationship — `legal_entity_person_roles.is_active` 가 이미 표현 |
| 개인정보 lifecycle | 별도 privacy 상태 모델 |
| 재직 여부 | employment relationship — 0-B |

> ⚠️ **개인정보 lifecycle 을 boolean 하나로 표현하지 않는다.**
> 실제로는 최소한 아래 구분이 필요해진다.
>
> ```text
> ACTIVE / DEACTIVATED / ANONYMIZED /
> DELETION_REQUESTED / RETENTION_HOLD / PURGED
> ```
>
> 또는 `deleted_at` / `anonymized_at` / `retention_until` 같은 별도 lifecycle.

**0-A 의 Person 은 신원·법적 인물의 안정적 식별 레코드로 둔다.**
`is_active` 는 제거하며, 같은 이름을 다른 의미로 재사용하지 않는다.

### §1.39 `ownership_percent` 를 역할 테이블에서 제거한다

§1.3 이 조직역할과 지분소유를 별개 개념으로 확정했다.
**`legal_entity_person_roles.ownership_percent` 는 그 둘이 한 행에 결합된 상태다.**

`601714`/`601715` 실측: 컬럼과 `chk_lepr_ownership_percent`(0~100) 제약이 모두 실재.
`601501` §2.3.1 은 사용 금지 상태로 서술. `601701` C-1 은 **「초과구현」** 으로 분류.

**결합이 만드는 문제**

```text
Person A
   ├── DIRECTOR       ← 조직 역할
   ├── REPRESENTATIVE ← 조직 역할
   └── 30%            ← 경제적 소유
```

현재 모델은 이것을 아래처럼 표현할 수 있게 만든다.

```text
DIRECTOR  + 30%
INVESTOR  + 30%     ← 같은 지분인데 행이 둘
```

**지분이라는 하나의 사실이 role row 에 종속된다.**

**조치**

```text
legal_entity_person_roles.ownership_percent  →  제거
```

**Economic ownership 은 LegalEntity–Person 의 organizational role 과
독립된 별도 관계축으로 모델링한다.**

**0-A 에서 새 ownership 모델을 구현하지 않는다.** 축이 별개라는 선언까지만 한다.

> ⚠️ 제거는 `0168` 파일을 직접 수정하는 것이 아니라
> **신규 forward migration 으로 수행한다**(`000701` §14.5, `601710` §5).
>
> `CASCADE` 로 일괄 제거하지 않는다.
> dependent constraint / view / function 을 전수 확인하고 명시적으로 처리한다.

### §1.40 SaaS Architecture 는 처음부터, SaaS Business Operations 는 나중에

**멀티테넌시는 나중에 붙일 수 있는 기능이 아니라 데이터 모델의 뼈대다.**

나중에 넣으려면 거의 모든 테이블·RPC·권한·unique constraint·캐시 키·
외부 연동 키를 다시 손대게 된다.

**1호점부터 반드시 SaaS 구조로 만드는 것**

```text
tenant / store
사용자 계정 · 로그인
tenant_id · store_id
Role / Permission / Scope
직원이 어느 tenant/store 소속인지
고객·멤버십 데이터의 tenant 귀속
메뉴·재고·직원·KDS 데이터의 tenant/store 귀속
Tenant 간 데이터 격리
외부 시스템 credential 및 merchant/store mapping
모든 핵심 객체의 ownership boundary
```

윤슬김밥 1호점에서 `tenant = YOONSUL` / `store = YOONSUL_STORE_001`
하나만 사용하더라도 처음부터 그렇게 만든다.
두 번째 고객이 들어오면 행을 하나 더 만들 뿐이고 **코드는 똑같이 돌아가야 한다.**

**이번 나선에서 구현하지 않는 것 (SaaS Business Operations)**

```text
Settlement / 정산
과금 상태 전이
Franchise HQ 횡단 조회 권한
OperatingGroup persistence
cross_business_link 물리 구조
Store 상태 3축의 enum·전이
```

§2.1 · §2.2 · §1.30 이 이미 이들을 미결로 두고 있다.

### §1.41 판별 기준 — 두 번째 음식점이 들어와도 그대로 쓸 수 있는가

어떤 산출물이 **플랫폼 구조**인지 **윤슬 데이터**인지 판별할 때 이 질문을 쓴다.

```text
두 번째 음식점이 들어오는 순간 그대로 쓸 수 있는가?

쓸 수 있다  →  CatchMenu 플랫폼 구조
못 쓴다     →  윤슬 tenant 데이터
```

| | 두 번째 매장 | 소속 |
|---|---|---|
| tenant / store / login / role | 그대로 사용 | CatchMenu |
| Membership 구조 | 그대로 사용 | CatchMenu |
| Inventory 구조 | 그대로 사용 | CatchMenu |
| KDS 도메인 모델 | 그대로 사용 | CatchMenu |
| 외부 provider adapter | 그대로 사용 | CatchMenu |
| 윤슬 레시피·BOM 수치 | 사용 불가 | 윤슬 데이터 |
| 윤슬 SOP | 사용 불가 | 윤슬 데이터 |
| 윤슬 브랜드 정책 | 사용 불가 | 윤슬 데이터 |

**구조는 CatchMenu, 내용은 윤슬이다.**

이는 tenant 격리 경계와 같은 선이다.
`tenant_id = YOONSUL` 인 데이터가 윤슬 것이고, 그것을 담는 스키마가 CatchMenu 것이다.

**"이 기능이 윤슬 것이냐 CatchMenu 것이냐"가 아니라
"이것이 스키마냐 데이터냐"로 묻는다.**

### §1.42 네 시스템의 경계를 어휘로 고정한다

윤슬 사업과 CatchMenu 가 상존하므로 대화·문서에서 층위가 섞인다.
**아래 네 어휘로 고정한다.**

| 약칭 | 대상 | 책임 |
|---|---|---|
| `CM-PLAT` | CatchMenu 플랫폼 | tenant / store / auth / role / scope / 외부연동 registry |
| `YS-OS` | 윤슬김밥 운영 시스템 | membership / preference / inventory / recipe / KDS Core |
| `TOSS-TX` | Toss 거래 시스템 | POS / Kiosk / Payment / PG / 영수증 |
| `SC-EXEC` | Smartcast 실행 시스템 | KDS / DID / CMS 화면 |

**핵심 원칙**

```text
초개인화 원본 = YS-OS
결제 Authority = TOSS-TX
KDS/DID 실행  = SC-EXEC
SaaS 구조     = CM-PLAT
```

**운영 채널의 진입 경로**

점주·직원·본사 사용자는 **CM-PLAT 을 거쳐** YS-OS 에 도달한다.
로그인 시 tenant / store / role 판정이 선행되기 때문이다.

> ⚠️ **`TOSS-TX` 가 `SC-EXEC` 로 직접 전달하지 않는다.**
>
> ```text
> TOSS-TX → YS-OS → SC-EXEC
> ```
>
> 같은 옵션이라도 의미가 다르기 때문이다.
>
> ```text
> TOSS-TX 에서   "단무지 제외" = 주문 옵션
> YS-OS 에서     = customer preference + recipe delta + inventory delta
>                  + cost delta + kitchen instruction
> ```
>
> 직결하면 YS-OS 가 사후에 매출만 읽는 통계 프로그램이 된다.

### §1.43 외부 시스템 연결은 CM-PLAT 의 tenant/store 경계에 귀속된다

외부 provider 의 credential 과 merchant/store mapping 은
**플랫폼 구조의 일부**이며 §1.40 의 뼈대에 포함된다.

**provider 는 두 종류이며 성격이 다르다.**

| 구분 | 예 | 다루는 것 |
|---|---|---|
| 거래 provider | `TOSS-TX` | 주문·결제·정산 |
| 실행 provider | `SC-EXEC` | KDS·DID 화면 |

**연결은 tenant/store 단위로 귀속된다.**

```text
Store
 ├─ tenant_id
 ├─ merchant_account_id
 ├─ legal_entity_id (시점 관계 — §1.34)
 └─ 외부 provider 연결
      ├─ 거래 provider  : external merchant id
      └─ 실행 provider  : external store code
```

**의미 ID 는 CatchMenu/YS-OS 가 canonical 이며 외부 코드는 매핑 대상이다.**

```text
YS-OS 의 의미 ID        canonical
   ↕
거래 provider 옵션 코드   매핑
   ↕
실행 provider modifier   매핑
```

provider 를 교체해도 canonical 의미 ID 는 바뀌지 않는다. 매핑만 추가한다.

**014630 매트릭스**(2026-06)가 Toss Place 를 **P1**(공식 API/plugin/webhook 경로
우선 검증 대상)으로, OKPOS·KIS OKPOS·KICC EasyPos 를 **P0**(반드시 이해하되
즉시 통합을 전제하지 않음)으로 분류했다.

**014050 §17** Phase 1 포함 규칙에 `provider adapter minimum for Toss` 가 이미 있다.

> ⚠️ **실행 provider 는 `014050`/`014630` 조사 범위에 없다.**
> 두 문서는 POS/VAN/PG 거래 provider 를 대상으로 한다.
> 실행 provider 의 우선순위·개방성·리스크는 **별도 조사가 필요**하다.

**물리 구조·테이블명·필드는 2단계 ERD 및 ChangeContract 에서 정한다.**

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
| `MERCHANT_OWNER` 역할명 | §1.2·§1.4에서 도출. `MERCHANT_ADMIN` 등이 후보 |
| `HQ_ADMIN_SESSION` / `HQ Admin` 개명 | §1.9에서 정정 대상 확정. 방식은 2단계 |
| `franchise_hq_id` 정정 방식 | §1.9에서 정정 대상 확정. 방식은 2단계 |
| 프랜차이즈 본사 사용자의 계정 유형·세션 등급 | `020310` §12 계정유형 6종에 해당 항목 없음 |
| `FranchiseAgreement` 의 CatchMenu 측 표현 | §1.10에 따라 원천은 Franchise OS. CatchMenu 측 표현 방식은 2단계 |
| `COMPANY` / `BUSINESS_UNIT` scope 구현 여부 | `000150` §4·§6은 **CatchMenu 조직축**으로 정의. 프랜차이즈 본사가 아님 |
| `cross_business_link` 구조 | `000150` §26 개념 엔티티에 존재하나 미구현 |
| Scope 전환 UI·세션 표현 방식 | §1.14의 컨텍스트 전환을 어떻게 구현할지 |
| `JWT.sub` 가 무엇을 가리키는가 | §1.16에서 `staff.id` 배제만 확정. `auth.users.id` / `User.id` 중 무엇인지는 0-B |
| `staff` 테이블 재구조화 | §1.18에 따라 0-B 소관 |
| `person_id` / `user_id` FK 추가 여부 | §1.18에 따라 0-B 소관 |
| `auth_sessions` 존치 여부 | §1.18에 따라 0-B 소관 |
| `resolve_store_staff_actor()` 재설계 | 0-B 완료 이후 |
| Scope Type / Scope Level 통합 taxonomy | §1.20에서 해석 확정을 보류. 후속 ERD/Authorization 설계 |
| 프랜차이즈 본사의 CatchMenu 접근 scope 명칭 | §1.21이 `COMPANY`/`BUSINESS_UNIT` 사용을 배제. 별도 명칭은 2단계 |
| `cross_business_link` 가 scope 인가 관계인가 | `020320` §10은 scope type으로, `000150` §26은 개념 엔티티로 나열 |
| Tenant ↔ MerchantAccount 1:N 전환 시점 | §1.22에서 1:1 확정. 실제 사례 발생 시 재검토 |
| Store 당 LegalEntity cardinality | §1.24는 "명시되어야 한다"까지만 확정. 단일/복수·이력 표현은 2단계 |
| `merchant_accounts` 물리 구현 | 개념 확정(§1.22·§1.23). SQL 미구현 — 2단계 ERD |
| Company / BusinessUnit persistent entity 필요성 | §1.21은 의미만 확정. 물리 엔티티 필요성은 2단계 조사에서 OPEN |
| `000170` §6 `Merchant Company` 절 정정 | §1.25에서 legacy composite 로 분류. 문서 정정은 후속 상위문서 정합화 작업 |
| `010640` §4 `company_id` 어휘 | *corporate entity if separate from legal entity* 로 서술되어 용어 오염 잔존. 정정 대상 |
| Tenant 격리 invariant 의 표현 방식 | §1.26은 구조 관계와 구분만 확정. 물리 표현은 4·5단계 |
| Store 상태 3축의 canonical enum | §1.27에서 축 존재·독립성만 확정. 값 집합은 후속 |
| 상태 전이 규칙 | 동상 |
| `STORE_ACTIVE_PAID` 류 결합 명칭 분해 여부 | §2.1(과금 미결)에 걸림 |
| 각 계층 상태 enum (Tenant / MerchantAccount / Store) | §1.28은 원칙만 확정 |
| 고객사-side `company` 용어 정정 (`009070`/`003020`) | §1.29에서 분해 대상으로 판정. 문서 정정은 후속 상위문서 정합화 |
| `OperatingGroup` persistence | §1.30 — ACTIVE 문서 넷이 미결로 남김 |
| `Brand` 축의 canonical 정의 | §1.13·§1.29가 축 존재만 확정. 엔티티 여부는 후속 |
| `legal_entities` 0행의 실제 원인 | §1.31 — intake 미수행 여부를 onboarding evidence 로 확인 |
| `store_operator_type` 의 canonical 표현 | §1.32는 축 분리만 확정. 값·필드는 후속 |
| 프랜차이즈 본사가 별도 Tenant 인가 | §1.32 — `hq_tenant_candidate_id` 는 candidate 단계. 확정 근거 부족 |
| `cross_business_link` 물리 구조 | §1.33 — `000190` §10이 필드를 제시하나 구현은 후속 |
| Store–LegalEntity 시점 관계의 물리 구조 | §1.34 — 별도 테이블 여부·현재 포인터 위치는 2단계 ERD |
| 유효기간 중첩 방지 검증 방식 | §1.34 — exclusion constraint 등. 물리 설계 |
| `orders.legal_entity_id` 구현 | §1.35 — 원칙만 확정. 주문 객체는 0-A 범위 밖 |
| Tenant 이전 절차·데이터 처리·권한 승계 | §1.36 — 두 사건이 다르다는 것만 확정 |
| **Finding-1**: `contact_email` 평문 vs `contact_phone_hash` 해시 비대칭 | PII 처리 방침이 컬럼마다 다른 근거 불명. 별도 검토 |
| **Finding-2**: `role_type` `INVESTOR` 가 organizational role 인가 | `OWNER` 는 `601501` §0.6이 조직역할로 설명하나 `INVESTOR` 는 설명 없음. §1.39 적용 후에도 economic 축 혼동 여지 |
| 외부 provider 연결의 물리 구조 | §1.43 — 경계만 확정. 테이블·필드는 2단계 ERD |
| 실행 provider(KDS/DID) 개방성 조사 | §1.43 — `014050`/`014630` 은 거래 provider 만 다룸. 별도 조사 필요 |
| 거래 provider 의 옵션 구조가 구조화 필드인지 메모인지 | 초개인화 주문이 KDS 까지 전달되는지의 전제. 계약 전 확인 대상 |
| 실행 provider 가 구조화 modifier 를 손실 없이 수신·회신하는지 | 동상 |
| 외부 provider Kiosk 에서 회원 식별·preference 적용이 가능한지 | 불가하더라도 §1.42 원칙(YS-OS 가 원본)은 유지 |

### §2.3 미조사 대상

`601701` §48.2가 지정한 14개 대상 중 **5개(Company/Owner/Tenant/HQ/Store)만 조사**되었다.
아래 9개는 미조사이며, 본 선언의 범위 밖이다.

User identity / Customer identity / Staff identity / Session / Role /
Permission / Membership / Menu seed / Dining table

**A단계 조사 완료 (2026-08-13)**: HQ / Staff identity / Session / Role / Permission
5개 대상에 대한 A단계(문서만 존재) 조사가 수행되었다 — `601703`.

그 결과로 §1.7~§1.14 를 확정했다. 다만 **A단계만 수행되었으며
B~E(SQL 객체·일치·실행·권한)는 미수행**이다.
Staff·Session·Role·Permission 자체의 업무규칙은 아직 선언하지 않았다.

### §2.4 문서 간 충돌 — 판정 보류

`000150`과 `010640`이 프랜차이즈 본사의 소재를 다르게 다룬다.

| 문서 | 서술 |
|---|---|
| `000150` §11·§33 | 프랜차이즈 본사 거버넌스는 Franchise OS 소관. CatchMenu와 분리 |
| `010640` §4·§11 | `franchise_hq_id` 가 CatchMenu scope 차원에 존재하고 Franchise HQ 조회 범위를 규정 |

§1.10은 층위를 나눠 정리했다 — 윤슬 그룹 내부의 사업 분리(`000150` §11)와
CatchMenu가 프랜차이즈를 고객으로 수용하는 것(`000150` §13)은 다른 문제다.

**다만 `franchise_hq_id` 가 CatchMenu envelope에 있어야 하는지는 판정하지 않았다.**
`000001` §5.7 Conflict Resolution 절차를 거치지 않았으므로
어느 문서를 정정할지는 2단계 또는 별도 워크패킷에서 판정한다.

`010640` 자체의 내부 불일치도 함께 기록한다:
§4 Scope Dimension 22개에는 `franchise_hq_id` 가 있으나
§5 Mandatory Envelope Fields 22개에는 없다.

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
| `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | §4, §5, §6, §11, §12, §13, §26, §28, §33 | Company/BusinessUnit/LegalEntity 경계, Franchise OS 분리 |
| `010640_Policy_Tenant_Scope_Envelope.md` | §4, §5, §9, §10, §11 | Scope 차원, LegalEntity·운영그룹·프랜차이즈 경계 |
| `020310_Policy_User_Account_And_Login.md` | §8, §12, §29, §34, §35 | 계정유형, 세션등급, Franchise OS 로그인 경계 |
| `020320_Policy_Role_Permission_And_Scope.md` | §11, §14, §15, §21~§23, §40, §41 | Scope 레벨, Merchant/Internal Operator 역할 |
| `601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | A-1, A-3, tenant/store×login session | HQ/Staff/Session/Role/Permission A단계 조사 (Cursor, 2026-08-13). **A-2 어휘표는 신뢰 불가 — 배너 참조** |
| `601211_Overview_Caller_Authorization_Resolver_Pilot.md` | 최종상태, §3.1, §3.2, §3.4, §4, §5 | JWT↔staff 브리지 부재 사실 기록. **권위보류** |
| `601212_Logic_Caller_Authorization_Resolver_Pilot.md` | §0, §1.2 | resolver 설계 원칙과 보류 사유. **권위보류** |
| `601704_Register_Stage2_ERD_Relationship_Survey.md` | Q1~Q8, Core 5축 속성 | 2단계 ERD 선행 관계·cardinality 조사 (Cursor, 2026-08-13). Q1·Q5는 미판정이며 §1.22·§1.23이 Human Decision으로 확정 |
| `601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | V1~V5, Blocker 6건 | 3단계 인접 도메인 대조 (Cursor, 2026-08-13). 외부 어휘·누락 중심 |
| `601707_Audit_Stage3_Adjacent_Domain_Codex.md` | V1~V5, Blocker 6건 | 3단계 인접 도메인 대조 (Codex, 2026-08-13). ERD 내부 정합성 중심 |
| `000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | §10, §11, §21 | CatchMenu ↔ Franchise OS 경계 전담 문서. §1.33 |
| `010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | §4, §10, §11 | 영업 intake — LegalEntity business identity source. §1.31~§1.32 |
| `601708_Evidence_Stage4_Overview_Evidence_Pack_Cursor.md` | E-1~E-4 | 4단계 Evidence Pack (Cursor). `000701` §46 |
| `601709_Evidence_Stage4_Overview_Evidence_Pack_Codex.md` | E-1~E-4 | 4단계 Evidence Pack (Codex). §35 이중 검증 |
| `601714_Evidence_Stage4_Logic_Gap_Survey_Cursor.md` | Q-2, Q-4, Q-8 | `601713` Logic §6 미해결 5건 조사 (Cursor, 2026-08-21~22) |
| `601715_Evidence_Stage4_Logic_Gap_Survey_Codex.md` | 동상 | 동일 조사 (Codex, 2026-08-21). `000701` §35 이중 검증 |

권위보류 문서(`601501`/`601503`/`601211`/`601212`)는 §3 및 `600020` §3에 따라 **사실 기록 목적으로만** 인용했으며, 그 설계 결론을 승인한 것이 아니다.

두 도구의 발견이 갈렸다(`000701` §35 — 검증자 1명의 사각지대).
Cursor 는 `Merchant Company` 부재와 store 상태축 누락을,
Codex 는 ERD 내부 모순(미정 관계를 확정 기호로 표기)을 잡았다.

**Evidence Pack 이중 수행 결과** (`000701` §35·§46)

Cursor 와 Codex 가 독립 수행한 결과 합집합 79건 중
**한쪽만 찾은 문서가 40건**이었다(Cursor 26 / Codex 14).
Cursor 는 조직·경계·거버넌스 계열을, Codex 는 금융·법무·API 계열을 더 찾았다.

**어느 하나만 수행했다면 절반 가까이 놓쳤을 것이다.**
§46이 든 CH-F04 사례(`005191`/`005241` 독립 작성 충돌)와 같은 위험이다.

## §5 확정 기록

```text
확정:     정영석
일자:     2026-08-13 (§1.1~§1.33) / 2026-08-22 (§1.34~§1.39)
범위:     Owner 축 (§1.1~§1.6)
          조직 경계 · HQ 어휘 · 세 세계 분리 (§1.7~§1.12)
          LegalEntity / MerchantAccount 축 (§1.13~§1.14)
          Identity 축 · 0-B 인계 조건 (§1.15~§1.18)
          Role/Permission/Scope 축 (§1.19~§1.21)
          Tenant/MerchantAccount/Store cardinality (§1.22~§1.24)
          Merchant Company 정규화 · Store 구조 경로 (§1.25~§1.26)
          Store 상태 3축 분리 · 계층 상태 독립 (§1.27~§1.28)
          company 어휘 정규화 · OperatingGroup 축 (§1.29~§1.30)
          LegalEntity intake source · operator_type 축 · cross-business link (§1.31~§1.33)
          Store–LegalEntity 시점 관계 · 금전 snapshot · Tenant 이전 구분 (§1.34~§1.36)
          Person 어휘 정규화 · is_active 제거 · ownership_percent 제거 (§1.37~§1.39)
          SaaS 구조 선행 원칙 · 플랫폼/데이터 판별 기준 (§1.40~§1.41)
          네 시스템 경계 어휘 · 외부 provider 연결 귀속 (§1.42~§1.43)
미결:     Session 상세 (0-B 소관, §1.18)
          Scope taxonomy 통합 (§1.20)
          000150 ↔ 010640 franchise_hq_id 충돌 판정 (§2.4)
          000170 §6 / 010640 §4 어휘 정정 (§2.2)
          과금 관계 (§2.1 — 이번 나선에서 정하지 않음)
          Finding-1 PII 처리 비대칭 / Finding-2 INVESTOR role taxonomy (§2.2)
          실행 provider(KDS/DID) 개방성 조사 (§2.2)
```
