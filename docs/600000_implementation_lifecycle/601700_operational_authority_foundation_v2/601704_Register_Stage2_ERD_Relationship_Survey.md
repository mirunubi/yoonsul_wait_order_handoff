# 601704_Register_Stage2_ERD_Relationship_Survey.md

> ⚠️ **2단계 ERD 선행 조사 · 판정이 아니다**
>
> 이 문서는 `000701` §47.1의 **2단계(ERD 초안)** 작성을 위한 관계·cardinality 조사다.
> 조사 결과이며 설계 판정이 아니다.
>
> **조사 원칙**: SQL 존재 여부를 ERD 채택 기준으로 삼지 않는다.
> 1단계 Human Business Rules(`601702`) → authoritative source documents →
> SQL(physical evidence) 순으로 우선한다.
> 어떤 개념이 SQL에 없다는 것은 `DESIGN EXCLUDED` 가 아니라
> `CONCEPT PRESENT / PHYSICAL IMPLEMENTATION MISSING` 이다.
>
> **Q1(Tenant↔MerchantAccount)과 Q5(한 Account 아래 복수 LegalEntity)는
> 이 조사에서 「추정만 가능」 / 「근거 없음」으로 판정되었고,
> 이후 `601702` §1.22·§1.23에서 Human Decision 으로 확정되었다.**
> 이 문서의 미판정 상태를 근거로 그 선언을 뒤집지 않는다.
>
> 수행: Cursor, 2026-08-13.

> **근거**: `000701` §34.1 대용량 스캔 · §47.1 2단계(ERD 초안)  
> **조사일**: 2026-08-13 · **범위**: 관계·cardinality 문서 근거 수집만 (ERD/DDL 제안 없음)  
> **우선순위**: (1) `601702` §1.1~§1.21 → (2) authoritative source docs → (3) SQL 실측(physical evidence, 설계 근거 아님)

---

## Q1. Tenant ↔ MerchantAccount

### 문서 근거

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `601702_Register_Stage1_Business_Rules.md` §1.14 | `MerchantAccount는 **CatchMenu의 SaaS 계약·관리 단위**다. LegalEntity 경계와도, Brand 경계와도, User Identity와도 **독립이다.**` | MerchantAccount = SaaS 계약·관리 단위 (Tenant와 동의어·관계 미명시) | Human Business Rule (1순위) |
| 2 | `601702` §1.14 | `- **MerchantAccount 개수를 전역 규칙으로 고정하지 않는다.** 계약·관리 단위가 결정한다` | 1:1/1:N 고정 규칙 없음 | |
| 3 | `003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` §2 | `\| tenant \| SaaS customer boundary and contract scope. \| ... \| Root SaaS boundary for stores and configuration. \| Required. \|` | Tenant = SaaS 고객 경계 (최상위 축) | ACTIVE |
| 4 | `000170_Policy_Merchant_Account_Company_And_Store_Context.md` §4 | `Merchant Account is the top-level customer relationship in CatchMenu.` | MerchantAccount = 최상위 고객 관계 | ACTIVE |
| 5 | `009030_Register_Conceptual_Entity_Master.md` §2 | `\| tenant \| SaaS customer or contract boundary. \| ... \| Owns stores, users, package context, policies. \|` | Tenant가 store 소유 | ACTIVE |
| 6 | `009070_Matrix_Context_Entity_Alignment_Model.md` §2 | `tenant is SaaS customer boundary.` | Tenant = SaaS customer boundary | ACTIVE |
| 7 | `601701_Register_Stage0_Evidence_Collection.md` A-5 #1 | `\| 1 \| \`000170\` §4: 최상위 \`merchant_account\` \| \`003020\` §2: 최상위 \`tenant\` \| SaaS 고객 경계 명칭·계층 불일치 \|` | 두 어휘 병기·대체; cardinality 규정 없음 | |
| 8 | `601701` A-4 | `\| merchant_account \| \`000170\` §4 \| Top-level SaaS customer relationship \| tenant와 병기·대체 \|` | 동일 개념 후보로 기록; 1:1/1:N 미기재 | |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `catchmenu_hq.tenants` | TABLE 존재 (`0002_create_hq_tenant_store.sql`) | comment: `Top-level SaaS tenant boundary` |
| `merchant_accounts` (또는 동명 테이블) | **없음** | `601701` §4.3 C-1: `merchant_account` 이름다름 / 동명 SQL 0개 |
| `tenants` ↔ `merchant_account` FK | **없음** | 매핑 테이블·컬럼 미관측 |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **추정만 가능** | Tenant와 MerchantAccount 모두 "최상위 SaaS 고객 경계"로 기술되나 **1:1·1:N·동일 개념 여부를 명시한 ACTIVE 문서 없음**. `601702` §1.14은 MerchantAccount 독립성만 확정. 부족: Tenant↔MerchantAccount 대응·cardinality 명시 규정. |

