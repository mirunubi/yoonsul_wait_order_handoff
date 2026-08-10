# 601501 ERD — 0-A Tenant / Company / HQ / Store

- **나선**: 0단계(운영 권위 기반) · **하위 나선 0-A**
- **단계**: §47.1 6단계 나선 중 **2단계 (ERD)**
- **작성**: Claude Code
- **상태**: **v5 (Stage 11B 블라인드 감사 BLOCK 4개 조건 반영)**
- **선행 근거**: §48 증거수집, 1단계 Human 선언, 3단계 인접도메인 대조 1차(Opus 5) 및 **2차**, 외부 검토(ChatGPT+Gemini) 합의, Architecture Verification

> **가드레일(§47.2, §47.6)**: `.sql` 생성/수정 없음. `franchise_brands`(0085) 변경 없음.

## 개정 이력

| 버전 | 변경 | 근거 |
|---|---|---|
| v1 | 최초 ERD 초안 (`companies`/`owner_companies`) | 1단계 선언 + §48 증거수집 |
| v2 | B-1(tenant_status 2컬럼 분리), B-2(RLS deny-by-default), A-1~A-7 | 3단계 1차 대조(Opus 5) |
| v3 | **LegalEntity 중심 모델** 전면 재작성, AV 7개 반영(v2의 `TRIAL_30` 오진·`service_role` 설명 정정 포함) | 외부 검토 합의 + AV |
| **v4** | **B-1 접근제어 서술 전면 재작성**(실제 차단 계층은 RLS가 아니라 GRANT+PostgREST), **B-2 `legal_entity_representatives` 별도 테이블 분리**, A-1~A-9 반영 | **3단계 2차 검증** |
| **v5** | **Stage 11B BLOCK 4개 조건 반영** — ①② SECURITY DEFINER 보안경계(전용 owner role·search_path·PUBLIC EXECUTE·tenant 검증, §2.7.6), ③ **SOLE 대표 유일성 DB 강제**(§2.5.4), ④ **4개 개념 분리 선언**(§0.6). 추가로 §3에 서비스가능 판정규칙·상태 전이 규칙 명문화 | **Stage 11B (ChatGPT 완전독립 블라인드 감사)** — `601510` |

**v5가 대응하는 BLOCK 조건 4가지** (`601510` 최종판정):

| 조건 | 요구 | v5 반영 위치 | 이행 시점 |
|---|---|---|---|
| ① | SECURITY DEFINER owner를 전용 NOLOGIN 역할로 고정 + CI/migration drift 검증 | **§2.7.6**, `601503` §2.9/§9 | **0169**(role 신설) + 0-C(함수 생성 시) |
| ② | search_path / PUBLIC EXECUTE / tenant 경계 검증 | **§2.7.6**, `601503` §9 | **0-C 필수 규칙으로 명문화**(0-A에는 함수 없음) |
| ③ | SOLE 대표 불변조건을 partial unique index로 DB enforcement | **§2.5.4**, `601503` §2.9 | **0169** |
| ④ | ownership / representation / person role / business registration identity가 서로 다른 개념임을 명확히 선언 | **§0.6**, §2.1, §2.3 | **본 문서 v5** |

**v3 → v4에서 정정된 사실 2건**:
- v3 §2.6의 "0021 패턴과 동일한 deny-by-default" 서술은 **차단 메커니즘을 잘못 지목**했다 → §2.7에서 전면 재작성.
- v3 §2.4의 대표권 표현(`is_legal_representative` + `representation_mode` 2컬럼 + 정합성 CHECK)은
  **"하나의 사실을 두 컬럼에 저장"하는 구조**였다 → §2.5에서 별도 테이블로 분리.

---

## §0. 확정 업무규칙 및 축 정의

### §0.1 최종 확정 구조

```text
Owner(사람) ↔(N:M)↔ LegalEntity(법적 사업주체, 사업자번호 보유) ↔(1:N)↔ Store
```

**핵심 원칙 2가지 (재논의 금지)**:

1. **법인(`CORPORATION`)은 별도 테이블이 아니라 `legal_entities.entity_type`의 한 값이다.**
   개인사업자·법인·조합·비영리는 전부 같은 테이블의 서로 다른 `entity_type`이며, 법적 사업주체를 담는 테이블은 **`legal_entities` 하나뿐**이다. (A-2)
2. **Store는 항상 정확히 1개의 LegalEntity에만 연결된다.** `company_id`/`owner_id`로 갈라지는 **두 갈래 FK 분기가 없다** — `legal_entity_id` 하나로 통일한다.

원칙 2의 이유: 두 갈래 FK를 두면 "이 매장의 법적 책임 주체가 누구인가"에 대한 답이 두 곳에 생기고,
둘이 어긋나는 순간 어느 쪽이 진실인지 판정할 방법이 없다. 이는 §3의 `tenant_status` 상호 파괴와
**정확히 같은 종류의 결함**이다 — 하나의 사실을 두 곳에 저장하면 반드시 갈라진다.
v4의 §2.5(대표권 테이블 분리)도 **같은 원칙을 대표권에 적용한 결과**다.

### §0.2 1단계 Human 선언과의 대응

| # | 1단계 선언 | v4 반영 |
|---|---|---|
| 1 | Tenant 1개, 기존 유지 | `tenants` 유지 + 상태컬럼 2개 추가(§3) |
| 2 | Owner(사람) 전역, 신규 | `owners` 신규 |
| 3 | 사업주체 전역·신규, Tenant 직접연결 금지 | **`legal_entities`** — 전역, `stores.legal_entity_id`로만 연결 |
| 4 | Owner↔사업주체 N:M | **`legal_entity_person_roles`**(역할·지분) + **`legal_entity_representatives`**(대표권) |
| 5 | 운영본부는 `store_groups` 재사용 | `group_type='REGION'`만(§0.5) |
| 6 | `stores`에 운영주체 FK 1개 | **`stores.legal_entity_id`** |
| 7 | HQ는 `catchmenu_hq` 스키마 자체 | 변경 없음 |

### §0.3 상위 개념문서와의 정합 — 003020의 실현

이번 나선은 **`003020`이 선언해 둔 company/legal_entity 분리 원칙을 LegalEntity 중심 모델로 실현한 것**이다.

`003020` §2/§3, `009030` L18–19, `009070` L19–20, `007040` L21/L40이 공통 규정하는 바:
`legal_entity` = 계약·세무·정산 권한 맥락 / `company` = 브랜드·운영 그룹핑 맥락, 두 축은 **parallel context axes**,
명시 금지 = "do not assume one company equals one legal_entity"(`003020` §3), "Do not treat company as legal entity automatically"(`007040` L40).

| 003020의 축 | v4 구현체 | 비고 |
|---|---|---|
| `legal_entity` (계약·세무·정산 권한) | **`legal_entities` (신규, 본 나선)** | 사업자번호를 보유하는 유일한 테이블 |
| `company` (브랜드 그룹핑) | 기존 `franchise_brands` | **`store_groups`는 여기 해당하지 않음** (A-3) |
| `operating_group` (지역·운영 그룹핑) | 기존 `store_groups` | `group_type='REGION'`만 사용 |
| `tenant` | 기존 `tenants` | SaaS 경계 |
| `store` | 기존 `stores` | `legal_entity_id`로 법적 주체와 연결 |

> **A-3 정정**: v3는 company 축의 구현체로 `franchise_brands`와 `store_groups`를 **함께** 적었으나,
> `003020`/`009070`은 `company`와 `operating_group`을 **서로 다른 축**으로 규정한다.
> `store_groups`는 `operating_group` 축의 구현체이지 company 축이 아니다 → 매핑에서 분리했다.

> **⚠️ 어휘 충돌 경고 (삭제 금지)**: `entity_type='CORPORATION'`은 **법인격의 종류(legal form)** 이며,
> `003020`이 말하는 **"company 축(브랜드 그룹핑)"과 전혀 다른 개념**이다. §0.1 원칙 1은 법인격 어휘 안에서만
> 성립하며, `003020`의 company 축을 legal_entity로 흡수한다는 뜻이 **아니다**.
> 이 프로젝트가 반복적으로 당해온 어휘 혼동의 정확한 재발 지점이다.

### §0.4 사업자 축 vs 브랜드 축

| **사업자 축 — `legal_entities` (0-A 소관)** | **브랜드 축 — `franchise_brands` (브랜드 나선 소관)** |
|---|---|
| 법인격 종류 (`entity_type`) | 상표·브랜드명 (`brand_name`/`brand_code`) |
| 사업자등록번호 (`business_registration_number`) | 로열티 정책 (`royalty_rate_pct`) |
| 법인등기번호 (`corporate_registration_number`) | 브랜드 가이드 (`brand_guidelines_url` 등) |
| 대표권 (`legal_entity_representatives`) | 멤버십·메뉴 공유 (`shared_membership` 등) |
| **누가 법적 책임을 지는가** | **어떤 간판을 달고 무엇을 공유하는가** |

