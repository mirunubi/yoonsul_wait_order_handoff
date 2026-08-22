# 601716_TestPlan_Operational_Authority_Foundation_V2.md

Status: Draft
Lifecycle: TestPlan
Gate Classification: 0-A v2 Operational Authority Foundation Test Plan Draft
Runtime Implementation Authorization: Not Granted
Owner: Stage 2 (Claude) — 저자 분리(`000001` §5.4.2)
Last Updated: 2026-08-22

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-22 | 초안 — 4단계 TestPlan |
| 2026-08-22 | 2판 — B-1 · B-7 해소 반영. 대상 2·3·4 BLOCKED 해제 |
| 2026-08-22 | **3판** — B-2a/B-2b(`601702` §1.37 보강) · N-1/N-2(§1.45) · N-3(§2.2) · N-4(`601713` 병기) · N-6(§5) 해소 반영. **backfill 이 검증 대상으로 편입**. 신규 blocker 5건 |

## §0 성격과 저자

`000001` §5.4.4 TestPlan 이다. **구현을 승인하지 않는다.**

**저자 분리**(`000001` §5.4.2)

| 산출물 | 저자 |
|---|---|
| ERD `601705` / Overview `601710` / Logic `601713` | Claude Code |
| 선언 `601702` | Human |
| **TestPlan `601716` / ChangeContract `601717`** | **Claude (본 문서 저자)** |

이 TestPlan 은 상위 문서를 **소비**하며 **옹호하지 않는다.**
불충분한 지점은 §12 에 사실로 기록했고, 임의로 메우지 않았다.

### §0.1 2판 이후 무엇이 달라졌는가

2판이 기록한 blocker 12건 중 **7건이 Human 선언으로 해소**됐다.

| 2판 blocker | 판정 | 근거 |
|---|---|---|
| **B-2a** 트리거명 미선언 | **해소** | `601702` §1.37 「물리 식별자 정합화 범위」 — `trg_owners_updated_at` → `trg_persons_updated_at` 명시 |
| **B-2b** `owner_name` 미선언 | **해소** | 동일 — `owner_name` → **`person_name`** 명시 |
| **N-1** MA→Store enforcement 부적격 | **원인 해소, 잔여 존재** | `601702` §1.45 가 backfill 을 확정해 「데이터가 없다」는 원인은 사라졌다. **다만 NOT NULL 은 여전히 걸 수 없다** — §12 N-1′ |
| **N-2** 스키마 배치·RLS/GRANT posture 미선언 | **해소** | `601702` §1.45 「배치」(`catchmenu_hq`) · 「초기 보안 posture」(RLS `ENABLE`+`FORCE`, Policy 0개, GRANT 미확대) |
| **N-3** 필드명·타입 소관 순환 | **해소** | `601702` §2.2 정정 — ChangeContract 소관으로 통일. `601705` O18 과 일치 |
| **N-4** 옛 서술 잔류 | **해소** | `601713` I-14 와 §1.1 본문에 대체 관계 병기. 보존 대상 목록에 명시 |
| **N-6** §5 일자 표기 | **해소** | `601702` §5 — 「2026-08-22 (§1.34~§1.45)」 |

### §0.2 이번 판의 성격 변화 — backfill 이 들어왔다

**2판까지 이 워크패킷은 「데이터를 만들지 않는다」가 전제였다.**
`601702` §1.45 가 그것을 바꿨다.

```text
2판   구현 대상 = 구조뿐          negative: INSERT/UPDATE/DELETE 0건
3판   구현 대상 = 구조 + backfill  negative: 선언된 backfill 2건 외 0건
```

> ⚠️ **검사를 느슨하게 바꾼 것이 아니다.**
> 「데이터 조작이 0건인가」는 선언된 backfill 과 임의 seed 를 구분하지 못한다.
> **「조작된 것이 선언된 파생뿐인가」로 대조 대상을 명시한다.**
>
> `601702` §1.45 자신이 같은 구분을 요구한다 —
> 「Tenant 가 3개면 MerchantAccount 3개, **Tenant 가 0개면 아무 행도 만들지 않는다**」.
> **행 수가 원천 테이블 행 수와 일치하는지가 seed 와 backfill 을 가르는 검사다.**

**이 TestPlan 이 하지 않는 것**

| # | 하지 않는 것 | 소관 |
|---|---|---|
| 1 | 새 정책 결정 | Human (`601702`) |
| 2 | 물리 변경 방법·필드명·타입 판정 | ChangeContract `601717` |
| 3 | 허용·금지 파일 확정 | ChangeContract `601717` §1·§5 |
| 4 | 남은 모순의 해소 | §12 에 blocker 로 기록만 |
| 5 | DB 재조회 | `601701`/`601711`/`601712`/`601714`/`601715` 가 이미 수행 |

## §1 Test Scope

| Overview §2 대상 | 취급 | 2판 대비 |
|---|---|---|
| 1. canonical `Person` 물리 표현 | **전면 검증** (§4.1) | 트리거명·`person_name` 이 조건부 → **확정 기대값**으로 전환 |
| 2. persistent `MerchantAccount` | **전면 검증 + backfill 검증** (§4.2·§4.4) | 스키마·posture·backfill 이 기대값으로 확정 |
| 3. Tenant ↔ MerchantAccount (1:1) | **전면 검증** (§4.2) | 강제 방향(`merchant_accounts.tenant_id` 단방향)이 확정 |
| 4. MerchantAccount → Store (1:N) | **구조 + backfill 검증, enforcement negative** (§4.2·§4.4·§5.6) | backfill 로 관계가 실현됨. NOT NULL 은 여전히 이월 |
| 5. Store–LegalEntity target invariant | **negative 검증만** (§5.4) | 변동 없음 |

**검증 대상 물리 객체** (`catchmenu_hq`)

```text
owners                        → persons        7컬럼 → 6컬럼, owner_name → person_name
                                                trg_owners_updated_at → trg_persons_updated_at
legal_entity_person_roles     owner_id → person_id, ownership_percent 제거
legal_entity_representatives  owner_id → person_id
merchant_accounts             신규 + backfill (tenants 행 수만큼)
stores                        merchant_account_id 추가 + backfill
legal_entities · tenants      무변경 (tenants 는 읽기만)
```

## §2 Preconditions

| # | 전제 | 확인 방법 | 미충족 시 |
|---|---|---|---|
| PRE-1 | ChangeContract `601717` §10 의 Stage 7 이 승인 상태 | 문서 확인 + G15 | 착수 금지 |
| PRE-2 | §12 blocker 중 착수 범위에 걸린 것이 해소 또는 명시적 제외됨 | Approval | 해당 범위 제외 |
| PRE-3 | 검증 환경의 최신 migration 이 `0169` | `migration_history` 상위 1행 | 기준선 재수립 |
| PRE-4 | 기준선 재측정 완료 (§2.1) | 아래 표 | 사후 비교 불가 |
| PRE-5 | **`tenants` 행 수 재확인** | `select count(*) from catchmenu_hq.tenants` | backfill 기대값이 확정되지 않음 — 착수 금지 |
| PRE-6 | 검증자가 원작자가 아님 (`000701` §37) | 지시문 서두에 원작자 명시 | 검증 무효 |