---

## Q2. MerchantAccount ↔ Store

### 문서 근거

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `000170` §7 | `A merchant account may have one or more merchant stores.` | **MerchantAccount 1 : N Store** | ACTIVE |
| 2 | `000170` §9 (Multi-Store Merchant) | `merchant_account` → `merchant_company` → `multiple merchant_stores` | 1 Account : N Stores (company 중간 계층 가능) | ACTIVE |
| 3 | `000170` §8 (Single-Store Merchant) | `merchant_account` → `merchant_company optional` → `one merchant_store` | 1 : 0..1 company : 1 store (단일 매장) | ACTIVE |
| 4 | `020320_Policy_Role_Permission_And_Scope.md` §40 | `Merchant account scope may include multiple stores.` | Account scope ⊇ 복수 store | ACTIVE; scope 관점 |
| 5 | `020320` §41 | `Store scope must not expand to account scope silently.` | Store scope ⊂ Account scope (역방향 자동 확장 금지) | ACTIVE |
| 6 | `601702` §1.14 | `- 한 MerchantAccount가 여러 브랜드의 Store를 포함할 수 있다` + (`020320` §40 인용) | **1 MerchantAccount : N Store** (브랜드 혼재 가능) | Human Business Rule |
| 7 | `003020` §2 | `\| store \| ... \| Belongs to tenant; ... \| Required. \|` | Store → tenant 소속 (MerchantAccount 어휘 없음) | ACTIVE |
| 8 | `009070` §2 | `store ... Belongs to tenant` | Store → tenant | ACTIVE |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `catchmenu_hq.stores.tenant_id` | `NOT NULL references catchmenu_hq.tenants(id)` | `0002` — **Tenant 1 : N Store** |
| `merchant_account_id` on `stores` | **없음** | MerchantAccount 물리 FK 없음 |
| `merchant_stores.merchant_account_id` | **테이블 없음** | `000170` 권장 필드 미구현 |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **확정 가능** (MerchantAccount↔Store, 정책 문서) | `000170` §7·§9, `020320` §40, `601702` §1.14: **1 : N** (복수 store). |
| **추정만 가능** (Tenant↔Store로 대체 매핑 시) | SQL은 `tenant_id`만 존재. Tenant≡MerchantAccount 대응 미확정(`Q1`). |

---

## Q3. Store ↔ LegalEntity (intended cardinality)

