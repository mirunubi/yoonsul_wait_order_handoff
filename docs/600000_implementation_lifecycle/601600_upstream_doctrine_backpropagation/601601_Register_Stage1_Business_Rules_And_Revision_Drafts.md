# 601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md

Status: **적용 완료 (2026-08-11)** — §4 확인 필요 4건 전부 해소, 5개 문서 개정삽입 적용됨
Lifecycle: Register
Stage: **1단계 업무규칙 선언**(Human 전담) + 개정 초안(Claude Code) — `000701` §47.1
Domain: Upstream Doctrine Backpropagation
Last Updated: 2026-08-11

## §0 이 문서의 위치

`000701` §47.1의 6단계 나선 중 **1단계(업무규칙 선언)** 산출물이다.

**2026-08-11 적용 완료**: §4의 확인 필요 4건이 전부 해소됐고, §3의 개정삽입이 **5개 문서에 실제 적용**됐다.
§3은 이제 초안이 아니라 **적용된 내용의 기록**이다.

| 대상 문서 | 삽입 위치 | 상태 |
|---|---|---|
| `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | `Legacy path` 직후 (§1 Purpose 앞) | ✅ 적용 |
| `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | §14 직전 | ✅ 적용 |
| `003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | §2 축 표 직후 | ✅ 적용 |
| `009030_Register_Conceptual_Entity_Master.md` | §2 엔터티 표 직후 | ✅ 적용 |
| `010004_Policy_SaaS_Tenant_Isolation_...md` | §4 표 직후 (**§4.1 신설**) | ✅ 적용 |

**원본 보존 확인**: 5개 문서 모두 **기존 내용을 한 줄도 삭제하지 않았고**, 새 섹션만 삽입했다(§1.1 준수).

---

## §1 1단계 업무규칙 (Human 확정, 그대로 기록)

| # | 규칙 |
|---|---|
| 1 | `000170`의 `STORE_TRIAL_ACTIVE`/`STORE_SUSPENDED`/`STORE_TERMINATED`/`TRIAL_ACTIVE`/`CONVERTED` 등 어휘를 **superseded 표시**하고, 실제 구현 어휘(`tenants.tenant_status`/`isolation_state`, `stores.store_status`)로 **리다이렉트하는 개정 삽입** |
| 2 | `000150`/`009030`의 `companies`/`business_units` 개념에 **"이 프로젝트에서는 `legal_entities`(사업자축) + `franchise_brands`(브랜드축)로 실현됨"** 공식 주석 삽입. `601501` §0.4 축 정의표를 원본 위치로도 이전 |
| 3 | `010004`에 **"전역 테이블 예외"** 조항 신설. 0-A의 신규 4테이블이 첫 사례임을 명시하고, **예외 요건**(GRANT 없음 + `SECURITY DEFINER` 경유만 + `601503` §9 6대 규칙 준수)도 함께 기록 |
| 4 | **`ACTIVE`+`ISOLATED` 과금정책**은 Open Item으로 유지("사업 정책 추후 결정"). **0-A-2가 과금 로직에 의존하는 어떤 것도 만들지 않도록** 제약으로 명시 |

### §1.1 절대 금지 (Human 지시)

- 상위 문서 **전체 재작성 금지** — 기존 내용 보존 + 새 섹션/각주로만 반영
- `franchise_brands` 등 **다른 파일 수정 금지**
- **`.sql` 수정 금지**

---

## §2 조사 결과 — 실제 구현된 어휘 (유일한 진실원천)

| 컬럼 | 허용값 | 출처 |
|---|---|---|
| `tenants.tenant_status` | `ACTIVE` / `TRIAL` / `SUSPENDED` / `CANCELLED` / `TERMINATED` | `0168` |
| `tenants.isolation_state` | `NONE` / `ISOLATED` | `0168` |
| `stores.store_status` | `PREPARING` / `ACTIVE` / `SUSPENDED` / `CLOSED` | `0002` |

**신규 4테이블**(전역, `tenant_id` 컬럼 **없음**): `catchmenu_hq.owners` / `legal_entities` /
`legal_entity_person_roles` / `legal_entity_representatives` (`0168`) + `catchmenu_authority_owner` role (`0169`).

---

## §3 개정 삽입 초안 (미적용)

### §3.1 `000170_Policy_Merchant_Account_Company_And_Store_Context.md` — 업무규칙 1

**삽입 위치**: §14 "Store Service Status" 직전(L385 부근). §14/§15/§16 세 절을 한 번에 덮는 각주.

> ### ⚠️ 2026-08-11 개정 — §14 / §15 / §16 상태 어휘는 SUPERSEDED
>
> 아래 §14(Store Service Status) / §15(Store Operating Status) / §16(Trial Status)의 상태값 목록은
> **"Suggested"(제안) 단계에서 작성된 것이며, 실제 구현된 어휘가 아니다.**
> 0-A 워크패킷(`601500`, 마이그레이션 `0168`/`0169`, 2026-08-11 완료)이 확정한 실제 어휘는 아래와 같다.
>
> **구현된 상태 축 3개**
>
> | 축 | 컬럼 | 허용값 | 의미 |
> |---|---|---|---|
> | 구독 생명주기 | `catchmenu_hq.tenants.tenant_status` | `ACTIVE`/`TRIAL`/`SUSPENDED`/`CANCELLED`/`TERMINATED` | tenant 단위 구독 상태 |
> | **보안 격리** | `catchmenu_hq.tenants.isolation_state` | `NONE`/`ISOLATED` | **구독 축과 직교** — 동시 표현 가능 |
> | 매장 운영 | `catchmenu_hq.stores.store_status` | `PREPARING`/`ACTIVE`/`SUSPENDED`/`CLOSED` | store 단위 |
>
> **서비스 가능 판정은 두 축의 AND다**(`601501` §3.1):
> `serviceable := tenant_status IN ('ACTIVE','TRIAL') AND isolation_state = 'NONE'`.
> **한쪽만 확인하는 코드는 격리를 무력화하므로 금지**한다.
>
> **어휘 대응 — 1:1 치환이 아니다**
>
> | 본문(§14/§15/§16)의 어휘 | 실제 구현 | 성격 |
> |---|---|---|
> | `STORE_SERVICE_PENDING` / `STORE_TRIAL_ACTIVE` / `STORE_TRIAL_EXPIRED` / `STORE_ACTIVE_PAID` / `STORE_TERMINATION_PENDING` / `STORE_REACTIVATION_PENDING` | **미구현** | store 단위 *서비스* 상태 축 자체가 구현되지 않았다. 구독 상태는 **tenant 단위**에만 존재한다 |
> | `STORE_SUSPENDED` / `STORE_TERMINATED` | `stores.store_status='SUSPENDED'` / (없음) | `TERMINATED`는 store에 없고 `tenants.tenant_status`에만 있다 |
> | §15 `PRE_OPEN`/`OPEN`/`TEMPORARILY_CLOSED`/`CLOSED`/`MOVED`/`UNKNOWN` | `stores.store_status`의 `PREPARING`/`ACTIVE`/`SUSPENDED`/`CLOSED` | **값이 다르고 개수도 다르다.** `MOVED`/`UNKNOWN` 미구현 |
> | §16 `TRIAL_NOT_STARTED`/`TRIAL_PENDING`/`TRIAL_ACTIVE`/`TRIAL_EXTENDED`/`TRIAL_EXPIRED`/`CONVERTED`/`DECLINED`/`NOT_USING`/`UNREACHABLE`/`RECOVERY_REQUIRED` | `tenants.tenant_status='TRIAL'` **단일 값** | 10개 세분값이 **1개로 축약**됐다. 체험 생명주기 추적은 미구현 |
>
> **이 문서의 §14–§16이 틀렸다는 뜻이 아니다.** 정책 의도로서는 유효하며,
> **구현이 아직 그만큼 세분화되지 않았을 뿐**이다. 코드를 작성할 때는 위 "실제 구현" 열을 따르고,
> 세분화가 필요해지면 별도 워크패킷으로 확장한다.
>
> 근거: `601501_ERD_Tenant_Company_HQ_Store.md` §3/§3.1/§3.2, `sql/migrations/0002`·`0168`.

---

### §3.2 `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` — 업무규칙 2

**삽입 위치**: `## Purpose` 직후(문서 최상단 각주).