**기존 중첩 기록(해소하지 않음)**: `franchise_brands`의 `hq_contact_*`, `contract_start_date`/`contract_end_date`는
0-A 이전부터 존재하던 사업자축 중첩이며 **해소는 브랜드 나선 소관**이다(§47.2).

### §0.5 store_groups 사용 범위

- 0-A는 **`group_type='REGION'`만** 사용. `DISTRICT`/`BRAND`/`FRANCHISE`/`CUSTOM` 미사용, 계층(`parent_group_id`) 미사용.
- `DISTRICT` 도입 판정조건(이월): "실제 가맹계약 체결로 하나의 REGION 아래 **독립 관리 권역이 2개 이상** 생기고, 권역별 별도 관리자·성과집계가 필요해지는 시점".

### §0.6 ⚠️ 4개 개념은 서로 다르다 — 혼동 금지 (v5 신설, BLOCK 조건 ④)

Stage 11B 감사가 지적한 핵심: **"대표자(Representative)와 소유자(Owner)는 같은 개념이 아니다 —
대표이사가 지분 0%일 수 있고 60% 주주가 대표가 아닐 수도 있다."**

Person ↔ LegalEntity 사이에는 **서로 독립적인 4개 개념**이 존재하며, 하나를 다른 하나로 추론해서는 안 된다.

| # | 개념 | 뜻 | v5에서의 담당 | 상태 |
|---|---|---|---|---|
| 1 | **소유권** (economic ownership, 지분) | 누가 얼마를 **소유**하는가 | **없음 — 미모델링** | **Open Item (q)** |
| 2 | **대표권** (legal representation authority) | 누가 법적으로 **대표**하는가 | `legal_entity_representatives` | 구현됨 |
| 3 | **역할** (employment / organizational role) | 조직 내 **직위·역할** | `legal_entity_person_roles` | 구현됨 |
| 4 | **사업자등록 식별자** (business registration identity) | 등록된 **식별번호** | `legal_entities.business_registration_number` | 구현됨(§2.1 경계 참조) |

**금지되는 추론 (전부 틀림)**:

- ~~"대표권이 있으니 지분이 있다"~~ — 지분 0%인 전문경영인 대표가 정상
- ~~"지분이 있으니 대표다"~~ — 60% 주주가 대표가 아닐 수 있음
- ~~"OWNER 역할이니 소유자다"~~ — `role_type='OWNER'`는 **3번(역할)** 이지 **1번(소유권)이 아니다**
- ~~"사업자번호가 있으니 법인격이 하나다"~~ — §2.1 참조

> **소유권(1번)은 이번 나선에서 모델링하지 않는다.** 필요해지면 별도 테이블
> (예: `legal_entity_ownership_stakes` — 지분율·의결권·취득일 등)이 필요하며, 이는 Open Item (q)다.
> **`legal_entity_person_roles.ownership_percent` 컬럼을 소유권 모델로 사용하지 말 것** — §2.3 경고 참조.

---

## §1. Mermaid ERD

```mermaid
erDiagram
    OWNERS ||--o{ LEGAL_ENTITY_PERSON_ROLES : "역할 보유(N:M)"
    LEGAL_ENTITIES ||--o{ LEGAL_ENTITY_PERSON_ROLES : "역할 부여(N:M)"
    OWNERS ||--o{ LEGAL_ENTITY_REPRESENTATIVES : "대표권 보유(N:M)"
    LEGAL_ENTITIES ||--o{ LEGAL_ENTITY_REPRESENTATIVES : "대표 지정(N:M)"
    LEGAL_ENTITIES ||--o{ STORES : "운영(1:N, NEW legal_entity_id)"
    TENANTS ||--o{ STORES : "소속(1:N)"
    TENANTS ||--o{ STORE_GROUPS : "보유(1:N)"
    STORE_GROUPS ||--o{ STORE_GROUP_MEMBERS : "구성(1:N)"
    STORES ||--o{ STORE_GROUP_MEMBERS : "가입(1:N)"
    STORE_GROUPS ||--o{ STORE_GROUPS : "계층(parent_group_id, 0-A 미사용)"

    OWNERS {
        uuid id PK "NEW"
        text owner_name "NOT NULL"
        text contact_phone_hash "nullable, UNIQUE 없음(§2.4)"
        text contact_email "nullable"
        boolean is_active "NOT NULL default true"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }

    LEGAL_ENTITIES {
        uuid id PK "NEW"
        text entity_type "NOT NULL CHECK SOLE_PROPRIETOR/CORPORATION/PARTNERSHIP/NON_PROFIT"
        text legal_name "NOT NULL"
        text business_registration_number "nullable, 표기 그대로"
        text brn_normalized "GENERATED STORED 숫자만, UK(부분 WHERE NOT NULL)"
        text corporate_registration_number "nullable, 표기 그대로"
        text crn_normalized "GENERATED STORED 숫자만, UK(부분 WHERE NOT NULL)"
        text tax_id "nullable, UNIQUE 없음"
        text status "NOT NULL default ACTIVE CHECK ACTIVE/SUSPENDED/CLOSED"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }

    LEGAL_ENTITY_PERSON_ROLES {
        uuid id PK "NEW"
        uuid legal_entity_id FK "NOT NULL -> legal_entities.id, UK(복합부분)"
        uuid owner_id FK "NOT NULL -> owners.id, UK(복합부분)"
        text role_type "NOT NULL CHECK OWNER/REPRESENTATIVE/DIRECTOR/EXECUTIVE/INVESTOR, UK(복합부분)"
        numeric ownership_percent "nullable CHECK 0..100"
        date effective_from "NOT NULL default current_date"
        date effective_to "nullable CHECK >= effective_from"
        boolean is_active "NOT NULL default true, UK 조건컬럼"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }

    LEGAL_ENTITY_REPRESENTATIVES {
        uuid id PK "NEW - 법적 대표권의 유일한 진실원천"
        uuid legal_entity_id FK "NOT NULL -> legal_entities.id, UK(복합부분)"
        uuid owner_id FK "NOT NULL -> owners.id, UK(복합부분)"
        text representation_mode "NOT NULL CHECK SOLE/JOINT/INDIVIDUAL, SOLE는 법인당 1명(UK 0169)"
        date effective_from "NOT NULL default current_date"
        date effective_to "nullable CHECK >= effective_from"
        boolean is_active "NOT NULL default true, UK 조건컬럼"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }

    TENANTS {
        uuid id PK
        text tenant_code "NOT NULL UK"
        text tenant_name "NOT NULL"
        text tenant_type "NOT NULL CHECK BRAND/FRANCHISE/INDEPENDENT/TEST"
        text plan_tier "NOT NULL CHECK LITE/STANDARD/PRO/ENTERPRISE"
        text tenant_status "NEW NOT NULL default TRIAL CHECK ACTIVE/TRIAL/SUSPENDED/CANCELLED/TERMINATED"
        text isolation_state "NEW NOT NULL default NONE CHECK NONE/ISOLATED"
        boolean is_active "NOT NULL default true"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }

    STORES {
        uuid id PK
        uuid tenant_id FK "NOT NULL -> tenants.id, UK(복합)"
        uuid legal_entity_id FK "NEW nullable -> legal_entities.id (5단계 말미 NOT NULL 승격 검토)"
        text store_code "NOT NULL, UK(복합: tenant_id+store_code)"
        text store_name "NOT NULL"
        text store_type "NOT NULL CHECK DINE_IN/TAKEOUT/HYBRID/DELIVERY_ONLY"
        text store_status "NOT NULL CHECK PREPARING/ACTIVE/SUSPENDED/CLOSED"
        text address "nullable"
        text phone "nullable"
        text timezone "NOT NULL default Asia/Seoul"
        jsonb business_hours "nullable CHECK object"
        boolean is_active "NOT NULL default true"
        date opened_on "nullable"
        date closed_on "nullable"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }

    STORE_GROUPS {
        uuid id PK
        uuid tenant_id FK "NOT NULL -> tenants.id, UK(복합)"
        text group_code "NOT NULL, UK(복합)"
        text group_name "NOT NULL"
        text group_type "NOT NULL CHECK REGION/BRAND/FRANCHISE/DISTRICT/CUSTOM (0-A는 REGION만)"
        uuid parent_group_id FK "nullable, 0-A 미사용"
        int depth "NOT NULL default 0"
        uuid group_manager_id "nullable"
        text group_manager_name "nullable"
        boolean shared_menu_enabled "NOT NULL default false"
        boolean shared_inventory_enabled "NOT NULL default false"
        boolean cross_store_transfer_enabled "NOT NULL default false"
        text performance_metric "NOT NULL CHECK REVENUE/ORDER_COUNT/CUSTOMER_COUNT/PROFIT"
        boolean is_active "NOT NULL default true"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }

    STORE_GROUP_MEMBERS {
        uuid id PK
        uuid tenant_id FK "NOT NULL -> tenants.id"
        uuid group_id FK "NOT NULL -> store_groups.id, UK(복합)"
        uuid store_id FK "NOT NULL -> stores.id, UK(복합)"
        text member_role "NOT NULL CHECK LEADER/MEMBER/HQ"
        timestamptz joined_at "NOT NULL default now()"
        uuid joined_by "nullable"
        boolean is_active "NOT NULL default true"
        timestamptz created_at "NOT NULL default now()"
        timestamptz updated_at "NOT NULL default now()"
    }
```

