# 601732_Audit_Stage6_Round3_Verification_Codex.md

> ⚠️ **Stage 6 Round 3 Contract Verification · Eyes-Only**
>
> `000701` §38.4 에 따라 두 검증자에게 **다른 검증 방법**을 배정했다.
>
> ```text
> Verifier A (Cursor)   경계 · 범위 · handoff · blocker lifecycle
> Verifier B (Codex)    계약 ↔ TestPlan 실행 가능성 line-by-line 대조
> ```
>
> 이번 라운드부터 **finding acceptance rule** 이 적용되었다 —
> blocking 은 "Stage 8 에서 다른 코드를 만들 수 있는가"를 기준으로 한다.
>
> 수행: Codex, 2026-08-23.

> **Eyes-Only · 실행 가능성 및 계약↔TestPlan 교차대조**
>
> 대상: `601716_TestPlan_Operational_Authority_Foundation_V2.md`,
> `601717_ChangeContract_Operational_Authority_Foundation_V2.md`.
>
> 대상 문서를 수정하지 않았으며, 이 결과 파일 외 파일을 조작하지 않았다.
> 상대 검증 결과를 읽거나 참조하지 않았다. 이 문서는 승인·차단 판정문이 아니다.

## Acceptance rule 적용 기준

| Rule | blocking 적용 조건 |
|---|---|
| 1 | 계약이 허용한 구현을 그대로 했는데 TestPlan에서 FAIL할 수 있음 |
| 2 | 금지 조작을 계약/TestPlan이 실제 허용하거나 실행하게 함 |
| 3 | Stage 8 구현자가 둘 이상의 합리적 구현 중 하나를 스스로 선택해야 함 |

표현 개선, 명시적으로 이월된 후속 나선 사항, 실행 의미가 같은 중복 설명은 informational로만 분류했다.

## B1. R2-F1~F5 closure

| Finding | closure | 인접 조항 잔존 | 근거 |
|---|---|---|---|
| R2-F1 `CREATE UNIQUE INDEX` 잔존 | 닫힘 | 없음 | `601717` §1.4 D-15 L301은 `ADD CONSTRAINT … UNIQUE`만 허용; §1.6 L343은 D-15·D-19를 `ADD CONSTRAINT`에 연결; §4.2 L526도 동일 형태. `601716` TP-P-29 L394는 unique index 단독을 FAIL 처리 |
| R2-F2 COMMENT literal | 닫힘 | 없음 | `601717` §4.2.1 L532–555에 4개 exact literal; `601716` TP-P-23 L379 및 TP-P-38 L404가 같은 문자열을 직접 기대 |
| R2-F3 TP-N-63 관측 불가 | 실행 의미상 닫힘 | “실행 command 목록”의 보존 위치는 미지정 | `601716` §5.9 TP-N-63 L572는 md5·migration 본문·command 목록의 정적 증거로 재정의하고 종전 runtime 관측 정의는 L573에서 폐기 |
| R2-F4 H-1 prerequisite | 본문 닫힘 | 경계 요약에 N-8″ 누락 | `601717` §4.4.3 L712–726은 N-6″와 N-8″ 모두 명시. 다만 §9.2 L1132는 H-1 prerequisite를 N-6″만으로 요약 |
| R2-F5 AC 누락 | 닫힘 | 없음 | `601716` AC-4 L929에 TP-D-09, AC-12 L937에 H-3a; `601717` AC-10 L1186에도 H-3a 포함 |

## B2. 허용 동사 ↔ 조작 항목 양방향 일치

| §1.6 동사 | 대응 D/M | 역방향 일치 | 근거 |
|---|---|---|---|
| `ALTER TABLE … RENAME TO` | D-1 | 일치 | `601717` §1.3 L272, §1.6 L340 |
| `ALTER TABLE … RENAME COLUMN` | D-2~D-4 | 일치 | L273–275, L340 |
| `ALTER TABLE … RENAME CONSTRAINT` | D-6~D-7 | 일치 | L277–278, L340 |
| `ALTER TABLE … DROP COLUMN` | D-10, D-12 | 일치 | L281, L283, L341 |
| `ALTER TABLE … DROP CONSTRAINT` | D-11 | 일치 | L282, L341 |
| `ALTER TABLE … ADD COLUMN` | D-18 | 일치 | L304, L342 |
| `ALTER TABLE … ADD CONSTRAINT` | D-15, D-19 | 일치 | L301, L305, L343 |
| `ENABLE/FORCE RLS` | D-17 | 일치 | L303, L344 |
| `ALTER TRIGGER … RENAME` | D-5 | 일치 | L276, L345 |
| `ALTER INDEX … RENAME` | D-8~D-9 | 일치 | L279–280, L346 |
| `CREATE TABLE` | D-14 | 일치 | L300, L347 |
| `CREATE INDEX` | D-20 | 일치 | L306, L347 |
| `CREATE TRIGGER` | D-16 | 일치 | L302, L347 |
| `COMMENT` | D-13, D-21 | 일치 | L284, L307, L348 |
| `INSERT … SELECT` | M-1 | 일치 | `601717` §1.6 L349, §4.5.1 |
| `UPDATE … FROM` | M-2 | 일치 | `601717` §1.6 L350, §4.5.1 |

