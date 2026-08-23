# 601734_Audit_Stage6_Round4_Verification_Codex.md

> ⚠️ **Stage 6 Round 4 Contract Verification · Eyes-Only**
>
> Verifier B 관점으로 `601717` 계약과 `601716` TestPlan의 실행 가능성을 line-by-line 대조했다.
> Round 3 처분 결과는 새 근거 없이 재개방하지 않았다.
>
> 수행: Codex, 2026-08-23.

## 검증 기준

| 구분 | 적용 |
|---|---|
| 대상 | `601716` 13판 / `601717` 13판 |
| R3-F1 | 「FUNCTION 전부 유효」 폐기 및 catalog/body와 runtime 분리 여부만 closure 확인 |
| R3-F2 | 물리 객체명 5건 exact expectation 전파 여부만 closure 확인 |
| R3-I1 | CW-B4 해소 상태 유지 확인 |
| R3-I2 | CW-B3 해소 상태 유지 확인 |
| R3-I3 | §12.5 범위 한정 사유 유지 확인 |
| 금지 | Human 확정 정책 및 CLOSED 항목 재설계·재개방 없음 |

## B1. R3-F1 closure — FUNCTION 존재/본문과 runtime executability 분리

| 확인 | `601716` | `601717` | 결과 |
|---|---|---|---|
| “전부 유효” 폐기 | TP-R-14·15가 모집단·본문 불변으로 재정의 (§6 L618–619) | R3-F1 처분이 runtime 분리를 명시 (§7.8 L1198) | 닫힘 |
| known phantom의 취급 | TP-R-14가 N-4″·N-6″·N-7″·N-8″를 FAIL 사유에서 제외 (L618) | V-19가 runtime executability를 주장하지 않음 (§8.2 L1258) | 일치 |
| Acceptance Criteria | AC-7이 모집단·본문 기준선으로 판정하고 phantom을 FAIL에서 제외 (§13 L1013) | AC-7은 `601716` Acceptance Criteria 전체를 요구 | 일치 |
| `stores` 모집단 | before/after 158, 본문 불변 (TP-R-14) | V-19 동일 | 일치 |
| `tenants` 모집단 | 10건 존재, 본문 불변 (TP-R-15) | 금지 조작 FO-A·FO-D 및 TestPlan 위임 | 일치 |

## B2. R3-F2 closure — 물리 객체명 5건

| 객체 | 계약 exact name | TestPlan exact expectation | 결과 |
|---|---|---|---|
| MerchantAccount PK | `merchant_accounts_pkey` (`601717` §4.1 L480, §4.2.2 L582) | TP-P-26 (`601716` §4.2 L394) | 일치 |
| Tenant UNIQUE | `uq_merchant_accounts_tenant` (`601717` §4.2 L545, §4.2.2 L583) | TP-P-29 | 일치 |
| MerchantAccount→Tenant FK | `fk_merchant_accounts_tenant_id` (`601717` §4.2 L546, §4.2.2 L584) | TP-P-27 (`601716` L395) | 일치 |
| Store→MerchantAccount FK | `fk_stores_merchant_account_id` (`601717` D-19 L307, §4.2.2 L585) | TP-P-34·35 (`601716` L402–403) | 일치 |
| Store lookup index | `idx_stores_merchant_account_id` (`601717` D-20 L308, §4.2.2 L586) | TP-P-36 (`601716` L404) | 일치 |

추가 index 방지는 `601716` TP-N-65 L494가 `merchant_accounts_pkey`와
`uq_merchant_accounts_tenant` 두 개만 허용하여 검사한다.

## B3. 허용 동사 ↔ D/M 항목 양방향 대조

