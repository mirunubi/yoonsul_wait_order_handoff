# 601740_VerificationResult_Stage9_Implementation_Verification_ClaudeCode.md

Status: Active
Lifecycle: VerificationResult
Owner: Stage 9 (Claude Code) — Verifier A
Last Updated: 2026-08-24

> 🛑 **이 문서는 Stage 9 COMPLETE 를 선언하지 않는다.**
>
> `000701` Critical tier 에서 Cursor 가 이 문서와 actual diff 를 받아 `MinorOpinion` 을 작성한다.
> 그 뒤 Claude 통합과 Human 확인이 남는다.

> ⚠️ **이 Stage 의 권한은 판정이 아니라 관측이다.**
> Claude Code 는 terminal operator / raw log collector / result recorder 이며 judge 가 아니다.
> **`TESTPLAN_DEFECT` · `CONTRACT_DEFECT` 를 확정하지 않는다.**

## §0 AC-13 known specification conflict — 먼저 읽을 것

**승인된 `601716` AC-13 과 `000701` Stage 9 가 정면 충돌한다.**

| 출처 | 조항 (인용) |
|---|---|
| `601716` AC-13 (승인 판본) | 「검증자가 상위 문서 및 본 문서의 원작자가 아니다 (`000701` §37)」 |
| `000701` §9 Stage 9 | 구현 검증자로 **Claude Code** 를 지정. Codex 는 구현자이므로 제외 |
| 실제 | **Claude Code 가 `601710` / `601713` / `601716` / `601717` 의 원작자다** (`601717` §0 저자 분리 표 · Stage 5 Provenance) |

```text
분류    SPEC_CONFLICT_OBSERVED / HUMAN_ADJUDICATION_NEEDED
판정    AC-13 = SKIP(SPEC_CONFLICT_AC13)
```

**AC-13 을 PASS 로 적지 않았다.** Stage 9 actor assignment 를 변경하지도 않았고
`IMPLEMENTATION_DEVIATION` 으로 분류하지도 않았다.

> ⚠️ **이 충돌은 `0170`·`0171` 구현 결함을 의미하지 않는다.**
> 구현 자체의 기계적 검증 결과는 §4 이하에 별도로 있다.

> **`601739` §0.1 은 AC-13 을 PASS 로 기록했다.** 그 근거는 「Cowork 이 원작자가 아니다」이며,
> Cowork 은 `000701` §9.16 이 정의한 Stage 9 actor 가 아니다.
> **그 PASS 는 이 검증 실행에 이전되지 않는다** — §11 대조 참조.

## §1 검증 대상 판본 고정 — 실측

### §1.1 EOL 선행 확인 (`601717` §10.9 대조 절차 0단계)

```text
$ git ls-files --eol <4 files>

i/lf  w/lf  attr/            601716_TestPlan_...md
i/lf  w/lf  attr/            601717_ChangeContract_...md
i/lf  w/lf  attr/text eol=lf 0170_person_vocabulary_normalization.sql
i/lf  w/lf  attr/text eol=lf 0171_merchant_account_foundation.sql
```

`core.autocrlf=true` 환경이나 working tree 가 `w/lf` 다. **EOL drift 없음.**

### §1.2 판본 대조

| 대상 | 승인 고정값 | 실측 | 판정 |
|---|---|---|---|
| `601716` SHA-256 (repository LF content) | `00C1376E…F102` | worktree `00c1376e…f102` · `git show HEAD:` blob 동일 | **일치** |
| `601717` 승인 기준 커밋 (§10.10) | `01cfd45bab7710b0db2a4957b7e540bebfad7377` | 존재 확인. 현 최종 변경 커밋은 `accf0666`(§10.9 5단계 기록 커밋) | **일치 — §10.9 5단계 규정대로** |
| `0170` | `b657ec2` | `b657ec23ce5493c7561cd1139c93c6ee2bc21090` | **일치** |
| `0171` | `bc4cd14` | `bc4cd14deaea6d696d573d437163ab42d4f93619` | **일치** |

> `601717` 의 최종 변경 커밋이 승인 커밋(`01cfd45b`)이 아니라 그 다음 커밋(`accf0666`)인 것은
> §10.9 「기록 시점 5단계」가 규정한 상태다 — 「5단계 커밋은 기록 행위이며 계약 내용을 바꾸지 않는다」.

### §1.3 실행 환경

```text
canonical DB   supabase_db_yoonsul_wait_order_handoff
               public.ecr.aws/supabase/postgres:17.6.1.140
               PostgreSQL 17.6 on x86_64-pc-linux-gnu
               SHOW default_transaction_read_only  ->  on        <- 강제 read-only 확인
disposable DB  wp601700_replay_verify (동일 이미지, 검증 후 삭제)
```

**canonical DB 에 write 를 수행하지 않았다.** 검증 종료 후 재확인:
`merchant_accounts` 1행 / `migration_history` 171행 / `catchmenu_hq` BASE TABLE 21 — 검증 전과 동일.

**금지 함수 호출 0회** — `601505` §4 7건 및 phantom 참조 확인 함수 3건
(`provision_tenant` / `create_franchise_store` / `onboard_tenant`) 전부 미호출.

## §2 Test ID inventory — 승인판 `601716` 에서 직접 생성

**번호 범위를 하드코딩하지 않고 승인판 문면에서 추출했다.**

| 접두 | 정의 건수 | 폐기(제외) | 활성 | 실행 | 누락 |
|---|---:|---:|---:|---:|---:|
| `BL-` | 38 | 0 | 38 | 38 | 0 |
| `TP-P-` | 38 | 0 | 38 | 38 | 0 |
| `TP-N-` | 65 | 0 | 65 | 65 | 0 |
| `TP-D-` | 9 | 0 | 9 | 9 | 0 |
| `TP-R-` | 20 | 0 | 20 | 20 | 0 |
| `TP-RB-` | 8 | 0 | 8 | 8 | 0 |
| `TP-RT-` | 8 | 1 | 7 | 7 | 0 |
| `TP-B-` | 8 | 0 | 8 | 8 | 0 |
| `TP-M-` | 11 | 0 | 11 | 11 | 0 |
| `TP-X-` | 13 | 0 | 13 | 13 | 0 |
| `AC-` | 18 | 0 | 18 | 18 | 0 |
| **합계** | **236** | **1** | **235** | **235** | **0** |

**폐기(취소선) 항목 — 활성 inventory 에서 제외하되 사실을 기록한다**

```text
TP-RT-03            폐기 (2026-08-23, F-5 처분) — 대체: TP-N-62~64
TP-N-63 (종전 정의)  폐기 (2026-08-23, R2-F3 처분) — 현행 TP-N-63 이 정적 증거로 재정의됨
```

`BL-2~4` 는 한 행에 3개 값을 담으므로 행 수 36, 항목 수 38 이다. 위 표는 **항목 수** 기준이다.

## §3 종합

