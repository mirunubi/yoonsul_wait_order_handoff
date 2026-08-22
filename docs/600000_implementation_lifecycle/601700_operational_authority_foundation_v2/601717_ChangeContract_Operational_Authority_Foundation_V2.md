# 601717_ChangeContract_Operational_Authority_Foundation_V2.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: 0-A v2 Operational Authority Foundation Change Contract Draft
Runtime Implementation Authorization: Not Granted
Owner: Stage 2 (Claude) — 저자 분리(`000001` §5.4.2)
Last Updated: 2026-08-22

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-22 | 초안 — 판정 4건 + Blocker 10건 |
| 2026-08-22 | 2판 — B-1 등 해소. 대상 2·3·4 편입. 판정 6건 |
| 2026-08-22 | 3판 — §1.37 보강·§1.45 반영. backfill 편입. §1.5 조건부 1건(C-1) |
| 2026-08-22 | **4판** — `601718`/`601719` write-path 실측으로 C-1 근거 확보. **C-1 을 `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` 로 확정**. 두 INSERT RPC 수정 명시적 금지. Deferred handoff 명시. N-5 해소, 신규 blocker 2건 |

## Change ID

```text
Workpacket    601700  Operational Authority Foundation V2 (0-A 재수행)
Change Scope  ① Person 어휘·물리 식별자 정합화
              ② MerchantAccount foundation 신설 + canonical backfill + Store 구조 부모 연결
Migration     0170 · 0171  (신규 · 번호 미사용 확인: sql/migrations 최신 = 0169)
```

## §0 계약 요약

`000001` §5.4.5 ChangeContract 다. **구현을 승인하지 않는다.**

**저자 분리**(`000001` §5.4.2)

| 산출물 | 저자 |
|---|---|
| ERD `601705` / Overview `601710` / Logic `601713` | Claude Code |
| 선언 `601702` | Human |
| **TestPlan `601716` / ChangeContract `601717`** | **Claude (본 문서 저자)** |

### §0.1 3판 이후 무엇이 달라졌는가

**측정이 하나 들어왔고, 그 결과가 C-1 을 판정 가능하게 만들었다.**

`601718`(Cursor) / `601719`(Codex)가 **상대 결과를 참조하지 않고 동일 수치에 도달**했다(`000701` §35).

```text
stores 참조 함수         158        (601701 D-3 은 151 — §7.2 에 기록)
INSERT 경로               2         provision_tenant / create_franchise_store
  둘 다 COLUMN_LIST
  둘 다 merchant_account_id 를 공급하지 않는다
NO_COLUMN_LIST            0
ROW_TYPE                  0
SELECT * · 행 타입 의존    0
앱 코드 직접 INSERT        0
UPDATE 경로               2         onboard_tenant(brand_id) / update_business_hours
stores 트리거            241        internal 240 + user 1 (trg_stores_updated_at)
stores 참조 view/matview   0 / 0
```

| 3판 blocker | 판정 |
|---|---|
| **N-5** `stores` 참조 함수 형태 미측정 | **해소.** `SELECT *`·행 타입 의존 0건, `NO_COLUMN_LIST` 0건이 실측됐다 |
| **N-1′** C-1 승격 가부 미판정 | **판정 가능해졌고, 판정 결과는 부적격이다.** §4.4 |

### §0.2 이 계약이 판정한 6건

| # | 판정 대상 | 결론 | 절 |
|---|---|---|---|
| 1 | `owners → persons` 물리 변경 방법 | **`ALTER … RENAME` 계열만 허용** | §2 |
| 2 | Store–LegalEntity `NOT NULL` enforcement | **DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT** | §3 |
| 3 | 허용 파일 / 금지 파일 | migration 2건 + 색인 동기화 / X-1~X-21 | §1 · §5 |
| 4 | Stage 7 승인란 | **대기** | §10 |
| 5 | `merchant_accounts` 물리 표현 | §4 에서 확정 | §4 |
| 6 | **MerchantAccount → Store `NOT NULL` enforcement** | **DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT** | §4.4 |

## §1 Allowed — 허용 대상

### §1.1 허용 파일 — 구현(Stage 8)

| # | 경로 | 성격 | 제약 |
|---|---|---|---|
| A-1 | `sql/migrations/0170_person_vocabulary_normalization.sql` | 신규 | Person 계열 전용. 파일명은 제안이며 Stage 7 이 확정 |
| A-2 | `sql/migrations/0171_merchant_account_foundation.sql` | 신규 | MerchantAccount 계열 + backfill 전용. 동상 |

**A-1·A-2 가 허용 SQL 파일의 전부다.**

### §1.2 허용 파일 — 문서 동기화 (Stage 10, 기계적)

| # | 경로 | 허용 조작 |
|---|---|---|
| A-3 | `docs/…/601720_Module_*.md` | 신규 생성 (Stage 8 자기보고서). 번호는 `000005` 기준 다음 빈 번호 |
| A-4 | `601700_Readme_…V2.md` §8 File List | 행 추가 |
| A-5 | `docs/000005_Index_Document_Number.md` | 행 추가 |
| A-6 | `docs/000007_Map_Full_Directory.md` | 행 추가 |

### §1.3 허용 DDL — `0170` Person 계열

| # | 조작 | 대상 | 근거 |
|---|---|---|---|
| D-1 | `ALTER TABLE … RENAME TO` | `owners` → `persons` | `601702` §1.37 |
| D-2 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_person_roles.owner_id` → `person_id` | 동일 |
| D-3 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_representatives.owner_id` → `person_id` | 동일 |
| D-4 | `ALTER TABLE … RENAME COLUMN` | `persons.owner_name` → `person_name` | §1.37 보강 |
| D-5 | `ALTER TRIGGER … RENAME TO` | `trg_owners_updated_at` → `trg_persons_updated_at` | §1.37 보강 |
| D-6 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_person_roles_owner_id_fkey` → `…_person_id_fkey` | §1.37 |
| D-7 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_representatives_owner_id_fkey` → `…_person_id_fkey` | 동일 |
| D-8 | `ALTER INDEX … RENAME TO` | `owners_pkey` → `persons_pkey` | 동일 |
| D-9 | `ALTER INDEX … RENAME TO` | `idx_lepr_owner` → `idx_lepr_person` | 동일 |
| D-10 | `ALTER TABLE … DROP COLUMN` | `persons.is_active` | `601713` I-36 / §1.38 |
| D-11 | `ALTER TABLE … DROP CONSTRAINT` | `chk_lepr_ownership_percent` | `601713` I-37 / §1.39 |
| D-12 | `ALTER TABLE … DROP COLUMN` | `legal_entity_person_roles.ownership_percent` | 동일 |
| D-13 | `COMMENT ON TABLE` | `persons` | `601713` I-15 |

> **D-11 을 D-12 보다 먼저 수행한다.** 제약을 남긴 채 컬럼을 지우면 `CASCADE` 가 필요해지고,
> `601702` §1.39 와 I-37 이 `CASCADE` 를 금지했다.

> ⚠️ **`uq_lepr_active` / `uq_ler_active` / `uq_ler_sole_active` 는 이름을 바꾸지 않는다.**
> 세 이름에 `owner` 문자열이 없고, 정의 안의 컬럼 참조는 D-2·D-3 으로 자동 갱신된다.

