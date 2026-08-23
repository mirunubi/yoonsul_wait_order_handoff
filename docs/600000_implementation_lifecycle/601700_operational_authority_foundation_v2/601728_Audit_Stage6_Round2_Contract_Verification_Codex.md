# 601728_Audit_Stage6_Round2_Contract_Verification_Codex.md

> ⚠️ **Stage 6 Round 2 Contract Verification · Eyes-Only · 판정문이 아니다**
>
> 1차 findings 반영본에 대한 2차 독립 검증이다.
>
> ⚠️ **두 라운드 연속 검증자 결론이 갈렸다.**
>
> ```text
> Round 1   Cursor blocking 0 / Codex blocking 5
> Round 2   Cursor blocking 0 / Codex blocking 5
> ```
>
> Claude 통합 결과 Round 2 에서도 **Codex 의 5건을 blocking 으로 채택**했고,
> 그중 R2-F1 은 1차 수정이 인접 조항에 잔존을 남긴 사례였다.
>
> 검증자 특성 분석은 `601717` §7.4 에 있다.
> **이 관찰을 검증자 제거 근거로 사용하지 않는다**(`000701` §38.4).
>
> 수행: Codex, 2026-08-23.

> **Eyes-Only 독립 계약 검증 결과**
>
> 대상: `601716_TestPlan_Operational_Authority_Foundation_V2.md`,
> `601717_ChangeContract_Operational_Authority_Foundation_V2.md` 개정본.
>
> 이 보고서는 계약을 승인하거나 차단하는 판정문이 아니다. 발견사항만 기록한다.
> 대상 문서와 상대 검증 결과는 수정하지 않았다.

## 검증 범위와 방법

| 항목 | 내용 |
|---|---|
| 검증자 | Codex, Verifier B |
| 원작자 제외 | Stage 5 원작자 Claude Code 제외 (`000701` §37) |
| 대상 | `601716` 10판, `601717` 10판 |
| Authority 대조 | `601702`, `601705`, `601710`, `601713` |
| Evidence 대조 | `601718`~`601721`, `601725`, `601726` |
| 상대 결과 | 읽지 않음 |
| 변경 | 이 결과 파일 1개 생성만 수행 |

## V1. Allowed Files 경계

| # | 항목 | 판정 | 근거 위치 |
|---|---|---|---|
| 1 | SQL 파일 A-1/A-2 | 일치 | `601717` §1.1 L241–248: `0170_person_vocabulary_normalization.sql`, `0171_merchant_account_foundation.sql` 두 개만 허용 |
| 2 | Module A-3 | 일치 | `601717` §1.2 L254, L259–263: `601722_Module_Operational_Authority_Foundation_V2.md`로 확정, 와일드카드 및 다음 빈 번호 지시 폐기 |
| 3 | 문서 동기화 A-4~A-6 | 일치 | `601717` §1.2 L255–257; `601716` TP-B-01·02·06 L648–655 |
| 4 | `601710` §3 Out of Scope | 일치 | `601717` §5.3 L792–800, §6.3 L847–859; `601716` §14 L910–931 |
| 5 | 구현 허용 파일과 TestPlan 경계 | 일치 | `601716` TP-B-01~08 L648–655 ↔ `601717` §1.1~§1.2 |

## V2. Allowed Operations 동사 입도

| # | 조작 ID | narrow 인가 | 근거 |
|---|---|---|---|
| 1 | D-1~D-13 | 예 | `601717` §1.3 L269–283: 대상·조작·이름을 개별 고정 |
| 2 | D-14 | 예 | `601717` §1.4 L299: 확정 5컬럼 정의로 제한 |
| 3 | D-15 | 예 | `601717` §1.4 L300: `ADD CONSTRAINT … UNIQUE`, 제약명까지 고정하고 unique index 단독 형태 제외 |
| 4 | D-16~D-20 | 예 | `601717` §1.4 L301–305: 대상과 조작 고정 |
| 5 | D-21 | **아니오 — column COMMENT literal 미확정** | `601717` §1.4 L306은 table COMMENT만 literal을 제공하고 두 column COMMENT는 “참조 관계를 서술”한다고만 적음. `601716` TP-P-38 L403은 D-21 literal과 문자열 동일을 요구 |
| 6 | §1.6 허용 동사 요약 | **too broad** | `601717` §1.6 L345에 `CREATE UNIQUE INDEX`가 여전히 허용 동사로 남음. D-15 L300은 그 형태를 명시적으로 제외함 |

## V3. TestPlan coverage — I-1~I-51

