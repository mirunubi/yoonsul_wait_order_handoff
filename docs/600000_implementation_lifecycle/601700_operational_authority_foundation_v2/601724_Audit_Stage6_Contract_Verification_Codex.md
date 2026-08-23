# 601724_Audit_Stage6_Contract_Verification_Codex.md

> ⚠️ **Stage 6 Contract Verification · Eyes-Only · 판정문이 아니다**
>
> `000701` §9.16 Stage 6 독립 계약 검증(Critical tier)의 Verifier B 보고서다.
> 원작자 Claude Code 는 §37 에 따라 검증자 풀에서 제외되었다.
>
> **이 보고서는 계약을 승인하지도 차단하지도 않는다.** 발견사항만 기록한다.
>
> **같은 작업을 Cursor 도 독립 수행했다 — `601723`**(`000701` §35).
>
> ⚠️ **두 검증자의 결론이 갈렸다.**
>
> ```text
> 601723 Cursor   blocking 0건 — NO CONCERNS FOUND
> 601724 Codex    blocking 5건 / 고유 findings 7건
> ```
>
> **이 불일치 자체가 Stage 6 의 산출물이다.**
>
> 수행: Codex, 2026-08-23.

검증일: 2026-08-23  
역할: 독립 계약 검증자(Verifier B)  
원작자 배제: `601716`/`601717` 원작자 Claude Code 제외 (`000701` §37)  
검증 성격: Eyes-Only. 재설계·승인·차단 판정을 하지 않고 발견사항만 기록한다.

상대 검증 결과는 읽거나 참조하지 않았다.

## V1. Allowed Files 경계

| # | 항목 | 판정 | 근거 위치 |
|---|---|---|---|
| 1 | A-1 `0170_person_vocabulary_normalization.sql` | 일치 | `601717` §1.1 L240–247; `601710` §2.1 L52–68; `601713` §1.1 L53–165 |
| 2 | A-2 `0171_merchant_account_foundation.sql` | 일치 | `601717` §1.1 L240–247; `601710` §2 대상 2~4 L45–47; `601713` §1.2~§1.4 L171–282 |
| 3 | A-3 Module 자기보고서 | 일치 | `601717` §1.2 L249–263이 `601722_Module_Operational_Authority_Foundation_V2.md`로 고정하며 와일드카드와 “다음 빈 번호”를 명시적으로 폐기 |
| 4 | A-4 Readme §8 행 추가 | 일치 | `601717` §1.2 L249–264; 문서 동기화 경계 |
| 5 | A-5 `000005` 행 추가 | 일치 | 동일 |
| 6 | A-6 `000007` 행 추가 | 일치 | 동일 |
| 7 | Store 상태/OperatingGroup/Staff·Session/Role·Permission/과금/RPC/FranchiseAgreement | 일치 | `601710` §3 L141–155; `601717` §5.3 L724–732 및 §6.1·§6.3 L736–791에서 허용 목록 밖/금지 |
| 8 | External Provider Mapping | 일치 | `601710` §3.1 L157–177; `601717` §4.6 L677–695, FO-21 L779 |
| 9 | Store–LegalEntity 시점 관계 | 일치 | `601710` §4 조건부; `601717` §3.4 L447–456, FO-29 L787에서 이번 허용 범위 제외 |

V1에서 허용 파일의 와일드카드 또는 “다음 빈 번호” 표기는 발견되지 않았다.

## V2. Allowed Operations 동사 입도