### §1.1 관계 요약

| 관계 | 카디널리티 | 연결 | 비고 |
|---|---|---|---|
| Owner ↔ LegalEntity (역할) | N:M | `legal_entity_person_roles` | 역할 종류·지분·유효기간 |
| Owner ↔ LegalEntity (대표권) | N:M | **`legal_entity_representatives`** | **법적 대표권의 유일한 진실원천** |
| LegalEntity → Store | **1:N** | `stores.legal_entity_id` | Store당 정확히 1개 |
| Tenant → Store | 1:N | `stores.tenant_id` | 기존 |
| Tenant → StoreGroup | 1:N | `store_groups.tenant_id` | 기존, REGION만 |
| StoreGroup ↔ Store | N:M | `store_group_members` | 기존 |
| **LegalEntity ↔ Tenant** | **직접 없음** | (stores 경유 간접) | 같은 사업주체가 서로 다른 Tenant 매장 운영 가능 |

---

## §2. 스키마 계약표

### §2.1 `legal_entities` (신규)

| 컬럼 | 타입 | NOT NULL | UNIQUE | CHECK / 비고 |
|---|---|---|---|---|
| id | uuid | ✓ (PK) | PK | `default gen_random_uuid()` |
| entity_type | text | ✓ | — | CHECK `('SOLE_PROPRIETOR','CORPORATION','PARTNERSHIP','NON_PROFIT')` |
| legal_name | text | ✓ | — | 법적 상호(브랜드명 아님 — §0.4) |
| business_registration_number | text | ✗ | — | 사업자등록번호. **표기 그대로 저장**(하이픈 보존) |
| `brn_normalized` | text | ✗ | **부분 UK** `WHERE NOT NULL` | **생성컬럼** — §2.2 |
| corporate_registration_number | text | ✗ | — | 법인등기번호. **표기 그대로 저장** |
| `crn_normalized` | text | ✗ | **부분 UK** `WHERE NOT NULL` | **생성컬럼 (A-6, v4 신규)** — §2.2 |
| tax_id | text | ✗ | **없음** | 국내에선 사업자번호와 동일값인 경우가 많아 유일성 미부여 |
| status | text | ✓ | — | `default 'ACTIVE'` CHECK `('ACTIVE','SUSPENDED','CLOSED')` — 사업자 자체 상태(휴업/폐업). `tenants.tenant_status`·`stores.store_status`와 **별개 축** |
| created_at / updated_at | timestamptz | ✓ | — | `default now()` + `set_updated_at` 트리거 |

**CHECK — 개인사업자의 법인등기번호 금지**: `entity_type <> 'SOLE_PROPRIETOR' or corporate_registration_number is null`.

#### §2.1.1 ⚠️ 사업자등록번호의 존재론적 경계 (v5 신설, BLOCK 조건 ④)

Stage 11B 원문 인용:

> *"사업자등록번호는 등록의 식별자이지 법적정체성의 근본 존재론이 아니다."*
> *"개인사업자는 사업체와 자연인이 완전히 별개 법인격이 아니고, 하나의 법인이 여러 사업장/등록단위를 가질 수 있다.
> Legal Entity와 Business/Tax Registration을 1:1로 가정하지 않는 게 안전."*

**현재 설계의 명시적 한계**:

- v5는 `legal_entities` **1행 : 사업자등록번호 최대 1개**를 전제한다 — **MVP 단순화이지 도메인 진실이 아니다.**
- 실제로는 **한 법인이 복수 사업장(종된 사업장)·복수 등록단위**를 가질 수 있다.
- **개인사업자**의 경우 사업체와 자연인이 법적으로 완전히 분리되지 않는다 — `legal_entities` 행과
  `owners` 행이 사실상 같은 실체를 가리키면서도 **별개 행으로 표현**된다는 점을 인지할 것.

**따라서 금지되는 사용법**: `business_registration_number`를 **법적 주체의 동일성 판단 기준(identity key)으로
사용하지 말 것.** 그것은 등록 사실의 식별자일 뿐이며, 동일성의 기준은 `legal_entities.id`다.
1:N(법인 : 등록단위) 확장이 필요해지면 별도 테이블 분리가 필요하다 — Open Item (r).

> **A-7 판단 명시**: **`CORPORATION`에 `corporate_registration_number`를 요구하지 않는다**(NOT NULL 강제 없음).
> 법인 설립 등기 전이거나 번호를 아직 확보하지 못한 시점에도 `legal_entities` 행을 만들 수 있어야 하며,
> 이는 `business_registration_number`를 nullable로 둔 것과 **같은 이유·같은 원칙**이다
> (제약이 업무 절차를 앞질러 막지 않도록 한다). 역방향 금지(개인사업자는 CRN 불가)만 강제한다.

### §2.2 등록번호 정규화 — BRN·CRN 동일 방식 (A-6)

**문제**: `123-45-67890` / `1234567890` / `123 45 67890`은 같은 번호지만 문자열로는 다르다.
raw 컬럼에 UNIQUE를 걸면 **표기만 다른 중복 등록이 통과**한다. 법인등기번호도 동일 문제를 갖는다.

**채택 — 생성컬럼(stored generated column) + 그 컬럼에 부분 UNIQUE, 두 번호에 동일 적용**:

```text
brn_normalized text generated always as (
  nullif(regexp_replace(coalesce(business_registration_number,''), '[^0-9]', '', 'g'), '')
) stored

crn_normalized text generated always as (
  nullif(regexp_replace(coalesce(corporate_registration_number,''), '[^0-9]', '', 'g'), '')
) stored
```

**`nullif(..., '')`이 설계의 핵심이다.** 없으면 원본이 NULL인 행들이 전부 `''`로 정규화되어 **서로 충돌**한다
→ 번호 미확정 사업주체를 2건 이상 만들 수 없게 된다. v2에서 "placeholder가 UNIQUE 슬롯을 점유한다"며 배제했던
함정이, 정규화를 도입하며 **다른 얼굴로 재등장**하는 지점이다.

**v3 → v4 변경(A-6)**: v3는 CRN에만 정규화를 적용하지 않고 raw 컬럼에 부분 UNIQUE를 걸었다.
이는 "같은 번호의 표기 변형이 중복 등록된다"는 **BRN에서 이미 해결한 문제를 CRN에 그대로 남겨두는 것**이므로
동일 방식으로 통일했다. raw 컬럼은 두 번호 모두 입력 표기 그대로 보존한다(대외 문서 표기 일치 목적).

**표현식 인덱스 대신 생성컬럼인 이유**: (a) RPC가 정규화값으로 직접 조회 가능, (b) 정규화 규칙이 인덱스 정의에
숨지 않고 **스키마에 드러남**.

### §2.3 `legal_entity_person_roles` (신규 — 대표권 컬럼 제거됨)

| 컬럼 | 타입 | NOT NULL | UNIQUE | CHECK / 비고 |
|---|---|---|---|---|
| id | uuid | ✓ (PK) | PK | |
| legal_entity_id | uuid | ✓ | 복합부분 UK | FK → `legal_entities.id` |
| owner_id | uuid | ✓ | 복합부분 UK | FK → `owners.id` |
| role_type | text | ✓ | 복합부분 UK | CHECK `('OWNER','REPRESENTATIVE','DIRECTOR','EXECUTIVE','INVESTOR')` |
| ownership_percent | numeric(5,2) | ✗ | — | CHECK `null or (0 <= x <= 100)` |
| effective_from | date | ✓ | — | `default current_date` |
| effective_to | date | ✗ | — | CHECK `null or effective_to >= effective_from` |
| is_active | boolean | ✓ | UK 조건컬럼 | `default true` |

**복합 부분 UNIQUE**: `UNIQUE (legal_entity_id, owner_id, role_type) WHERE is_active = true`
— 같은 사람이 같은 법인에서 OWNER와 DIRECTOR를 동시에 가질 수 있고(정상), 역할 종료 후 재부여가 가능하다
(전체 UNIQUE면 종료 이력 행이 슬롯을 영구 점유해 재부여 불가).

