# 601746_Report_Stage11C_Conflict_Analysis.md

Status: Active
Lifecycle: Report
Last Updated: 2026-08-24

## Change ID

Workpacket: 601700

## §0 이 문서의 지위

`000701` §13.9 Stage 11C — **Human Conflict Analysis**.

```text
Stage 11A   601744   Claude 감사          APPROVE_WITH_NOTES
Stage 11B   601745   ChatGPT 블라인드 감사  Critical 1건 발견
Stage 11C   이 문서   Human 대조 · 처분
```

> ⚠️ **`000701` §13.7 Dual Anchor Principle**
>
> Stage 11A 단독으로는 Stage 12 병합 결정의 충분한 근거가 아니다.
> **PASS/PASS 일치 자체는 약한 증거이며, 불일치 지점을 최우선으로 본다.**

**판정자** — 정영석, 2026-08-24

## §1 Stage 11B 가 실증한 것

**Stage 11A 가 놓친 Critical 1건을 블라인드 역설계가 찾았다.**

```text
놓친 주체   Cursor / Codex / Cowork / Claude Code / Claude(Stage 11A)
찾은 주체   ChatGPT (사전 맥락 없는 신규 대화)
```

**`000701` §13.7 이 이론으로 적어둔 anchoring 을 실제 사례로 확인했다.**

### §1.1 더 중요한 관측 — 검증 층위의 공백

```text
Stage 6       계약이 설계문서와 맞는가            5라운드
Stage 9 · 11A 구현이 계약과 맞는가                235건 전건
Stage 11B     이 전체가 업무 불변조건을
              실제로 구현하는가                  ← 여기서 D-1 발견
```

**D-1 의 공백은 `601705` · `601710` · `601713` 에 처음부터 있었다.**

```text
Logic 이 tenant isolation 을 불변조건으로 선언
설계가 단일 컬럼 FK 를 지정
그 둘이 어긋나는데 Stage 2~6 이 잡지 못했다
```

**내부 정합성은 5라운드를 봤으나 외부 타당성은 아무도 묻지 않았다.**

```text
「계약이 설계와 일치하는가」        계속 물었다
「설계가 선언을 실제로 구현하는가」  묻지 않았다
```

> ⚠️ **이것은 `000701` 개선 대상이다.**
> 블라인드 역설계를 감사 시점이 아니라 **설계 확정 전**에 넣어야 한다.
> **0-A 종료 후 별건으로 처리한다. 진행 중인 나선을 흔들지 않는다.**

## §2 처분 — 10건

### §2.1 D-1 — Store ↔ MerchantAccount tenant 경계 미강제

```text
Disposition   ACCEPTED — DEFERRED WITH HARD PRECONDITION
신규 식별자    C-3
```

**사실**

```text
FK 가 검증하는 것      stores.merchant_account_id → merchant_accounts.id
검증하지 않는 것       stores.tenant_id = merchant_accounts.tenant_id

→ tenant A 의 Store 가 tenant B 의 MerchantAccount 를 참조해도 FK 통과
```

**판정 근거**

```text
1  D-1 은 실제 구조적 invariant gap 이다
2  승인된 ChangeContract 를 Codex 가 잘못 구현한 것은 아니다
   D-19 가 단일 컬럼 FK 를 지정했고 구현은 그대로 했다
3  현재 승인된 application/runtime producer 중
   stores.merchant_account_id 를 공급하는 경로가 없다
4  M-2 backfill 은 ma.tenant_id = s.tenant_id 조건으로 수행돼
   existing data mismatch 가 없다
5  따라서 현재 운영 상태에서 즉시 노출되는 application defect 로 보지 않는다
6  그러나 H-2 · H-3 가 merchant_account_id 공급을 시작하면
   DB-level tenant-match enforcement 부재가 실제 위험으로 전환된다
7  그러므로 D-1 해소는 H-2 · H-3 의 HARD ENTRY CONDITION 이다
```

