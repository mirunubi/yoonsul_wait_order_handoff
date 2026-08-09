# 601502_Overview_Operational_Authority_Foundation_Ddl.md

Status: Draft (v4)
Lifecycle: Overview
Stage: 4 (설계문서 정합화 — `000701` §47.1 6단계 나선의 4단계)
Domain: Operational Authority Foundation (0단계 / 하위 나선 0-A)
Last Updated: 2026-08-09

## Change ID

`operational_authority_foundation_ddl`

## 개정 이력

| 버전 | 변경 | 근거 |
|---|---|---|
| v2 | 최초 Overview (`companies`/`owner_companies` 기준) | 3단계 1차 대조 |
| v3 | LegalEntity 중심 모델 전면 재작성 + AV 7개 반영 | 외부 검토(ChatGPT+Gemini) + AV |
| **v4** | **접근제어 사실 정정**(차단 계층은 GRANT+PostgREST), **대표권 테이블 분리**(`legal_entity_representatives`), A-1~A-9 반영 | **3단계 2차 검증** |

**v4에서 정정된 v3의 사실 1건**: "0021 패턴과 동일한 deny-by-default RLS" 서술이 **차단 메커니즘을 잘못 지목**했다
(`601501` §2.7). 신규 테이블이 4개로 늘었다(대표권 분리).

## §0 배경

§47.3이 정의한 0단계(운영 권위 기반)의 첫 하위 나선 **0-A**의 산출물이다.
0단계 목표는 "SaaS 전체 구현"이 아니라 **이후 어떤 도메인을 만들어도 다시 흔들리지 않을 최소 권위 구조 확정**이다(§47.3, §47.6-1).

| 나선 단계 | 수행 | 산출물 |
|---|---|---|
| 1단계 업무규칙 선언 | Human | Owner/사업주체 전역화, Tenant 직접연결 금지, store_groups 재사용 |
| 2단계 ERD 초안 | Cursor(§48) + Claude Code | `601501` v1 |
| 3단계 대조 (1차) | Opus 5 (별도 세션 — §47.1) | B-1/B-2, A-1~A-7 → v2 |
| 외부 검토 + AV | ChatGPT + Gemini / Architecture Verification | LegalEntity 중심 모델 확정 → v3 |
| **3단계 대조 (2차)** | **별도 세션 검증** | **접근제어 정정 + 대표권 분리 + A-1~A-9 → 본 v4** |
| 4단계 설계문서 정합화 | Claude Code (Human 승인 대기) | `601502`/`601503` v4 |
| 5단계 SQL 구현 | Codex (승인 후) | — |

### §0.1 상위 정합 — `003020`의 실현

`003020`/`009030`/`009070`/`007040`이 "company와 legal_entity를 자동 동일시하지 말 것"을 규정해 왔으나
**어느 쪽도 물리 테이블로 존재하지 않았다**. 0-A는 그중 `legal_entity` 축을 실체화한다.

| 003020의 축 | v4 구현체 |
|---|---|
| `legal_entity` (계약·세무·정산 권한) | **`legal_entities` 신규** |
| `company` (브랜드 그룹핑) | 기존 `franchise_brands` — **`store_groups` 아님**(A-3) |
| `operating_group` (지역·운영 그룹핑) | 기존 `store_groups`(`REGION`만) |

> `entity_type='CORPORATION'`은 **법인격의 종류**이지 `003020`의 "company 축"이 아니다.
> 어휘 충돌 경고 전문은 `601501` §0.3.

## §1 해결하는 문제

### §1.1 법적 사업주체 개념의 부재

"누가 이 매장의 법적 책임 주체인가"를 DB가 표현하지 못한다. 여러 RPC가 **존재하지 않는 컬럼**에 그 정보를
쓰려다 실패한다 — `tenants.company_name`/`business_number`/`ceo_name`(0112), `tenants.owner_name`(0082),
`stores.extra_metadata`(0060)가 전부 같은 공백의 증상이다.