> **v3에서 제거된 컬럼**: `is_legal_representative`, `representation_mode`, 그리고 이 둘을 묶던
> `chk_lepr_representative_consistency`. 전부 §2.5의 별도 테이블로 이관됐다.

#### §2.3.1 ⚠️ `ownership_percent`는 개념 혼재다 — 사용 금지 (v5 신설)

§0.6의 4개 개념 분리를 적용하면, **이 테이블(3번 역할)에 `ownership_percent`(1번 소유권)가 들어있는 것은
개념 혼재**다. Stage 11B가 "현재 소유권(지분) 자체를 모델링하는 구조가 없다"고 지적한 것과 정면으로 맞물린다 —
구조가 없는 게 아니라 **엉뚱한 테이블에 컬럼 하나로 얹혀 있었다.**

| 항목 | 판단 |
|---|---|
| 컬럼 물리적 존재 | 0168에 이미 적용됨(`numeric(5,2)`, CHECK 0–100) |
| **v5 사용 정책** | **사용하지 않는다.** 이 컬럼에 값을 쓰지 말 것 (현재 전 행 0건이므로 오염 없음) |
| 소유권이 실제로 필요해지면 | 별도 테이블 `legal_entity_ownership_stakes` 신설 — Open Item (q) |
| 컬럼 제거 여부 | **0-A에서 제거하지 않는다**(가법 원칙, `601505` §4.1). 제거·이관은 소유권 모델링 워크패킷 소관 |

**왜 지금 제거하지 않는가**: 제거는 가법적 변경이 아니고, `601505` 계약의 Allowed 범위 밖이다.
값이 0건인 상태에서 "쓰지 않는다"는 정책만으로 오염을 막을 수 있으며,
실제 제거는 소유권 테이블 설계와 함께 판단하는 것이 옳다.

### §2.4 `owners` (신규)

| 컬럼 | 타입 | NOT NULL | UNIQUE | 비고 |
|---|---|---|---|---|
| id | uuid | ✓ (PK) | PK | |
| owner_name | text | ✓ | — | |
| contact_phone_hash | text | ✗ | **없음** | PII 평문 금지 → 해시 |
| contact_email | text | ✗ | 없음 | |
| is_active | boolean | ✓ | — | `default true` |
| created_at / updated_at | timestamptz | ✓ | — | 트리거 |

**유니크를 걸지 않는 판정(계승)**: 동명이인·번호 공유(가족/법인 대표번호)·번호 변경이 전부 정상 시나리오다.
전역 유니크는 이 정상 케이스를 DB 레벨에서 거부하고 **존재탐지 오라클**을 만든다 → 중복 방지는 0-C 절차 소관.

#### §2.4.1 ⚠️ "Owner"가 뜻하는 것 — 명시 선언 (v5 신설, 11B 추가발견 4)

Stage 11B 지적: *"SaaS에서 흔한 'tenant admin / account owner'와 법적 'beneficial owner / shareholder /
proprietor'는 다른 의미. 어느 쪽인지 명확히 해야 향후 권한 시스템에서 혼란을 방지한다."*

**선언**: 본 설계의 `catchmenu_hq.owners`는 **"법적 사업주체와 관계를 맺는 자연인(natural person)"** 을 뜻한다.

| `owners`가 뜻하는 것 | `owners`가 뜻하지 **않는** 것 |
|---|---|
| 실존하는 **사람**(자연인) | SaaS **계정 소유자** / tenant 관리자 |
| `legal_entities`와 역할·대표권으로 연결되는 주체 | **로그인 주체**(그것은 0-B의 staff identity 소관) |
| — | **지분 보유자**(그것은 §0.6의 1번 — 미모델링) |

**따라서 `owners`는 인증·권한 주체가 아니다.** 로그인·세션·권한은 **0-B(staff identity) / 0-C(authorization)** 가
별도 개념으로 다루며, `owners` 행을 계정으로 재활용해서는 안 된다.

> 테이블명이 `owners`인 것은 1단계 Human 선언의 어휘를 따른 것이나, §0.6에 비추면
> **`persons`가 더 정확한 이름**이었다. 개명은 §33(permanent from creation)과 가법 원칙에 걸리므로 하지 않고,
> **본 선언으로 의미를 고정**한다. 향후 권한 시스템 설계 시 이 문단을 근거로 삼을 것 — Open Item (x).

### §2.5 `legal_entity_representatives` (신규 — B-2, v4의 핵심 변경)

**법적 대표권의 유일한 진실원천.**

| 컬럼 | 타입 | NOT NULL | UNIQUE | CHECK / 비고 |
|---|---|---|---|---|
| id | uuid | ✓ (PK) | PK | |
| legal_entity_id | uuid | ✓ | 복합부분 UK | FK → `legal_entities.id` |
| owner_id | uuid | ✓ | 복합부분 UK | FK → `owners.id` |
| representation_mode | text | ✓ | — | CHECK `('SOLE','JOINT','INDIVIDUAL')` — **`'NONE'` 값이 사라졌다** |
| effective_from | date | ✓ | — | `default current_date` |
| effective_to | date | ✗ | — | CHECK `null or effective_to >= effective_from` |
| is_active | boolean | ✓ | UK 조건컬럼 | `default true` |

**복합 부분 UNIQUE**: `UNIQUE (legal_entity_id, owner_id) WHERE is_active = true`

#### §2.5.1 왜 별도 테이블인가 — v3 설계의 결함

v3는 대표권을 `legal_entity_person_roles`의 **두 컬럼**(`is_legal_representative` boolean + `representation_mode`)으로
표현하고, 둘의 모순을 `chk_lepr_representative_consistency` CHECK로 막았다. 이 구조의 문제:

- **하나의 사실("이 사람은 이 법인의 법적 대표다")이 두 컬럼에 분산**되어 있었다.
  CHECK가 필요했다는 것 자체가 구조가 잘못됐다는 신호다 — 제약으로 봉합해야 하는 모순은 애초에 표현 가능해선 안 된다.
- `representation_mode='NONE'`이라는 **"대표가 아님"을 뜻하는 값**이 대표방식 도메인에 섞여 있었다.
  대표방식이라는 개념에 "대표 아님"은 속하지 않는다.
- 대표권에는 고유한 유효기간(`effective_from`/`to`)이 있는데, 역할의 유효기간과 **같은 행을 공유**해야 했다.
  대표권만 종료하고 이사 역할은 유지하는 정상 시나리오를 표현할 수 없었다.

**v4 판정**: "법적 대표인가"는 **`legal_entity_representatives`에 활성 행이 존재하는지로만** 판정한다.
사실이 한 곳에만 존재하도록 복원한 것이며, §0.1 원칙 2("하나의 사실을 두 곳에 저장하면 갈라진다")를
대표권에 적용한 결과다. `representation_mode`는 이제 **행이 존재할 때만 의미를 갖는** 순수한 대표방식 값이 되어
`'NONE'`이 불필요해졌고, 정합성 CHECK 자체가 사라졌다.

`representation_mode` 의미: `SOLE`=단독대표, `JOINT`=공동대표(2인 이상 공동 행사), `INDIVIDUAL`=각자대표(각자 단독 행사).

#### §2.5.2 행 단위 CHECK로 막을 수 없는 것 (v5에서 일부 해소)

별도 테이블 분리로 **한 행 내부의 모순은 해소**됐으나, 행 사이의 모순은 CHECK로 막을 수 없다.
**v5는 그중 SOLE 유일성을 부분 UNIQUE 인덱스로 해소한다**(§2.5.4).

| 모순 | 행 CHECK | v5 상태 |
|---|---|---|
| 같은 법인에 `SOLE`(단독대표) **2명 이상** | 불가 | ✅ **해소** — §2.5.4 부분 UNIQUE |
| `SOLE`과 `JOINT`가 같은 법인에 **혼재** | 불가 | ❌ **미해소** — Open Item (c) |
| 대표가 **0명**인 법인 | 불가(존재하지 않는 행) | ❌ **미해소** — Open Item (c) |
| 복잡한 공동대표 조합(A+B 서명, A 또는 B+C 등) | 불가 | **MVP 범위 밖**(`601510` §4 명시) |

#### §2.5.3 v4 서술의 정정 — "CHECK로 못 막는다" ≠ "DB로 못 막는다"

v4 §2.5.2는 SOLE 2명 문제를 "행 CHECK로 막을 수 없으므로 RPC/트리거 소관"으로 이월했다.
**Stage 11B가 이 판단을 반박했고, 그 반박이 옳다**:

> *"'CHECK로 못막는다' ≠ 'DB로 못막는다'. partial unique index로 충분히 방어 가능 …
> 시드 0건인 지금이 가장 싸게 고칠 시점."*

v4는 **제약 수단을 CHECK로만 상정**해 DB 강제 가능성을 조기에 포기했다.
부분 UNIQUE 인덱스는 이미 이 설계가 3곳에서 쓰고 있던 도구였다(§2.2, §2.3, §2.5).
**같은 도구를 SOLE 불변조건에 적용할 생각을 하지 못한 것이 v4의 누락**이다.