| 허용 동사 | 대응 조작 | 결과 |
|---|---|---|
| `RENAME TO / COLUMN / CONSTRAINT` | D-1~D-4, D-6~D-7 | 일치 (`601717` §1.3 L272–278, §1.6 L340) |
| `DROP COLUMN / CONSTRAINT` | D-10~D-12 | 일치 (L281–283, §1.6 L341) |
| `ADD COLUMN` | D-18 | 일치 (`601717` L306, §1.6 L342) |
| `ADD CONSTRAINT` | D-15·D-19 | 일치 (`601717` L303·307, §1.6 L343) |
| `ENABLE/FORCE RLS` | D-17 | 일치 |
| trigger/index rename | D-5, D-8~D-9 | 일치 |
| `CREATE TABLE/INDEX/TRIGGER` | D-14, D-20, D-16 | 일치 |
| `COMMENT` | D-13, D-21 | exact literal까지 고정 |
| `INSERT … SELECT` / `UPDATE … FROM` | M-1 / M-2 | 일치 |

허용 동사에 대응 D/M 항목이 없는 경우와 D/M 항목이 허용 동사 밖인 경우는 발견되지 않았다.

## B4. TestPlan 기대값 실행 가능성

| Test군 | 관측 방법 | 결과 |
|---|---|---|
| TP-P-23/38 COMMENT | catalog comment와 확정 literal 문자열 비교 | 실행 가능 (`601716` L379·404 ↔ `601717` §4.2.1 L532–555) |
| TP-P-26/27/29/34~36 | `pg_constraint`, `pg_indexes`, columns catalog | 실행 가능; 이름·정의 모두 exact |
| TP-N-50~53/62 | `pg_proc.prosrc` md5 및 length | 실행 가능; 두 핵심 RPC는 PRE-7 값 고정 |
| TP-N-63 | 두 migration 본문의 호출문 정적 검색 | 실행 가능; 존재하지 않는 command-list 요구는 제거됨 (`601716` L587) |
| TP-R-14/15 | before/after 함수 모집단과 `prosrc` 비교 | 실행 가능하나 비교 snapshot 형식은 미지정 |
| TP-RT-08 | 기존 md5와 phantom column 부재의 정적 결합 | runtime 성공성을 요구하지 않고 기존 실패 원인 불변을 확인 가능 |

### B4-a. pre-state 캡처 확인

`601716` PRE-4는 §2.1 기준선 재측정을 구현 전 요구한다(L259). 다만 BL-22/BL-23은
함수 수만 기록하고 158개/10개 전체 본문의 hash set은 기록하지 않는다(L298–299).
TP-R-14/15가 요구하는 “본문 불변”을 재현하려면 PRE-4 시점에 별도 body snapshot 또는 hash set이 필요하지만,
그 표현·저장 형식은 지정되지 않았다.

이는 migration SQL의 허용 구현을 바꾸지 않고 검증 증거 형식만 남긴 간극이므로 informational로 분류한다.

## B5. 불변조건 coverage

| 범위 | coverage | 근거 |
|---|---|---|
| I-1~I-17 | 직접 Test 또는 대체 상태 검사 | `601716` TP-P-01~24, TP-N-01~15 |
| I-18·19·21·22·25·26·31·32 | 명시 Test ID 없음, 범위 한정 사유 유지 | `601716` §12.5 및 R3-I3 처분 L986 |
| I-20·23·24·27~30 | schema/negative/backfill Test | TP-P-37, TP-D-05~06, TP-N-16·22·26~30·40~43 |
| I-33~I-46 | Person rename, 제외 항목, 경계 Test | TP-P-03~23, TP-N-03~08·16~21 |
| I-47~I-51 | backfill·1:1·배치·fail-closed Test | TP-D-01~09, TP-P-25~33, TP-N-09~14·22·24 |

R3-I3의 범위 한정 사유는 유지되며 현재 Stage 8 구현 선택지를 추가하지 않는다.

## B6. 금지 조항 우회

