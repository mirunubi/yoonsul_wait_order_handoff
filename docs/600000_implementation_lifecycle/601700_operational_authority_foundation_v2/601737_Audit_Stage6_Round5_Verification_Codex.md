# 601737_Audit_Stage6_Round5_Verification_Codex.md

> ⚠️ **Stage 6 Round 5 Contract Verification · Eyes-Only · 판정문이 아니다**
>
> 역할: Verifier B — 계약 ↔ TestPlan 실행 가능성 line-by-line 대조  
> 수행: Codex, 2026-08-23  
> 입력: `601716` TestPlan 14판 / `601717` ChangeContract 14판  
> 관련 문서는 수정하지 않았다. 승인·차단 또는 재설계를 수행하지 않는다.

## §0 판본 선행 확인

| 대상 | 작업 전 확인 | 근거 |
|---|---|---|
| `601716` | 개정 이력 마지막 행 **14판 — Round 4 findings 반영**, Round 5 재검증 필요 | `601716` 개정 이력 L27 |
| `601717` | 개정 이력 마지막 행 **14판 — Round 4 findings 반영**, Round 5 재검증 필요 | `601717` 개정 이력 L27 |
| `601700` Readme | Correction A 상태: Stage 6 OPEN / Stage 7 NOT EFFECTIVE / Stage 8 MUST NOT START | `601700` §3 L45-L60, 진행표 L70-L72 |

지시서와 현물 판본은 일치했다. 아래 검증은 14판을 대상으로 수행했다.

## B1. C4-B1 · C4-I1 closure

| 항목 | 확인 결과 | 인접 조항 잔존 | 근거 |
|---|---|---|---|
| C4-B1 — Tenant FK 생성 책임 | 닫힘. `fk_merchant_accounts_tenant_id`는 D-14의 `CREATE TABLE` 안에서 명명된 FK로 생성된다 | 발견 없음. §4.1·§4.2·§4.2.2도 모두 D-14를 가리킨다 | `601717` §1.4 D-14 L303, §1.4.1 L312-L345, §4.1 L518-L546, §4.2 L588, §4.2.2 L624-L629 |
| C4-I1 — trigger 이름·형태 | 닫힘. D-16이 `trg_merchant_accounts_updated_at`을 만들며 확정 구문이 하나다 | 발견 없음. TestPlan은 이름과 호출 함수를 함께 exact 검사한다 | `601717` §1.4 D-16 L305, §4.2 L589, §4.2.2 L627, §4.2.3 L664-L676; `601716` TP-P-32 L401 |

## B2. 물리 객체명 6건의 생성 책임

| # | 물리 객체명 | 생성 책임 | §1.6 허용 | TestPlan 관측 |
|---|---|---|---|---|
| 1 | `merchant_accounts_pkey` | D-14 `CREATE TABLE … CONSTRAINT … PRIMARY KEY` | D-14 한정 `CREATE TABLE … CONSTRAINT` | TP-P-26 exact 이름 |
| 2 | `uq_merchant_accounts_tenant` | D-15 `ALTER TABLE … ADD CONSTRAINT … UNIQUE` | D-15 한정 `ADD CONSTRAINT` | TP-P-29 exact 이름·제약 형태 |
| 3 | `fk_merchant_accounts_tenant_id` | D-14 `CREATE TABLE … CONSTRAINT … FOREIGN KEY` | D-14 한정 `CREATE TABLE … CONSTRAINT` | TP-P-27 exact 이름·대상·referential action |
| 4 | `trg_merchant_accounts_updated_at` | D-16 `CREATE TRIGGER` | `CREATE TRIGGER`; D-16에서 대상·이름·함수 확정 | TP-P-32 exact 이름·함수 |
| 5 | `fk_stores_merchant_account_id` | D-19 `ALTER TABLE … ADD CONSTRAINT … FOREIGN KEY` | D-19 한정 `ADD CONSTRAINT` | TP-P-34·35 exact 이름·대상·referential action |
| 6 | `idx_stores_merchant_account_id` | D-20 `CREATE INDEX` | 비-unique `CREATE INDEX`; unique 형태 명시적 배제 | TP-P-36 exact 이름 |

