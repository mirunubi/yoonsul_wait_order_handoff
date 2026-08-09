# 601502_Overview_Operational_Authority_Foundation_Ddl.md

Status: Draft
Lifecycle: Overview
Stage: 4 (설계문서 정합화 — `000701_Guide_Controlled_AI_Development_Pipeline.md` §47.1 6단계 나선의 4단계)
Domain: Operational Authority Foundation (0단계 / 하위 나선 0-A)
Last Updated: 2026-08-09

## Change ID

`operational_authority_foundation_ddl`

## §0 배경 — 이 워크패킷이 존재하는 이유

§47.3이 정의한 0단계(운영 권위 기반)의 첫 하위 나선 **0-A(Tenant/Company/HQ/Store)** 의 산출물이다.
0단계 목표는 "SaaS 전체 구현"이 아니라 **이후 어떤 도메인을 만들어도 다시 흔들리지 않을 최소 권위 구조를 확정**하는 것이다(§47.3, §47.6-1).

진행 경위:

| 나선 단계 | 수행 | 산출물 |
|---|---|---|
| 1단계 업무규칙 선언 | Human | Owner/Company 전역화, Company↔Tenant 직접연결 금지, store_groups 재사용 등 7개 규칙 |
| 2단계 ERD 초안 | Cursor 증거수집(§48) + Claude Code | `601501_ERD` v1 |
| **3단계 인접도메인 대조** | **Opus 5 (별도 세션 — §47.1 세션 분리 요건 충족)** + ChatGPT 교차검증 | B-1/B-2(차단), A-1~A-7(수정후진행) |
| 2단계 재작업 | Claude Code | `601501_ERD` **v2** (검증결과 전량 반영) |
| **4단계 설계문서 정합화** | Claude Code 작성 + **Human 승인 대기** | **본 문서 + `601503_Logic`** |

> §47.1 세션 분리 요건은 이번 나선에서 실제로 준수되었다 — 3단계는 ERD를 작성한 세션과 분리된 새 세션에서 수행됐고,
> 그 결과 ERD v1이 놓친 B-1(1컬럼 구조의 원리적 한계)이 발견됐다. 이 요건 자체가 이번 나선 중 §47.1에 명문화됐다.

## §1 해결하는 문제

### §1.1 구조적 공백 — 사업자·소유자 개념의 부재

`companies`/`owners` 테이블이 migration·라이브 어디에도 없다. 그 결과 "누가 이 매장의 법적 운영 주체인가"를
DB가 표현하지 못하고, 여러 RPC가 **존재하지 않는 컬럼(phantom)** 에 그 정보를 쓰려다 실패한다.
`tenants.company_name`/`business_number`/`ceo_name`(0112), `tenants.owner_name`(0082),
`stores.extra_metadata`(0060)가 전부 같은 공백의 증상이다(`601501` §3).

핵심은 단순 컬럼 누락이 아니다 — 1단계 업무규칙 3(**한 Tenant에 여러 Company 가능**)에 의해
tenant 단위 `company_name`은 **정의 자체가 불가능**하다. 즉 phantom 컬럼을 그냥 `tenants`에 추가하는 것은
오답이며, 별도 축(전역 Company)으로 분리해야만 한다.

### §1.2 상태축 충돌 — `tenant_status` 상호 파괴 (B-1)

`tenant_status` 하나에 **구독 생명주기**와 **보안 격리**라는 직교하는 두 축을 밀어넣은 결과,
두 RPC가 같은 컬럼을 서로 다른 의미로 덮어쓴다(라이브 코드 확인, `601501` §3.3):

- `manage_subscription()` SUSPEND(0112 L592–597)가 `'SUSPENDED'`를 쓴 **직후** `isolate_tenant()`(L599–606)가 `'ISOLATED'`로 **즉시 파괴**
- 격리 해제 시 `isolate_tenant()`(0090 L1283–1286)가 무조건 `'ACTIVE'`로 되돌려 **격리 전 구독상태 소실**

1컬럼으로는 `ACTIVE`+`ISOLATED` 같은 동시상태를 **원리적으로 표현할 수 없다** — 이것이 근본원인이다.

### §1.3 왜 지금 고쳐야 하는가

0-B(Staff identity) 이후 모든 나선이 store/tenant 경계 위에서 동작한다. 권위 구조가 확정되지 않은 채
상위 도메인을 쌓으면 §47.4의 탈출조건 5번("한 Workpacket이 인접 도메인 4개 이상을 동시에 수정")에 직행한다.

## §2 함께 봐야 하는 파일 (구현 컨텍스트)

