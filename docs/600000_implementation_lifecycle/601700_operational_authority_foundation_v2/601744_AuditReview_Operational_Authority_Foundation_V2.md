# 601744_AuditReview_Operational_Authority_Foundation_V2.md

Status: Active
Lifecycle: AuditReview
Last Updated: 2026-08-24

```text
STAGE 11A AUDIT — COMPLETED
Auditor: Claude (Stage 11A)
Date: 2026-08-24
Re-derived from raw evidence per 000701 §13.6.
601740 / 601741 / 601742 / 601743 were NOT used as answer keys —
they were read only after independent findings were locked.
```

> ⚠️ **절별 저자 provenance** — `000701` §13.6
>
> ```text
> Claude Code (Stage 10)   Change ID / Documents Reviewed /
>                          Raw Logs Reviewed / Git Diff Summary
>                          — evidence manifest 4개 절
>
> Claude (Stage 11A)       나머지 18개 절
>                          — raw diff · raw log · 원본 검증자 보고서에서
>                            직접 재도출해 작성
> ```
>
> **Stage 10 초안은 판정을 담지 않았다.**
> 초안이 판정을 담았다면 독립 감사가 확인 감사로 변질됐을 것이다.
>
> **`601740` · `601741` · `601742` · `601743` 은
> 독립 findings 를 잠근 뒤에만 열람했다.**

## Change ID

Workpacket: 601700

```text
구현 범위     0-A v2 Operational Authority Foundation
계약          601717_ChangeContract_Operational_Authority_Foundation_V2.md
승인          정영석, 2026-08-23 (601717 §10.10)
구현 delta    df49eb56..bc4cd14
```

## Documents Reviewed

**repository blob content (LF) 기준 SHA-256.**

| 문서 | 커밋 | SHA-256 |
|---|---|---|
| `601716_TestPlan_…V2.md` | — (Stage 7 고정판) | `00c1376eb1230a4b68f27c1479681c5bc95b23a8801ee70364eaacf22719f102` |
| `601717_ChangeContract_…V2.md` | 승인 기준 `01cfd45b` / 최종 변경 `accf0666` | `ab30aaee0be808cfa8f1df80488ca1d448697f78e02188b2562e9d1cdbd29bcf` |
| `601722_Module_…V2.md` | `1234993b` | `108881805daf5e878f3ae266ff32bea8b2efca0d72bbc4ff2fe5ff1149631f0f` |
| `601739_Evidence_Stage8_Supplemental_FileScope_Pass_Cowork.md` | `614244fa` | `4944b035bb4bcc91fd25a6e13636b73f14c73d891ce5a3c3527b237ca15a8d2d` |
| `601740_VerificationResult_Stage9_…ClaudeCode.md` | `1f9b4428` | `c6db7f519df00c4d51bb50bad36f50b22a7c5f8ee5e7a097f04f293fe60c7248` |
| `601741_MinorOpinion_Stage9_…Cursor.md` | `78a31d34` | `23c0689112f8db9157c299fe4182b5e79243ff5dc3b0cc4c24e0cff6cc27e620` |
| `601742_Report_Stage9_Verification_Integration.md` | `1366d733` | `703792ab30eb3c06f15126590db7139658c84f399147c8ce14341ebefb32abf4` |
| `601743_Verification_…V2.md` | 이 slice 에서 생성 — 미커밋 | — |

**소재 디렉터리**

```text
docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/
```

> ⚠️ **`601742` · `601743` 은 Claude 자신의 통합·목차다.**
> `000701` §13.6 에 따라 **정답지로 사용하지 않는다.**
> 재도출 대상은 `601740` · `601741` · `601739` 원문과 raw 증거다.

## Raw Logs Reviewed

**소재** `docs/implementation_evidence/601700/raw_logs/` — **15건.**