> ⚠️ **「현재 발현 경로 0개」라고 쓰지 않는다.**
>
> **「현재 승인된 application/runtime producer path 에서는
> 발현 경로가 확인되지 않는다」가 정확하다.**
>
> superuser · 수동 SQL · 향후 migration 같은 **privileged path 까지
> 0 이라고 단정하지 않는다.**

**C-3 등록**

```text
C-3   Store ↔ MerchantAccount tenant-consistency enforcement
      DEFERRED — REQUIRED BEFORE H-2 / H-3
```

**금지**

```text
D-1 미해결 상태에서
H-2 · H-3 또는 다른 runtime Store→MerchantAccount binding 구현 착수
```

**권장 방향 — 후속 나선이 결정한다**

```text
merchant_accounts 에 UNIQUE (id, tenant_id)
stores (merchant_account_id, tenant_id) → merchant_accounts (id, tenant_id)
```

**이것은 새 설계 결정이다.** 필요한 UNIQUE·제약명, nullable 상태에서의 의미,
provisioning 순서를 새로 정해야 한다. **Stage 7 계약을 몰래 보강할 문제가 아니다.**

### §2.2 MerchantAccount 1:1 COMMENT 의미 과장

```text
Disposition   ACCEPTED — DEFERRED, BUNDLED WITH C-3
```

**사실**

```text
literal   "Owning tenant. NOT NULL and UNIQUE;
           this column alone enforces the 1:1 relationship."

실제
  merchant_accounts.tenant_id NOT NULL
    → 각 MerchantAccount 는 반드시 한 Tenant 에 속함
  UNIQUE(tenant_id)
    → 한 Tenant 에 MerchantAccount 가 최대 하나
  강제하지 않는 것
    → 모든 Tenant 가 반드시 MerchantAccount 를 가져야 함
```

**total 1:1 로 읽히면 과장된 COMMENT 다.**

**이 COMMENT 는 DB 스키마에 영구히 새겨져 `psql \d+` 로 계속 노출된다.**

**처분 근거**

```text
지금 고치지 않는다
  D-1 이라는 더 중요한 구조적 문제는 그대로 둔 채
  설명문 하나만 forward migration 으로 고치는 것은 균형이 맞지 않는다

C-3 후속에서
  tenant consistency constraint
  + MerchantAccount cardinality COMMENT 정정
  을 함께 처리한다
```

**현재 0-A 를 재개방하지 않는다.**

### §2.3 TP-M-07 ordering expectation

```text
Disposition   DISMISSED — TESTPLAN OVER-SPECIFICATION
```

```text
TP-M-07 기대   테이블 생성 → M-1 → stores 컬럼·FK·인덱스 → M-2
실제 구현      D-14~D-21 → M-1 → M-2

계약           FO-39(파일 간 순서) 외에 0171 내부 D↔M 상대 순서 요구 없음
               §4.5 는 M-1 · M-2 를 형태로만 제한
참조 무결성     양쪽 순서 모두 성립 — NULL 은 FK 검사 대상이 아니다
```

**Stage 11A · 11B 가 독립적으로 같은 결론에 도달했다.**

**TestPlan 이 유효한 순서 하나를 유일한 것으로 과지정했다.**

### §2.4 트리거 총계 241 → 243

```text
Disposition   ACCEPTED — TESTPLAN ARITHMETIC ERROR
Required      TestPlan 기대값 정정 — 후속
```

```text
D-19 가 FK 를 만들면 PostgreSQL 이 RI 트리거 2건을 자동 생성한다
RI_ConstraintTrigger_c_65977 · 65978 → fk_stores_merchant_account_id
user-visible 트리거는 여전히 1건
```

**계약이 FK 생성을 요구하면서 TestPlan 이 트리거 증가를 0 으로 기대했다.
산술적으로 양립 불가능하다.**

**구현 결함이 아니다.** `TP-R-19` 의 「backfill 중 트리거 우회 금지」 취지는 충족된다.

### §2.5 함수 모집단 158 ↔ 151

```text
Disposition   ACCEPTED — BASELINE MEASUREMENT DISCREPANCY
Required      158 출처 재조사 — 601702 §2.2 와 함께 처리
```