> **PRE-5 가 이번 판에서 새로 필요해졌다.**
> backfill 결과 행 수의 기대값이 `tenants` 행 수에 **종속**된다.
> 기준선 실측은 1행(`601701` E단계)이지만, 재측정 없이 1을 상수로 쓰면
> 환경이 다를 때 검사가 조용히 틀린 값을 통과시킨다.

### §2.1 기준선 — 사후 비교용 실측값

| # | 항목 | before | after | 출처 |
|---|---|---:|---:|---|
| BL-1 | `owners` 행 수 | 0 | 0 | `601711` P-3 / `601712` P-3 |
| BL-2 | `legal_entity_person_roles` 행 수 | 0 | 0 | 동일 |
| BL-3 | `legal_entity_representatives` 행 수 | 0 | 0 | 동일 |
| BL-4 | `legal_entities` 행 수 | 0 | 0 | `601711` P-3 |
| BL-5 | `stores` 행 수 | 1 | 1 | `601701` §4.5 D-3 |
| BL-6 | `stores.legal_entity_id` NOT NULL 행 수 | 0 | 0 | 동일 |
| BL-7 | `catchmenu_hq` BASE TABLE 수 | 20 | **21** | `601714`/`601715` 환경 절 |
| BL-8 | `owners` 참조 FUNCTION | 0 | 0 | `601711` P-1 / `601714` Q-4 |
| BL-9 | `owners` 참조 VIEW / MATVIEW | 0 | 0 | `601711` P-1 |
| BL-10 | `owners` RLS 플래그 | `relrowsecurity=true`, `relforcerowsecurity=true` | 동일(대상 `persons`) | `601711` P-1 |
| BL-11 | `owners` GRANT (grantee ≠ postgres) | 4 (`catchmenu_authority_owner`, `is_grantable=NO`) | 4 | `601711` P-1 #15~#18 |
| BL-12 | `set_updated_at()` 호출 non-internal 트리거 | 114 | **115** | `601714`/`601715` Q-3 |
| BL-13 | Person 계열 4테이블 참조 **타 스키마** FK | 0 | 0 | `601714`/`601715` Q-4 |
| BL-14 | Person 계열 4테이블 참조 동일 스키마 FK | 5 | 5 | `601714` Q-4 |
| BL-15 | 이름에 `merchant` 가 든 **테이블** | 0 | **1** | `601714`/`601715` Q-5 |
| BL-16 | 이름에 `merchant` 가 든 **컬럼** | 5 | **7** | `601714`/`601715` Q-5 — `merchant_accounts.tenant_id` 는 미해당, `stores.merchant_account_id` + `merchant_accounts` 자체 컬럼 반영은 §4.3 이름 확정 후 |
| BL-17 | 앱·패키지·테스트·seed 의 `owners` 참조 | 0 | 0 | `601711` P-5 / `601712` P-5 |
| BL-18 | `chk_lepr_role_type` 허용값 | 5개 | 동일 | `601714`/`601715` Q-2 |
| BL-19 | `owners` CHECK 제약 | 0 | 0 | 동일 |
| BL-20 | `catchmenu_hq.tenants` | 10컬럼, **1행**, RLS ENABLE+FORCE, `id uuid PK` | **무변경** | `601701` E단계 |
| BL-21 | `catchmenu_hq.stores` | 16컬럼, 1행, RLS ENABLE+FORCE, `legal_entity_id` nullable | **17컬럼**, 그 외 무변경 | `601701` E단계 |
| BL-22 | `stores` 를 직접 참조하는 FUNCTION | 151 | 151 | `601701` §4.5 D-3 |
| BL-23 | `tenants` 를 직접 참조하는 FUNCTION | 10 (전부 SECURITY DEFINER) | 10 | `601701` E단계 |
| BL-24 | **`merchant_accounts` 행 수** | (테이블 없음) | **`tenants` 행 수와 동일 = 1** | `601702` §1.45 backfill |
| BL-25 | **`stores.merchant_account_id` NOT NULL 행 수** | (컬럼 없음) | **1** (= `stores` 행 수) | §1.45 파생 — §12 N-2′ |
| BL-26 | **`stores.updated_at`** | 기존 값 | **변경됨** (backfill UPDATE 가 `trg_stores_updated_at` 발동) | §12 N-4′ |
| BL-27 | `tenants.tenant_status` / `isolation_state` | `TRIAL` / `NONE` | **무변경** | `601701` — `601505` §4 금지 유효 |

> ⚠️ **BL-24 는 상수가 아니라 함수다.** 기대값은 `tenants` 행 수이며,
> PRE-5 에서 재측정한 값을 쓴다. **1이라는 숫자를 하드코딩하지 않는다.**
>
> ⚠️ **BL-26 은 승인이 필요한 부작용이다.** backfill UPDATE 는 감사 컬럼을 건드린다.
> 어느 문서도 이를 다루지 않았다 — §12 N-4′.

### §2.2 두 조사 환경의 차이

| 항목 | `601701`/`601711`/`601712` | `601714`/`601715` |
|---|---|---|
| 이미지 태그 | `postgres:17.6.1.140` | `postgres:17.6.1.156` |
| 최신 migration | `0169` | `0169` |
| BASE TABLE 총계 | — | 243 (`601714`) / 247 (`601715`) |

> **총계 차이는 집계 기준 차이다** — `601714` 는 `pg_catalog`(64)+`information_schema`(4) 제외,
> `601715` 는 `pg_catalog` 만 제외. 차이 4는 `information_schema` 와 일치한다. 모순이 아니다.
>
> ⚠️ **이미지 태그 차이는 다르다.** 어느 환경에서 구현·검증할지 **여전히 미선언** — §12 B-8.
> **backfill 이 들어온 이번 판에서는 이 미선언이 더 중요해졌다.**
> 두 환경의 `tenants` 행 수가 같다는 보장이 없다(PRE-5).

## §3 Test ID 체계

```text
TP-P-nn   Positive        목표 상태가 실제로 만들어졌는가
TP-N-nn   Negative        만들지 않기로 한 것이 만들어지지 않았는가
TP-D-nn   Data            backfill 이 선언된 파생인가 (3판 신설)
TP-R-nn   Regression      건드리지 않기로 한 것이 그대로인가
TP-B-nn   Boundary        허용·금지 파일 경계
TP-M-nn   Migration       migration 파일 규격
TP-X-nn   External        External Provider Mapping negative (§7)
TP-RB-nn  Rollback        되돌릴 수 있는가
```

**판정값은 PASS / FAIL / BLOCKED 셋뿐이다.** `BLOCKED` 는 PASS 가 아니다.

## §4 Positive Tests