| # | 조작 ID | narrow 인가 | 근거 |
|---|---|---|---|
| 1 | D-1 | 예 | `owners` → `persons` 테이블 rename으로 고정 (`601717` §1.3 L270) |
| 2 | D-2 | 예 | 역할 테이블 `owner_id` → `person_id` (`601717` L271) |
| 3 | D-3 | 예 | 대표자 테이블 `owner_id` → `person_id` (`601717` L272) |
| 4 | D-4 | 예 | `persons.owner_name` → `person_name` (`601717` L273) |
| 5 | D-5 | 예 | 트리거 이름 양쪽을 고정 (`601717` L274) |
| 6 | D-6 | 예 | 첫 FK 제약명 rename 고정 (`601717` L275) |
| 7 | D-7 | 예 | 둘째 FK 제약명 rename 고정 (`601717` L276) |
| 8 | D-8 | 예 | PK 인덱스 이름 고정 (`601717` L277) |
| 9 | D-9 | 예 | 조회 인덱스 이름 고정 (`601717` L278) |
| 10 | D-10 | 예 | `persons.is_active`만 DROP (`601717` L279) |
| 11 | D-11 | 예 | `chk_lepr_ownership_percent`만 DROP (`601717` L280) |
| 12 | D-12 | 예 | 역할 테이블 `ownership_percent`만 DROP (`601717` L281) |
| 13 | D-13 | 아니오 | `COMMENT ON TABLE persons` 동사는 지정되나 comment literal/허용 문면이 없다 (`601717` L282). `601716` TP-P-23 L375도 “canonical 개념과 어긋나지 않음”이라는 비기계적 기대값만 둔다 |
| 14 | D-14 | 예 | §4.1의 정확한 5컬럼 정의를 참조한 CREATE TABLE (`601717` L298, §4.1 L460–517) |
| 15 | D-15 | 아니오 | `UNIQUE 제약 또는 CREATE UNIQUE INDEX` 두 형태를 모두 허용 (`601717` L299). 반면 `601716` TP-P-29 L391은 `UNIQUE 제약` 존재를 기대한다 |
| 16 | D-16 | 예 | 대상·시점·호출 함수가 고정 (`601717` L300) |
| 17 | D-17 | 예 | 대상과 ENABLE/FORCE 두 동사가 고정 (`601717` L301) |
| 18 | D-18 | 예 | `stores.merchant_account_id`, NULL 허용으로 고정 (`601717` L302, §4.1의 `id uuid`) |
| 19 | D-19 | 예 | FK 양끝과 NO ACTION 동작 고정 (`601717` L303) |
| 20 | D-20 | 예 | 대상 컬럼의 조회 인덱스로 한정 (`601717` L304) |
| 21 | D-21 | 아니오 | `merchant_accounts` 및 신규 컬럼 COMMENT를 허용하지만 literal/허용 문면이 없다 (`601717` L305); 대응 Test ID도 없다 |
| 22 | M-1 | 예 | SQL 전문이 고정 (`601717` §4.5.1 L644–649) |
| 23 | M-2 | 예 | 대상 컬럼·FROM·join key가 고정 (`601717` §4.5 L635–642) |

## V3. TestPlan coverage — I-1~I-51