### 문서 근거 — Source design (ACTIVE)

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `003020` §2 | `\| store \| ... \| Not tenant, not legal_entity alone. \| Belongs to tenant; may link to operating_group and company/legal context. \|` | Store ≠ LegalEntity; legal context **연결 가능** | ACTIVE |
| 2 | `003020` §3 | `- store may belong to operating_group and legal/company context.` | Store–LegalEntity: loose link | ACTIVE |
| 3 | `003020` §3 | `- do not assume one company equals one legal_entity.` | Company ≠ LegalEntity (Store linkage 간접) | ACTIVE |
| 4 | `601702` §1.4 | `매장의 법적·계약상 운영 주체는 **LegalEntity 관계로 표현**한다.` | Store → LegalEntity (법적 운영 주체) | Human Business Rule |
| 5 | `601702` §1.5 (표) | `\| Store → LegalEntity \| 누가 이 매장을 법적으로 운영하는가 \|` | Store–LegalEntity 관계 축 존재 | |
| 6 | `601702` §1.13 | `한 LegalEntity가 여러 브랜드의 매장을 운영할 수 있다.` | **LegalEntity 1 : N Store** | Human Business Rule |
| 7 | `009030` §2 (legal_entity) | `May relate to company, tenant, stores, payment profile.` | LegalEntity ↔ stores 관련 가능 | ACTIVE |
| 8 | `009030` (owners 주의) | `**전역 테이블 주의**: ... Owner/LegalEntity가 여러 tenant에 걸칠 수 있는 전역 개념` | LegalEntity–Tenant: **직접 FK 없음**, store 경유 | ACTIVE (층 A) |
| 9 | `010640` §9 | `Legal entity scope is required for financial actions.` ... `A financial object without legal entity context must not become final.` | Store/runtime 객체는 legal_entity 컨텍스트 필요(금융) | ACTIVE |
| 10 | `000150` §7 | `Legal entity should be distinct from company and business unit.` | LegalEntity 독립 축 | ACTIVE (본문; 역전파 블록 제외) |

### 문서 근거 — Implementation narrative (권위보류, 사실 기록만)

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 11 | `003020` 역전파 블록 (⛔ 권위 없음) | `Store → LegalEntity는 단일 경로다` ... `stores.legal_entity_id` **하나뿐**` | **Store N : 1 LegalEntity** (store당 FK 1개) | 역전파; `600020` §1.1 |
| 12 | `601501_ERD_Tenant_Company_HQ_Store.md` §0.1 #6 (권위보류) | `\| 6 \| \`stores\`에 운영주체 FK 1개 \| \`**\`stores.legal_entity_id\`\`** \|` | Store당 legal_entity_id 1개 | **권위보류** |
| 13 | `601501` § 관계표 (권위보류) | `\| LegalEntity → Store \| **1:N** \| \`stores.legal_entity_id\` \| Store당 정확히 1개 \|` | LE 1:N Store; each store exactly one LE | **권위보류** |
| 14 | `601501` (권위보류) | `\| **LegalEntity ↔ Tenant** \| **직접 없음** \| (stores 경유 간접) \|` | LE–Tenant 직접 관계 없음 | **권위보류** |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `catchmenu_hq.stores.legal_entity_id` | `uuid`, FK → `legal_entities(id)`, **nullable** (`0168`) | comment: legal entity association |
| `catchmenu_hq.legal_entities` | TABLE 존재; **`tenant_id` 컬럼 없음** | 전역 테이블 |
| Store당 `legal_entity_id` UNIQUE | **없음** | N store → 1 LE 허용; 1 store → N LE FK 불가(단일 컬럼) |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **확정 가능** (방향·LE 측) | `601702` §1.13, `601501`(권위보류)·`003020` 역전파: **LegalEntity 1 : N Store**. |
| **확정 가능** (Store 측, 권위보류 서술만) | `601501`/역전파: **각 Store는 정확히 1 LegalEntity** (`legal_entity_id` 단일 FK). ACTIVE `003020` §2는 "may link" 수준. |
| **추정만 가능** (ACTIVE만으로 Store-side cardinality) | ACTIVE 문서는 Store–LegalEntity **연결 필요**만 명시; store당 1 LE **강제**는 `601501`(권위보류) 또는 역전파 블록에만 명시. |

---

## Q4. LegalEntity → MerchantAccount (복수 허용/금지)

### 문서 근거

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `601702` §1.14 | `- 한 LegalEntity가 여러 MerchantAccount를 가질 수 있다` | **LegalEntity 1 : N MerchantAccount 허용** | Human Business Rule (명시) |
| 2 | `601702` §1.14 | `MerchantAccount는 ... LegalEntity 경계와도 ... **독립이다.**` | 두 축 cardinality 고정·동일 가정 금지 | |
| 3 | `000170` §4 | (Merchant Account 정의만; LE와의 cardinality **미언급**) | 규정 없음 | ACTIVE |
| 4 | `003020` §2 | (legal_entity와 tenant 병렬 축; LE–MerchantAccount **미언급**) | 규정 없음 | ACTIVE |
| 5 | `000150` §8 | `One legal entity may operate multiple business units.` | LE : N business units (MerchantAccount 아님) | ACTIVE |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `legal_entities` ↔ `merchant_account` / `tenants` | **직접 FK 없음** | LE 전역; tenant/merchant_account 매핑 컬럼 없음 |
| `merchant_accounts` table | **없음** | |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **확정 가능** (허용) | `601702` §1.14: **한 LegalEntity → 여러 MerchantAccount 가능** (명시적 Human Rule). |
| **근거 없음** (금지 규칙) | LE당 MerchantAccount **1개만** 허용/금지하는 ACTIVE 문서 **없음**. |