| 접두 | 총 | PASS | FAIL | SKIP |
|---|---:|---:|---:|---:|
| `BL-` | 38 | 36 | 2 | 0 |
| `TP-P-` | 38 | 38 | 0 | 0 |
| `TP-N-` | 65 | 65 | 0 | 0 |
| `TP-D-` | 9 | 9 | 0 | 0 |
| `TP-R-` | 20 | 18 | 2 | 0 |
| `TP-RB-` | 8 | 6 | 0 | 2 |
| `TP-RT-` | 7 | 5 | 0 | 2 |
| `TP-B-` | 8 | 8 | 0 | 0 |
| `TP-M-` | 11 | 9 | 2 | 0 |
| `TP-X-` | 13 | 13 | 0 | 0 |
| `AC-` | 18 | 14 | 2 | 2 |
| **합계** | **235** | **221** | **8** | **6** |

### §3.1 TestPlan 결과 판정

```text
FAIL = 8   (> 0)

-> TESTPLAN FAILURES FOUND
```

**SKIP 도 6건이므로 아래도 동시에 참이다.**

```text
실행    229건  (PASS 221 · FAIL 8)
미실행    6건  (SKIP)

-> TESTPLAN NOT FULLY EXECUTED
```

### §3.2 Stage 9 상태 판정 — TestPlan 결과와 별개

```text
INCOMPLETE
```

**사유 — 세 가지가 각각 독립적으로 성립한다**

| # | 사유 | 근거 |
|---|---|---|
| 1 | unresolved specification conflict 존재 | AC-13 (§0) · TP-M-07 (§6.1) · BL-33/TP-R-19 (§6.2) |
| 2 | 필수 검증 미수행 | TP-M-08 clean baseline replay 가 `0170` 에 도달하지 못함 (§6.3) |
| 3 | required test SKIP 6건 | governing rule 이 명시적으로 허용한 SKIP 이 아님 (§8) |

> ⚠️ **구현이 완벽해도 spec conflict 때문에 `INCOMPLETE` 가 될 수 있다. 그 구분을 흐리지 않는다.**
>
> **`0170`·`0171` 자체의 기계적 계약 준수는 별개로 측정됐다** — §4·§5·§7.
> **`IMPLEMENTATION_DEVIATION_OBSERVED` 는 0건이다.**

## §4 `0170` / `0171` 계약 대조 — 파일 정적 검사

### §4.1 `0170` — §1.3 D-1~D-13

| 계약 | 파일 행 | 실측 | 판정 |
|---|---|---|---|
| D-1 `owners`→`persons` | L6 | `ALTER TABLE catchmenu_hq.owners RENAME TO persons` | 일치 |
| D-2 `lepr.owner_id`→`person_id` | L9-10 | 일치 | 일치 |
| D-3 `ler.owner_id`→`person_id` | L13-14 | 일치 | 일치 |
| D-4 `owner_name`→`person_name` | L17-18 | 일치 | 일치 |
| D-5 트리거명 | L21-22 | `trg_owners_updated_at`→`trg_persons_updated_at` | 일치 |
| D-6 / D-7 FK 제약명 | L25-32 | `…_person_id_fkey` 2건 | 일치 |
| D-8 `owners_pkey`→`persons_pkey` | L35 | 일치 | 일치 |
| D-9 `idx_lepr_owner`→`idx_lepr_person` | L38 | 일치 | 일치 |
| D-10 `persons.is_active` DROP | L41 | 일치 | 일치 |
| D-11 `chk_lepr_ownership_percent` DROP | L44-45 | **D-12 보다 먼저** | 일치 (§1.3 주석 준수) |
| D-12 `ownership_percent` DROP | L48-49 | 일치 | 일치 |
| D-13 `COMMENT ON TABLE persons` | L52-53 | §4.2.1 확정 literal 과 **문자 단위 동일** | 일치 |

**D-1~D-13 외 조작 0건.** `BEGIN;`/`COMMIT;` 단일 트랜잭션.

### §4.2 `0171` — §1.4 D-14~D-21 · §4.5 M-1·M-2

| 계약 | 파일 행 | 실측 | 판정 |
|---|---|---|---|
| D-14 `CREATE TABLE merchant_accounts` 5컬럼 | L6-18 | 5컬럼 + `merchant_accounts_pkey` + `fk_merchant_accounts_tenant_id` | 일치 |
| D-15 `ADD CONSTRAINT … UNIQUE` | L21-22 | `uq_merchant_accounts_tenant UNIQUE (tenant_id)` — **제약 형태** | 일치 (R2-F1·CW-B1 준수) |
| D-16 BEFORE UPDATE 트리거 | L25-27 | `trg_merchant_accounts_updated_at` → `catchmenu_common.set_updated_at()` | 일치 |
| D-17 RLS ENABLE + FORCE | L30-31 | 일치 | 일치 |
| D-18 `stores.merchant_account_id` NULL 허용 | L34 | `uuid` (NOT NULL 없음) | 일치 |
| D-19 FK | L37-42 | `fk_stores_merchant_account_id`, NO ACTION/NO ACTION | 일치 |
| D-20 인덱스 | L45-46 | `idx_stores_merchant_account_id` | 일치 |
| D-21 COMMENT 3건 | L49-56 | §4.2.1 확정 literal 3건과 **문자 단위 동일** | 일치 |
| M-1 | L59-60 | §4.5.1 확정 SQL 과 동일 | 일치 |
| M-2 | L63-66 | `UPDATE stores SET merchant_account_id = ma.id FROM merchant_accounts ma WHERE ma.tenant_id = s.tenant_id` | 일치 |

**`CREATE UNIQUE INDEX` 사용 0건. 인라인 `UNIQUE` 0건.** 두 CW-B1 금지 형태 모두 회피됐다.

### §4.3 §1.6 허용 동사 · §6 금지 조작 대조

```text
CASCADE                        0건   (FO-4 / TP-M-09)
DROP TABLE                     0건   (FO-2 / TP-M-10)
CREATE OR REPLACE FUNCTION     0건   (FO-15 / TP-M-11)
SET NOT NULL                   0건   (FO-13 / TP-N-42)
INSERT                         1건   merchant_accounts (M-1)
UPDATE                         1건   stores.merchant_account_id (M-2)
DELETE                         0건
VALUES (리터럴 주입)            0건
provider|external|mapping|벤더명 0건  (TP-X-13)
stores.legal_entity_id 언급     0건  (FO-12 / TP-N-30)
tenants DDL·DML                0건  (FO-18 / TP-N-58) — REFERENCES 와 SELECT 만
provision_tenant 등 RPC 호출문   0건  (TP-N-63)
```

## §5 전건 결과표

> 기대값은 승인판 `601716` 문면이다. exact expectation 은 문자 단위 대조했다.

### §5.1 BL — 기준선 (`0170`·`0171` 적용 후이므로 after 가 기대값)

