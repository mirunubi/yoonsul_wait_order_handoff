# 601507_Verification_Operational_Authority_Foundation_Ddl.md

Status: Draft
Lifecycle: Verification
Stage: 10 (Documentation — Claude Code "중요 문서", `000701` §3 L181–185 / 역할표 L92)
Domain: Operational Authority Foundation (0단계 / 하위 나선 0-A)
Last Updated: 2026-08-10

## Change ID

`operational_authority_foundation_ddl`

## §0 이 문서의 위치

`000701` §3의 Stage 10 정의상 **Claude Code가 생산하는 "중요 문서"** 다.
Stage 9의 raw 산출물(`601506`)과 **역할이 다르다**:

| 문서 | 단계 | 성격 |
|---|---|---|
| `601506_Verification_...` | Stage 9 | 두 독립 검증자(Cursor / Claude Code)의 **raw 결과 원문 수록** |
| **`601507`(본 문서)** | **Stage 10** | raw 결과를 **정리한 검증 기록** — Stage 11 감사자와 후속 독자가 사용하는 형태 |

본 문서는 **판정 권한이 없다.** ACCEPT/REJECT는 Stage 11(Claude 단독, `000701` §3 L187–191)의 권한이다.

## §1 검증 대상

| 항목 | 값 |
|---|---|
| 구현 커밋 | `33251448` |
| 변경 규모 | **1 file changed, 264 insertions(+)** — `sql/migrations/0168_create_operational_authority_foundation.sql` 단독 |
| 적용 환경 | 로컬 `supabase_db_yoonsul_wait_order_handoff`, **PostgreSQL 17.6** |
| `migration_history` | `success = t`, `applied_by = postgres`, `applied_at = 2026-08-09 15:35:39+00` |
| 파일 무결성 | 기록 checksum `263615fd…f194` == 현재 파일 `sha256` — **적용 후 파일 변조 없음** |

## §2 검증자 구성 (§37 준수)

| 검증자 | 참여 | 근거 |
|---|---|---|
| **Codex** | **제외** | §37 — 구현자는 자기 구현의 검증자가 될 수 없음 |
| Cursor | 참여 | Critical tier |
| Claude Code | 참여 | `000701` 역할표 L92 — Stage 9 담당 |

두 검증자가 **각각 독립적으로** 라이브 DB를 조회했고, raw 결과는 `601506`에 원문 수록됐다.

## §3 검증 결과 요약

### §3.1 설계 대조 (0168 ↔ `601501`/`601503`)

라이브 DB에서 역추출한 실제 스키마가 의사 DDL과 **전 항목 일치**.

| 확인 축 | 결과 |
|---|---|
| 신규 4테이블 존재·소유자 | 4/4 존재, `tableowner = postgres` |
| `legal_entities` 11컬럼 | 타입/nullable/default 일치 |
| 생성컬럼 2개 | `is_generated = ALWAYS`, 표현식에 **`NULLIF`+`regexp_replace`+`COALESCE` 모두 포함** |
| 신규 3컬럼 | `tenant_status`(NN, `'TRIAL'`) / `isolation_state`(NN, `'NONE'`) / `stores.legal_entity_id`(**nullable**) |
| CHECK 10 + FK 1 | `pg_get_constraintdef` 원문 **11건 전부 일치** |
| 부분 인덱스 5개 | 술어(`WHERE`) 전부 일치 |
| 컬럼·테이블 델타 | tenants 8→**10**, stores 15→**16**, `catchmenu_hq` 16→**20** — **초과 생성 0건** |

### §3.2 계약 준수 (`601505` Forbidden)

| 금지 조항 | 검증 방법 | 결과 |
|---|---|---|
| 기존 RPC 수정 | 구현 커밋 파일 목록 | 0168 단독 — **위반 없음** |
| 추적 `.sql` 변경 | `git status --porcelain -- '*.sql'` | **0건** |
| `franchise_brands` / `config.toml` | git diff | **변경 없음** |
| tenant `ACTIVE` 승격 (§4.3) | `count(*) where tenant_status='ACTIVE'` | **0** |
| GRANT 부여 (§2.1) | `grantee <> 'postgres'` 필터 | 신규 4테이블 **0건**, `catchmenu_hq` 전체 **0건** |
| RLS 정책 생성 (§2.2) | `pg_policies` | **0개** (enable/force는 4/4 `t`) |
| 시드 실투입 | 신규 4테이블 행수 | **전부 0행** |

### §3.3 TestPlan 핵심 5항목 (Stage 9에서 **재현 실행**)

Codex의 Stage 8 보고를 신뢰하지 않고 검증자가 직접 실행했다.

| # | 항목 | 결과 (raw) |
|---|---|---|
| 1 | **§3.3 `service_role` 리트머스** | `rolbypassrls = t`이나 `catchmenu_hq` USAGE 없음 → **`ERROR: permission denied for schema catchmenu_hq`**. `authenticated`는 USAGE는 있으나 → **`permission denied for table`**(4테이블 전부) |
| 2 | **§4.2 `SECURITY DEFINER` 경유** | `authenticated`로 전환한 상태에서 임시 SECDEF 함수 호출 → **`0` 정상 반환** (1번과 정면 대비) |
| 3 | **§5.1(3) `nullif` 검증** | BRN `NULL` **3건 동시 INSERT 성공**. 표기 다른 동일번호(`123-45-67890` vs `1234567890`)는 `uq_legal_entities_brn_normalized` **충돌**. CRN도 동일 |
| 4 | **§6.2 직교 조합** | `TRIAL+ISOLATED` / `ACTIVE+ISOLATED` / `SUSPENDED+ISOLATED` / `TERMINATED+NONE` **4/4 성립**. 축 혼입은 각각 CHECK 위반으로 거부 |
| 5 | **§8.1 멱등성** | 0168 전문 재실행(`BEGIN … ROLLBACK`) **exit 0, 오류 0건**. 제약 3종 각 1건, 트리거 4종 각 1건 — 중복 생성 없음 |

