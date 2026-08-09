# 601503_Logic_Operational_Authority_Foundation_Ddl.md

Status: Draft
Lifecycle: Logic
Stage: 4 (설계문서 정합화 — `000701` §47.1 6단계 나선의 4단계)
Domain: Operational Authority Foundation (0단계 / 하위 나선 0-A)
Last Updated: 2026-08-09

## Change ID

`operational_authority_foundation_ddl`

> 본 문서는 **설계**다. `.sql` 파일은 5단계(Codex 구현)에서 작성한다. 아래 코드블록은 설계 의도를
> 정확히 고정하기 위한 **의사 DDL**이며, 그대로 복사해 실행하는 것을 전제하지 않는다.

## §1 설계 원칙 3가지

1. **가법적(additive) 변경만** — 기존 컬럼/제약을 삭제하거나 의미를 바꾸지 않는다. 추가만 한다.
2. **DDL과 로직의 분리** — 본 워크패킷은 DDL만. `CREATE OR REPLACE FUNCTION`을 **일절 포함하지 않는다**(601502 §3).
3. **직교하는 축은 직교하는 컬럼으로** — 한 컬럼이 두 개의 독립된 사실을 표현하면 반드시 상호 파괴가 발생한다(B-1의 교훈).

## §2 대상별 설계

### §2.1 `catchmenu_hq.companies` (신규)

```sql
-- 의사 DDL (설계 표현용)
create table if not exists catchmenu_hq.companies (
  id                 uuid primary key default gen_random_uuid(),
  company_name       text not null,
  business_number    text,                      -- nullable (§2.1.1)
  legal_entity_type  text not null default 'SOLE_PROPRIETOR',
  ceo_name           text,
  ceo_phone_hash     text,                      -- PII 평문 금지
  is_active          boolean not null default true,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),

  constraint chk_companies_legal_entity_type check (
    legal_entity_type in ('CORPORATION', 'SOLE_PROPRIETOR')
  )
);

-- 부분 UNIQUE: 실제 번호끼리만 전역 유일 (§2.1.1)
create unique index if not exists uq_companies_business_number
  on catchmenu_hq.companies (business_number)
  where business_number is not null;
```

#### §2.1.1 `business_number`를 nullable + 부분 UNIQUE로 하는 이유 (Human 결정, 2026-08-09)

1호점(윤슬김밥 울산1호점)의 실제 사업자번호가 **아직 확정되지 않았다**(Human 확인).
라이브의 `윤슬 울산 1호점`은 `tenant_code='YOONSUL_TEST'` 아래 주소가 `테스트로 123`인 시드 행이며
(0034 L24–25, L52–55), 사업자번호는 어디에도 없다.

| 대안 | 결과 |
|---|---|
| `NOT NULL` + 전역 UNIQUE | company 행을 만들려면 지금 **가짜 placeholder**를 넣어야 하고, UNIQUE라서 그 가짜값은 **딱 1건만** 쓸 수 있다. 두 번째 미확정 company는 아예 생성 불가. |
| **nullable + 부분 UNIQUE (채택)** | 번호 미확정 상태로 company 행 생성 가능(여러 건 가능). 실제 번호가 들어온 것들끼리는 전역 유일 보장. 번호 확정 후 `NOT NULL` 승격은 가법적으로 가능. |

**유일성 의미론은 신규 정의다(A-6 정정)**: `business_number`를 참조하는 FK나 유일성 계약이 기존 스키마에
**존재하지 않으므로**, 이는 기존 계약과의 *충돌*이 아니라 새로운 유일성 규칙의 *도입*이다.

**⚠️ 존재탐지 오라클 위험(기록)**: 사업자번호 중복 위반 오류를 호출자에게 그대로 노출하면,
미인증 호출자가 임의의 번호를 넣어보며 "이 사업자번호가 이미 시스템에 등록됨"을 알아낼 수 있다.
DB 제약은 그대로 두되, **오류를 일반화된 메시지로 감싸는 것은 RPC 계층의 책임**이며 0-C/후속 RPC 워크패킷 소관이다.

### §2.2 `catchmenu_hq.owners` (신규)