| Test ID | 기대값 | 실측값 | 판정 | raw log |
|---|---|---|---|---|
| BL-1 | 0 | 0 | PASS | 07 |
| BL-2~4 | 0 / 0 / 0 | 0 / 0 / 0 | PASS | 07 |
| BL-5 | 1 | 1 | PASS | 07 |
| BL-6 | 0 | 0 | PASS | 07 |
| BL-7 | 21 | 21 | PASS | 07 · 11 |
| BL-8 | 0 | 0 | PASS | 07 |
| BL-9 | 0 / 0 | 0 | PASS | 07 |
| BL-10 | `ENABLE`+`FORCE` (대상 `persons`) | t / t | PASS | 07 · 13 |
| BL-11 | 4, `is_grantable=NO` | 4, 전부 NO | PASS | 07 · 13 |
| BL-12 | 115 | 115 | PASS | 07 · 11 |
| BL-13 | 0 | 0 | PASS | 07 |
| BL-14 | 5 | 5 | PASS | 07 |
| BL-15 | 1 | 1 (`catchmenu_hq.merchant_accounts`) | PASS | 09 |
| BL-16 | 선언된 증가분만 | 7 (기존 5 + `merchant_account_name` + `merchant_account_id`) | PASS | 09 |
| BL-17 | 0 | 0 (implementation delta = sql 2파일) | PASS | 03 |
| BL-18 | 5개 | 5개 (`OWNER`/`REPRESENTATIVE`/`DIRECTOR`/`EXECUTIVE`/`INVESTOR`) | PASS | 07 |
| BL-19 | 0 | 0 | PASS | 07 |
| BL-20 | 10컬럼, 1행, 무변경 | 10 / 1 | PASS | 07 |
| BL-21 | 17 | 17 | PASS | 07 · 10 |
| BL-22 | **158** | **151** | **FAIL** | 11 — §6.2 |
| BL-23 | 10 | 10 | PASS | 07 |
| BL-24 | 1 | 1 | PASS | 07 · 10 |
| BL-25 | 1 | 1 | PASS | 07 · 10 |
| BL-26 | 변경됨 | `created_at` 2026-07-09 → `updated_at` 2026-08-24 02:25:14 | PASS | 10 |
| BL-27 | `TRIAL` / `NONE` 무변경 | `TRIAL` / `NONE` | PASS | 07 |
| BL-28 | 2, 본문 불변 | 2, md5 baseline 일치 | PASS | 11 |
| BL-29 | 0 / 0 | INSERT 경로 2건 모두 `COLUMN_LIST`, prosrc 불변 → 0 / 0 | PASS | 11 (파생) |
| BL-30 | 0 | 함수 생성·수정 0건이므로 baseline 0 유지 | PASS | 11 (파생) |
| BL-31 | 2, 본문 불변 | 2 (`onboard_tenant`/`update_business_hours`) | PASS | 11 |
| BL-32 | 0 | 0 | PASS | 03 |
| BL-33 | **241** (internal 240 / user 1) | **243** (internal 242 / user 1) | **FAIL** | 11 — §6.2 |
| BL-34 | 0 / 0 | 0 / 0 | PASS | 11 |
| BL-35 | `f84ac1a81da4ccba87930bf020a3e974` / 4758 | 동일 | PASS | 11 |
| BL-36 | `87511a95676a41d2c95866e0c2da8b7f` / 3460 | 동일 | PASS | 11 |
| BL-37 | 둘 다 부재 | 0건 | PASS | 11 |
| BL-38 | `text NOT NULL`, 1행, 무변경 | 1행, `merchant_account_name` 과 문자열 동일 | PASS | 10 |

### §5.2 TP-P — Positive (38건 전건 PASS)

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-P-01 | 1건 | `catchmenu_hq.persons` BASE TABLE 1 | PASS |
| TP-P-02 | `id uuid` 단일 PK | `PRIMARY KEY (id)`, `id uuid NOT NULL` | PASS |
| TP-P-03 / 04 | 각 1건 | `lepr.person_id` · `ler.person_id` | PASS |
| TP-P-05 | 2건 동시 참조 | 두 FK 모두 `REFERENCES catchmenu_hq.persons(id)` | PASS |
| TP-P-06 | 2건 모두 NO ACTION | `confdeltype=a` / `confupdtype=a` × 2 | PASS |
| TP-P-07 | `…_person_id_fkey` | 2건 모두 일치 | PASS |
| TP-P-08 | `trg_persons_updated_at` + `set_updated_at()` | 정확히 일치 | PASS |
| TP-P-09 | `(legal_entity_id, person_id, role_type)` active 부분 unique | `uq_lepr_active` 정의 일치 | PASS |
| TP-P-10 | `(legal_entity_id, person_id)` active 부분 unique | `uq_ler_active` 정의 일치 | PASS |
| TP-P-11 | 존재·정의 불변 | `uq_ler_sole_active` 불변 | PASS |
| TP-P-12 | 존재, `person` 기준 이름 | `idx_lepr_person` on `(person_id) WHERE is_active` | PASS |
| TP-P-13 | `person` 기준 | `persons_pkey` | PASS |
| TP-P-14 | 둘 다 true | t / t | PASS |
| TP-P-15 | 4건, `is_grantable=NO` | 4건 전부 NO | PASS |
| TP-P-16 | BL-11 대비 동일 | postgres 7 privilege | PASS |
| TP-P-17 | 0건 | 0 | PASS |
| TP-P-18 | 1건, NOT NULL | `person_name text NOT NULL` | PASS |
| TP-P-19 | 6컬럼 | 6 | PASS |
| TP-P-20 / 21 | 0건 / 0건 | 0 / 0 | PASS |
| TP-P-22 | 유지 | `legal_entity_representatives` 존재 | PASS |
| TP-P-23 | D-13 확정 literal 과 **문자열 동일** | 완전 일치 | PASS |
| TP-P-24 | 0건 | column/table/index/constraint/trigger 전 범주 0 | PASS |
| TP-P-25 | 1건 | `catchmenu_hq.merchant_accounts` BASE TABLE | PASS |
| TP-P-26 | `uuid` PK / NOT NULL / `gen_random_uuid()` / PK명 `merchant_accounts_pkey` | 전부 일치 | PASS |
| TP-P-27 | FK → `tenants(id)`, NO ACTION ×2, 제약명 `fk_merchant_accounts_tenant_id` | 전부 일치 | PASS |
| TP-P-28 | NOT NULL | `is_nullable=NO` | PASS |
| TP-P-29 | `UNIQUE` **제약**, 제약명 `uq_merchant_accounts_tenant` | `contype=u`, `UNIQUE (tenant_id)` | PASS |
| TP-P-30 | 정확히 `merchant_account_name`, `text NOT NULL` | 일치 | PASS |
| TP-P-31 | `timestamptz NOT NULL DEFAULT now()` ×2 | 일치 | PASS |
| TP-P-32 | BEFORE UPDATE + `set_updated_at()`, 트리거명 확정 | `trg_merchant_accounts_updated_at`, tgtype=19 | PASS |
| TP-P-33 | 둘 다 true | t / t | PASS |
| TP-P-34 | 존재 + FK, 제약명 `fk_stores_merchant_account_id` | 일치 | PASS |
| TP-P-35 | NO ACTION | `a` / `a` | PASS |
| TP-P-36 | 인덱스명 `idx_stores_merchant_account_id` | 일치 | PASS |
| TP-P-37 | 2건 별도 테이블 | 2 | PASS |
| TP-P-38 | §4.2.1 literal 3건과 문자열 동일 | 3건 전부 완전 일치 | PASS |