근거: `601717` §1.4 L303-L310, §1.4.1 L314-L345, §1.6 L375-L394, §4.2.2 L619-L633; `601716` §4.2 L395-L405, §4.3 L426-L444.

6개 모두 생성 책임이 한 D 항목에 귀속되고, 허용 동사와 exact Test 기대값이 연결된다.

## B3. 허용 동사 ↔ 조작 항목 양방향 일치

| 조작군 | D/M 항목 → 허용 동사 | 허용 동사 → D/M 항목 | 결과 |
|---|---|---|---|
| Person rename | D-1~D-9 → table/column/constraint/trigger/index rename | 각 rename 동사는 D-1~D-9에 대응 | 일치 |
| Person 제거 | D-10~D-12 → DROP COLUMN/CONSTRAINT | §1.6이 D-10~D-12로 한정 | 일치 |
| COMMENT | D-13·D-21 → COMMENT ON TABLE/COLUMN | exact literal은 §4.2.1과 TP-P-23·38에 고정 | 일치 |
| MerchantAccount table | D-14 → CREATE TABLE + 명명 PK/FK | §1.6 D-14 한정 | 일치 |
| UNIQUE | D-15 → ADD CONSTRAINT UNIQUE | §1.6 D-15 한정; CREATE UNIQUE INDEX 배제 | 일치 |
| trigger | D-16 → CREATE TRIGGER | 이름·대상·함수는 §4.2.3으로 단일화 | 일치 |
| RLS | D-17 → ENABLE/FORCE RLS | §1.6 D-17 한정 | 일치 |
| Store FK column | D-18~D-20 → ADD COLUMN/FK/INDEX | §1.6 D-18·D-19 및 비-unique CREATE INDEX와 대응 | 일치 |
| backfill | M-1 INSERT SELECT / M-2 UPDATE FROM | §1.6이 M-1·M-2로 한정 | 일치 |

근거: `601717` §1.3 L271-L297, §1.4 L299-L345, §1.6 L375-L394, §4.5 L889-L929.

허용 동사에 대응 조작이 없는 경우와 D/M 항목이 허용 동사 밖에 있는 경우는 발견하지 못했다.

## B4. TestPlan 기대값의 실행 가능성

| 검사군 | 관측 증거 | 계약과 literal·객체명 일치 | 결과 |
|---|---|---|---|
| Person rename·제약·RLS·GRANT | catalog relation/column/constraint/index/trigger/RLS/ACL | D-1~D-13 및 FO-1~FO-9와 일치 | 관측 가능 |
| MerchantAccount 5컬럼 | `information_schema.columns`, `pg_constraint` | §4.1의 5컬럼과 TP-P-26~31 일치 | 관측 가능 |
| 물리 객체명 6건 | `pg_constraint`, `pg_trigger`, `pg_indexes` | §4.2.2와 TP-P-26·27·29·32·34~36 동일 | 관측 가능 |
| COMMENT 4건 | `obj_description` / `col_description` | D-13 및 §4.2.1 literal과 TP-P-23·38 동일 | 관측 가능 |
| backfill | 행 수·join·NULL·문자열 비교와 migration text | §4.5.1 M-1·M-2와 TP-D-01~09 일치 | 관측 가능 |
| forbidden DDL/DML | migration text와 schema delta | FO-1~FO-40 및 TP-N/TP-B/TP-M에 대응 | 관측 가능 |
| 함수 불변 | `pg_proc.prosrc` md5·length·본문/모집단 전후 대조 | TP-N-50~53·62~64, TP-R-14·15. runtime 성공을 요구하지 않음 | 관측 가능 |
| rollback | 역방향 신규 migration 계획과 baseline 비교 | TP-RB-01~08; `stores.updated_at` 비가역 예외 명시 | 관측 가능 |