```sql
create table if not exists catchmenu_hq.owners (
  id                  uuid primary key default gen_random_uuid(),
  owner_name          text not null,
  contact_phone_hash  text,            -- UNIQUE 없음 (§2.2.1)
  contact_email       text,
  is_active           boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
```

#### §2.2.1 `owners`에 부분 유니크를 걸지 않는 판정 (D-2)

검토했고 **걸지 않는 것으로 판정**한다:

- 사람에게는 안정적인 자연키가 없다 — **동명이인**, **번호 공유**(가족/법인 대표번호), **번호 변경**이 전부 정상 시나리오다.
- `contact_phone_hash`에 전역 유니크를 걸면 위 정상 케이스를 **DB 레벨에서 거부**하게 되고,
  §2.1.1과 동일한 **존재탐지 오라클**을 하나 더 만든다.
- 중복 owner 방지는 "DB가 물리적으로 막는 문제"가 아니라 "등록 절차가 판단할 문제"다 → RPC/운영절차(0-C)로 이월.

### §2.3 `catchmenu_hq.owner_companies` (신규, N:M)

```sql
create table if not exists catchmenu_hq.owner_companies (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null references catchmenu_hq.owners(id),
  company_id     uuid not null references catchmenu_hq.companies(id),
  relation_role  text not null default 'REPRESENTATIVE',
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  constraint chk_owner_companies_relation_role check (
    relation_role in ('REPRESENTATIVE', 'CO_OWNER', 'INVESTOR')
  )
);

-- 부분 UNIQUE: "동시에 활성인 관계는 최대 1건" (§2.3.1)
create unique index if not exists uq_owner_companies_active
  on catchmenu_hq.owner_companies (owner_id, company_id)
  where is_active = true;

create index if not exists idx_owner_companies_company
  on catchmenu_hq.owner_companies (company_id) where is_active = true;
```

#### §2.3.1 재가입 불가 문제와 그 해결 (D-3)

`(owner_id, company_id)`에 **전체 UNIQUE**를 걸면 다음이 불가능해진다:

> Owner A가 Company X에서 손을 뗀다 → 관계를 `is_active=false`로 종료 → **나중에 다시 참여** →
> `insert` 시도 → **UNIQUE 위반**. 종료된 이력 행이 슬롯을 **영구 점유**하기 때문이다.

`WHERE is_active = true` 부분 인덱스는 활성 관계의 중복만 막고, 종료된 이력 행은 여러 건 남을 수 있게 한다.
→ **재가입 가능하며 이력도 보존**된다.

### §2.4 `catchmenu_hq.tenants` — 컬럼 2개 추가 (B-1)

```sql
alter table catchmenu_hq.tenants
  add column if not exists tenant_status text not null default 'TRIAL';

alter table catchmenu_hq.tenants
  add column if not exists isolation_state text not null default 'NONE';

alter table catchmenu_hq.tenants
  add constraint chk_tenants_status check (
    tenant_status in ('ACTIVE','TRIAL','SUSPENDED','CANCELLED','TERMINATED')
  );

alter table catchmenu_hq.tenants
  add constraint chk_tenants_isolation_state check (
    isolation_state in ('NONE','ISOLATED')
  );
```

| 컬럼 | 축 | 소관 | 누가 쓰는가(후속 워크패킷) |
|---|---|---|---|
| `tenant_status` | 구독 생명주기 | 과금/구독 | `manage_subscription()` **만** |
| `isolation_state` | 보안 격리 | 보안 | `isolate_tenant()` **만** |

**직교 원칙**: 두 축은 독립이며 **동시 표현 가능**하다 — `TRIAL`+`ISOLATED`, `ACTIVE`+`ISOLATED`,
`SUSPENDED`+`ISOLATED` 전부 유효한 상태다. 이것이 1컬럼 구조로는 불가능했던 지점이다.

#### §2.4.1 후속 RPC가 지켜야 할 계약 (본 워크패킷에서 구현하지 않음, 계약만 고정)