### §5.3 TP-N — Negative (65건 전건 PASS)

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-N-01 / 02 | 0건 | `catchmenu_hq.owners` relation 0 (relkind 무관) | PASS |
| TP-N-03 | 0건 | `owner_id`/`owner_name` 컬럼 0 (catchmenu 전 스키마) | PASS |
| TP-N-04 | 0건 | 0 | PASS |
| TP-N-05 | 0건 | `persons` 에 `is_active`/`active`/`enabled`/`status` 0 | PASS |
| TP-N-06 | 0건 | `%ownership%` 컬럼 0 (전 스키마) | PASS |
| TP-N-07 | 불변 | `catchmenu_common.set_updated_at` 존재, md5 `1c4318be…` len 53 | PASS |
| TP-N-08 | 불변 | `catchmenu_authority_owner` 존재 | PASS |
| TP-N-09 / 10 / 11 | 각 0건 | 5개 테이블 policy 합계 0 | PASS |
| TP-N-12 | `rolbypassrls=true`, `rolcanlogin=false` | t / f | PASS |
| TP-N-13 | 0건 | `merchant_accounts` grantee = postgres(소유자) 뿐 | PASS |
| TP-N-14 | 정확히 4건 | 4 | PASS |
| TP-N-15 | 불변 | `tenants` t/t, `stores` t/t | PASS |
| TP-N-16~20 | 각 0건 | legal_entity 0 · owner 0 · status/trial 0 · contact/billing 0 · store_id/metadata 0 | PASS |
| TP-N-21 | 정확히 5 | 5 | PASS |
| TP-N-22 | 0건 | `tenants.merchant_account_id` 0 | PASS |
| TP-N-23 | 0건 | merchant 계열 테이블 = `merchant_accounts` 1건뿐 | PASS |
| TP-N-24 | 0건 | `catchmenu_hq` 에만 존재 | PASS |
| TP-N-25 | `is_nullable=YES` | YES | PASS |
| TP-N-26 / 27 | 0행 / 0행 | 0 / 0 | PASS |
| TP-N-28 | 0건 | 함수 생성·수정 0건 | PASS |
| TP-N-29 | 0건 | 시점 이력 테이블 0 | PASS |
| TP-N-30 | 0건 | `0170`·`0171` 에 `legal_entity_id` 언급 0 | PASS |
| TP-N-31~38 | 각 0건 | delta 가 만든 relation = `merchant_accounts` 1건뿐. enum 0 · snapshot 컬럼 0 · Staff/User/Session 변경 0 | PASS |
| TP-N-39 | 0건 | 신규 provisioning 함수 0 | PASS |
| TP-N-40 | `is_nullable=YES` | YES | PASS |
| TP-N-41 | `is_nullable=NO` | NO | PASS |
| TP-N-42 | 0건 | `SET NOT NULL` 0 | PASS |
| TP-N-43 | 0건 | `merchant_account_id` 강제 CHECK 0 | PASS |
| TP-N-44 | 정확히 1건 | INSERT 1 (`merchant_accounts`) | PASS |
| TP-N-45 | 정확히 1건 | UPDATE 1 (`stores.merchant_account_id`) | PASS |
| TP-N-46 | 0건 | DELETE 0 | PASS |
| TP-N-47 | 리터럴 0건 | `VALUES` 0, 두 DML 모두 원천 파생 | PASS |
| TP-N-48 | 0행 | 4테이블 전부 0행 | PASS |
| TP-N-49 | 나머지 전부 불변 | M-2 SET 절이 `merchant_account_id` 단일 | PASS |
| TP-N-50 | `f84ac1a81da4ccba87930bf020a3e974` | 일치 (len 4758) | PASS |
| TP-N-51 | `87511a95676a41d2c95866e0c2da8b7f` | 일치 (len 3460) | PASS |
| TP-N-52 | 0건 | 두 RPC 모두 `merchant_account_id` 미포함 (f/f) | PASS |
| TP-N-53 | 불변 | `onboard_tenant` `46469f72…`/2793, `update_business_hours` `147f9f89…`/1750 — 함수 DDL 0건 | PASS |
| TP-N-54 | 2건 | 2 | PASS |
| TP-N-55 | 2건 | 2 | PASS |
| TP-N-56 | 0건 | `stores` user 트리거 1건 유지, 신규 0 | PASS |
| TP-N-57 | 0건 | seed 변경 0 | PASS |
| TP-N-58 | 불변 | `TRIAL`/`NONE`, tenants DDL·DML 0 | PASS |
| TP-N-59 | 0건 | `brand_id`/`extra_metadata` 0 | PASS |
| TP-N-60 | 0건 | 제외 목록 전 범주 0 | PASS |
| TP-N-61 | 0건 | `account_name` 컬럼 0 | PASS |
| TP-N-62 | baseline md5 일치 | `f84ac1a8…` 일치 | PASS |
| TP-N-63 | ① md5 불변 ② migration 본문 호출문 0건 | ① 일치 ② 0 | PASS |
| TP-N-64 | BL-20 유지 | tenants 1행, read-only 강제로 write 불가 | PASS |
| TP-N-65 | 정확히 2건 | `merchant_accounts_pkey` · `uq_merchant_accounts_tenant` | PASS |

### §5.4 TP-D — Data (9건 전건 PASS)

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-D-01 | `tenants` 행 수와 일치 | ma 1 / tenants 1 | PASS |
| TP-D-02 | 누락 0 · 중복 0 | 0 / 0 | PASS |
| TP-D-03 | 0건 | 0 | PASS |
| TP-D-04 | 전 행 문자열 동일 | mismatch 0 | PASS |
| TP-D-05 | 전 행 일치 | wrong 0 | PASS |
| TP-D-06 | 0건 | 0 | PASS |
| TP-D-07 | BL-5·BL-20 유지 | tenants 1 / stores 1 | PASS |
| TP-D-08 | 0건 | 0 | PASS |
| TP-D-09 | §4.5.1 확정 구문과 동일 | 완전 일치 | PASS |

### §5.5 TP-R — Regression

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-R-01 | 21 | 21 | PASS |
| TP-R-02 | 115 | 115 | PASS |
| TP-R-03 | 불변 | md5 `1c4318be…` len 53 | PASS |
| TP-R-04 | 11컬럼 | 11 | PASS |
| TP-R-05 | 10컬럼 | 10 | PASS |
| TP-R-06 | 17 | 17 | PASS |
| TP-R-07 | 3건 불변 | `chk_legal_entities_{crn_not_for_sole,entity_type,status}` | PASS |
| TP-R-08 | 불변 | `chk_ler_{effective_range,representation_mode}` · `chk_lepr_effective_range` | PASS |
| TP-R-09 | 4건 · 3건 불변 | `chk_tenants_*` 4 / `chk_stores_*` 3 | PASS |
| TP-R-10 | 5개 불변 | 5 | PASS |
| TP-R-11 | 불변 | `fk_stores_legal_entity_id` · `uq_stores_tenant_code` · `idx_stores_tenant_id` 전부 존재 | PASS |
| TP-R-12 | 0건 | 0 | PASS |
| TP-R-13 | 0건 | 0 | PASS |
| TP-R-14 | before/after 모두 **158**, 본문 불변 | **151** (본문 불변은 충족) | **FAIL** — §6.2 |
| TP-R-15 | 10건 존재, 본문 불변 | 10 | PASS |
| TP-R-16 | 동일 | `0168` `263615fd…` / `0169` `eb9b1188…` — 파일 sha256 = `migration_history` 값 | PASS |
| TP-R-17 | 불변 | 171행 (169 + 2 신규) | PASS |
| TP-R-18 | 0건 | 두 RPC 시그니처가 `601720`/`601721` 기록과 동일 | PASS |
| TP-R-19 | **241** | **243** | **FAIL** — §6.2 |
| TP-R-20 | 0 / 0 | 0 / 0 | PASS |