---

## Q5. 하나의 MerchantAccount 아래 서로 다른 LegalEntity의 Store

### 문서 근거

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `601702` §1.14 (예시) | `강남점 legal_entity = 김철수사업자 / merchant_account = 김철수 Account` ... `역삼점 legal_entity = 김철수사업자 / merchant_account = 김철수 Account` | 동일 Account 내 **동일 LegalEntity** 사례만 제시 | 다른 LE 혼재 **미언급** |
| 2 | `601702` §1.14 | `MerchantAccount ... LegalEntity 경계와도 ... **독립이다.**` | Account 경계 ≠ LE 경계 (혼재 **금지/허용 미명시**) | |
| 3 | `601702` §1.13 | `한 LegalEntity가 여러 브랜드의 매장을 운영할 수 있다.` | 1 LE : N stores (브랜드 무관) | |
| 4 | `003020` 역전파 (⛔) | `legal_entities`와 `tenants` 사이에는 **직접 관계선이 없다.** ... **서로 다른 tenant에 걸칠 수 있다.** | 1 LE → stores in **multiple tenants** 가능 (권위보류 블록) | |
| 5 | `000170` §37 (MVP defer) | `multi-legal-entity billing` (deferred) | 복수 LE billing **미래 과제**; Account 내 store 혼재 규칙 아님 | ACTIVE |
| 6 | `000170` §9 | Multi-store: `merchant_account` → `merchant_company` → multiple `merchant_stores` | **merchant_company** 계층; legal_entity 아님 | ACTIVE |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `stores.tenant_id` + `stores.legal_entity_id` | 동일 tenant 내 store들이 **서로 다른** `legal_entity_id` 가능 (nullable FK, UNIQUE 없음) | **물리적으로 혼재 가능**; 정책 근거 아님 |
| CHECK (동일 tenant → 동일 LE) | **없음** | |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **근거 없음** (허용/금지 명시) | ACTIVE·`601702` 모두 **한 MerchantAccount 아래 Store들이 서로 다른 LegalEntity를 가질 수 있는지** 명시 규정 **없음**. |
| **추정만 가능** | `601702` §1.14 독립성 + SQL상 store별 `legal_entity_id` → 혼재 **물리 가능**; 허용/금지 **문서 부재**. |

---

## Q6. Company / BusinessUnit — persistent entity vs organizational context