| 불변조건 | 대응 Test ID | 미검증이면 사유 |
|---|---|---|
| I-1 | TP-P-05 | |
| I-2 | TP-P-05 | |
| I-3 | TP-P-06, TP-P-27, TP-P-35 | |
| I-4 | TP-P-08 | 트리거 존재·호출관계만 확인. 실제 UPDATE 동작은 `601716` §12.5 L874의 유지 판정으로 범위 밖 |
| I-5 | TP-P-09 | |
| I-6 | TP-P-10 | |
| I-7 | TP-P-11 | |
| I-8 | TP-P-12 | |
| I-9 | TP-P-02, TP-P-13 | |
| I-10 | TP-P-14, TP-P-33 | |
| I-11 | TP-N-09~11 | |
| I-12 | TP-P-15, TP-N-14 | |
| I-13 | TP-P-16 | |
| I-14 | TP-P-19 | I-36으로 대체된 상태를 검사 |
| I-15 | TP-P-23 | |
| I-16 | TP-B-03, TP-M-09~10 | |
| I-17 | TP-N-15, TP-R-05 | |
| I-18 | 명시 Test ID 없음 | `601716` §12.5 L873이 schema/backfill 범위 밖 유지로 처분 |
| I-19 | 명시 Test ID 없음 | 동일 |
| I-20 | TP-N-16 | LegalEntity 참조 0건으로 확인 |
| I-21 | 명시 Test ID 없음 | `601716` §12.5 L873 유지 처분 |
| I-22 | 명시 Test ID 없음 | 동일 |
| I-23 | TP-P-37, TP-N-25 | |
| I-24 | TP-N-22, TP-N-40 | 역참조·선행 강제 부재로 확인 |
| I-25 | 명시 Test ID 없음 | `601716` §12.5 L873 유지 처분 |
| I-26 | 명시 Test ID 없음 | 동일 |
| I-27 | TP-D-05~06, TP-N-40~43 | 현재 backfill과 enforcement 이월을 검사 |
| I-28 | TP-N-26~27 | |
| I-29 | TP-N-27~28 | 미검증 identity를 사용한 배정 부재로 확인 |
| I-30 | TP-N-28 | |
| I-31 | 명시 Test ID 없음 | `601716` §12.5 L873 유지 처분 |
| I-32 | 명시 Test ID 없음 | 동일 |
| I-33 | TP-N-29 | 이번 나선에서 시점 구조를 만들지 않았음을 확인 |
| I-34 | TP-P-03~04, TP-P-07, TP-N-03 | |
| I-35 | TP-P-22 | |
| I-36 | TP-P-17, TP-N-05 | |
| I-37 | TP-P-20~21, TP-N-06, TP-M-09 | |
| I-38 | TP-N-16 | |
| I-39 | TP-N-17~21, TP-N-60~61 | |
| I-40 | TP-N-25, TP-N-29 | enforcement·시점 구조가 이번 범위에서 생성되지 않음을 확인 |
| I-41 | TP-N-29 | |
| I-42 | TP-N-30 | 현 포인터를 변경하지 않음을 확인 |
| I-43 | TP-P-08 | |
| I-44 | TP-P-18 | |
| I-45 | TP-N-07, TP-R-03 | |
| I-46 | TP-N-08, TP-N-12 | |
| I-47 | TP-D-02, TP-D-08 | 검증 시점 상태만 확인; 강제 부재는 N-1″ 이월 |
| I-48 | TP-D-01, TP-D-07 | |
| I-49 | TP-P-29, TP-N-22 | |
| I-50 | TP-P-25, TP-N-24 | |
| I-51 | TP-P-33, TP-N-11~13 | |

### V3-a. X-1~X-11, idempotency, rollback, audit/evidence, negative coverage

| 항목 | 반영 | 근거 |
|---|---|---|
| X-1~X-8 | 반영 | TP-P-05~15, TP-N-09~14 (`601716` §4.1·§5.2) |
| X-9 | 부분 반영 | TP-B-06은 27~30건 문서 미변경과 별도 정합화 이월을 검사 (`601716` L653, §12.2 B-9 L784) |
| X-10 | 반영 | TP-B-03, TP-M-09~10 |
| X-11 | 반영 | PRE-1, TP-M-01~03; 현재 Stage 7은 대기 (`601716` L253, `601717` L1117–1173) |
| idempotency/replay | 반영 | clean baseline replay만 요구하는 TP-M-08 (`601716` L668–682) |
| rollback | 반영 | TP-RB-01~08 (`601716` §11 L745–756) |
| audit/evidence | 반영 | migration history TP-M-05, TP-R-16~17 및 이중 검증 요구 |
| 금지 조작 negative | 반영 | TP-N, TP-B, TP-M 전반 |