### §4.1 대상 1 — canonical `Person`

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-P-01 | `catchmenu_hq.persons` 가 BASE TABLE 로 존재 | 1건 | `601702` §1.1·§1.37 |
| TP-P-02 | `persons` PK 가 `id uuid` 단일 컬럼 | 1건 | `601713` I-9 |
| TP-P-03 | `legal_entity_person_roles.person_id` 존재 | 1건 | `601713` I-34 |
| TP-P-04 | `legal_entity_representatives.person_id` 존재 | 1건 | 동일 |
| TP-P-05 | 두 FK 가 **동시에** `persons.id` 를 참조 | 2건 | `601713` I-1·I-2, X-1 |
| TP-P-06 | 두 FK 의 `ON DELETE`/`ON UPDATE` 가 `NO ACTION` | 2건 모두 | I-3, X-2 |
| TP-P-07 | FK 제약명이 `..._person_id_fkey` | 2건 | `601702` §1.37 |
| TP-P-08 | **트리거명이 `trg_persons_updated_at`** 이고 `catchmenu_common.set_updated_at()` 을 호출 | 1건 | **`601702` §1.37 보강** |
| TP-P-09 | `uq_lepr_active` 정의가 `(legal_entity_id, person_id, role_type)` active 부분 unique | 1건 | I-5, X-4 |
| TP-P-10 | `uq_ler_active` 정의가 `(legal_entity_id, person_id)` active 부분 unique | 1건 | I-6, X-4 |
| TP-P-11 | `uq_ler_sole_active` 존재·정의 불변 | 1건 | I-7, X-4 |
| TP-P-12 | Person 기준 역할 조회 인덱스 존재, 이름이 `person` 기준 | 1건 | I-8, `601702` §1.37 |
| TP-P-13 | `persons` PK 인덱스명이 `person` 기준 | 1건 | `601702` §1.37 |
| TP-P-14 | `persons` RLS 가 `ENABLE` **그리고** `FORCE` | 둘 다 true | I-10, X-6 |
| TP-P-15 | `catchmenu_authority_owner` → `persons` GRANT 4건, `is_grantable = NO` | 4건 | I-12, X-7 |
| TP-P-16 | 소유자(`postgres`) 기본 privilege 구성 불변 | BL-11 대비 동일 | I-13 |
| TP-P-17 | **`persons.is_active` 가 존재하지 않는다** | 0건 | I-36 / §1.38 |
| TP-P-18 | **`persons.person_name` 이 존재하고 `NOT NULL`** | 1건 | **`601702` §1.37 보강** |
| TP-P-19 | `persons` 가 **6컬럼** — `id` · `person_name` · `contact_phone_hash` · `contact_email` · `created_at` · `updated_at` | 6컬럼 | I-14(I-36 으로 대체) ∩ §1.37 보강 |
| TP-P-20 | **`legal_entity_person_roles.ownership_percent` 가 존재하지 않는다** | 0건 | I-37 / §1.39 |
| TP-P-21 | `chk_lepr_ownership_percent` 가 존재하지 않는다 | 0건 | I-37 |
| TP-P-22 | `legal_entity_representatives` 테이블명 유지 | 유지 | I-35 |
| TP-P-23 | `persons` 테이블 코멘트가 canonical 개념과 어긋나지 않음 | 문자열 확인 | I-15 |
| TP-P-24 | **canonical schema 에 `owner_` 로 시작하는 식별자 0건** | 0건 | **`601702` §1.37 「검증 범위」** |

> ⚠️ **TP-P-24 의 범위는 `601702` §1.37 이 명시적으로 좁혔다.**
>
> ```text
> 검사 대상   0-A 이후 canonical physical object
> 검사 제외   역사 문서 · 과거 migration 파일 (000701 §14.5 불변)
> ```
>
> **과거 migration 에서 `owner_` 0건을 요구하지 않는다.**
> `catchmenu_authority_owner` role 과 `catchmenu_common.set_updated_at()` 은
> §1.37 이 명시적으로 제외한 대상이며 **TP-P-24 의 FAIL 사유가 아니다.**

### §4.2 대상 2·3·4 — `MerchantAccount` 구조

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-P-25 | `catchmenu_hq.merchant_accounts` 가 BASE TABLE 로 존재 | 1건 | **`601702` §1.45 「배치」** — `catchmenu_hq` |
| TP-P-26 | 식별자(PK)가 존재하고 단일 컬럼 | 1건 | §1.44 필수 |
| TP-P-27 | `merchant_accounts.tenant_id` 가 존재하고 `catchmenu_hq.tenants` 를 FK 참조 | 1건 | **§1.45 「관계의 물리 표현」** |
| TP-P-28 | `merchant_accounts.tenant_id` 가 `NOT NULL` | 참 | 동일 |
| TP-P-29 | `merchant_accounts.tenant_id` 에 `UNIQUE` 제약 존재 | 1건 | 동일 — 1:1 강제 |
| TP-P-30 | 계정 명칭 컬럼이 존재하고 `NOT NULL` | 1건 | §1.44 필수 |
| TP-P-31 | 생성·수정 시각 컬럼 2종 존재 | 2건 | §1.44 필수 |
| TP-P-32 | `merchant_accounts` 에 `BEFORE UPDATE` 트리거 존재, `set_updated_at()` 호출 | 1건 | §1.44 「수정 시각」 |
| TP-P-33 | `merchant_accounts` RLS 가 `ENABLE` **그리고** `FORCE` | 둘 다 true | **§1.45 fail-closed baseline** |
| TP-P-34 | `stores.merchant_account_id` 가 존재하고 `merchant_accounts` 를 FK 참조 | 1건 | §1.26·§1.43, Overview 대상 4 |
| TP-P-35 | 그 FK 의 `ON DELETE`/`ON UPDATE` 가 `NO ACTION` | 참 | `fk_stores_legal_entity_id` 와 동일 관행 |
| TP-P-36 | `stores.merchant_account_id` 조회 인덱스 존재 | 1건 | `idx_stores_legal_entity_id` 와 동일 관행 |
| TP-P-37 | `merchant_accounts` 와 `tenants` 가 **별도 테이블**로 유지 | 2건 | I-23 |

### §4.3 판정값이 ChangeContract 에 종속되는 항목

TP-P-26·TP-P-30·TP-P-31·TP-P-34 는 **컬럼명과 타입을 명시하지 않았다.**
`601702` §1.44 가 「무엇이 필요한가」까지만 확정했고, §2.2 정정으로 표현이
**ChangeContract 소관**으로 통일됐다(`601705` §10 O18 과 일치 — 2판 N-3 해소).

**ChangeContract `601717` §4 가 확정한 이름·타입으로 기대값을 확정한 뒤 실행한다.**

> `tenant_id` 만은 §1.45 가 이름까지 명시했으므로 TP-P-27~TP-P-29 는 확정 기대값이다.

### §4.4 backfill — 선언된 파생인가

