# 601506 Stage 9 독립 검증 결과 — Operational Authority Foundation DDL

- 대상 워크패킷: `601500_operational_authority_foundation`
- 대상 구현: `33251448` / `0168_create_operational_authority_foundation.sql`
- 단계: Stage 9 (Independent Verification)
- 독립 검증자: Cursor, Claude Code
- 종합 판정: **차단 우려사항 없음**
- 검증 환경 한정: 로컬 DB. 클라우드 환경은 Open Item (m)으로 Stage 12에 이월.

아래에는 두 독립 검증자가 제출한 raw 결과를 원문 그대로 수록한다.

---

## 1. Cursor raw 결과

Stage 9 독립 검증 — Raw 결과
검증 일시: live local DB (supabase_db_yoonsul_wait_order_handoff)
대상: 33251448 (0168_create_operational_authority_foundation.sql)
DB 쓰기: §6.2 검증용 UPDATE만 사용, ROLLBACK 확인됨. 그 외 INSERT/UPDATE/DELETE 없음.

### 1. 0168 DDL ↔ 601501/601503 의사DDL 일치

판정: 일치 (우려사항 없음)

| 영역 | Live | 601501/601503 |
|---|---|---|
| 신규 4테이블 | 존재 (owners, legal_entities, legal_entity_person_roles, legal_entity_representatives) | ✓ |
| tenants +2 | tenant_status NOT NULL DEFAULT 'TRIAL', isolation_state NOT NULL DEFAULT 'NONE' | ✓ |
| stores +1 | legal_entity_id uuid NULL | ✓ |
| CHECK | chk_tenants_status, chk_tenants_isolation_state, fk_stores_legal_entity_id 각 1건 | ✓ |
| 생성컬럼 | brn_normalized/crn_normalized — nullif+regexp_replace+coalesce | ✓ |
| 부분 UNIQUE | uq_legal_entities_brn/crn, uq_lepr_active, uq_ler_active WHERE 절 | ✓ |
| ownership_percent | numeric(5,2) | ✓ |
| representation_mode | SOLE/JOINT/INDIVIDUAL (NONE 없음) | ✓ |
| RLS | 4테이블 enable+force, policy_count=0 | ✓ §2.7.2 |
| uq_stores_tenant_code | UNIQUE (tenant_id, store_code) 변경 없음 | ✓ |
| catchmenu_hq 테이블 수 | 20 (기존 16 + 신규 4) | ✓ §6.1 기대 |

적용 순서: legal_entities → owners → lepr → ler → tenants/stores 컬럼 → DO 가드 제약 → RLS → trigger → comment (601503 §4.1과 동일).
601502(Overview) 정합: DDL-only, RPC/시드/GRANT/정책 없음 — 준수.

### 2. 601505 Forbidden / git diff

판정: 위반 없음

git diff 33251448^..33251448 --name-only:
sql/migrations/0168_create_operational_authority_foundation.sql

단일 파일만 변경.

| Forbidden | 확인 |
|---|---|
| 기존 RPC 수정 (0082/0090/0112/0120/0121/0123/0129/0130/0131) | diff 0 |
| franchise_brands/0085 수정 | diff 0 |
| supabase/config.toml 수정 | diff 0 (schemas = ["public","graphql_public"] 유지) |
| CREATE OR REPLACE FUNCTION | 0168 내 없음 |
| 신규 4테이블 GRANT | 0168 내 없음 |
| RLS policy 생성 | 0168 내 없음 (enable/force만) |
| tenant ACTIVE 승격(영구) | §6.1: ACTIVE tenant 0건 |

### 3. TestPlan 핵심 3항목 — 독립 재실행

#### §3 service_role 리트머스 (deny-by-default)

§3.2 authenticated

ERROR: permission denied for table legal_entities
HINT: GRANT SELECT ON catchmenu_hq.legal_entities TO authenticated
(owners도 동일 42501)

§3.3 service_role

ERROR: permission denied for schema catchmenu_hq

판정: PASS — RLS가 아니라 GRANT/USAGE 계층에서 차단 (601501 §2.7.1 주장과 일치).

#### §6 tenant_status / isolation_state 직교

§6.1 (현재 persisted 상태)

YOONSUL_TEST | tenant_status=TRIAL | isolation_state=NONE
ACTIVE tenant count = 0

§6.2 (트랜잭션 내 5조합 → ROLLBACK)

| test | tenant_status | isolation_state | 결과 |
|---|---|---|---|
| combo1 | TRIAL | ISOLATED | OK |
| combo2 | ACTIVE | ISOLATED | OK |
| combo3 | SUSPENDED | ISOLATED | OK |
| combo4 | CANCELLED | NONE | OK |
| combo5 | TERMINATED | NONE | OK |

ROLLBACK 후:

YOONSUL_TEST | TRIAL | NONE   ← 원복 확인

판정: PASS — TRIAL+ISOLATED 등 직교 조합 표현 가능, 영구 데이터 변경 없음.

#### §8 멱등성

0168 2회째 실행 (pipe via docker exec -i):

NOTICE: ... already exists, skipping — table/column/index
DO 블록 제약 가드 — 에러 없음
trigger DROP IF EXISTS → CREATE — 정상(0168 설계대로)

제약 중복 검증:

chk_tenants_status          → 1
chk_tenants_isolation_state → 1
fk_stores_legal_entity_id   → 1

판정: PASS

### 4. 신규 4테이블 GRANT (grantee <> 'postgres')

SELECT ... AND grantee <> 'postgres';
→ 0 rows

판정: PASS (§3.1 / §2.1 설계결정 준수)

### 5. 기존 seed 데이터 불변

| 객체 | count | 내용 |
|---|---:|---|
| catchmenu_hq.tenants | 1 | 000...0001 / YOONSUL_TEST / 윤슬 테스트 브랜드 / TRIAL / NONE |
| catchmenu_hq.stores | 1 | 000...0002 / ULSAN_01 / 윤슬 울산 1호점 / ACTIVE / legal_entity_id=NULL |
| 신규 4테이블 row | 0 each | — |

판정: PASS — tenant/store 식별값·핵심 필드 변경 없음.

### 우려사항 목록

명시적 우려사항 없음 (601505 Forbidden / 601501·601503 DDL / 핵심 TestPlan 재검증 기준)

### 참고 메모 (결함 아님)

1. 0168 재실행 시 trigger drop/create — 멱등성 설계(`drop trigger if exists`)에 따른 정상 동작; 데이터/기존 객체에는 영향 없음.
2. §6.2에서 트랜잭션 내 `ACTIVE+ISOLATED` 조합 검증 — ROLLBACK으로 persisted state는 `TRIAL+NONE` 유지(§4.3 준수).
3. Codex §1–§9 PASS — 본 독립 검증에서 §3/§6/§8 및 DDL/Forbidden/GRANT/seed 핵심 항목을 직접 재실행해 교차 확인; 불일치 없음.

Stage 9 종합 판정: 0168 구현은 601501/601503/601505와 정합하며, Codex TestPlan 핵심 항목을 독립 재현 PASS.

---

## 2. Claude Code raw 결과

Stage 9 독립검증 결과 — 601500 / 0168

판정: 우려사항 없음 (No blocking concerns) — 관찰사항 3건은 아래 §4에 별도 기록.

### 1. 설계 대조 (0168 ↔ 601501/601503)

라이브 DB에서 역추출한 실제 스키마가 의사DDL과 전 항목 일치.

| 대상 | 확인 | 결과 |
|---|---|---|
| 신규 4테이블 | 존재·소유자 | 전부 존재, tableowner = postgres |
| legal_entities 11컬럼 | 타입/nullable/default/생성컬럼 | 일치 |
| brn_normalized/crn_normalized | is_generated | ALWAYS, 표현식에 NULLIF(regexp_replace(COALESCE(...))) 확인 |
| 신규 3컬럼 | tenant_status NN default 'TRIAL' / isolation_state NN default 'NONE' / stores.legal_entity_id uuid nullable | 일치 |
| CHECK 8 + FK 1 + tenants CHECK 2 | pg_get_constraintdef 원문 | 11건 전부 일치 |
| 부분 인덱스 | 술어(WHERE) | brn_normalized IS NOT NULL / crn_normalized IS NOT NULL / is_active = true×2 / legal_entity_id IS NOT NULL — 전부 일치 |
| 컬럼·테이블 델타 | 기대 8+2 / 15+1 / 16+4 | 10 / 16 / 20 — 초과 생성 0건 |
| 파일 무결성 | migration_history checksum vs 파일 sha256 | 263615fd…f194 일치(적용 후 파일 변조 없음), success=t |

### 2. ChangeContract Forbidden 준수

| 금지 | 검증 방법 | 결과 |
|---|---|---|
| 기존 RPC 수정 | 구현 커밋 33251448 범위 | 1 file changed, 264 insertions — 0168 단독 |
| 임의 파일 수정 | git status --porcelain -- '*.sql' | 추적 .sql 변경 0건(untracked .tmp_*만) |
| franchise_brands / config.toml | git diff | 변경 없음 |
| tenant ACTIVE 승격 | count(*) where tenant_status='ACTIVE' | 0 |
| GRANT 부여 | grantee <> 'postgres' 필터 | 신규 4테이블 0건, catchmenu_hq 전체 0건 |
| RLS 정책 생성 | pg_policies | 0개 (enable/force는 4테이블 전부 t) |
| 시드 실투입 | 신규 4테이블 행수 | 전부 0행 |