#### §2.5.4 ⭐ SOLE 대표 유일성 — DB 강제 (v5 신설, BLOCK 조건 ③)

```text
unique index uq_ler_sole_active
  on catchmenu_hq.legal_entity_representatives (legal_entity_id)
  where representation_mode = 'SOLE' and is_active = true
```

**보장하는 것**: 한 법인에 **동시에 활성인 `SOLE` 대표는 최대 1명**.

**보장하지 않는 것(명시)**:
- `SOLE` 1명 + `JOINT` 2명이 **동시에 존재**하는 모순은 막지 못한다(서로 다른 부분 인덱스 술어).
- 대표가 **0명**인 법인도 막지 못한다.
- → Open Item (c)로 유지. 다만 **가장 흔하고 가장 위험한 케이스(단독대표 2명)는 DB가 막는다.**

> **`601510` 원문의 컬럼명 주의**: 감사 원문은 `representation_type` / `active`로 적었으나,
> 실제 스키마의 컬럼명은 **`representation_mode` / `is_active`** 다. 위 인덱스는 실제 컬럼명을 따른다.

**적용 시점**: **0169**. 현재 이 테이블은 **0행**이므로 인덱스 추가가 기존 데이터와 충돌하지 않는다 —
`601510`이 지적한 *"시드 0건인 지금이 가장 싸게 고칠 시점"* 그대로다.

#### §2.5.3 `is_active` ↔ `effective_to` 이중 진실원천 (A-5)

`legal_entity_person_roles`와 `legal_entity_representatives` **양쪽 모두** 종료 상태를 두 가지로 표현할 수 있다:
`is_active = false` **또는** `effective_to < current_date`. 둘이 어긋나면(예: `is_active=true`인데 `effective_to`가 과거)
어느 쪽이 진실인지 판정 불가다. **§0.1 원칙 2 위반이 두 신규 테이블에 남아 있는 셈**이다.

0-A에서 즉시 해소하지 않는 이유: 부분 UNIQUE 인덱스가 `WHERE is_active = true`에 의존하는데,
날짜 기반 술어(`effective_to is null or effective_to >= current_date`)는 **`current_date`가 STABLE이라 인덱스 술어로 사용 불가**하다.
따라서 `is_active`를 제거하려면 유일성 보장 방식 자체를 재설계해야 한다(배타 제약 `EXCLUDE`+`daterange` 등).

**0-A 잠정 계약**: `is_active`를 **유일성 판정의 진실원천**으로 삼고, `effective_from`/`to`는 **이력 기록용**으로 둔다.
둘의 동기화는 RPC 책임이다. 근본 해소는 §7 Open Item (b)로 이월한다.

### §2.6 기존 테이블 변경 (가법적 추가만)

| 테이블 | 추가 | NOT NULL | 비고 |
|---|---|---|---|
| `tenants` | `tenant_status text` | ✓ `default 'TRIAL'` | CHECK 5값 — 구독 생명주기 축 |
| `tenants` | `isolation_state text` | ✓ `default 'NONE'` | CHECK 2값 — 보안 격리 축 |
| `stores` | `legal_entity_id uuid` | ✗ (nullable) | FK → `legal_entities.id`. **5단계 말미 NOT NULL 승격 검토**(§5.2, A-8) |

**기존 제약 유지 선언**: `uq_stores_tenant_code (tenant_id, store_code)`는 **tenant 단위 그대로 유지**한다.
`legal_entity_id`를 이 유니크 키에 넣지 않는다.

### §2.7 접근제어 — 실제 차단 계층 (B-1, v4 전면 재작성)

> **⚠️ v3 §2.6 서술 폐기**: v3는 "0021 패턴과 동일한 deny-by-default"라며 **RLS를 차단 메커니즘으로 지목**했다.
> 2차 검증 결과 **이는 차단 계층을 잘못 짚은 것**이다. 아래가 실제 사실이다.

#### §2.7.1 실제 차단은 RLS가 아니라 GRANT + PostgREST 노출 제한이다

| 계층 | 실제 상태 | 확인 근거 |
|---|---|---|
| **① PostgREST 노출 스키마** | `catchmenu_hq`가 **API에 노출되지 않음** | `supabase/config.toml` `[api] schemas = ["public", "graphql_public"]` |
| **② GRANT (테이블 권한)** | `catchmenu_hq`의 **16개 테이블 전부 테이블 권한 GRANT 0건** | migration 전수 검색 결과 `grant ... on ... catchmenu_hq.<table>` **0건** |
| ③ RLS | enable/force되어 있으나 **①②에 도달조차 못 하므로 실질 차단자가 아님** | — |

**역할별 실제 상태**:

- **`service_role`**: `BYPASSRLS = true`이지만 **`catchmenu_hq` 스키마에 USAGE 자체가 없다**
  (0022 L614–623의 `grant usage on schema` 대상은 `authenticated`뿐). → RLS를 우회할 수 있어도 **스키마에 진입할 수 없다**.
- **`authenticated`**: 스키마 USAGE는 있으나(0022 L615) **테이블 권한이 없다** → 테이블에 접근 불가.

즉 **RLS가 없더라도 이 테이블들은 이미 접근 불가**다. RLS는 3차 방어선이지 1차 차단자가 아니다.

#### §2.7.2 "0021 패턴과 동일" 서술 삭제 — 이 저장소 최초 사례

0021은 `enable`+`force`를 걸고 **0022가 그 테이블들에 정책을 붙이는 짝**으로 설계돼 있다.
즉 0021 단독이 "정책 0개" 상태로 남는 것이 아니다.

**본 워크패킷의 신규 4개 테이블은 이 저장소에서 최초로 "force RLS + 정책 0개"로 남는 사례다.**
선례가 없으므로 "기존 패턴을 따랐다"고 서술할 수 없으며, **의도된 신규 설계 결정**으로 명시한다.

#### §2.7.3 명시적 설계 결정 — 신규 4테이블에 GRANT를 주지 않는다

**결정**: `owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives`에
`authenticated`·`service_role` 어느 역할에도 **테이블 권한을 부여하지 않는다.**

근거: 0-A는 **구조 확정**까지이고 이 테이블들을 읽고 쓰는 RPC는 후속 워크패킷 소관이다(§47.6-1).
접근이 필요해지는 시점에 **필요한 최소 권한만** 부여하는 것이 순서다.
지금 GRANT를 주면 "쓰는 곳이 없는데 열려 있는 테이블"이 생기고, 0-C가 접근제어를 설계할 때
**이미 열린 문을 닫는 작업**부터 해야 한다.

#### §2.7.4 Open Item (l) — **조건부 해소** (`SECURITY DEFINER` 접근)

v3는 "`SECURITY DEFINER` 함수가 이 테이블에 접근 가능한지 미확인"으로 남겼다. **조건부로 해소한다**:

`SECURITY DEFINER` 함수는 **소유자 권한**으로 실행된다. 소유자가 `postgres`이면 `postgres`는 `BYPASSRLS`를 가지며
스키마·테이블 소유자이므로, `force row level security`와 GRANT 부재에 관계없이 **정상 접근한다**.
**소유권의 실제 근거 상태 (직접 확인)**:

| 확인 대상 | 결과 |
|---|---|
| `sql/migrations/*.sql`의 명시적 소유자 지정(`owner to postgres`) | **0건** |
| 클라우드 백업 덤프(`cloud_backup_before_sync_2026_07_11.sql`)의 `ALTER FUNCTION ... OWNER TO "postgres"` | 623건 |

즉 **소유자를 `postgres`로 고정하는 선언이 마이그레이션 어디에도 없다.** 현재 `postgres` 소유인 것은
"마이그레이션을 `postgres`로 실행해 왔다"는 **운영 관행의 결과(emergent property)** 일 뿐이며,
덤프의 623건은 그 결과를 사후에 기록한 것이지 계약이 아니다.

> **⚠️ 전제 조건 명시 (2차 검증 지적 반영)**: 이 해소는 **"함수 소유자를 `postgres`로 유지한다"는 배포 계약이
> 성립할 때만** 유효하다. 무조건적 사실이 아니며, 위 표대로 **그 계약은 현재 코드로 명문화돼 있지 않다**.
> 다음 중 하나라도 발생하면 **해소는 무효가 되고 접근이 막힌다**:
>
> - 후속 워크패킷이 RPC를 `postgres` 아닌 역할 소유로 생성/변경하는 경우
> - 배포 파이프라인이 마이그레이션을 `postgres` 아닌 역할로 실행해 함수 소유자가 그 역할이 되는 경우
> - Supabase 측 정책 변경으로 `postgres`의 `BYPASSRLS`가 사라지는 경우
>
> **따라서 Open Item (l)은 "삭제"가 아니라 "배포 계약 항목으로 전환"한다** — §7 (o)에 소유자 계약을 신설하고,
> 5단계에서 신규 함수 생성 시 소유자를 확인하는 것을 검증 항목으로 남긴다.
> GRANT를 주지 않는 설계(§2.7.3)를 택한 이상, **소유자 전제가 이 테이블들의 유일한 접근 경로**이므로
> 이 전제가 깨지면 조용히 "아무도 못 쓰는 테이블"이 된다.