## V4. Forbidden Operations 우회 경로

| # | 금지 조항 | 우회 가능성 | 근거 |
|---|---|---|---|
| 1 | 두 INSERT RPC 부분 수정 | 닫힘 | `601717` §6.1 FO-A/FO-B/FO-B1 및 §9.3 L1070–1071; `601716` TP-N-50~53, TP-M-11 |
| 2 | `create_franchise_store` phantom 한 줄 교정 | 닫힘 | `601717` FO-B1 L813, S-8 L1087; H-3a 이월 |
| 3 | 신규 우회 function/trigger | 닫힘 | `601717` FO-15, FO-E, FO-20; `601716` TP-N-54~56, TP-M-11 |
| 4 | 검증 도구 수정 | 닫힘 | `601717` FO-36 L867; `601716` TP-B-04 L651 |
| 5 | `SET NOT NULL` 우회 CHECK/trigger | 닫힘 | `601717` FO-13; `601716` TP-N-40~43 |
| 6 | D-15의 unique-index 우회 | **문서 내부에서 다시 열림** | D-15는 unique index 단독 형태를 제외하지만 `601717` §1.6 L345가 `CREATE UNIQUE INDEX`를 허용 동사로 열거 |

## V5. C-1 · C-2 이월 판정

| 확인 | 결과 | 근거 |
|---|---|---|
| C-1 상태 | `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` | `601717` §1.5 L314, §4.4 L537, §10.1 L1184 |
| C-2 상태 | 동일 | `601717` §1.5 L315, §10.1 L1184 |
| `RESOLVED` 기록 | 없음; 금지 경고 존재 | `601717` L317–325, `601716` §12.4 L838–843 |
| §1.24/§1.34 요구 | 살아 있음 | `601717` §1.5 L332, `601716` C-2 L830 |
| §1.26/§1.45 요구 | 살아 있음 | `601717` §1.5 L331, §4.4 L539, `601716` C-1 L829 |

## V6. H-1~H-5 handoff

| 항목 | 기록 | 축소 여부 |
|---|---|---|
| H-1 | `601717` §4.4.3 L674, `601716` §12.4 L831 | 본문 존재 |
| H-2 | `601717` L675, `601716` L832 | 본문 존재 |
| H-3 | `601717` L676, `601716` L833 | 본문 존재 |
| H-3a | `601717` L677, `601716` L835 | 본문 존재하나 Acceptance Criteria 요약에서 누락 |
| H-4 | `601717` L679, `601716` L834 | 본문 존재 |
| H-5 | `601717` L678, `601716` L836 | 본문 및 별도 AC 존재 |

## V7. Blocker 처분

| # | 확인 | 결과 | 근거 |
|---|---|---|---|
| 1 | `601717` §7과 `601716` §12의 N-6″ | 일치 | `601717` L914 ↔ `601716` L796 |
| 2 | N-7″ | 일치 | `601717` L915 ↔ `601716` L797 |
| 3 | N-8″ | 사실 내용 일치 | `601717` L916 ↔ `601716` L798. 단 `601717`의 evidence citation `601725 §-4`는 유효한 절 표기가 아님 |
| 4 | 구현자 신규 정책 판단 차단 | 대체로 닫힘 | FO-A~E, FO-B1 및 S-8이 RPC 교정을 금지 (`601717` §6.1, §9.3) |
| 5 | H-1 prerequisite | **불완전** | `601717` L684–690은 N-6″ 세 phantom만 prerequisite로 삼음. 같은 함수가 이후 `store_type='RESTAURANT'`로 N-8″에 걸리므로 정상 producer transaction의 end-to-end 검증 선행조건을 모두 닫지 못함 |

## V8. `601716` ↔ `601717` 모순