### 3. 핵심 5항목 직접 재현 (Codex 보고 미신뢰, 전부 자체 실행)

#### ① §3 리트머스 — 차단 계층 실증 (가장 결정적)

| 역할 | rolbypassrls | catchmenu_hq USAGE | SELECT 결과 |
|---|---|---|---|
| service_role | t | f | ERROR: permission denied for schema catchmenu_hq |
| authenticated | f | t | ERROR: permission denied for table legal_entities (4테이블 전부) |
| anon | f | f | permission denied for schema |

service_role은 RLS를 우회할 수 있음에도 스키마 단계에서 차단됐습니다. 차단자가 RLS가 아니라 GRANT/USAGE라는 601501 §2.7.1이 실증됐습니다.

#### ② §4 대조군 — SECURITY DEFINER 경유

authenticated로 전환한 상태에서 임시 SECURITY DEFINER 함수 호출 → 0 정상 반환. ①에서 같은 역할이 거부된 것과 대비되어, Open Item (o) 전제(소유자 postgres)가 실제로 성립함을 확인.

#### ③ §6 직교조합

4개 조합 전부 성립 후 ROLLBACK: TRIAL+ISOLATED / ACTIVE+ISOLATED / SUSPENDED+ISOLATED / TERMINATED+NONE. 축 혼입은 거부: tenant_status='ISOLATED' → chk_tenants_status 위반, isolation_state='SUSPENDED' → chk_tenants_isolation_state 위반.

#### ④ §5.1(3) 정규화 (nullif 핵심)

123-45-67890 vs 1234567890 → uq_legal_entities_brn_normalized 충돌 ✓ / BRN NULL 3건 동시 INSERT 성공 ✓ / CRN도 동일 동작 ✓ / 개인사업자 CRN → chk_legal_entities_crn_not_for_sole 거부 ✓ / raw ' 123-45-67890 ' 보존 + brn_normalized='1234567890' ✓

#### ⑤ §8 멱등성

0168 전문 재실행(BEGIN … ROLLBACK) exit code 0, 오류 0건. 롤백 후 제약 3종 각 1건, 트리거 4종 각 1건, 신규테이블 인덱스 11개 — 중복 생성 없음.

### 4. 기존 데이터 및 부작용

- tenants 1행 (YOONSUL_TEST, BRAND, PRO, is_active=t) → TRIAL/NONE, 기존 컬럼 값 전부 보존
- stores 1행 (ULSAN_01, 윤슬 울산 1호점) → legal_entity_id NULL(백필 0건)
- cron.job 0행, pg_cron_jobs 47/38 — Baseline과 완전 동일, 부작용 없음

### 관찰사항 3건 (결함 아님, 기록용)

#### (1) 적용 순서 편차 — 무해

601503 §3은 "5. tenants 컬럼+CHECK → 6. stores 컬럼+FK"로 교차 배치를 규정했으나, 0168은 ADD COLUMN 3개를 먼저 모으고 제약 3개를 단일 DO 블록(L160–204)에 넣었습니다. 기능적으로 동일하고 §49.2 취지(ADD COLUMN 선행)에는 오히려 더 부합합니다. 반려 사유 아님 — 향후 검증자가 편차로 오인하지 않도록 기록합니다.

#### (2) 사후 검증의 구조적 한계 — 명시

DDL이 이미 적용된 상태라 TestPlan §1 pre-flight의 적용 전 상태(tenants 8컬럼, hq 16테이블, GRANT baseline)는 제가 직접 목격할 수 없습니다. 대신 적용 후 상태가 baseline+델타와 정확히 일치(10/16/20, 초과 0건)함을 확인했습니다 — 강한 간접 증거이나 pre-flight 목격과 동일하지는 않습니다. Codex 보고를 신뢰하지 않는다는 원칙상 이 한계를 감춰서는 안 된다고 판단해 명시합니다.

#### (3) 금지 7함수 "호출 없음"의 증명 한계

실패한 호출은 흔적을 남기지 않으므로 "호출된 적 없음"을 직접 증명할 수는 없습니다. 다만 (a) tenant_status='ACTIVE' 0건, (b) 데이터 무변경, (c) 신규 호출자 추가 0건(커밋이 0168 단독), (d) 7함수 전부 42703/42883 방벽으로 도달 불가 — 관측 가능한 모든 지표가 일관되게 "호출 없음"을 가리킵니다.

### 검증 범위 한정

이번 검증은 로컬 DB(PostgreSQL 17.6) 한정입니다. Open Item (m)의 클라우드 확인 3건(pg_cron 상태 / 카탈로그 값 / PG 버전)은 여전히 미해결이며, Stage 12 병합 판단 시 별도로 다뤄야 합니다.