### 문서 근거

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `601702` §1.21 | `**0-A에서는 \`company\` 와 \`business_unit\` 을 \`000150\` 에서 정의된 CatchMenu 내부 조직축으로 해석한다.**` | CatchMenu **내부** 조직 context | Human Business Rule |
| 2 | `601702` §1.21 | `**따라서 이 둘을 아래 의미로 사용하지 않는다.**` ... `Franchise HQ` / `MerchantAccount 상위 고객집단` | 외부 고객·Franchise HQ ≠ company/business_unit | |
| 3 | `000150` §4 | `Company boundary defines who operates CatchMenu as a platform.` | Company = **CatchMenu 플랫폼 운영** 경계 | ACTIVE |
| 4 | `000150` §6 | `Business unit defines operating responsibility inside CatchMenu.` ... `It does not automatically grant permissions.` | Business unit = **내부 운영 책임**; permission ≠ | ACTIVE |
| 5 | `000150` §26 | MVP conceptual entities: `companies`, `business_units`, ... `This document defines policy.` `Actual schema may be designed later.` | **개념 엔티티**; 스키마는 후속 | ACTIVE |
| 6 | `003020` §2 | `company` / `operating_group` = context axes; `May be required depending tenant type` / `Optional initially` | **Context axis**; tenant-type 의존 | ACTIVE |
| 7 | `003020` §6 Open Decisions | `- whether company/legal_entity required for every tenant.` `- whether operating_group exists in MVP data.` | persistence **미결** (§6 OPEN) | ACTIVE |
| 8 | `009070` §2 | `company` ... `May be optional for single-store MVP.` `operating_group` ... `Persistence depth open for MVP.` | **Persistent entity 필요성 OPEN** | ACTIVE |
| 9 | `601702` §2.2 | `\| \`COMPANY\` / \`BUSINESS_UNIT\` scope 구현 여부 \| \`000150\` §4·§6은 **CatchMenu 조직축**으로 정의. 프랜차이즈 본사가 아님 \|` | 2단계 ERD 이후 항목 | |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `companies` / `business_units` tables | **없음** | |
| `franchise_brands` | 존재; `601702` §1.21은 company≠고객 브랜드 | **권위보류** 블록(`003020`/`601501`)은 company=`franchise_brands` 주장 — **설계 근거로 사용 안 함** |
| `store_groups` (`group_type='REGION'`) | 존재 | `003020`: operating_group 후보; **권위보류** 매핑만 |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **확정 가능** (의미·범위) | `601702` §1.21 + `000150` §4·§6: **CatchMenu 내부 조직 context**; Franchise HQ·Merchant 상위 그룹 **아님**. |
| **추정만 가능** (persistent entity 필요성) | `000150` §26·`003020` §6·`009070`: **스키마/persistence OPEN**; MVP에서 필수 persistent entity로 **확정된 ACTIVE 규정 없음**. |

---

## Q7. Person ↔ LegalEntity (Representative / PersonRole) — 0-A ERD 필요 수준

### 문서 근거

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `601702` §1.1 | `이 개념의 명칭은 **\`Person\`** 으로 한다.` (`owners` 테이블 = 자연인) | Person = Core 0-A | Human Business Rule |
| 2 | `601702` §1.5 (다이어그램) | `Store ─ LegalEntity ├─ Representative ─ Person` / `├─ Person Role ──── Person` | **Representative**, **PersonRole** = LE–Person 축 (Store RBAC 별도) | |
| 3 | `601702` §1.5 (표) | `\| Representative \| 그 사업주체를 법적으로 대표하는 사람은 누구인가 \|` ... `\| Person Role \| 그 사업주체에서 이 사람의 조직적 위치는 무엇인가 \|` | 0-A 개념 축에 포함 | |
| 4 | `601702` §1.3 | `지분구조를 모델링한다면 별도 축으로 분리한다. **이번 나선에서 모델링할지는 2단계에서 정한다.**` | **Ownership** ERD 포함 **미확정** | |
| 5 | `601702` §1.18 | `0-A는 \`Person\` 이라는 기준점과 불변조건까지만 책임진다.` `staff`/`person_id`/`user_id` FK → **0-B** | Staff/User/Auth **침범 금지** | |
| 6 | `601702` §2.2 | `\| 지분소유 모델링 여부 \| §1.3에서 분리만 확정. 모델링은 2단계 \|` | Ownership deferred | |
| 7 | `000150` §8 | `Separate axes now to avoid painful retrofit later.` (company/business unit/legal entity) | Person/Representative **미열거** | ACTIVE |
| 8 | `009030` (owners) | `catchmenu_hq.owners` = natural person; `owners` 행을 계정으로 재활용 금지 | Person 후보 = `owners` (명칭 충돌) | ACTIVE 층 A |

### 문서 근거 — 권위보류 (사실·physical mapping 기록만)