| 불변조건 | 대응 Test ID | 미검증이면 사유 |
|---|---|---|
| I-1 | TP-P-05 | — |
| I-2 | TP-P-05 | — |
| I-3 | TP-P-06, TP-P-27, TP-P-35 | — |
| I-4 | TP-P-08, TP-R-03 | 트리거 존재·함수 불변으로 간접 검증 |
| I-5 | TP-P-09 | — |
| I-6 | TP-P-10 | — |
| I-7 | TP-P-11 | — |
| I-8 | TP-P-12 | — |
| I-9 | TP-P-02 | — |
| I-10 | TP-P-14, TP-P-33 | — |
| I-11 | TP-N-09~TP-N-11 | — |
| I-12 | TP-P-15, TP-N-14 | — |
| I-13 | TP-P-16 | — |
| I-14 | TP-P-19 | I-36에 의해 `is_active` 부분은 대체됨 (`601713` §1.1 L79) |
| I-15 | TP-P-23 | comment literal이 없어 의미 판단은 비기계적 |
| I-16 | TP-B-03, TP-R-16, TP-RB-01~02 | — |
| I-17 | TP-N-15, TP-N-58 | — |
| I-18 | TP-N-16, TP-N-25~30 | MA에 LE 축을 넣지 않고 기존 Store LE 축을 건드리지 않는 구조적 negative 검증 |
| I-19 | TP-N-16, TP-N-37 | 재무권한 공유 구조를 만들지 않는 negative 검증 |
| I-20 | TP-N-16, TP-N-28 | LE 참조·추론 경로 부재 검증 |
| I-21 | TP-B-04, TP-N-39 | 앱/신규 provisioning 경로 무변경만 검증하며, “같은 브랜드 이유로 동일 Tenant” 오용 자체를 실행 검증하지 않음 |
| I-22 | TP-P-29, TP-N-22, TP-B-04 | DB 1:1과 애플리케이션 우회 미생성을 조합 검증 |
| I-23 | TP-P-37 | — |
| I-24 | TP-P-34, TP-P-37 | 물리 구조로 간접 검증 |
| I-25 | TP-R-11, TP-N-15 | 기존 `stores.tenant_id`·격리 경계 불변으로 검증 |
| I-26 | TP-P-34, TP-R-11 | 개념 의미는 직접 기계 검증 불가; 물리 양축 보존으로 간접 검증 |
| I-27 | TP-D-05~06, TP-N-40~43 | 현재 데이터 충족과 runtime 강제 부재를 각각 기록. enforcement는 C-1/H-1~H-4로 이월 |
| I-28 | TP-N-26~28 | — |
| I-29 | TP-N-26~30 | 이번 범위에서 intake/LE 생성·배정이 전부 없음을 negative 검증 |
| I-30 | TP-N-28 | — |
| I-31 | TP-N-25, TP-N-29~30 | `정확히 1` enforcement를 만들지 않음을 검증 |
| I-32 | TP-R-04, TP-R-11, TP-N-16 | 기존 글로벌 LE 구조 불변 및 MA의 LE 참조 부재로 간접 검증 |
| I-33 | TP-N-29~30 | 시점 구조를 만들지 않는 deferred 상태 검증; 불변조건 자체의 positive 충족은 B-5로 이월 |
| I-34 | TP-P-03~07, TP-P-12~13, TP-P-24 | — |
| I-35 | TP-P-22 | — |
| I-36 | TP-P-17, TP-N-05 | — |
| I-37 | TP-P-20~21, TP-N-06, TP-M-09 | — |
| I-38 | TP-N-16, TP-N-60 | — |
| I-39 | TP-N-17~21, TP-N-60~61 | — |
| I-40 | TP-N-25, TP-N-29~30 | 시점 관계 implementation은 C-2/B-5로 이월된 negative coverage |
| I-41 | TP-N-29~30 | 중첩 방지 구조 자체는 미구현/이월 |
| I-42 | TP-N-25, TP-N-29~30 | 현재 포인터를 권위 원본으로 승격하지 않는 negative coverage |
| I-43 | TP-P-08 | — |
| I-44 | TP-P-18 | — |
| I-45 | TP-N-07, TP-R-03 | — |
| I-46 | TP-N-08 | — |
| I-47 | TP-D-02, TP-D-08 | 검증 시점 상태만 검사; runtime enforcement 부재는 N-1″/H-1로 이월 (`601716` §0.1.1 L85–89) |
| I-48 | TP-D-01, TP-D-07 | 0-Tenant 분기 실행 사례는 현재 기준선이 1행이므로 별도 실행되지 않음 |
| I-49 | TP-P-29, TP-N-22, TP-D-02 | — |
| I-50 | TP-P-25, TP-N-24 | — |
| I-51 | TP-P-33, TP-N-11~14 | — |

### V3-A. X-1~X-11 coverage

| 예외 | 대응 Test ID | 결과 |
|---|---|---|
| X-1 | TP-P-05 | 반영 |
| X-2 | TP-P-06 | 반영 |
| X-3 | TP-P-08, TP-R-02~03 | 반영 |
| X-4 | TP-P-09~11 | 반영 |
| X-5 | TP-P-12 | 반영 |
| X-6 | TP-P-14, TP-P-33 | 반영 |
| X-7 | TP-P-15, TP-N-14, TP-RB-04 | 반영 |
| X-8 | TP-N-09~13, TP-RT-05 | 반영 |
| X-9 | TP-B-06 | 정합화가 B-9로 이월됐고 이번 Stage 8에서 문서군 미변경을 검사 |
| X-10 | TP-B-03, TP-R-16 | 반영 |
| X-11 | PRE-1, TP-M-01~03 | 반영 |