- `isolate_tenant()`는 **`isolation_state`만** 변경한다. `tenant_status`는 **읽지도 쓰지도 않는다**.
- **격리 해제 시 `tenant_status`를 `'ACTIVE'`로 자동 복구하지 않는다** — 격리 전 값을 그대로 둔다.
  (현재 0090 L1283–1286이 무조건 `'ACTIVE'`로 되돌려 구독상태를 소실시키는 동작의 폐기)
- `manage_subscription()`은 **`tenant_status`만** 변경한다. SUSPEND 시 격리가 필요하면
  `isolate_tenant()`를 호출하되, 그 호출이 `tenant_status`를 건드리지 않으므로 **상호 파괴가 발생하지 않는다**.

#### §2.4.2 `is_active`와의 관계

기존 `tenants.is_active boolean`은 **건드리지 않는다**(가법 원칙). 다만 `tenant_status`와 의미가 겹치므로,
"어느 쪽이 진실원천인가"의 정리는 **0-A-2 후속 워크패킷의 명시 과제**로 이월한다.
0-A DDL 단계에서 둘 중 하나를 폐기하면 기존 참조 전체를 동시에 건드려야 해서 범위 절단이 무너진다.

#### §2.4.3 `default 'TRIAL'` 선택 근거

기존 라이브 tenant는 시드(`YOONSUL_TEST`) 중심이고 실제 구독계약이 체결된 tenant가 없다.
`default 'ACTIVE'`로 두면 §5의 배치들이 **즉시 실제 대상으로 인식**해 예고 없이 돌기 시작한다.
`'TRIAL'`은 "아직 실운영 구독이 아님"을 정확히 표현하면서 배치 활성화를 **명시적 승격 행위**로 미룬다.

### §2.5 `catchmenu_hq.stores.company_id` — 컬럼 1개 추가

```sql
alter table catchmenu_hq.stores
  add column if not exists company_id uuid;

alter table catchmenu_hq.stores
  add constraint fk_stores_company_id
  foreign key (company_id) references catchmenu_hq.companies(id);

-- 0-C 조인 기반 RLS 정책의 성능 전제 (601501 §2.3)
create index if not exists idx_stores_company_id
  on catchmenu_hq.stores (company_id) where company_id is not null;
```

- **nullable로 둔다** — 기존 라이브 stores 행을 보존해야 하고, 백필은 §4의 별도 절차다.
- **`uq_stores_tenant_code (tenant_id, store_code)`는 tenant 단위 그대로 유지한다**(A-1).
  같은 Company가 서로 다른 Tenant에서 동일 `store_code`를 쓰는 것은 정상이며, 유일성 경계는 계속 Tenant다.
  `company_id`를 이 유니크 키에 **넣지 않는다**.

### §2.6 RLS — deny-by-default (B-2)

```sql
alter table catchmenu_hq.owners            enable row level security;
alter table catchmenu_hq.owners            force  row level security;
alter table catchmenu_hq.companies         enable row level security;
alter table catchmenu_hq.companies         force  row level security;
alter table catchmenu_hq.owner_companies   enable row level security;
alter table catchmenu_hq.owner_companies   force  row level security;
-- 정책(policy)은 만들지 않는다 → authenticated 전체 차단
```

0021이 확립한 패턴과 동일하다: `enable`+`force`만 걸고 **정책을 만들지 않으면**
`authenticated`의 직접 접근이 전부 차단되고, `SECURITY DEFINER` RPC / `service_role` 경로만 남는다.

이 3개 테이블은 **전역(tenant 무관)** 이라 기존의 `tenant_id = current_tenant_id()` 정책식을 쓸 수 없다.
이는 **미해결 공백이 아니라 안전하게 닫힌 상태**이며, 조인 기반 정책식 후보는 `601501` §2.3에 0-C 과제로 기록돼 있다.

**5단계 검증 필수 항목**: `force row level security` 하에서 `SECURITY DEFINER` 함수(소유자 `postgres`)와
`service_role`이 실제로 이 테이블에 접근 가능한지 **로컬에서 직접 실행 확인**할 것(§48의 D단계).
정책 없는 `force`가 의도보다 강하게 잠글 가능성을 문서로 넘기지 말고 실행으로 확인한다.

## §3 적용 순서 (§49.2 — `ADD COLUMN` 선행)