> ### ⚠️ 2026-08-11 개정 — 이 문서의 개념이 실제로 어떻게 실현됐는가
>
> 본 문서가 다루는 **company / business_unit / legal_entity** 개념은,
> 0-A 워크패킷(`601500`, 2026-08-11 완료)에서 다음과 같이 실현됐다.
>
> | 본 문서의 개념 | 실제 구현 | 비고 |
> |---|---|---|
> | **legal entity**(계약·세무·정산 주체) | **`catchmenu_hq.legal_entities`** (신규, `0168`) | 사업자등록번호를 보유하는 유일한 테이블 |
> | **company**(브랜드·운영 그룹핑) | 기존 `catchmenu_hq.franchise_brands` | **신규 테이블을 만들지 않았다** |
> | business_unit / operating group | 기존 `catchmenu_hq.store_groups` (`group_type='REGION'`만 사용) | |
>
> **⚠️ 어휘 함정**: `legal_entities.entity_type = 'CORPORATION'`은 **법인격의 종류(legal form)** 를 뜻하며,
> 본 문서·`003020`이 말하는 **"company 축(브랜드 그룹핑)"과 다른 개념**이다.
> "법인 = Company"로 읽으면 두 축이 뒤섞인다.
>
> **사업자 축 vs 브랜드 축** (`601501` §0.4에서 이전)
>
> | 사업자 축 — `legal_entities` | 브랜드 축 — `franchise_brands` |
> |---|---|
> | 법인격 종류(`entity_type`) | 상표·브랜드명(`brand_name`/`brand_code`) |
> | 사업자등록번호(`business_registration_number`) | 로열티 정책(`royalty_rate_pct`) |
> | 법인등기번호(`corporate_registration_number`) | 브랜드 가이드(`brand_guidelines_url` 등) |
> | 대표권(`legal_entity_representatives`) | 멤버십·메뉴 공유(`shared_membership` 등) |
> | **누가 법적 책임을 지는가** | **어떤 간판을 달고 무엇을 공유하는가** |
>
> **사업자등록번호의 경계**(`601501` §2.1.1): 사업자등록번호는 **등록의 식별자**이지
> **법적 정체성의 근본 존재론이 아니다.** 한 법인이 복수 사업장·등록단위를 가질 수 있고,
> 개인사업자는 사업체와 자연인이 완전히 분리되지 않는다. 현재 구현은 **1:1 MVP 단순화**이며,
> 동일성 판단 기준은 `business_registration_number`가 아니라 **`legal_entities.id`** 다.
>
> **아직 모델링되지 않은 것**: **소유권(지분)**. 대표권(`legal_entity_representatives`)·
> 역할(`legal_entity_person_roles`)과 **독립된 개념**이며 별도 테이블이 필요하다
> (`601501` §0.6, Open Item (q)). **`legal_entity_person_roles.ownership_percent` 컬럼을
> 소유권 모델로 사용하지 말 것** — 개념 혼재이며 사용 금지 상태다(`601501` §2.3.1).
>
> 근거: `601501` §0.4/§0.6/§2.1.1/§2.3.1, `sql/migrations/0168`.

