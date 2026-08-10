# 601503_Logic_Operational_Authority_Foundation_Ddl.md

Status: Draft (v5)
Lifecycle: Logic
Stage: 4 (설계문서 정합화 — `000701` §47.1 6단계 나선의 4단계)
Domain: Operational Authority Foundation (0단계 / 하위 나선 0-A)
Last Updated: 2026-08-09

## Change ID

`operational_authority_foundation_ddl`

## 개정 이력

| 버전 | 변경 |
|---|---|
| v2 | 최초 Logic (`companies`/`owner_companies` 기준) |
| v3 | LegalEntity 중심 모델 전면 재작성 + AV 7개 반영 |
| **v4** | **§2.7 접근제어 전면 재작성**(GRANT+PostgREST가 실제 차단자), **§2.5 대표권 별도 테이블**, CRN 정규화(A-6), NOT NULL 승격 앞당김(A-8), PG 17.6 반영(A-9), cron 실측·`is_registered` 역논리(A-1) |
| **v5** | **Stage 11B BLOCK 4개 조건 반영** — **§2.9 `0169` 마이그레이션 초안 신설**(전용 owner role + SOLE 부분 UNIQUE), **§9 `SECURITY DEFINER` 작성 규칙 신설**(0-C 필수), CI 검증 체크리스트, Open Item 8건 추가 |

> 본 문서는 **설계**다. `.sql` 파일은 5단계(Codex 구현)에서 작성한다.
> 아래 코드블록은 설계 의도를 고정하기 위한 **의사 DDL**이며, 그대로 복사 실행을 전제하지 않는다.

## §1 설계 원칙 4가지

1. **가법적 변경만** — 기존 컬럼/제약을 삭제하거나 의미를 바꾸지 않는다.
2. **DDL과 로직의 분리** — `CREATE OR REPLACE FUNCTION`을 **일절 포함하지 않는다**.
3. **직교하는 축은 직교하는 컬럼으로** — 한 컬럼이 두 개의 독립된 사실을 표현하면 반드시 상호 파괴가 발생한다.
4. **하나의 사실은 한 곳에만** — Store의 법적 주체는 `legal_entity_id` 하나. 법적 대표권은 `legal_entity_representatives`의 행 존재 하나.
   **제약(CHECK)으로 봉합해야 하는 모순은 애초에 표현 가능해선 안 된다** — v4가 대표권 구조를 바꾼 이유다.

## §2 대상별 설계

### §2.1 `catchmenu_hq.legal_entities` (신규)

```sql
-- 의사 DDL (설계 표현용)
create table if not exists catchmenu_hq.legal_entities (
  id           uuid primary key default gen_random_uuid(),
  entity_type  text not null,
  legal_name   text not null,

  -- 사업자등록번호: 표기 보존 + 정규화 생성컬럼 (§2.2)
  business_registration_number text,
  brn_normalized text
    generated always as (
      nullif(
        regexp_replace(
          coalesce(business_registration_number, ''), '[^0-9]', '', 'g'
        ),
        ''
      )
    ) stored,

  -- 법인등기번호: 동일 방식 (A-6, v4 신규)
  corporate_registration_number text,
  crn_normalized text
    generated always as (
      nullif(
        regexp_replace(
          coalesce(corporate_registration_number, ''), '[^0-9]', '', 'g'
        ),
        ''
      )
    ) stored,

  tax_id       text,                    -- UNIQUE 걸지 않음 (§2.1.1)
  status       text not null default 'ACTIVE',

  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  -- CHECK는 CREATE TABLE 내부 인라인 (§6.1 멱등성)
  constraint chk_legal_entities_entity_type check (
    entity_type in (
      'SOLE_PROPRIETOR', 'CORPORATION', 'PARTNERSHIP', 'NON_PROFIT'
    )
  ),
  constraint chk_legal_entities_status check (
    status in ('ACTIVE', 'SUSPENDED', 'CLOSED')
  ),
  -- 개인사업자는 법인등기번호를 가질 수 없다 (역방향만 강제 — §2.1.2)
  constraint chk_legal_entities_crn_not_for_sole check (
    entity_type <> 'SOLE_PROPRIETOR'
    or corporate_registration_number is null
  )
);

create unique index if not exists uq_legal_entities_brn_normalized
  on catchmenu_hq.legal_entities (brn_normalized)
  where brn_normalized is not null;

create unique index if not exists uq_legal_entities_crn_normalized
  on catchmenu_hq.legal_entities (crn_normalized)
  where crn_normalized is not null;
```

#### §2.1.1 컬럼별 판단 근거

- **`status`**: 사업자 **자체**의 상태(정상/휴업/폐업)다. `tenants.tenant_status`(구독)와도 `stores.store_status`(영업)와도 **별개 축**이다(원칙 3).
- **`tax_id`**: 국내에서는 사업자등록번호가 사실상 납세자번호이므로 값이 중복될 수 있다. 유일성을 걸면 정상 케이스를 거부한다 → **UNIQUE 없음**.
- **자릿수 형식 CHECK 없음**: `^[0-9]{10}$` 같은 CHECK는 0-A에서 걸지 않는다. 실제 번호가 미확정이고 비국내/특수 케이스를 판정하지 않았다(§7 (d)).

#### §2.1.2 `CORPORATION`에 CRN을 요구하지 않는다 (A-7)

**판단**: `entity_type='CORPORATION'`이어도 `corporate_registration_number`를 **NOT NULL로 강제하지 않는다.**
법인 설립 등기 전이거나 번호를 아직 확보하지 못한 시점에도 `legal_entities` 행을 만들 수 있어야 하며,
이는 `business_registration_number`를 nullable로 둔 것과 **같은 이유·같은 원칙**이다 —
제약이 업무 절차를 앞질러 막지 않도록 한다. **역방향 금지(개인사업자는 CRN 불가)만 강제**한다.

#### §2.2 등록번호 정규화 — BRN·CRN 동일 방식 (A-6)

**문제**: `123-45-67890` / `1234567890` / `123 45 67890`은 같은 번호지만 문자열로는 다르다.
raw 컬럼에 UNIQUE를 걸면 **표기만 다른 중복 등록이 통과**한다.

**`nullif(..., '')`이 설계의 핵심이다.** 없으면 원본이 NULL인 행들이 전부 `''`로 정규화되어 **서로 충돌**한다
→ 번호 미확정 사업주체를 2건 이상 만들 수 없게 된다. v2에서 "placeholder가 UNIQUE 슬롯을 점유한다"며 배제했던
함정이 정규화 도입과 함께 **다른 얼굴로 재등장**하는 지점이다.

**v3 → v4 변경(A-6)**: v3는 CRN에 정규화를 적용하지 않고 raw 컬럼에 부분 UNIQUE를 걸었다.
이는 **BRN에서 이미 해결한 문제를 CRN에 그대로 남겨두는 것**이므로 동일 방식으로 통일했다.
raw 컬럼은 두 번호 모두 입력 표기 그대로 보존한다(대외 문서 표기 일치 목적).

**생성컬럼 요건**: `regexp_replace`/`coalesce`/`nullif`는 전부 `IMMUTABLE`이므로 `STORED` 생성컬럼에 사용 가능하다.

### §2.3 `catchmenu_hq.owners` (신규)