근거: `601716` §4 L354-L458, §5 L463-L608, §6 L610-L649, §8 L681-L692, §9 L694-L726, §10 L728-L803, §11 L805-L816; `601717` §4.2.1 L593-L617.

계약이 허용한 구현을 그대로 했을 때 TestPlan이 다른 literal 또는 다른 객체명을 요구하는 지점은 발견하지 못했다.

## B5. 불변조건 I-1~I-51 coverage

| 불변조건 | TestPlan 대응 | 결과 |
|---|---|---|
| I-1~I-3 | TP-P-05·06 | 검증 |
| I-4 | TP-P-08·TP-R-03. 실제 UPDATE 동작은 허용 DML 경계 때문에 후속 소관임을 명시 | 사유 명시 (`601716` §12.5 L933-L935) |
| I-5~I-8 | TP-P-09~12 | 검증 |
| I-9~I-13 | TP-P-02·14~18, TP-N-09~14 | 검증 |
| I-14 | I-36으로 대체; TP-N-05가 `is_active` 재생성을 금지 | 대체 관계 명시 |
| I-15 | TP-P-23 exact COMMENT | 검증 |
| I-16 | TP-B-03, TP-R-16·17, TP-M-04 | 검증 |
| I-17 | TP-N-15·58 | 검증 |
| I-18~I-22 | TP-N-16·22·23, TP-X-08~11 및 범위 한정 | 사유 명시 (`601716` §12.5 L929-L938) |
| I-23 | TP-P-37 | 검증 |
| I-24~I-27 | TP-P-34~36, TP-D-05·06, TP-N-22 및 범위 한정 | 검증/사유 명시 |
| I-28~I-30 | TP-N-26~30 | 검증 |
| I-31~I-33 | TP-N-29·30·33 및 Out of Scope/이월 | 사유 명시 |
| I-34~I-37 | TP-P-03~13, TP-N-03·05·06, TP-M-09 | 검증 |
| I-38~I-39 | TP-N-16~21·60·61 | 검증 |
| I-40~I-42 | TP-N-25~30, C-2 이월 | 검증/이월 명시 |
| I-43~I-46 | TP-P-08·22~23, TP-N-07·08 | 검증 |
| I-47~I-51 | TP-D-01~08, TP-P-27·29·33, TP-N-11·13·22·24 | 검증 |

근거: `601713` §1.1~§1.5 I-1~I-51; `601716` §4~§7, §12.4 L882-L903, §12.5 L929-L938, §14 L1058-L1080.

명시 Test ID가 없는 conceptual invariant는 이미 범위 한정 또는 후속 나선 이월 사유가 기록돼 있다. Round 3의 R3-I3 및 이전 유지 판정을 새 근거 없이 재개방하지 않았다.

## B6. 금지 조항 우회

| 우회 후보 | 닫는 조항 | TestPlan 대응 | 결과 |
|---|---|---|---|
| 두 INSERT RPC 일부 수정·phantom 즉석 교정 | FO-A~FO-D·FO-B1·FO-C | TP-N-50~53·59·62~64, TP-M-11 | 닫힘 |
| 새 함수·트리거로 Store 생성 우회 | FO-E·FO-15·FO-32 | TP-N-35·39·54~56, TP-M-11 | 닫힘 |
| NOT NULL 대신 CHECK/trigger 강제 | FO-13·FO-20 | TP-N-40·42·43 | 닫힘 |
| UNIQUE 구현 형태 변경 | D-15 단일 형태, CREATE UNIQUE INDEX 금지 | TP-P-29·TP-N-65 | 닫힘 |
| 검증 도구 수정 | X-18·FO-36 | TP-B-04·TP-B-05 | 닫힘 |
| 기존 migration 수정 | X-1~X-3·FO-40 | TP-B-03·TP-R-16·17 | 닫힘 |
| provider/LegalEntity/상태 축 범위 확장 | FO-21~FO-33 | TP-X-01~13·TP-N-16~39·58·60 | 닫힘 |