| # | 파일 | blob bytes | worktree bytes | 커밋 | SHA-256 (앞 16) |
|---|---|---|---|---|---|
| 01 | `01_git_diff_stat.txt` | 1057 | 1057 | `1f9b4428` | `7eed8959159f57af` |
| 02 | `02_git_diff_check.txt` | 149 | 149 | `1f9b4428` | `8369c8fc9e003f76` |
| 03 | `03_git_diff_name_only.txt` | 209 | 209 | `1f9b4428` | `f475758d37cb5c61` |
| 04 | `04_git_diff.patch` | 4179 | 4179 | `1f9b4428` | `83e5021da6770b31` |
| 05 | `05_governance_check.log` | 87829 | 88775 | `a2e659cd` | `68739c76e25111b7` |
| 06 | `06_governance_strict.log` | 87814 | 88760 | `a2e659cd` | `59b88be9c86a473f` |
| 07 | `07_db_baseline.log` | 6471 | 6471 | `a2e659cd` | `ec1dacec0901bda0` |
| 08 | `08_schema_positive.log` | 10094 | 10094 | `a2e659cd` | `5a38c87482afc8ea` |
| 09 | `09_negative_checks.log` | 3637 | 3637 | `a2e659cd` | `513cb10d6c2be327` |
| 10 | `10_backfill_checks.log` | 3042 | 3042 | `a2e659cd` | `f14bfcfa3f3cfd6c` |
| 11 | `11_regression.log` | 5736 | 5736 | `a2e659cd` | `2758384ef793e382` |
| 12 | `12_migration_history.log` | 3570 | 3570 | `a2e659cd` | `0ded02836d78f41b` |
| 13 | `13_rls_security.log` | 1976 | 1976 | `a2e659cd` | `265226a21f76038c` |
| 14 | `14_replay.log` | 2098 | 2098 | `a2e659cd` | `9caddd059ac8f1ad` |
| 15 | `15_rollback.log` | 4996 | 4996 | `a2e659cd` | `13968648b1c4f572` |

**SHA-256 은 repository blob(LF) 기준이다.**

> ⚠️ **`05` · `06` 만 blob 과 worktree 바이트가 946 씩 다르다.**
> 두 파일은 PowerShell `Out-File` 산출물이라 worktree 가 **CRLF + BOM** 이고
> blob 은 LF 로 정규화돼 있다. **증거 원형을 보존하려고 변환하지 않았다.**
> **Stage 11 이 이 두 파일을 바이트 대조할 때 이 차이를 먼저 고려해야 한다.**

## Git Diff Summary

```text
base    df49eb56
end     bc4cd14
```

**`git diff --name-status df49eb56..bc4cd14`**

```text
A   sql/migrations/0170_person_vocabulary_normalization.sql
A   sql/migrations/0171_merchant_account_foundation.sql
```

**`git diff --numstat df49eb56..bc4cd14`**

```text
55   0   sql/migrations/0170_person_vocabulary_normalization.sql
68   0   sql/migrations/0171_merchant_account_foundation.sql
```

**`git diff --stat df49eb56..bc4cd14`**

```text
2 files changed, 123 insertions(+)
```

```text
file count       2
insertions       123
deletions        0
신규 파일        2 (A)
수정 파일        0
삭제 파일        0
```

**raw diff 본문** `04_git_diff.patch` (4179 bytes)

> ⚠️ **위 수치는 Claude Code 가 `git` 에서 직접 실측한 것이다.**
> **Stage 11 은 이 요약이 아니라 `04_git_diff.patch` 본문을 읽고 재도출한다**(§13.6).

## Approved Scope Compliance

PASS

```text
implementation delta   df49eb56..bc4cd14d
파일                    2건 — 둘 다 new file mode 100644
                       sql/migrations/0170_person_vocabulary_normalization.sql
                       sql/migrations/0171_merchant_account_foundation.sql
통계                    123 insertions / 0 deletions
git diff --check        clean (exit=0)
```

`601717` §1.1 A-1 · A-2 와 **정확히 일치한다.** 허용 밖 파일 0건.

> `accf0666..bc4cd14d` 넓은 범위에는 문서 커밋이 섞여 있으나
> **implementation delta 는 `df49eb56..bc4cd14d` 다**(01 · 03).

## Master Rule / Context Snapshot Compliance

PASS

```text
Workpacket header   두 파일 모두 첫 행 -- Workpacket: 601700
트랜잭션            BEGIN; … COMMIT; 로 감쌈
인코딩              UTF-8 / BOM 없음 / LF
G15 게이트          migrations checked 4 carry a workpacket header
                    WARN 2건은 0168 · 0169 (workpacket 601500, Stage 7 대기)
                    → 0170 · 0171 은 게이트를 통과했다
```

`601500` 의 WARN 2건은 1차 0-A 이며 `600020` 이 권위를 정지시킨 대역이다.
**이 워크패킷의 신규 실패가 아니다.**

## Logic Compliance

PASS

**조작 전건 재도출**

```text
0170   D-1 ~ D-13     누락 0 / 추가 0 / 순서 일치
0171   D-14 ~ D-21 · M-1 · M-2     동일
executable statements   0170 15 / 0171 15
                        0171 세미콜론 17개 중 2개는 COMMENT literal 내부
```