#### §2.7.6 ⭐ SECURITY DEFINER 보안 경계 (v5 신설, BLOCK 조건 ①②)

Stage 11B의 BLOCKER 지적: *"문제는 함수 소유자가 '시스템의 일부'인데 이걸 문서 경고로만 남긴 것."*
v4는 소유자 전제를 Open Item (o)로 **기록만** 했다. v5는 이를 **강제 가능한 형태**로 바꾼다.

##### 요구 방어선 5개 (`601510` §3)

| # | 요구 | 0-A(0169)에서 가능한 것 | 0-C에서 반드시 할 것 |
|---|---|---|---|
| 1 | 함수 owner를 **전용 NOLOGIN role**로 고정 | ✅ **role 신설**(`catchmenu_authority_owner`) | 함수 생성 시 이 role 소유로 |
| 2 | `ALTER FUNCTION … OWNER TO …`를 migration에 명시 | — (함수 없음) | ✅ 필수 |
| 3 | `EXECUTE`를 `PUBLIC`에서 제거, 필요 role만 GRANT | — | ✅ 필수 |
| 4 | `search_path` 함수별 고정 + 모든 참조 schema-qualified | — | ✅ 필수 |
| 5 | CI/migration verification에서 `proowner`/ACL/`prosecdef` 검사 | ✅ **체크리스트 명문화** | ✅ 실행 |

**0-A는 DDL 전용이라 함수가 하나도 없다.** 따라서 0169가 할 수 있는 것은 **①(role 신설)과 ⑤(체크리스트)** 이고,
②③④는 **0-C의 필수 요구사항으로 명문화**한다(`601503` §9).

##### ⚠️ `search_path`가 owner보다 위험하다 (원문 인용)

> *"SECURITY DEFINER 함수에 부적절한 search_path가 붙으면 '접근불능'이 아니라 '권한상승 취약점'으로 발전 가능
> (호출자가 자기 search_path 앞쪽 스키마에 동명 가짜테이블을 만들면 함수가 그걸 참조, postgres 권한으로 실행됨)."*

이것이 ①(owner 고정)보다 ④(search_path 고정)를 **더 시급하게** 만든다 —
owner 문제는 최악이 "안 됨"이지만, search_path 문제는 최악이 **"공격자가 postgres 권한을 얻음"** 이다.

**0-C 고정값**: `set search_path = catchmenu_hq, pg_catalog` (필요 스키마만, **`public` 제외**).

##### ⚠️⚠️ 전용 owner role 도입 시의 함정 — 실측 확인 (v5 신규 발견)

**전용 NOLOGIN role을 만들어 함수 소유자로 지정하면, 그 role에 `BYPASSRLS`가 없는 한
이 4개 테이블에서 함수가 조용히 0행을 반환한다.** 오류가 아니라 **빈 결과**다.

로컬 실측(2026-08-10, 행 1건 삽입 후 `authenticated`로 호출):

| 함수 소유 role | 결과 |
|---|---|
| NOLOGIN, **`BYPASSRLS` 없음** (테이블 `SELECT` 권한은 부여) | **`0`** ← RLS가 조용히 전량 필터 |
| NOLOGIN, **`BYPASSRLS` 있음** | **`1`** ← 정상 |

원인: 이 4개 테이블은 `FORCE ROW LEVEL SECURITY` + **정책 0개**(§2.7.2)다.
`FORCE`는 소유자에게도 RLS를 적용하므로, 정책이 없으면 **모든 행이 걸러진다.**
`postgres`가 지금 동작하는 이유는 오직 `rolbypassrls = t` 때문이다.

**따라서 `catchmenu_authority_owner`는 다음 중 하나를 반드시 갖춰야 한다**:

| 선택지 | 내용 | 평가 |
|---|---|---|
| **(a)** | role에 `BYPASSRLS` 부여 | **0169 채택 권고** — `postgres`(슈퍼유저급)보다 **좁은 권한**이고, NOLOGIN이며, 권능이 명시적·감사 가능 |
| (b) | 이 role을 위한 RLS 정책 생성 | 0-C 소관. 정책이 생기면 (a)의 `BYPASSRLS`를 회수하는 경로가 열린다 |
| (c) | `FORCE` 해제 | **채택 안 함** — 방어선을 낮춘다 |

> **이 함정을 문서화하지 않으면**: 0169가 조건 ①을 문자 그대로 이행(`NOLOGIN` role 신설 + 소유권 이전)한 순간,
> 0-C에서 만든 함수가 **오류 없이 빈 결과를 반환**하고, 그 원인을 찾는 데 오래 걸린다.
> **조용한 실패는 시끄러운 실패보다 비싸다.**

##### tenant 경계 — confused deputy (BLOCK 조건 ② 후반)

> *"SECURITY DEFINER는 RLS를 우회하므로, 이 4개 테이블이 tenant간 공유영역이라면 함수 내부에서
> tenant authority를 직접 검증해야 한다. base table GRANT 제거가 multi-tenant isolation을 자동 보장하지 않는다 —
> 잘못 작성된 SECURITY DEFINER 하나가 'tenant A가 tenant B의 legal entity를 조회'하는 confused deputy가 될 수 있다."*

이 지적은 **본 설계의 구조상 특히 유효**하다: `owners`/`legal_entities`/`legal_entity_person_roles`/
`legal_entity_representatives`는 **전역 테이블로 `tenant_id` 컬럼이 없다**(§0.1 업무규칙 3).
즉 **RLS가 걸려 있어도 tenant를 구분할 근거가 테이블 자체에 없다.**

**0-C 필수 설계 원칙 (v5 명문화)**:

> 이 4개 테이블을 조회·변경하는 **모든** `SECURITY DEFINER` 함수는,
> 호출자의 tenant 권한을 **함수 내부에서 명시적으로 검증**해야 한다.
> 검증 경로는 `stores.legal_entity_id`를 경유한다 —
> "요청된 `legal_entity_id`가 `current_tenant_id()`의 store와 연결되어 있는가".
> **이 검증 없이 `legal_entity_id`를 파라미터로 받아 조회하는 함수는 confused deputy다.**

#### §2.7.5 0-C 후보 정책식 (참고 — 접근이 필요해질 때)

```text
-- legal_entities: 내 tenant의 매장을 운영하는 법적 주체만
using (exists (
  select 1 from catchmenu_hq.stores s
  where s.legal_entity_id = legal_entities.id
    and s.tenant_id = catchmenu_common.current_tenant_id()
))
```

0-C 판단 필요: (a) 조인 성능(`idx_stores_legal_entity_id` 전제), (b) `legal_entity_id IS NULL`인 store만 가진
주체는 어떤 정책으로도 안 보이는 문제, (c) 교차 tenant 존재 노출 여부. **정책 이전에 GRANT가 선행 조건**이다.

---

## §3. `tenants` 상태 2컬럼 분리 (B-1 v2에서 계승)

| 컬럼 | 정의 | 축 | 단독 기록자 |
|---|---|---|---|
| `tenant_status` | `NOT NULL default 'TRIAL'` CHECK `('ACTIVE','TRIAL','SUSPENDED','CANCELLED','TERMINATED')` | 구독 생명주기 | `manage_subscription()` |
| `isolation_state` | `NOT NULL default 'NONE'` CHECK `('NONE','ISOLATED')` | 보안 격리 | `isolate_tenant()` |

**직교 — 동시 표현 가능**: `TRIAL`+`ISOLATED`, `ACTIVE`+`ISOLATED`, `SUSPENDED`+`ISOLATED` 전부 유효.

**근본원인**: `isolate_tenant()`(0090 L1283–1286)가 `'ISOLATED'`/`'ACTIVE'`를 `tenant_status`에 덮어쓴다(L1293–1295).
`manage_subscription()` SUSPEND(0112 L595)가 `'SUSPENDED'`를 쓴 직후 `isolate_tenant()`를 호출(L599–606)해
**자기가 쓴 값을 즉시 파괴**하고, 해제 시엔 무조건 `'ACTIVE'`로 되돌려 **구독상태를 소실**시킨다.

