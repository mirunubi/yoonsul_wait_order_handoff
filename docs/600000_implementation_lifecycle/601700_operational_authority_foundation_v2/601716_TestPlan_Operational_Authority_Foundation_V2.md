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
| 2026-08-22 | 초안 — 4단계 TestPlan. Overview(`601710`) / Logic(`601713`) / 선언(`601702`) 소비 |

## §0 성격과 저자

`000001` §5.4.4 TestPlan 이다. **구현을 승인하지 않는다.**

**저자 분리**(`000001` §5.4.2)

| 산출물 | 저자 |
|---|---|
| Overview `601710` / Logic `601713` | Claude Code |
| **TestPlan `601716` / ChangeContract `601717`** | **Claude (본 문서 저자)** |

이 TestPlan 은 Overview / Logic 을 **소비**하며 **옹호하지 않는다.**
두 문서가 불충분한 지점은 §11 Blocker 에 사실로 기록했고, 임의로 메우지 않았다.

**이 TestPlan 이 하지 않는 것**

| # | 하지 않는 것 | 소관 |
|---|---|---|
| 1 | 새 정책 결정 | Human (`601702`) |
| 2 | 물리 변경 방법 판정 | ChangeContract `601717` §2 |
| 3 | 허용·금지 파일 확정 | ChangeContract `601717` §1·§5 |
| 4 | Overview / Logic 의 모순 해소 | §11 에 blocker 로 기록만 |
| 5 | DB 재조회 | `601711`/`601712`/`601714`/`601715` 가 이미 수행 |

**표기**

`persons` / `person_id` 는 **목표 명칭**이며, ChangeContract §2 판정을 전제로 쓴다.
Stage 7 이 다른 방식을 승인하면 이 TestPlan 의 해당 항목은 그 방식으로 재작성되어야 한다.

## §1 Test Scope

Overview `601710` §2 의 구현 대상 5건 중, **이번 나선에서 실제로 검증 가능한 범위**만 다룬다.

| Overview §2 대상 | 이 TestPlan 의 취급 | 사유 |
|---|---|---|
| 1. canonical `Person` 물리 표현 | **전면 검증** (§4·§5·§6) | Logic I-1~I-16, `601702` §1.37 로 목표 상태가 특정된다 |
| 2. persistent `MerchantAccount` | **검증 불가 — B-1** | 필드 집합·테이블명 미선언(`601705` §10 O5·O9·O10, `601713` §1.2) |
| 3. Tenant ↔ MerchantAccount (1:1) | **검증 불가 — B-1 종속** | 대상 2 없이는 검증 대상이 없다 |
| 4. MerchantAccount → Store (1:N) | **검증 불가 — B-1 종속** | 동상 |
| 5. Store–LegalEntity target invariant | **negative 검증만** (§5.4) | ChangeContract §3 이 enforcement 부적격으로 판정 |

> ⚠️ **대상 2·3·4 를 "검증 통과"로 기록하지 않는다.**
> 검증 불가는 통과가 아니다. §11 B-1 이 해소되기 전에는
> 이 세 대상에 대한 어떤 PASS 판정도 근거가 없다.

**검증 대상 물리 객체** (`catchmenu_hq` 스키마)

```text
owners                        → persons        (7컬럼, 0행)
legal_entity_person_roles     owner_id → person_id
legal_entity_representatives  owner_id → person_id
legal_entities                (명칭 유지 — 601702 §1.37 미언급)
stores                        DDL 대상 아님 (ChangeContract §3)
```

## §2 Preconditions — 이 조건이 모두 참이어야 테스트를 시작한다

| # | 전제 | 확인 방법 | 미충족 시 |
|---|---|---|---|
| PRE-1 | ChangeContract `601717` §10 의 Stage 7 이 승인 상태 | 문서 확인 + `tools/Check-Governance.ps1` G15 | 테스트 착수 금지 |
| PRE-2 | §11 의 Blocker B-1~B-7 이 Human 판정으로 해소됨 | `601702` 개정 이력 또는 Approval 문서 | 해당 범위 테스트 제외 |
| PRE-3 | 검증 환경의 최신 migration 이 `0169` | `catchmenu_meta.migration_history` 상위 1행 | 기준선 불일치 — 재수립 |
| PRE-4 | 기준선 재측정 완료 (§2.1) | 아래 표 | 사후 비교 불가 |
| PRE-5 | 검증자가 원작자가 아님 (`000701` §37) | 지시문 서두에 원작자 명시 | 검증 무효 |

### §2.1 기준선 — 사후 비교용 실측값

`601711`/`601712`/`601714`/`601715` 가 기록한 값이다. **구현 직전에 같은 질의로 재측정**하고,
값이 다르면 그 차이 자체를 먼저 조사한다(`601713` A-3).

