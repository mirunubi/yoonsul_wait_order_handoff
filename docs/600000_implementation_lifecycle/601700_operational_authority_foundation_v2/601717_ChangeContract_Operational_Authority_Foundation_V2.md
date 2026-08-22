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
| 2026-08-22 | 2판 — B-1 등 해소. 대상 2·3·4 편입. 판정 6건 + Blocker 13건 |
| 2026-08-22 | **3판** — B-2a/B-2b(`601702` §1.37 보강) · N-1/N-2(§1.45) · N-3(§2.2) · N-4(`601713` 병기) · N-6(§5) 해소. **backfill 이 허용 범위로 편입**. §1.5 조건부 1건으로 축소. 판정 6건 + Blocker 11건 |

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

이 계약은 상위 문서를 **옹호하지 않는다.** 불충분한 지점은 §7 에 blocker 로 기록했다.

### §0.1 2판 이후 무엇이 달라졌는가

2판이 기록한 blocker 13건 중 **7건이 Human 선언으로 해소**됐다.

| 2판 blocker | 판정 | 근거 |
|---|---|---|
| **B-2a** 트리거명 미선언 | **해소** | `601702` §1.37 「물리 식별자 정합화 범위」 — `trg_owners_updated_at` → `trg_persons_updated_at` |
| **B-2b** `owner_name` 미선언 | **해소** | 동일 — `owner_name` → **`person_name`** |
| **N-1** MA→Store enforcement 부적격 | **원인 해소, 잔여 존재** | `601702` §1.45 backfill 이 「데이터가 없다」를 없앴다. **NOT NULL 은 여전히 미판정** — §7.3 N-1′ |
| **N-2** 스키마·RLS/GRANT posture 미선언 | **해소** | `601702` §1.45 「배치」 + 「초기 보안 posture — fail-closed baseline」 |
| **N-3** 필드명·타입 소관 순환 | **해소** | `601702` §2.2 정정 — ChangeContract 소관으로 통일 |
| **N-4** 옛 서술 잔류 | **해소** | `601713` I-14 · §1.1 본문에 대체 관계 병기 |
| **N-6** §5 일자 표기 | **해소** | `601702` §5 — 「2026-08-22 (§1.34~§1.45)」 |

### §0.2 이번 판의 성격 변화 — 이 계약이 데이터를 허용한다

**2판까지 이 계약은 데이터 조작을 전면 금지했다.** `601702` §1.45 가 그것을 바꿨다.

```text
2판   FO-11  INSERT / UPDATE / DELETE — 어떤 테이블에도 금지
3판   FO-11  선언된 backfill 2건 외 금지
```

> ⚠️ **이 계약이 스스로 완화한 것이 아니다.**
> `601702` §1.45 가 「기존 Tenant → canonical backfill → MerchantAccount 생성」을
> 명시적으로 지시했다. 선언이 상위 근거다(`601702` §0).
>
> **다만 §1.45 는 seed 와 backfill 의 경계도 함께 그었다** —
> 「Tenant 가 3개면 3개, **Tenant 가 0개면 아무 행도 만들지 않는다**」.
> 이 계약은 그 경계를 §4.5 의 허용 DML 정의로 옮긴다.

### §0.3 이 계약이 판정한 6건

| # | 판정 대상 | 결론 | 절 |
|---|---|---|---|
| 1 | `owners → persons` 물리 변경 방법 | **`ALTER … RENAME` 계열만 허용.** 신규 생성 후 교체·호환 view 금지 | §2 |
| 2 | Store–LegalEntity `NOT NULL` enforcement | **부적격. 명시적 blocker 와 함께 이월** | §3 |
| 3 | 허용 파일 / 금지 파일 | migration 2건 + 색인 동기화 / X-1~X-21 | §1 · §5 |
| 4 | Stage 7 승인란 | **대기** | §10 |
| 5 | `merchant_accounts` 물리 표현 (필드명·타입) | **§4 에서 확정.** 스키마·posture 는 §1.45 가 확정했으므로 계약이 정하지 않고 승계 | §4 |
| 6 | MerchantAccount → Store enforcement | **backfill 허용, `NOT NULL` 은 이월.** 사유가 「데이터 없음」에서 **「런타임 영향 미측정」**으로 바뀌었다 | §4.4 |

### §0.4 이 계약이 판정하지 않은 것

**Store–LegalEntity 시점 관계의 물리 구조를 만들지 않는다.** §3.4 · §7.2 B-5.
**`stores.merchant_account_id` 의 `NOT NULL` 승격을 판정하지 않는다.** §4.4 · §7.3 N-1′.

## §1 Allowed — 허용 대상

### §1.1 허용 파일 — 구현(Stage 8)

| # | 경로 | 성격 | 제약 |
|---|---|---|---|
| A-1 | `sql/migrations/0170_person_vocabulary_normalization.sql` | 신규 | Person 계열 전용. 파일명은 제안이며 Stage 7 이 확정 |
| A-2 | `sql/migrations/0171_merchant_account_foundation.sql` | 신규 | MerchantAccount 계열 + backfill 전용. 동상 |

**A-1·A-2 가 허용 SQL 파일의 전부다.**

> **왜 2개인가**: 두 변경은 독립이며 rollback 단위가 다르다.
> Person 정규화는 기존 객체의 이름을 바꾸고, MerchantAccount 는 새 객체를 만든 뒤
> 데이터를 채우고 `stores` 에 컬럼을 추가한다. **한 파일에 합치면 한쪽 실패가 다른 쪽을 되돌린다.**

### §1.2 허용 파일 — 문서 동기화 (Stage 10, 기계적)

| # | 경로 | 허용 조작 |
|---|---|---|
| A-3 | `docs/…/601718_Module_*.md` | 신규 생성 (Stage 8 자기보고서) |
| A-4 | `601700_Readme_…V2.md` §8 File List | 행 추가 |
| A-5 | `docs/000005_Index_Document_Number.md` | 행 추가 |
| A-6 | `docs/000007_Map_Full_Directory.md` | 행 추가 |

`000001` §5.11 트리플 업데이트는 A-4·A-5·A-6 을 **같은 배치**에서 처리할 것을 요구한다.

### §1.3 허용 DDL — `0170` Person 계열

**대상 스키마는 `catchmenu_hq` 뿐이다.**