### V3-B. idempotency / rollback / audit / evidence / negative

| 항목 | TestPlan 반영 |
|---|---|
| idempotency/replay | TP-M-08은 동일 DB 재실행이 아니라 clean baseline replay로 한정 (`601716` §9 L644–658) |
| rollback | TP-RB-01~08 (`601716` §11 L697–708) |
| audit | 신규 감사 구조를 만들지 않는 TP-N-35; migration history TP-M-05·TP-R-17 |
| evidence | BL-1~38, TP-M-05, Module A-3 및 이중 검증 요구 |
| 금지 조작 negative | TP-N-01~61, TP-X-01~13, TP-B-01~08, TP-M-09~11 |

## V4. Forbidden Operations 우회 경로

| # | 금지 조항 | 우회 가능성 | 근거 |
|---|---|---|---|
| 1 | `provision_tenant` 수정 | 닫힘 | FO-A가 생성·수정·삭제·재정의를 모두 금지 (`601717` §6.1 L743); TP-N-50/52, TP-M-11 |
| 2 | `create_franchise_store` 수정 | 닫힘 | FO-B와 FO-B1이 부분 교정·phantom 교정까지 금지 (`601717` L744–746); TP-N-51/52/59 |
| 3 | 컬럼 한 줄 추가 | 닫힘 | FO-C가 두 INSERT 목록에 `merchant_account_id` 추가를 직접 금지 (`601717` L746) |
| 4 | 새 함수·트리거로 우회 | 닫힘 | FO-E, FO-15, FO-20; TP-N-54~56, TP-M-11 |
| 5 | 이미 실패하는 RPC를 수정 근거로 사용 | 닫힘 | FO-B1 (`601717` L745), H-3a 이월 (`601717` §4.4.3 L617) |
| 6 | `NOT NULL` 또는 우회 CHECK/trigger | 닫힘 | FO-13; TP-N-40~43 |
| 7 | 검증 도구 수정 | 닫힘 | X-18, FO-36 (`601717` L729, L799); TP-B-04 |
| 8 | tenant ACTIVE 승격 | 계약에는 금지되나 TestPlan이 우회 | FO-33이 금지 (`601717` L791). 그러나 TP-RT-03은 `provision_tenant` 성공 실행을 요구 (`601716` §10 L673), 해당 함수는 `tenant_status='ACTIVE'`를 INSERT (`601721` PRE-7 prosrc, L129 이후 전문). TP-N-58은 tenants 무변경을 동시에 요구 (`601716` L558) |

## V5. C-1 · C-2 이월 판정

| 확인 항목 | 결과 | 근거 |
|---|---|---|
| C-1 장기 요구 존속 | 명시됨 | `601717` §1.5 L313–330, §4.4 L534–538; `601702` §1.26·§1.45 |
| C-2 장기 요구 존속 | 명시됨 | `601717` §1.5 L314–331, §3.1 L407–412; `601702` §1.24·§1.34 |
| `RESOLVED` 표기 | C-1/C-2에 대해 발견되지 않음 | `601717` §1.5 L316–324가 `RESOLVED`가 아님을 직접 명시; `601716` §12.4 L766–787 동일 |
| 현재 계약 상태 | `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` | 양 문서 동일 |

## V6. H-1~H-5 handoff

| 항목 | ChangeContract | TestPlan | 결과 |
|---|---|---|---|
| H-1 | `601717` §4.4.3 L614 | `601716` §12.4 L775 | 유지 |
| H-2 | `601717` L615 | `601716` L776 | 유지 |
| H-3 | `601717` L616 | `601716` L777 | 유지 |
| H-3a | `601717` L617 | `601716` L779 | 추가 이월로 유지 |
| H-4 | `601717` L619 | `601716` L778 | 유지 |
| H-5 | `601717` L618 | `601716` L780, AC-17 L808 | 유지 |

단, `601717` §9.2 L938의 “후속 RPC alignment” 요약은 H-1~H-4만 열거하고 H-5를 생략한다. 본문 handoff 표와 §10.1 L1068, TestPlan AC-17에는 H-5가 남아 있다.