단순 컬럼 누락이 아니다. 1단계 업무규칙(한 Tenant에 복수 사업주체 가능)에 의해 tenant 단위 `company_name`은
**정의 자체가 불가능**하므로, phantom 컬럼을 `tenants`에 그냥 추가하는 것은 오답이다.
`ceo_name`도 마찬가지다 — 법인은 공동/각자대표가 가능하고 대표권에 유효기간이 있으므로,
정확한 답은 **`legal_entity_representatives`의 활성 행 집합**이다.

### §1.2 상태축 충돌 — `tenant_status` 상호 파괴

`tenant_status` 하나에 **구독 생명주기**와 **보안 격리**라는 직교하는 두 축을 넣은 결과,
`manage_subscription()` SUSPEND(0112 L595)가 쓴 값을 `isolate_tenant()`(0090 L1283–1295)가 즉시 덮어쓰고,
격리 해제 시 무조건 `'ACTIVE'`로 되돌려 구독상태를 소실시킨다.
1컬럼으로는 `ACTIVE`+`ISOLATED`를 **원리적으로 표현할 수 없다**.

### §1.3 같은 결함의 예방 — "하나의 사실은 한 곳에만"

§1.2의 교훈을 신규 설계에 두 번 적용한다:

1. **Store의 법적 주체**는 `company_id`/`owner_id` 두 갈래로 나누지 않고 **`legal_entity_id` 하나**로 통일.
2. **법적 대표권**은 `is_legal_representative`+`representation_mode` 두 컬럼이 아니라
   **`legal_entity_representatives`의 행 존재 여부** 하나로 판정(v4 신규 — `601501` §2.5).

v3는 2번을 CHECK 제약으로 봉합하려 했다. **제약으로 봉합해야 하는 모순은 애초에 표현 가능해선 안 된다**는 것이
2차 검증의 판정이며, v4는 구조 자체를 바꿨다.

## §2 함께 봐야 하는 파일

| 파일 | 왜 |
|---|---|
| `0002_create_hq_tenant_store.sql` | `tenants`/`stores` 원형 — 컬럼 추가 대상 |
| **`supabase/config.toml`** | **PostgREST 노출 스키마 — 실제 1차 차단 계층(§4.3)** |
| `0022_create_rls_policies.sql` | `grant usage on schema`(L614–623), `is_service_role()` — 접근제어 사실 근거 |
| `0021_enable_rls.sql` | enable+force. **0022와 짝을 이룸 — "정책 0개" 선례 아님** |
| `0072_create_pg_cron_schedules.sql` | `pg_cron_jobs` 카탈로그 + **`is_registered` 역논리 결함 근거(§4.2)** |
| `0077_create_multistore_rpc.sql` | `store_groups` 재사용(신규 생성 금지) |
| `0085_...franchise_os_foundation_rpc.sql` | `franchise_brands` — **읽기 전용**, 축 구분 |
| `0082`/`0090`/`0112` | phantom·상호 파괴 지점. **본 워크패킷에서 수정하지 않음** |
| `0120`/`0123`/`0129` | `tenant_status='ACTIVE'` 필터. **수정하지 않음**(§4.2 승계) |
| `003020`/`009030`/`009070`/`007040` | 상위 개념축 정합 |

## §3 범위 절단 — **DDL 전용** (재논의 금지)

### §3.1 포함

**신규 테이블 4개** (`catchmenu_hq` 스키마) — v3의 3개에서 대표권 분리로 **4개가 됨**
1. `catchmenu_hq.owners`
2. `catchmenu_hq.legal_entities`
3. `catchmenu_hq.legal_entity_person_roles`
4. **`catchmenu_hq.legal_entity_representatives`** (v4 신규)

**신규 컬럼 3개** (전부 가법적)
1. `catchmenu_hq.tenants.tenant_status`
2. `catchmenu_hq.tenants.isolation_state`
3. `catchmenu_hq.stores.legal_entity_id`

부수적으로 위 대상에 직접 딸린 것만: PK/FK/CHECK/부분 UNIQUE 인덱스, 생성컬럼(`brn_normalized`/`crn_normalized`),
`set_updated_at` 트리거, `enable/force row level security`, `comment on`.

**명시적 비포함 — GRANT**: 신규 4개 테이블에 **어떤 역할에도 테이블 권한을 부여하지 않는다**(§4.3, `601501` §2.7.3).