| # | 조작 | 대상 | 근거 |
|---|---|---|---|
| D-1 | `ALTER TABLE … RENAME TO` | `owners` → `persons` | `601702` §1.37 |
| D-2 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_person_roles.owner_id` → `person_id` | 동일 |
| D-3 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_representatives.owner_id` → `person_id` | 동일 |
| D-4 | `ALTER TABLE … RENAME COLUMN` | **`persons.owner_name` → `person_name`** | **§1.37 보강 (2판 B-2b 해소)** |
| D-5 | `ALTER TRIGGER … RENAME TO` | **`trg_owners_updated_at` → `trg_persons_updated_at`** | **§1.37 보강 (2판 B-2a 해소)** |
| D-6 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_person_roles_owner_id_fkey` → `…_person_id_fkey` | §1.37 |
| D-7 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_representatives_owner_id_fkey` → `…_person_id_fkey` | 동일 |
| D-8 | `ALTER INDEX … RENAME TO` | `owners_pkey` → `persons_pkey` | 동일 |
| D-9 | `ALTER INDEX … RENAME TO` | `idx_lepr_owner` → `idx_lepr_person` | 동일 |
| D-10 | `ALTER TABLE … DROP COLUMN` | `persons.is_active` | `601713` I-36 / §1.38 |
| D-11 | `ALTER TABLE … DROP CONSTRAINT` | `chk_lepr_ownership_percent` | `601713` I-37 / §1.39 |
| D-12 | `ALTER TABLE … DROP COLUMN` | `legal_entity_person_roles.ownership_percent` | 동일 |
| D-13 | `COMMENT ON TABLE` | `persons` — canonical 개념과 어긋나지 않는 문구 | `601713` I-15 |

> **D-11 을 D-12 보다 먼저 수행한다.** 제약을 남긴 채 컬럼을 지우면 `CASCADE` 가
> 필요해지고, `601702` §1.39 와 `601713` I-37 이 `CASCADE` 를 금지했다.

> ⚠️ **`uq_lepr_active` / `uq_ler_active` / `uq_ler_sole_active` 는 이름을 바꾸지 않는다.**
> 세 이름에 `owner` 문자열이 없고, 정의 안의 컬럼 참조는 D-2·D-3 으로 자동 갱신된다.

> ⚠️ **§1.37 이 정합화 범위와 함께 그 경계도 그었다.**
>
> ```text
> 직접 Owner semantic identifier   →  Person 으로 변경   (D-1 ~ D-9)
> generic technical identifier     →  유지
> ```
>
> **`catchmenu_common.set_updated_at()` 함수명과 `catchmenu_authority_owner` role 명은
> 변경 대상이 아니다**(§6 FO-9·FO-16). 트리거명은 바뀌지만 호출 대상 함수명은 그대로다.

### §1.4 허용 DDL — `0171` MerchantAccount 계열

| # | 조작 | 대상 | 근거 |
|---|---|---|---|
| D-14 | `CREATE TABLE` | **`catchmenu_hq.merchant_accounts`** — §4.1 의 5컬럼 | `601702` §1.44 · **§1.45 「배치」** |
| D-15 | `CREATE UNIQUE INDEX` 또는 `UNIQUE` 제약 | `merchant_accounts.tenant_id` 단독 | **§1.45 「관계의 물리 표현」** |
| D-16 | `CREATE TRIGGER` | `merchant_accounts` BEFORE UPDATE → `catchmenu_common.set_updated_at()` | §1.44 「수정 시각」 |
| D-17 | `ALTER TABLE … ENABLE / FORCE ROW LEVEL SECURITY` | `merchant_accounts` | **§1.45 fail-closed baseline** |
| D-18 | `ALTER TABLE … ADD COLUMN` | `stores.merchant_account_id` — **NULL 허용** | §1.26·§1.43 / Overview 대상 4 |
| D-19 | `ALTER TABLE … ADD CONSTRAINT … FOREIGN KEY` | `stores.merchant_account_id` → `merchant_accounts(id)`, `ON DELETE/UPDATE NO ACTION` | `fk_stores_legal_entity_id` 와 동일 관행(`601714` Q-4) |
| D-20 | `CREATE INDEX` | `stores.merchant_account_id` 조회 인덱스 | `idx_stores_legal_entity_id` 와 동일 관행(`601701`) |
| D-21 | `COMMENT ON TABLE / COLUMN` | `merchant_accounts` 및 신규 컬럼 | 어휘 정합 |

### §1.5 조건부 허용 — Human 판정 후에만

| # | 조작 | 대상 | 걸린 blocker |
|---|---|---|---|
| C-1 | `ALTER TABLE … ALTER COLUMN … SET NOT NULL` | `stores.merchant_account_id` | **N-1′** — §4.4 |

> **2판의 조건부 2건(C-1 트리거명 · C-2 `owner_name`)은 §1.37 보강으로 해소되어
> D-5 · D-4 로 이동했다.** 남은 조건부는 위 1건이며, 성격이 다르다 —
> **선언이 없어서가 아니라 실측이 없어서 걸린 항목**이다.
>
> **C-1 은 기본 상태가 "금지"다.** Stage 7 Approval 이 N-1′ 해소와 함께 명시하지 않으면 수행하지 않는다.

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
조건부     ALTER TABLE … ALTER COLUMN … SET NOT NULL        (C-1)
```

이 목록에 없는 동사는 전부 §6 금지다.

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
ALTER … RENAME          객체 OID 가 유지된다
                        FK · TRIGGER · RLS 플래그 · GRANT · PK 가 재선언 없이 따라간다
                        → I-1~I-4, I-9~I-14 가 자동 보존된다

CREATE 신규 + 교체       FK 2건 · TRIGGER 1건 · RLS ENABLE+FORCE · GRANT 4건 ·
                        PK · 부분 unique 3건을 전부 사람 손으로 재선언해야 한다
                        → Logic X-1 · X-2 · X-3 · X-4 · X-6 · X-7 · X-8 이
                          전부 실현 가능한 실패 지점이 된다
```

**Logic §3 의 11개 실패 지점 중 7개는 "신규 생성 후 교체"에서만 발생한다.**

### §2.4 rename 이 자동으로 해주지 않는 것

| 항목 | PostgreSQL 동작 | 계약 요구 |
|---|---|---|
| FK **정의** 안의 컬럼 참조 | 컬럼 rename 시 자동 갱신 | 별도 조치 불필요 |
| FK **제약 이름** | 자동 갱신되지 않음 | D-6 · D-7 |
| **인덱스 이름** | 자동 갱신되지 않음 | D-8 · D-9 |
| **트리거 이름** | 자동 갱신되지 않음 | **D-5** |
| 부분 unique 인덱스의 **정의** | 컬럼 rename 시 자동 갱신 | 이름 변경 금지 |
| 테이블 **코멘트** | 유지 | D-13 |

### §2.5 호환 계층을 금지하는 이유

`owners` view 를 남기면 legacy 어휘가 **다시 조회 가능한 canonical 표면**이 된다.
`601710` §2.1 이 「legacy `owners` terminology 를 authoritative 로 남기지 않는다」고 정했다.
데이터 0행·코드 참조 0건 상태에서 호환 계층이 보호할 호출자가 없다.

### §2.6 이 판정이 결정하지 않은 것

**`legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives` 테이블명은 유지한다.**
`601713` I-35 가 `legal_entity_representatives` 유지를 확정했고 나머지 둘의 개명 선언이 없다.