| 파일 | 왜 봐야 하는가 |
|---|---|
| `sql/migrations/0002_create_hq_tenant_store.sql` | `tenants`/`stores` 실제 정의. 컬럼 추가 대상 |
| `sql/migrations/0021_enable_rls.sql` | deny-by-default RLS 패턴 — 신규 3개 테이블이 그대로 따름 |
| `sql/migrations/0077_create_multistore_rpc.sql` | `store_groups`/`store_group_members` — 재사용 대상(신규 생성 금지) |
| `sql/migrations/0085_create_franchise_os_foundation_rpc.sql` | `franchise_brands` — **읽기 전용 참조**, 축 구분용(`601501` §0.2) |
| `sql/migrations/0090`/`0112` | `tenant_status` 상호 파괴 지점. **본 워크패킷에서 수정하지 않음**(§3) |
| `sql/migrations/0120`/`0123`/`0129` | `WHERE tenant_status='ACTIVE'` 필터. **본 워크패킷에서 수정하지 않음**(§3) |
| `sql/migrations/0034_seed_data.sql` | 시드 tenant/store — 백필 대상 확인용 |

## §3 범위 절단 — **DDL 전용** (A-7, 재논의 금지)

3단계 검증에서 "범위 비대화"가 지적됐다. 본 워크패킷의 5단계(SQL 구현)는 **DDL 전용**으로 절단한다.

### §3.1 포함 (INCLUDE)

**신규 테이블 3개** (전부 `catchmenu_hq` 스키마, deny-by-default RLS 포함)
1. `catchmenu_hq.owners`
2. `catchmenu_hq.companies`
3. `catchmenu_hq.owner_companies`

**신규 컬럼 3개** (전부 가법적 ADD COLUMN)
1. `catchmenu_hq.tenants.tenant_status`
2. `catchmenu_hq.tenants.isolation_state`
3. `catchmenu_hq.stores.company_id`

부수적으로 위 대상에 직접 딸린 것만: PK/FK/CHECK/부분 UNIQUE 인덱스, `set_updated_at` 트리거,
`enable/force row level security`, `comment on`.

### §3.2 제외 (EXCLUDE — 전부 별도 후속 워크패킷)

| 제외 항목 | 이유 | 이월 대상 |
|---|---|---|
| `isolate_tenant()` / `manage_subscription()` 재작성 | RPC 로직 변경. DDL과 섞으면 실패 시 원인 분리 불가 | 후속 워크패킷 (0-A-2) |
| `0120`/`0123`/`0129`의 `tenant_status='ACTIVE'` 필터 보강 | 위와 동일. **단 §4.2 위험 반드시 승계** | 후속 워크패킷 (0-A-2) |
| `onboard_tenant()` 재설계 | 4개 독립 결함, 실호출자 0건(`601501` §3.5) | 후속 워크패킷 (0-A-3) |
| `provision_tenant()`(0082) 재작성 | owner/company 생성 흐름 재구성 필요 | 후속 워크패킷 (0-A-3) |
| `0060`의 `extra_metadata` 참조 정리 | franchisee 정보 이전 판정 필요 | 후속 워크패킷 |
| `stores.brand_id` 추가 | 브랜드 축 = 미래 나선 소관(§47.2) | 브랜드 나선 |
| 신규 3개 테이블의 RLS **정책(policy)** 부여 | deny-by-default로 안전하게 닫힘. 정책식은 0-C 소관 | 0-C (Authorization) |
| `owners`/`companies` 대상 CRUD RPC | 0-A는 구조 확정까지 | 후속 워크패킷 |
| `store_groups` REGION 행 실제 생성 | 데이터 시드, DDL 아님 | 후속 |

**절단 근거**: DDL은 `CREATE OR REPLACE FUNCTION`보다 **먼저** 적용돼야 한다(§49.2, PL/pgSQL 지연바인딩).
DDL과 RPC 재작성을 한 마이그레이션에 섞으면 이 순서 요건이 파일 내부 순서 문제로 숨어버리고,
실패 시 "스키마 문제인가 로직 문제인가"를 분리할 수 없다.

## §4 영향 범위와 위험

### §4.1 기존 동작 보존

- 신규 테이블 3개: 참조하는 기존 코드 **0건** → 기존 동작 영향 없음.
- `stores.company_id`: nullable 추가 → 기존 `insert`/`select *` 영향 없음. `uq_stores_tenant_code`는 **tenant 단위 그대로 유지**(`601501` §2.2).
- `tenants` 컬럼 2개: nullable이 아닌 `NOT NULL DEFAULT`이나, PostgreSQL 11+ 는 기본값 있는 컬럼 추가를 테이블 재작성 없이 처리한다(메타데이터 전용). 기존 행은 전부 default 값을 얻는다.

### §4.2 ⚠️ 승계 필수 위험 — 배치 작업의 조용한 활성화

현재 `tenant_status` 컬럼은 **존재하지 않으므로**, 이를 참조하는 `0120`(pg_cron `sql_command` 문자열 내부)/
`0123`/`0129`의 쿼리는 **실행 시점에 오류로 실패**하고 있다.

본 워크패킷이 컬럼을 추가하면 이 쿼리들은 **오류 없이 성공하기 시작한다**. `default 'TRIAL'`이므로
기존 tenant는 전부 `TRIAL`이 되어 `WHERE tenant_status='ACTIVE'`는 **0행을 반환**한다 —
즉 "실패"가 "조용한 0행 처리"로 바뀐다. 이후 누군가 tenant를 `ACTIVE`로 바꾸는 순간
대사(reconciliation)/감사패킷 배치가 **예고 없이 실제로 돌기 시작**한다.