### §3.2 제외 — 전부 별도 후속 워크패킷

| 제외 항목 | 이유 | 이월 |
|---|---|---|
| `isolate_tenant()` / `manage_subscription()` 재작성 | RPC 로직. DDL과 섞으면 실패 원인 분리 불가 | 0-A-2 |
| `0112`의 21개 `tenant_status` 지점 정합화 | **공개 파라미터(L248) 시그니처 결정 + 대시보드 집계 정의 포함** — 단순 치환 아님 | 0-A-2 |
| `0120`/`0123`/`0129` 필터 보강 | 위와 동일. §4.2 승계 필수 | 0-A-2 |
| **`pg_cron_jobs.is_registered` 역논리 결함 수정** | **cron 등록 로직 결함 — DDL 아님(v4 신규)** | **0-A-2** |
| `onboard_tenant()` 재설계 | 파라미터명 불일치 등 독립 결함 다수, 실호출자 0건 | 0-A-3 |
| `provision_tenant()`(0082) 재작성 | owner/legal_entity 생성 흐름 재구성 | 0-A-3 |
| `0060`의 `extra_metadata` 정리 | franchisee 정보 이전 판정 필요 | 후속 |
| `stores.brand_id` 추가 | 브랜드 축 = 미래 나선(§47.2) | 브랜드 나선 |
| 신규 테이블 **GRANT 및 RLS 정책** | 쓰는 RPC가 생길 때 최소권한으로 | 0-C / 후속 |
| `owners`/`legal_entities` CRUD RPC | 0-A는 구조 확정까지 | 후속 |
| 대표권 **행간** 정합성 강제(SOLE 2명 방지 등) | 행 CHECK로 불가 — 트리거/RPC 소관 | 후속(`601501` §2.5.2) |

**절단 근거**: DDL은 `CREATE OR REPLACE FUNCTION`보다 **먼저** 적용돼야 한다(§49.2, PL/pgSQL 지연바인딩).
섞으면 이 순서 요건이 파일 내부 순서 문제로 숨고, 실패 시 "스키마 문제인가 로직 문제인가"를 분리할 수 없다.

## §4 영향 범위와 위험

### §4.1 기존 동작 보존

- 신규 테이블 4개: 참조하는 기존 코드 **0건** → 영향 없음.
- `stores.legal_entity_id`: nullable 추가 → 기존 `insert`/`select *` 영향 없음. `uq_stores_tenant_code`는 tenant 단위 그대로.
- `tenants` 컬럼 2개: `NOT NULL DEFAULT` 추가이나 PostgreSQL 11+ 는 테이블 재작성 없이 처리(메타데이터 전용).

### §4.2 ⚠️ 승계 필수 위험 — "조용한 활성화"와 cron 실측 (A-1)

**(a) 파일 정의상 영향 지점 — Claude Code 직접 확인**

`tenant_status`가 없는 현재 아래 쿼리는 **실행 시 오류로 실패**한다. 컬럼 추가 후에는 **오류 없이 0행 반환**으로 바뀐다(`default 'TRIAL'`).

| 파일 | 지점 | 종류 |
|---|---|---|
| 0120 | L898, L916, L926 | `pg_cron_jobs.sql_command` 내부 `$sql$` (LAYER1/LAYER2) |
| 0129 | L873–885 | 동상 (`HOURLY_METRICS`) |
| 0123 | L636 / 0129 L885 | 함수·뷰 내부 필터 |

**(b) 실측 결과 — 로컬 확인 완료 / 클라우드 미확인**

2차 검증에서 로컬 DB를 실측한 결과:

- **`cron.job` 0행** — 로컬에는 **실제로 스케줄된 pg_cron 작업이 하나도 없다**.
- **`pg_cron_jobs` 카탈로그의 0120 행이 migration 파일 내용과 다르다** — 카탈로그가 파일의 최신 상태를 반영하지 않는다.

> **범위 한정**: 위는 **로컬 DB 실측**이며 **클라우드(운영) DB는 미확인**이다.
> 클라우드 상태는 5단계 착수 전 별도 확인 항목으로 남긴다(`601501` §7 Open Item (m)).