> `601702` §1.45: 「Tenant 가 3개면 대응하는 MerchantAccount 3개를 만든다.
> **Tenant 가 0개면 아무 행도 만들지 않는다.**」

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-D-01 | `merchant_accounts` 행 수 = **`tenants` 행 수** | 일치 (PRE-5 재측정값) | **§1.45** |
| TP-D-02 | 모든 `tenants.id` 가 정확히 1개의 `merchant_accounts` 행과 대응 | 누락 0 · 중복 0 | §1.45 — 1:1 |
| TP-D-03 | `merchant_accounts` 에 대응 `tenants` 행이 없는 고아 행 0건 | 0건 | §1.45 |
| TP-D-04 | 계정 명칭이 **기존 `tenants` 행에서 파생**됐고 임의 리터럴이 아니다 | 파생 확인 | §1.45 「임의 business data 를 seed 하지 않는다」. 값 출처는 §12 N-3′ |
| TP-D-05 | `stores.merchant_account_id` 가 `stores.tenant_id` 를 통해 결정된 값과 일치 | 전 행 일치 | §1.26 구조 경로. §12 N-2′ |
| TP-D-06 | `stores` 중 `merchant_account_id` 가 NULL 인 행 0건 | 0건 | 동일 |
| TP-D-07 | backfill 이 **기존 행을 추가·삭제하지 않았다** — `tenants` · `stores` 행 수 불변 | BL-5 · BL-20 유지 | §1.45 「migration 이 미래 Tenant 를 만들지 않는다」 |

> **TP-D-01 이 seed 와 backfill 을 가르는 단 하나의 검사다.**
> 행이 존재하는지가 아니라 **원천 행 수와 정확히 일치하는지**를 본다.
> 하드코딩된 1행을 넣어도 TP-P-25 는 통과하지만 TP-D-01·TP-D-02 는 잡는다.

## §5 Negative Tests

### §5.1 legacy 어휘가 authoritative 로 남지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-01 | `catchmenu_hq.owners` 가 relation 으로 존재하지 않음 | 0건 | `601710` §2.1 |
| TP-N-02 | `owners` 이름의 **호환 VIEW / MATVIEW 미생성** | 0건 | `601710` §2.1 |
| TP-N-03 | `owner_id` / `owner_name` 컬럼이 canonical schema 에 남지 않음 | 0건 | `601702` §1.37 보강 |
| TP-N-04 | `owners` 를 참조하는 FUNCTION 이 새로 생기지 않음 | 0건 (BL-8) | `601711` P-1 |
| TP-N-05 | `is_active` 가 `persons` 에 다른 이름으로 되살아나지 않음 | 0건 | I-36 |
| TP-N-06 | `ownership_percent` 가 다른 테이블·이름으로 옮겨지지 않음 | 0건 | I-37 / §1.39 |
| TP-N-07 | **`catchmenu_common.set_updated_at()` 함수명이 바뀌지 않음** | 불변 | **`601702` §1.37 — generic technical identifier 는 유지** |
| TP-N-08 | **`catchmenu_authority_owner` role 명이 바뀌지 않음** | 불변 | 동일 |

> **TP-N-07·TP-N-08 은 이번 판에서 새로 필요해졌다.**
> §1.37 보강이 정합화 범위를 넓히면서 **과잉 적용의 여지도 함께 만들었다.**
> 선언 자신이 그 경계를 그었으므로, 경계를 넘었는지도 검사한다.

### §5.2 RLS / 권한 조합이 조용히 뒤바뀌지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-09 | `persons` 의 RLS POLICY 0건 | 0건 | I-11, X-8 |
| TP-N-10 | 나머지 3테이블의 RLS POLICY 0건 유지 | 0건 | 동일 |
| TP-N-11 | **`merchant_accounts` 의 RLS POLICY 0건** | 0건 | **§1.45 「Policy 0개 — application access contract 를 만들지 않는다」** |
| TP-N-12 | `catchmenu_authority_owner` 의 `rolbypassrls=true`, `rolcanlogin=false` 유지 | 유지 | `601714`/`601715` Q-4 |
| TP-N-13 | **클라이언트 도달 가능 role(`anon`/`authenticated`/`service_role`)에 `merchant_accounts` GRANT 0건** | 0건 | **§1.45 「`GRANT SELECT TO authenticated` 같은 조항을 지금 넣으면 0-A 가 0-C 의 권한 정책을 선결정한다」** |
| TP-N-14 | `catchmenu_authority_owner` 의 privilege 가 4건에서 축소되지도 않음 | 정확히 4건 | I-12 |
| TP-N-15 | `tenants` / `stores` 의 기존 RLS 플래그·정책 불변 | 불변 | I-17 |

### §5.3 `merchant_accounts` 가 선언 범위를 넘지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-16 | **LegalEntity 참조 컬럼·FK 없음** | 0건 | I-38 / §1.44·§1.23 |
| TP-N-17 | `primary_owner_user_id` 또는 대체 컬럼 없음 | 0건 | I-39 — 미채택 |
| TP-N-18 | 서비스 상태 / 체험 상태 컬럼 없음 | 0건 | I-39 — 미채택 |
| TP-N-19 | 청구·계약 연락처 컬럼 없음 | 0건 | I-39 — 미채택 |
| TP-N-20 | `000170` §4 그 외 권장 필드 없음 | 0건 | I-39 — deferred |
| TP-N-21 | **컬럼 수가 §1.44 최소 필드 수와 정확히 일치** | 일치 | I-39 |
| TP-N-22 | **`tenants.merchant_account_id` 가 생성되지 않음 — 순환 참조 없음** | 0건 | **§1.45 「`tenants.merchant_account_id` 를 두어 순환 참조를 만들지 않는다」** |
| TP-N-23 | `merchant_companies` / `merchant_stores` 등 3층 구조 테이블 미생성 | 0건 | §1.25 / `601705` §4.6 |
| TP-N-24 | `merchant_accounts` 가 `catchmenu_hq` 외 schema 에 생성되지 않음 | 0건 | §1.45 「배치」 |

> **TP-N-22 가 §1.45 의 방향 결정을 검사한다.**
> 1:1 을 양쪽에서 강제하려는 시도는 자연스러운 실수이며, 그 결과가 순환 참조다.

### §5.4 Store–LegalEntity — enforcement 를 걸지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-25 | `stores.legal_entity_id` 가 여전히 NULL 허용 | `is_nullable = YES` | `601710` §4 / `601717` §3 |
| TP-N-26 | `legal_entities` 행 수가 여전히 0 | 0행 | I-28 |
| TP-N-27 | `stores.legal_entity_id` 백필 0행 유지 | 0행 | I-28 |
| TP-N-28 | `store_operator_type` 근거 LegalEntity 배정 로직 미생성 | 0건 | I-30 |
| TP-N-29 | Store–LegalEntity 시점 이력 테이블 미생성 | 0건 | §12 B-5 |
| TP-N-30 | `stores.legal_entity_id` 에 대한 어떤 DDL·DML 도 없음 | 0건 | `601717` §3 |

> ⚠️ **§1.45 의 backfill 이 LegalEntity 로 확장되지 않는다.**
> §1.45 자신이 그 경계를 그었다 — 「§1.31 의 synthetic identity 금지는 **LegalEntity 에 대한 것**이다.
> LegalEntity 는 외부 검증(사업자등록 intake)이 필요하나, MerchantAccount 는 Tenant 로부터 파생된다.」
> **TP-N-26·TP-N-27 이 그 경계가 지켜졌는지를 본다.**