```sql
create table if not exists catchmenu_hq.owners (
  id                  uuid primary key default gen_random_uuid(),
  owner_name          text not null,
  contact_phone_hash  text,           -- UNIQUE 없음 (§2.3.1)
  contact_email       text,
  is_active           boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
```

#### §2.3.1 유니크를 걸지 않는 판정

동명이인·번호 공유(가족/법인 대표번호)·번호 변경이 전부 정상 시나리오다. 전역 유니크는 이 정상 케이스를
DB 레벨에서 거부하고 **존재탐지 오라클**을 만든다. 중복 방지는 "DB가 물리적으로 막을 문제"가 아니라
"등록 절차가 판단할 문제"다 → 0-C 이월.

### §2.4 `catchmenu_hq.legal_entity_person_roles` (신규 — 대표권 컬럼 제거됨)

```sql
create table if not exists catchmenu_hq.legal_entity_person_roles (
  id               uuid primary key default gen_random_uuid(),
  legal_entity_id  uuid not null references catchmenu_hq.legal_entities(id),
  owner_id         uuid not null references catchmenu_hq.owners(id),
  role_type        text not null,

  ownership_percent numeric(5,2),

  effective_from   date not null default current_date,
  effective_to     date,
  is_active        boolean not null default true,

  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),

  constraint chk_lepr_role_type check (
    role_type in (
      'OWNER', 'REPRESENTATIVE', 'DIRECTOR', 'EXECUTIVE', 'INVESTOR'
    )
  ),
  constraint chk_lepr_ownership_percent check (
    ownership_percent is null
    or (ownership_percent >= 0 and ownership_percent <= 100)
  ),
  constraint chk_lepr_effective_range check (
    effective_to is null or effective_to >= effective_from
  )
);

create unique index if not exists uq_lepr_active
  on catchmenu_hq.legal_entity_person_roles (legal_entity_id, owner_id, role_type)
  where is_active = true;

create index if not exists idx_lepr_owner
  on catchmenu_hq.legal_entity_person_roles (owner_id) where is_active = true;
create index if not exists idx_lepr_legal_entity
  on catchmenu_hq.legal_entity_person_roles (legal_entity_id) where is_active = true;
```

> **v3에 있었으나 v4에서 제거된 것**: `is_legal_representative`, `representation_mode`,
> `chk_lepr_representative_consistency`. 전부 §2.5의 `legal_entity_representatives`로 이관됐다.

#### §2.4.1 재부여 가능성 — 부분 UNIQUE

전체 UNIQUE `(legal_entity_id, owner_id, role_type)`를 걸면 역할을 종료(`is_active=false`)한 뒤
**같은 역할을 다시 부여할 수 없다**(종료 이력 행이 슬롯을 영구 점유).
`WHERE is_active = true` 부분 인덱스는 **동시에 활성인 (법인, 사람, 역할) 조합이 최대 1건**만 강제하고
종료 이력은 여러 건 남게 한다 → 재부여 가능 + 이력 보존.
`role_type`이 키에 포함되므로 같은 사람이 같은 법인에서 OWNER와 DIRECTOR를 동시 보유할 수 있다(정상).

#### §2.4.2 행 CHECK로 막을 수 없는 것

`ownership_percent`의 **법인별 합계 ≤ 100**은 여러 행에 걸친 조건이라 행 CHECK로 표현 불가하다.
RPC/트리거 소관이며 0-A 범위 밖(§7 (e)). 기록하지 않으면 "CHECK가 있으니 지분도 검증된다"는 잘못된 안심이 생긴다.

### §2.5 `catchmenu_hq.legal_entity_representatives` (신규 — B-2, v4 핵심 변경)

**법적 대표권의 유일한 진실원천.**

```sql
create table if not exists catchmenu_hq.legal_entity_representatives (
  id                   uuid primary key default gen_random_uuid(),
  legal_entity_id      uuid not null references catchmenu_hq.legal_entities(id),
  owner_id             uuid not null references catchmenu_hq.owners(id),
  representation_mode  text not null,

  effective_from       date not null default current_date,
  effective_to         date,
  is_active            boolean not null default true,

  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),

  constraint chk_ler_representation_mode check (
    representation_mode in ('SOLE', 'JOINT', 'INDIVIDUAL')
  ),
  constraint chk_ler_effective_range check (
    effective_to is null or effective_to >= effective_from
  )
);

create unique index if not exists uq_ler_active
  on catchmenu_hq.legal_entity_representatives (legal_entity_id, owner_id)
  where is_active = true;

create index if not exists idx_ler_legal_entity
  on catchmenu_hq.legal_entity_representatives (legal_entity_id) where is_active = true;
```

#### §2.5.1 왜 별도 테이블인가 — v3 설계의 결함

v3는 대표권을 `legal_entity_person_roles`의 **두 컬럼**(`is_legal_representative` boolean + `representation_mode`)으로
표현하고 둘의 모순을 CHECK로 막았다. 문제:

- **하나의 사실이 두 컬럼에 분산**돼 있었다. **CHECK가 필요했다는 것 자체가 구조 결함의 신호**다(원칙 4).
- `representation_mode='NONE'`이라는 **"대표가 아님"을 뜻하는 값**이 대표방식 도메인에 섞여 있었다.
  대표방식이라는 개념에 "대표 아님"은 속하지 않는다.
- 대표권 고유의 유효기간을 역할의 유효기간과 **같은 행에서 공유**해야 했다 —
  대표권만 종료하고 이사 역할은 유지하는 정상 시나리오를 표현할 수 없었다.

**v4 판정**: "법적 대표인가"는 **이 테이블에 활성 행이 존재하는지로만** 판정한다.
`representation_mode`는 행이 존재할 때만 의미를 갖는 순수한 대표방식 값이 되어 `'NONE'`이 사라졌고,
정합성 CHECK 자체가 불필요해졌다.

의미: `SOLE`=단독대표, `JOINT`=공동대표(2인 이상 공동 행사), `INDIVIDUAL`=각자대표(각자 단독 행사).

#### §2.5.2 이 테이블도 막지 못하는 것 (A-4 — 반드시 기록)

분리로 **v3의 구조적 결함(한 행 내부의 모순)은 해소됐으나**, 다음 **행 사이의 모순**은 여전히 행 CHECK로 막을 수 없다:

| 막지 못하는 모순 | 이유 |
|---|---|
| **같은 법인에 `SOLE`(단독대표) 2명 이상** | 여러 행에 걸친 조건 — 행 CHECK는 다른 행을 볼 수 없다 |
| `SOLE`과 `JOINT`가 같은 법인에 혼재 | 동상 |
| 대표가 **0명인 법인** | 존재하지 않는 행은 CHECK로 검사 불가 |

→ **§7 (c)** 로 기록, 트리거/RPC 소관. **"테이블을 분리했으니 대표권 정합성이 보장된다"는 잘못된 안심을 막기 위해
반드시 남겨둔다.** 분리가 해결한 것은 *행 내부*의 모순이고 *행 사이*의 모순은 그대로다.

#### §2.5.3 `is_active` ↔ `effective_to` 이중 진실원천 (A-5)

`legal_entity_person_roles`와 `legal_entity_representatives` **양쪽 모두** 종료 상태를 두 가지로 표현할 수 있다:
`is_active = false` **또는** `effective_to < current_date`. 둘이 어긋나면 어느 쪽이 진실인지 판정 불가다 —
**원칙 4 위반이 두 신규 테이블에 남아 있는 셈**이다.