| # | 항목 | 기준값 | 출처 |
|---|---|---:|---|
| BL-1 | `owners` 행 수 | 0 | `601711` P-3 / `601712` P-3 |
| BL-2 | `legal_entity_person_roles` 행 수 | 0 | 동일 |
| BL-3 | `legal_entity_representatives` 행 수 | 0 | 동일 |
| BL-4 | `legal_entities` 행 수 | 0 | `601711` P-3 |
| BL-5 | `stores` 행 수 | 1 | `601701` §4.5 D-3 |
| BL-6 | `stores.legal_entity_id` NOT NULL 행 수 | 0 | 동일 |
| BL-7 | `catchmenu_hq` BASE TABLE 수 | 20 | `601714` / `601715` 환경 절 |
| BL-8 | `owners` 참조 FUNCTION | 0 | `601711` P-1 / `601714` Q-4 |
| BL-9 | `owners` 참조 VIEW / MATVIEW | 0 | `601711` P-1 |
| BL-10 | `owners` RLS POLICY | 0 (`relrowsecurity=true`, `relforcerowsecurity=true`) | `601711` P-1 |
| BL-11 | `owners` GRANT (grantee ≠ postgres) | 4 (`catchmenu_authority_owner` SELECT/INSERT/UPDATE/DELETE, `is_grantable=NO`) | `601711` P-1 #15~#18 |
| BL-12 | `set_updated_at()` 호출 non-internal 트리거 | 114 | `601714` Q-3 / `601715` Q-3 |
| BL-13 | 신규 4테이블을 참조하는 **타 스키마** FK | 0 | `601714` Q-4 / `601715` Q-4 |
| BL-14 | 신규 4테이블을 참조하는 동일 스키마 FK | 5 | `601714` Q-4 |
| BL-15 | 이름에 `merchant` 가 든 테이블 | 0 | `601714` Q-5 / `601715` Q-5 |
| BL-16 | 앱·패키지·테스트·seed 코드의 `owners` 참조 | 0 | `601711` P-5 / `601712` P-5 |
| BL-17 | `chk_lepr_role_type` 허용값 | `OWNER` / `REPRESENTATIVE` / `DIRECTOR` / `EXECUTIVE` / `INVESTOR` | `601714` Q-2 / `601715` Q-2 |
| BL-18 | `owners` CHECK 제약 | 0 | 동일 |

### §2.2 두 조사 환경의 차이 — 테스트 전에 확인할 것

| 항목 | `601701`/`601711`/`601712` | `601714`/`601715` |
|---|---|---|
| 이미지 태그 | `postgres:17.6.1.140` | `postgres:17.6.1.156` |
| 최신 migration | `0169` | `0169` |
| BASE TABLE 총계 | — | 243 (`601714`) / 247 (`601715`) |

> **총계 차이는 집계 기준 차이다.** `601714` 는 `pg_catalog`(64)와 `information_schema`(4)를
> 모두 제외해 243, `601715` 는 `pg_catalog` 만 제외해 247 이다. 차이는 정확히 4 이며
> `information_schema` 의 테이블 수와 일치한다. **모순이 아니다.**
>
> ⚠️ **이미지 태그 차이는 다르다.** 두 컨테이너가 서로 다른 환경이라는 사실이 기록되어 있다.
> 구현·검증을 어느 환경에서 수행할지는 **이 TestPlan 이 정하지 않는다.** §11 B-6.

## §3 Test ID 체계

```text
TP-P-nn   Positive        목표 상태가 실제로 만들어졌는가
TP-N-nn   Negative        만들지 않기로 한 것이 만들어지지 않았는가
TP-R-nn   Regression      건드리지 않기로 한 것이 그대로인가
TP-B-nn   Boundary        허용 파일·금지 파일 경계를 넘지 않았는가
TP-M-nn   Migration       migration 파일 자체의 규격
TP-X-nn   External        External Provider Mapping negative 검증 (§7)
TP-RB-nn  Rollback        되돌릴 수 있는가
```

**판정값은 PASS / FAIL / BLOCKED 셋뿐이다.**
`BLOCKED` 는 전제가 해소되지 않아 실행하지 못한 상태이며 **PASS 가 아니다.**

## §4 Positive Tests — 목표 상태 검증