**1번의 의미**: `service_role`은 `BYPASSRLS`를 가지므로 **RLS만으로는 원리적으로 막을 수 없다.**
그럼에도 차단됐다는 것은 실제 차단자가 **GRANT/스키마 USAGE 계층**임을 실증한다 —
`601501` §2.7.1의 (v3에서 정정된) 서술이 라이브에서 확인된 것이다.

### §3.4 기존 데이터 및 부작용

| 확인 | 결과 |
|---|---|
| `tenants` | 1행 `YOONSUL_TEST` — 기존 컬럼 값 전부 보존, 신규 2컬럼은 default(`TRIAL`/`NONE`) |
| `stores` | 1행 `ULSAN_01` 윤슬 울산 1호점 — `legal_entity_id` **NULL**(백필 0건) |
| `cron.job` | **0행** — Baseline과 동일 |
| `pg_cron_jobs` | **47 / `is_registered=true` 38** — Baseline과 동일, 부작용 없음 |

### §3.5 DB 쓰기 통제

검증 중 사용한 모든 INSERT/UPDATE는 **트랜잭션 내부에서만 실행되고 ROLLBACK**됐다.
최종 확인: `legal_entities` **0행**, `tenants` 상태 `TRIAL/NONE` 원상 — 잔존 데이터 없음.

## §4 Stage 9 종합 판정

**차단 우려사항 없음 (No blocking concerns).**

단, 아래 관찰사항 3건은 판정과 별개로 기록되며 **Stage 11 감사자가 반드시 읽어야 한다**.

## §5 관찰사항 (결함 아님 — Stage 11 인계)

### §5.1 적용 순서 편차 — 무해

`601503` §3은 "5. tenants 컬럼+CHECK → 6. stores 컬럼+FK"의 교차 배치를 규정했으나,
0168은 **ADD COLUMN 3개를 먼저 모으고 제약 3개를 단일 `DO` 블록**(L160–204)에 배치했다.
기능적으로 동일하며 §49.2 취지(ADD COLUMN 선행)에는 오히려 더 부합한다. **반려 사유 아님.**

### §5.2 사후 검증의 구조적 한계 — 명시

DDL이 **이미 적용된 상태**에서 검증했으므로, `601504` §1 pre-flight의 **적용 전 상태**
(tenants 8컬럼, `catchmenu_hq` 16테이블, GRANT baseline)는 검증자가 직접 목격할 수 없었다.
대신 **적용 후 상태가 baseline+델타와 정확히 일치**(10/16/20, 초과 0건)함을 확인했다 —
강한 간접 증거이나 pre-flight 목격과 동일하지 않다.

> 이 한계를 감추지 않고 기록하는 이유: Stage 11은 "액면 그대로 신뢰하지 않고 핵심 주장 재도출"을
> 요구한다(`000701` §3 L189). 검증의 경계를 숨기면 그 재도출이 불가능해진다.

### §5.3 "금지 7함수 호출 없음"의 증명 한계

실패한 호출은 흔적을 남기지 않으므로 **"호출된 적 없음"을 직접 증명할 수는 없다.**
다만 관측 가능한 모든 지표가 일관되게 이를 가리킨다:
(a) `tenant_status='ACTIVE'` 0건, (b) 데이터 무변경, (c) 신규 호출자 추가 0건(커밋 1파일),
(d) 7함수 전부 42703/42883 방벽으로 도달 불가.

## §6 검증 범위 한정

**로컬 DB 한정.** 클라우드 환경은 검증되지 않았다 —
Open Item **(m)**(클라우드 `pg_cron` 상태 / `pg_cron_jobs` 카탈로그 값 / PostgreSQL 버전)은
**여전히 미해결**이며 Stage 12 병합 판단에서 별도로 다뤄야 한다.

## §7 근거 문서 목록 (§46)

| 문서 | 역할 |
|---|---|
| `000701` §3(L181–191 Stage 10/11 정의, L92 역할표), §13.7–§13.8(Dual Anchor / Stage 11B), §37, §46, §48, §49.2 | 단계 정의·검증자 배제 규칙·증거 기준 |
| `000001_Md_Rules.md` §5.4.1–§5.4.3 | Verification 문서 규격 |
| `601501_ERD...md` (v4) | 설계 원본 — §3.1 대조 기준 |
| `601502`/`601503` (v4) | 범위 절단·의사 DDL |
| `601504_TestPlan...md` | §3.3 핵심 5항목 정의 |
| `601505_ChangeContract...md` | §3.2 Forbidden 목록 |
| `601506_Verification...md` | **Stage 9 raw 결과 원문** — 본 문서의 1차 출처 |
| `sql/migrations/0168_...sql` | 검증 대상 구현 |
| 커밋 `33251448` | raw diff |

## Module Domain Tags

`hq`, `tenant`, `store`, `legal_entity`, `owner`, `representative`, `rls`, `grant`, `ddl`, `verification`