| # | 문서 경로 | 인용 | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 9 | `601501` (권위보류) | `\| Owner ↔ LegalEntity (역할) \| N:M \| legal_entity_person_roles \|` | Person–LE N:M (role) | **권위보류** |
| 10 | `601501` (권위보류) | `\| Owner ↔ LegalEntity (대표권) \| N:M \| legal_entity_representatives \|` | Person–LE N:M (representative) | **권위보류** |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `catchmenu_hq.owners` | TABLE (7 columns), **tenant_id 없음** | Person 후보 |
| `legal_entity_person_roles` | N:M (`owner_id`, `legal_entity_id`) | `0168` |
| `legal_entity_representatives` | N:M | `0168` |
| `ownership_percent` + CHECK | 컬럼 존재; `601702` §1.3 **사용 금지** (역할 테이블 혼재) | physical only |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **확정 가능** (개념 분리) | `601702` §1.5: Representative·PersonRole은 **LegalEntity–Person** 축; **Store RBAC·Staff/User(§1.18)와 분리**. |
| **추정만 가능** (0-A ERD 포함 depth) | Representative/PersonRole **관계 테이블 포함 여부** — ACTIVE는 축 존재만; **Ownership 모델링·FranchiseAgreement는 2단계**(§1.3, §2.2). `601501` N:M은 **권위보류**. |

---

## Q8. Franchise OS / FranchiseAgreement — cross-business boundary (내부 entity 금지)

### 문서 근거

| # | 문서 경로 | 인용 (원문 그대로) | 시사하는 cardinality | 비고 |
|---|---|---|---|---|
| 1 | `601702` §1.6 | `가맹계약의 당사자는 **LegalEntity 간**이다. Store와 Person 사이 관계가 아니다.` | FranchiseAgreement: **LE ↔ LE** (CatchMenu 내부 full model 아님) | Human Business Rule |
| 2 | `601702` §1.6 | `**가맹계약과 Store가 1:1이라고 전제하지 않는다.**` ... `\`Store.franchise_contract_id\` ... 1단계에서 확정하지 않는다.` | Store–Agreement **1:1 고정 없음** | |
| 3 | `601702` §1.10 | `Franchise OS ... **[C. CatchMenu World]** ... 고객: 외부 프랜차이즈` — 세 세계 분리 | Franchise OS = **외부 경계** | |
| 4 | `601702` §2.2 | `\| \`FranchiseAgreement\` 의 CatchMenu 측 표현 \| §1.10에 따라 **원천은 Franchise OS**. CatchMenu 측 표현 방식은 2단계 \|` | CatchMenu **내부 entity 미확정** | |
| 5 | `000150` §11 | `Franchise OS business boundary includes:` ... `Franchise OS may use CatchMenu.` `Franchise OS does not own CatchMenu by default.` | Franchise OS **별 사업 경계** | ACTIVE |
| 6 | `000150` §33 | `If CatchMenu and Franchise OS share a store, user, or reporting context, the link must be explicit.` ... `Allow explicit links. **Deny implicit authority.**` | **`cross_business_link`** 참조 패턴 | ACTIVE |
| 7 | `000150` §26 | `cross_business_links` (MVP conceptual entities) | **개념 엔티티**; 구현 OPEN | ACTIVE |
| 8 | `000190` § (Default) | `Franchise OS users cannot view CatchMenu merchant data by default.` | **기본 격리** | ACTIVE |
| 9 | `010640` §11 | `Franchise scope is contract-scoped.` + Franchise HQ access allow/deny 목록 | CatchMenu envelope의 **franchise_hq_id** / contract scope | ACTIVE |
| 10 | `601702` §2.4 | `000150` §11·§33 vs `010640` §4·§11 (`franchise_hq_id`) — **판정 보류** | boundary 근거 **문서 간 충돌** | |

### SQL 실측 (physical evidence — 설계 근거 아님)

| 객체 | 실측 | 비고 |
|---|---|---|
| `franchise_agreement` / `FranchiseAgreement` table | **없음** | `601702` §2.2: 구조 없음 |
| `cross_business_links` | **없음** | `000150` §26 개념만 |
| `franchise_brands` | 존재 | `601702` §1.6: **가맹계약 대체 불가** |

### 판정 가능 여부

| 값 | 조건 |
|---|---|
| **확정 가능** (경계 원칙) | Franchise OS / FranchiseAgreement = **CatchMenu 내부 entity로 만들지 않음**; explicit link / contract-scoped scope (`601702` §1.6·§1.10, `000150` §33, `010640` §11). |
| **추정만 가능** (CatchMenu-side reference 형태) | `cross_business_link`·FranchiseAgreement CatchMenu 표현 — **2단계** (`601702` §2.2). |