| 금지 경로 | 계약 | TestPlan | 결과 |
|---|---|---|---|
| 기존 RPC 부분 수정 | FO-A~FO-D | TP-N-50~53, TP-M-11 | 닫힘 |
| 신규 store writer 우회 | FO-E | TP-N-54~56 | 닫힘 |
| phantom 컬럼을 신규 컬럼으로 해소 | FO-19/FO-B1 | TP-N-59 | 닫힘 |
| `SET NOT NULL` 및 우회 enforcement | FO-13 | TP-N-40~43 | 닫힘 |
| 추가 index | D-15·D-20 외 금지 | TP-N-65 | 닫힘 |
| provider/out-of-scope 객체 | FO-21~33 | TP-X-01~13, TP-N-31~39 | 닫힘 |
| 검증 도구 변경 | X-18/FO-36 | TP-B-04 | 닫힘 |

## B7. Acceptance Criteria 완결성

| 필수 범위 | AC | 결과 |
|---|---|---|
| Preconditions/environment | `601716` AC-1 | 포함 |
| Positive | AC-2 | 포함 |
| TP-D-01~09 | AC-4 | 포함 |
| Negative 전체 | AC-5 | TP-N-65 포함 |
| Regression | AC-7 | R3-F1 의미까지 명시 |
| External/Boundary/Migration | AC-8~09 | 포함 |
| Rollback | AC-10 | 포함 |
| C-1/C-2/H-1~H-5/H-3a | AC-12·17, `601717` AC-10·12 | 포함 |
| 물리 정의 | AC-16 및 `601717` AC-11 | 5컬럼·제약·객체명 Test로 연결 |

## B8. 기준선 값 교차대조

| 값 | `601716` | `601717` | Evidence | 결과 |
|---|---|---|---|---|
| tenants rows | 1 | 1 | `601720`/`601721` PRE-5 | 일치 |
| stores rows | 1 | 1 | `601718`~`601721` | 일치 |
| stores columns | before 16 / after 17 | preflight 16 | `601720`/`601721` PRE-6 | 일치 |
| provision_tenant md5/len | `f84ac…e974` / 4758 | 동일 | `601720`/`601721` PRE-7 | 일치 |
| create_franchise_store md5/len | `87511…b7f` / 3460 | 동일 | `601720`/`601721` PRE-7 | 일치 |
| stores-ref function population | 158 | 158 | `601718`/`601719` | 일치 |
| tenants-ref function population | 10 | 10 | `601701` E단계 | 일치 |

## Round 3 disposition 재개방 확인

| 항목 | 상태 |
|---|---|
| R3-F1 | closure 확인; 재개방하지 않음 |
| R3-F2 | closure 확인; 재개방하지 않음 |
| R3-I1 | CW-B4 해소 유지 |
| R3-I2 | 본문·경계 요약 모두 N-6″/N-8″ 연결 확인 (`601717` §4.4.3, §9.2) |
| R3-I3 | §12.5 범위 한정 유지 |
| Cursor A3·A7 4건 | 유지 판정 그대로 보존 |

## 종합

| 항목 | 발견 | blocking | informational |
|---|---:|---:|---:|
| B1 R3 closure | 0 | 0 | 0 |
| B2 물리 이름 | 0 | 0 | 0 |
| B3 동사↔조작 | 0 | 0 | 0 |
| B4 실행 가능성 | 1 | 0 | 1 |
| B5 invariant coverage | 0 | 0 | 0 |
| B6 금지 우회 | 0 | 0 | 0 |
| B7 Acceptance Criteria | 0 | 0 | 0 |
| B8 기준선 | 0 | 0 | 0 |

## Findings

| # | 유형 | 지점 | 내용 | blocking | acceptance rule 근거 |
|---|---|---|---|---|---|
| R4-I1 | evidence format | `601716` PRE-4 L259, BL-22·23 L298–299, TP-R-14·15 L618–619 | 전체 함수 body 불변 비교를 위한 pre-state hash/snapshot의 형식과 보존 위치가 미지정이다 | NO | 검증 증거 형식의 문제이며 Stage 8 migration SQL에 서로 다른 합리적 구현을 만들지 않음 |

## 명시적 결과

**NO BLOCKING CONCERNS FOUND.**

Informational finding 1건을 기록한다. 이 문서는 승인 또는 차단 판정을 하지 않는다.