**CHECK 값의 실증 근거**: 0112가 이미 `'ACTIVE'`(L102,160,611,904)/`'TRIAL'`(L105,831)/
`'SUSPENDED'`(L108,595,828)/`'CANCELLED'`(L625,823)를 실제 사용한다 — 5값 중 4값은 기존 코드에서 역산됐다.
`'TERMINATED'`만 `tenants` 맥락 사용처가 **없다**(0053/0074/0076/0085의 것은 staff/pos/franchise 맥락)
→ **전방 호환용 신규 값**임을 명시한다.

**후속 RPC 계약(본 워크패킷 구현 아님)**:
- `isolate_tenant()`는 `isolation_state`만 변경, `tenant_status`는 읽지도 쓰지도 않는다.
- **격리 해제 시 `tenant_status`를 자동으로 `'ACTIVE'`로 되돌리지 않는다**.
- `manage_subscription()`은 `tenant_status`만 변경한다.

### §3.1 서비스 가능 판정 규칙 (v5 신설 — Stage 11B §1)

Stage 11B는 2컬럼 분리를 ACCEPT하면서 다음을 요구했다:
*"'서비스가능여부 = lifecycle 허용상태 AND isolation_state=NONE'이라는 공통 판정규칙이 시스템 전체에서
일관되게 적용돼야 함 — 일부 RPC가 한쪽만 확인하면 격리가 뚫린다."*

**공통 판정 규칙 (0-A-2가 단일 함수로 구현할 것)**:

```text
serviceable(tenant) := tenant_status IN ('ACTIVE', 'TRIAL')
                       AND isolation_state = 'NONE'
```

- **두 축을 각각 따로 확인하는 코드를 금지**한다. 한쪽만 보는 RPC가 하나라도 있으면 격리가 무력화된다.
- 0-A-2는 이를 **하나의 헬퍼 함수로 만들어 모든 호출부가 그것만 쓰도록** 해야 한다
  (`601505` §8A 완료 항목에 편입 — `601503` §7 (s)).

### §3.2 상태 전이 규칙 (v5 신설 — Stage 11B §1 요구)

Stage 11B가 명시를 요구한 3가지에 대한 **설계 선언**(0-A-2 구현 시 이 정의를 따른다):

| 항목 | 선언 |
|---|---|
| **`CANCELLED` vs `TERMINATED`** | `CANCELLED` = **구독 해지**(고객 의사·미납 등). **재활성 가능**. `TERMINATED` = **계약 종료**(영구). **재활성 불가** |
| **`TERMINATED` → `ACTIVE` 역전이** | **금지(terminal state)**. 다시 서비스하려면 신규 tenant를 생성한다 |
| **격리 해제가 `tenant_status`를 바꾸는 것** | **금지.** `TERMINATED`+`ISOLATED`에서 `isolation_state`만 `NONE`이 되어도 `tenant_status`는 `TERMINATED`로 남아야 하며, **tenant가 되살아나서는 안 된다** |

> 마지막 항목이 §3의 2컬럼 분리가 실제로 지켜지는지를 가르는 지점이다 —
> v4까지의 `isolate_tenant()`는 해제 시 무조건 `'ACTIVE'`를 썼으므로(0090 L1283–1286),
> **`TERMINATED` 테넌트를 격리 해제하는 것만으로 되살릴 수 있었다.**
>
> **이 전이 규칙은 CHECK로 강제되지 않는다**(상태 전이는 행 단위 제약으로 표현 불가).
> 0-A-2가 RPC 레벨에서 강제해야 하며, DB는 값의 유효성만 보장한다 — Open Item (t).

---

## §4. phantom 컬럼 정리 방안

| phantom 참조 | 참조 위치 | 정리 방향 | 0-A DDL 추가? |
|---|---|---|---|
| `tenants.company_name` | 0112 L288, L346, L533, L677, L690 | `legal_entities.legal_name` + `stores.legal_entity_id` 조인 | ✗ |
| `tenants.business_number` | 0112 L289, L404 | `legal_entities.business_registration_number` + `brn_normalized` 부분 UK | ✗ |
| `tenants.ceo_name` | 0112 L290 | **`legal_entity_representatives` 활성 행 조인** | ✗ |
| `tenants.owner_name/email/phone` | 0082 L479–483 | `owners` + `legal_entity_person_roles` 조인 | ✗ |
| `tenants.tenant_status` | 0082/0090/0112/0120/0123/0129 | **2컬럼 분리 후 실제 추가** | **✓ ×2** |
| `stores.extra_metadata` | 0060 L235, L946 | 구조화 정보는 `legal_entities`/`owners`로 이전 | ✗ |
| `stores.brand_id` | 0112 L456–458 | 브랜드 축 = 브랜드 나선 소관 | ✗ |

`ceo_name`이 단순 컬럼 이관이 아닌 이유: 법인은 대표자가 복수일 수 있고(공동/각자대표) 대표권에는 유효기간이 있다.
단일 `ceo_name` 컬럼은 이 현실을 표현할 수 없으며, **`legal_entity_representatives`의 활성 행 집합**이 정확한 답이다.

---

## §5. MVP 시드 및 백필 방향 (설계만 — 실제 값은 5단계)

### §5.1 시드 설계

| 대상 | 설계값 | 제약 통과 |
|---|---|---|
| Owner | 1명 (정영석) | — |
| LegalEntity | `entity_type='SOLE_PROPRIETOR'`, `business_registration_number=NULL` | `brn_normalized`도 NULL → 부분 UK 미적용 ✓ / `corporate_registration_number` **반드시 NULL** ✓ |
| 역할 | `legal_entity_person_roles`: `role_type='OWNER'` | 부분 UK ✓ |
| **대표권** | **`legal_entity_representatives`: `representation_mode='SOLE'` 1행** | 부분 UK ✓ / v4에서 별도 행이 됨 |
| Store | 기존 store 1개에 `legal_entity_id` 설정 | FK ✓ |

`ownership_percent`는 단독 사업주이므로 `100` 또는 `NULL` — 5단계 확정.

### §5.2 `stores.legal_entity_id` NOT NULL 승격 시점 (A-8)

v3는 승격을 "0단계 종료 판정"으로 미뤘다. v4는 **5단계 말미(시드 1건 생성 직후)로 앞당기는 것을 검토**한다.

**앞당기기 유리한 근거**: 라이브 `stores` 행이 사실상 시드 1건뿐이므로, 그 1건에 `legal_entity_id`를 채우면
**즉시 전 행이 NOT NULL 조건을 만족**한다. 나중으로 미루면 그 사이에 `legal_entity_id=NULL`인 store가
추가로 생겨 승격이 더 어려워질 수 있다 — **가장 쉬운 시점은 지금**이다.

**신중해야 할 근거**: NOT NULL 승격은 **가법적이지 않다**(기존 INSERT 경로가 이 컬럼을 채우지 않으면 즉시 실패).
`stores`에 INSERT하는 기존 RPC 전수 조사가 선행돼야 한다.

→ **판정 자체를 5단계 말미로 이관**하되, 그 시점에 위 두 근거를 대조해 결정한다. §7 Open Item (h).

**FK 검사와 RLS 관계 기록(A-8)**: `stores.legal_entity_id`의 FK 무결성 검사는 **RLS가 적용되지 않는다**
(PostgreSQL의 참조 무결성 검사는 시스템 내부에서 수행되며 RLS 정책을 우회한다).
따라서 `legal_entities`가 deny-by-default 상태여도 **FK는 정상 작동**한다.
반대로 이는 **FK 존재 자체가 정보 노출 경로**가 될 수 있음을 뜻한다(존재하지 않는 id로 INSERT 시 FK 위반 오류) —
0-C 오류 메시지 설계 시 함께 고려할 것.

---

## §6. 검증 결과 처분 요약

| 항목 | 처분 | 위치 |
|---|---|---|
| **B-1** 접근제어 서술 | 전면 재작성 — 실제 차단은 GRANT+PostgREST, RLS 아님. "0021 패턴 동일" 삭제, GRANT 미부여 설계결정 명시, Open Item (l) 해소 | §2.7 |
| **B-2** 대표권 분리 | `legal_entity_representatives` 신규 테이블, roles에서 2컬럼 제거 | §2.5 |
| **A-1** cron 실측 | `601503` §5에 반영 — `cron.job` 0행(로컬), 0120 카탈로그 불일치, `is_registered` 역논리 결함 신규 승계 | `601503` §5 |
| **A-2** 원칙1 재서술 | "Company" 단어 제거 → "법인은 `entity_type`의 한 값" | §0.1 |
| **A-3** 매핑표 정정 | company 축에서 `store_groups` 삭제, `franchise_brands`만 | §0.3 |
| **A-4** 대표권 잔여 허점 | 별도 테이블로 근본 해결됐으나 행간 모순(SOLE 2명 등)은 여전 → Open Item | §2.5.2 |
| **A-5** `is_active`↔`effective_*` | 두 신규 테이블 모두 이중 진실원천 → 잠정 계약 + Open Item | §2.5.3 |
| **A-6** CRN 정규화 | BRN과 동일한 생성컬럼 방식 적용 | §2.2 |
| **A-7** CORPORATION의 CRN | NOT NULL 요구하지 않음 — 판단 명시 | §2.1 |
| **A-8** NOT NULL 승격 | 5단계 말미로 앞당기기 검토 + FK/RLS 관계 기록 | §5.2 |
| **A-9** PG 17.6 | `SET EXPRESSION` 경로 실재 → Open Item (d) 긴급도 하향 | `601503` §6.3 |