Logic `601713` §1.1 의 I-1~I-16 과 `601702` §1.37 을 검사 가능한 형태로 변환한 것이다.

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-P-01 | `catchmenu_hq.persons` 가 BASE TABLE 로 존재 | 1건 | `601702` §1.1·§1.37 |
| TP-P-02 | `persons` PK 가 `id uuid` 단일 컬럼 | 1건 | Logic I-9 |
| TP-P-03 | `legal_entity_person_roles.person_id` 컬럼 존재 | 1건 | `601702` §1.37 |
| TP-P-04 | `legal_entity_representatives.person_id` 컬럼 존재 | 1건 | `601702` §1.37 |
| TP-P-05 | 두 FK 가 **동시에** `persons.id` 를 참조 | 2건 | Logic I-1·I-2, X-1 |
| TP-P-06 | 두 FK 의 `ON DELETE` / `ON UPDATE` 가 `NO ACTION` | 2건 모두 | Logic I-3, X-2 |
| TP-P-07 | FK 제약명이 `person` 기준 (`..._person_id_fkey`) | 2건 | `601702` §1.37 |
| TP-P-08 | `persons` 에 `BEFORE UPDATE` 트리거가 존재하고 `catchmenu_common.set_updated_at()` 을 호출 | 1건 | Logic I-4, X-3 |
| TP-P-09 | `uq_lepr_active` 가 존재하고 정의가 `(legal_entity_id, person_id, role_type)` active 부분 unique | 1건 | Logic I-5, X-4 |
| TP-P-10 | `uq_ler_active` 가 존재하고 정의가 `(legal_entity_id, person_id)` active 부분 unique | 1건 | Logic I-6, X-4 |
| TP-P-11 | `uq_ler_sole_active` 가 존재하고 정의가 불변 | 1건 | Logic I-7, X-4 |
| TP-P-12 | Person 기준 역할 조회 인덱스가 존재 (`idx_lepr_owner` 또는 `person` 기준 후속명) | 1건 | Logic I-8, X-5 |
| TP-P-13 | `persons` PK 인덱스명이 `person` 기준 | 1건 | `601702` §1.37 |
| TP-P-14 | `persons` 의 `relrowsecurity = true` **그리고** `relforcerowsecurity = true` | 둘 다 true | Logic I-10, X-6 |
| TP-P-15 | `catchmenu_authority_owner` → `persons` GRANT 4건, `is_grantable = NO` | 4건 | Logic I-12, X-7 |
| TP-P-16 | 소유자(`postgres`) 기본 privilege 구성 불변 | BL-11 대비 동일 | Logic I-13 |
| TP-P-17 | `persons` 컬럼의 자연인 식별·연락처·타임스탬프 역할 보존 | 컬럼별 대응 확인 | Logic I-14 |
| TP-P-18 | `persons` 테이블 코멘트가 canonical 개념과 어긋나지 않음 | 문자열 확인 | Logic I-15 |
| TP-P-19 | 신규 migration 번호가 `0169` 보다 크고 `0168`/`0169` 는 미수정 | forward-only | Logic I-16, `000701` §14.5 |

> **TP-P-17 주의**: `601702` §1.38 이 `is_active` 제거를 선언했다.
> 그러나 Logic I-14 는 7컬럼의 「활성」 역할 유실 금지를 요구한다. **두 문서가 어긋난다.**
> §11 B-2 가 해소되기 전에는 TP-P-17 을 `BLOCKED` 로 둔다.
> 해소 결과에 따라 기대값이 `7컬럼 보존` 또는 `6컬럼 + is_active 제거` 로 갈린다.

## §5 Negative Tests — 만들지 않았음을 확인한다

> **negative 검증이 이 TestPlan 의 무게 중심이다.**
> Overview §7 이 "만들었는가가 아니라 만들지 않았는가를 확인해야 한다"고 지시했다.

### §5.1 legacy 어휘가 authoritative 로 남지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-01 | `catchmenu_hq.owners` 가 더 이상 relation 으로 존재하지 않음 | 0건 | `601710` §2.1 |
| TP-N-02 | `owners` 라는 이름의 **호환 VIEW / MATVIEW 가 생성되지 않음** | 0건 | `601710` §2.1 — legacy 어휘를 authoritative 로 남기지 않는다 |
| TP-N-03 | `owner_id` 컬럼이 `catchmenu_hq` 의 어느 테이블에도 남지 않음 | 0건 | `601702` §1.37 |
| TP-N-04 | `owners` 를 참조하는 FUNCTION 이 새로 생기지 않음 | 0건 (BL-8 유지) | `601711` P-1 |

> TP-N-02 는 실수하기 쉬운 지점이다. 호환 view 는 "안전하게 남겨두자"는 판단으로 만들어지지만,
> 그 순간 legacy 어휘가 다시 조회 가능한 canonical 표면이 된다.
> **데이터 0행·코드 참조 0건인 상태에서 호환 계층을 만들 이유가 없다.**

### §5.2 RLS / 권한 조합이 조용히 뒤바뀌지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-05 | `persons` 의 RLS POLICY 가 **0건** | 0건 | Logic I-11, X-8 |
| TP-N-06 | 다른 3테이블의 RLS POLICY 도 0건 유지 | 0건 | 동일 |
| TP-N-07 | `catchmenu_authority_owner` 의 `rolbypassrls` 가 여전히 `true`, `rolcanlogin` 이 `false` | 유지 | `601714` Q-4 / `601715` Q-4 |
| TP-N-08 | 클라이언트 도달 가능 role(`anon` / `authenticated` / `service_role` 등)에 신규 GRANT 가 부여되지 않음 | 0건 | Logic I-12 — 4 privilege 확대 금지 |
| TP-N-09 | `catchmenu_authority_owner` 의 privilege 가 4건에서 **축소되지도** 않음 | 정확히 4건 | Logic I-12 |