```text
601701 D-3         151
601718 / 601719    158
Stage 9 · 11A      4가지 측정법 전부 151, pg_depend 0

delta 에 CREATE OR REPLACE FUNCTION 0건
→ 이 구현으로 모집단이 변할 수 없다
```

**구현 결함이 아니다.** 기준선·측정 정의 문제다.

### §2.6 clean replay blocker at 0093

```text
Disposition   REQUIRES_FOLLOWUP_WORKPACKET
```

```text
중단 지점   [93] 0093_create_message_catalog_complete.sql
원인        chk_error_domain — canonical 23도메인 / fresh 18도메인, MENU 부재
canonical   0093 = success=true (2026-07-09)
```

**`0170` 76파일 전이며 이 워크패킷과 무관한 저장소 자체 결함이다.**

> ⚠️ **종전 「78」은 어느 셈법으로도 나오지 않는다.**
>
> ```text
> 0093   93번째 / 0170   169번째 / 총 171개
> 간격 169 − 93 = 76
> 사이 파일(양끝 제외) 75
> ```
>
> **판정에는 영향이 없다** — 「훨씬 이전이라 무관」이라는 논지는 동일하다.

**별건 워크패킷** — `0093` replay blocker.

> ⚠️ **`TP-M-08` 을 이 나선에서 PASS 로 만들 수 없다.**
> 보충 실행에서 `0170` · `0171` 이 `rc=0` 이었으나 절차가 다르므로 PASS 가 아니다.

### §2.7 rollback 증거 충분성

```text
Disposition   ACCEPTED — EVIDENCE GAP, DEFERRED
```

**Stage 11B 가 지적한 것**

```text
1  저장소에 정식 reverse migration 파일이 없다
2  migration_history 의 0170 · 0171 성공 행을 되돌리지 않는다
   → 스키마는 과거로 가도 ledger 에는 적용된 것으로 남는다
3  reverse script 가 운영 후 생성 데이터를 구분하지 않는다
4  canonical ↔ disposable 의 create_franchise_store md5 가 다르다
   87511a… vs 92a341… → disposable 결과를 canonical 대리 검증으로 볼 수 없다
5  persons.is_active 재생성 시 DEFAULT true
   → 기존 false 였던 사람이 있었다면 복원되지 않는다
   현재 persons 0행이라 이번 검증에서 드러나지 않았다
```

**5번이 중요하다.** `R-4` 가 *"Person 계열 rollback 대상 데이터는 없다(4테이블 0행)"* 이라고 했으나
**0행이라 안 드러난 것이지 문제가 없는 것이 아니다.**

**처분**

```text
R-1 은 rollback 수행 방식을 정한 정책이며 산출물 선행 생성 요구가 아니다
R-7 이 rollback 판단을 Human 에 둔다
→ 저장소에 역방향 산출물이 없는 것은 위반이 아니다

다만 rollback 완전성은 미입증이다
rollback 을 실제로 결정하면 위 5건을 먼저 해소해야 한다
```

**Stage 11A 의 Rollback Review `PASS` 는 「disposable DB 에서 역전 성공」에 한정된다.**

### §2.8 AC-13 actor conflict

```text
Disposition   REQUIRES_GOVERNANCE_FIX
```

```text
601716 AC-13   「검증자가 상위 문서 및 본 문서의 원작자가 아니다」
000701 §9      Stage 9 검증자 = Claude Code
실제           Claude Code 가 601710/713/716/717 원작자
```

**Claude Code 는 AC-13 literal 을 만족할 수 없다.**

`601740` 이 `SKIP(SPEC_CONFLICT_AC13)` 로 기록했고 **PASS 로 적지 않았다. 그 처리가 옳다.**

**후속 governance 과제** — `000701` §9 의 Stage 9 actor 배정과 `AC-13` 중 무엇이 우선인가.

### §2.9 DocumentType conflicts — 3건

```text
Disposition   REQUIRES_GOVERNANCE_FIX
```

```text
000701 §9      VerificationResult.md
000701 §12.9   MinorOpinion.md
000701 §13.4   AuditReview.md

000002 §1.2 승인 목록에 셋 다 없다
$GroupC 에 'Verification' 은 있으나 'VerificationResult' 는 없다
```