### §5.6 TP-RT — Runtime

> 승인판이 정적 대체를 허용한 ID 만 PASS 로 두었다.

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-RT-01 | 0건 | `owners` 참조 함수 0, 함수 DDL 0건 | PASS (정적) |
| TP-RT-02 | 0건 | `SELECT *`·행타입 의존 0(baseline), prosrc 전건 불변 | PASS (정적) |
| ~~TP-RT-03~~ | 폐기 | — | 활성 inventory 제외 |
| TP-RT-04 | 동일 | 앱 빌드·테스트 스위트 미실행 | **SKIP(NOT_EXECUTED)** |
| TP-RT-05 | 불변 | RLS t/t + bypassrls + GRANT 4 불변 | PASS (정적) |
| TP-RT-06 | 도달 0 | grantee = postgres 뿐, RLS FORCE, policy 0 | PASS |
| TP-RT-07 | 불변 | `set_updated_at` 트리거 115, `chk_*` 전건 존재 | PASS |
| TP-RT-08 | 동일 오류 | **호출 금지 함수** — 실행 검증 불가 | **SKIP(FORBIDDEN_FUNCTION_CALL)** |

> **TP-RT-08 정적 방증**: `create_franchise_store` prosrc md5 불변 + `stores.extra_metadata` 여전히 부재.
> **그러나 실행하지 않았으므로 PASS 로 적지 않는다.**
> AC-15 에 따라 이 함수의 현재 실패를 이 구현의 결함으로 판정하지 않았다.

### §5.7 TP-B — Boundary (8건 전건 PASS)

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-B-01 | §1 허용 목록의 부분집합 | `0170`·`0171` 2파일뿐 | PASS |
| TP-B-02 | 0건 | 0 | PASS |
| TP-B-03 | 0건 | 기존 migration 수정 0 | PASS |
| TP-B-04 | 0건 | `apps`/`packages`/`catchmenu_app`/`tests`/`tools` 0 | PASS |
| TP-B-05 | 0건 | `supabase/` 0 | PASS |
| TP-B-06 | 범위 내 | implementation delta 에 `docs/` 변경 0 | PASS |
| TP-B-07 | 0건 | `601702`/`601705`/`601710`/`601713`/`601718`/`601719` 변경 0 | PASS |
| TP-B-08 | 2개 | 신규 migration 정확히 2 | PASS |

> **A-3~A-6 (Module 자기보고서 · Readme · `000005` · `000007`)는 implementation delta 에 없다.**
> `601722_Module_*` 파일은 아직 존재하지 않는다. **Stage 10 문서 동기화 소관이며 FAIL 사유로 두지 않는다.**

### §5.8 TP-M — Migration / Schema

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-M-01 | 2건 모두 5행 이내 | 둘 다 **1행** `-- Workpacket: 601700` | PASS |
| TP-M-02 | 0건 | G15 findings 2건 = `0168`/`0169`(workpacket 601500). **`0170`/`0171` 0건** | PASS |
| TP-M-03 | 0건 | `-StrictStage7` 에서도 `0170`/`0171` 0건 | PASS |
| TP-M-04 | 참 | `0170_` / `0171_`, 번호 재사용 없음 | PASS |
| TP-M-05 | 2행 `success=true` | 2행, 둘 다 `t` | PASS |
| TP-M-06 | `0170` → `0171` | 02:12:19 → 02:25:14 | PASS |
| TP-M-07 | 테이블 생성 → **M-1** → stores 컬럼·FK·인덱스 → **M-2** | 테이블 생성 → **stores 컬럼·FK·인덱스** → **M-1** → M-2 | **FAIL** — §6.1 |
| TP-M-08 | clean baseline replay 성공 | **[93] `0093_create_message_catalog_complete.sql` 에서 중단.** `0170`/`0171` 미도달 | **FAIL** — §6.3 |
| TP-M-09 | 0건 | 0 | PASS |
| TP-M-10 | 0건 | 0 | PASS |
| TP-M-11 | 0건 | 0 | PASS |

### §5.9 TP-X — External Provider negative (13건 전건 PASS)

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-X-01 | 0건 | provider mapping 테이블 0 | PASS |
| TP-X-02 | 0건 | provider 전용 컬럼 0 | PASS |
| TP-X-03 | 0건 | 0 | PASS |
| TP-X-04 | 정확히 1개 | `stores` 16 → 17, 증가분 `merchant_account_id` 1개 | PASS |
| TP-X-05 | 정확히 1건 | `merchant_accounts` | PASS |
| TP-X-06 | 대조 일치 | 5 → 7, 증가분 2건 모두 선언분 | PASS |
| TP-X-07 | 0건 | 벤더명 grep 0 | PASS |
| TP-X-08 | 0건 | 기존 5개 merchant 컬럼에 FK·unique 추가 0 | PASS |
| TP-X-09 | 0건 | `merchant_accounts` outgoing FK = `tenants` 1건뿐 | PASS |
| TP-X-10 | 원천 1개 | M-1 원천 = `catchmenu_hq.tenants` 하나 | PASS |
| TP-X-11 | 0건 | 해당 제약·주석 0 | PASS |
| TP-X-12 | 조항 존재 | `601717` §4.6 존재 | PASS |
| TP-X-13 | 0건 | 0 | PASS |

### §5.10 TP-RB — Rollback

> **저장소에 역방향 migration 산출물이 존재하지 않는다.**
> TP-RB-04·05 는 `601717` §9.1 R-2·R-3 에서 구성한 역방향 DDL 을 **disposable DB 에서만** 실행해 측정했다.
> 그 스크립트는 저장소 산출물이 아니며 raw log 15 에 전문이 있다.

| Test ID | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| TP-RB-01 | 가능 | 역방향 전 조작이 신규 migration 으로 표현 가능함을 실행으로 확인 | PASS |
| TP-RB-02 | 전제 없음 | §9.1 R-1 규정. `0170`/`0171` 미수정 | PASS |
| TP-RB-03 | 복원 (BL-26 제외) | disposable DB 는 19개 migration 실패로 canonical baseline 과 다름 | **SKIP(DISPOSABLE_BASELINE_NOT_FAITHFUL)** |
| TP-RB-04 | 복원 | rollback 후 `owners` RLS t/t, GRANT 4건 복원 | PASS (disposable 실측) |
| TP-RB-05 | 0행 복귀 | `merchant_accounts` 1행 DELETE 후 테이블 제거 | PASS (disposable 실측) |
| TP-RB-06 | 명시 | §9.1 **R-6** 존재 | PASS |
| TP-RB-07 | 참 | §9.1 R-2 규정 존재. 실행 순서도 `0171` 역 → `0170` 역 | PASS |
| TP-RB-08 | 불변 | `provision_tenant` md5 rollback 전후 동일. `create_franchise_store` 는 disposable baseline 자체가 canonical 과 상이 | **SKIP(DISPOSABLE_BASELINE_NOT_FAITHFUL)** |