### B2-a. 물리 이름의 결정성

| 객체 | 계약 고정 여부 | TestPlan | 결과 |
|---|---|---|---|
| `uq_merchant_accounts_tenant` | 고정 | TP-P-29이 이름까지 검사 | 결정적 (`601717` L301·L526; `601716` L394) |
| `trg_merchant_accounts_updated_at` | 고정 | TP-P-32는 기능만 검사 | 계약이 이름을 고정 (`601717` L528) |
| `merchant_accounts.tenant_id` FK constraint name | **미고정** | TP-P-27은 참조·동작만 검사 | inline 자동명 또는 explicit 명칭 모두 합리적 (`601717` §4.1 L471–474, §4.2 L527; `601716` L392) |
| `stores.merchant_account_id` FK constraint name | **미고정** | TP-P-34~35는 참조·동작만 검사 | 자동명 또는 `fk_stores_merchant_account_id` 등 복수 구현 가능 (`601717` D-19 L305; `601716` L399–400) |
| `stores.merchant_account_id` index name | **미고정** | TP-P-36은 존재만 검사 | 복수의 합리적 이름 가능 (`601717` D-20 L306; `601716` L401) |

## B3. TestPlan 기대값 실행 가능성

| Test | 관측 증거 | 실행 가능성 | 근거 |
|---|---|---|---|
| TP-P-23 | `obj_description`/catalog 문자열 비교 가능 | 가능 | literal 동일: `601716` L379 ↔ `601717` L550–551 |
| TP-P-38 | table/column description 문자열 비교 가능 | 가능 | 세 literal 동일: `601716` L404 ↔ `601717` L537–544 |
| TP-N-50~53 | `pg_proc.prosrc` md5/본문 대조 | 가능 | `601716` §5.7 L535–538; baseline BL-35~36 |
| TP-N-62 | md5/length 대조 | 가능 | `601716` L571 |
| TP-N-63 | migration text 및 검증 command manifest 정적 검색 | 조건부 가능 | `601716` L572. command 목록의 경로·산출물은 지정되지 않았으나 구현 SQL 선택을 바꾸지는 않음 |
| TP-N-64 | before/after tenants row·상태 대조 | 가능 | `601716` L574, BL-20/BL-27 |
| TP-R-14 | “158개 FUNCTION 전부 유효” | **기대값 충족 불가 또는 의미 미정** | `601716` L601. `601725`/`601726`은 그 모집단의 `provision_tenant`가 phantom 3개로 실행 불가능함을 실측 |
| TP-R-15 | “tenants 참조 10개 FUNCTION 전부 유효” | **기대값 충족 불가 또는 의미 미정** | `601716` L602. `provision_tenant`가 tenants 참조 함수이며 현재 정적 실행 불가능 (`601725`/`601726`) |
| TP-RT-08 | 기존 실패 원인 불변 비교 | 가능 | `601716` L698; baseline md5와 phantom column 부재를 정적으로 함께 대조 가능 |

`TP-R-14/15`의 “유효”가 단순 catalog 존재를 뜻하면 관측 가능하지만 문언의 “전부 유효”와 다르고,
실행 가능성을 뜻하면 이미 확보된 evidence와 충돌한다. 계약대로 RPC를 전혀 수정하지 않는 구현은
phantom 상태를 그대로 보존하므로 두 Test가 FAIL할 수 있다.

## B4. 불변조건 coverage — `601713` I-1~I-51