0-A에서 즉시 해소하지 않는 이유: 부분 UNIQUE 인덱스가 `WHERE is_active = true`에 의존하는데,
날짜 기반 술어(`effective_to is null or effective_to >= current_date`)는 **`current_date`가 STABLE이라
인덱스 술어로 사용할 수 없다**. `is_active`를 제거하려면 유일성 보장 방식 자체를 재설계해야 한다
(`EXCLUDE` 배타 제약 + `daterange` 등).

**0-A 잠정 계약**: `is_active`를 **유일성 판정의 진실원천**으로, `effective_from`/`to`는 **이력 기록용**으로 둔다.
둘의 동기화는 RPC 책임이다. 근본 해소는 §7 (b)로 이월.

### §2.6 `catchmenu_hq.tenants` — 컬럼 2개 추가

```sql
alter table catchmenu_hq.tenants
  add column if not exists tenant_status text not null default 'TRIAL';

alter table catchmenu_hq.tenants
  add column if not exists isolation_state text not null default 'NONE';

-- CHECK 추가는 IF NOT EXISTS가 없다 → 가드 필요 (§6.2)
```

| 컬럼 | 축 | 단독 기록자(후속) |
|---|---|---|
| `tenant_status` | 구독 — `('ACTIVE','TRIAL','SUSPENDED','CANCELLED','TERMINATED')` | `manage_subscription()` **만** |
| `isolation_state` | 격리 — `('NONE','ISOLATED')` | `isolate_tenant()` **만** |

**CHECK 값의 실증 근거**: 0112가 이미 `'ACTIVE'`(L102,160,611,904)/`'TRIAL'`(L105,831)/`'SUSPENDED'`(L108,595,828)/
`'CANCELLED'`(L625,823)를 실제 사용한다 — 5값 중 4값은 기존 코드에서 역산됐다. `'TERMINATED'`만 `tenants` 맥락
사용처가 **없다**(0053/0074/0076/0085의 것은 staff/pos/franchise 맥락) → **전방 호환용 신규 값**임을 명시한다.
5단계 검증자가 "쓰이지 않는 값"을 결함으로 오인하지 않도록 하기 위함이다.

**후속 RPC 계약(구현 아님)**:
- `isolate_tenant()`는 **`isolation_state`만** 변경. `tenant_status`는 읽지도 쓰지도 않는다.
- **격리 해제 시 `tenant_status`를 `'ACTIVE'`로 자동 복구하지 않는다**(0090 L1283–1286의 동작 폐기).
- `manage_subscription()`은 **`tenant_status`만** 변경.

**`is_active` / `default 'TRIAL'`**: 기존 `tenants.is_active`는 건드리지 않는다(가법 원칙).
진실원천 정리는 0-A-2 과제(§7 (a)). `default 'ACTIVE'`로 두면 §5의 배치들이 즉시 실제 대상으로 인식하므로
`'TRIAL'`로 두어 활성화를 **명시적 승격 행위**로 미룬다.

### §2.7 `catchmenu_hq.stores.legal_entity_id` — 컬럼 1개 추가

```sql
alter table catchmenu_hq.stores
  add column if not exists legal_entity_id uuid;

-- FK 추가도 IF NOT EXISTS 없음 → 가드 필요 (§6.2)

create index if not exists idx_stores_legal_entity_id
  on catchmenu_hq.stores (legal_entity_id)
  where legal_entity_id is not null;
```

- **nullable로 둔다** — 기존 라이브 행 보존. NOT NULL 승격 판정은 §4.3.
- **두 갈래 FK 금지(원칙 4)**: `company_id`/`owner_id`를 따로 두지 않는다.
- **`uq_stores_tenant_code`는 tenant 단위 그대로 유지**한다 — `legal_entity_id`를 유니크 키에 넣지 않는다.
- 인덱스는 0-C 조인 정책의 **성능 전제**다.

### §2.8 접근제어 — 실제 차단 계층 (B-1, v4 전면 재작성)

> **⚠️ v3 §2.7 서술 폐기**: v3는 "0021 패턴과 동일한 deny-by-default"라며 **RLS를 차단 메커니즘으로 지목**했다.
> 2차 검증 결과 **차단 계층을 잘못 짚은 것**이다.

#### §2.8.1 실제 차단자는 GRANT + PostgREST 노출 제한

| 계층 | 실제 상태 | 근거 |
|---|---|---|
| **① PostgREST 노출 스키마** | `catchmenu_hq` **미노출** | `supabase/config.toml` `[api] schemas = ["public","graphql_public"]` |
| **② GRANT (테이블 권한)** | `catchmenu_hq` **16개 테이블 전부 테이블권한 GRANT 0건** | migration 전수 검색 결과 `grant ... on ... catchmenu_hq.<table>` **0건** |
| ③ RLS | enable/force되어 있으나 **①②에 도달조차 못 하므로 실질 차단자가 아님** | — |

- **`service_role`**: `BYPASSRLS = true`이나 **`catchmenu_hq` 스키마 USAGE 자체가 없다**
  (0022 L614–623의 `grant usage on schema` 대상은 `authenticated`뿐) → RLS를 우회할 수 있어도 **스키마에 진입 불가**.
- **`authenticated`**: 스키마 USAGE는 있으나(0022 L615) **테이블 권한이 없다** → 접근 불가.

**RLS가 없더라도 이 테이블들은 이미 접근 불가**다. RLS는 3차 방어선이지 1차 차단자가 아니다.

#### §2.8.2 "0021 패턴과 동일" 서술 삭제 — 이 저장소 최초 사례

0021은 `enable`+`force`를 걸고 **0022가 그 테이블들에 정책을 붙이는 짝**으로 설계돼 있다.
0021 단독이 "정책 0개" 상태로 남는 구조가 아니다.

**본 워크패킷의 신규 4개 테이블은 이 저장소에서 최초로 "force RLS + 정책 0개"로 남는 사례다.**
선례가 없으므로 "기존 패턴을 따랐다"고 서술할 수 없으며, **의도된 신규 설계 결정**으로 명시한다.

```sql
alter table catchmenu_hq.owners                        enable row level security;
alter table catchmenu_hq.owners                        force  row level security;
alter table catchmenu_hq.legal_entities                enable row level security;
alter table catchmenu_hq.legal_entities                force  row level security;
alter table catchmenu_hq.legal_entity_person_roles     enable row level security;
alter table catchmenu_hq.legal_entity_person_roles     force  row level security;
alter table catchmenu_hq.legal_entity_representatives  enable row level security;
alter table catchmenu_hq.legal_entity_representatives  force  row level security;
-- 정책(policy) 생성 없음 / GRANT 부여 없음 (§2.8.3)
```

#### §2.8.3 명시적 설계 결정 — 신규 4테이블에 GRANT를 주지 않는다

**결정**: `owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives`에
`authenticated`·`service_role` 어느 역할에도 **테이블 권한을 부여하지 않는다.**

근거: 0-A는 **구조 확정**까지이고 이 테이블들을 읽고 쓰는 RPC는 후속 워크패킷 소관이다(§47.6-1).
접근이 필요해지는 시점에 **필요한 최소 권한만** 부여하는 것이 순서다. 지금 GRANT를 주면
"쓰는 곳이 없는데 열려 있는 테이블"이 생기고, 0-C가 접근제어를 설계할 때 **이미 열린 문을 닫는 작업**부터 해야 한다.