**물리 객체명 6건 — 각 1회, 계약과 exact**

```text
merchant_accounts_pkey / uq_merchant_accounts_tenant /
fk_merchant_accounts_tenant_id / trg_merchant_accounts_updated_at /
fk_stores_merchant_account_id / idx_stores_merchant_account_id
```

**COMMENT literal 4건 — 계약에 verbatim 존재**

**금지 토큰 14종 전부 0**

```text
CASCADE / DROP TABLE / TRUNCATE / CREATE POLICY / GRANT / REVOKE /
IF EXISTS / IF NOT EXISTS / DO $$ / EXCEPTION / CREATE OR REPLACE /
CREATE UNIQUE INDEX / SET NOT NULL / VALUES
```

`EXECUTE` 1건은 D-16 의 `EXECUTE FUNCTION` 이며 dynamic SQL 이 아니다.

**불변 확인 대상 RPC 4건 — SQL 에 언급 0회, prosrc md5 불변**

```text
provision_tenant         f84ac1a81da4ccba87930bf020a3e974
create_franchise_store   87511a95676a41d2c95866e0c2da8b7f
onboard_tenant           46469f720263a89b9a1c740d1dfe8afb
update_business_hours    147f9f89d3b1d4624efa76ff736dbc6d
```

> ⚠️ **`update_business_hours` 는 호출 금지 목록이 아니라 불변 감시 대상이다.**
> 호출 금지는 `provision_tenant` · `create_franchise_store` · `onboard_tenant`
> 셋이며, `601505` §4 의 7건이 별도로 있다.

**순서 제약**

```text
D-11 < D-12   제약을 먼저 지워 CASCADE 불필요 — §1.39
M-1  < M-2    계정이 먼저 존재
D-18 < D-19
```

**이월 유지**

```text
stores.merchant_account_id   nullable YES / CHECK · trigger 0   → C-1
stores.legal_entity_id       nullable YES / legal_entities 0행   → C-2
```

**`IMPLEMENTATION_DEVIATION_OBSERVED = 0`**

## Test Coverage Review

APPROVE_WITH_NOTES

```text
inventory   236 정의 / 폐기 1(TP-RT-03) / 활성 235
판정        235 전건 — 누락 0
실행        229
SKIP        6 — 전건 사유 기록. PASS 로 추정된 것 없음
```

**SKIP 6건이 타당하다.**

```text
TP-RT-04   앱 빌드·테스트 스위트 미실행
           delta 에 apps / packages / tests 변경 0건
TP-RT-08   create_franchise_store 는 호출 금지 함수
TP-RB-03   disposable baseline 이 canonical 과 상이
TP-RB-08   동상
AC-1       PRE-3·5·6·7 은 pre-implementation 게이트라 post-hoc 관측 불가
AC-13      SPEC_CONFLICT — 아래 Findings F-6
```

## Automated Verification Review

PASS

```text
Check-Governance  default  ERROR 332
                  -StrictStage7  ERROR 334
```

**두 실행 모두 raw log 로 보존됐다**(05 · 06).

증가분 2건은 G15 가 WARN 에서 ERROR 로 승격된 것이며
그 2건은 `0168` · `0169`(`601500`)다.

**`0170` · `0171` 은 어느 모드에서도 G15 에 걸리지 않는다.**

## Minor Opinion Review (Stage 9 (Critical tier), Medium/Full Tier)

**`601741` 의 concern 4건을 전건 명시적으로 처리한다**(`000701` §12.9).

| # | severity | 판정 | 사유 |
|---|---|---|---|
| 1 | MATERIAL_CONCERN | **DISMISSED** | 아래 |
| 2 | INFORMATIONAL | **DISMISSED** | 아래 |
| 3 | INFORMATIONAL | **ACCEPTED** | AC-13 처리가 타당하다는 확인. 동의 |
| 4 | INFORMATIONAL | **ACCEPTED** | DocumentType conflict 는 실재. Findings F-6 |

**Concern #1 — DISMISSED**

```text
주장   601716 git blob SHA-256 = 672ED1D1…DC3, 70223 bytes
       §10.8 기록값 00C1376E…F102 와 불일치

독립 재측정
  git cat-file -s HEAD:<601716 경로>        88800 bytes
  worktree 파일 크기                        88800 bytes
  → blob 과 worktree 의 내용이 동일하다

  cmd /c "git cat-file blob HEAD:<경로> > tmp.bin" 후 Get-FileHash
  → 00C1376EB1230A4B68F27C1479681C5BC95B23A8801EE70364EAACF22719F102
  → §10.8 기록값과 완전 일치
```