§49.2가 명시한 대로 **`ADD COLUMN`은 `CREATE OR REPLACE FUNCTION`보다 먼저** 적용돼야 한다
(PL/pgSQL은 지연 바인딩이라, 함수 본문이 참조하는 컬럼은 함수 생성 시점이 아니라 **실행 시점**에 해석된다 —
컬럼 없이 함수를 먼저 만들면 컴파일은 통과하고 런타임에 실패한다. 지금 phantom 컬럼들이 정확히 이 상태다).

본 워크패킷 내부 순서:

1. `companies` 생성 (`owner_companies`/`stores.company_id`의 FK 대상이므로 최선행)
2. `owners` 생성
3. `owner_companies` 생성 (1, 2에 FK 의존)
4. `tenants` 컬럼 2개 + CHECK 추가
5. `stores.company_id` + FK + 인덱스 추가
6. 3개 테이블 RLS enable/force
7. `comment on` / `set_updated_at` 트리거

**워크패킷 간 순서**: 본 워크패킷(DDL) → 0-A-2(RPC 재작성 + 배치 필터 보강) → 0-A-3(`onboard_tenant`/`provision_tenant` 재설계).
이 순서를 뒤집으면 §49.2 위반이다.

## §4 백필(backfill) 설계 (A-1)

### §4.1 `stores.company_id`

- **본 워크패킷에서 백필하지 않는다.** DDL만 적용하고 전 행 `NULL`로 둔다.
- 이유: 1호점의 실제 사업자번호가 미확정이고, 시드 행(`YOONSUL_TEST`)을 실운영 company와 연결할지 여부가
  아직 결정되지 않았다(Human: "아직 없음/미확정").
- 백필은 실제 company 행이 생성되는 시점(후속 워크패킷)에 수행한다. 그때
  `company_id IS NULL`인 store를 찾아 연결하며, `business_number`는 계속 `NULL`이어도 무방하다(§2.1.1).

### §4.2 `NOT NULL` 승격 조건

`stores.company_id`를 `NOT NULL`로 승격하는 것은 **모든 라이브 store 행이 company에 연결된 이후**에만 가능하다.
0-A에서는 승격하지 않는다. 승격 판정은 0단계 종료 판정(6단계)에서 다룬다.

## §5 ⚠️ 후속 워크패킷으로 승계되는 위험 (601502 §4.2 대응)

`tenant_status` 컬럼이 **존재하지 않는 현재**, 이를 참조하는 아래 쿼리들은 실행 시 **오류로 실패**하고 있다:

| 파일 | 위치 | 성격 |
|---|---|---|
| `0120_create_reconciliation_pipeline.sql` | L898, L916, L926 | **`pg_cron_jobs.sql_command` 내부 `$sql$` 문자열** — 컴파일 검증이 되지 않는다 |
| `0123_create_ai_customer_center_v2.sql` | L636 | `WHERE t.tenant_status = 'ACTIVE'` |
| `0129_create_launch_readiness_package.sql` | L885 | `WHERE t.tenant_status = 'ACTIVE'` |

본 워크패킷이 컬럼을 추가하면:

1. 이 쿼리들이 **오류 없이 성공하기 시작**한다 → "명시적 실패"가 "조용한 0행 처리"로 바뀐다(`default 'TRIAL'`이므로 매칭 0건).
2. 이후 누군가 tenant를 `ACTIVE`로 승격하는 순간, 대사/감사패킷 배치가 **예고 없이 실제로 동작**한다.
3. 2컬럼 분리로 `ACTIVE`+`ISOLATED` 상태가 표현 가능해지므로, 이 필터들은 **격리된 테넌트까지 포함**하게 된다.

**필수 승계 사항 — 0-A-2 워크패킷**:

- 위 6개 지점(0120 ×3, 0123 ×1, 0129 ×1, 그리고 0112 L533의 SELECT)의 필터를
  `tenant_status = 'ACTIVE' AND isolation_state = 'NONE'`으로 보강한다.
- **0120은 문자열 내부**이므로 `pg_cron_jobs` 행의 `sql_command` 값 자체를 수정해야 한다 —
  함수 재작성만으로는 반영되지 않는다.