**5단계 검증 항목**: 신규 4테이블에 GRANT가 **부여되지 않았음**을 확인할 것(있으면 결함).

#### §2.8.4 Open Item (l) — **조건부 해소** (`SECURITY DEFINER` 접근)

v3는 "`SECURITY DEFINER` 함수가 이 테이블에 접근 가능한지 미확인"으로 남기고 5단계 실행검증을 요구했다.
**조건부로 해소한다**:

`SECURITY DEFINER` 함수는 **소유자 권한**으로 실행된다. 소유자가 `postgres`이면 `postgres`는 `BYPASSRLS`를 갖고
스키마·테이블 소유자이므로 `force row level security`와 GRANT 부재에 관계없이 **정상 접근**하며,
후속 워크패킷의 RPC는 별도 조치 없이 이 테이블들을 읽고 쓸 수 있다.

**소유권의 실제 근거 상태 (직접 확인)**:

| 확인 대상 | 결과 |
|---|---|
| `sql/migrations/*.sql`의 명시적 소유자 지정(`owner to postgres`) | **0건** |
| 클라우드 백업 덤프의 `ALTER FUNCTION ... OWNER TO "postgres"` | 623건 |

**소유자를 `postgres`로 고정하는 선언이 마이그레이션 어디에도 없다.** 현재 `postgres` 소유인 것은
"마이그레이션을 `postgres`로 실행해 왔다"는 **운영 관행의 결과**일 뿐 계약이 아니다.

> **⚠️ 전제 조건 (2차 검증 지적 반영)**: 이 해소는 **"함수 소유자를 `postgres`로 유지한다"는 배포 계약**에 의존한다.
> 다음 중 하나라도 발생하면 **해소는 무효가 되고 접근이 막힌다**:
>
> - 후속 워크패킷이 RPC를 `postgres` 아닌 역할 소유로 생성/변경
> - 배포 파이프라인이 마이그레이션을 다른 역할로 실행해 그 역할이 소유자가 됨
> - Supabase 정책 변경으로 `postgres`의 `BYPASSRLS`가 사라짐
>
> **따라서 Open Item (l)은 "삭제"가 아니라 "배포 계약 항목으로 전환"한다**(§7 (o)).
> GRANT를 주지 않는 설계(§2.8.3)를 택한 이상 **소유자 전제가 이 테이블들의 유일한 접근 경로**이므로,
> 이 전제가 깨지면 조용히 "아무도 못 쓰는 테이블"이 된다.
>
> **5단계 검증 항목**: 신규 RPC 생성 시 `select proname, proowner::regrole from pg_proc where ...`로
> 소유자가 `postgres`인지 확인할 것. v3가 걸어둔 "RLS 때문에 접근 불가할 수 있다"는 검증 요구는 철회하되,
> **소유자 확인 검증으로 대체**한다.

## §2.9 ⭐ `0169` 마이그레이션 초안 (v5 신설 — Stage 11B BLOCK 조건 ①③)

> **본 절은 설계 초안이다.** 실제 `.sql` 작성은 **Codex의 Stage 8 몫**이며,
> 본 문서는 `.sql` 파일을 만들지 않는다(`601505` §1.1 원칙 유지).
> `0168`은 이미 적용됐으므로 **수정하지 않는다**(배포된 migration 불변 원칙) — 보강은 **신규 파일 `0169`** 로 한다.

**파일명(안)**: `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql`

### §2.9.1 조건 ③ — SOLE 대표 유일성 부분 UNIQUE

```sql
-- 의사 DDL
create unique index if not exists uq_ler_sole_active
  on catchmenu_hq.legal_entity_representatives (legal_entity_id)
  where representation_mode = 'SOLE' and is_active = true;
```

- `create unique index **if not exists**` → **멱등**(§6 표 기준, 별도 가드 불필요).
- 대상 테이블은 현재 **0행**이므로 기존 데이터와 충돌하지 않는다.
- 컬럼명은 실제 스키마(`representation_mode`/`is_active`)를 따른다 — `601510` 원문의
  `representation_type`/`active`는 감사자의 표기이며 실제 컬럼명이 아니다(`601501` §2.5.4).

### §2.9.2 조건 ① — 전용 NOLOGIN owner role 신설

```sql
-- 의사 DDL (role은 트랜잭션 밖 카탈로그 객체이므로 존재 여부 가드 필요)
do $ddl$
begin
  if not exists (select 1 from pg_roles where rolname = 'catchmenu_authority_owner') then
    create role catchmenu_authority_owner nologin bypassrls;   -- §2.9.3 근거
  end if;
end
$ddl$;

grant usage on schema catchmenu_hq to catchmenu_authority_owner;

grant select, insert, update, delete on
  catchmenu_hq.owners,
  catchmenu_hq.legal_entities,
  catchmenu_hq.legal_entity_person_roles,
  catchmenu_hq.legal_entity_representatives
to catchmenu_authority_owner;

-- 함수 소유권 이전에 필요한 멤버십 (postgres가 SET ROLE 할 수 있어야 ALTER FUNCTION OWNER 가능)
grant catchmenu_authority_owner to postgres;
```

> **`601505` §2.1(신규 4테이블에 GRANT 금지)과의 관계**: §2.1은 **`authenticated`/`service_role`/`anon`**
> 즉 **클라이언트 도달 가능 역할**에 대한 금지였다. `catchmenu_authority_owner`는 **NOLOGIN**이라
> 어떤 클라이언트도 이 역할이 될 수 없으므로 §2.1의 취지를 위반하지 않는다.
> 다만 계약 문언상 확장이므로 **`601505` 갱신 및 Human 재승인이 필요**하다(§2.9.4).

### §2.9.3 ⚠️ `BYPASSRLS`가 필요한 이유 — 실측 근거

**전용 role에 `BYPASSRLS`가 없으면 `SECURITY DEFINER` 함수가 오류 없이 0행을 반환한다.**

로컬 실측(2026-08-10, `legal_entities`에 행 1건 삽입 후 `authenticated`로 함수 호출, 전부 ROLLBACK):

| 함수 소유 role | 테이블 `SELECT` 권한 | 결과 |
|---|---|---|
| NOLOGIN, `BYPASSRLS` **없음** | 부여함 | **`0`** ← FORCE RLS + 정책 0개가 전량 필터 |
| NOLOGIN, `BYPASSRLS` **있음** | 부여함 | **`1`** ← 정상 |

원인은 §2.8의 설계 그 자체다 — `FORCE ROW LEVEL SECURITY` + **정책 0개**이므로
`BYPASSRLS`가 없는 역할은 소유자든 아니든 **모든 행이 걸러진다**. `postgres`가 지금 동작하는 이유도
오직 `rolbypassrls = t` 때문이다.

**보안상 평가**: `catchmenu_authority_owner`에 `BYPASSRLS`를 주는 것은 **현행보다 권한을 좁히는 변경**이다.

| | 현행(`postgres` 소유) | 0169 이후 |
|---|---|---|
| 로그인 | 가능 | **NOLOGIN** |
| 권능 범위 | DB 전역(슈퍼유저급) | **`catchmenu_hq` 4테이블 + BYPASSRLS** |
| 감사 가능성 | "관행"(마이그레이션에 선언 0건) | **migration에 명시 선언** |