**`catchmenu_authority_owner` role 명과 `catchmenu_common.set_updated_at()` 함수명은 유지한다.**
`601702` §1.37 이 「이름에 `owner` 가 들어간다는 이유만으로 바꾸지 않는다」로
**명시적으로 제외**했다. 2판까지는 계약의 판단이었으나 이제 선언이다.

## §3 판정 2 — Store–LegalEntity NOT NULL enforcement eligibility

### §3.1 판정

**부적격(NOT ELIGIBLE).** `stores.legal_entity_id` 에 `NOT NULL` 을 걸지 않는다.
enforcement 는 **명시적 blocker 와 함께 이월**한다(`601710` §4 「미확보」 분기).

### §3.2 판정 근거 — Logic E-1~E-4 대조

| 조건 | 판정 | 근거 |
|---|---|---|
| E-1 모든 Store 가 검증된 business identity 확보 | **거짓** | `010901` §11 의 9개 intake 필드 중 실재 정확명 1건(`business_registration_number`), 나머지 8건 0건 (`601714`/`601715` Q-8) |
| E-2 그 identity 로 canonical LegalEntity 생성·연결 | **거짓** | `legal_entities` 0행 (`601701` §4.5 D-3) |
| E-3 mapping completeness — 미매핑 Store 0 | **거짓** | `stores` 1행 / 백필 0행 → 미매핑 1 |
| E-4 신규 onboarding 경로 강제 | **미확인** | `sales_lead`/`tenant_candidate` 0건. `tenant_onboarding_log` 는 intake 9필드를 담지 않는다 |

**`601710` §4 가 같은 결론을 독립적으로 재확인했다** — 「enforcement 는 여전히 부적격이다」.

### §3.3 §1.45 의 backfill 이 여기로 확장되지 않는다

`601702` §1.45 자신이 경계를 그었다.

```text
LegalEntity        외부 검증(사업자등록 intake)이 필요하다   →  §1.31 synthetic 금지 적용
MerchantAccount    Tenant 로부터 파생, 외부 검증 불요        →  backfill 허용
```

| 금지 | 근거 |
|---|---|
| 검증되지 않은 synthetic LegalEntity 생성 | `601713` I-28 / `601702` §1.31·§1.45 |
| placeholder 로 `stores.legal_entity_id` 백필 | 동일 |
| `store_operator_type` 값으로 LegalEntity 추론·배정 | `601713` I-30 / `601702` §1.32 |

### §3.4 시점 관계 물리 구조를 만들지 않는 이유

| # | 이유 |
|---|---|
| 1 | `601710` §4 의 적용 분기가 **「미확보 → 관계만 유지」** 이고, 같은 §4 가 「enforcement 는 여전히 부적격」을 명시했다 |
| 2 | I-41(유효기간 중첩 금지)의 검증 방식을 `601702` §1.34 가 「물리 설계에서 정한다」로 남겼는데, **필요한 확장(`btree_gist` 등) 설치 여부를 측정한 evidence 가 없다** |
| 3 | I-42 는 Store 의 현재값을 「권위 원본이 아니라 현재 포인터」로 규정한다. 시점 테이블 없이 포인터만 남기면 **권위 원본 없는 포인터**가 된다 |
| 4 | 검증할 데이터가 0행이다 |

**§7.2 B-5 로 남긴다.**

## §4 판정 5 — `merchant_accounts` 물리 표현

> `601702` §2.2 정정(2026-08-22)으로 필드명·타입의 소관이 **ChangeContract 로 통일**됐다.
> `601705` §10 O18 과 일치한다. **2판 N-3(순환 지시)은 해소됐다.**

### §4.1 확정 — 필드 구성

§1.44 의 최소 필드 4종을, §1.45 가 명시한 관계 표현과 `601701` E단계 실측 관행에 맞춰 표현한다.

| 선언 항목 | 물리 표현 | 파생 근거 |
|---|---|---|
| 식별자 (PK) | `id uuid primary key default gen_random_uuid()` | `tenants.id` / `stores.id` / `legal_entities.id` 가 모두 동일 형태(`601701` E단계, `601714` Q-8) |
| Tenant 참조 | **`tenant_id uuid not null`** + FK → `catchmenu_hq.tenants(id)` | **`601702` §1.45 가 이름·NOT NULL·UNIQUE 를 직접 명시.** 타입은 `tenants.id` 가 uuid PK 라는 실측에서 파생 |
| 계정 명칭 | `account_name text not null` | `tenants.tenant_name` / `stores.store_name` 이 `text NOT NULL`(`601701` E단계) |
| 생성·수정 시각 | `created_at timestamptz not null default now()` / `updated_at timestamptz not null default now()` | 네 테이블 전부 동일 형태 |

**총 5컬럼.** `601716` TP-N-21 이 컬럼 수 일치를 검사한다.

> **이것은 새 설계가 아니라 선언의 표현이다.**
> 타입·기본값·NOT NULL 은 전부 **인접 테이블의 실측 관행**에서 파생했다.
> `601713` I-39 가 금지한 「미채택 필드 추가」에 해당하는 항목은 없다.

### §4.2 확정 — 제약과 부속 객체

| # | 객체 | 정의 | 근거 |
|---|---|---|---|
| 1 | `uq_merchant_accounts_tenant` | `unique (tenant_id)` | **§1.45 「이것만으로 1:1 이 강제된다」** |
| 2 | `trg_merchant_accounts_updated_at` | `BEFORE UPDATE … EXECUTE FUNCTION catchmenu_common.set_updated_at()` | §1.44 「수정 시각」 |
| 3 | RLS | `ENABLE` + `FORCE`, POLICY 0건 | **§1.45 fail-closed baseline** |
| 4 | GRANT | `catchmenu_authority_owner` 외 확대 금지 | **동일** |

> **§1.45 가 posture 를 확정하면서 2판 N-2 가 해소됐다.**
> 이 계약은 더 이상 posture 를 "제안"하지 않는다 — 선언을 **승계**한다.
>
> §1.45: 「이것은 "임시 posture" 가 아니다. 기본 폐쇄 상태 자체는 계속 유지될 수 있다.
> 0-C 는 그 위에 **필요한 접근 정책만 추가**한다.」

### §4.3 확정 — 스키마 배치

**`catchmenu_hq`.** `601702` §1.45 「배치」가 직접 확정했다 —
「동일 Operational Authority Foundation 은 동일 schema 에 둔다.」

**2판에서 이 계약이 제안하고 Stage 7 확인을 요청했던 항목이며, 이제 선언이다.**

### §4.4 판정 6 — MerchantAccount → Store enforcement eligibility

**backfill 은 허용한다. `NOT NULL` 승격은 이월한다.**

**2판과 결론은 같으나 사유가 바뀌었다.**