### §5.5 선언되지 않은 것을 만들지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-31 | economic ownership 모델 미생성 | 0건 | §1.39 |
| TP-N-32 | Store 상태 3축 enum / 상태 컬럼 미생성 | 0건 | `601710` §3 |
| TP-N-33 | `OperatingGroup` / `company` / `business_unit` 테이블 미생성 | 0건 | `601710` §3 |
| TP-N-34 | `cross_business_link` 물리 구조 미생성 | 0건 | `601710` §3 |
| TP-N-35 | 감사 이력 테이블 / 감사 트리거 미생성 | 0건 | `601713` §5 |
| TP-N-36 | Staff / User / Session / Role / Permission 객체 미변경 | 0건 | §1.18·§1.19 |
| TP-N-37 | 금전 객체 LegalEntity snapshot 컬럼 미생성 | 0건 | `601710` §2.3 — §1.35 는 원칙 전용 |
| TP-N-38 | Tenant 이전 절차·데이터 처리 객체 미생성 | 0건 | `601710` §2.3 — §1.36 은 원칙 전용 |
| TP-N-39 | **Tenant provisioning 경로(RPC·트리거)가 수정되지 않음** | 0건 | **§1.45 — 책임 소재만 확정, 구현은 `601710` §3 Out of Scope** |

> **TP-N-39 가 §1.45 의 가장 미끄러운 지점을 막는다.**
> §1.45 는 「신규 Tenant 생성 경로가 MerchantAccount 동시 생성을 책임진다」고 썼다.
> **구현자가 이를 "지금 만들라"로 읽을 여지가 있다.**
> 같은 절이 곧바로 「다만 Tenant provisioning 경로의 구현은 0-A 범위 밖」이라고 못박았다.

### §5.6 MerchantAccount → Store enforcement 를 걸지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-40 | `stores.merchant_account_id` 가 **NULL 허용** | `is_nullable = YES` | §12 N-1′ — `601717` §4.4 |
| TP-N-41 | `merchant_accounts.tenant_id` 는 **NOT NULL** (반대 방향은 강제됨) | `is_nullable = NO` | §1.45 |

> ⚠️ **TP-N-40 과 TP-D-06 은 함께 읽어야 한다.**
> 컬럼은 NULL 허용이지만 **실제로 NULL 인 행은 0건**이다.
> 값은 채워졌고 제약은 걸리지 않았다 — 이것이 이번 나선의 정확한 결과다.
> 「데이터가 없어서 못 걸었다」가 아니라 **「걸 수 있는지 판정할 실측이 없어서 미뤘다」** 이다(§12 N-1′).

### §5.7 데이터 조작이 선언된 파생뿐인가

> **2판의 「INSERT/UPDATE/DELETE 0건」을 대체한다.** §0.2 참조.

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-42 | migration 전체의 `INSERT` 문이 **`merchant_accounts` 대상 1건뿐** | 정확히 1건 | §1.45 |
| TP-N-43 | migration 전체의 `UPDATE` 문이 **`stores.merchant_account_id` 대상 1건뿐** | 정확히 1건 | §1.45 파생 |
| TP-N-44 | migration 전체의 `DELETE` 문 0건 | 0건 | 선언 없음 |
| TP-N-45 | 두 DML 이 **기존 행에서 파생**되며 business data 리터럴을 포함하지 않는다 | 리터럴 0건 | §1.45 「임의 business data 를 seed 한다 ❌」 |
| TP-N-46 | Person 계열 4테이블에 DML 0건 — 전부 0행 유지 | 0행 | BL-1~BL-4 |
| TP-N-47 | seed SQL 미변경 | 0건 | `601711` P-5 |
| TP-N-48 | `tenants` 행이 수정되지 않음 — `tenant_status`/`isolation_state` 포함 | 불변 | BL-27, `601505` §4 |
| TP-N-49 | `stores` 의 **`merchant_account_id`·`updated_at` 외 컬럼이 수정되지 않음** | 15컬럼 불변 | BL-26 — §12 N-4′ |

## §6 Regression Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-R-01 | `catchmenu_hq` BASE TABLE 수 = **21** | 21 (BL-7) | 20이면 `merchant_accounts` 미생성, 22면 rename 대신 신규 생성이 남은 것 |
| TP-R-02 | `set_updated_at()` 호출 non-internal 트리거 총계 = **115** | 115 (BL-12) | 114 면 트리거 누락, 116 이상이면 범위 초과 |
| TP-R-03 | `set_updated_at()` 정의 불변 (`SECURITY DEFINER`, `search_path=pg_catalog`, 본문 동일) | 불변 | `601714`/`601715` Q-3 |
| TP-R-04 | `legal_entities` 11컬럼 불변 | 불변 | `601714`/`601715` Q-8 |
| TP-R-05 | `tenants` 10컬럼 불변 | 불변 | BL-20 |
| TP-R-06 | `stores` 가 정확히 **17컬럼** | 17 | BL-21 |
| TP-R-07 | `chk_legal_entities_*` 3건 불변 | 불변 | `601714`/`601715` Q-2 |
| TP-R-08 | `chk_ler_*` / `chk_lepr_effective_range` 불변 | 불변 | 동일 |
| TP-R-09 | `chk_tenants_*` 4건 · `chk_stores_*` 불변 | 불변 | `601701` E단계 |
| TP-R-10 | `chk_lepr_role_type` 허용값 5개 불변 | BL-18 | 재정의 선언 없음 |
| TP-R-11 | `fk_stores_legal_entity_id` 불변 | 불변 | `601714` Q-4 |
| TP-R-12 | 타 스키마 → Person 계열 4테이블 FK 0건 유지 | 0건 (BL-13) | `601714`/`601715` Q-4 |
| TP-R-13 | 앱·패키지·테스트·seed 의 `owners`/`owner_id` 참조 0건 유지 | 0건 (BL-17) | `601711` P-5 |
| TP-R-14 | **`stores` 를 직접 참조하는 151개 FUNCTION 이 전부 유효** | 151건 유효 | BL-22 — §12 N-5 |
| TP-R-15 | **`tenants` 를 직접 참조하는 10개 FUNCTION 이 전부 유효** | 10건 유효 | BL-23 |
| TP-R-16 | `0168`/`0169` 파일 checksum 이 `migration_history` 기록값과 동일 | 동일 | `000701` §14.5 |
| TP-R-17 | `migration_history` 의 기존 행이 수정·삭제되지 않음 | 불변 | 이력 보존 |
| TP-R-18 | 기존 RPC 시그니처 변경 0건 | 0건 | `601700` Readme §5 |

> **TP-R-14 가 이 워크패킷 최대의 회귀 표면이다.**
> `owners` 는 참조 함수가 0개였지만 **`stores` 는 151개**다(`601701` §4.5 D-3).
> 이번 판은 `stores` 에 컬럼을 추가하고 **UPDATE 까지 수행**한다.