---

### §3.3 `009030_Register_Conceptual_Entity_Master.md` — 업무규칙 2

**삽입 위치**: `company` / `legal_entity` 행이 있는 표(L15–21) 직후.

> ### ⚠️ 2026-08-11 개정 — 구현 대응 (0-A `601500`)
>
> | 개념 엔터티 | 실제 구현 | 상태 |
> |---|---|---|
> | `legal_entity` | **`catchmenu_hq.legal_entities`** (`0168`) | 구현됨 |
> | `company` | 기존 `catchmenu_hq.franchise_brands` | **신규 테이블 없음** — 브랜드 축이 담당 |
> | `operating_group` | 기존 `catchmenu_hq.store_groups`(`REGION`만) | 부분 사용 |
> | `store` / `tenant` | 기존 `catchmenu_hq.stores` / `tenants` | 기존 유지 |
> | (신규) 자연인 | **`catchmenu_hq.owners`** | 본 문서에 대응 개념 없음 — §아래 주의 |
> | (신규) 대표권 | **`catchmenu_hq.legal_entity_representatives`** | 동상 |
> | (신규) 조직 역할 | **`catchmenu_hq.legal_entity_person_roles`** | 동상 |
>
> 본 문서의 **"`company` is Not automatically legal entity"** 원칙은 구현에서 지켜졌다 —
> 두 축이 서로 다른 테이블(`franchise_brands` / `legal_entities`)로 분리돼 있다.
>
> **⚠️ `owners` 명칭 주의**(`601501` §2.4.1): `catchmenu_hq.owners`는
> **"법적 사업주체와 관계를 맺는 자연인"** 을 뜻하며,
> **SaaS 계정 소유자(tenant admin)도, 지분 보유자도 아니다.** 로그인·권한 주체는 0-B/0-C 소관이다.
>
> 근거: `601501` §0.6/§2.4.1, `sql/migrations/0168`.

---

### §3.4 `003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` — 업무규칙 2 (파생)