**회수 경로**: 0-C가 이 역할을 위한 RLS 정책을 만들면 `BYPASSRLS`를 회수할 수 있다 → Open Item (o).

### §2.9.4 0169가 하지 **않는** 것

| 항목 | 이유 |
|---|---|
| 기존 4테이블의 **소유권 이전**(`ALTER TABLE … OWNER TO`) | 0169 범위 밖. 테이블 소유자는 `postgres` 유지, 접근은 GRANT로 부여 |
| **함수 생성 및 소유권 이전** | **0-A에는 함수가 하나도 없다**. `ALTER FUNCTION … OWNER TO`는 0-C가 함수를 만들 때 수행(§9) |
| `EXECUTE` 권한 조정 / `search_path` 고정 | 동상 — 대상 함수가 없다. **0-C 필수 규칙으로 §9에 명문화** |
| `0168` 수정 | 배포된 migration 불변 원칙 |

### §2.9.5 0169 적용 순서

1. `uq_ler_sole_active` 부분 UNIQUE 생성 (§2.9.1)
2. `catchmenu_authority_owner` role 생성 가드 (§2.9.2)
3. 스키마 USAGE + 4테이블 권한 GRANT
4. `postgres`에 역할 멤버십 부여
5. `comment on role`(선택)

§49.2의 `ADD COLUMN` 선행 규칙은 0169에 해당 사항이 없다(컬럼 추가 없음). 다만 **함수 생성보다 먼저**여야 하므로
워크패킷 간 순서는 유지된다: `0168`(DDL) → **`0169`(보안경계·불변조건)** → 0-A-2(RPC) → 0-C(함수·정책).

---

## §3 적용 순서 (§49.2)

**`ADD COLUMN`은 `CREATE OR REPLACE FUNCTION`보다 먼저** 적용돼야 한다 — PL/pgSQL은 지연 바인딩이라
함수 본문의 컬럼 참조가 **생성 시점이 아닌 실행 시점**에 해석된다. 컬럼 없이 함수를 먼저 만들면 컴파일은 통과하고
런타임에 실패한다. **현재 phantom 컬럼들이 정확히 이 상태다.**

**워크패킷 내부 순서**:

1. `legal_entities` (FK 대상이므로 최선행)
2. `owners`
3. `legal_entity_person_roles` (1, 2에 FK 의존)
4. **`legal_entity_representatives`** (1, 2에 FK 의존)
5. `tenants` 컬럼 2개 → CHECK 2개(가드 적용)
6. `stores.legal_entity_id` → FK(가드 적용) → 인덱스
7. 신규 4테이블 RLS enable/force (**GRANT 없음**)
8. `comment on` / `set_updated_at` 트리거

**워크패킷 간 순서**: 본 워크패킷(DDL) → **0-A-2**(RPC 재작성 + 배치 필터 보강 + `is_registered` 역논리 수정)
→ **0-A-3**(`onboard_tenant`/`provision_tenant` 재설계). 뒤집으면 §49.2 위반이다.

## §4 백필 및 MVP 시드 설계

### §4.1 시드 설계 (설계만 — 실제 값은 5단계)

| 대상 | 설계값 | 제약 통과 |
|---|---|---|
| Owner | 1명 (정영석) | — |
| LegalEntity | `entity_type='SOLE_PROPRIETOR'`, `legal_name`=실제 상호, `business_registration_number=NULL` | `brn_normalized`=NULL → 부분 UK 미적용 ✓ / `corporate_registration_number` **반드시 NULL**(`chk_..._crn_not_for_sole`) ✓ |
| 역할 | `legal_entity_person_roles`: `role_type='OWNER'` | `uq_lepr_active` ✓ |
| **대표권** | **`legal_entity_representatives`: `representation_mode='SOLE'` 1행** | `uq_ler_active` ✓ / v4에서 별도 행 |
| Store | 기존 store 1개에 `legal_entity_id` 설정 | FK ✓ |

`ownership_percent`는 단독 사업주이므로 `100` 또는 `NULL` — 5단계 확정.

### §4.2 백필

- **DDL 적용 시점에는 백필하지 않는다.** 전 행 `NULL`로 둔다.
- 백필은 §4.1의 `legal_entities` 행 생성 직후 수행한다(같은 5단계 내).

### §4.3 `NOT NULL` 승격 시점 — 5단계 말미로 앞당김 검토 (A-8)

v3는 승격을 "0단계 종료 판정"으로 미뤘다. v4는 **5단계 말미(시드 1건 생성 직후)로 앞당기는 것을 검토**한다.

| 앞당기기 유리 | 신중해야 할 이유 |
|---|---|
| 라이브 `stores` 행이 사실상 시드 1건뿐 → 그 1건을 채우면 **즉시 전 행이 조건 만족**. **가장 쉬운 시점이 지금**이다 | NOT NULL 승격은 **가법적이지 않다** — `stores`에 INSERT하는 기존 RPC가 이 컬럼을 채우지 않으면 즉시 실패 |
| 미루면 그 사이 `legal_entity_id=NULL`인 store가 추가로 생겨 승격이 더 어려워질 수 있다 | 따라서 **`stores` INSERT 경로 전수 조사가 선행**돼야 한다 |

→ **판정 자체를 5단계 말미로 이관**하되, 그 시점에 위 두 근거를 대조해 결정한다(§7 (h)).

**FK 검사와 RLS의 관계 기록(A-8)**: `stores.legal_entity_id`의 FK 무결성 검사는 **RLS가 적용되지 않는다**
(PostgreSQL의 참조 무결성 검사는 시스템 내부에서 수행되어 RLS 정책을 우회한다).
따라서 `legal_entities`가 접근 차단 상태여도 **FK는 정상 작동**한다.
역으로 이는 **FK 존재 자체가 정보 노출 경로**가 될 수 있음을 뜻한다(존재하지 않는 id로 INSERT 시 FK 위반 오류로
"그 id는 없다"가 드러남) → 0-C 오류 메시지 설계 시 함께 고려할 것.

## §5 ⚠️ 후속 워크패킷 승계 위험 (A-1 실측 반영)

### §5.1 파일 정의상 영향 지점 (Claude Code 직접 확인)

`tenant_status`가 없는 현재 아래는 **실행 시 오류로 실패**한다. 컬럼 추가 후 **오류 없이 0행 반환**으로 바뀐다.

| 파일 | 지점 | 종류 |
|---|---|---|
| `0120` | L898, L916, L926 | `pg_cron_jobs.sql_command` 내부 `$sql$` (LAYER1/LAYER2) |
| `0129` | L873–885 | 동상 (`HOURLY_METRICS`) |
| `0123` | L636 | 함수·뷰 내부 필터 |
| `0129` | L885 | 함수·뷰 내부 필터 |
| `0112` | 21개 지점 | UPDATE 3(L595/611/625), 집계 6, 필터 4, 출력 6, **공개 파라미터 1(L248)** |

> **⚠️ 카탈로그 불일치(A-1 실측)**: 로컬 `pg_cron_jobs`의 **0120 행 내용이 migration 파일과 다르다**.
> 즉 위 표의 **파일 라인번호가 라이브 카탈로그 값을 보장하지 않는다.**
> 0-A-2는 파일뿐 아니라 **카탈로그 행의 실제 값을 직접 읽고** 수정해야 한다.