> **TP-N-05 는 "정책이 없다"를 확인하는 것이 아니라 "정책 0개라는 의도된 상태가 유지됐다"를 확인한다**
> (Logic I-11). 정책이 하나라도 생기면 `FORCE` + `bypassrls` 조합의 접근 모델이 바뀐다.

### §5.3 선언되지 않은 것을 만들지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-10 | `merchant_accounts` / `merchant_companies` / `merchant_stores` 테이블 미생성 | 0건 (BL-15 유지) | §11 B-1 — 필드 집합 미선언 |
| TP-N-11 | 이름에 `merchant` 가 든 테이블이 여전히 0건 | 0건 | `601714` Q-5 |
| TP-N-12 | economic ownership 모델(별도 지분 테이블) 미생성 | 0건 | `601702` §1.39 — 「0-A 에서 새 ownership 모델을 구현하지 않는다」 |
| TP-N-13 | Store 상태 3축의 enum / 상태 컬럼 미생성 | 0건 | `601710` §3, `601713` §2 |
| TP-N-14 | `OperatingGroup` / `company` / `business_unit` 테이블 미생성 | 0건 | `601710` §3 |
| TP-N-15 | `cross_business_link` 물리 구조 미생성 | 0건 | `601710` §3 |
| TP-N-16 | Store–LegalEntity 시점 이력 테이블 미생성 | 0건 | §11 B-3 — Overview/Logic 에 구현 대상으로 없음 |
| TP-N-17 | 감사 이력 테이블 / 감사 트리거 미생성 | 0건 | `601713` §5 |
| TP-N-18 | Staff / User / Session / Role / Permission 관련 객체 미변경 | 변경 0건 | `601702` §1.18·§1.19 |

### §5.4 Store–LegalEntity — enforcement 를 걸지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-19 | `stores.legal_entity_id` 가 여전히 NULL 허용 | `is_nullable = YES` | ChangeContract §3 판정 |
| TP-N-20 | `legal_entities` 행 수가 여전히 0 | 0행 | Logic I-28 — synthetic LegalEntity 생성 금지 |
| TP-N-21 | `stores.legal_entity_id` 백필 0행 유지 | 0행 | Logic I-28 |
| TP-N-22 | `stores` 테이블에 어떤 DDL 도 적용되지 않음 | git diff 상 `stores` 대상 구문 0건 | ChangeContract §3 |
| TP-N-23 | `store_operator_type` 값을 근거로 한 LegalEntity 배정 로직 미생성 | 0건 | Logic I-30 |

### §5.5 데이터를 만들지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-24 | 4테이블 전부 여전히 0행 | 0행 | BL-1~BL-4 |
| TP-N-25 | migration 파일에 `INSERT` / `UPDATE` / `DELETE` 구문 0건 | 0건 | `601710` §2 — 구현 대상에 데이터 없음 |
| TP-N-26 | seed SQL 미변경 | 변경 0건 | `601711` P-5 |

## §6 Regression Tests — 건드리지 않기로 한 것이 그대로인가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-R-01 | `catchmenu_hq` BASE TABLE 수 = 20 | 20 (BL-7) | rename 이면 증감 없음. 21이면 신규 생성이 함께 남은 것 |
| TP-R-02 | `set_updated_at()` 호출 non-internal 트리거 총계 = 114 | 114 (BL-12) | Logic I-4 — 다른 110개 트리거에 영향 없음 |
| TP-R-03 | `catchmenu_common.set_updated_at()` 정의 불변 (`SECURITY DEFINER`, `search_path=pg_catalog`, 본문 동일) | 불변 | `601714`/`601715` Q-3 |
| TP-R-04 | `legal_entities` 11컬럼 구성 불변 | 불변 | `601714`/`601715` Q-8 |
| TP-R-05 | `chk_legal_entities_entity_type` / `_status` / `_crn_not_for_sole` 불변 | 3건 불변 | `601714`/`601715` Q-2 |
| TP-R-06 | `chk_ler_representation_mode` / `chk_ler_effective_range` / `chk_lepr_effective_range` 불변 | 3건 불변 | 동일 |
| TP-R-07 | `chk_lepr_role_type` 허용값 5개 불변 | BL-17 유지 | `601702` 에 role_type 재정의 선언 없음 |
| TP-R-08 | `fk_stores_legal_entity_id` 불변 | 불변 | `601714` Q-4 |
| TP-R-09 | 타 스키마 → 신규 4테이블 FK 가 여전히 0건 | 0건 (BL-13) | `601714`/`601715` Q-4 |
| TP-R-10 | 앱·패키지·테스트·seed 의 `owners` / `owner_id` 참조가 여전히 0건 | 0건 (BL-16) | `601711` P-5 |
| TP-R-11 | `0168` / `0169` 의 파일 checksum 이 `migration_history` 기록값과 동일 | 동일 | `000701` §14.5 |
| TP-R-12 | `catchmenu_meta.migration_history` 의 기존 행이 수정·삭제되지 않음 | 불변 | 이력 보존 |
| TP-R-13 | 기존 RPC 시그니처 변경 0건 | 0건 | `601700` Readme §5 |