### §5.11 AC — Acceptance Criteria

| Test ID | 기대값 | 실측 근거 | 판정 |
|---|---|---|---|
| AC-1 | PRE-1~PRE-8 충족 | PRE-1 승인 상태 확인. **PRE-3·5·6·7 은 pre-implementation 게이트라 post-hoc 관측 불가** | **SKIP(PRE_IMPLEMENTATION_GATE_NOT_OBSERVABLE_POST_HOC)** |
| AC-2 | §4 Positive 전부 PASS | TP-P-01~38 전건 PASS | PASS |
| AC-3 | §4.1 로 확정된 뒤 실행 | §4.1 Stage 7 확정값과 구현 일치 (§4.2) | PASS |
| AC-4 | TP-D-01~09 전부 PASS | 9/9 PASS | PASS |
| AC-5 | §5 Negative 전 항목 PASS | TP-N 65/65 PASS | PASS |
| AC-6 | §5.6 · §5.7 · §5.9 전부 PASS | 해당 전건 PASS | PASS |
| AC-7 | §6 Regression 전 항목 PASS | **TP-R-14 · TP-R-19 FAIL** | **FAIL (파생)** |
| AC-8 | §7 External negative 전 항목 PASS | TP-X 13/13 PASS | PASS |
| AC-9 | §8 Boundary · §9 Migration 전 항목 PASS | TP-B 8/8 PASS · **TP-M-07 · TP-M-08 FAIL** | **FAIL (파생)** |
| AC-10 | rollback 계획 문서 존재 + TP-RB-01·02·06·07 | §9.1 R-1~R-7 존재, 4개 항목 PASS | PASS |
| AC-11 | blocker 해소 또는 제외 명시 | §7.2·§7.3 disposition 전건 기재 | PASS |
| AC-12 | C-1·C-2·H-1~H-5 이월 명시 | `601716` §12.4 · `601717` §1.5·§4.4.3·§10.1 | PASS |
| AC-13 | 검증자가 원작자가 아님 | **§0 SPEC_CONFLICT** | **SKIP(SPEC_CONFLICT_AC13)** |
| AC-14 | I-47 을 검증 시점 상태로 판정 | TP-D-08 = 0 으로 판정 | PASS |
| AC-15 | `create_franchise_store` 실패를 결함으로 보지 않음 | TP-RT-08 을 SKIP 처리 | PASS |
| AC-16 | §4.1 확정 정의와 정확히 일치 | TP-P-26~31 · TP-N-21 · 60 · 61 전건 PASS | PASS |
| AC-17 | H-5 이월 명시 | `601717` §4.4.3 H-5 · §10.1 항목 5 | PASS |
| AC-18 | TP-M-08 을 clean baseline replay 로만 판정 | 동일 DB 재실행 미시도 | PASS |

> **AC-14 · AC-15 · AC-18 · TP-R-14/15 · C-1/C-2 · `stores.updated_at` — false FAIL 방지 규칙을 전부 적용했다.**
> C-1·C-2 의 `NOT NULL` 부재를 FAIL 로 적지 않았고, `stores.updated_at` 변경을 FAIL 로 적지 않았다.

## §6 관측 목록 — defect 를 확정하지 않는다

| # | 분류 | 지점 | `601716` 서술 | `601717` 서술 | 실제 구현 |
|---|---|---|---|---|---|
| O-1 | `SPEC_CONFLICT_OBSERVED` · `HUMAN_ADJUDICATION_NEEDED` | `0171` 내부 실행 순서 | TP-M-07 「`0171` 내부 순서가 **테이블 생성 → M-1 → stores 컬럼·FK·인덱스 → M-2**」 (근거: 참조 무결성) | §1.4 가 D-14…D-21 을 순서대로 열거하고 §4.5 가 M-1·M-2 를 그 뒤에 둔다. **M-1 을 D-18 앞에 두라는 조항은 없다** | D-14 → D-15 → D-16 → D-17 → **D-18·D-19·D-20** → D-21 → **M-1** → M-2 |
| O-2 | `SPEC_CONFLICT_OBSERVED` · `HUMAN_ADJUDICATION_NEEDED` | `stores` 트리거 총계 | BL-33 「before **241**(internal 240 / user 1) → after **241**」 · TP-R-19 「241」 | §1.4 **D-19** 가 `stores` 에 FK 추가를 허용한다 | **243** (internal 242 / user 1). 증가분 2건은 `RI_ConstraintTrigger_c_65977`·`_65978`, 소속 제약 `fk_stores_merchant_account_id` |
| O-3 | `EVIDENCE_GAP` | `stores` 참조 FUNCTION 수 | BL-22 「158 (`601701` 기록은 151)」 · TP-R-14 「before/after 모두 158」 | — | **151**. 4가지 측정법 전부 151 |
| O-4 | `EVIDENCE_GAP` | clean baseline replay | TP-M-08 「깨끗한 baseline DB 에서 `0000`…`0169` → `0170` → `0171` 전체 순차 재생 성공」 | — | **[93] `0093_create_message_catalog_complete.sql` 에서 중단.** `0170`·`0171` 에 도달하지 못함 |
| O-5 | `SPEC_CONFLICT_OBSERVED` · `HUMAN_ADJUDICATION_NEEDED` | Stage 9 검증자 자격 | AC-13 「검증자가 상위 문서 및 본 문서의 원작자가 아니다」 | — (`000701` §9 가 Stage 9 검증자로 Claude Code 지정) | Claude Code 가 `601710`/`601713`/`601716`/`601717` 원작자 |
| O-6 | `NOT_EXECUTED` | 앱 빌드·테스트 스위트 | TP-RT-04 「앱 빌드 / 테스트 스위트가 이전과 동일하게 통과」 | — | 미실행. implementation delta 에 `apps`/`packages`/`tests` 변경 0건 |
| O-7 | `NOT_EXECUTED` | `create_franchise_store` 런타임 | TP-RT-08 「실패 양상이 구현 전후로 동일」 | §6.1 FO-B·FO-B1 이 수정 금지 | 호출 금지 함수라 실행하지 않음. prosrc md5 불변·`extra_metadata` 부재는 정적 확인 |
| O-8 | `EVIDENCE_GAP` | rollback 기준선 | TP-RB-03 「기준선 before 값 복원 (BL-26 제외)」 · TP-RB-08 | §9.1 R-1 이 역방향 신규 migration 을 요구 | 저장소에 역방향 산출물 없음. disposable DB 는 19개 migration 실패로 canonical baseline 과 상이 |

**`IMPLEMENTATION_DEVIATION_OBSERVED` — 0건.**
계약 §1.3·§1.4·§1.6·§4.5·§5·§6 대비 `0170`·`0171` 의 기계적 불일치는 관측되지 않았다.