### §5.2 cron 실측 — 로컬 확인 완료 / 클라우드 미확인 (A-1)

2차 검증의 로컬 DB 실측 결과(실행 중인 로컬 DB에서 재확인):

| 측정 | 값 |
|---|---|
| `pg_cron_jobs` 총 행수 | **47행** |
| 그중 `is_registered = true` | **38행** |
| 그 38행 중 `pg_cron_job_id IS NULL` | **38행 전부** |
| `cron.job` 행수 | **0행** |

`is_registered = true`인 38행이 **전부 `pg_cron_job_id IS NULL`** 이라는 것이 결정적이다 —
`pg_cron_job_id`는 등록 함수가 `cron.schedule()`의 반환값으로만 채우는 컬럼이므로(0072 L219–230),
NULL이라는 것은 **그 행에 대해 `cron.schedule()`이 단 한 번도 호출된 적이 없다**는 직접 증거다.
`cron.job` 0행과 정확히 일치하며, §5.3의 역논리 설명을 데이터로 확증한다.

- `pg_cron_jobs` 카탈로그의 0120 행이 migration 파일과 불일치(§5.1).

> **범위 한정**: 위는 **로컬 DB 실측**이며 **클라우드(운영) DB는 미확인**이다(§7 (m)).
> §48의 원칙대로 로컬 결과를 클라우드로 일반화하지 않는다.

### §5.3 `is_registered` 역논리 결함 — v4 신규 발견

등록 함수는 `where is_registered = false`인 행만 순회해 `cron.schedule`을 호출하고 성공 시 `is_registered = true`로
갱신한다([0072](sql/migrations/0072_create_pg_cron_schedules.sql) L201–206, L226–230).
그런데 **0120/0129의 시드 INSERT는 처음부터 `is_registered = true`로 행을 넣는다.**

결과: 이 행들은 **등록 루프가 영원히 집어가지 않는다** — 카탈로그는 "등록됨"이라 주장하지만 `cron.schedule`은
한 번도 호출된 적이 없다. **§5.2의 `cron.job` 0행과 정확히 일치하는 설명**이다.
`is_registered`는 실제로 "등록 여부"가 아니라 **"등록 시도 제외 플래그"** 로 동작하며 이름과 의미가 반대다.

→ **0-A-2 승계 신규 항목**(§7 (n)). 본 워크패킷 범위 밖(DDL 아님).

### §5.4 2컬럼 분리가 추가로 만드는 문제

분리 후 `ACTIVE`+`ISOLATED`가 표현 가능해지므로 `WHERE tenant_status='ACTIVE'` 필터는
**격리된 테넌트까지 포함**하게 된다 → `AND isolation_state='NONE'` 보강 필요.

### §5.5 0-A-2 필수 승계 항목

1. §5.1의 모든 지점에 `AND isolation_state='NONE'` 보강.
2. **`0120`/`0129`는 문자열 내부**이므로 `pg_cron_jobs` 행의 `sql_command` **값 자체를 수정**해야 한다 —
   함수 재작성만으로는 반영되지 않는다. **카탈로그 실제 값을 먼저 읽을 것**(§5.1 불일치).
3. **`is_registered` 역논리 결함 수정**(§5.3) — 시드가 `false`로 들어가거나, 컬럼 의미를 재정의해야 한다.
4. **`0112` L248 `p_tenant_status` 공개 파라미터**: "격리 상태로도 필터링할 것인가"는 **API 시그니처 결정**이다.
5. **`0112` 집계 6곳**: "격리된 ACTIVE 테넌트"를 어느 칸에 셀지 정의하지 않으면 **대시보드 합계가 맞지 않는다**.
6. **순서 강제**: 어떤 tenant를 `tenant_status='ACTIVE'`로 승격하기 **전에** 0-A-2가 완료돼야 한다.

## §6 의사 DDL 멱등성

**`IF NOT EXISTS`가 없는 구문이 실제 함정**이다.

| 구문 | `IF NOT EXISTS` | 처리 |
|---|---|---|
| `create table` | ✓ | `if not exists` |
| `alter table ... add column` | ✓ | `if not exists` |
| `create index` / `create unique index` | ✓ | `if not exists` |
| **`add constraint` (CHECK)** | **✗** | **가드 필요(§6.2)** |
| **`add constraint` (FK)** | **✗** | **가드 필요(§6.2)** |
| `enable/force row level security` | 해당없음 | 반복 실행 무해 |
| `create trigger` | ✗ | `drop trigger if exists` 선행(저장소 관행) |
| `comment on` | 해당없음 | 멱등 |

### §6.1 전략 1 — 신규 테이블의 CHECK는 `CREATE TABLE` 내부 인라인

`create table if not exists` 안에 `constraint ... check (...)`를 넣으면 테이블 생성이 건너뛰어질 때
제약도 함께 건너뛰어진다 → **자동 멱등**. §2.1/§2.4/§2.5의 의사 DDL이 이 형태다.
신규 테이블의 CHECK를 별도 `ALTER TABLE ADD CONSTRAINT`로 빼지 **않는다**.

### §6.2 전략 2 — 기존 테이블 대상 제약은 `pg_constraint` 가드

`tenants`의 CHECK 2개와 `stores`의 FK 1개는 기존 테이블 대상이라 인라인이 불가하다.

```sql
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'chk_tenants_status'
      and conrelid = 'catchmenu_hq.tenants'::regclass
  ) then
    alter table catchmenu_hq.tenants
      add constraint chk_tenants_status check (
        tenant_status in (
          'ACTIVE','TRIAL','SUSPENDED','CANCELLED','TERMINATED'
        )
      );
  end if;
end $$;
```

`chk_tenants_isolation_state`, `fk_stores_legal_entity_id`도 동일 패턴으로 감싼다.

**`drop constraint if exists` + `add constraint` 대안을 쓰지 않는 이유**: 그 방식도 멱등이지만
재실행마다 제약을 떨어뜨렸다 다시 붙이며 **전체 행을 재검증**한다. 지금은 행이 적어 무해하나
운영 데이터가 쌓인 뒤 재실행하면 **락과 재검증 비용이 커진다**. `pg_constraint` 가드는 이미 있으면 아무 것도 하지 않는다.

### §6.3 생성컬럼 재실행 — PostgreSQL 17.6 반영 (A-9)

`brn_normalized`/`crn_normalized`는 `create table` 내부 정의이므로 §6.1로 커버된다.

**v3 서술 완화(A-9)**: v3는 "이미 생성된 테이블의 생성컬럼 정의는 변경 불가하므로 정규화 표현식을
5단계 착수 전에 **반드시** 확정해야 한다"고 썼다. **로컬 환경이 PostgreSQL 17.6으로 확인**됐고,
`ALTER TABLE ... ALTER COLUMN ... SET EXPRESSION`은 **PostgreSQL 17부터 지원**되므로
**정규화 표현식을 사후 변경할 경로가 실재한다.**

→ Open Item (d)의 **긴급도를 "5단계 착수 전 필수"에서 "권장"으로 하향**한다.
다만 `SET EXPRESSION`은 **테이블 재작성(rewrite)을 유발**하므로 운영 데이터가 쌓인 뒤에는 여전히 비싸다.
가능하면 5단계 착수 전에 확정하는 편이 낫다는 판단 자체는 유지한다.