**주장한 70223 bytes 는 실제 blob 크기와 다르다.**
내용이 같은데 다른 해시가 나왔다면 측정 파이프라인이 바이트를 변형한 것이다.

**Concern #2 — DISMISSED**

```text
주장   601716 에 skip-worktree 플래그 H 가 설정돼 있다

실측   git ls-files -v docs | grep '^S'   →   0건
       H = cached (정상 추적)
       S = skip-worktree
```

**플래그 오독이며, Concern #1 의 「worktree 와 blob 이 분리돼 있다」는
설명 근거가 여기서 무너진다.**

> ⚠️ **`601741` 을 수정하지 않는다.**
> 검증자의 finding 은 권위가 아니라 evidence 다.
> **오판을 원본 그대로 보존하고 상위 감사에서 재측정으로 기각하는 것이
> 이 체계가 작동하는 방식이다.**

## Raw Error Log Review

PASS

**실패한 명령의 raw 출력이 전부 보존됐다.**

```text
14_replay.log
  [93] 0093_create_message_catalog_complete.sql rc=3
  ERROR: new row for relation "error_codes" violates check constraint "chk_error_domain"
  DETAIL: Failing row contains (5001, category_not_found, MENU, NOT_FOUND, 404, WARNING, …)
```

**실패 사실과 원인이 요약이 아니라 원문으로 남아 있다.**

## Financial Accident Scenario Review

N/A

이 변경은 **금전 이동 로직을 포함하지 않는다.**

```text
결제 / 정산 / ledger / 승인 상태 전이   전부 delta 밖
DDL 과 backfill 2건이 전부
```

`merchant_accounts` 는 SaaS 계약·관리 단위이며 금전 객체가 아니다(`601702` §1.44).

## Idempotency / Duplicate Prevention Review

PASS

```text
uq_merchant_accounts_tenant   UNIQUE (tenant_id) 존재
TP-D-02   missing 0 / dup 0
TP-D-03   orphan 0
```

**동일 DB 재실행 idempotency 는 요구되지 않는다.**
Stage 7 이 B-7 을 `clean baseline replay` 로 한정했다(`601717` §10.2).
`0170` 의 `RENAME` 은 동일 DB 재실행에 적합하지 않으며 그것이 결함이 아니다.

## Timeout / Unknown State Review

N/A

**이 변경에 비동기 · 외부 호출 · 대기 상태가 없다.**

두 migration 모두 단일 트랜잭션 DDL 이며 unknown state 가 발생할 지점이 없다.

## RLS / Permission Review

PASS

```text
5테이블 RLS   ENABLE + FORCE
              persons / legal_entities / legal_entity_person_roles /
              legal_entity_representatives / merchant_accounts
policy        5테이블 합계 0건 — fail-closed baseline

merchant_accounts grants   postgres 만 (테이블 소유자)
authority_owner            nologin + bypassrls 불변
tenants / stores RLS        t / t 불변
```

> ⚠️ **Findings F-7 참조** — `authority_owner` 가 person 4테이블에는
> grants 4건을 갖고 `merchant_accounts` 에는 0건이다.
> **`FO-7` 이 `merchant_accounts` 신규 부여를 명시적으로 금지**했으므로 위반이 아니다.

## Audit Ledger Review

N/A

**이 변경은 audit ledger 이벤트를 발생시키지 않는다.**

DDL 과 backfill 이며 `catchmenu_hq` 의 감사 대상 런타임 경로를 건드리지 않는다.

## Evidence Packet Review

PASS

```text
docs/implementation_evidence/601700/raw_logs/   15건
커밋   1f9b442 (01~04) · a2e659c (05~15)
```

**`000701` §7 이 요구하는 raw log + git diff 인계가 충족됐다.**

11건이 `.gitignore` 의 `*.log` 로 제외되던 것을 예외 규칙으로 추적 대상에 넣었다.

**05 · 06 은 PowerShell 출력이라 CRLF + BOM 이다. 정규화하지 않았다.**
도구 원본 출력을 변형하면 증거가 아니게 된다.

## Rollback Review

PASS