> ⚠️ **§1.37 이 정합화 범위와 경계를 함께 그었다.**
> `catchmenu_common.set_updated_at()` 함수명과 `catchmenu_authority_owner` role 명은
> **변경 대상이 아니다**(FO-9·FO-16).

### §1.4 허용 DDL — `0171` MerchantAccount 계열

| # | 조작 | 대상 | 근거 |
|---|---|---|---|
| D-14 | `CREATE TABLE` | `catchmenu_hq.merchant_accounts` — §4.1 의 5컬럼 | §1.44 · §1.45 「배치」 |
| D-15 | `UNIQUE` 제약 또는 `CREATE UNIQUE INDEX` | `merchant_accounts.tenant_id` 단독 | §1.45 「관계의 물리 표현」 |
| D-16 | `CREATE TRIGGER` | `merchant_accounts` BEFORE UPDATE → `catchmenu_common.set_updated_at()` | §1.44 「수정 시각」 |
| D-17 | `ALTER TABLE … ENABLE / FORCE ROW LEVEL SECURITY` | `merchant_accounts` | §1.45 fail-closed baseline |
| D-18 | `ALTER TABLE … ADD COLUMN` | `stores.merchant_account_id` — **NULL 허용** | §1.26·§1.43 / Overview 대상 4 |
| D-19 | `ALTER TABLE … ADD CONSTRAINT … FOREIGN KEY` | `stores.merchant_account_id` → `merchant_accounts(id)`, `ON DELETE/UPDATE NO ACTION` | `fk_stores_legal_entity_id` 와 동일 관행 |
| D-20 | `CREATE INDEX` | `stores.merchant_account_id` 조회 인덱스 | `idx_stores_legal_entity_id` 와 동일 관행 |
| D-21 | `COMMENT ON TABLE / COLUMN` | `merchant_accounts` 및 신규 컬럼 | 어휘 정합 |

### §1.5 Deferred Enforcement — 이번 계약이 수행하지 않는 강제

**3판의 「조건부 허용 C-1」을 여기로 옮긴다. 조건부가 아니라 이월이다.**

| # | 대상 | 상태 |
|---|---|---|
| **C-1** | `stores.merchant_account_id` `NOT NULL` 승격 | **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** |
| **C-2** | `stores.legal_entity_id` `NOT NULL` 승격 | **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** |

> ⚠️ **`RESOLVED` 가 아니다.**
>
> ```text
> 장기 canonical invariant       살아 있음
> 현재 0-A 에서 NOT NULL 적용    부적격
> ```
>
> **`RESOLVED` 로만 적으면 나중에 NOT NULL 요구 자체가 폐기된 것으로 읽힌다.**
> 두 항목 모두 요구는 유효하고 **이번 계약에서 적용할 수 없을 뿐**이다.

**각 항목의 장기 invariant 근거**

| # | 살아 있는 invariant | 근거 |
|---|---|---|
| C-1 | Store 의 구조 부모는 MerchantAccount 이며, MerchantAccount 없이 Tenant 에 직접 매달지 않는다. Tenant 만 존재하고 MerchantAccount 가 없는 상태를 정상 운영 상태로 허용하지 않는다 | **`601702` §1.26 · §1.45** / `601713` I-27 |
| C-2 | 각 Store 는 현재 시점의 법적 운영주체를 명시하며, 그 배정은 유효기간을 갖는 시점 관계다 | **`601702` §1.24 · §1.34** / `601713` I-40~I-42 |

부적격 사유는 §4.4(C-1)와 §3(C-2)에 각각 적었다. **사유가 서로 다르다.**

### §1.6 허용 동사 (narrow verbs)

```text
DDL 허용   ALTER TABLE … RENAME TO / RENAME COLUMN / RENAME CONSTRAINT
           ALTER TABLE … DROP COLUMN / DROP CONSTRAINT      (D-10 · D-11 · D-12 한정)
           ALTER TABLE … ADD COLUMN / ADD CONSTRAINT        (D-18 · D-19 한정)
           ALTER TABLE … ENABLE / FORCE ROW LEVEL SECURITY  (D-17 한정)
           ALTER TRIGGER … RENAME TO                        (D-5 한정)
           ALTER INDEX … RENAME TO
           CREATE TABLE / CREATE INDEX / CREATE UNIQUE INDEX / CREATE TRIGGER
           COMMENT ON TABLE / COLUMN
DML 허용   INSERT … SELECT   (§4.5 M-1 한정)
           UPDATE … FROM     (§4.5 M-2 한정)

금지       ALTER TABLE … ALTER COLUMN … SET NOT NULL        (§1.5 — 이월)
```

**3판까지 있던 조건부 동사는 없다.** `SET NOT NULL` 은 이제 조건부가 아니라 **금지**다(FO-13).

## §2 판정 1 — `owners → persons` 물리 변경 방법

### §2.1 판정

**`ALTER … RENAME` 계열 조작만 허용한다.**
**신규 테이블 생성 후 교체 방식을 금지한다.**
**`owners` 라는 이름의 호환 view / matview 생성을 금지한다.**

### §2.2 판정 근거 — 실측 사실

| # | 사실 | 출처 |
|---|---|---|
| F-1 | Person 계열 4테이블 전부 0행 | `601711` P-3 / `601712` P-3 |
| F-2 | `owners` 참조 FUNCTION 0건, `pg_depend`→`pg_proc` 의존 0건 | `601714`/`601715` Q-4 |
| F-3 | `owners` 참조 VIEW / MATVIEW 0건 | `601711` P-1 |
| F-4 | 타 스키마에서 4테이블을 참조하는 FK 0건 | `601714`/`601715` Q-4 |
| F-5 | 앱·패키지·테스트·seed 코드 참조 0건 | `601711` P-5 / `601712` P-5 |
| F-6 | 관련 migration 은 `0168`/`0169` 2건뿐 | `601711` P-2 |
| F-7 | RLS `ENABLE`+`FORCE`, POLICY 0건, GRANT 4건, role 은 `nologin`+`bypassrls` | `601711` P-1 / `601714` Q-4 |

### §2.3 왜 rename 인가

```text
ALTER … RENAME          객체 OID 가 유지된다 → I-1~I-4, I-9~I-14 자동 보존
CREATE 신규 + 교체       FK 2 · TRIGGER 1 · RLS · GRANT 4 · PK · 부분 unique 3 을
                        전부 재선언 → Logic X-1·X-2·X-3·X-4·X-6·X-7·X-8 이 실현 가능해진다
```

**Logic §3 의 11개 실패 지점 중 7개는 "신규 생성 후 교체"에서만 발생한다.**

### §2.4 rename 이 자동으로 해주지 않는 것

| 항목 | PostgreSQL 동작 | 계약 요구 |
|---|---|---|
| FK **정의** 안의 컬럼 참조 | 자동 갱신 | 조치 불필요 |
| FK **제약 이름** | 자동 갱신 안 됨 | D-6 · D-7 |
| **인덱스 이름** | 자동 갱신 안 됨 | D-8 · D-9 |
| **트리거 이름** | 자동 갱신 안 됨 | D-5 |
| 부분 unique 인덱스 **정의** | 자동 갱신 | 이름 변경 금지 |
| 테이블 **코멘트** | 유지 | D-13 |

### §2.5 호환 계층을 금지하는 이유

`owners` view 를 남기면 legacy 어휘가 **다시 조회 가능한 canonical 표면**이 된다.
데이터 0행·코드 참조 0건 상태에서 호환 계층이 보호할 호출자가 없다(`601710` §2.1).