> **TP-R-11 의 방식**: `0168`/`0169` 파일을 다시 해시해 `migration_history.checksum` 과 비교한다.
> 두 값이 기록되어 있다 — `0168` `263615f…`, `0169` `eb9b118…` (`601714` 환경 절).

## §7 External Provider Mapping — negative 검증 (`601710` §7 필수)

> ⚠️ **이 절은 "만들었는가"를 묻지 않는다. "만들지 않았는가"를 묻는다.**
>
> `601702` §1.43 이 외부 provider 연결을 **플랫폼 구조의 일부로 선언**했기 때문에,
> 구현 주체가 "필요하다고 했으니 만들어야겠다"고 판단할 여지가 실재한다.
> Overview §3.1 은 그것을 **이번 나선에서 만들지 않는다**고 명시했다.

### §7.1 금지 대상 — 하나라도 발견되면 FAIL

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-X-01 | provider mapping 테이블 미생성 (`*provider*mapping*`, `*external*mapping*`, `*provider*store*`, `*provider*merchant*` 등) | 0건 | `601710` §3.1 |
| TP-X-02 | 기존 테이블에 외부 provider 전용 컬럼 미추가 (`external_merchant_id`, `external_store_code`, `provider_id`, `terminal_id` 등) | 0건 | `601710` §3.1 |
| TP-X-03 | provider contract 를 추정한 schema(테이블·타입·제약) 미생성 | 0건 | `601710` §3.1 |
| TP-X-04 | `stores` 에 외부 provider 연결 컬럼 미추가 | 0건 | `601710` §3.1 + ChangeContract §3 (`stores` DDL 전면 금지) |
| TP-X-05 | 이름·컬럼에 `merchant` 가 든 객체 수가 기준선(테이블 0 / 컬럼 5)에서 증가하지 않음 | 증가 0 | BL-15, `601714`/`601715` Q-5 |
| TP-X-06 | `TOSS-TX` / `SC-EXEC` / `OKPOS` / `KICC` 등 특정 벤더명을 담은 신규 객체 미생성 | 0건 | `601710` §3.1 — 특정 업체 미확정 |
| TP-X-07 | `catchmenu_integrations` / `catchmenu_payment` 의 기존 5개 `merchant` 컬럼이 **canonical identity 로 승격되지 않음** — 신규 FK / unique 제약 미추가 | 0건 | `601702` §1.43 「의미 ID 는 CatchMenu/YS-OS 가 canonical」 |
| TP-X-08 | `stores.id` 를 외부 provider 의 merchant id 와 동일시하는 제약·주석 미도입 | 0건 | `601710` §3.1 금지 도식 |

### §7.2 확인해야 하는 것 — 선언은 남고 물리는 없다

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-X-09 | ChangeContract `601717` 이 provider mapping 물리 구현을 **명시적으로 금지**하는 조항을 포함 | 조항 존재 | `601710` §7 — 「선언만 있고 금지가 없으면 구현 주체가 만들 여지가 남는다」 |
| TP-X-10 | migration 본문에 provider / external / mapping 관련 주석성 선언조차 스키마 객체로 남지 않음 | 0건 | 빈 테이블도 설계 결정이다(`601710` §3.1) |

> **왜 negative 인가**: 외부 provider 의 실제 identifier 구조가 확보되지 않았다.
> 지금 추정한 축(`tenant_id`/`store_id`/`external_store_id`)과 실제 provider 축
> (`merchant_id`/`terminal_id`/`business_registration_no`/`shop_id`)이 어긋나면 재작업이 발생한다.
> **만들지 않은 상태가 이번 나선의 올바른 결과다.**