```text
문서화   601717 §9.1 R-1 ~ R-7
실행     disposable container wp601700_replay_verify 에서 검증
         canonical DB 에는 쓰지 않았다

결과
  ma_tbl 0 / owners_tbl 1 / persons_tbl 0 / s_ma_col 0
  → 완전 역전 성공

  owners RLS   t / t 복원
  owners grants 4건 복원
  → R-4 가 지목한 「RLS · GRANT 조합의 비대칭 복원」 위험 해소 확인

  provision_tenant md5   f84ac1a8… 불변
```

**`R-1` 은 rollback 수행 방식을 정한 정책이며 산출물 선행 생성 요구가 아니다.**
`R-7` 이 rollback 판단을 Human 에게 둔다.
**저장소에 역방향 산출물이 없는 것은 위반이 아니라 TP-RB 계열의 evidence gap 이다** — Findings F-5.

## Code Simplicity Review

PASS

```text
방어 코드 0건   IF EXISTS / IF NOT EXISTS / DO $$ / dynamic EXECUTE / EXCEPTION
주석            0170 14 / 0171 11 — 헤더 1 + 조작 식별 주석
설명 산문 주석   0건
```

**baseline 이 예상과 다르면 migration 이 적응하지 않고 실패한다.**
그것이 의도된 설계이며, 방어 코드는 drift 를 감춰 착수 게이트를 무의미하게 만든다.

## Findings

| Severity | Finding | Required Action |
|---|---|---|
| **HIGH** | **F-1** `BL-33` · `TP-R-19` 기대 241 이 **산술적으로 불가능**하다. `D-19` 가 FK 를 만들면 PostgreSQL 이 RI 트리거 2건을 자동 생성한다. 실측 243 = 241 + 2, `RI_ConstraintTrigger_c_65977` · `65978` → `fk_stores_merchant_account_id` 로 귀속 특정. user-visible 트리거는 여전히 1건이며 TP-R-19 의 「backfill 중 트리거 우회 금지」 취지는 충족된다 | **TestPlan 기대값 정정** — Stage 11C / Human |
| **HIGH** | **F-2** `BL-22` · `TP-R-14` 기대 158 을 **4가지 측정법 어느 것도 재현하지 못한다**(전부 151, `pg_depend` 0). delta 에 `CREATE OR REPLACE FUNCTION` 0건이므로 이 구현으로 모집단이 변할 수 없다. 158 은 `601718`/`601719` 의 측정값이며 `601702` §2.2 가 이미 미결로 등재했다 | **158 출처 재조사** — Stage 11C / Human |
| **MEDIUM** | **F-3** `TP-M-07` 이 `0171` 내부 순서를 **과지정**했다. 계약은 `FO-39`(파일 간 순서) 외에 D↔M 상대 순서를 요구하지 않으며 §4.5 는 M-1·M-2 를 형태로만 제한한다. 참조 무결성은 양쪽 순서 모두 성립한다 — NULL 은 FK 검사 대상이 아니다 | **TestPlan 정정 또는 계약 명시** — Stage 11C / Human |
| **MEDIUM** | **F-4** `TP-M-08` clean baseline replay 가 `[93] 0093` `chk_error_domain` 에서 중단한다. canonical 23도메인 / fresh 18도메인, `MENU` 부재. `0170` 78파일 전이며 **이 워크패킷과 무관한 저장소 자체 결함** | **별건 워크패킷** — `0093` replay blocker |
| **LOW** | **F-5** 역방향 migration 산출물이 저장소에 없다. rollback 은 §9.1 R-2/R-3 에서 조립한 DDL 을 disposable DB 에서 실행해 검증했다. `R-1` 은 정책이고 `R-7` 이 판단을 Human 에 두므로 **위반이 아니라 evidence gap** | 이월 — rollback 결정 시 생성 |
| **MEDIUM** | **F-6** `000701` 이 지정한 Stage 9~11 산출물명 셋이 `000002` §1.2 승인 목록 밖이다 — `VerificationResult` · `MinorOpinion` · `AuditReview`. 세 번째 사례가 이 문서 자신이다. **두 상위 규칙의 구조적 불일치** | **`000002` 확장 또는 `000701` 개정** — Stage 11C / Human |
| **LOW** | **F-7** `authority_owner` 가 person 4테이블에 grants 4건, `merchant_accounts` 에 0건이다. **`FO-7` 이 신규 부여를 명시적으로 금지**했으므로 **위반이 아니다.** 다만 sibling 테이블과 비대칭이며, 이 상태에서 `merchant_accounts` 는 어떤 명명 role 로도 도달 불가다 | **0-C 접근 정책 설계 시 필수 검토** |