> **범위 한정**: PostgreSQL 17.6은 **로컬 확인**이다. 클라우드(Supabase) 버전이 17 미만이면 이 경로는 없다 —
> 클라우드 버전 확인이 필요하다(§7 (m)에 포함).

## §7 Open Items

| # | 항목 | 소관 | v4 변동 |
|---|---|---|---|
| (a) | `is_active` vs `tenant_status` 진실원천 정리 | 0-A-2 | — |
| (b) | `is_active` ↔ `effective_from/to` 이중 진실원천 근본 해소(두 신규 테이블) | 후속 | **A-5 신규** |
| (c) | 대표권 **행간** 모순(같은 법인 SOLE 2명, 대표 0명 등) 방지 | 트리거/RPC | **A-4 신규** |
| (d) | 등록번호 정규화 표현식·형식 CHECK 확정 | 5단계 착수 전 **권장** | **긴급도 하향(A-9)** |
| (e) | `ownership_percent` 법인별 합계 ≤ 100 | RPC/트리거 | — |
| (f) | 등록번호 중복 오류의 존재탐지 오라클 차단 | 0-C | — |
| (g) | `owners` 중복 등록 방지 절차 | 0-C | — |
| (h) | `stores.legal_entity_id` NOT NULL 승격 판정(+`stores` INSERT 경로 전수조사) | **5단계 말미** | **A-8 앞당김** |
| (i) | `store_groups` `DISTRICT` 도입 | 프랜차이즈 나선 | — |
| (j) | `franchise_brands` 사업자축 중첩 해소 | 브랜드 나선 | — |
| (k) | `stores.extra_metadata` / `stores.brand_id` | 후속 / 브랜드 나선 | — |
| ~~(l)~~ | ~~`SECURITY DEFINER` 접근 가능 여부~~ | — | **조건부 해소 → (o)로 전환(§2.8.4)** |
| (m) | **클라우드 확인 3건**: `pg_cron` 등록 상태 / `pg_cron_jobs` 카탈로그 값 / PostgreSQL 버전 | 5단계 착수 전 | **로컬은 실측 완료** |
| (n) | `pg_cron_jobs.is_registered` 역논리 결함 수정 | 0-A-2 | **A-1 신규** |
| (o) | ~~함수 소유자 `postgres` 유지 배포 계약~~ → **전용 role `catchmenu_authority_owner`로 대체**(§2.9.2). **`BYPASSRLS` 회수는 0-C 정책 생성 후** | **0169 + 0-C** | **v5 강화(조건 ①)** |
| (q) | 소유권(지분) 모델링 — `ownership_percent` **사용 금지**(`601501` §2.3.1) | 소유권 워크패킷 | **v5(조건 ④)** |
| (r) | LegalEntity : 사업자등록 1:N 확장(`601501` §2.1.1) | 미정 | **v5(조건 ④)** |
| (s) | `serviceable()` 공통 판정 헬퍼 — 두 축 개별 확인 금지(`601501` §3.1) | **0-A-2** | **v5(11B §1)** |
| (t) | 상태 전이 RPC 강제 — `TERMINATED` terminal, 격리해제가 부활 금지(`601501` §3.2) | **0-A-2** | **v5(11B §1)** |
| (u) | `stores.legal_entity_id` 시간성 — 과거 주문·정산 기록 재해석 위험 | 미정 | **v5(11B 추가1)** |
| (v) | 삭제 정책 — `ON DELETE CASCADE` 위험, dissolved lifecycle 권장 | 미정 | **v5(11B 추가2)** |
| (w) | default 자동승인 패턴 경계(본 워크패킷은 `TRIAL`/`NONE`이라 안전) | 상시 | **v5(11B 추가3)** |
| (x) | "Owner" 명칭 모호성 — `601501` §2.4.1 선언 참조 | 0-C | **v5(11B 추가4)** |
| (y) | **§9.3 tenant 검증과 백필의 순서 의존** — `stores.legal_entity_id` 백필 전에는 검증이 **모든 요청을 거부**한다 | **0-C 착수 전** | **v5 신규 발견** |

## §9 ⭐ `SECURITY DEFINER` 함수 작성 규칙 — 0-C 필수 (v5 신설, BLOCK 조건 ①②)

> **적용 대상**: `catchmenu_hq.owners` / `legal_entities` / `legal_entity_person_roles` /
> `legal_entity_representatives` 4개 테이블에 접근하는 **모든** `SECURITY DEFINER` 함수.
> **0-A에는 함수가 없으므로 지금 이행할 것이 없다.** 본 절은 **0-C가 함수를 만들 때 반드시 지킬 규칙**이다.

### §9.1 필수 6항목 (하나라도 누락 시 반려)

| # | 규칙 | 이유 |
|---|---|---|
| 1 | 함수 소유자를 **`catchmenu_authority_owner`** 로 지정 | 소유자가 `postgres`(슈퍼유저급)이면 사고 시 피해 범위가 DB 전역 |
| 2 | migration에 **`alter function … owner to catchmenu_authority_owner;` 를 명시** | 소유권을 "관행"이 아니라 **코드로 고정**(v4 Open Item (o)의 근본 원인 제거) |
| 3 | **`revoke all on function … from public;`** 후 필요한 role에만 `grant execute` | PostgreSQL 함수는 기본적으로 `PUBLIC`에 `EXECUTE`가 부여된다 — **명시 회수하지 않으면 누구나 호출 가능** |
| 4 | **`set search_path = catchmenu_hq, pg_catalog`** 고정 (`public` 제외) | §9.2 — 권한상승 취약점 방지 |
| 5 | 함수 본문의 **모든 테이블·함수 참조를 schema-qualified** 로 작성 | 4번과 짝. `search_path` 고정만으로는 실수를 못 막는다 |
| 6 | 함수 내부에서 **호출자의 tenant 권한을 명시적으로 검증** | §9.3 — confused deputy 방지 |

**표준 형태(0-C용 골격)**:

```sql
create or replace function catchmenu_hq.<fn_name>(...)
returns ...
language plpgsql
security definer
set search_path = catchmenu_hq, pg_catalog      -- 4번
as $$
begin
  -- 6번: tenant 권한 검증을 함수 최상단에서 먼저 수행 (§9.3)
  ...
end
$$;

alter function catchmenu_hq.<fn_name>(...) owner to catchmenu_authority_owner;   -- 1,2번
revoke all on function catchmenu_hq.<fn_name>(...) from public;                  -- 3번
grant execute on function catchmenu_hq.<fn_name>(...) to authenticated;          -- 3번(필요 role만)
```

### §9.2 왜 `search_path`가 소유자보다 위험한가

`601510` 원문:

> *"SECURITY DEFINER 함수에 부적절한 search_path가 붙으면 '접근불능'이 아니라 '권한상승 취약점'으로
> 발전 가능(호출자가 자기 search_path 앞쪽 스키마에 동명 가짜테이블을 만들면 함수가 그걸 참조,
> postgres 권한으로 실행됨)."*

**실패 심각도의 비대칭**을 인지할 것:

| 규칙 위반 | 최악의 결과 |
|---|---|
| 1번(소유자) 위반 | 함수가 **동작하지 않음** 또는 피해 범위가 넓어짐 |
| **4·5번(`search_path`) 위반** | **공격자가 함수 소유자 권한으로 임의 코드 실행** |