---

## 종합

| # | 질문 | 판정 가능 여부 | 근거 문서 수 | 비고 |
|---|---|---|---:|---|
| Q1 | Tenant ↔ MerchantAccount | **추정만 가능** | 8 | 최상위 어휘 충돌; cardinality ACTIVE 규정 없음 |
| Q2 | MerchantAccount ↔ Store | **확정 가능** (Account→Store) | 8 | 1:N (`000170`, `020320` §40, `601702` §1.14) |
| Q3 | Store ↔ LegalEntity | **부분 확정** | 14 | LE 1:N Store 확정(`601702`); Store당 1 LE는 권위보류/`601501`만 명시 |
| Q4 | LE → multiple MerchantAccount | **확정 가능** (허용) | 5 | `601702` §1.14 명시; 금지 규정 없음 |
| Q5 | Mixed LE stores under one Account | **근거 없음** | 6 | 허용/금지 ACTIVE 규정 없음; SQL상 혼재 물리 가능 |
| Q6 | Company / BusinessUnit persistence | **부분 확정** | 9 | 내부 조직 context 확정; persistent entity OPEN |
| Q7 | Person / Representative / PersonRole | **부분 확정** | 10 | 축 분리 확정; ERD depth·Ownership 2단계; Staff=0-B |
| Q8 | Franchise OS / Agreement boundary | **확정 가능** (경계) | 10 | 내부 entity 금지; reference/link 2단계; `franchise_hq_id` 충돌 보류 |

---

## 문서 간 불일치 (조사 중 발견)