| # | 항목 | 결과 | 근거 |
|---|---|---|---|
| 1 | 허용 파일 | 일치 | `601717` §1.1~1.2 ↔ `601716` TP-B-01~08 |
| 2 | 허용 조작 | **부분 모순** | `601717` D-15 L300은 unique index 단독 제외, 같은 문서 §1.6 L345는 `CREATE UNIQUE INDEX` 허용 |
| 3 | COMMENT 검사 | **판정값 부족** | `601716` TP-P-38 L403은 exact literal을 요구하지만 `601717` D-21 L306은 column literal을 제공하지 않음 |
| 4 | Stage 7 상태 | 일치 | `601716` PRE-1 L253; `601717` §10 L1117–1173: 대기/MUST NOT START |
| 5 | 기준선 md5 | 일치 | `601716` BL-35·36 L308–309, TP-N-50·51 L535–536 |
| 6 | 기준선 rows/columns | 일치 | `601716` PRE-5·6 L257–259, BL-20·21 L293–295 |
| 7 | C-1/C-2 | 일치 | 양쪽 모두 DEFERRED/INELIGIBLE |

## V9. Stage 7 선행조건

| 확인 | 결과 | 근거 |
|---|---|---|
| Human 판단 항목 | §10.1에 9개 pre-decision으로 보존 | `601717` L1175–1191 |
| 현재 효력 | Stage 7 `NOT EFFECTIVE`; Stage 6 findings 반영 중 | `601717` L1117–1126, L1170–1173 |
| 배너와 상태표 | 일치 | 무효화 배너 및 단계표 모두 Stage 8 금지 |
| TestPlan 전제 | 일치 | `601716` PRE-1 L253은 현재 대기 및 착수 금지 명시 |

## V10. Stage 8 착수 차단

| 확인 | 결과 | 근거 |
|---|---|---|
| 구현자 직접 지시 | Stage 7 미승인, Stage 8 착수 금지 | `601717` §9.3 L1062–1074 |
| Stop Conditions | 범위 확대·RPC 수정·NOT NULL 요구 시 중단 | `601717` L1076–1091 |
| 잘못된 승인 완료 표현 | 효력 있는 지시에는 없음 | 과거 pre-decision은 무효화 배너 아래 보존됨 |
| 문서 상태 | Stage 6 findings 반영 중, Stage 7 대기 | `601717` L1170–1173 |

## V11. C-1 사유 교체의 정합성

| 확인 | 결과 | 근거 |
|---|---|---|
| 종전 사유 보존 | 보존되고 `철회`로 명시 | `601717` §4.4.1.2 L592–603 |
| 새 사유와 실측 | 일치 | phantom 3개, tenants INSERT 선행: `601717` L607–616 ↔ `601725`/`601726` |
| old/new 유효성 구분 | 명확 | §4.4.1.1 종전 결론도 L645–647에서 철회 대상으로 재지정 |
| 판정 유지 | DEFERRED 유지 | `601717` L605, L625–627 |
| 장기 invariant | 살아 있음 | `601717` §1.5 L317–332; `601716` §12.4 L827–843 |

## V12. 폐기 항목의 대체 적정성

| 확인 | 결과 | 근거 |
|---|---|---|
| TP-RT-03 폐기 사유 | 명확 | `601716` §10 L697, L704–724: ACTIVE 승격 금지와 phantom 실패 |
| TP-N-62 | 본문 md5 불변을 검사 | `601716` L570; TP-N-50과 중복·연동 |
| TP-N-63 | 호출 0건을 요구 | `601716` L571 |
| TP-N-64 | tenants 데이터 불변을 요구 | `601716` L572; TP-N-58과 중복 |
| runtime 성공성 검증 | 후속 나선으로 명시 이월 | `601716` L574–582, §12.4 |
| 대체 항목의 판정 가능성 | **TP-N-63은 증거 방법이 없음** | 실패 호출은 DB 상태에 흔적을 남기지 않을 수 있는데 TestPlan은 호출 로그·trace·실행 통제 증거를 지정하지 않음. AC-5 L891은 §5 전항목 PASS를 요구 |

## V13. 신규 blocker의 처분

| blocker | 새 정책을 구현자에게 맡기는가 | 처분 근거 |
|---|---|---|
| N-6″ | 아니오 | FO-A로 수정 금지, 후속 alignment 이월 (`601717` L914) |
| N-7″ | 아니오 | FO-D로 수정 금지 (`601717` L915) |
| N-8″ | 아니오 | 후속 alignment로 유지 (`601717` L916) |
| H-1 prerequisite | **완전히 닫히지 않음** | N-6″만 명시 (`601717` L684–690). N-8″가 같은 `provision_tenant`의 후속 Store INSERT를 막는다는 자체 기록(L916)이 prerequisite에 연결되지 않음 |

## V14. 개정이 만든 새 모순