```text
2판 사유   merchant_accounts 0행 / stores 1행
           → 채울 값이 없다. 데이터 생성 선언도 없다

3판 사유   §1.45 backfill 로 값은 채워진다
           → 채울 수 있다. 그러나 NOT NULL 이 무엇을 깨뜨리는지 모른다
```

| 조건 | 판정 | 근거 |
|---|---|---|
| 기존 데이터에 값을 채울 수 있는가 | **참** | §1.45 backfill + `stores.tenant_id` 가 NOT NULL(`601701` E단계) → 전 행 결정적 파생 |
| mapping completeness 를 만들 수 있는가 | **참** | 미매핑 Store 0 달성 가능 |
| **`NOT NULL` 이 기존 런타임을 깨뜨리지 않는가** | **미확인** | `601701` §4.5 D-3 은 `stores` 참조 함수가 **151개**라는 개수만 기록했다. **그중 `stores` 에 INSERT 하는 함수가 몇 개이며 새 컬럼을 공급하는지 실측이 없다** |

**세 번째 조건이 미확인이므로 C-1 을 조건부로 둔다.**

> ⚠️ **`601713` I-27 과의 긴장은 남아 있으나 성격이 달라졌다.**
>
> I-27 은 「Store 를 MerchantAccount 없이 Tenant 에 직접 매달지 않는다」를 요구한다.
> **backfill 후에는 실제로 그런 행이 0건이다**(`601716` TP-D-06).
> 남은 것은 **제약이 없어 앞으로 그런 행이 생길 수 있다**는 것뿐이다.
>
> ```text
> 2판   값도 없고 제약도 없다
> 3판   값은 있고 제약이 없다
> ```
>
> **이 계약은 어느 쪽이 옳은지 판정하지 않는다** — §7.3 N-1′.

### §4.5 확정 — 허용 DML (backfill)

`601702` §1.45 가 지시한 backfill 을 **정확히 2개 문장으로 한정**한다.

| # | 조작 | 정의 | 근거 |
|---|---|---|---|
| **M-1** | `INSERT INTO catchmenu_hq.merchant_accounts (tenant_id, account_name) SELECT … FROM catchmenu_hq.tenants` | **`tenants` 전 행에서 1:1 파생.** 리터럴 business data 금지 | **`601702` §1.45** |
| **M-2** | `UPDATE catchmenu_hq.stores SET merchant_account_id = … FROM catchmenu_hq.merchant_accounts WHERE stores.tenant_id = merchant_accounts.tenant_id` | **`stores.tenant_id` 경유 결정적 파생** | §1.26 구조 경로 — **§7.3 N-2′ (파생이며 직접 선언이 아니다)** |

**M-1 · M-2 가 허용 DML 의 전부다.**

**`account_name` 의 값 출처**: `tenants.tenant_name`.
§1.45 는 backfill 을 지시했으나 **명칭 값의 출처를 말하지 않았다.**
`tenants` 에서 결정적으로 파생 가능한 유일한 명칭 컬럼이며,
§1.45 의 「임의 business data 를 seed 하지 않는다」를 만족하는 유일한 선택이다.
**§7.3 N-3′ 로 기록하며 Stage 7 이 확인한다.**

> ⚠️ **M-1 · M-2 는 조건이 아니라 형태로 제한된다.**
>
> ```text
> 허용   INSERT … SELECT FROM tenants        원천 행에서 파생
> 금지   INSERT … VALUES (…)                 리터럴 주입
> ```
>
> `601716` TP-D-01(행 수 일치) · TP-N-45(리터럴 0건)가 이를 검사한다.
> **`tenants` 가 0행이면 M-1 은 0행을 만든다** — §1.45 가 요구한 동작이다.

> ⚠️ **M-2 는 `trg_stores_updated_at` 을 발동시켜 `stores.updated_at` 을 갱신한다.**
> 어느 문서도 이 부작용을 다루지 않았고 **rollback 으로 복원되지 않는다** — §7.3 N-4′.

## §4.6 판정 3 관련 — External Provider Mapping 명시적 금지 (`601710` §7 요구)

### §4.6.1 금지 조항

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

**마지막 항목이 3판에서 추가됐다.** backfill 이 들어오면서 **값의 출처**가 위험 표면이 됐다.

### §4.6.2 `merchant_accounts` 와 backfill 이 이 금지를 약화시키지 않는다

```text
merchant_accounts        CatchMenu SaaS 계약·관리 단위        CM-PLAT
van_merchant_id 등 5건   결제 가맹점 식별자                    외부 provider
```

`merchant_accounts` 를 채울 때 `catchmenu_integrations.pos_store_configs.merchant_id` 같은
외부 값을 끌어오는 것은 어휘상 자연스러워 보이지만,
**정확히 `601702` §1.43 이 금지한 provider identity 의 canonical 승격이다.**

**M-1 의 원천은 `catchmenu_hq.tenants` 하나뿐이다.** `601716` TP-X-10 이 검사한다.

## §5 Forbidden Files — 금지 파일 목록

**§1 에 없는 모든 파일이 금지다.** 아래는 실수 가능성이 높은 것을 명시한 것이며 한정 목록이 아니다.

### §5.1 절대 금지