**삽입 위치**: §2 "Context Axes" 표 직후. **§6 Open Decisions의 1번 항목에 대한 답이기도 하다.**

> ### ⚠️ 2026-08-11 개정 — 이 축 모델의 구현 결과 (0-A `601500`)
>
> 본 문서가 규정한 축 분리는 **LegalEntity 중심 모델**로 실현됐다.
>
> | 축 | 구현체 | 비고 |
> |---|---|---|
> | `legal_entity` | **`catchmenu_hq.legal_entities`**(신규) | 사업자번호 보유 |
> | `company` | `catchmenu_hq.franchise_brands`(기존) | **`store_groups`가 아니다** |
> | `operating_group` | `catchmenu_hq.store_groups`(`REGION`만) | |
> | `tenant` / `store` | `tenants` / `stores`(기존) | `stores.legal_entity_id` FK 신규 |
>
> **Store → LegalEntity 단일 경로**: `stores.legal_entity_id` **하나뿐**이며,
> `company_id`/`owner_id`로 갈라지는 두 갈래 FK는 **의도적으로 만들지 않았다** —
> 하나의 사실이 두 곳에 있으면 반드시 갈라지기 때문이다(`601501` §0.1 원칙 2).
>
> **§6 Open Decision "whether company/legal_entity required for every tenant"에 대한 0-A의 답**:
> MVP에서 **LegalEntity를 필수로 둔다**(Store가 법적 주체를 갖도록).
> 단 `stores.legal_entity_id`는 백필 완료 전까지 nullable이다(`601501` §2.5).
>
> 근거: `601501` §0.1/§0.3, `sql/migrations/0168`.

---

### §3.5 `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` — 업무규칙 3

> **⚠️ 이 초안은 §4.2의 확인이 먼저 필요하다** — 원문이 "모든 객체"가 아니라
> **"tenant-owned objects"** 로 이미 한정하고 있어, "예외 신설"이 맞는 표현인지 판단이 필요하다.

**삽입 위치(안)**: §4 "Mandatory Context Fields" 표 직후, 신설 §4.1.

> ### §4.1 ⚠️ 전역 테이블 (Global Tables) — 2026-08-11 신설
>
> §4의 `tenant_id` 요건은 **"tenant-owned objects"** 에 적용된다.
> **어떤 tenant에도 속하지 않는 전역 테이블**은 tenant-owned가 아니므로 `tenant_id`를 갖지 않으며,
> 이는 §25 Anti-Patterns의 *"tenant id optional on tenant-owned objects"* 위반이 **아니다.**
>
> **전역 테이블의 판별 기준**: 해당 행이 **여러 tenant에 걸쳐 동일한 실체**를 가리키는가.
> 예 — 하나의 법적 사업주체가 서로 다른 tenant 소속 매장을 동시에 운영할 수 있다.
> 이 경우 `tenant_id`를 넣으면 **같은 실체가 tenant마다 중복 생성**되어 오히려 무결성이 깨진다.
>
> **첫 사례 (0-A `601500`, `0168`)** — `catchmenu_hq` 스키마의 4개 테이블:
> `owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives`
>
> **전역 테이블이 충족해야 할 요건 (전부 필수)**
>
> | # | 요건 | 근거 |
> |---|---|---|
> | 1 | **클라이언트 도달 가능 역할에 테이블 GRANT를 부여하지 않는다** (`authenticated`/`service_role`/`anon`) | `601505` §2.1 |
> | 2 | 접근은 **`SECURITY DEFINER` 함수 경유만** 허용한다 | `601501` §2.7 |
> | 3 | 그 함수는 **`601503` §9의 6대 규칙**을 지킨다 — 전용 owner role(`catchmenu_authority_owner`) / `search_path` 고정(`public` 제외) / `PUBLIC EXECUTE` 회수 / schema-qualified 참조 / **함수 내부 tenant 권한 검증** | `601503` §9 |
> | 4 | RLS는 `enable`+`force`, 정책은 0-C가 설계 전까지 두지 않는다 | `601501` §2.7.2 |
>
> **⚠️ 3번의 tenant 검증이 이 예외의 핵심이다.** 전역 테이블에는 `tenant_id`가 없으므로
> **RLS만으로는 tenant를 구분할 근거가 테이블 안에 없다.** `SECURITY DEFINER`는 RLS를 우회하므로,
> 함수 내부에서 호출자의 tenant 권한을 직접 검증하지 않으면
> **"tenant A가 tenant B의 법적 주체를 조회"하는 confused deputy**가 된다.
> 검증은 `stores.legal_entity_id`를 경유한다(`601503` §9.3).
>
> **base table GRANT 제거가 multi-tenant isolation을 자동 보장하지 않는다** —
> 잘못 작성된 `SECURITY DEFINER` 함수 하나가 격리를 뚫는다.
>
> 근거: `601501` §2.7, `601503` §9, `601510`(Stage 11B 블라인드 감사) 조건 ②.