| # | 문서 A | 문서 B | 어긋나는 지점 |
|---|---|---|---|
| 1 | `003020` §2: `tenant` 최상위 | `000170` §4: `merchant_account` 최상위 | SaaS 고객 경계 **명칭** (`601701` A-5 #1) |
| 2 | `003020` §2: `company` context axis | `000170` §6: `merchant_company` | 동일 계층 **다른 명칭** (`601701` A-5 #2) |
| 3 | `000150` §2: `business_unit` | `003020` §2: `operating_group` | 유사 역할 **다른 용어** (`601701` A-5 #4) |
| 4 | `601702` §1.21: `company`/`business_unit` = CatchMenu 내부 | `020320` §10–§11: `company`/`business_unit` scope types (의미 미정의) | Scope type vs 조직축 **TERM_COLLISION** (`601702` §1.20) |
| 5 | `000150` §11·§33: Franchise OS 소관 | `010640` §4·§11: `franchise_hq_id` in CatchMenu envelope | Franchise boundary **소재** (`601702` §2.4, 판정 보류) |
| 6 | `010640` §4 Scope Dimensions | `010640` §5 Mandatory Envelope Fields | `franchise_hq_id` **§4에만** 존재 (`601702` §2.4) |
| 7 | `003020` §6 Open Decisions (OPEN) | `003020` 역전파 블록: LegalEntity MVP 필수 | 동일 파일 **이중 서술** (역전파 ⛔) |
| 8 | `601501` (권위보류): Store당 1 `legal_entity_id` | `003020` §2 ACTIVE: store "may link" to legal context | Store–LE cardinality **강도** 차이 |

---

## Core 5축 — 문서가 정의하는 필수 속성 (개념·경계)

> SQL 컬럼은 **physical evidence**로만 별도 표기. 아래는 **ACTIVE + `601702` Human Rule** 위주.

### Person

| 속성/경계 | 출처 |
|---|---|
| 자연인 식별 주체; 명칭 `Person` (`owners` 명칭 부적합) | `601702` §1.1 |
| Store/Tenant/고용/로그인/staff row에 **종속되지 않음** | `601702` §1.17 |
| Person ↔ User **1:1 전제하지 않음** | `601702` §1.17 |
| 무수식 `Owner` 금지; 경제·법적 소유권에만 `Owner` 예약 | `601702` §1.2 |

### Tenant

| 속성/경계 | 출처 |
|---|---|
| SaaS customer boundary and contract scope | `003020` §2, `009030`, `009070` |
| Root boundary for stores and configuration | `003020` §2 |
| Not a single store or legal entity by default | `003020` §2 |
| `tenant_id` mandatory on tenant-owned objects | `010004` §4 |
| (SQL) `tenant_code`, `tenant_name`, `tenant_type`, `plan_tier`, … | `0002` — physical only |

### LegalEntity

| 속성/경계 | 출처 |
|---|---|
| Legal/tax/settlement/contract identity | `000150` §7, `003020` §2 |
| Distinct from company and business unit | `000150` §7–§8 |
| Required for financial finality / settlement context | `010640` §9 |
| May span brands; do not duplicate LE per brand | `601702` §1.13 |
| Global concept; **no direct tenant FK** (via stores) | `009030` 주의, `003020` 역전파 층 A |
| (SQL) `entity_type`, BRN/CRN, `status`, … | `0168` — physical only |

### MerchantAccount

| 속성/경계 | 출처 |
|---|---|
| Top-level SaaS **customer relationship** | `000170` §4 |
| CatchMenu SaaS **contract·management unit**; independent from LE/Brand/User | `601702` §1.14 |
| May include **multiple stores** (and multi-brand) | `000170` §7, `601702` §1.14 |
| Recommended: `merchant_account_id`, name, type, `service_status`, `trial_status`, `primary_owner_user_id`, contacts | `000170` §4 |
| Count **not globally fixed** | `601702` §1.14 |
| (SQL) **`merchant_accounts` table: CONCEPT PRESENT / PHYSICAL IMPLEMENTATION MISSING** | `601701` §4.3 |

### Store

| 속성/경계 | 출처 |
|---|---|
| Operational unit (handoff runtime) | `003020` §2, `000170` §7 |
| Belongs to tenant | `003020` §2, `009070` |
| Legal operator via **LegalEntity relationship** | `601702` §1.4–§1.5 |
| Runtime context vs MerchantAccount customer context | `000170` §7 Core rule |
| Recommended: `merchant_store_id`, `merchant_account_id`, name, address, `store_status`, `service_status`, timezone, … | `000170` §7 |
| (SQL) `tenant_id` NOT NULL; `legal_entity_id` nullable FK | `0002`, `0168` — physical only |

---

## Candidate 축 (Company / BusinessUnit) — 요약

| 축 | 문서 정의 | Persistent entity |
|---|---|---|
| **Company** | CatchMenu **platform operator** boundary (`000150` §4); NOT franchise HQ / merchant parent (`601702` §1.21) | OPEN (`000150` §26, `003020` §6, `009070`) |
| **BusinessUnit** | **Internal operating responsibility** inside CatchMenu (`000150` §6); not permission | OPEN (동상) |
| **operating_group** (`003020`) | Parallel context axis (region/franchise grouping); ≠ legal settlement default | Optional / persistence OPEN |

---

## External Boundary (조사 범위 — 내부 구조 미조사)

| 항목 | 문서 근거 요약 |
|---|---|
| **Franchise OS** | Separate business boundary (`000150` §11); default data isolation (`000190`); HR/payroll not in CatchMenu |
| **FranchiseAgreement** | Parties = LegalEntity ↔ LegalEntity (`601702` §1.6); not Store–Person; source of truth Franchise OS; CatchMenu expression **2단계** |
| **Franchise Store Identity** | `cross_business_link` / `AFFILIATED_STORE` explicit only (`000150` §12·§33); same physical store may differ system IDs |
| **Staff / User / Session / Role / Permission** | **0-B/0-C 소관** (`601702` §1.16–§1.18); 0-A ERD **침범하지 않음** |

---

## 조사 방법 메모

- **스캔 범위**: `docs/**/*.md` 1,653건 (제외: quarantine, migration_history, implementation_evidence, `*_KO.md`, duplicate_review)
- **권위보류**: `600000/**` (`600020` §1.3); **`601700_operational_authority_foundation_v2/**` 제외**
- **SQL**: `sql/migrations/0002_create_hq_tenant_store.sql`, `0168_create_operational_authority_foundation.sql` 및 `601701` B-1 실측 인용 — **physical evidence only**