**(c) `is_registered` 역논리 결함 — v4 신규 발견 (0-A-2 승계)**

등록 함수는 `where is_registered = false`인 행만 순회해 `cron.schedule`을 호출하고, 성공 시 `is_registered = true`로
갱신한다([0072](sql/migrations/0072_create_pg_cron_schedules.sql) L201–206, L226–230).
그런데 **0120/0129의 시드 INSERT는 처음부터 `is_registered = true`로 행을 넣는다.**

결과: 이 행들은 **등록 루프가 영원히 집어가지 않는다** — 카탈로그는 "등록됨"이라 주장하지만 `cron.schedule`은
한 번도 호출된 적이 없다. **(b)의 `cron.job` 0행과 정확히 일치**하는 설명이다.
`is_registered`는 실제로는 "등록 여부"가 아니라 "등록 시도 제외 플래그"로 동작하고 있으며,
그 이름과 의미가 반대다.

→ **0-A-2 승계 항목 신규 추가**(`601501` §7 Open Item (n)). 본 워크패킷 범위 밖이다.

**(d) 2컬럼 분리가 추가로 만드는 문제**

분리 후 `ACTIVE`+`ISOLATED`가 표현 가능해지므로 `WHERE tenant_status='ACTIVE'` 필터는
**격리된 테넌트까지 포함**하게 된다 → `AND isolation_state='NONE'` 보강 필요.

**처분**: (a)~(d) 전부 §3.2에 따라 본 워크패킷 범위 밖이나 **0-A-2의 필수 선행 항목으로 승계**한다.
**어떤 tenant를 `ACTIVE`로 승격하기 전에 0-A-2가 완료돼야 한다** — `601503` §5에 못박는다.

### §4.3 접근제어 — v3 서술의 정정 (B-1)

> **v3 §4.3 폐기**: v3는 신규 테이블이 "0021 패턴의 deny-by-default RLS로 닫혀 있다"고 서술했다.
> **차단 계층을 잘못 지목한 것**이다.

실제 차단자는 RLS가 아니라 아래 두 계층이다:

| 계층 | 상태 | 근거 |
|---|---|---|
| **PostgREST 노출 스키마** | `catchmenu_hq` **미노출** | `supabase/config.toml` `[api] schemas = ["public","graphql_public"]` |
| **GRANT (테이블 권한)** | `catchmenu_hq` **16개 테이블 전부 테이블권한 0건** | migration 전수 검색 결과 해당 GRANT 없음 |

- `service_role`: `BYPASSRLS=true`이나 **`catchmenu_hq` 스키마 USAGE 자체가 없다** → 진입 불가.
- `authenticated`: 스키마 USAGE는 있으나(0022 L615) **테이블 권한이 없다** → 접근 불가.

**설계 결정**: 신규 4개 테이블에 **GRANT를 주지 않는다**. 0-A는 구조 확정까지이고, 접근이 필요해지는 시점에
최소 권한만 부여하는 것이 순서다. 지금 열면 0-C가 **이미 열린 문을 닫는 작업**부터 해야 한다.

**해소된 미결**: `SECURITY DEFINER` 함수는 소유자 `postgres`(BYPASSRLS 보유, 스키마·테이블 소유자) 권한으로
실행되므로 **별도 조치 없이 정상 접근**한다 — v3의 Open Item (l)은 해소됐다(`601501` §2.7.4).

### §4.4 미결

- `stores.legal_entity_id` 백필 및 **NOT NULL 승격 시점을 5단계 말미로 앞당기는 판정**(`601503` §4.3, A-8).
- 대표권 **행간** 모순(같은 법인 SOLE 2명 등)은 행 CHECK로 막을 수 없음 — 트리거/RPC 소관(`601501` §2.5.2).
- `is_active` ↔ `effective_from/to` 이중 진실원천 — 0-A는 잠정 계약, 근본 해소는 이월(`601501` §2.5.3).
- 클라우드 `pg_cron` 상태 미확인.

## §5 완료 정의