## §7 External Provider Mapping — negative 검증 (`601710` §7 필수)

> ⚠️ **이 절은 "만들었는가"를 묻지 않는다. "만들지 않았는가"를 묻는다.**
> `601710` §2.3 이 「§1.43 은 §3.1 이 Deferred 로 처리했다」로 확정했다.

### §7.1 금지 대상 — 하나라도 발견되면 FAIL

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-X-01 | provider mapping 테이블 미생성 | 0건 | `601710` §3.1 |
| TP-X-02 | 기존 테이블에 외부 provider 전용 컬럼 미추가 (`external_merchant_id` / `external_store_code` / `provider_id` / `terminal_id` 등) | 0건 | `601710` §3.1 |
| TP-X-03 | provider contract 를 추정한 schema·타입·제약 미생성 | 0건 | `601710` §3.1 |
| TP-X-04 | `stores` 에 늘어난 컬럼이 **MerchantAccount 참조 1개뿐** | 정확히 1개 | TP-R-06 |
| TP-X-05 | 이름에 `merchant` 가 든 **테이블** 증가분이 **`merchant_accounts` 1건뿐** | 정확히 1건 | BL-15 |
| TP-X-06 | 이름에 `merchant` 가 든 **컬럼** 증가분이 선언된 것뿐 | 대조 일치 | BL-16 |
| TP-X-07 | 특정 벤더명(TOSS / OKPOS / KICC / Smartcast 등)을 담은 신규 객체 미생성 | 0건 | `601710` §3.1 |
| TP-X-08 | `catchmenu_integrations`/`catchmenu_payment` 의 기존 5개 `merchant` 컬럼이 canonical identity 로 승격되지 않음 | 0건 | `601702` §1.43 |
| TP-X-09 | **`merchant_accounts` 가 provider 계열 테이블로 향하는 FK 0건** | 0건 | `601702` §1.43 — canonical 과 provider 는 매핑 관계이지 동일시 대상이 아니다 |
| TP-X-10 | **backfill 이 외부 provider 값을 참조하지 않는다** — `merchant_accounts` INSERT 의 원천이 `tenants` 뿐 | 원천 1개 | **§1.45 + §1.43** |
| TP-X-11 | `stores.id` 를 외부 provider merchant id 와 동일시하는 제약·주석 미도입 | 0건 | `601710` §3.1 |

> ⚠️ **TP-X-10 이 이번 판에서 새로 필요해졌다.**
> backfill 이 들어오면서 **값의 출처**가 검사 대상이 됐다.
> `merchant_accounts` 를 채울 때 `catchmenu_integrations.pos_store_configs.merchant_id` 같은
> 외부 값을 끌어오는 것은 어휘상 자연스러워 보이지만,
> **정확히 §1.43 이 금지한 provider identity 의 canonical 승격이다.**

### §7.2 확인해야 하는 것

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-X-12 | ChangeContract `601717` 이 provider mapping 물리 구현을 **명시적으로 금지**하는 조항을 포함 | 조항 존재 | `601710` §7 |
| TP-X-13 | migration 본문에 provider / external / mapping 관련 스키마 객체가 남지 않음 | 0건 | `601710` §3.1 |

## §8 Boundary / Forbidden File Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-B-01 | `git diff --name-only` 가 `601717` §1 허용 목록의 부분집합 | 부분집합 | `601717` §1 |
| TP-B-02 | `601717` §5 금지 파일 중 변경된 것 0건 | 0건 | `601717` §5 |
| TP-B-03 | `sql/migrations/` 기존 169개 파일 미수정 | 0건 | `000701` §14.5 |
| TP-B-04 | `apps/` / `packages/` / `catchmenu_app/` / `tests/` / `tools/` 변경 0건 | 0건 | `601717` §5 |
| TP-B-05 | `supabase/` 변경 0건 | 0건 | `601717` §5 |
| TP-B-06 | `docs/` 변경이 허용된 문서 동기화 범위 내 | 범위 내 | `601717` §1.2 |
| TP-B-07 | `601702` / `601705` / `601710` / `601713` 이 구현 과정에서 수정되지 않음 | 0건 | 상위 근거 문서 |
| TP-B-08 | 신규 migration 파일이 **정확히 2개** (`0170` · `0171`) | 2개 | `601717` §1.1 |

## §9 Migration / Schema Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-M-01 | 신규 migration **각 파일** 상단 5행 이내 `-- Workpacket: 601700` | 2건 모두 | `000701` §6.11.1 |
| TP-M-02 | `tools/Check-Governance.ps1` 에서 두 파일에 G15 finding 없음 | 0건 | 동일 |
| TP-M-03 | `-StrictStage7` 로도 G15 ERROR 없음 | 0건 | 동일 |
| TP-M-04 | 파일명이 `0170_` / `0171_` 로 시작, 번호 재사용 없음 | 참 | 최신 = `0169` |
| TP-M-05 | 적용 후 `migration_history` 에 `success = true` 2행 추가 | 2행 | 적용 증거 |
| TP-M-06 | 적용 순서가 `0170` → `0171` | 참 | FK 의존 |
| TP-M-07 | `0171` 내부 순서가 **테이블 생성 → backfill → FK/인덱스 → stores backfill** | 참 | 참조 무결성 |
| TP-M-08 | 재적용(replay) 시 파괴적 실패가 발생하지 않음 | 확인 | §12 B-7 |
| TP-M-09 | migration 본문에 `CASCADE` 0건 | 0건 | §1.39 / I-37 |
| TP-M-10 | migration 본문에 `DROP TABLE` 0건 | 0건 | `601717` §2 |

> ⚠️ **TP-M-08 이 이번 판에서 위험도가 올라갔다.**
> 2판까지는 재적용 실패가 rename 구문에서만 났다. **이제 backfill INSERT 가 있다.**
> 재적용 시 중복 INSERT 가 되면 TP-D-01(행 수 일치)이 깨진다.
> `merchant_accounts.tenant_id` 의 UNIQUE 가 이를 막지만,
> **막힌 결과가 오류인지 무시인지는 재적용 정책이 없어 판정할 수 없다** — §12 B-7.

## §10 Runtime Behavior Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-RT-01 | Person 계열 변경으로 인한 RPC 회귀 없음 | 0건 | BL-8 |
| TP-RT-02 | **`stores` 컬럼 추가·UPDATE 로 인한 RPC 회귀 없음** | 0건 | BL-22 — `SELECT *` / 행 타입 의존 함수 별도 확인 |
| TP-RT-03 | 앱 빌드 / 테스트 스위트가 이전과 동일하게 통과 | 동일 | BL-17 |
| TP-RT-04 | `catchmenu_authority_owner` 경유 접근의 가능/불가능 불변 | 불변 | X-8 |
| TP-RT-05 | **`merchant_accounts` 에 어떤 애플리케이션 경로도 도달하지 못한다** | 도달 0 | **§1.45 fail-closed baseline** |
| TP-RT-06 | 다른 도메인의 트리거·제약 불변 | 불변 | TP-R-02 |