| # | 경로 | 사유 |
|---|---|---|
| X-1 | `sql/migrations/0168_create_operational_authority_foundation.sql` | `000701` §14.5 · `601710` §5 동결 |
| X-2 | `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 동일 |
| X-3 | `sql/migrations/0000_*.sql` ~ `0167_*.sql` (기존 167개) | 동일 |
| X-4 | `sql/_excluded_from_local_replay/**` | 재생 제외 결정 파일 |
| X-5 | `sql/seed_yoonsul_menu.sql` · 기타 seed | §4.5 는 migration 내 backfill 만 허용한다 |
| X-6 | `sql/migrations/CHANGELOG.md` | 규약 상태 미결 — §7.2 B-6 |

### §5.2 상위 근거 문서

| # | 경로 | 사유 |
|---|---|---|
| X-7 | `601702_Register_Stage1_Business_Rules.md` | Human 전담. AI 수정 불가(`601702` §0) |
| X-8 | `601705_…ERD.md` · `601710_Overview_…V2.md` · `601713_Logic_…V2.md` | 2·4단계 상위 근거. 개정은 Stage 3/4 경로로만 |
| X-9 | `601716_TestPlan_…V2.md` · `601717_ChangeContract_…V2.md` | 본 계약 자신 포함. 개정은 Stage 6/7 경로로만 |
| X-10 | `601701` · `601703`~`601709` · `601711`·`601712` · `601714`·`601715` | Evidence / Register / Audit — 사후 수정 시 기준선 소멸 |
| X-11 | `docs/000001_Md_Rules.md` · `docs/000701_…Pipeline.md` | 거버넌스 문서 |
| X-12 | `docs/…/600020_…Authority_Reset.md` | 권위 판정 전문 |
| X-13 | `docs/…/601500_operational_authority_foundation/**` | 권위보류 대역 |

### §5.3 범위 밖

| # | 경로 | 사유 |
|---|---|---|
| X-14 | `apps/**` | 코드 참조 0건(`601711` P-5) |
| X-15 | `packages/**` | 동일 |
| X-16 | `catchmenu_app/**` | 동일 |
| X-17 | `tests/**` | 동일 |
| X-18 | `tools/**` | 검증 도구를 변경해 검사를 통과시키지 않는다 |
| X-19 | `supabase/**` | 런타임 설정 |
| X-20 | `.git/hooks/**` | 커밋 게이트 우회 금지 |
| X-21 | `data/**` · `scratch/**` · `sop/**` | 무관 |

## §6 Forbidden Operations — 금지 조작

### §6.1 물리 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-1 | Person 계열에서 신규 테이블 생성 (`persons` 를 포함해 어떤 이름으로도) | §2 판정 |
| FO-2 | `DROP TABLE` | 동일 |
| FO-3 | `owners` 이름의 VIEW / MATVIEW 생성 | §2.5 |
| FO-4 | `CASCADE` 사용 | `601702` §1.39 / I-37 |
| FO-5 | RLS POLICY 생성·삭제 — `merchant_accounts` 포함 | **`601702` §1.45 「Policy 0개」** · I-11 |
| FO-6 | `DISABLE` / `NO FORCE ROW LEVEL SECURITY` | I-10 / §1.45 |
| FO-7 | GRANT / REVOKE — `catchmenu_authority_owner` 4 privilege 확대·축소, `merchant_accounts` 신규 부여 포함 | **§1.45 「GRANT 는 `catchmenu_authority_owner` 외에 확대하지 않는다」** |
| FO-8 | 클라이언트 도달 가능 role(`anon`/`authenticated`/`service_role`)에 권한 부여 | **§1.45 「0-A 가 0-C 의 권한 정책을 선결정하는 것이 된다」** |
| FO-9 | role 생성·삭제·속성 변경 (`catchmenu_authority_owner` 개명 포함) | **`601702` §1.37 이 명시적 제외** |
| FO-10 | FK 참조 동작을 `NO ACTION` 이외로 변경 | I-3 |
| FO-11 | **§4.5 M-1 · M-2 외의 모든 `INSERT` / `UPDATE` / `DELETE`** | §4.5. **2판의 전면 금지를 §1.45 에 맞춰 좁힌 것이다** |
| FO-12 | `stores.legal_entity_id` 에 대한 모든 DDL·DML | §3.1 |
| FO-13 | `NOT NULL` 승격 — `stores.legal_entity_id` 는 절대, `stores.merchant_account_id` 는 C-1 승인 전까지 | §3.1 · §4.4 |
| FO-14 | `chk_lepr_role_type` 허용값 재정의 | 선언 없음 |
| FO-15 | 함수 생성·수정·삭제 (SECURITY DEFINER 포함) | `601700` Readme §5 |
| FO-16 | `catchmenu_common.set_updated_at()` 수정·개명 | **`601702` §1.37 이 명시적 제외.** 114개 트리거 공유 |
| FO-17 | `catchmenu_meta.migration_history` 직접 조작 | 이력 보존 |
| FO-18 | `tenants` 에 대한 모든 DDL 및 UPDATE | **§1.45 「`tenants.merchant_account_id` 를 두어 순환 참조를 만들지 않는다」**. `tenant_status`/`isolation_state` 는 FO-33 |
| FO-19 | `stores` 에 `merchant_account_id` 외의 컬럼 추가·변경·삭제 | D-18 한정. 151개 참조 함수(N-5) |

### §6.2 범위 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-20 | External Provider Mapping 물리 구현 | §4.6.1 |
| FO-21 | `merchant_accounts` 에 LegalEntity 참조 추가 | I-38 / §1.44·§1.23 |
| FO-22 | `merchant_accounts` 에 미채택·deferred 필드 추가 | I-39 |
| FO-23 | `merchant_companies` / `merchant_stores` 등 3층 구조 테이블 생성 | §1.25 / `601705` §4.6 |
| FO-24 | `merchant_accounts` 와 `tenants` 를 한 테이블로 합치기 | I-23 |
| FO-25 | **Tenant provisioning 경로(RPC·트리거) 생성·수정** | **§1.45 「Tenant provisioning 경로의 구현은 0-A 범위 밖」** / `601710` §3 |
| FO-26 | economic ownership 모델 생성 | §1.39 |
| FO-27 | Store 상태 3축 enum · 상태 컬럼 생성 | `601710` §3 |
| FO-28 | `OperatingGroup` / `company` / `business_unit` / `cross_business_link` 물리화 | `601710` §3 |
| FO-29 | Store–LegalEntity 시점 이력 테이블 생성 | §3.4 |
| FO-30 | 금전 객체 LegalEntity snapshot 컬럼 생성 | `601710` §2.3 — §1.35 원칙 전용 |
| FO-31 | Tenant 이전 절차·데이터 처리 객체 생성 | `601710` §2.3 — §1.36 원칙 전용 |
| FO-32 | 감사 이력 테이블 · 감사 트리거 생성 | `601713` §5 |
| FO-33 | Staff / User / Session / Role / Permission 객체 변경, `tenant_status`/`isolation_state` 조작, tenant `ACTIVE` 승격 | §1.18·§1.19 / `601505` §4 (0-A-2 완료까지 유효) |

> **FO-25 가 §1.45 의 가장 미끄러운 지점을 막는다.**
> §1.45 는 「신규 Tenant 생성 경로가 MerchantAccount 동시 생성을 책임진다」고 썼고,
> **구현자가 이를 "지금 만들라"로 읽을 여지가 있다.**
> 같은 절이 곧바로 「다만 Tenant provisioning 경로의 구현은 0-A 범위 밖」이라고 못박았다.

### §6.3 절차 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-34 | Stage 7 승인 전 migration 적용 또는 커밋 | `000701` §10 · §6.11.1 |
| FO-35 | `-- Workpacket: 601700` 헤더 누락 — **두 파일 모두** | `000701` §6.11.1 |
| FO-36 | 검증 도구를 수정해 검사를 통과시키는 행위 | X-18 |
| FO-37 | 구현자가 자기 구현을 감사·승인하는 행위 | `000701` §37 |
| FO-38 | `0170`/`0171` 각각을 2개 이상으로 분할 | 중간 상태 커밋 금지(X-1) |
| FO-39 | `0171` 을 `0170` 보다 먼저 적용 | 적용 순서 고정 |
| FO-40 | **과거 migration 파일에서 `owner_` 를 제거하려는 시도** | **`601702` §1.37 「검증 범위」 — 명시적 제외.** `000701` §14.5 |

## §7 Blocker

### §7.1 해소된 것 (기록 보존)

| # | blocker | 해소 근거 |
|---|---|---|
| B-1 | `MerchantAccount` 목표 물리 형태 | `601702` §1.44 |
| B-2a / B-2b | 트리거명 / `owner_name` 미선언 | **`601702` §1.37 보강** → D-5 · D-4 |
| B-3 / B-4 | `is_active` / `ownership_percent` 충돌 | `601713` I-36 · I-37 |
| B-6(1판) / B-7(1판) | §1.43 vs §3.1 / §1.34~§1.44 미반영 | `601710` §2.3 / `601713` I-34~I-42 |
| N-1 | MA→Store enforcement (원인) | **`601702` §1.45 backfill** — 잔여는 N-1′ |
| N-2 | 스키마·RLS/GRANT posture | **`601702` §1.45** |
| N-3 | 필드명·타입 소관 순환 | **`601702` §2.2 정정** |
| N-4 | 옛 서술 잔류 | **`601713` I-14 · §1.1 병기** |
| N-6 | §5 일자 표기 | **`601702` §5** |

### §7.2 남아 있는 것 — 처분 유효성 재확인

| # | Blocker | 처분이 여전히 유효한가 | 이 계약의 처리 |
|---|---|---|---|
| **B-5** | Store–LegalEntity 시점 관계 물리 구조 미정 | **유효.** `601710` §4 분기·확장 실측 부재 모두 변동 없음. §1.45 는 §1.31 경계에 따라 LegalEntity 로 확장되지 않는다 | FO-29. §3.4 |
| **B-6** | `CHANGELOG.md` 규약 상태 미결 | **유효.** 변동 없음 | X-6 |
| **B-7** | 재적용 동작 요구사항 미선언 | **유효하되 위험도 상승.** backfill INSERT 가 추가되어 재적용 시 중복 판정 문제가 새로 생겼다. `uq_merchant_accounts_tenant` 가 막지만 오류인지 무시인지 판정 기준이 없다 | Stage 7 |
| **B-8** | 검증 환경 미지정 | **유효하되 위험도 상승.** backfill 기대값이 `tenants` 행 수에 종속된다 | Stage 7. `601716` PRE-5 |
| **B-9** | 문서 정합화 시점 미정 | **유효.** `owners` 참조 문서 27~30건 | §1.2 는 색인 3종만 허용 |
| **N-5** | `stores` 참조 151개 함수의 형태 미측정 | **유효하되 성격 변화.** 회귀 범위 산정 문제였던 것이 **이제 C-1 승인 가부의 직접 근거**가 됐다 | FO-19. N-1′ 의 전제 |

### §7.3 새로 생긴 것

| # | Blocker | 사실 관계 | 이 계약의 처리 |
|---|---|---|---|
| **N-1′** | **`stores.merchant_account_id` NOT NULL 승격 가부 미판정** | §1.45 backfill 로 값은 채워진다. **그러나 `stores` 참조 151개 함수 중 `stores` 에 INSERT 하는 함수가 몇 개이며 새 컬럼을 공급하는지 실측이 없다**(N-5). NOT NULL 은 값을 공급하지 않는 INSERT 를 전부 깨뜨린다 | C-1 조건부. 기본 금지(FO-13) |
| **N-2′** | **`stores` backfill 이 §1.45 의 직접 선언이 아니다** | §1.45 의 backfill 문언은 **MerchantAccount 생성**만 다룬다. `stores.merchant_account_id` 를 `stores.tenant_id` 경유로 채우는 것은 §1.26 구조 경로에서의 **파생**이다. 결정적이지만 선언된 문장은 아니다 | M-2 로 허용하되 **파생임을 명시. Stage 7 확인 필요** |
| **N-3′** | **backfill 의 `account_name` 값 출처 미선언** | §1.44 가 계정 명칭을 필수로 두고 §1.45 가 backfill 을 지시했으나, **값의 출처는 어느 문서에도 없다** | `tenants.tenant_name` 을 §4.5 에서 지정. **Stage 7 확인 필요** |
| **N-4′** | **backfill UPDATE 의 `stores.updated_at` 부작용 미논의** | M-2 가 `trg_stores_updated_at` 을 발동시켜 감사 컬럼을 갱신한다. **rollback 으로 복원되지 않는다** | §9.1 R-6 에 비가역 지점으로 명시 |
| **N-5′** | **§1.45 와 §1.37 보강이 ERD/Overview/Logic 에 미반영** | §1.44 때와 달리 이번 선언은 설계 문서로 전파되지 않았다. `601705`/`601710`/`601713` 어디에도 backfill · 배치 · fail-closed posture 가 없고, `601713` I-34 는 여전히 「FK 제약명·인덱스명」까지만 적는다 | 이 계약은 기대값 일부를 **Logic 이 아니라 선언에서 직접 도출**했다. 그 사실을 명시한다 |

> **N-5′ 는 2판 B-7 과 같은 형태의 재발이다.**
> `601702` §0 이 「이미 이 선언을 근거로 만들어진 산출물의 재검토 범위를 함께 판정한다」고
> 요구했는데, §1.45·§1.37 보강에 대한 그 판정이 문서로 없다.
>
> **이번에는 결과가 다르다.** 2판에서는 선언과 Logic 이 **충돌**했지만(I-14 vs I-36),
> 이번에는 Logic 에 **대응 항목이 아예 없다.** 충돌이 없으므로 구현은 가능하나,
> **Stage 6 검증자가 Logic 만 읽으면 backfill 과 트리거명 변경을 범위 초과로 판단하게 된다.**

> **N-1′ 이 이번 판의 유일한 실질적 미완결이다.**
> 대상 4는 이제 구조가 있고 값도 채워지지만 **제약이 없다.**
> N-5 의 측정 한 번이면 판정할 수 있다 —
> 「151개 중 `stores` 에 INSERT 하는 함수가 몇 개이며, 그것들이 새 컬럼을 공급하는가」.

## §8 Required Verification

### §8.1 착수 직전 게이트

| # | 항목 | 미충족 시 |
|---|---|---|
| V-1 | §10 Stage 7 이 승인 상태 | 착수 금지 |
| V-2 | §7 blocker 중 착수 범위에 걸린 것이 해소 또는 명시적 제외됨 | 해당 범위 제외 |
| V-3 | `601716` §2.1 기준선 BL-1~BL-27 재측정 완료 | 착수 금지 |
| V-4 | **`tenants` 행 수 재측정 완료** (`601716` PRE-5) | backfill 기대값 미확정 — 착수 금지 |
| V-5 | 검증 환경 확정(B-8) | 착수 금지 |
| V-6 | §4.1 의 컬럼명·타입이 Stage 7 에서 확정됨 | `601716` §4.3 기대값 확정 불가 — 착수 금지 |
| V-7 | N-2′ · N-3′ 이 Stage 7 에서 확인됨 | M-2 및 `account_name` 값 출처 미승인 — 해당 범위 제외 |
| V-8 | 구현자가 상위 문서·본 문서의 원작자가 아님 | 배정 재조정(`000701` §37) |

### §8.2 구현 후 검증

**`601716` 의 전 항목을 수행한다.** 특히 아래는 생략 불가다.

| # | 항목 | 대응 Test ID |
|---|---|---|
| V-9 | negative 검증 전건 | `601716` §5 |
| V-10 | **backfill 이 선언된 파생인가** — 행 수 일치·고아 0·리터럴 0 | TP-D-01~TP-D-07, TP-N-42~TP-N-45 |
| V-11 | **External Provider Mapping negative** — 특히 **TP-X-10**(backfill 원천이 `tenants` 뿐) | `601716` §7 |
| V-12 | `merchant_accounts` 컬럼 수 일치 · LegalEntity 참조 0건 | TP-N-21 · TP-N-16 |
| V-13 | **순환 참조 없음** — `tenants.merchant_account_id` 미생성 | TP-N-22 |
| V-14 | fail-closed posture — RLS `ENABLE`+`FORCE`, POLICY 0, 클라이언트 role GRANT 0 | TP-P-33 · TP-N-11 · TP-N-13 |
| V-15 | **§1.37 경계 준수** — `set_updated_at()` 함수명·`catchmenu_authority_owner` role 명 불변 | TP-N-07 · TP-N-08 |
| V-16 | `catchmenu_hq` BASE TABLE 수 = 21 / `set_updated_at()` 트리거 = 115 | TP-R-01 · TP-R-02 |
| V-17 | **`stores` 참조 151개 함수 유효성** | TP-R-14 · TP-RT-02 (N-5) |
| V-18 | `stores` 의 `merchant_account_id`·`updated_at` 외 컬럼 불변 | TP-N-49 |
| V-19 | `0168`/`0169` checksum 동일 | TP-R-16 |
| V-20 | 허용 파일 목록 준수 | TP-B-01 · TP-B-02 |
| V-21 | G15 — `-StrictStage7` 포함, 두 파일 모두 | TP-M-02 · TP-M-03 |

### §8.3 이중 검증 (`000701` §35)

구현자(Codex)를 제외한 **2개 이상의 독립 행위자**가 §8.2 를 각각 수행한다.

> ⚠️ **Stage 6·9 검증자에게 N-5′ 를 함께 전달한다.**
> Logic `601713` 에는 backfill·트리거명 변경에 대응하는 불변조건이 없다.
> **Logic 만 읽은 검증자는 이를 범위 초과로 판단하게 된다.**
> 근거는 `601702` §1.45 와 §1.37 보강이다.

## §9 Rollback Policy · 경계 · 구현자 지시 경계

### §9.1 Rollback Policy

| # | 규칙 |
|---|---|
| R-1 | rollback 은 **역방향 신규 migration** 으로만 수행한다. `0170`/`0171` 을 수정·삭제하지 않는다 |
| R-2 | rollback 순서는 **`0171` 역 → `0170` 역** 이다 |
| R-3 | `0171` 역 순서는 **stores FK/컬럼 제거 → `merchant_accounts` 행 제거 → 테이블 제거** |
| R-4 | Person 계열 rollback 대상 데이터는 없다(4테이블 0행). 위험은 **RLS·GRANT 조합의 비대칭 복원** |
| R-5 | rollback 후 `601716` §2.1 기준선 before 값이 복원되어야 한다 |
| R-6 | **`stores.updated_at` 은 복원되지 않는다.** M-2 가 갱신한 이전 값은 어디에도 보존되지 않는다. **완전 복원이 아니라는 사실을 rollback 계획에 명시한다** — N-4′ |
| R-7 | rollback 판단은 Human 이 한다. 구현자가 스스로 되돌리고 기록하지 않는 것을 금지한다 |

### §9.2 Boundary With Related Workpackets

| 워크패킷 | 경계 |
|---|---|
| `601500` (1차 0-A) | 권위보류. 설계 결론 미사용. `601505` §4 금지는 0-A-2 완료까지 유효(FO-33) |
| `601600` (역전파) | 권위보류. 판정은 `600020` §5 로 대체 |
| 0-A-2 | `tenant_status` / `isolation_state` — FO-33 |
| 0-B (Identity/Login/Session) | Staff / User / Session — FO-33. `primary_owner_user_id` 새 어휘도 여기 |
| 0-C (Role/Permission/Authorization) | **`merchant_accounts` 의 application access policy — `601702` §1.45 가 명시적으로 이관** |
| Tenant provisioning 경로 | **MerchantAccount 동시 생성 구현 — §1.45 가 책임 소재만 확정. FO-25** |
| Provider Integration (번호 미정) | External Provider Mapping — §4.6 |
| Franchise OS | `FranchiseAgreement` — §1.10 |

### §9.3 Codex Instruction Boundary

```text
Codex 는 Stage 7 Human Approval 이 명시적으로 허용 파일을 열거한 뒤에만 구현한다.
허용 파일 §1.1·§1.2 / 허용 DDL §1.3·§1.4 / 허용 DML §4.5 / 허용 동사 §1.6.
merchant_accounts 의 이름·타입은 §4.1 이 확정한 것만 사용한다.
backfill 은 M-1 · M-2 두 문장뿐이며 원천은 catchmenu_hq.tenants 와 catchmenu_hq.stores 뿐이다.
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
| S-6 | **backfill 값을 `tenants` 외의 원천에서 가져와야 한다** |
| S-7 | **backfill 결과 행 수가 `tenants` 행 수와 다르다** |
| S-8 | Tenant provisioning 경로를 수정해야 한다는 판단이 든다 |
| S-9 | §7 의 blocker 중 하나가 구현 도중 범위에 걸린다 |
| S-10 | provider / external / mapping 관련 객체를 만들어야 한다는 판단이 든다 |

### §9.4 Acceptance Criteria

| # | 조건 |
|---|---|
| AC-1 | §8.1 V-1~V-8 충족 |
| AC-2 | 변경 파일이 §1 허용 목록의 부분집합 |
| AC-3 | §5 금지 파일 변경 0건 |
| AC-4 | §6 금지 조작 0건 |
| AC-5 | **§4.5 외의 DML 0건** |
| AC-6 | `601716` §13 Acceptance Criteria AC-1~AC-12 충족 |
| AC-7 | §8.3 이중 검증 수행, N-5′ 가 검증자에게 전달됨 |
| AC-8 | §7 blocker 중 미해소분이 Stage 7 Approval 에 **제외 사실로 명시**되어 있다 |

> **AC-8 이 없으면 "blocker 를 잊은 것"과 "blocker 를 알고 제외한 것"이 구분되지 않는다.**
> 1차 0-A 실패의 형태가 정확히 이것이다 — `601505` §10 이 스스로 `Stage 7 대기` 라고
> 기록하고 있었는데도 아무도 발견하지 못했다(`000701` §6.11.1 근거 사례).

## §10 Approval State

| 단계 | 상태 |
|---|---|
| Stage 4 (ERD / Overview / Logic, Claude Code) | 완료 — `601705` / `601710` / `601713`. **단 §1.45·§1.37 보강 미반영 (N-5′)** |
| Stage 5 (Contract Drafting) | 완료 — 본 문서 및 `601716` (3판) |
| Stage 6 (Contract Verification) | 대기 — §37 에 따라 **Claude 제외**(계약 작성자) |
| Stage 7 (Human Approval) | 대기 |
| Stage 8 (Implementation, Codex) | 미착수 |

> **Stage 6 주의**(`000701` §37): `601716` 과 본 계약은 Claude 가 작성했으므로
> Claude 는 계약 검증에 참여하지 않는다. ERD/Overview/Logic 은 Claude Code 가 작성했으므로
> Claude Code 도 그 범위의 원작자다. 검증자는 그 둘을 제외해 구성한다(`601700` Readme §10.1).

> ⚠️ **Stage 7 이 승인 상태가 되기 전에는 `sql/migrations/0170_*.sql` 과 `0171_*.sql` 이
> 존재해서는 안 된다.** `tools/Check-Governance.ps1` 의 G15 가 커밋 시점에 이 표의
> Stage 7 행을 읽는다(`000701` §6.11.1). `-StrictStage7` 또는 `GOVERNANCE_STRICT=1` 에서
> ERROR 로 승격된다.

> ⚠️ **Stage 7 승인 시 함께 명시해야 하는 것**
>
> ```text
> 1. 허용 파일 목록 (§1.1·§1.2 를 확정하거나 축소)
> 2. §1.5 조건부 C-1 (stores.merchant_account_id NOT NULL) 의 허용 여부
>    — 허용하려면 N-5 측정이 선행되어야 한다
> 3. §4.1 컬럼명·타입 확정
> 4. N-2′ (stores backfill 이 파생임) · N-3′ (account_name 값 출처) 확인
> 5. §7 blocker 중 미해소분과 제외 범위 (AC-8)
> 6. 검증 환경 (B-8) 및 tenants 행 수 (V-4)
> ```

## §11 근거 문서 목록 (`000701` §46)

| 문서 | 인용 절 | 권위 | 역할 |
|---|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4.1~§5.4.6, §5.4.10, §5.7, §5.11 | ACTIVE | ChangeContract 규격·저자 분리·충돌 처리 |
| `docs/000700_…/000701_…Pipeline.md` | §3, §6.11.1, §10, §14.5, §35, §37, §46, §47.1 | ACTIVE | Stage 게이트·불변 경계·이중 검증 |
| `docs/…/600020_Governance_…Authority_Reset.md` | §2, §5 | ACTIVE | `601500` 권위보류 |
| `docs/…/601700_Readme_…V2.md` | §4, §5, §10, §10.1 | 본 워크패킷 | In/Out of Scope · Actor 배정 |
| `docs/…/601701_Register_Stage0_Evidence_Collection.md` | §4.5 D-3, E단계 (`tenants`·`stores` 컬럼·행수·함수 실측) | 본 워크패킷 | §4.1 파생 근거 · N-5 |
| `docs/…/601702_Register_Stage1_Business_Rules.md` | §0, §1.2, §1.10, §1.18, §1.19, §1.22, §1.23, §1.25~§1.27, §1.31, §1.32, §1.34, **§1.37(보강 포함)**, §1.38, §1.39, §1.43, §1.44, **§1.45**, §2.2, §5 | 본 워크패킷 | **최우선 근거** — Human 선언 |
| `docs/…/601705_Diagram_…ERD.md` | §4.4, §4.6, §5.2 U1·U2, §8, §10 (O5·O18·O19) | 본 워크패킷 | 물리 정의 · Open Decisions |
| `docs/…/601710_Overview_…V2.md` | §2, §2.1~§2.3, §3, §3.1, §4, §5, §7 | 본 워크패킷 | 구현 대상 · 제외 · 금지 조항 요구 |
| `docs/…/601711_…Cursor.md` / `601712_…Codex.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선(이중) |
| `docs/…/601713_Logic_…V2.md` | §1.1~§1.5 (I-1~I-42, I-14·§1.1 병기 포함), §2~§6 | 본 워크패킷 | 불변조건 · 예외 · 미해결 |
| `docs/…/601714_…Cursor.md` / `601715_…Codex.md` | Environment, Q-2 ~ Q-8 | 본 워크패킷 | 갭 해소 실측(이중) |
| `docs/…/601716_TestPlan_…V2.md` | 전체 | 본 워크패킷 | 검증 요건의 실체 |
| `sql/migrations/CHANGELOG.md` | 2026-08-07 항목 · Convention status | 프로젝트 파일 | B-6 |
| `tools/Check-Governance.ps1` | G15 | 프로젝트 파일 | §10 게이트 실행 주체 |

**권위보류 문서 인용 — 명시**

| 문서 | 인용 위치 | 어떻게 썼는가 |
|---|---|---|
| `601505` §4 | FO-33 · §9.2 | 금지 조항이 0-A-2 완료까지 유효하다는 **사실**만 인용. `601710` §5 를 경유 |
| `601505` §10 | AC-8 주석 | 1차 0-A 실패의 **형태**로만 인용 |

`601501`~`601512` 의 설계 결론을 정답으로 전제한 곳은 없다(`600020` §2).

---

## Final Rule

```text
This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after Human Approval explicitly lists allowed files.
```

> **이번 판에서 이 계약의 성격이 바뀌었다.**
> 2판까지는 「구조만 만들고 데이터는 건드리지 않는다」였다.
> `601702` §1.45 가 backfill 을 지시하면서 **이 계약이 데이터 조작을 허용한다.**
> 그래서 §4.5 가 허용 DML 을 **두 문장으로 한정**하고, 그 형태(`… SELECT FROM`)까지 고정한다.
> **조건이 아니라 형태로 제한해야 seed 와 backfill 이 구분된다.**
>
> **남은 미완결은 하나다.** `stores.merchant_account_id` 는 값이 채워지지만 제약이 없다.
> 2판의 「데이터가 없어서 못 걸었다」가 **「걸면 무엇이 깨지는지 몰라서 미뤘다」**로 바뀌었고,
> 그 판정에 필요한 것은 N-5 측정 한 번이다.
>
> 이월 사실이 Stage 7 Approval 에 명시되지 않으면,
> 다음 나선은 **"관계가 강제되어 있다"** 고 읽게 된다.
>
> 승인 시 Approval 과 이 계약이 충돌하면 **더 엄격한 경계가 이긴다**(`000001` §5.4.6).