---

## §4 확인 필요 지점 — **전부 해소됨 (Human 결정, 2026-08-11)**

| # | 쟁점 | **결정** |
|---|---|---|
| §4.1 | 대상 문서 4개 vs 5개 | **5개 확정** — `003020`/`009030`/`000150`/`000170`/`010004` 전부 포함 |
| §4.2 | `010004` 삽입 명칭 | **"해설(clarification)" 채택** — "예외 조항" 표현을 전부 제거. 원 규칙이 이미 `tenant-owned`로 한정돼 있었음을 명시하고, 0-A 4테이블이 **왜** tenant-owned가 아닌지(전역 개념)를 설명하는 형태 |
| §4.3 | `000170` 미구현 항목 표기 | **백로그 후보로 승격 + 트리거 조건 명시** — "미구현"으로만 두지 않음 |
| §4.4 | 업무규칙 4 기록 위치 | **본 문서 §5 Open Item + §5.1 제약**으로 유지(상위 문서에 과금 정책 조항 없음). 추가로 **0-A-2 착수 시 필독**으로 표시 |

### §4.3-R `000170` 백로그 후보 3건과 트리거 조건 (적용된 내용)

| # | 백로그 후보 | **트리거 조건** |
|---|---|---|
| 1 | store 단위 서비스 상태 축(§14 전체) | **매장별 개별 과금이 필요해지면** |
| 2 | 체험 상태 10개 세분화(§16) | **체험 정책이 단순 `TRIAL` 이상으로 세분화되면** |
| 3 | `MOVED` / `UNKNOWN`(§15) | **실제 운영 중 이 상태가 필요한 사례가 발생하면** |

---

## §4-OLD 확인 필요 지점 (원문 보존 — 결정 근거)

> 아래는 §4 결정의 **근거가 된 원 분석**이다. 결정이 왜 그렇게 났는지 추적 가능하도록 보존한다.

### §4.1 대상 문서가 4개인가 5개인가