## V7. blocker 처분

| 확인 항목 | 결과 | 근거 |
|---|---|---|
| 구현자 정책 판단을 요구하는 blocker | operative 경계에서는 없음 | §7의 B-5/B-6/B-9/N-2′/N-4′ 및 N-1″/N-3″/N-4″/N-5″가 각각 제외·이월·문면 소관으로 disposition됨 (`601717` §7.2~7.3 L828–845) |
| ChangeContract/TestPlan blocker 표 대응 | 대부분 일치 | `601717` §7.1~7.3 L807–845; `601716` §12.1~12.3 L712–747 |
| N-2″ disposition | 문서 내부 충돌 | 두 문서 모두 해소/확정 표와 “판정하지 않는다” 잔존 문단을 동시에 포함. 상세는 Findings F-3 |
| B-8 disposition | TestPlan 내부 충돌 | PRE-3은 환경 고정, §12.1은 CLOSED이나 §2.2 L330은 “여전히 미해소”라고 기록. 상세는 Findings F-4 |

## V8. 두 문서 간 모순

| 항목 | 대조 결과 | 근거 |
|---|---|---|
| 허용 파일 | 일치 | `601717` §1.1~1.2와 `601716` TP-B-01~08 |
| 허용 migration 수·순서 | 일치 | `0170`/`0171`; `601717` A-1/A-2 및 `601716` TP-B-08, TP-M-04/06 |
| 기준선 tenants/stores | 일치 | 1행/1행; `601716` BL-5/20, `601717` §10.3 |
| stores 컬럼 수 | 일치하는 operative 값과 충돌하는 stale 문단 공존 | before 16/after 17은 일치하나 N-2″ “판정하지 않음” 문단이 양쪽에 남음 |
| RPC md5 | 일치 | `f84ac...` / `87511...`; `601716` BL-35/36, `601717` §0.1.2·V-5 |
| Stage 7 상태 | 일치 | `601716` PRE-1 L252와 `601717` §10 배너 L1000–1056 모두 대기/무효/MUST NOT START |
| UNIQUE 표현 | 불일치 | `601717` D-15는 제약 또는 unique index; `601716` TP-P-29는 UNIQUE 제약 |
| `provision_tenant` runtime test | 금지 조항과 충돌 | `601716` TP-RT-03 vs `601717` FO-33 및 `601716` TP-N-58 |
| `create_franchise_store` 실패 test ID | 상호참조 오류 | `601717` §7.3 N-4″ L844는 TP-RT-03이라 쓰지만 실제 TestPlan은 TP-RT-08 (`601716` L674, L746) |

## V9. Stage 7 선행조건

| 확인 항목 | 결과 | 근거 |
|---|---|---|
| 무효화 배너 | 명확 | `601717` §10 L1000–1048: Stage 6 NOT COMPLETED, Stage 7 NOT EFFECTIVE, Stage 8 MUST NOT START |
| 상태 표 | 배너와 일치 | `601717` L1050–1056: Stage 6/7 대기, Stage 8 MUST NOT START |
| Human 판단 항목 | 9개 pre-decision으로 열거 | `601717` §10.1 L1058–1074; 효력 없음과 승계 방식을 L1060–1062에 명시 |
| 재승인에 필요한 정보 | 제공됨 | 파일, C-1/C-2, H-1~H-5, 컬럼 정의, blocker, 환경, I-47을 항목별 열거 |

본문의 “Stage 7 확정 완료” 표현은 §4.1·§4.5.1·§7의 과거 pre-decision 기록에 남아 있으나, §10 배너는 그 결정값은 보존하되 승인 효력은 없다고 구분한다 (`601717` L1023–1025, L1060–1062).

## V10. Stage 8 착수 차단

| 확인 항목 | 결과 | 근거 |
|---|---|---|
| 구현자 직접 지시 | 배너와 일치 | `601717` §9.3 L945–957 첫 줄이 “Stage 7 미승인…Stage 8 착수하지 않는다” |
| 중단 조건 | 존재 | `601717` §9.3 L959–975 S-1~S-12 |
| Acceptance gate | 존재 | `601717` §9.4 L976–996 |
| Final Rule | 비승인 명시 | `601717` L1199–1205: Human Approval 전 구현 불가 |
| 유효한 “Stage 7 승인 완료” 지시 | 발견되지 않음 | 완료 문구는 pre-decision/개정 이력이며 operative §9.3·§10·Final Rule은 미승인 상태 |