근거: `601717` §5 L951-L986, §6 L988-L1057; `601716` §5 L463-L608, §7 L651-L679, §8 L681-L692, §9 L694-L726.

금지된 조작을 실제로 허용하거나 실행하게 하는 문면은 발견하지 못했다.

## B7. Acceptance Criteria 완결성

| 범주 | TestPlan AC | ChangeContract AC | 결과 |
|---|---|---|---|
| preflight·허용 파일·금지 경계 | AC-1·2·9·13 | AC-1~4·7~8 | 포함 |
| positive·backfill·negative | AC-2~6·16 | AC-5~7·11 | 포함 |
| regression·migration·rollback | AC-7·9·10·18 | AC-7 | 포함 |
| C-1·C-2·H-1~H-5 handoff | AC-11·12·17 | AC-9·10·12 | 포함 |
| I-47·known phantom 구분 | AC-14·15 | AC-7·10 | 포함 |
| 이중 검증·저자 분리 | AC-13 | AC-8 | 포함 |

근거: `601716` §13 L1031-L1052; `601717` §9.4 L1540-L1560.

필수 Test 또는 handoff가 Acceptance Criteria에서 빠진 지점은 발견하지 못했다.

## B8. 기준선 값 정합

| 기준선 | `601716` | `601717` | evidence | 결과 |
|---|---|---|---|---|
| PostgreSQL image | `postgres:17.6.1.140` | 동일 | `601720`·`601721` | 일치 |
| latest migration | `0169` | 동일 | `601720`·`601721` | 일치 |
| tenants 행 수 | 1 | 1 | `601720`·`601721` PRE-5 | 일치 |
| stores 행 수 | 1 | 1 | `601718`·`601719` Environment | 일치 |
| stores 컬럼 수 | before 16 / after 17 | preflight 16 | `601720`·`601721` PRE-6 | 일치 |
| stores 참조 함수 | 158 | 158 | `601718`·`601719` S-1 | 일치 |
| `provision_tenant` md5 / len | `f84ac1a81da4ccba87930bf020a3e974` / 4758 | 동일 | `601720`·`601721` PRE-7 | 일치 |
| `create_franchise_store` md5 / len | `87511a95676a41d2c95866e0c2da8b7f` / 3460 | 동일 | `601720`·`601721` PRE-7 | 일치 |
| stores trigger | 241 before/after | 변경 금지 | `601718` S-6 | 일치 |
| stores VIEW / MATVIEW | 0 / 0 | 변경 금지 | `601718`·`601719` S-6 | 일치 |

근거: `601716` §2.1 L276-L318, §2.2 L326-L337, TP-N-50·51 L560-L561, TP-R-14 L627; `601717` §0.1.2 기준선, §8.1 L1432-L1444.

## 종합

| 항목 | 발견 | blocking | informational |
|---|---:|---:|---:|
| B1 C4-B1·C4-I1 closure | 0 | 0 | 0 |
| B2 물리 객체명 6건 생성 책임 | 0 | 0 | 0 |
| B3 허용 동사 양방향 일치 | 0 | 0 | 0 |
| B4 TestPlan 실행 가능성 | 0 | 0 | 0 |
| B5 I-1~I-51 coverage | 0 | 0 | 0 |
| B6 금지 조항 우회 | 0 | 0 | 0 |
| B7 Acceptance Criteria | 0 | 0 | 0 |
| B8 기준선 값 | 0 | 0 | 0 |
| **합계** | **0** | **0** | **0** |

## Findings

| # | 유형 | 지점 | 내용 | blocking | acceptance rule 근거 |
|---|---|---|---|---|---|
| — | — | — | 발견사항 없음 | — | acceptance rule 1·2·3 해당 없음 |

**NO CONCERNS FOUND**

이 문구는 승인 또는 차단 판정이 아니다. Verifier B 관점에서 14판 계약과 TestPlan 사이에 Stage 8 코드를 달라지게 만드는 신규 불일치를 발견하지 못했다는 검증 결과다.