## §8 Boundary / Forbidden File Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-B-01 | `git diff --name-only` 결과가 ChangeContract §1 허용 목록의 부분집합 | 부분집합 | `601717` §1 |
| TP-B-02 | ChangeContract §5 금지 파일 중 변경된 것 0건 | 0건 | `601717` §5 |
| TP-B-03 | `sql/migrations/` 의 기존 169개 파일이 하나도 수정되지 않음 | 0건 | `000701` §14.5 |
| TP-B-04 | `apps/` / `packages/` / `catchmenu_app/` / `tests/` / `tools/` 변경 0건 | 0건 | `601717` §5 |
| TP-B-05 | `supabase/` 설정 변경 0건 | 0건 | `601717` §5 |
| TP-B-06 | `docs/` 변경이 허용된 문서 동기화 범위를 넘지 않음 | 범위 내 | `601717` §1.2 |
| TP-B-07 | Overview `601710` / Logic `601713` / 선언 `601702` 가 구현 과정에서 수정되지 않음 | 0건 | 상위 근거 문서 — 구현자가 고칠 대상이 아니다 |
| TP-B-08 | 신규 migration 파일이 **정확히 1개** | 1개 | `601717` §1.1 |

## §9 Migration / Schema Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-M-01 | 신규 migration 파일 상단 **5행 이내**에 `-- Workpacket: 601700` | 존재 | `000701` §6.11.1 |
| TP-M-02 | `tools/Check-Governance.ps1` 실행 시 해당 파일에 G15 finding 없음 | finding 0건 | `000701` §6.11.1 |
| TP-M-03 | `-StrictStage7` 로 실행해도 G15 가 ERROR 를 내지 않음 | ERROR 0건 | 승인 게이트 실효 확인 |
| TP-M-04 | 파일명이 `0170_` 으로 시작하고 기존 번호를 재사용하지 않음 | 참 | `sql/migrations` 최신 = `0169` |
| TP-M-05 | migration 적용 후 `migration_history` 에 `success = true` 1행 추가 | 1행 | 적용 증거 |
| TP-M-06 | 재적용(replay) 시 파괴적 실패가 발생하지 않음 | 확인 | `tools/apply_migrations.py` 재생 경로 |
| TP-M-07 | migration 본문에 `CASCADE` 사용 0건 | 0건 | `601702` §1.39 — 「`CASCADE` 로 일괄 제거하지 않는다」 |
| TP-M-08 | migration 본문에 `DROP TABLE` 사용 0건 | 0건 | ChangeContract §2 판정(rename) 전제 |

> **TP-M-06 주의**: `ALTER TABLE … RENAME` 은 `IF EXISTS` 가 없으면 재적용 시 실패한다.
> 실패 자체가 곧 결함은 아니다. 이 프로젝트의 재생 관행(`CHANGELOG` 2026-08-07 항목)에서
> **어떤 재적용 동작을 요구하는지가 선언되어 있지 않다.** §11 B-7 로 기록한다.

## §10 Runtime Behavior Tests

물리 대상에 데이터가 0행이고 참조 함수·앱 코드가 0건이므로, 런타임 표면 변화는 없어야 한다.

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-RT-01 | 기존 RPC 호출 경로에 회귀 없음 | 회귀 0건 | BL-8 — 참조 함수 0건 |
| TP-RT-02 | 앱 빌드 / 테스트 스위트가 이전과 동일하게 통과 | 동일 | BL-16 — 코드 참조 0건 |
| TP-RT-03 | `catchmenu_authority_owner` 경유 접근의 가능/불가능이 변하지 않음 | 불변 | Logic X-8 |
| TP-RT-04 | 다른 도메인(`catchmenu_store` / `catchmenu_pos` / `catchmenu_payment`)의 트리거·제약 불변 | 불변 | TP-R-02 |

> ⚠️ **TP-RT-03 은 실제 접근 주체가 확인된 상태에서만 의미가 있다.**
> `601714`/`601715` Q-4 는 `catchmenu_authority_owner` 의 멤버가 `postgres` 뿐이고
> 참조 함수가 0건임을 확인했다. 즉 **이 role 을 경유하는 애플리케이션 경로는 관측되지 않았다.**
> Logic §4 가 남긴 "현재 실제 접근 주체가 누구인지 확인되지 않았다"는 상태는
> Q-4 조사로 **좁혀졌으나 완전히 해소되지는 않았다** — `postgres` 가 직접 쓰는지,
> 아무도 쓰지 않는지는 여전히 기록되지 않았다. §11 B-5.

## §11 Rollback Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-RB-01 | rollback 이 **역방향 신규 migration** 으로 표현 가능 | 가능 | `000701` §14.5 — 적용된 파일 수정 금지 |
| TP-RB-02 | rollback 계획이 `0170` 파일 수정이나 삭제를 전제하지 않음 | 전제 없음 | 동일 |
| TP-RB-03 | rollback 후 §2.1 기준선 BL-1~BL-18 이 전부 복원됨 | 전부 복원 | 기준선 대조 |
| TP-RB-04 | rollback 시 RLS `ENABLE`+`FORCE` 와 GRANT 4건이 함께 복원됨 | 복원 | Logic X-6·X-7 |
| TP-RB-05 | rollback 대상 데이터가 없음을 사전 확인 (0행) | 0행 | BL-1~BL-4 |