### §2.6 이 판정이 결정하지 않은 것

`legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives` 테이블명은 유지한다(I-35).
`catchmenu_authority_owner` role 명과 `catchmenu_common.set_updated_at()` 함수명은 유지한다(§1.37 명시적 제외).

## §3 판정 2 — Store–LegalEntity NOT NULL enforcement

### §3.1 판정

**`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** (§1.5 C-2).
`stores.legal_entity_id` 에 `NOT NULL` 을 걸지 않는다.

**장기 invariant 는 살아 있다** — `601702` §1.24·§1.34, `601713` I-40~I-42.

### §3.2 부적격 사유 — Logic E-1~E-4 대조

| 조건 | 판정 | 근거 |
|---|---|---|
| E-1 모든 Store 가 검증된 business identity 확보 | **거짓** | `010901` §11 의 9개 intake 필드 중 실재 정확명 1건, 나머지 8건 0건 (`601714`/`601715` Q-8) |
| E-2 그 identity 로 canonical LegalEntity 생성·연결 | **거짓** | `legal_entities` 0행 (`601701` §4.5 D-3) |
| E-3 mapping completeness — 미매핑 Store 0 | **거짓** | `stores` 1행 / 백필 0행 → 미매핑 1 |
| E-4 신규 onboarding 경로 강제 | **미확인** | `sales_lead`/`tenant_candidate` 0건. `tenant_onboarding_log` 는 intake 9필드를 담지 않는다 |

**`601710` §4 가 같은 결론을 독립적으로 재확인했다** — 「enforcement 는 여전히 부적격이다」.

> **C-1 과 사유가 다르다.**
>
> ```text
> C-2 (LegalEntity)      채울 값 자체가 없다.  외부 검증(사업자등록 intake)이 선행되어야 한다
> C-1 (MerchantAccount)  값은 채워진다.        신규 생성 경로가 값을 공급하지 않을 뿐이다
> ```

### §3.3 §1.45 의 backfill 이 여기로 확장되지 않는다

`601702` §1.45 자신이 경계를 그었다.

```text
LegalEntity        외부 검증(사업자등록 intake)이 필요하다   →  §1.31 synthetic 금지 적용
MerchantAccount    Tenant 로부터 파생, 외부 검증 불요        →  backfill 허용
```

| 금지 | 근거 |
|---|---|
| 검증되지 않은 synthetic LegalEntity 생성 | I-28 / §1.31·§1.45 |
| placeholder 로 `stores.legal_entity_id` 백필 | 동일 |
| `store_operator_type` 값으로 LegalEntity 추론·배정 | I-30 / §1.32 |

### §3.4 시점 관계 물리 구조를 만들지 않는 이유

| # | 이유 |
|---|---|
| 1 | `601710` §4 의 적용 분기가 **「미확보 → 관계만 유지」** 다 |
| 2 | I-41(유효기간 중첩 금지) 검증 방식을 §1.34 가 「물리 설계에서 정한다」로 남겼는데, **필요한 확장(`btree_gist` 등) 설치 여부 실측이 없다** |
| 3 | I-42 는 Store 의 현재값을 「현재 포인터」로 규정한다. 시점 테이블 없이 포인터만 남기면 **권위 원본 없는 포인터**가 된다 |
| 4 | 검증할 데이터가 0행이다 |

**§7.2 B-5 로 남긴다.**

## §4 판정 5 — `merchant_accounts` 물리 표현

### §4.1 확정 — 필드 구성

| 선언 항목 | 물리 표현 | 파생 근거 |
|---|---|---|
| 식별자 (PK) | `id uuid primary key default gen_random_uuid()` | `tenants.id`/`stores.id`/`legal_entities.id` 동일 형태(`601701` E단계) |
| Tenant 참조 | `tenant_id uuid not null` + FK → `catchmenu_hq.tenants(id)` | **§1.45 가 이름·NOT NULL·UNIQUE 를 직접 명시** |
| 계정 명칭 | `account_name text not null` | `tenants.tenant_name`/`stores.store_name` 이 `text NOT NULL` |
| 생성·수정 시각 | `created_at timestamptz not null default now()` / `updated_at timestamptz not null default now()` | 네 테이블 전부 동일 형태 |

**총 5컬럼.** `601716` TP-N-21 이 컬럼 수 일치를 검사한다.

### §4.2 확정 — 제약과 부속 객체

| # | 객체 | 정의 | 근거 |
|---|---|---|---|
| 1 | `uq_merchant_accounts_tenant` | `unique (tenant_id)` | §1.45 「이것만으로 1:1 이 강제된다」 |
| 2 | `trg_merchant_accounts_updated_at` | `BEFORE UPDATE … EXECUTE FUNCTION catchmenu_common.set_updated_at()` | §1.44 |
| 3 | RLS | `ENABLE` + `FORCE`, POLICY 0건 | §1.45 fail-closed baseline |
| 4 | GRANT | `catchmenu_authority_owner` 외 확대 금지 | 동일 |

### §4.3 확정 — 스키마 배치

**`catchmenu_hq`.** `601702` §1.45 「배치」가 직접 확정했다.

### §4.4 판정 6 — MerchantAccount → Store NOT NULL enforcement

**`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** (§1.5 C-1).

**장기 invariant 는 살아 있다** — `601702` §1.26·§1.45, `601713` I-27.

#### §4.4.1 판정 근거 — `601718`/`601719` 실측

| 조건 | 판정 | 근거 |
|---|---|---|
| 기존 데이터에 값을 채울 수 있는가 | **참** | §1.45 backfill + `stores.tenant_id` NOT NULL → 전 행 결정적 파생 |
| mapping completeness 를 만들 수 있는가 | **참** | 미매핑 Store 0 달성 가능 (M-2) |
| `SELECT *` · 행 타입 의존 함수가 깨지는가 | **아니오** | **`SELECT *`/`ROW_TYPE` 0건**(`601718` S-3 / `601719` S-3) |
| 컬럼 목록 없는 INSERT 가 깨지는가 | **아니오** | **`NO_COLUMN_LIST` 0건**(`601718` S-2 / `601719` S-2) |
| 앱 코드가 깨지는가 | **아니오** | **앱 코드 직접 INSERT 0건**(`601718` S-5 / `601719` S-5) |
| **신규 Store 생성 경로가 값을 공급하는가** | **아니오 — 2건 전부 미공급** | **`provision_tenant` / `create_franchise_store`. 둘 다 `COLUMN_LIST` 이며 `merchant_account_id` 가 컬럼 목록에 없다** |

**마지막 조건 하나가 부적격을 만든다.**

```text
provision_tenant       insert into catchmenu_hq.stores
                         (tenant_id, store_code, store_name,
                          store_type, store_status, timezone)

create_franchise_store insert into catchmenu_hq.stores
                         (tenant_id, store_code, store_name, store_type,
                          store_status, address, phone, timezone,
                          business_hours, opened_on, is_active, extra_metadata)
```

**어느 쪽도 `merchant_account_id` 를 공급하지 않는다.**
`NOT NULL` 을 지금 걸면 **두 경로 모두 다음 호출에서 실패한다.**

#### §4.4.2 왜 두 RPC 를 고쳐서 해결하지 않는가

**두 RPC 수정은 이 계약의 범위 밖이다.**