**단발 오류가 아니라 두 상위 규칙의 구조적 불일치다.**

**후속 governance 과제** — `000002` 승인 목록 확장 / `000701` 산출물명 변경.

> ⚠️ **`601742` · `601746` 이 `Report` 를, `601745` 가 `Evidence` 를 쓴 것은
> G02 를 추가로 만들지 않기 위한 회피이며 문제 해소가 아니다.**

### §2.10 Cursor MATERIAL_CONCERN — 무효

```text
Disposition   DISMISSED — INVALIDATED BY RE-MEASUREMENT
```

```text
주장   601716 git blob SHA-256 = 672ED1D1…, 70223 bytes
       skip-worktree 로 worktree 와 index 가 분리돼 있다

실측   git cat-file -s HEAD:<601716>        88800 bytes
       worktree                             88800 bytes
       git ls-files -v docs | grep '^S'     0건
       cmd 리다이렉션 후 Get-FileHash        00C1376E…F102 — §10.8 과 일치
```

**무효 사유 2건**

```text
① H 플래그를 skip-worktree 로 오독했다
   H = cached (정상 추적) / S = skip-worktree
② 해시 측정이 repository 바이트를 보존하지 못했다
   주장한 70223 bytes 는 실제 blob 크기와 다르다
```

**`601741` 을 수정하지 않는다.**
검증자의 finding 은 권위가 아니라 evidence 다.
**오판을 원본 그대로 보존하고 상위 감사에서 재측정으로 기각하는 것이
이 체계가 작동하는 방식이다.**

### §2.11 Stage 11A · 11B 잔여 findings — 5건

**§2.1~§2.10 이 덮지 않은 항목이다. 누락을 기록하고 처분한다.**

| # | 출처 | 항목 | Disposition |
|---|---|---|---|
| a | `601744` F-7 / H-6 | `authority_owner` 가 person 4테이블에 grants 4건, `merchant_accounts` 에 0건. `FO-7` 이 신규 부여를 명시적으로 금지했으므로 위반이 아니다. 다만 이 상태에서 `merchant_accounts` 는 어떤 명명 role 로도 도달 불가다 | **ACCEPTED — DEFERRED TO 0-C** |
| b | `601745` §5 High 3 | `TP-D-02` 를 I-47 enforcement 증거로 인용한 것이 부적절하다. 현재 missing 0 은 migration 직후 시점 스냅샷이며, 다음 tenant 생성부터 다시 깨지는 것을 계약이 `N-1″` 로 인정한다 | **ACCEPTED — AUDIT REASONING CORRECTION** |
| c | `601745` §5 Medium 7 | RLS deny-all 은 **누출에는 안전**하지만 **usable tenant authorization 이 아니다.** `601744` F-7 은 비대칭만 봤고 접근모델 미구현의 운영 효과를 충분히 평가하지 않았다 | **ACCEPTED — DEFERRED TO 0-C** |
| d | `601745` §5 Medium 8 | tenant 상태와 merchant account 계약 상태가 전혀 연결되지 않는다. 계약이 상태 전이 불필요를 명시했으므로 계약 위반은 아니다 | **ACCEPTED — DEFERRED, 상태 축 후속** |
| e | `601745` §3.5 | 로그 이상징후 — `migration_name` 컬럼 오류, `12_migration_history.log` 제목 블록 반복 | **DISMISSED — 증거 수집 절차상 잡음. 실측값에 영향 없음** |

**b 에 대한 보충**

```text
601744 ## Idempotency / Duplicate Prevention Review 가
TP-D-02 missing 0 / dup 0 을 PASS 근거로 인용했다

중복 방지 자체는 uq_merchant_accounts_tenant 가 강제하므로 PASS 는 유효하다
그러나 「모든 tenant 에 merchant account 가 있다」의 근거로 읽히면 부정확하다

시점 정합성 검사와 invariant enforcement 검사를 구분해야 한다
```