### §6.1 O-1 — TP-M-07 상세

**Stage 9 가 기록하는 것은 여기까지다.**

```text
601716 이 요구한다     테이블 생성 → M-1 → stores 컬럼·FK·인덱스 → M-2
601717 이 허용한다     §1.4 D-14…D-21  →  §4.5 M-1 · M-2  (번호 순서)
0171 이 수행했다       D-14…D-21  →  M-1  →  M-2
```

**「그러므로 어느 쪽이 결함인가」는 이 문서가 판단하지 않는다.**
`TP-M-07` 은 이 워크패킷 원작자(Claude Code)가 쓴 두 문서 사이의 충돌이며,
여기서 한쪽을 고르면 Stage 9 역할을 넘는다.

> 참조 무결성은 두 순서 모두에서 성립함을 실행으로 확인했다 —
> `0171` 은 canonical DB 와 disposable DB 양쪽에서 오류 없이 적용됐다.

### §6.2 O-2 · O-3 상세

**O-2 — 산술적으로 양립 불가능하다**

```text
D-19 를 실행하면            stores 에 FK RI 트리거 2건이 생긴다
BL-33 / TP-R-19 기대값       241 (증가 없음)
실측                        243
```

증가분 2건의 소속 제약이 `fk_stores_merchant_account_id` 임을
`pg_trigger` ↔ `pg_constraint` 조인으로 특정했다(raw log 11).
**user-visible 트리거는 여전히 정확히 1건**(`trg_stores_updated_at`)이므로
TP-R-19 근거란의 「backfill 중 트리거 우회·비활성화 금지」 취지 자체는 충족된다.

**O-3 — 158 을 어떤 방법으로도 재현하지 못했다**

| 측정법 | 결과 |
|---|---:|
| `prosrc ILIKE '%catchmenu_hq.stores%'`, `catchmenu%` 스키마 | 151 |
| 동일 조건, 전 스키마 | 151 |
| `prosrc` 정규식 word-boundary `stores` | 151 |
| `pg_depend` → `pg_proc` | 0 |

`0170`·`0171` 은 `CREATE OR REPLACE FUNCTION` 0건이므로 **모집단이 이 구현으로 증감할 수 없다.**
TP-R-14 의 실질 기준(모집단 증감 없음 · 본문 불변)은 충족되나,
**문면에 적힌 기대값 158 과 실측 151 이 다르므로 PASS 로 적지 않았다.**
151 vs 158 은 `601702` §2.2 가 이미 미결로 등재한 항목이다.

### §6.3 O-4 상세 — TP-M-08

**disposable 환경은 생성됐다.** 따라서 `SKIP(NO_DISPOSABLE_REPLAY_ENV)` 가 아니다.

```text
컨테이너   wp601700_replay_verify  (public.ecr.aws/supabase/postgres:17.6.1.140)
절차       sql/migrations/*.sql 을 파일명 순서로 psql -v ON_ERROR_STOP=1 적용
결과       [93] 0093_create_message_catalog_complete.sql 에서 중단

ERROR: new row for relation "error_codes" violates check constraint "chk_error_domain"
DETAIL: Failing row contains (5001, category_not_found, MENU, ...)
```

**원인은 이 워크패킷 밖에 있다** — 실측으로 특정했다.

| DB | `chk_error_domain` 허용 도메인 수 | `MENU` 포함 |
|---|---:|---|
| canonical | 23 | 예 |
| clean replay (0093 시점) | 18 | **아니오** |

canonical 은 `0093` 을 `success=true` 로 기록하고 있다(2026-07-09).
**즉 clean baseline replay 자체가 현재 저장소 상태에서 성립하지 않으며, `0170`·`0171` 과 무관하다.**

**보충 실행 — TP-M-08 이 아니다**

실패 허용 모드로 계속 적용한 결과 19개 파일이 실패했고(전부 `0093`~`0135` 구간),
**`0170`·`0171` 은 둘 다 `rc=0` 으로 적용됐다.**
적용 후 disposable DB 상태: `persons` 1 · `merchant_accounts` 1 · `owners` 0 · `stores.merchant_account_id` 1.

> **이 보충 결과를 TP-M-08 의 PASS 로 적지 않는다.** 절차가 다르다.
> 다만 「`0170`·`0171` 이 from-scratch 베이스라인에서 적용 가능한가」에 대한 증거는 된다.

## §7 canonical DB 무결성 — 검증 전후 대조

| 항목 | 검증 전 | 검증 후 |
|---|---|---|
| `default_transaction_read_only` | on | on |
| `merchant_accounts` 행 | 1 | 1 |
| `migration_history` 행 | 171 | 171 |
| `catchmenu_hq` BASE TABLE | 21 | 21 |

**canonical DB 에 write 0회. 금지 함수 호출 0회. git write 명령 0회.**
disposable 컨테이너는 검증 종료 후 `docker rm -f` 로 제거했다.

## §8 SKIP 목록 — PASS 로 추정하지 않았다

| Test ID | 사유 | Stage 9 후속에서 수행 가능한가 |
|---|---|---|
| AC-1 | `PRE_IMPLEMENTATION_GATE_NOT_OBSERVABLE_POST_HOC` | 아니오 — 시점이 지났다. Stage 8 착수 기록으로만 확인 가능 |
| AC-13 | `SPEC_CONFLICT_AC13` | 아니오 — Human adjudication 필요 |
| TP-RT-04 | `NOT_EXECUTED` — 앱 빌드·테스트 스위트 미실행 | **예** |
| TP-RT-08 | `FORBIDDEN_FUNCTION_CALL` | 아니오 — 금지 함수. 후속 RPC alignment 나선 소관 |
| TP-RB-03 | `DISPOSABLE_BASELINE_NOT_FAITHFUL` | 예 — 역방향 migration 산출물과 충실한 baseline 이 생기면 |
| TP-RB-08 | `DISPOSABLE_BASELINE_NOT_FAITHFUL` | 동상 |

## §9 실행 명령 전문 — 재현 가능