| 범위 | 대응 Test | coverage |
|---|---|---|
| I-1~I-3 | TP-P-05~07, TP-P-27, TP-P-35 | 직접 검증 |
| I-4 | TP-P-08 | 트리거 존재·호출 관계 검증; 실제 UPDATE 동작은 DML 경계로 제외했다고 `601716` §12.5 L874에 명시 |
| I-5~I-9 | TP-P-09~13 | 직접 검증 |
| I-10~I-13 | TP-P-14~16, TP-N-09~15 | 직접 검증 |
| I-14~I-16 | TP-P-19·23, TP-B-03, TP-M-09~10 | I-14는 I-36 대체 상태 포함 |
| I-17 | TP-N-15, TP-R-05 | 직접 검증 |
| I-18~I-19 | 명시 Test ID 없음 | 운영·정책 축 positive 검증은 범위 밖이라는 유지 사유가 `601716` §12.5 L873에 명시 |
| I-20 | TP-N-16 | 직접 검증 |
| I-21~I-22 | 명시 Test ID 없음 | 동일한 범위 한정 사유 명시 (`601716` §12.5 L873) |
| I-23~I-24 | TP-P-37, TP-N-22, TP-N-40 | 구조 분리·순환 부재·enforcement 이월 검증 |
| I-25~I-26 | 명시 Test ID 없음 | 범위 한정 사유 명시 (`601716` §12.5 L873) |
| I-27 | TP-D-05~06, TP-N-40~43 | 현 데이터 및 deferred enforcement 검증 |
| I-28~I-30 | TP-N-26~30 | 직접 검증 |
| I-31~I-32 | 명시 Test ID 없음 | 범위 한정 사유 명시 (`601716` §12.5 L873) |
| I-33 | TP-N-29~30 | 이번 범위에서 시점 구조·포인터 변경 부재 검증 |
| I-34~I-37 | TP-P-03~04·07·17·20~22, TP-N-03·05·06 | 직접 검증 |
| I-38~I-39 | TP-N-16~21, TP-N-60~61 | 직접 검증 |
| I-40~I-42 | TP-N-25·29·30 | 이월 경계 검증 |
| I-43~I-46 | TP-P-08·18, TP-N-07·08·12 | 직접 검증 |
| I-47~I-49 | TP-D-01~08, TP-P-29, TP-N-22 | 검증 시점 상태와 1:1 방향 검증; 강제 부재는 N-1″ 이월 |
| I-50~I-51 | TP-P-25·33, TP-N-09~14·24 | schema와 fail-closed posture 검증 |

명시 Test ID가 없는 I-18·19·21·22·25·26·31·32는 이유가 문서에 기록되어 있고,
현재 Stage 8 구현 선택지를 바꾸지 않으므로 acceptance rule상 informational이다.

## B5. 금지 조항 우회

| 경로 | 닫힘 여부 | 근거 |
|---|---|---|
| `provision_tenant` 부분 수정·재정의 | 닫힘 | `601717` FO-A L848, FO-C L851, S-8 L1164; `601716` TP-N-50·52, TP-M-11 |
| `create_franchise_store` 부분 수정·phantom 교정 | 닫힘 | `601717` FO-B/B1 L849–850, S-8; `601716` TP-N-51·59 |
| `onboard_tenant`/`update_business_hours` 수정 | 닫힘 | `601717` FO-D L852; `601716` TP-N-53 |
| 신규 우회 store writer | 닫힘 | `601717` FO-E L853; `601716` TP-N-54~56 |
| `NOT NULL` 또는 CHECK/trigger 우회 | 닫힘 | `601717` FO-13 L871; `601716` TP-N-40~43 |
| provider/다른 schema 확장 | 닫힘 | `601717` §6.3; `601716` TP-X-01~13 |
| 검증 도구 변경 | 닫힘 | `601717` X-18 L834, FO-36; `601716` TP-B-04 |

## B6. Acceptance Criteria 완결성

| 필수 범위 | AC 포함 | 근거 |
|---|---|---|
| Positive | 예 | `601716` AC-2 L927 |
| TP-D-01~09 | 예 | `601716` AC-4 L929 |
| Negative 전체 | 예 | `601716` AC-5 L930 |
| Regression 전체 | 예 | `601716` AC-7 L932 |
| External/Boundary/Migration | 예 | `601716` AC-8~09 L933–934 |
| Rollback | 예 | `601716` AC-10 L935 |
| C-1/C-2, H-1~H-5, H-3a | 예 | `601716` AC-12 L937; `601717` AC-10 L1186 |
| H-5 | 예 | `601716` AC-17 L941; `601717` AC-12 L1185 |
| 환경 drift/Stage gate | 예 | `601716` AC-1 L926, `601717` §10 상태표 |

단, AC-7이 Regression 전항목 PASS를 요구하므로 TP-R-14/15의 불가능·모호한 기대값이 그대로
최종 수용 여부에 영향을 준다.

## B7. 기준선 값 정합