**두 Stage 9 검증자가 발견하지 못한 것은 F-7 이다.**

## Audit Decision

APPROVE_WITH_NOTES

**`000701` §13.5 Block Criteria 17항목 전건 대조 결과 BLOCK 사유 없음.**

```text
Unauthorized files changed          NO — delta = A-1 · A-2
Implementation deviated             NO — 0건
Money-moving logic ambiguous        N/A
Duplicate prevention missing        NO — uq_merchant_accounts_tenant
Idempotency missing                 NO — clean baseline replay 로 한정됨
RLS / access unsafe                 NO — fail-closed. F-7 은 더 닫힌 방향
Audit ledger event missing          N/A
Evidence packet path missing        NO — raw_logs 15건
Rollback impossible or undocumented NO — §9.1 문서화 + disposable DB 실행 성공
Raw logs missing for failed cmds    NO — 14_replay.log
Git diff missing                    NO
MinorOpinion concern unaddressed    NO — 4건 전건 명시적 처리
Unknown status without evidence     N/A — Timeout / Unknown State Review
Tests do not cover required cases   NO — Test Coverage Review. SKIP 6건 전건 사유 기록
Code too broad or too abstract      NO — Code Simplicity Review
Conflicts with ImpactScope master   NO — Master Rule / Context Snapshot Compliance
Verification failed                 아래 별도 해석
```

**「Verification failed」 해석**

```text
구현 검증이 실패한 것이 아니다.

FAIL 8건의 귀속
  F-1 · F-2   TestPlan 기대값 자체의 결함
  F-3         TestPlan 의 과지정
  F-4         이 워크패킷 이전부터 있던 저장소 상태
  AC-7 · AC-9 위 넷의 파생

0170 · 0171 의 계약 위반에서 비롯된 FAIL   0건
```

**산술적으로 불가능한 기대값 때문에 정확한 구현을 BLOCK 하는 것은
이 기준이 의도한 바가 아니다.**

> ⚠️ **`000701` §13.7 Dual Anchor Principle 에 따라
> 이 문서만으로 Stage 12 병합 결정의 충분한 근거가 되지 않는다.**
>
> **Stage 11B(ChatGPT Blind Audit)와 Stage 11C(Conflict Analysis)가 남아 있다.**

## Required Human Review Notes

**Stage 11C 에서 판정해야 할 것**

| # | 항목 | 선택지 |
|---|---|---|
| H-1 | **F-1** 트리거 총계 | TestPlan 기대값 241 → 243 정정 / 또는 RI 트리거를 계수에서 제외하도록 검사 재정의 |
| H-2 | **F-2** 함수 모집단 158 | 158 출처 재조사 / `601702` §2.2 와 함께 처리 / TestPlan 기대값 151 정정 |
| H-3 | **F-3** `TP-M-07` 순서 | TestPlan 정정 / 계약에 순서 명시 / 양쪽 유효로 검사 완화 |
| H-4 | **F-4** `0093` replay blocker | 별건 워크패킷 개설 / `TP-M-08` 을 이 나선에서 요구할 것인가 |
| H-5 | **F-6** DocumentType | `000002` §1.2 승인 목록 확장 / `000701` 산출물명 변경 |
| H-6 | **F-7** grant 비대칭 | 0-C 접근 정책에서 다룰 것을 확인 |
| H-7 | `601742` §5 I-1~I-7 | 위와 중복되지 않는 잔여 항목 |

> ⚠️ **`601717` §10.1 Human pre-decision 9건은 재논쟁 대상이 아니다.**
> **C-1 · C-2 는 `DEFERRED — INELIGIBLE` 로 유지된다.**

**Stage 11B 로 넘길 것**

```text
1단계 — 설계문서를 보여주지 않는다
  0170 · 0171 실제 SQL
  raw_logs 15건
  live 스키마 · 트리거 · RPC 정의

  프레임: "이 시스템이 무슨 구조인지, 어떤 상태머신을 가정하는지,
           경계는 어디인지, 어떤 위험이 있는지 처음부터 역설계해주세요"

2단계 — 그 다음에만
  601710 / 601713 / 601716 / 601717 / 이 문서

  프레임: "이게 Claude의 설계와 감사 결과입니다.
           당신이 역설계한 것과 차이가 있는지 찾아주세요"
```

**반드시 사전 맥락이 없는 새 대화창에서 진행한다**(`000701` §13.8).
**기존 대화창을 재사용하면 Stage 11B 는 무효다.**