> **TP-RT-05 는 실패가 아니라 목표 상태다.**
> §1.45: 「테이블은 존재한다. 그러나 application access contract 는 아직 없다.」
> **접근이 안 되는 것이 이번 나선의 정답이며, 0-C 가 그 위에 필요한 정책만 추가한다.**

## §11 Rollback Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-RB-01 | rollback 이 **역방향 신규 migration** 으로 표현 가능 | 가능 | `000701` §14.5 |
| TP-RB-02 | rollback 계획이 `0170`/`0171` 수정·삭제를 전제하지 않음 | 전제 없음 | 동일 |
| TP-RB-03 | rollback 후 §2.1 기준선 before 값이 전부 복원됨 | 복원 | 기준선 대조 |
| TP-RB-04 | rollback 시 RLS `ENABLE`+`FORCE` 와 GRANT 4건이 함께 복원됨 | 복원 | X-6·X-7 |
| TP-RB-05 | **backfill 로 만든 행이 함께 제거된다** — `merchant_accounts` 0행 복귀 | 0행 | BL-24 역 |
| TP-RB-06 | **`stores.updated_at` 은 복원되지 않는다는 사실이 rollback 계획에 명시됐다** | 명시 | **BL-26 — 되돌릴 수 없는 부작용** |
| TP-RB-07 | rollback 순서가 `0171` 역 → `0170` 역 | 참 | FK 의존 역순 |

> ⚠️ **TP-RB-06 이 이번 판에서 새로 생긴 비가역 지점이다.**
> `stores.merchant_account_id` 를 지우면 컬럼은 사라지지만
> **backfill UPDATE 가 갱신한 `stores.updated_at` 의 이전 값은 복구되지 않는다.**
> 데이터 손실은 아니나 **완전 복원이 아니라는 사실이 기록되어야 한다.**

## §12 Blocker

### §12.1 해소된 것 (기록 보존)

| # | blocker | 해소 근거 |
|---|---|---|
| B-1 | `MerchantAccount` 목표 상태 미정의 | `601702` §1.44 (1판→2판) |
| B-2a | 트리거명 미선언 | **`601702` §1.37 보강** |
| B-2b | `owner_name` 미선언 | **동일 — `person_name` 으로 확정** |
| B-3 | `is_active` 처리 충돌 | `601713` I-36 |
| B-4 | `ownership_percent` 처리 충돌 | `601713` I-37 |
| B-6(1판) | `§1.43` vs `§3.1` | `601710` §2.3 |
| B-7(1판) | §1.34~§1.44 미반영 | `601713` I-34~I-42 · §6 병기 |
| N-2 | 스키마 배치·RLS/GRANT posture | **`601702` §1.45** |
| N-3 | 필드명·타입 소관 순환 | **`601702` §2.2 정정** |
| N-4 | 옛 서술 잔류 | **`601713` I-14 · §1.1 본문 병기** |
| N-6 | §5 일자 표기 | **`601702` §5** |

### §12.2 남아 있는 것 — 처분 유효성 재확인

| # | Blocker | 처분이 여전히 유효한가 | 영향받는 테스트 |
|---|---|---|---|
| **B-5** | Store–LegalEntity 시점 관계 물리 구조 미정 | **유효.** `601710` §4 의 「미확보 → 관계만 유지」 분기가 그대로이고, I-41 중첩 방지에 필요한 확장 설치 여부 실측이 여전히 없다. §1.45 의 backfill 은 §1.31 경계에 따라 **LegalEntity 로 확장되지 않는다** | TP-N-29, §5.4 |
| **B-6** | `CHANGELOG.md` 규약 상태 미결 | **유효.** 변동 없음 | §8 |
| **B-7** | 재적용 동작 요구사항 미선언 | **유효하되 위험도 상승.** backfill INSERT 가 추가되어 재적용 시 중복 판정 문제가 새로 생겼다 | TP-M-08 |
| **B-8** | 검증 환경 미지정 | **유효하되 위험도 상승.** backfill 기대값이 `tenants` 행 수에 종속되므로 환경이 다르면 기대값이 달라진다 | §2.1 전체, PRE-5 |
| **B-9** | 문서 정합화 시점 미정 | **유효.** `owners` 참조 문서 27~30건. 변동 없음 | §8 |
| **N-5** | `stores` 참조 151개 함수의 형태 미측정 | **유효하되 성격 변화.** 2판에서는 컬럼 추가 회귀 범위 산정 문제였으나, **이제 NOT NULL 승격 가부 판정의 직접 근거**가 됐다(N-1′) | TP-RT-02, TP-R-14 |

### §12.3 새로 생긴 것

| # | Blocker | 내용 | 영향받는 테스트 |
|---|---|---|---|
| **N-1′** | **`stores.merchant_account_id` NOT NULL 승격 가부 미판정** | §1.45 backfill 로 「데이터가 없다」는 2판 N-1 의 원인은 사라졌다. **그러나 `stores` 를 참조하는 151개 함수 중 `stores` 에 INSERT 하는 것이 몇 개인지 기록이 없다**(N-5). NOT NULL 은 값을 공급하지 않는 INSERT 를 전부 깨뜨린다. **데이터는 준비됐고 런타임 영향이 미측정이다** | TP-N-40 |
| **N-2′** | **`stores` backfill 이 §1.45 의 직접 선언이 아니다** | §1.45 의 backfill 문언은 **MerchantAccount 생성**만 다룬다. `stores.merchant_account_id` 를 `stores.tenant_id` 경유로 채우는 것은 §1.26 구조 경로에서의 **파생**이다. 결정적(deterministic)이지만 선언된 문장은 아니다 | TP-D-05, TP-D-06 |
| **N-3′** | **backfill 의 계정 명칭 값 출처 미선언** | §1.44 가 계정 명칭을 필수로 두었고 §1.45 가 backfill 을 지시했으나, **그 값을 어디서 가져오는지는 어느 문서에도 없다.** `tenants.tenant_name` 이 유일한 결정적 후보다 | TP-D-04 |
| **N-4′** | **backfill UPDATE 의 `stores.updated_at` 부작용 미논의** | `trg_stores_updated_at` 이 발동해 감사 컬럼이 갱신된다. 어느 문서도 이를 다루지 않았고 **rollback 으로 복원되지 않는다** | BL-26, TP-N-49, TP-RB-06 |
| **N-5′** | **§1.45 와 §1.37 보강이 ERD/Overview/Logic 에 미반영** | §1.44 때와 달리 이번 선언은 설계 문서로 전파되지 않았다. `601705`/`601710`/`601713` 어디에도 backfill · 배치 · fail-closed posture 가 없고, `601713` I-34 는 여전히 「FK 제약명·인덱스명」까지만 적는다. **이 TestPlan 은 기대값 일부를 Logic 이 아니라 선언에서 직접 도출했다** | §4.2, §4.4, TP-P-08, TP-P-18 |