| 기준선 | `601716` | `601717` | Evidence | 결과 |
|---|---|---|---|---|
| `tenants` 행 | 1 (`601716` PRE-5 L257, BL-20) | §10.3 기준 환경 1 | `601720`/`601721` PRE-5 | 일치 |
| `stores` 행 | 1 (BL-5) | §10.3 기준 환경 1 | `601718`/`601719`, `601720`/`601721` | 일치 |
| `stores` columns | before 16 / after 17 (`601716` BL-21 L294) | S-10 before 16 (`601717` L1166) | `601720`/`601721` PRE-6 = 16 | 일치 |
| `provision_tenant` md5/len | `f84ac1a81da4ccba87930bf020a3e974` / 4758 (`601716` BL-35, TP-N-50/62) | PRE-7 gate 참조 | `601720`/`601721` | 일치 |
| `create_franchise_store` md5/len | `87511a95676a41d2c95866e0c2da8b7f` / 3460 (`601716` BL-36, TP-N-51) | PRE-7 gate 참조 | `601720`/`601721` | 일치 |
| Store writer functions | 2 | 두 함수 명시 금지 | `601718`/`601719` | 일치 |
| `stores` reference functions | 158 (`601716` BL-22) | 검증 V-19 | `601718`/`601719` | 수치 일치; “전부 유효” 기대만 별도 문제 |

## 종합

| 항목 | 발견 | blocking | informational |
|---|---:|---:|---:|
| B1 R2-F1~F5 closure | 2 | 0 | 2 |
| B2 허용 동사↔조작 | 1 | 1 | 0 |
| B3 Test 실행 가능성 | 2 | 1 | 1 |
| B4 invariant coverage | 1 | 0 | 1 |
| B5 금지 우회 | 0 | 0 | 0 |
| B6 Acceptance Criteria | 1 | 1 | 0 |
| B7 기준선 | 0 | 0 | 0 |

중복을 합치면 **고유 findings 5건: blocking 2건, informational 3건**이다.

## Findings

| # | 유형 | 지점 | 내용 | blocking | acceptance rule 근거 |
|---|---|---|---|---|---|
| R3-F1 | invariant mismatch / executable test conflict | `601716` §6 TP-R-14 L601, TP-R-15 L602; AC-7 L932 | known phantom 함수가 모집단에 포함되는데 “전부 유효”를 기대한다. “유효”가 실행 가능이면 계약대로 RPC를 불변 유지한 구현이 FAIL하고, catalog 존재이면 문언과 판정 방식이 달라진다 | **YES** | **Rule 1**: 허용 구현을 그대로 해도 FAIL 가능. **Rule 3**: 검증자가 `유효` 의미를 선택해야 함 |
| R3-F2 | too narrow / unspecified physical identity | `601717` §1.4 D-19·D-20 L305–306, §4.1 L471–474, §4.2 L527; `601716` TP-P-27·34~36 L392·399–401 | `merchant_accounts.tenant_id` FK, Store FK, Store index의 물리 이름이 고정되지 않았다. 자동명과 명시명 등 복수의 합리적 SQL이 모두 계약/TestPlan을 만족한다 | **YES** | **Rule 3**: Stage 8 구현자가 물리 이름을 스스로 선택해야 함 |
| R3-I1 | evidence specificity | `601716` TP-N-63 L572 | 정적 검증으로 전환돼 코드 선택에는 영향 없으나 “이 TestPlan의 실행 command 목록”을 어느 산출물에서 고정하는지는 명시되지 않았다 | NO | 구현 코드가 달라지지 않으므로 blocking 조건 1~3에 해당하지 않음 |
| R3-I2 | adjacent summary drift | `601717` §4.4.3 L712–726 ↔ §9.2 L1132 | 본문 prerequisite는 N-6″+N-8″로 닫혔지만 경계 요약은 N-6″만 적는다 | NO | 후속 나선 항목이며 현재 Stage 8 코드 선택에 영향 없음 |
| R3-I3 | explicit coverage exception | `601716` §12.5 L873 | I-18·19·21·22·25·26·31·32에 명시 Test ID가 없지만 범위 한정 사유가 기록돼 있다 | NO | 명시적 범위 밖이며 현재 구현 경계를 넓히지 않음 |

`NO CONCERNS FOUND`가 아니다. 위 5건을 기록한다.

이 보고서는 승인 또는 차단 판정을 하지 않는다. `blocking=YES`는 사용자 제공 acceptance rule
1·2·3 중 명시한 조건을 충족한다는 분류만 뜻한다.