또한 2컬럼 분리로 인해 `ACTIVE` + `ISOLATED`인 테넌트가 표현 가능해지므로,
이 필터들은 **격리된 테넌트까지 배치 대상에 포함**하게 된다 → `AND isolation_state='NONE'` 보강 필요.

**처분**: 이 보강은 §3.2에 따라 본 워크패킷 범위 밖이나, **0-A-2 후속 워크패킷의 필수 선행 항목으로 승계**한다.
0-A DDL 병합 후 tenant를 `ACTIVE`로 전환하기 전에 0-A-2가 완료돼야 한다 — 이 순서를 `601503_Logic` §5에 못박는다.

### §4.3 남은 미결

- `stores.company_id` 백필: 1호점 사업자번호 **미확정**(Human 확인, 2026-08-09) → `business_number IS NULL`인
  company 행으로 먼저 생성 가능하도록 부분 UNIQUE 채택(`601501` §2.4 D-1). 백필 자체의 시점/방법은 `601503` §4.
- 존재탐지 오라클(A-6): 사업자번호 중복 오류 메시지 설계는 RPC 워크패킷/0-C 소관.

## §5 완료 정의 (Definition of Done)

1. 신규 테이블 3개 + 신규 컬럼 3개가 라이브에 존재하고, 제약/인덱스/트리거/RLS가 `601503_Logic` §2와 일치한다.
2. 기존 RPC/배치 동작이 **본 변경으로 인해 새로 깨지지 않는다**(이미 깨져 있던 것은 그대로 — 수리는 0-A-2/0-A-3).
3. §4.2 위험이 0-A-2 워크패킷에 문서로 승계됐다.
4. `000005`/`000007` 등록 완료(§5.11 트리플 업데이트).

## §6 근거 문서 목록 (§46)

| 문서/파일 | 이 설계에서의 역할 |
|---|---|
| `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` §46/§47.1/§47.2/§47.3/§47.4/§47.6/§48/§49.2 | 나선 방법론, 세션 분리 요건, 범위 가드레일, `ADD COLUMN` 선행순서 |
| `docs/.../601500_.../601501_ERD_Tenant_Company_HQ_Store.md` (v2) | 본 워크패킷의 ERD·스키마계약·phantom 정리 원본 |
| `docs/000001_Md_Rules.md` §5.4.1/§5.4.2/§5.4.3 | Overview/Logic 문서 규격 및 lifecycle 순서 |
| `sql/migrations/0002_create_hq_tenant_store.sql` | `tenants`(L8–24), `stores`(L43–76), `uq_stores_tenant_code`(L60), `chk_tenants_plan`(L21–23) |
| `sql/migrations/0021_enable_rls.sql` | deny-by-default RLS 패턴 |
| `sql/migrations/0034_seed_data.sql` | 시드 tenant `YOONSUL_TEST`(L24–25), `윤슬 울산 1호점`(L52–55) |
| `sql/migrations/0060_create_franchise_hq_rpc.sql` | `stores.extra_metadata` phantom(L235, L946) |
| `sql/migrations/0077_create_multistore_rpc.sql` | `store_groups`(L25–78), `store_group_members`(L126–155) |
| `sql/migrations/0082_create_saas_billing_rpc.sql` | `provision_tenant` owner/tenant_status phantom(L429, L479–483) |
| `sql/migrations/0085_create_franchise_os_foundation_rpc.sql` | `franchise_brands`(L123–160) — 축 구분 근거, **미변경** |
| `sql/migrations/0090_create_multitenant_isolation_rpc.sql` | `isolate_tenant` 상태 덮어쓰기(L1283–1286, L1293–1295) |
| `sql/migrations/0112_create_hq_admin_rpc.sql` | 상호 파괴(L592–606), `tenant_status` SELECT(L533), `brand_id`(L456–458), `onboard_tenant`(L373–384) |
| `sql/migrations/0120_create_reconciliation_pipeline.sql` | `pg_cron_jobs.sql_command` 내부 필터(L898/916/926) |
| `sql/migrations/0123_create_ai_customer_center_v2.sql` | `tenant_status='ACTIVE'` 필터(L636) |
| `sql/migrations/0129_create_launch_readiness_package.sql` | `tenant_status='ACTIVE'` 필터(L885) |
| `sql/migrations/0137`/`0138` | `'Run onboard_tenant()'` 문자열 언급(실호출 아님 근거) |

## Module Domain Tags

`hq`, `tenant`, `store`, `company`, `owner`, `rls`, `ddl`

## Snapshot Decision

본 Overview는 `601501_ERD` v2를 유일한 설계 원본으로 삼는다. ERD v2와 본 문서가 충돌하면 **ERD v2가 우선**하며,
그 충돌 자체를 4단계 승인 전 해소해야 한다.