| # | 근거 |
|---|---|
| 1 | `601700` Readme §5 · `601710` §3 — **RPC 재작성 Out of Scope** |
| 2 | `601702` §1.45 자신이 「Tenant provisioning 경로의 구현은 0-A 범위 밖」이라고 명시했다 |
| 3 | 두 RPC 는 `stores` 를 넘어 tenant·brand·plan·quota 를 함께 다룬다. 여기서 손대면 0-A 가 provisioning 설계를 선점한다 |

**따라서 이 계약은 값을 채우되 제약을 걸지 않는다.**

```text
이번 계약    구조 생성 + backfill        기존 행 전부 값 보유
             NOT NULL 미적용             신규 행은 NULL 로 생성될 수 있다

후속 나선    두 RPC 가 값을 공급하도록 정렬 → NOT NULL 승격 재판정
```

#### §4.4.3 Deferred Handoff — 후속 RPC alignment 나선

**이 계약이 넘기는 것을 명시한다.**

| # | 이월 항목 | 근거 |
|---|---|---|
| H-1 | `catchmenu_common.provision_tenant` 가 `merchant_accounts` 행을 **같은 transaction 에서** 생성하도록 정렬 | **`601702` §1.45 「신규 Tenant 생성 경로가 MerchantAccount 동시 생성을 책임진다」** |
| H-2 | `catchmenu_common.provision_tenant` 의 `stores` INSERT 가 `merchant_account_id` 를 공급하도록 정렬 | §1.26 / I-27 |
| H-3 | `catchmenu_hq.create_franchise_store` 의 `stores` INSERT 가 `merchant_account_id` 를 공급하도록 정렬 | 동일 |
| H-4 | H-1~H-3 완료 후 `stores.merchant_account_id` `NOT NULL` 승격 재판정 | §1.5 C-1 |

**소관**: 후속 **RPC alignment 나선**. `601700` Readme §5 가 RPC 재작성을 파생 나선 소관으로 두었다.
**워크패킷 번호는 이 계약이 확정하지 않는다.**

> ⚠️ **H-1 은 H-2·H-3 과 성격이 다르다.**
> H-2·H-3 은 컬럼 하나를 공급하는 문제지만,
> **H-1 은 `provision_tenant` 가 현재 MerchantAccount 를 아예 만들지 않는다는 문제**다.
> 이 계약이 backfill 로 기존 Tenant 를 덮고 나면,
> **다음에 provisioning 되는 Tenant 부터 §1.45 의 1:1 invariant 가 다시 깨진다.**
> §7.3 N-1″ 로 기록한다.

### §4.5 확정 — 허용 DML (backfill)

| # | 조작 | 정의 | 근거 |
|---|---|---|---|
| **M-1** | `INSERT INTO catchmenu_hq.merchant_accounts (tenant_id, account_name) SELECT … FROM catchmenu_hq.tenants` | **`tenants` 전 행에서 1:1 파생.** 리터럴 business data 금지 | `601702` §1.45 |
| **M-2** | `UPDATE catchmenu_hq.stores SET merchant_account_id = … FROM catchmenu_hq.merchant_accounts WHERE stores.tenant_id = merchant_accounts.tenant_id` | `stores.tenant_id` 경유 결정적 파생 | §1.26 — **§7.3 N-2′ (파생이며 직접 선언이 아니다)** |

**M-1 · M-2 가 허용 DML 의 전부다.**

**`account_name` 의 값 출처**: `tenants.tenant_name`. §1.45 는 값 출처를 말하지 않았다 — §7.3 N-3′.

> ⚠️ **M-1 · M-2 는 조건이 아니라 형태로 제한된다.**
>
> ```text
> 허용   INSERT … SELECT FROM tenants        원천 행에서 파생
> 금지   INSERT … VALUES (…)                 리터럴 주입
> ```
>
> `tenants` 가 0행이면 M-1 은 0행을 만든다 — §1.45 가 요구한 동작이다.

> ⚠️ **M-2 는 `trg_stores_updated_at` 을 발동시켜 `stores.updated_at` 을 갱신한다.**
> `601718` S-6 이 그 트리거가 실재함을 재확인했다(user-visible 1건).
> **rollback 으로 복원되지 않는다** — §7.3 N-4′.

## §4.6 판정 3 관련 — External Provider Mapping 명시적 금지 (`601710` §7 요구)

```text
금지   provider mapping table 생성
금지   외부 provider 전용 컬럼 추가 (기존 테이블 포함)
금지   provider contract 를 추정한 schema · 타입 · 제약 생성
금지   특정 벤더명을 담은 객체 생성 (TOSS / OKPOS / KICC / Smartcast 등)
금지   stores.id 를 외부 provider merchant id 와 동일시하는 제약 · 주석
금지   catchmenu_integrations / catchmenu_payment 의 기존 merchant 컬럼 5건을
       canonical identity 로 승격하는 FK · unique 제약 추가
금지   merchant_accounts 를 외부 provider 식별자와 연결하는 컬럼 · FK
금지   backfill 이 외부 provider 테이블의 값을 원천으로 삼는 것
```

**어휘가 겹친다.** `merchant_accounts`(CM-PLAT SaaS 계약 단위)와
`van_merchant_id` 등 5건(외부 결제 가맹점 식별자)은 같은 단어를 쓴다.
둘을 연결하는 것이 정확히 `601702` §1.43 이 금지한 provider identity 의 canonical 승격이다.

**M-1 의 원천은 `catchmenu_hq.tenants` 하나뿐이다.** `601716` TP-X-10 이 검사한다.

## §5 Forbidden Files

**§1 에 없는 모든 파일이 금지다.** 아래는 실수 가능성이 높은 것을 명시한 것이며 한정 목록이 아니다.

### §5.1 절대 금지