지시서의 **배경**은 `000150`/`000170`/`003020`/`010004` **4개**를 들었으나,
**업무규칙 2번**은 `000150`/**`009030`**을 지목한다. 즉 `009030`이 추가로 등장하고,
`003020`은 어느 규칙에도 명시되지 않았다.

본 문서는 **5개 전부에 대한 초안**을 준비했다(§3.1–§3.5).
`003020`은 축 정의의 **원 출처**이므로 역전파 대상에 포함하는 것이 타당하다고 판단했으나,
**최종 대상 목록은 Human이 확정**해야 한다.

### §4.2 `010004`는 "모든 객체 tenant_id 필수"가 아니다 — "예외 신설"이 맞는 표현인가

**업무규칙 3의 전제**는 *"010004: 모든 객체는 tenant_id 필수"* 였다. **원문은 다르다**:

| 위치 | 원문 |
|---|---|
| §4 표 | `` `tenant_id` `` \| **Required for all tenant-owned objects** |
| §25 | Avoid: *"tenant id optional on **tenant-owned** objects"* |

두 곳 모두 **`tenant-owned`로 이미 한정**돼 있다. 또한 §4 표에는
`` `legal_entity_id` `` \| *"Required when settlement/legal ownership matters"* 가 **이미 존재**한다.

따라서 필요한 것은 **"절대 규칙에 대한 예외"가 아니라
"tenant-owned가 아닌 객체의 판별 기준과 요건을 명시하는 해설(clarification)"** 일 수 있다.

> **왜 이 구분이 중요한가**: "예외 조항 신설"이라고 쓰면 **원 규칙이 절대적이었다고 잘못 기술**하게 된다.
> 이는 이 프로젝트가 방금 `000001` §5.12에서 정정한 것과 **같은 실패 유형**이다 —
> 문서가 다른 문서를 부정확하게 인용해 **규범의 강도를 바꾸는 것**.

**Human 결정 필요**: (a) §3.5 초안대로 **"해설/명시"** 로 삽입할 것인가,
(b) 그래도 **"예외 조항"** 이라는 명칭을 쓸 것인가.
본 초안은 (a)로 작성했다.

### §4.3 `000170`은 "리다이렉트"가 성립하지 않는 항목이 많다

업무규칙 1은 *"실제 구현된 어휘로 리다이렉트"* 를 지시했으나, 조사 결과 **1:1 치환이 불가능**하다:

- §14의 store 단위 **서비스** 상태 축은 **아예 구현되지 않았다**(구독 상태는 tenant 단위에만 존재)
- §16의 체험 상태 **10개 값이 `TRIAL` 1개로 축약**됐다
- §15의 운영 상태는 값 자체가 다르다(`MOVED`/`UNKNOWN` 없음)

§3.1 초안은 이를 **"미구현"으로 정직하게 표기**했다.
**Human 결정 필요**: 이 표기를 (a) 그대로 둘 것인가, (b) 미구현 항목을 **별도 백로그**로 승격할 것인가.

### §4.4 업무규칙 4의 기록 위치

`ACTIVE`+`ISOLATED` 과금정책 Open Item은 **상위 문서 개정 대상이 아니다**(어느 문서에도 과금 정책 조항이 없음).
따라서 §5에 워크패킷 Open Item으로 기록하고 `600010` 트래커에 반영했다.
**별도 정본 문서(예: 과금 정책 문서)에 넣어야 한다면 Human 지정 필요.**

---

## §5 Open Items

| # | 항목 | 상태 |
|---|---|---|
| (a) | **`ACTIVE`+`ISOLATED` 동시상태의 과금 정책** — 격리 중인 tenant에게 과금할 것인가 | **사업 정책 추후 결정.** 기술 결정 아님 |
| (b) | `000170` §14/§16 미구현 어휘의 백로그 승격 여부 | §4.3 |
| (c) | 역전파 대상 문서 최종 목록(4 vs 5) | §4.1 |
| (d) | `010004` 삽입 명칭("해설" vs "예외 조항") | §4.2 |

### §5.1 ⚠️⚠️ 0-A-2 착수 시 필독 — 과금 로직 의존 금지 (업무규칙 4)

> **0-A-2가 1단계(업무규칙 선언)를 작성할 때, 본 절을 명시적으로 인용해 제약으로 재선언할 것.**
> 이 제약이 0-A-2의 업무규칙에 다시 적혀 있지 않으면, 착수 검증에서 반려한다.
> (`600010` 트래커의 0-A-2 행에도 동일 표시가 있다.)

> **0-A-2는 과금 로직에 의존하는 어떤 것도 만들지 않는다.**
>
> `ACTIVE`+`ISOLATED` 상태의 과금 처리가 **미결(Open Item (a))** 이므로,
> 0-A-2가 `manage_subscription()`/`isolate_tenant()`를 재작성할 때
> **"격리 중 과금 중단/계속" 같은 판단을 코드에 넣어서는 안 된다.**
> 상태를 **정확히 기록**하는 데까지만 하고, 과금 해석은 정책 확정 후 별도 워크패킷이 맡는다.
>
> 이 제약을 어기면 미확정 사업 정책이 코드에 **암묵적으로 확정**되어 버린다.

---

## §6 근거 문서 목록 (§46)

| 문서 | 인용 |
|---|---|
| `000701` §46/§47.1(6단계 나선 1단계 정의)/§48 | 단계 정의·근거목록 |
| `601501_ERD...md` (v5) | §0.1/§0.3/§0.4/§0.6/§2.1.1/§2.3.1/§2.4.1/§2.5/§2.7/§3.1/§3.2 |
| `601503_Logic...md` (v5) | **§9**(SECURITY DEFINER 6대 규칙), §9.3(tenant 검증) |
| `601505_ChangeContract...md` (v3) | §2.1(GRANT 경계) |
| `601510_AuditReview_Stage11B_Blind_Audit.md` | 조건 ②(tenant 경계·confused deputy) |
| `000150_Policy_...md` | 개정 대상 — `## Purpose` 이하 전체 |
| `000170_Policy_...md` | 개정 대상 — §14(L385–), §15, §16(L436–) |
| `003020_Guide_...md` | 개정 대상 — §2 축 정의표, §6 Open Decisions |
| `009030_Register_...md` | 개정 대상 — L15–21 개념 엔터티 표 |
| `010004_Policy_...md` | 개정 대상 — **§4 표(L78 `tenant_id` "Required for all tenant-owned objects")**, §25 |
| `sql/migrations/0002` / `0168` / `0169` | 실제 구현 어휘의 진실원천 |