> ⚠️ **§2.1 이 같은 취지를 담고 있으나 그 지적 자체는 처분되지 않았다.**
> **Stage 11A 감사 논거의 정밀도 문제로 기록한다.**

**a · c 는 같은 RLS·권한 영역이다.** 0-C 접근 정책 설계에서 함께 다룬다.

## §3 최종 판정

```text
Stage 11C Human Decision

Decision   APPROVE_WITH_NOTES

판정자     정영석
일자       2026-08-24
```

**근거**

```text
IMPLEMENTATION_DEVIATION_OBSERVED   0
implementation delta                 허용 파일 2건뿐
0170 · 0171                          계약과 문자 단위 일치
Stage 11A · 11B 가 독립적으로 같은 결론
```

**FAIL 8건의 귀속**

```text
§2.4 · §2.5   TestPlan 기대값 자체의 결함
§2.3          TestPlan 의 과지정
§2.6          이 워크패킷 이전부터 있던 저장소 상태
AC-7 · AC-9   위 넷의 파생

0170 · 0171 의 계약 위반에서 비롯된 FAIL   0건
```

**D-1 처분의 의미**

> **현재 0-A 는 승인한다.**
> **그러나 D-1 은 실제 구조적 defect 로 인정하며,
> H-2 · H-3 를 열기 위한 강제 선행조건으로 승격한다.**

**「문제 없으니 나중에 보자」가 아니다.**

## §4 후속 이관 목록

| # | 항목 | 소관 |
|---|---|---|
| C-3 | Store ↔ MerchantAccount tenant-consistency enforcement | 후속 RPC alignment 나선 — **H-2 · H-3 선행** |
| — | MerchantAccount 1:1 COMMENT 정정 | C-3 와 묶어 처리 |
| — | TestPlan 트리거 기대값 241 → 243 | 후속 |
| — | 함수 모집단 158 출처 재조사 | `601702` §2.2 와 함께 |
| — | `0093` replay blocker | 별건 워크패킷 |
| — | rollback 완전성 5건 | rollback 결정 시 |
| — | AC-13 actor conflict | governance |
| — | DocumentType conflicts 3건 | governance |
| — | 블라인드 역설계를 설계 확정 전 단계로 이동 | `000701` 개선 |
| — | `Check-Governance.ps1` G13 이 코드펜스를 제외하지 않음 | 도구 개선 |
| — | `authority_owner` grant 비대칭 + RLS deny-all 이 usable authorization 이 아님 | 0-C 접근 정책 — §2.11 a · c |
| — | tenant 상태 ↔ merchant account 계약 상태 미연결 | 상태 축 후속 — §2.11 d |
| — | Stage 11A 감사 논거 정밀도 — 시점 정합성과 invariant enforcement 구분 | `000701` 개선 — §2.11 b |

**`601717` §10.1 Human pre-decision 9건은 재논쟁 대상이 아니다.**
**C-1 · C-2 는 `DEFERRED — INELIGIBLE` 로 유지된다.**

## §5 근거 문서 목록 (`000701` §46)

| 문서 | 인용 |
|---|---|
| `601744_AuditReview_…V2.md` | 전문 — Stage 11A |
| `601745_Evidence_Stage11B_Blind_Audit_ChatGPT.md` | 전문 — Stage 11B |
| `601742_Report_Stage9_Verification_Integration.md` | §5 I-1~I-7 |
| `601740_VerificationResult_…ClaudeCode.md` | §6 O-1~O-8 |
| `601741_MinorOpinion_…Cursor.md` | Concern 1~4 |
| `601717_ChangeContract_…V2.md` | §1 · §4.5 · §9.1 · §10.1 |
| `601716_TestPlan_…V2.md` | TP-M-07 · TP-R-19 · TP-R-14 · TP-M-08 |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §13.4 · §13.5 · §13.7 · §13.8 · §13.9 · §46 |
| `000002_Naming_Rules.md` | §1.2 |

## §6 다음 단계

```text
Stage 12   Human Merge And Release
```

**Stage 11C 가 종료됐으므로 Stage 12 진입 조건이 갖춰졌다.**