```bash
# --- 판본 고정 (본문 §1) ---
git ls-files --eol <4 files>
sha256sum  docs/.../601716_TestPlan_...md
git show HEAD:docs/.../601716_TestPlan_...md | sha256sum
git log -1 --format="%H" -- docs/.../601717_ChangeContract_...md
git log -1 --format="%H %s" -- sql/migrations/0170_person_vocabulary_normalization.sql
git log -1 --format="%H %s" -- sql/migrations/0171_merchant_account_foundation.sql

# --- 01 ~ 04 : implementation delta ---
git log  --oneline   df49eb56..bc4cd14d
git diff --stat      df49eb56..bc4cd14d      > 01_git_diff_stat.txt
git diff --check     df49eb56..bc4cd14d      > 02_git_diff_check.txt
git diff --name-only df49eb56..bc4cd14d      > 03_git_diff_name_only.txt
git diff             df49eb56..bc4cd14d      > 04_git_diff.patch

# --- 05 ~ 06 : governance ---
powershell -NoProfile -ExecutionPolicy Bypass -File tools\Check-Governance.ps1               > 05_governance_check.log
powershell -NoProfile -ExecutionPolicy Bypass -File tools\Check-Governance.ps1 -StrictStage7 > 06_governance_strict.log

# --- 07 ~ 13 : canonical DB, 강제 read-only ---
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i \
  supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres < <query.sql>
#   q07/q07b/q07c -> 07_db_baseline.log        (BL-*)
#   q08/q08b      -> 08_schema_positive.log    (TP-P-01..38)
#   q09           -> 09_negative_checks.log    (TP-N-*, TP-X-*)
#   q10           -> 10_backfill_checks.log    (TP-D-*, TP-R-04..17)
#   q22/q33/q11   -> 11_regression.log         (BL-22 4변형, 트리거 귀속, TP-R-*)
#   (07c 발췌)    -> 12_migration_history.log  (TP-M-05/06, TP-R-16)
#   (07c/09 발췌) -> 13_rls_security.log       (RLS/GRANT posture)

# --- 14 : clean baseline replay (disposable) ---
docker run -d --name wp601700_replay_verify -e POSTGRES_PASSWORD=verify -e POSTGRES_DB=postgres \
  public.ecr.aws/supabase/postgres:17.6.1.140
for f in $(ls sql/migrations/*.sql | sort); do
  docker exec -i wp601700_replay_verify psql -v ON_ERROR_STOP=1 -U postgres -d postgres < "$f" || break
done                                            > 14_replay.log

# --- 15 : rollback (disposable only) ---
docker exec -i wp601700_replay_verify psql -v ON_ERROR_STOP=1 -U postgres -d postgres < rollback.sql
                                                > 15_rollback.log
docker rm -f wp601700_replay_verify
```

## §10 raw evidence 목록

```text
docs/implementation_evidence/601700/raw_logs/
  01_git_diff_stat.txt        02_git_diff_check.txt      03_git_diff_name_only.txt
  04_git_diff.patch           05_governance_check.log    06_governance_strict.log
  07_db_baseline.log          08_schema_positive.log     09_negative_checks.log
  10_backfill_checks.log      11_regression.log          12_migration_history.log
  13_rls_security.log         14_replay.log              15_rollback.log
```

**Markdown 에 복사한 것으로 raw log 를 대체하지 않았다.** 위 15개 파일이 1차 증거다.

## §11 `601739` 대조 — 독립 판정 종료 후 수행

**절차**: `601716`/`601717` 직접 통독 → `0170`/`0171` 직접 통독 → live DB 실측 → commit 확인 →
전건 판정 완료 → **그 다음에** `601739` 열람.

| 항목 | 내 결과 | `601739` 결과 | 일치 |
|---|---|---|---|
| TP-M-07 | FAIL — SPEC_CONFLICT | FAIL — 동일 지점, 동일 사실 관계 | **일치** |
| AC-9 파생 FAIL | FAIL | FAIL (파생) | **일치** |
| 판본·EOL | 전건 일치 | 전건 PASS | **일치** |
| TP-B 8건 | 8/8 PASS | 8/8 PASS | **일치** |
| TP-M 문서 검사분 (01·04·09·10·11) | PASS | PASS | **일치** |
| TP-M-02 · TP-M-03 | PASS (PowerShell 실행) | SKIP(NO_POWERSHELL) | 불일치 — 환경 차이 |
| DB 계열 195건 | 실측 수행 | SKIP(NO_DB_ACCESS) | 불일치 — 환경 차이 |
| TP-M-08 | **FAIL** (replay 수행, 0093 중단) | SKIP | 불일치 — 환경 차이 |
| BL-22 / TP-R-14 | **FAIL** (151 실측) | SKIP. §9 에서 「함수 158」을 Stage 9 확인 대상으로 지목 | 불일치 |
| BL-33 / TP-R-19 | **FAIL** (243 실측) | SKIP | 불일치 |
| AC-13 | **SKIP(SPEC_CONFLICT)** | **PASS** | 불일치 |

**무엇이 다른지와 그 근거**

```text
환경 차이 (TP-M-02/03 · DB 195건 · TP-M-08)
  601739 는 DB·PowerShell 도달 불가 환경에서 file-scope 만 수행했다(§0.3).
  이번 실행은 두 접근이 모두 가능했으므로 SKIP 이 실측으로 대체됐다.

BL-22 / BL-33 (601739 SKIP -> 내 FAIL)
  DB 실측이 필요한 항목이므로 601739 가 판정할 수 없었다.
  601739 §9 는 이 둘을 Stage 9 에서 수행할 대상으로 명시했고, 수행 결과가 위 FAIL 이다.

AC-13 (601739 PASS -> 내 SKIP)
  601739 §0.1 은 「Cowork 이 원작자가 아니다」를 근거로 PASS 했다.
  그러나 Cowork 은 000701 §9.16 이 정의한 Stage 9 actor 가 아니다(601739 §0 자인).
  Stage 9 정규 actor 인 Claude Code 에 대해서는 AC-13 literal 이 성립하지 않는다.
  어느 쪽이 옳은지는 이 문서가 결정하지 않는다 — HUMAN_ADJUDICATION_NEEDED.
```

**두 pass 가 독립적으로 도달한 공통 결론**: TP-M-07 SPEC_CONFLICT.

## §12 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 역할 |
|---|---|---|
| `601716_TestPlan_…V2.md` | 승인판 전문 (§0~§15) | 검사 기준. Test ID inventory 원본 |
| `601717_ChangeContract_…V2.md` | §1 · §4 · §5 · §6 · §9 · §10.7~§10.11 | 허용·금지·판본 고정·rollback policy |
| `sql/migrations/0170_…sql` · `0171_…sql` | 전문 | 검증 대상 |
| `000701_…Pipeline.md` | §9 · §9.16 · §9.20 · §10 · §37 · §46 | Stage 9 규격 · actor · 원작자 배제 |
| `601702` §2.2 | 151 vs 158 미결 등재 | O-3 배경 |
| `601505` §4 | 호출 금지 함수 7건 | 안전 제약 |
| `601739_Evidence_Stage8_Supplemental_FileScope_Pass_Cowork.md` | §0 · §3 · §7 · §8 · §9 | **비구속 supplemental.** §11 대조에서만 사용 |
| `tools/Check-Governance.ps1` | G15 | TP-M-02 · TP-M-03 |

---

> **이 문서는 Stage 9 를 종료시키지 않는다.**
>
> ```text
> TestPlan 결과      TESTPLAN FAILURES FOUND      (FAIL 8)
>                    TESTPLAN NOT FULLY EXECUTED  (SKIP 6)
> Stage 9 상태        INCOMPLETE
> 구현 기계적 준수     IMPLEMENTATION_DEVIATION_OBSERVED = 0
> ```
>
> **FAIL 8건 중 `0170`·`0171` 의 계약 위반에서 비롯된 것은 0건이다.**
> 4건은 TestPlan ↔ ChangeContract 충돌(O-1·O-2)과 그 파생(AC-7·AC-9),
> 2건은 재현 불가·도달 불가(O-3·O-4)에서 왔다.
>
> **어느 문서가 우선하는지는 Stage 11 / Human 이 결정한다.**