| # | 경로 | 사유 |
|---|---|---|
| X-1 | `sql/migrations/0168_create_operational_authority_foundation.sql` | `000701` §14.5 · `601710` §5 동결 |
| X-2 | `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 동일 |
| X-3 | `sql/migrations/0000_*.sql` ~ `0167_*.sql` (기존 167개) | 동일. **`0034`/`0060`/`0082` 가 `stores` INSERT 를 포함하나 수정 대상이 아니다**(`601718` S-5 note) |
| X-4 | `sql/_excluded_from_local_replay/**` | 재생 제외 결정 파일 |
| X-5 | `sql/seed_yoonsul_menu.sql` · 기타 seed | §4.5 는 migration 내 backfill 만 허용 |
| X-6 | `sql/migrations/CHANGELOG.md` | 규약 상태 미결 — §7.2 B-6 |

### §5.2 상위 근거 문서

| # | 경로 | 사유 |
|---|---|---|
| X-7 | `601702_Register_Stage1_Business_Rules.md` | Human 전담. AI 수정 불가 |
| X-8 | `601705_…ERD.md` · `601710_Overview_…V2.md` · `601713_Logic_…V2.md` | 개정은 Stage 3/4 경로로만 |
| X-9 | `601716_…TestPlan.md` · `601717_…ChangeContract.md` | 개정은 Stage 6/7 경로로만 |
| X-10 | `601701` · `601703`~`601709` · `601711`·`601712` · `601714`·`601715` · **`601718`·`601719`** | Evidence / Register / Audit — 사후 수정 시 기준선 소멸 |
| X-11 | `docs/000001_Md_Rules.md` · `docs/000701_…Pipeline.md` | 거버넌스 문서 |
| X-12 | `docs/…/600020_…Authority_Reset.md` | 권위 판정 전문 |
| X-13 | `docs/…/601500_operational_authority_foundation/**` | 권위보류 대역 |

### §5.3 범위 밖

| # | 경로 | 사유 |
|---|---|---|
| X-14 ~ X-17 | `apps/**` · `packages/**` · `catchmenu_app/**` · `tests/**` | 코드 참조 0건(`601711` P-5, `601718` S-5) |
| X-18 | `tools/**` | 검증 도구를 변경해 검사를 통과시키지 않는다 |
| X-19 | `supabase/**` | 런타임 설정 |
| X-20 | `.git/hooks/**` | 커밋 게이트 우회 금지 |
| X-21 | `data/**` · `scratch/**` · `sop/**` | 무관 |

## §6 Forbidden Operations

### §6.1 RPC — 명시적 금지 (4판 신설)

> **`601718`/`601719` 가 두 함수를 이름으로 특정했으므로, 금지도 이름으로 특정한다.**
> 이름 없는 「RPC 수정 금지」는 구현자가 「이건 수정이 아니라 정렬」이라고 읽을 여지를 남긴다.

| # | 금지 | 근거 |
|---|---|---|
| **FO-A** | **`catchmenu_common.provision_tenant` 의 생성·수정·삭제·재정의** | **`601710` §3 RPC 재작성 Out of Scope · `601702` §1.45 「provisioning 경로 구현은 0-A 범위 밖」.** 이월 항목 §4.4.3 H-1·H-2 |
| **FO-B** | **`catchmenu_hq.create_franchise_store` 의 생성·수정·삭제·재정의** | 동일. 이월 항목 §4.4.3 H-3 |
| **FO-C** | 두 함수의 `stores` INSERT 컬럼 목록에 `merchant_account_id` 를 추가하는 행위 | FO-A · FO-B |
| **FO-D** | `catchmenu_common.onboard_tenant` · `catchmenu_store.update_business_hours` 수정 | `601718` S-4 가 특정한 `stores` UPDATE 경로 2건. 동일 사유 |
| **FO-E** | 두 INSERT 경로를 우회하는 신규 store 생성 함수·트리거 생성 | 우회는 수정과 같다 |

### §6.2 물리 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-1 | Person 계열에서 신규 테이블 생성 (어떤 이름으로도) | §2 판정 |
| FO-2 | `DROP TABLE` | 동일 |
| FO-3 | `owners` 이름의 VIEW / MATVIEW 생성 | §2.5 |
| FO-4 | `CASCADE` 사용 | §1.39 / I-37 |
| FO-5 | RLS POLICY 생성·삭제 — `merchant_accounts` 포함 | §1.45 「Policy 0개」 · I-11 |
| FO-6 | `DISABLE` / `NO FORCE ROW LEVEL SECURITY` | I-10 / §1.45 |
| FO-7 | GRANT / REVOKE — 4 privilege 확대·축소, `merchant_accounts` 신규 부여 포함 | §1.45 |
| FO-8 | 클라이언트 도달 가능 role(`anon`/`authenticated`/`service_role`)에 권한 부여 | §1.45 |
| FO-9 | role 생성·삭제·속성 변경 (`catchmenu_authority_owner` 개명 포함) | §1.37 명시적 제외 |
| FO-10 | FK 참조 동작을 `NO ACTION` 이외로 변경 | I-3 |
| FO-11 | §4.5 M-1 · M-2 외의 모든 `INSERT` / `UPDATE` / `DELETE` | §4.5 |
| FO-12 | `stores.legal_entity_id` 에 대한 모든 DDL·DML | §3.1 |
| FO-13 | **`SET NOT NULL` — `stores.legal_entity_id` · `stores.merchant_account_id` 둘 다** | **§1.5 — 조건부가 아니라 이월** |
| FO-14 | `chk_lepr_role_type` 허용값 재정의 | 선언 없음 |
| FO-15 | 함수 생성·수정·삭제 (SECURITY DEFINER 포함) | `601700` Readme §5. §6.1 이 그중 4건을 이름으로 특정 |
| FO-16 | `catchmenu_common.set_updated_at()` 수정·개명 | §1.37 명시적 제외. 114개 트리거 공유 |
| FO-17 | `catchmenu_meta.migration_history` 직접 조작 | 이력 보존 |
| FO-18 | `tenants` 에 대한 모든 DDL 및 UPDATE | §1.45 「순환 참조를 만들지 않는다」 |
| FO-19 | `stores` 에 `merchant_account_id` 외의 컬럼 추가·변경·삭제 | D-18 한정 |
| FO-20 | `stores` 의 기존 트리거 241건(internal 240 + user 1) 변경·비활성화 | `601718` S-6. backfill 중 트리거 우회 금지 |

### §6.3 범위 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-21 | External Provider Mapping 물리 구현 | §4.6 |
| FO-22 | `merchant_accounts` 에 LegalEntity 참조 추가 | I-38 / §1.44·§1.23 |
| FO-23 | `merchant_accounts` 에 미채택·deferred 필드 추가 | I-39 |
| FO-24 | `merchant_companies` / `merchant_stores` 등 3층 구조 테이블 생성 | §1.25 / `601705` §4.6 |
| FO-25 | `merchant_accounts` 와 `tenants` 를 한 테이블로 합치기 | I-23 |
| FO-26 | economic ownership 모델 생성 | §1.39 |
| FO-27 | Store 상태 3축 enum · 상태 컬럼 생성 | `601710` §3 |
| FO-28 | `OperatingGroup` / `company` / `business_unit` / `cross_business_link` 물리화 | `601710` §3 |
| FO-29 | Store–LegalEntity 시점 이력 테이블 생성 | §3.4 |
| FO-30 | 금전 객체 LegalEntity snapshot 컬럼 생성 | `601710` §2.3 — §1.35 원칙 전용 |
| FO-31 | Tenant 이전 절차·데이터 처리 객체 생성 | `601710` §2.3 — §1.36 원칙 전용 |
| FO-32 | 감사 이력 테이블 · 감사 트리거 생성 | `601713` §5 |
| FO-33 | Staff / User / Session / Role / Permission 객체 변경, `tenant_status`/`isolation_state` 조작, tenant `ACTIVE` 승격 | §1.18·§1.19 / `601505` §4 |

### §6.4 절차 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-34 | Stage 7 승인 전 migration 적용 또는 커밋 | `000701` §10 · §6.11.1 |
| FO-35 | `-- Workpacket: 601700` 헤더 누락 — 두 파일 모두 | `000701` §6.11.1 |
| FO-36 | 검증 도구를 수정해 검사를 통과시키는 행위 | X-18 |
| FO-37 | 구현자가 자기 구현을 감사·승인하는 행위 | `000701` §37 |
| FO-38 | `0170`/`0171` 각각을 2개 이상으로 분할 | 중간 상태 커밋 금지 |
| FO-39 | `0171` 을 `0170` 보다 먼저 적용 | 적용 순서 고정 |
| FO-40 | 과거 migration 파일에서 `owner_` 를 제거하려는 시도 | §1.37 「검증 범위」 명시적 제외 · §14.5 |

## §7 Blocker

### §7.1 해소된 것 (기록 보존)

| # | blocker | 해소 근거 |
|---|---|---|
| B-1 | `MerchantAccount` 목표 물리 형태 | `601702` §1.44 |
| B-2a / B-2b | 트리거명 / `owner_name` | `601702` §1.37 보강 → D-5 · D-4 |
| B-3 / B-4 | `is_active` / `ownership_percent` 충돌 | `601713` I-36 · I-37 |
| B-6(1판) / B-7(1판) | §1.43 vs §3.1 / §1.34~§1.44 미반영 | `601710` §2.3 / `601713` I-34~I-42 |
| N-1(2판) | MA→Store enforcement 원인 | `601702` §1.45 backfill |
| N-2 / N-3 / N-4 / N-6 | posture / 소관 순환 / 옛 서술 / 일자 | `601702` §1.45·§2.2·§5, `601713` 병기 |
| **N-5** | **`stores` 참조 함수 형태 미측정** | **`601718`/`601719` — `SELECT *`·`ROW_TYPE`·`NO_COLUMN_LIST` 전부 0건** |
| **N-1′** | **C-1 승격 가부 미판정** | **판정 가능해졌다. 결과는 §4.4 — 부적격이며 §1.5 로 이월** |

> **N-1′ 이 "해소"인 것은 판정 불능 상태가 끝났다는 뜻이다.**
> **C-1 자체는 해소되지 않았다** — §1.5 를 보라.

### §7.2 남아 있는 것 — 처분 유효성 재확인

| # | Blocker | 처분이 여전히 유효한가 | 이 계약의 처리 |
|---|---|---|---|
| **B-5** | Store–LegalEntity 시점 관계 물리 구조 미정 | **유효.** `601710` §4 분기·확장 실측 부재 모두 변동 없음 | FO-29. §3.4 |
| **B-6** | `CHANGELOG.md` 규약 상태 미결 | **유효.** 변동 없음 | X-6 |
| **B-7** | 재적용 동작 요구사항 미선언 | **유효.** backfill INSERT 중복 판정 기준이 여전히 없다. `601718` S-5 가 `0034`/`0060`/`0082` 에도 `stores` INSERT 가 있음을 기록했으나, 전체 재생 시 이들은 `0171` 보다 앞서 적용되므로 backfill 이 사후에 덮는다 — **순서상 문제는 없으나 정책 부재는 그대로다** | Stage 7 |
| **B-8** | 검증 환경 미지정 | **유효하되 완화.** `601718`/`601719` 가 `17.6.1.140` 에서 `stores` 1행 / `tenants` 1행을 재확인했다. 다만 `601714`/`601715` 는 `17.6.1.156` 이었다 | Stage 7. `601716` PRE-5 |
| **B-9** | 문서 정합화 시점 미정 | **유효.** `owners` 참조 문서 27~30건 | §1.2 는 색인 3종만 허용 |
| **N-2′** | `stores` backfill 이 §1.45 의 직접 선언이 아니다 | **유효.** §1.45 문언은 MerchantAccount 생성만 다룬다 | M-2 로 허용하되 파생임을 명시. Stage 7 확인 |
| **N-3′** | backfill `account_name` 값 출처 미선언 | **유효.** 변동 없음 | `tenants.tenant_name` 지정. Stage 7 확인 |
| **N-4′** | backfill UPDATE 의 `stores.updated_at` 부작용 | **유효.** `601718` S-6 이 트리거 실재를 재확인했다 | §9.1 R-6 비가역 지점 |
| **N-5′** | §1.45·§1.37 보강이 ERD/Overview/Logic 에 미반영 | **유효.** 변동 없음. **`601718`/`601719` 결과도 아직 어느 설계 문서에도 반영되지 않았다** | §8.3 검증자 전달 |

### §7.3 새로 생긴 것

| # | Blocker | 사실 관계 | 이 계약의 처리 |
|---|---|---|---|
| **N-1″** | **backfill 이후 신규 provisioning 부터 §1.45 의 1:1 invariant 가 다시 깨진다** | `provision_tenant` 는 `merchant_accounts` 를 만들지 않는다(`601718` S-2 — INSERT 대상은 `stores` 뿐). backfill 은 **기존** Tenant 만 덮는다. **다음에 provisioning 되는 Tenant 는 MerchantAccount 없이 생성된다** — §1.45 가 「정상 운영 상태로 허용하지 않는다」고 선언한 바로 그 상태다 | §4.4.3 H-1 로 이월. FO-A 로 이번 계약에서의 수정을 금지 |
| **N-2″** | **`stores` 의 실제 컬럼 수가 확정되지 않았다** | `601701` E단계는 **16컬럼**을 기록했으나, `601718`/`601719` 가 인용한 live `prosrc` 는 `stores.brand_id`(`onboard_tenant` UPDATE)와 `stores.extra_metadata`(`create_franchise_store` INSERT)를 사용한다. **두 컬럼은 `601701` 16컬럼 목록에 없고 다른 어느 authority 문서에도 없다.** 컬럼이 실재하는데 기록이 누락된 것인지, RPC 가 phantom 컬럼을 참조하는 것인지 판정할 실측이 없다 | `601716` TP-R-06 의 기대값을 **상수(17)가 아니라 「재측정한 before 값 + 1」**로 바꾼다 |

> **N-2″ 를 이 계약이 판정하지 않는 이유**
>
> 두 가능성의 결과가 완전히 다르다.
>
> ```text
> 컬럼이 실재한다        601701 E단계 기록이 불완전하다 — 기준선 문서의 정확성 문제
> 컬럼이 없다            두 RPC 가 phantom 컬럼을 참조한다 — 런타임 결함
> ```
>
> 이 프로젝트에는 **phantom 컬럼 참조로 RPC 가 실패한 실제 이력**이 있다
> (`sql/migrations/CHANGELOG.md` 2026-07-18 — `0160`~`0164` 가 `order_sessions` phantom 컬럼을 교정).
> **가능성을 배제할 근거가 없으므로 판정하지 않고 기록한다.**
>
> 어느 쪽이든 이번 계약의 허용 범위는 바뀌지 않는다 —
> `stores` 에 컬럼 하나를 추가할 뿐이고 FO-A·FO-B 가 두 RPC 수정을 금지한다.
> **바뀌는 것은 검증 기대값뿐이다.**

> **C-1·C-2 는 blocker 표에 없다. §1.5 에 있다.**
> 이월은 미해결이 아니라 **판정된 상태**이며, 그 판정이 `DEFERRED — INELIGIBLE` 이다.

## §8 Required Verification

### §8.1 착수 직전 게이트

| # | 항목 | 미충족 시 |
|---|---|---|
| V-1 | §10 Stage 7 이 승인 상태 | 착수 금지 |
| V-2 | §7 blocker 중 착수 범위에 걸린 것이 해소 또는 명시적 제외됨 | 해당 범위 제외 |
| V-3 | `601716` §2.1 기준선 재측정 완료 | 착수 금지 |
| V-4 | `tenants` 행 수 재측정 완료 | backfill 기대값 미확정 — 착수 금지 |
| V-5 | **`stores` 컬럼 수 재측정 완료 (N-2″)** | TP-R-06 기대값 확정 불가 — 착수 금지 |
| V-6 | 검증 환경 확정(B-8) | 착수 금지 |
| V-7 | §4.1 컬럼명·타입이 Stage 7 에서 확정됨 | 착수 금지 |
| V-8 | N-2′ · N-3′ 이 Stage 7 에서 확인됨 | 해당 범위 제외 |
| V-9 | 구현자가 상위 문서·본 문서의 원작자가 아님 | 배정 재조정(`000701` §37) |

### §8.2 구현 후 검증

| # | 항목 | 대응 Test ID |
|---|---|---|
| V-10 | negative 검증 전건 | `601716` §5 |
| V-11 | backfill 이 선언된 파생인가 — 행 수 일치·고아 0·리터럴 0 | TP-D-01~TP-D-07 |
| V-12 | **`NOT NULL` 을 선행 강제하지 않았는가** | **TP-N-40 · TP-N-25** |
| V-13 | **두 INSERT RPC 가 수정되지 않았는가** | **TP-N-50 ~ TP-N-53** |
| V-14 | External Provider Mapping negative — 특히 TP-X-10 | `601716` §7 |
| V-15 | `merchant_accounts` 컬럼 수 일치 · LegalEntity 참조 0건 · 순환 참조 없음 | TP-N-21 · TP-N-16 · TP-N-22 |
| V-16 | fail-closed posture | TP-P-33 · TP-N-11 · TP-N-13 |
| V-17 | §1.37 경계 준수 — `set_updated_at()`·role 명 불변 | TP-N-07 · TP-N-08 |
| V-18 | `catchmenu_hq` BASE TABLE 수 / `set_updated_at()` 트리거 수 | TP-R-01 · TP-R-02 |
| V-19 | **`stores` 참조 158개 함수 유효성** | TP-R-14 |
| V-20 | `stores` 의 `merchant_account_id`·`updated_at` 외 컬럼 불변 | TP-N-49 |
| V-21 | `0168`/`0169` checksum 동일 | TP-R-16 |
| V-22 | 허용 파일 목록 준수 | TP-B-01 · TP-B-02 |
| V-23 | G15 — `-StrictStage7` 포함, 두 파일 모두 | TP-M-02 · TP-M-03 |

### §8.3 이중 검증 (`000701` §35)

구현자(Codex)를 제외한 **2개 이상의 독립 행위자**가 §8.2 를 각각 수행한다.

> ⚠️ **Stage 6·9 검증자에게 N-5′ 를 함께 전달한다.**
> Logic `601713` 에는 backfill·트리거명 변경에 대응하는 불변조건이 없고,
> `601718`/`601719` 결과도 아직 설계 문서에 반영되지 않았다.
> **Logic 만 읽은 검증자는 이를 범위 초과로 판단하게 된다.**
> 근거는 `601702` §1.45·§1.37 보강과 `601718`/`601719` 다.

## §9 Rollback Policy · 경계 · 구현자 지시 경계

### §9.1 Rollback Policy

| # | 규칙 |
|---|---|
| R-1 | rollback 은 **역방향 신규 migration** 으로만 수행한다 |
| R-2 | rollback 순서는 **`0171` 역 → `0170` 역** |
| R-3 | `0171` 역 순서는 **stores FK/컬럼 제거 → `merchant_accounts` 행 제거 → 테이블 제거** |
| R-4 | Person 계열 rollback 대상 데이터는 없다(4테이블 0행). 위험은 **RLS·GRANT 조합의 비대칭 복원** |
| R-5 | rollback 후 `601716` §2.1 기준선 before 값이 복원되어야 한다 |
| R-6 | **`stores.updated_at` 은 복원되지 않는다.** M-2 가 갱신한 이전 값은 보존되지 않는다 — N-4′ |
| R-7 | rollback 판단은 Human 이 한다 |

### §9.2 Boundary With Related Workpackets

| 워크패킷 | 경계 |
|---|---|
| `601500` (1차 0-A) | 권위보류. `601505` §4 금지는 0-A-2 완료까지 유효(FO-33) |
| `601600` (역전파) | 권위보류. 판정은 `600020` §5 로 대체 |
| 0-A-2 | `tenant_status` / `isolation_state` — FO-33 |
| 0-B (Identity/Login/Session) | Staff / User / Session. `primary_owner_user_id` 새 어휘 |
| 0-C (Role/Permission/Authorization) | `merchant_accounts` 의 application access policy — §1.45 가 명시적 이관 |
| **후속 RPC alignment 나선 (번호 미정)** | **§4.4.3 H-1~H-4.** `provision_tenant` / `create_franchise_store` 정렬 후 `stores.merchant_account_id` NOT NULL 재판정. `601700` Readme §5 가 RPC 재작성을 파생 나선 소관으로 둔다 |
| Business Registration Intake 나선 (번호 미정) | §3 C-2. `010901` §11 intake 확보 후 `stores.legal_entity_id` NOT NULL 재판정 |
| Provider Integration (번호 미정) | External Provider Mapping — §4.6 |
| Franchise OS | `FranchiseAgreement` — §1.10 |

### §9.3 Codex Instruction Boundary

```text
Codex 는 Stage 7 Human Approval 이 명시적으로 허용 파일을 열거한 뒤에만 구현한다.
허용 파일 §1.1·§1.2 / 허용 DDL §1.3·§1.4 / 허용 DML §4.5 / 허용 동사 §1.6.
NOT NULL 을 걸지 않는다 (§1.5 · FO-13).
provision_tenant / create_franchise_store / onboard_tenant / update_business_hours 를
어떤 형태로도 수정하지 않는다 (§6.1).
불확실하면 중단하고 묻는다. 추론으로 범위를 넓히지 않는다.
Codex 는 자기 구현을 스스로 감사하거나 승인하지 않는다.
```

**중단 조건**

| # | 중단 조건 |
|---|---|
| S-1 | `601716` §2.1 기준선 재측정값이 before 값과 다르다 |
| S-2 | 허용 목록 밖 파일을 건드려야 한다는 판단이 든다 |
| S-3 | rename 만으로 Person 목표 상태에 도달할 수 없다 |
| S-4 | `merchant_accounts` 에 §4.1 의 5컬럼 외 필드가 필요하다 |
| S-5 | `stores` 에 `merchant_account_id` 외의 변경이 필요하다 |
| S-6 | backfill 값을 `tenants` 외의 원천에서 가져와야 한다 |
| S-7 | backfill 결과 행 수가 `tenants` 행 수와 다르다 |
| S-8 | **두 INSERT RPC 중 하나라도 고쳐야 한다는 판단이 든다** |
| S-9 | **`NOT NULL` 을 걸어야 검증이 통과한다는 판단이 든다** |
| S-10 | **`stores` 재측정 컬럼 수가 `601701` 의 16과 다르다** (N-2″) |
| S-11 | §7 의 blocker 중 하나가 구현 도중 범위에 걸린다 |
| S-12 | provider / external / mapping 관련 객체를 만들어야 한다는 판단이 든다 |

### §9.4 Acceptance Criteria

| # | 조건 |
|---|---|
| AC-1 | §8.1 V-1~V-9 충족 |
| AC-2 | 변경 파일이 §1 허용 목록의 부분집합 |
| AC-3 | §5 금지 파일 변경 0건 |
| AC-4 | §6 금지 조작 0건 — **§6.1 RPC 4건 무변경 포함** |
| AC-5 | §4.5 외의 DML 0건 |
| AC-6 | **`SET NOT NULL` 0건** |
| AC-7 | `601716` §13 Acceptance Criteria 충족 |
| AC-8 | §8.3 이중 검증 수행, N-5′ 가 검증자에게 전달됨 |
| AC-9 | §7 blocker 중 미해소분이 Stage 7 Approval 에 **제외 사실로 명시**되어 있다 |
| AC-10 | **§1.5 의 C-1·C-2 가 `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` 로, §4.4.3 의 H-1~H-4 가 이월 항목으로 Approval 에 명시되어 있다** |

> **AC-10 이 이번 판에서 가장 중요한 수용 조건이다.**
> C-1 이 `RESOLVED` 로 기록되면 **NOT NULL 요구가 폐기된 것으로 읽힌다.**
> 실제로는 요구가 살아 있고 이번 계약에서 적용할 수 없을 뿐이며,
> **H-1~H-4 를 수행할 후속 나선이 그 요구를 이어받는다.**

## §10 Approval State

| 단계 | 상태 |
|---|---|
| Stage 4 (ERD / Overview / Logic, Claude Code) | 완료 — `601705` / `601710` / `601713`. **단 §1.45·§1.37 보강 및 `601718`/`601719` 미반영 (N-5′)** |
| Stage 5 (Contract Drafting) | 완료 — 본 문서 및 `601716` (4판) |
| Stage 6 (Contract Verification) | 대기 — §37 에 따라 **Claude 제외**(계약 작성자) |
| Stage 7 (Human Approval) | 대기 |
| Stage 8 (Implementation, Codex) | 미착수 |

> **Stage 6 주의**(`000701` §37): `601716` 과 본 계약은 Claude 가 작성했으므로
> Claude 는 계약 검증에 참여하지 않는다. ERD/Overview/Logic 은 Claude Code 가 작성했으므로
> Claude Code 도 그 범위의 원작자다. 검증자는 그 둘을 제외해 구성한다(`601700` Readme §10.1).

> ⚠️ **Stage 7 이 승인 상태가 되기 전에는 `sql/migrations/0170_*.sql` 과 `0171_*.sql` 이
> 존재해서는 안 된다.** G15 가 커밋 시점에 이 표의 Stage 7 행을 읽는다(`000701` §6.11.1).

> ⚠️ **Stage 7 승인 시 함께 명시해야 하는 것**
>
> ```text
> 1. 허용 파일 목록 (§1.1·§1.2 를 확정하거나 축소)
> 2. §1.5 C-1 · C-2 의 이월 승인
>    — RESOLVED 가 아니라 DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT
> 3. §4.4.3 H-1 ~ H-4 를 후속 RPC alignment 나선으로 이월 (AC-10)
> 4. §4.1 컬럼명·타입 확정
> 5. N-2′ (stores backfill 이 파생임) · N-3′ (account_name 값 출처) 확인
> 6. N-2″ (stores 실제 컬럼 수) 재측정 결과
> 7. §7 blocker 중 미해소분과 제외 범위 (AC-9)
> 8. 검증 환경 (B-8) 및 tenants 행 수 (V-4)
> ```

## §11 근거 문서 목록 (`000701` §46)

| 문서 | 인용 절 | 권위 | 역할 |
|---|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4.1~§5.4.6, §5.4.10, §5.7, §5.11 | ACTIVE | ChangeContract 규격·저자 분리·충돌 처리 |
| `docs/000700_…/000701_…Pipeline.md` | §3, §6.11.1, §10, §14.5, §35, §37, §46, §47.1 | ACTIVE | Stage 게이트·불변 경계·이중 검증 |
| `docs/…/600020_Governance_…Authority_Reset.md` | §2, §5 | ACTIVE | `601500` 권위보류 |
| `docs/…/601700_Readme_…V2.md` | §4, **§5**, §10, §10.1 | 본 워크패킷 | RPC 재작성 파생 나선 소관 — §4.4.3 |
| `docs/…/601701_Register_Stage0_Evidence_Collection.md` | §4.5 D-3, E단계 | 본 워크패킷 | §4.1 파생 근거 · N-2″ |
| `docs/…/601702_Register_Stage1_Business_Rules.md` | §0, §1.2, §1.10, §1.18, §1.19, §1.22~§1.27, §1.31, §1.32, §1.34, §1.37(보강), §1.38, §1.39, §1.43, §1.44, §1.45, §2.2, §5 | 본 워크패킷 | **최우선 근거** — Human 선언 |
| `docs/…/601705_Diagram_…ERD.md` | §4.4, §4.6, §5.2, §8, §10 (O5·O18·O19) | 본 워크패킷 | 물리 정의 · Open Decisions |
| `docs/…/601710_Overview_…V2.md` | §2, §2.1~§2.3, **§3**, §3.1, §4, §5, §7 | 본 워크패킷 | 구현 대상 · RPC Out of Scope · 금지 조항 요구 |
| `docs/…/601711_…Cursor.md` / `601712_…Codex.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선(이중) |
| `docs/…/601713_Logic_…V2.md` | §1.1~§1.5 (I-1~I-42), §2~§6 | 본 워크패킷 | 불변조건 · 예외 · 미해결 |
| `docs/…/601714_…Cursor.md` / `601715_…Codex.md` | Environment, Q-2 ~ Q-8 | 본 워크패킷 | 갭 해소 실측(이중) |
| **`docs/…/601718_Evidence_Stores_Write_Path_Scan_Cursor.md`** | **Environment, S-1 ~ S-6** | **본 워크패킷** | **§4.4 판정의 직접 근거** |
| **`docs/…/601719_Evidence_Stores_Write_Path_Scan_Codex.md`** | **Environment, S-1 ~ S-6** | **본 워크패킷** | **동일(이중, `000701` §35)** |
| `docs/…/601716_TestPlan_…V2.md` | 전체 | 본 워크패킷 | 검증 요건의 실체 |
| `sql/migrations/CHANGELOG.md` | 2026-07-18 항목(phantom 컬럼 사례) · 2026-08-07 항목 · Convention status | 프로젝트 파일 | B-6 · N-2″ |
| `tools/Check-Governance.ps1` | G15 | 프로젝트 파일 | §10 게이트 실행 주체 |

**권위보류 문서 인용 — 명시**

| 문서 | 인용 위치 | 어떻게 썼는가 |
|---|---|---|
| `601505` §4 | FO-33 · §9.2 | 금지 조항이 0-A-2 완료까지 유효하다는 **사실**만 인용 |

`601501`~`601512` 의 설계 결론을 정답으로 전제한 곳은 없다(`600020` §2).

---

## Final Rule

```text
This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after Human Approval explicitly lists allowed files.
```

> **이번 판이 확정한 것은 하나다 — C-1 은 `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` 다.**
>
> 측정이 질문을 닫았고, 닫힌 답이 「지금은 못 건다」였다.
> 사유는 데이터가 아니라 **신규 Store 생성 경로 2건이 값을 공급하지 않는다**는 것이며,
> 그 2건을 고치는 일은 `601710` §3 이 이 나선 밖에 두었다.
>
> ```text
> 이번 계약   기존 행에 값을 채운다        제약은 걸지 않는다
> 후속 나선   생성 경로가 값을 공급하게 한다  그때 제약을 건다
> ```
>
> **`RESOLVED` 로 적으면 두 번째 줄이 사라진다.**
> §1.5 와 §4.4.3 이 그 줄을 문서에 남기기 위해 존재한다.
>
> 승인 시 Approval 과 이 계약이 충돌하면 **더 엄격한 경계가 이긴다**(`000001` §5.4.6).