1. 신규 테이블 4개 + 신규 컬럼 3개가 라이브에 존재하고, 제약/인덱스/생성컬럼/트리거/RLS가 `601503` §2와 일치한다.
2. **신규 테이블에 GRANT가 부여되지 않았음**이 확인된다(§4.3 설계 결정).
3. 재실행(idempotent)해도 오류 없이 같은 결과다(`601503` §6).
4. 기존 RPC/배치가 **본 변경으로 새로 깨지지 않는다**(이미 깨져 있던 것은 그대로 — 수리는 0-A-2/0-A-3).
5. §4.2 위험(특히 `is_registered` 역논리)과 §4.4 미결이 0-A-2로 문서 승계됐다.
6. `000005`/`000007` 등록 완료(§5.11 트리플 업데이트).

## §6 근거 문서 목록 (§46)

`601501` §8의 근거 목록 전체를 승계한다. 본 Overview가 직접 인용한 항목:

| 문서/파일 | 인용 지점 | 역할 |
|---|---|---|
| `000701` §46/§47.1/§47.2/§47.3/§47.4/§47.6/§48/§49.2 | — | 나선 방법론, 세션 분리, 가드레일, D단계, ADD COLUMN 선행 |
| `000001_Md_Rules.md` §5.4.1~§5.4.3 | — | lifecycle 문서 규격 |
| `601501_ERD_Tenant_Company_HQ_Store.md` (v4) | 전체 | 설계 원본 |
| **`supabase/config.toml`** | `[api] schemas`(L7–13) | **PostgREST 미노출 — §4.3** |
| `0022_create_rls_policies.sql` | L614–623, L78–89, L282–294, L606–611 | 스키마 USAGE 분포, `is_service_role()` |
| `0021_enable_rls.sql` | 전체 | 0022와 짝 — "정책 0개" 선례 아님 |
| **`0072_create_pg_cron_schedules.sql`** | **L29–66, L201–206, L226–230** | **`is_registered` 역논리 결함 근거 — §4.2(c)** |
| `docs/003000_saas_runtime/003020_...Context_Model.md` | §2, §3, §4, §6 | LegalEntity 중심 모델 상위 근거 |
| `docs/009000_.../009030_Register_Conceptual_Entity_Master.md` | L18, L19, L21 | 개념 엔터티 정의 |
| `docs/009000_.../009070_Matrix_Context_Entity_Alignment_Model.md` | L5, L19–22, L30, L33 | **company≠operating_group(A-3)** |
| `docs/007000_admin_console/007040_Policy_Admin_Screen_...md` | L21, L40 | 관리자 화면 축 구분 |
| `0002_create_hq_tenant_store.sql` | L8–24, L21–23, L43–76, L60 | `tenants`/`stores` 원형 |
| `0034_seed_data.sql` | L24–25, L52–55 | 시드 tenant/store |
| `0060_create_franchise_hq_rpc.sql` | L235, L946 | `extra_metadata` phantom |
| `0077_create_multistore_rpc.sql` | L25–78, L126–155 | `store_groups` 재사용 |
| `0082_create_saas_billing_rpc.sql` | L88–112, L426–438, L465, L477–486, L490, L500 | `provision_tenant` 실제 시그니처 |
| `0085_...franchise_os_foundation_rpc.sql` | L123–160 | `franchise_brands` — 미변경 |
| `0090_create_multitenant_isolation_rpc.sql` | L1283–1286, L1293–1295 | 상호 파괴 |
| `0112_create_hq_admin_rpc.sql` | 21개 지점(`601501` §8), L414–424 | 파급범위 |
| `0120_create_reconciliation_pipeline.sql` | L898, L916, L926 | cron 문자열 필터 |
| `0123_create_ai_customer_center_v2.sql` | L636 | 필터 |
| `0129_create_launch_readiness_package.sql` | L873–885 | `HOURLY_METRICS` |
| `0137`/`0138` | L64 / L59 | `onboard_tenant` 실호출 아님 근거 |

## Module Domain Tags

`hq`, `tenant`, `store`, `legal_entity`, `owner`, `representative`, `rls`, `grant`, `ddl`

## Snapshot Decision

본 Overview는 `601501_ERD` v4를 유일한 설계 원본으로 삼는다. 충돌 시 **ERD v4가 우선**하며,
그 충돌은 4단계 승인 전 해소해야 한다.