## 종합

| 항목 | 발견 | 그중 blocking |
|---|---:|---:|
| V1 Allowed Files | 0 | 0 |
| V2 Allowed Operations | 3 | 3 |
| V3 TestPlan coverage | 2 | 1 |
| V4 Forbidden Operations | 1 | 1 |
| V5 C-1/C-2 | 0 | 0 |
| V6 Handoff | 1 | 0 |
| V7 blocker 처분 | 2 | 2 |
| V8 문서 모순 | 4 | 4 |
| V9 Stage 7 선행조건 | 0 | 0 |
| V10 Stage 8 차단 | 0 | 0 |

중복 지점을 하나의 finding으로 합산한 고유 Findings는 7건이며, 그중 blocking은 5건이다.

## Findings 목록

| # | 유형 | 지점 | 내용 | blocking |
|---|---|---|---|---|
| F-1 | document conflict | `601717` §1.4 D-15 L299 ↔ `601716` TP-P-29 L391 | 계약은 `UNIQUE` 제약과 `CREATE UNIQUE INDEX`를 모두 허용하지만 TestPlan은 `UNIQUE 제약` 존재를 기대한다. 계약이 허용한 구현이 테스트에서 실패할 수 있다. | 예 |
| F-2 | too broad / missing test | `601717` D-13 L282, D-21 L305 ↔ `601716` TP-P-23 L375 | COMMENT 동사의 대상만 있고 허용 literal이 없다. `persons`는 주관적 의미 검사만 있으며 `merchant_accounts`/신규 컬럼 COMMENT는 대응 Test ID가 없다. | 예 |
| F-3 | document conflict / unresolved blocker | `601717` §7.1 L822 ↔ §7.3 L847–858; `601716` §12.1 L727 ↔ §12.3 L749–758 | N-2″를 양 문서가 “확정/해소”로 기록하면서 같은 문서 뒤에서 “판정하지 않는다/기대값을 상수로 두지 않는다”고 기록한다. 실제 BL-21/PRE-6은 이미 16→17 상수를 사용한다. | 예 |
| F-4 | document conflict / unresolved blocker | `601716` §2.2 L330 ↔ §12.1 L725 및 `601717` §7.1 L820·§10.3 | TestPlan은 B-8이 “여전히 미해소”라고 적지만 같은 문서 blocker 표와 ChangeContract는 기준 환경 확정으로 CLOSED라 기록한다. | 예 |
| F-5 | forbidden leakage / document conflict | `601716` TP-RT-03 L673 ↔ `601717` FO-33 L791, `601716` TP-N-58 L558, `601721` PRE-7 prosrc 전문 | TP-RT-03은 `provision_tenant` 성공 실행을 요구한다. 해당 함수는 `tenant_status='ACTIVE'` tenant를 INSERT하므로 FO-33의 tenant ACTIVE 승격 금지와 TP-N-58의 tenants 불변 기대를 실행 자체가 침범한다. rollback 예외도 TestPlan에 없다. | 예 |
| F-6 | document conflict | `601717` §7.3 N-4″ L844 ↔ `601716` L674·L746 | ChangeContract가 `create_franchise_store` 실패 양상 검사를 TP-RT-03으로 인용하지만 실제 Test ID는 TP-RT-08이다. | 아니오 |
| F-7 | too narrow | `601717` §9.2 L938 ↔ §4.4.3 L614–619·§10.1 L1068 | related-workpacket 요약이 후속 RPC alignment를 H-1~H-4로만 적어 H-5를 생략한다. H-5는 본문 handoff와 pre-decision, TestPlan AC-17에는 보존돼 있다. | 아니오 |

위 표는 발견사항만 기록한다. 이 보고서는 계약을 승인하거나 차단하는 판정문이 아니다.