> **데이터 0행이므로 rollback 의 위험은 데이터 손실이 아니라 권한·RLS 조합의 비대칭 복원이다.**
> 되돌릴 때 `FORCE` 나 GRANT 하나가 빠지면 접근 가능/불가능이 조용히 뒤바뀐다(Logic X-8).

## §12 Blocker — 이 TestPlan 이 해소하지 않은 것

> 아래는 **Overview / Logic / 선언 사이의 실제 어긋남**이다.
> 이 TestPlan 은 판정하지 않고 기록한다(`000001` §5.7).

| # | Blocker | 내용 | 영향받는 테스트 |
|---|---|---|---|
| B-1 | **`MerchantAccount` 목표 상태 미정의** | Overview §2 가 구현 대상 2·3·4 로 지정했으나, 테이블명·필드 집합·스키마가 어디에도 선언되지 않았다(`601705` §10 O5·O9·O10, `601713` §1.2). **검사 가능한 기대값을 만들 수 없다.** | 대상 2·3·4 전부 |
| B-2 | **`is_active` 처리 충돌** | Logic I-14(2026-08-13)는 7컬럼의 「활성」 역할 보존을 요구하고, `601702` §1.38(2026-08-22)은 사람 레코드에서 `is_active` 제거를 선언했다. Logic 은 개정되지 않았다 | TP-P-17 |
| B-3 | **Store–LegalEntity 시점 관계 미반영** | `601702` §1.34(2026-08-22)가 Store–LegalEntity 를 시점 관계로 확정하고 물리 구조를 ChangeContract 로 넘겼다. 그러나 Overview §2·§4 와 Logic I-31·I-33 은 그 선언 이전 문서이며, 시점 이력 구조를 구현 대상으로 두지 않았다 | TP-N-16, §5.4 전체 |
| B-4 | **`ownership_percent` 처리 충돌** | `601702` §1.39 는 제거를 선언했고, Logic §1.1 은 「제거도 사용도 지시하지 않는다」고 기록했다. Logic 은 개정되지 않았다 | TP-N-12, TP-M-07 |
| B-5 | **접근 주체 미확정** | `601714`/`601715` Q-4 가 멤버(`postgres`)와 함수 참조 0건을 확인했으나, 이 role 을 통해 실제로 접근하는 주체가 있는지는 기록되지 않았다 | TP-RT-03 |
| B-6 | **검증 환경 미지정** | `17.6.1.140` 과 `17.6.1.156` 두 컨테이너 기록이 있다. 어느 환경에서 구현·검증할지 선언되지 않았다 | §2.1 기준선 전체 |
| B-7 | **재적용 동작 요구사항 미선언** | migration 재생 시 idempotent 를 요구하는지, 1회성 적용을 전제하는지 프로젝트 규칙이 없다 | TP-M-06 |
| B-8 | **문서 정합화 시점 미정** | `owners` 를 참조하는 문서가 27건(`601711` P-4) / 30건(`601712` P-4.1)이다. Logic X-9 가 이를 최대 실패 지점으로 지목했으나 **언제 정합화하는지가 정해지지 않았다** | §8 문서 경계 전체 |

> **B-1 은 이 나선의 가장 큰 공백이다.**
> Overview §2 가 구현 대상 5건 중 3건(2·3·4)을 `MerchantAccount` 축에 걸어 두었는데,
> 그 축의 물리 형태를 정한 문서가 하나도 없다.
> **이 상태에서 대상 2·3·4 를 구현하면 그것은 구현이 아니라 설계다.**

## §13 Acceptance Criteria

이 TestPlan 은 아래를 **전부** 만족할 때만 PASS 로 판정한다.

| # | 조건 |
|---|---|
| AC-1 | §2 Preconditions PRE-1~PRE-5 가 모두 충족됐다 |
| AC-2 | §4 Positive 중 `BLOCKED` 가 아닌 항목이 전부 PASS 다 |
| AC-3 | §5 Negative 전 항목이 PASS 다. **하나라도 FAIL 이면 전체 FAIL** |
| AC-4 | §6 Regression 전 항목이 PASS 다 |
| AC-5 | §7 External Provider negative 전 항목이 PASS 다. **TP-X-01~TP-X-08 중 하나라도 발견되면 즉시 중단** |
| AC-6 | §8 Boundary 전 항목이 PASS 다 |
| AC-7 | §9 Migration 전 항목이 PASS 다 |
| AC-8 | §11 Rollback 계획이 문서로 존재하고 TP-RB-01·TP-RB-02 를 만족한다 |
| AC-9 | §12 의 Blocker 중 해당 범위에 걸리는 것이 Human 판정으로 해소됐거나, 그 범위가 구현에서 제외됐다 |
| AC-10 | 검증자가 Overview / Logic / TestPlan / ChangeContract 의 원작자가 아니다 (`000701` §37) |