---

## §7. Open Items

| # | 항목 | 소관 | v4 변동 |
|---|---|---|---|
| (a) | `is_active` vs `tenant_status` 진실원천 정리 | 0-A-2 | — |
| (b) | `is_active` ↔ `effective_from/to` 이중 진실원천 근본 해소(두 신규 테이블) | 후속 | **A-5 신규** |
| (c) | 대표권 **행간** 모순(같은 법인에 SOLE 2명, 대표 0명 등) 방지 | RPC/트리거 | **A-4 신규** |
| (d) | 등록번호 정규화 표현식·형식 CHECK 최종 확정 | 5단계 착수 전 | **긴급도 하향**(A-9) |
| (e) | `ownership_percent` 법인별 합계 ≤ 100 검증 | RPC/트리거 | — |
| (f) | 등록번호 중복 오류의 존재탐지 오라클 차단 | 0-C | — |
| (g) | `owners` 중복 등록 방지 절차 | 0-C | — |
| (h) | `stores.legal_entity_id` NOT NULL 승격 판정 | **5단계 말미** | **A-8 앞당김** |
| (i) | `store_groups` `DISTRICT` 도입 | 브랜드/프랜차이즈 나선 | — |
| (j) | `franchise_brands` 사업자축 중첩 해소 | 브랜드 나선 | — |
| (k) | `stores.extra_metadata` / `stores.brand_id` | 후속 / 브랜드 나선 | — |
| ~~(l)~~ | ~~`SECURITY DEFINER` 접근 가능 여부~~ | — | **조건부 해소 → (o)로 전환(§2.7.4)** |
| (m) | 라이브(클라우드) `pg_cron` 등록 상태 / 카탈로그 값 / PG 버전 확인 | 5단계 착수 전 | **로컬은 실측 완료**(A-1) |
| (n) | `pg_cron_jobs.is_registered` 역논리 결함 수정 | 0-A-2 | **A-1 신규** |
| (o) | ~~배포 계약: RPC 함수 소유자를 `postgres`로 유지~~ → **전용 role `catchmenu_authority_owner`로 대체·강화**(§2.7.6). **`BYPASSRLS` 필요 여부 판단 포함** | **0169 + 0-C** | **v5에서 강화(조건 ①②)** |
| (q) | **소유권(지분) 모델링** — `legal_entity_ownership_stakes` 등 별도 테이블 필요 가능성. `legal_entity_person_roles.ownership_percent`는 **사용 금지**(§2.3.1) | 소유권 워크패킷 | **v5 신규(조건 ④)** |
| (r) | **LegalEntity : 사업자등록 1:N 확장** — 한 법인이 복수 사업장·등록단위를 갖는 경우(§2.1.1) | 미정 | **v5 신규(조건 ④)** |
| (s) | **`serviceable()` 공통 판정 헬퍼** — 두 축을 각각 확인하는 코드 금지(§3.1) | **0-A-2** | **v5 신규(11B §1)** |
| (t) | **상태 전이 규칙 RPC 강제** — `TERMINATED` terminal, 격리해제가 부활시키지 않을 것(§3.2). CHECK로 표현 불가 | **0-A-2** | **v5 신규(11B §1)** |
| (u) | **`stores.legal_entity_id`의 시간성** — 운영법인 A→B 변경 시 과거 주문·정산·세금자료가 B 소관으로 재해석될 위험. `effective_from`/`to` 또는 거래시점 snapshot 필요 가능성 | 미정 | **v5 신규(11B 추가발견 1)** |
| (v) | **삭제 정책** — `legal_entity`는 상위 권위 객체이므로 `ON DELETE CASCADE` 위험. `inactive`/`dissolved` lifecycle 권장 | 미정 | **v5 신규(11B 추가발견 2)** |
| (w) | **default 자동승인 패턴 경계** — 기존 데이터에 무조건 default를 부여하는 backfill이 "사실상 권한 자동승인 migration"이 될 위험. **본 워크패킷은 `TRIAL`/`NONE`으로 시작해 안전**하나 향후 유사 패턴의 경계로 기록 | 상시 | **v5 신규(11B 추가발견 3)** |
| (x) | **"Owner" 명칭 모호성** — SaaS 계정 소유자 vs 법적·경제적 소유자. §2.4.1 선언 참조 | 0-C(권한 시스템) | **v5 신규(11B 추가발견 4)** |

---

## §8. 근거 목록 (§46)

**방법론**
- `000701_...` — §46, §47.1(세션 분리 요건), §47.2, §47.3, §47.4, §47.6, §48(5단계 분류·D단계), §49.2(`ADD COLUMN` 선행)
- `000001_Md_Rules.md` — §5.4.1~§5.4.3

**상위 개념문서**
| 문서 | 인용 | 역할 |
|---|---|---|
| `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | §2 축 정의표, §3, §4, §6 | LegalEntity 중심 모델의 상위 근거 |
| `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | L18, L19, L21 | 개념 엔터티 정의 |
| `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | L5, L19–22, L30, L33 | **company≠operating_group 축 구분 근거(A-3)** |
| `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | L21, L40 | 관리자 화면 축 구분 |

**접근제어 근거 (v4 핵심 — B-1)**
| 파일 | 인용 | 역할 |
|---|---|---|
| **`supabase/config.toml`** | `[api] schemas = ["public","graphql_public"]` (L7–13) | **PostgREST가 `catchmenu_hq`를 노출하지 않음 — 1차 차단자** |
| `0022_create_rls_policies.sql` | L614–623(`grant usage on schema ... to authenticated`), L78–89(`is_service_role()`), L282–294/L606–611(서비스전용 정책 실례) | **`authenticated`만 스키마 USAGE 보유 / `service_role`은 USAGE 없음** |
| migration 전수 검색 | `grant ... on ... catchmenu_hq.<table>` **0건** | **16개 테이블 테이블권한 GRANT 부재 — 2차 차단자** |
| `0021_enable_rls.sql` | 전체 | enable+force. **0022와 짝을 이루는 구조이며 "정책 0개" 선례가 아님** |

**기존 스키마**
- `0002_create_hq_tenant_store.sql` — `tenants`(L8–24), `stores`(L43–76, `uq_stores_tenant_code` L60)
- `0072_create_pg_cron_schedules.sql` — `pg_cron_jobs` 카탈로그(L29–66), **등록 루프 `where is_registered = false`(L201–206) 및 등록 후 `true` 갱신(L226–230) — A-1 역논리 결함 근거**
- `0077_create_multistore_rpc.sql` — `store_groups`(L25–78), `store_group_members`(L126–155)
- `0085_...franchise_os_foundation_rpc.sql` — `franchise_brands`(L123–160) — **참조만, 미변경**
- `0034_seed_data.sql` — `YOONSUL_TEST`(L24–25), `윤슬 울산 1호점`(L52–55)

**`tenant_status` 참조 6개 파일 전량**
| 파일 | 위치 |
|---|---|
| `0082_create_saas_billing_rpc.sql` | L88–112(`subscription_plans` 시드, `TRIAL_30`=plan_code), L426–438(실제 시그니처), L465, L477–486, L490, L500 |
| `0090_create_multitenant_isolation_rpc.sql` | L1283–1286, L1293–1295 |
| `0112_create_hq_admin_rpc.sql` | **21개 지점** — UPDATE 3(L595/611/625), 집계 6(L102/105/108/823/828/831), 필터 4(L160/271–272/337–338/904), 출력 6(L194/291/362/533/665/670), 공개 파라미터 1(L248) / `provision_tenant` 오호출 L414–424 |
| `0120_create_reconciliation_pipeline.sql` | L898, L916, L926 (`sql_command` 내부 `$sql$`) |
| `0123_create_ai_customer_center_v2.sql` | L636 |
| `0129_create_launch_readiness_package.sql` | L873–885(`HOURLY_METRICS`), L885 |

**기타**
- `0060_create_franchise_hq_rpc.sql` — `stores.extra_metadata`(L235, L946)
- `0053`/`0074`/`0076`/`0085` — `'TERMINATED'` 사용 맥락(tenants 맥락 아님)
- `0137`/`0138` — `'Run onboard_tenant()'` 문자열(실호출 아님)

**후속 문서**
- `601502_Overview_Operational_Authority_Foundation_Ddl.md` (v4)
- `601503_Logic_Operational_Authority_Foundation_Ddl.md` (v4)