> **N-5′ 는 2판 B-7 과 같은 형태의 재발이다.**
> 선언이 앞서고 설계 문서가 따라오지 않은 상태다.
> `601702` §0 이 「이미 이 선언을 근거로 만들어진 산출물의 재검토 범위를 함께 판정한다」고
> 요구했는데, §1.45·§1.37 보강에 대한 그 판정이 문서로 없다.
>
> **이번에는 결과가 다르다.** 2판에서는 선언과 Logic 이 **충돌**했지만(I-14 vs I-36),
> 이번에는 Logic 에 **대응 항목이 아예 없다.** 충돌이 없으므로 구현은 가능하나,
> Stage 6 검증자가 Logic 만 읽으면 backfill 을 범위 초과로 판단하게 된다.

> **N-1′ 이 이번 판의 유일한 실질적 미완결이다.**
> 대상 4는 이제 구조가 있고 값도 채워지지만 **제약이 없다.**
> N-5 의 측정 한 번이면 판정할 수 있다 —
> 「151개 중 `stores` 에 INSERT 하는 함수가 몇 개이며, 그것들이 새 컬럼을 공급하는가」.

## §13 Acceptance Criteria

| # | 조건 |
|---|---|
| AC-1 | §2 Preconditions PRE-1~PRE-6 이 모두 충족됐다 |
| AC-2 | §4 Positive 중 `BLOCKED` 가 아닌 항목이 전부 PASS 다 |
| AC-3 | §4.3 에 따라 컬럼명·타입 기대값이 `601717` §4 로 확정된 뒤 실행됐다 |
| AC-4 | **§4.4 backfill 검증 TP-D-01~TP-D-07 이 전부 PASS 다** |
| AC-5 | §5 Negative 전 항목이 PASS 다. **하나라도 FAIL 이면 전체 FAIL** |
| AC-6 | §6 Regression 전 항목이 PASS 다 |
| AC-7 | §7 External Provider negative 전 항목이 PASS 다. **TP-X-01~TP-X-11 중 하나라도 발견되면 즉시 중단** |
| AC-8 | §8 Boundary 전 항목이 PASS 다 |
| AC-9 | §9 Migration 전 항목이 PASS 다 |
| AC-10 | §11 Rollback 계획이 문서로 존재하고 TP-RB-01·TP-RB-02·TP-RB-06·TP-RB-07 을 만족한다 |
| AC-11 | §12.2·§12.3 의 blocker 중 해당 범위에 걸리는 것이 Human 판정으로 해소됐거나, 그 범위가 구현에서 제외됐다 |
| AC-12 | 검증자가 상위 문서 및 본 문서의 원작자가 아니다 (`000701` §37) |

> **`BLOCKED` 가 남아 있는 상태로 AC 를 충족했다고 기록하지 않는다.**

## §14 Out Of Scope

| 대상 | 사유 |
|---|---|
| Store 상태 3축의 값·전이 | `601710` §3 |
| `OperatingGroup` / `company` / `business_unit` persistence | `601710` §3 |
| Staff / User / Session | 0-B (`601702` §1.18) |
| Role / Permission / Authorization | 0-C (`601702` §1.19·§1.45) |
| `merchant_accounts` 의 application access policy | **`601702` §1.45 — 0-C 소관** |
| Tenant provisioning 경로의 MerchantAccount 동시 생성 **구현** | **`601702` §1.45 — 책임 소재만 확정. `601710` §3 Out of Scope** |
| 과금·정산 경로 | `601702` §2.1 |
| 금전 객체 LegalEntity snapshot (§1.35) / Tenant 이전 (§1.36) | `601710` §2.3 — 원칙 전용 |
| RPC 재작성 | `601700` Readme §5 |
| External Provider Mapping 의 **positive** 검증 | §7 — negative 만 수행 |
| 과거 migration 파일의 `owner_` 잔존 | **`601702` §1.37 「검증 범위」 — 명시적 제외** |
| `000170` §4 deferred 권장 필드 | `601705` O19 |
| `0168`/`0169` historical disposition 재판정 | `601710` §5.1 |

## §15 근거 문서 목록 (`000701` §46)

| 문서 | 인용 절 | 권위 | 역할 |
|---|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4.1~§5.4.4, §5.7 | ACTIVE | TestPlan 규격·저자 분리·충돌 처리 |
| `docs/000700_…/000701_…Pipeline.md` | §3, §6.11.1, §10, §14.5, §35, §37, §46 | ACTIVE | Stage 게이트·migration 헤더·검증자 분리 |
| `docs/…/601700_Readme_…V2.md` | §4, §5, §10, §10.1 | 본 워크패킷 | In/Out of Scope |
| `docs/…/601701_Register_Stage0_Evidence_Collection.md` | §4.5 D-3, E단계 (`tenants`·`stores` 컬럼·행수·함수 실측) | 본 워크패킷 | BL-5·BL-20~BL-23·BL-27 |
| `docs/…/601702_Register_Stage1_Business_Rules.md` | §1.1, §1.2, §1.18, §1.19, §1.22, §1.25~§1.27, §1.31, §1.34, §1.37(보강 포함), §1.38, §1.39, §1.43, §1.44, **§1.45**, §2.1, §2.2, §5 | 본 워크패킷 | **최우선 근거** — Human 선언 |
| `docs/…/601705_Diagram_…ERD.md` | §4.4, §4.6, §5.2, §8, §10 (O5·O18·O19) | 본 워크패킷 | 물리 정의 반영 · Open Decisions |
| `docs/…/601710_Overview_…V2.md` | §2, §2.1~§2.3, §3, §3.1, §4, §5, §7 | 본 워크패킷 | 구현 대상·제외·negative 지시 |
| `docs/…/601711_…Cursor.md` / `601712_…Codex.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선(이중) |
| `docs/…/601713_Logic_…V2.md` | §1.1~§1.5 (I-1~I-42, I-14·§1.1 병기 포함), §2~§6 | 본 워크패킷 | 불변조건·예외·미해결 |
| `docs/…/601714_…Cursor.md` / `601715_…Codex.md` | Environment, Q-2 ~ Q-8 | 본 워크패킷 | 갭 해소 실측(이중) |
| `sql/migrations/CHANGELOG.md` | 2026-08-07 항목 | 프로젝트 파일 | B-7 배경 |
| `tools/Check-Governance.ps1` | G15 | 프로젝트 파일 | TP-M-02·TP-M-03 |

**인용하지 않은 것**: `601500` 대역(`601501`~`601512`)의 설계 결론.
`601504` TestPlan 을 포함해 **어느 항목도 근거로 쓰지 않았다**(`600020` §2).

---

> **이 TestPlan 은 구현을 승인하지 않는다.**
> 허용·금지 파일과 물리 표현은 ChangeContract `601717` 이,
> 착수 권한은 Stage 7 Human Approval 이 정한다.
>
> §12.2·§12.3 의 blocker 중 해당 범위가 해소되지 않은 채 실행된 테스트 결과는
> **부분 결과이며 나선 종료 근거가 되지 않는다.**