> **`BLOCKED` 가 남아 있는 상태로 AC 를 충족했다고 기록하지 않는다.**
> `BLOCKED` 는 해당 범위가 **구현에서 제외됐음**이 명시될 때만 AC-9 로 흡수된다.

## §14 Out Of Scope

| 대상 | 사유 |
|---|---|
| Store 상태 3축의 값·전이 검증 | `601710` §3 |
| `OperatingGroup` / `company` / `business_unit` persistence 검증 | `601710` §3 |
| Staff / User / Session 검증 | 0-B (`601702` §1.18) |
| Role / Permission / Authorization 검증 | 0-C (`601702` §1.19) |
| 과금·정산 경로 검증 | `601702` §2.1 |
| RPC 재작성 검증 | `601700` Readme §5 |
| `FranchiseAgreement` | `601702` §1.10 |
| External Provider Mapping 의 **positive** 검증 | §7 — 이번 나선은 negative 만 수행한다 |
| `0168`/`0169` 의 historical disposition 재판정 | `601710` §5.1 — 전체 lifecycle 완료 후 |

## §15 근거 문서 목록 (`000701` §46)

Overview `601710` §6.1/§6.2 가 79건을 전수 분류했다. 여기에는 **이 TestPlan 이 직접 인용한 것만** 기록한다.

| 문서 | 인용 절 | 권위 | 역할 |
|---|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4.1, §5.4.3, §5.4.4, §5.4.2, §5.7 | ACTIVE | TestPlan 규격·저자 분리·충돌 처리 |
| `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` | §3, §6.11.1, §10, §14.5, §35, §37, §46 | ACTIVE | Stage 게이트·migration 헤더·검증자 분리 |
| `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | §4, §5, §10, §10.1 | 본 워크패킷 | In/Out of Scope, 비구현 경계 |
| 〃 `601701_Register_Stage0_Evidence_Collection.md` | §4.5 D-3 | 본 워크패킷 | LegalEntity 0행 / Store 1행 |
| 〃 `601702_Register_Stage1_Business_Rules.md` | §1.1, §1.2, §1.18, §1.19, §1.34, §1.37, §1.38, §1.39, §1.43, §2.1, §5 | 본 워크패킷 | **최우선 근거** — Human 선언 |
| 〃 `601705_Diagram_Operational_Authority_Core_ERD.md` | §5.2, §8, §10 | 본 워크패킷 | 미정 관계 · Physical Drift · Open Decisions |
| 〃 `601710_Overview_Operational_Authority_Foundation_V2.md` | §2, §2.1, §3, §3.1, §4, §5, §7 | 본 워크패킷 | 구현 대상·제외·negative 검증 지시 |
| 〃 `601711_Evidence_Person_Physical_Impact_Scan_Cursor.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선 |
| 〃 `601712_Evidence_Person_Physical_Impact_Scan_Codex.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선(이중) |
| 〃 `601713_Logic_Operational_Authority_Foundation_V2.md` | §1.1~§1.5, §2, §3, §4, §5, §6 | 본 워크패킷 | I-1~I-33 / X-1~X-11 |
| 〃 `601714_Evidence_Stage4_Logic_Gap_Survey_Cursor.md` | Environment, Q-2 ~ Q-8 | 본 워크패킷 | Logic §6 갭 해소 실측 |
| 〃 `601715_Evidence_Stage4_Logic_Gap_Survey_Codex.md` | 환경, Q-2 ~ Q-8 | 본 워크패킷 | 동일(이중) |
| `sql/migrations/CHANGELOG.md` | 2026-08-07 항목 | 프로젝트 파일 | 재생 관행 — TP-M-06 배경 |
| `tools/Check-Governance.ps1` | G15 | 프로젝트 파일 | TP-M-02·TP-M-03 실행 대상 |

**인용하지 않은 것**: `601500` 대역(`601501`~`601512`)의 설계 결론.
`601504` TestPlan 을 포함해 **어느 항목도 이 TestPlan 의 근거로 쓰지 않았다**(`600020` §2).
`601505` §4 의 금지 조항이 0-A-2 완료까지 유효하다는 **사실**은 `601710` §5 를 경유해 참조했다.

---

> **이 TestPlan 은 구현을 승인하지 않는다.**
> 무엇을 어떻게 검증하는지를 정할 뿐이며, 허용·금지 파일과 물리 변경 방법은
> ChangeContract `601717` 이, 착수 권한은 Stage 7 Human Approval 이 정한다.
>
> §12 의 Blocker 8건 중 해당 범위가 해소되지 않은 채 실행된 테스트 결과는
> **부분 결과이며 나선 종료 근거가 되지 않는다.**