| # | 지점 | 결과 | 근거 |
|---|---|---|---|
| 1 | D-15 ↔ §1.6 | 새/잔존 모순 | `601717` L300 vs L345 |
| 2 | D-21 ↔ TP-P-38 | 기대값 미정 | `601717` L306 vs `601716` L403 |
| 3 | TP-RT-03 철회 병기 | 모호하지 않음 | 취소선 행, 폐기 배너, 대체 항목이 명시됨 (`601716` L697, L704–724) |
| 4 | N-2″ 철회 병기 | 모호하지 않음 | 이전 문단 뒤에 효력 철회 및 현재 상수 명시 (`601716` L800–814; `601717` L918–938) |
| 5 | Revision summary 범위 | outdated | `601716` §0.3 L190–193은 TP-P-01~37/TP-N-01~61을 “동일”이라 기록하지만 현재 TP-P-38과 TP-N-62~64가 추가됨 |
| 6 | Acceptance Criteria backfill | TP-D-09 누락 | `601716` AC-4 L890은 TP-D-01~08만 필수 PASS로 묶지만 TP-D-09는 L430에 존재 |
| 7 | Acceptance Criteria handoff | H-3a 누락 | `601716` AC-12 L898 및 `601717` AC-10 L1108은 H-1~H-4만 열거. H-5는 별도 AC로 보완되지만 H-3a는 명시 AC에서 빠짐 |
| 8 | N-8″ citation | 잘못된 위치 표기 | `601717` L916의 `601725 §-4`는 유효 절 번호가 아님 |

## 종합

| 항목 | 발견 | 그중 blocking |
|---|---:|---:|
| V1 Allowed Files | 0 | 0 |
| V2 Allowed Operations | 2 | 2 |
| V3 TestPlan coverage | 1 | 1 |
| V4 Forbidden leakage | 1 | 1 |
| V5 C-1/C-2 | 0 | 0 |
| V6 Handoff | 1 | 1 |
| V7 Blocker disposition | 2 | 1 |
| V8 문서 간 모순 | 2 | 2 |
| V9 Stage 7 prerequisite | 0 | 0 |
| V10 Stage 8 차단 | 0 | 0 |
| V11 C-1 사유 교체 | 0 | 0 |
| V12 폐기 대체 | 1 | 1 |
| V13 신규 blocker | 1 | 1 |
| V14 새 모순 | 5 | 3 |

중복 항목을 하나의 finding으로 합치면 **고유 findings 7건, 그중 Stage 7 전에 해소가 필요한 항목 5건**이다.

## Findings 목록

| # | 유형 | 지점 | 내용 | blocking |
|---|---|---|---|---|
| R2-F1 | forbidden leakage / document conflict | `601717` §1.4 D-15 L300 ↔ §1.6 L345 | D-15가 제외한 `CREATE UNIQUE INDEX`가 허용 동사 목록에 남아 있다 | YES |
| R2-F2 | too broad / missing test oracle | `601717` §1.4 D-21 L306 ↔ `601716` TP-P-38 L403 | 두 column COMMENT의 exact literal이 없어서 문자열 동일 검사의 기대값이 완성되지 않는다 | YES |
| R2-F3 | missing test | `601716` TP-N-63 L571, AC-5 L891 | “검증 과정에서 함수 호출 0건”을 증명할 관측원·로그·trace 방법이 지정되지 않았다 | YES |
| R2-F4 | unresolved blocker / too narrow | `601717` §4.4.3 L684–690, §7.3 N-8″ L916 | H-1 prerequisite가 N-6″만 연결하고 같은 함수의 후속 Store INSERT를 막는 N-8″를 연결하지 않는다 | YES |
| R2-F5 | missing acceptance coverage | `601716` AC-4 L890, AC-12 L898; `601717` AC-10 L1108 | TP-D-09와 H-3a가 최종 Acceptance Criteria의 필수 목록에서 빠져 있다. H-5는 별도 AC로 보완됨 | YES |
| R2-F6 | document conflict | `601716` §0.3 L190–193 | 현 10판에 TP-P-38·TP-N-62~64가 있는데 재도출 요약은 TP-P-01~37·TP-N-01~61만 기록한다 | NO |
| R2-F7 | invariant mismatch / citation | `601717` §7.3 N-8″ L916 | evidence 위치가 `601725 §-4`로 표기돼 검증 가능한 절 인용이 아니다 | NO |

## 명시적 결과

`NO CONCERNS FOUND`가 아니다. 위 7개 findings를 기록한다.

이 문서는 승인 또는 차단 판정을 내리지 않는다. `blocking=YES`는 사용자 정의에 따라
Stage 7 진입 전에 해소해야 하는 발견사항이라는 분류만 뜻한다.