따라서 4·5번은 1번보다 **우선순위가 높다**. `search_path`에 **`public`을 포함하지 말 것** —
`public`은 기본적으로 누구나 객체를 만들 수 있는 스키마다.

### §9.3 tenant 경계 검증 — confused deputy 방지 (필수 6번)

**이 4개 테이블에는 `tenant_id` 컬럼이 없다**(전역 테이블 — `601501` §0.1 업무규칙 3).
따라서 **RLS가 있어도 tenant를 구분할 근거가 테이블 안에 없고**, `SECURITY DEFINER`는 RLS를 우회한다.

> `601510`: *"잘못 작성된 SECURITY DEFINER 하나가 'tenant A가 tenant B의 legal entity를 조회'하는
> confused deputy가 될 수 있다."*

**필수 검증 패턴** — 호출자가 넘긴 `legal_entity_id`가 **자기 tenant의 store와 연결되어 있는지**를
`stores.legal_entity_id` 경유로 확인한다:

```sql
-- 함수 최상단에서 먼저 수행
if not exists (
  select 1 from catchmenu_hq.stores s
  where s.legal_entity_id = p_legal_entity_id
    and s.tenant_id = catchmenu_common.current_tenant_id()
) then
  -- 권한 없음 처리 (존재 여부를 노출하지 않는 일반화된 오류로)
end if;
```

**금지**: `legal_entity_id`를 파라미터로 받아 **검증 없이 조회하는 함수**.
이는 그 자체로 confused deputy이며, 0-C 검증에서 반려 사유다.

> **주의**: 위 패턴은 `stores.legal_entity_id`가 채워져 있어야 작동한다. 현재 전 행 NULL이므로
> (백필 전) 이 검증은 **모든 요청을 거부**한다. 백필(§4.2)과 0-C 함수 작성의 순서 의존을 인지할 것.

### §9.4 CI / migration verification 체크리스트 (BLOCK 조건 ① 후반)

`601510` 요구: *"CI/migration verification에서 pg_proc.proowner/ACL/prosecdef 검사 + 실제 application role로 smoke test."*

**검증 쿼리(0-C 이후 상시 실행 대상)**:

```sql
-- (1) SECURITY DEFINER 함수의 소유자·search_path 일괄 점검
select n.nspname, p.proname,
       pg_get_userbyid(p.proowner) as owner,
       p.prosecdef,
       p.proconfig                          -- search_path 설정 확인
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname like 'catchmenu%' and p.prosecdef = true
order by owner, n.nspname, p.proname;

-- (2) PUBLIC EXECUTE가 남아있는 SECURITY DEFINER 함수 (0건이어야 함)
select n.nspname, p.proname, p.proacl
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname like 'catchmenu%' and p.prosecdef = true
  and (p.proacl is null or array_to_string(p.proacl, ',') like '%=X/%');

-- (3) search_path 미설정 SECURITY DEFINER 함수 (0건이어야 함)
select n.nspname, p.proname
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname like 'catchmenu%' and p.prosecdef = true
  and (p.proconfig is null
       or not exists (select 1 from unnest(p.proconfig) c where c like 'search\_path=%'));
```

| 검사 | 기대 | 위반 시 |
|---|---|---|
| (1) 4테이블 접근 함수의 `owner` | `catchmenu_authority_owner` | 반려 |
| (1) `proconfig`에 `search_path` | 존재하고 `public` 미포함 | **반려(최우선)** |
| (2) `PUBLIC` EXECUTE | **0건** | 반려 |
| (3) `search_path` 미설정 | **0건** | **반려(최우선)** |
| smoke test | 실제 application role로 호출 시 의도한 결과 | 반려 |

> **(2)의 주의**: `proacl`이 `NULL`이면 **기본 ACL = `PUBLIC`에 `EXECUTE` 부여**를 뜻한다.
> "ACL이 비어 있으니 안전"이 아니라 **"명시 회수를 안 했다"** 는 뜻이므로 위반으로 판정한다.

**smoke test 추가 항목**: `catchmenu_authority_owner`의 `BYPASSRLS` 속성이 살아 있는지 확인
(§2.9.3 — 이것이 빠지면 함수가 **오류 없이 0행**을 반환한다).

```sql
select rolname, rolcanlogin, rolbypassrls from pg_roles where rolname = 'catchmenu_authority_owner';
-- 기대: rolcanlogin = f, rolbypassrls = t (0-C가 정책을 만들어 회수하기 전까지)
```

---

## §8 근거 문서 목록 (§46)

`601502` §6 및 `601501` §8의 근거 목록 전체를 승계한다. 본 Logic이 **직접 인용한** 항목:

| 파일 | 인용 지점 | 용도 |
|---|---|---|
| `000701` §46/§47.1/§47.2/§47.6/§48/§49.2 | — | 근거목록, 나선 단계, 가드레일, D단계, `ADD COLUMN` 선행(§3) |
| `601501_ERD...md` (v4) | §0.1, §0.3, §2.1–§2.7, §3, §6 | 설계 원본 |
| `003020`/`009030`/`009070`/`007040` | `601501` §8 | 상위 축 정합 |
| **`supabase/config.toml`** | `[api] schemas`(L7–13) | **PostgREST 미노출 — §2.8.1** |
| `0022_create_rls_policies.sql` | **L614–623(스키마 USAGE 분포)**, L78–89, L282–294, L606–611 | **§2.8.1 근거** |
| `0021_enable_rls.sql` | 전체 | 0022와 짝 — "정책 0개" 선례 아님(§2.8.2) |
| **`0072_create_pg_cron_schedules.sql`** | **L29–66, L201–206, L226–230** | **`is_registered` 역논리(§5.3)** |
| `0002_create_hq_tenant_store.sql` | L8–24, L43–76, L60 | `tenants`/`stores` 원형 |
| `0034_seed_data.sql` | L24–25, L52–55 | 시드 tenant/store — §4 |
| `0077_create_multistore_rpc.sql` | L25–78, L126–155 | `store_groups` 재사용 |
| `0082_create_saas_billing_rpc.sql` | L88–112, L426–438, L465, L477–486, L490, L500 | `provision_tenant` 실제 시그니처 |
| `0085_...franchise_os_foundation_rpc.sql` | L123–160 | `franchise_brands` — **미변경** |
| `0090_create_multitenant_isolation_rpc.sql` | L1283–1286, L1293–1295 | §2.6 계약 근거 |
| `0112_create_hq_admin_rpc.sql` | 21개 지점, 특히 L248/L595/L611/L625/L414–424 | §2.6 실증, §5.5 승계 |
| `0120`/`0123`/`0129` | L898/L916/L926 · L636 · L873–885 | §5.1 |
| `0053`/`0074`/`0076`/`0085` | `'TERMINATED'` 맥락 | §2.6 — tenants 맥락 사용처 없음 근거 |
| `0060_create_franchise_hq_rpc.sql` | L235, L946 | Open Item (k) |

## Module Domain Tags

`hq`, `tenant`, `store`, `legal_entity`, `owner`, `representative`, `rls`, `grant`, `ddl`

## Snapshot Decision

본 Logic은 DDL 설계까지만 확정한다. RPC 동작 계약(§2.6)은 **후속 워크패킷이 지켜야 할 약속으로 기록**한 것이며
본 워크패킷의 구현 범위가 아니다. 이 경계를 넘는 구현은 4단계 Human 승인 없이 진행할 수 없다.