- **순서 강제**: 어떤 tenant를 `tenant_status='ACTIVE'`로 승격하기 **전에** 0-A-2가 완료돼야 한다.

## §6 Open Items

| # | 항목 | 소관 |
|---|---|---|
| (a) | `is_active` vs `tenant_status` 진실원천 정리 | 0-A-2 (§2.4.2) |
| (b) | 신규 3개 테이블 RLS 정책식(조인 기반) 확정 및 성능 검증 | 0-C (`601501` §2.3) |
| (c) | 사업자번호 중복 오류의 존재탐지 오라클 차단(메시지 일반화) | 0-C / RPC 워크패킷 (§2.1.1) |
| (d) | `owners` 중복 등록 방지 절차(제약 아닌 절차로) | 0-C (§2.2.1) |
| (e) | `business_number` `NOT NULL` 승격 시점 | 실제 번호 확정 후 |
| (f) | `stores.company_id` `NOT NULL` 승격 | 0단계 종료 판정 (§4.2) |
| (g) | `store_groups` `DISTRICT` 도입 | 판정조건 `601501` §0.3 |
| (h) | `franchise_brands`의 사업자축 중첩 필드(`hq_contact_*`, `contract_*`) 해소 | 브랜드 나선 (`601501` §0.2) |
| (i) | `stores.extra_metadata` / `stores.brand_id` | 후속/브랜드 나선 (`601501` §3.4, §3.6) |

## §7 근거 문서 목록 (§46)

`601502_Overview` §6의 근거 목록을 그대로 승계하며, 본 Logic이 **직접 인용한** 항목은 다음과 같다:

| 파일 | 인용 지점 | 용도 |
|---|---|---|
| `000701` §46 / §47.1 / §47.2 / §48 / §49.2 | — | 근거목록 의무, 나선 단계, 가드레일, 증거수집 D단계, `ADD COLUMN` 선행순서(§3) |
| `601501_ERD_Tenant_Company_HQ_Store.md` (v2) | §0.2, §0.3, §2.3, §2.4, §3.3, §3.5 | 축 정의, 유니크 판정, RLS, B-1 근거 |
| `0002_create_hq_tenant_store.sql` | L8–24, L21–23, L43–76, L60 | `tenants`/`stores` 원형, `chk_tenants_plan`, `uq_stores_tenant_code` |
| `0021_enable_rls.sql` | 전체 | deny-by-default 패턴(§2.6) |
| `0034_seed_data.sql` | L24–25, L52–55 | 시드 tenant/store — §2.4.3, §4.1 근거 |
| `0077_create_multistore_rpc.sql` | L25–78, L126–155 | `store_groups` 재사용 확인 |
| `0082_create_saas_billing_rpc.sql` | L429, L479–483 | `provision_tenant` phantom |
| `0085_create_franchise_os_foundation_rpc.sql` | L123–160 | `franchise_brands` — **미변경**, 축 구분 |
| `0090_create_multitenant_isolation_rpc.sql` | L1283–1286, L1293–1295 | `isolate_tenant` 덮어쓰기 — §2.4.1 계약의 근거 |
| `0112_create_hq_admin_rpc.sql` | L373–384, L456–458, L533, L592–606 | 상호 파괴, `onboard_tenant` 4개 결함 |
| `0120_create_reconciliation_pipeline.sql` | L898, L916, L926 | `sql_command` 문자열 내부 필터 — §5 |
| `0123_create_ai_customer_center_v2.sql` | L636 | 필터 — §5 |
| `0129_create_launch_readiness_package.sql` | L885 | 필터 — §5 |
| `0060_create_franchise_hq_rpc.sql` | L235, L946 | `extra_metadata` — Open Item (i) |

## Module Domain Tags

`hq`, `tenant`, `store`, `company`, `owner`, `rls`, `ddl`

## Snapshot Decision

본 Logic은 DDL 설계까지만 확정한다. RPC 동작 계약(§2.4.1)은 **후속 워크패킷이 지켜야 할 약속으로 기록**한 것이며,
본 워크패킷의 구현 범위가 아니다. 이 경계를 넘는 구현은 4단계 Human 승인 없이 진행할 수 없다.
