# 000752_Register_Current_Project_Baseline.md

## §0 이 문서의 목적

이 저장소의 "현재 상태" 를 Git 안에 둔다.

AI 세션(Claude Chat · Claude Code · Codex · Cursor)이 시작할 때 가장 먼저 읽는다.

`000701` §29 결정 로그 · §30 ChangeHistory · §32 NavigationMap 을 대체하지 않는다.
그것들을 가리키는 전역 스냅샷이다.

**신설 승인** — `HD-BASE-01` (2026-09-25 22:35 KST)

## §1 Session Baseline Rule

```text
SESSION START
  1. git rev-parse HEAD 를 실행해 실제 HEAD 와 이 문서의 HEAD 를 비교한다
  2. 다르면 이 문서를 신뢰하지 않는다. 개발을 시작하기 전에 먼저 재동기화한다
  3. git status --short --branch · ahead/behind · 열린 Human Decision 을
     저장소 증거로 다시 확인한다

SESSION END
  1. 종료 전에 이 문서를 갱신한다
  2. 현재 HEAD · working tree · 진행 / 동결 프로그램 ·
     열린 Human Decision · 다음 ONE action 을 적는다
```

**기록 원칙**

```text
HEAD · ahead/behind · modified · untracked 같은 기계적 값은
같은 세션의 실제 명령 결과에서만 적는다
확인하지 못한 값은 UNKNOWN 으로 적는다
AI 의 기억이나 이전 대화로 이 값을 채우지 않는다
```

## §2 현재 기준선

**측정 시각** — 2026-09-25 22:37 KST (이 문서 신설 직전, 같은 세션의 명령 결과)

| 항목 | 값 | 명령 |
|---|---|---|
| HEAD | `78f16c5134d1c0dfabb51216311072dacd43db68` | `git rev-parse HEAD` |
| 브랜치 | `main` (추적 `origin/main`) | `git status --short --branch` |
| ahead / behind | ahead 3 · behind 0 — **로컬 추적 ref 기준**, `git fetch` 하지 않음 | `git rev-list --left-right --count origin/main...HEAD` → `0	3` |

**미커밋 목록** — `git status --short --branch` 원출력

```text
## main...origin/main [ahead 3]
 M docs/000005_Index_Document_Number.md
 M docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md
?? business_day_probe_out.txt
?? docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md
?? docs/600000_implementation_lifecycle/602000_runtime_gate/602060_Evidence_RuntimeGate_Ownership_Chain_Tenant_Consistency.md
?? docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/
?? sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql
```

> ⚠️ **위 목록은 이 문서 신설 직전의 상태다.**
> **이 문서의 신설과 색인 3곳 등록(`000005` · `000007` · `000700` Readme)이 그 뒤에 working tree 변경으로 추가된다.**

**Check-Governance 합계** — `tools\Check-Governance.ps1 -Top 0`

```text
ERROR    324
WARN      34
REVIEW   153
TOTAL    511
scanned  1700 markdown files · excluded 736
```

## §3 Human Decision 현황 — 증거가 있는 것만 APPROVED

> ⚠️ **AI 의 추천안을 Human Decision 으로 승격시키지 않는다.**
> **각 HD 의 전문은 원 문서를 따른다. 아래는 한 줄 요약이다.**

**APPROVED**

| HD | 일시 | 증거 | 요약 |
|---|---|---|---|
| `HD-CTN-01` ~ `04` | 2026-09-22 09:41 KST | 사용자 문장 "제시한 안으로 적용해서 작성해주세요" | CTN 처분안 적용 — `HD-CTN-04` 는 RG-06 을 H03-F2 로 범위 축소. 전문은 원 문서(02_Overview 등) |
| `HD-CTN-06` | 2026-09-23 06:53 KST | 사용자 문장 "HD-CTN-06 승인하겠습니다" | 전문은 원 문서(02_Overview 등) |
| `HD-BASE-01` | 2026-09-25 22:35 KST | 이 문서 신설 지시 | `000752` 세션 기준선 문서 신설 |
| `HD-METHOD-01` | 2026-09-26 07:03 KST | 사용자 문장 "승인합니다" | 방법론 전환 — 작업 단위 함수 하나 → 구조 하나 · 문서 제한 설계 1 · 계약 1 · 검증 1 · 결정로그 1 (기본 상한) · 검증 상한 기본 최대 2라운드 (상세는 §9) |
| `HD-CTN-07` | 2026-09-26 07:03 KST | 사용자 문장 "승인합니다" | CTN-1a = P2 FROZEN / SUPERSEDED_BY_TAF — finding · evidence 보존 · Stage 8 · 9 구현 진행하지 않음 · containment 요구는 TAF default-deny 에 흡수 · untracked 파일의 실제 처분은 별도 결정 (미정) — **STATUS: AMENDED_BY `HD-METHOD-02` (2026-09-26)** · 원래 승인 사실과 결정 기록은 보존한다 · CTN-1a 의 현재 실행 상태는 SUSPENDED 이다 · Legacy Migration Line HOLD 에 종속된다 · 기존 "SUPERSEDED_BY_TAF" 는 더 이상 현재 상태를 나타내지 않는다 (TAF 자체가 `HD-METHOD-02` 로 이동했으므로 대체 관계가 성립하지 않는다) · containment 요구사항은 폐기하지 않는다 · containment 요구사항의 승계 경로를 변경한다: TAF default-deny 에 흡수 → Canonical Migration B2 의 Authority Kernel 설계 입력으로 승계 |
| `HD-NEXT-01` | 2026-09-26 07:03 KST | 사용자 문장 "승인합니다" | 다음 한 걸음 = Canonical Function Inventory — 완료 후 바로 Golden Path. 중간에 다른 감사를 끼우지 않는다 — **STATUS: AMENDED_BY `HD-METHOD-02` (2026-09-26)** · 승인 사실과 결정 기록은 유효하게 보존한다 · 결정 자체는 유지하되 실행 순서와 산출물 목적을 변경한다 · Canonical Function Inventory 는 Rebuild Feasibility Spike 이후로 이동한다 · 변경된 목적: "446개를 어떻게 고칠 것인가" → "CARRY_FORWARD / REDESIGN / DISCARD / UNKNOWN 분류" |
| `HD-METHOD-02` | 2026-09-26 07:26 KST | 사용자 문장 "일단 설계문서는 냅두고 기초공사부터 다시 시작하죠." (provenance: Claude Chat conversation record) | 기존 설계문서와 검증된 domain 지식은 보존한다 · Legacy migration chain 의 추가 patch 는 HOLD 한다 · 새 canonical migration chain 을 빈 DB 에서 다시 구성하는 B2 방향을 채택한다 — 범위 구분: B2 방향 결정 = 승인 완료 · B2 implementation rollout = Rebuild Feasibility Spike PASS 후 · Spike 의 성격 = 방향 재투표가 아니라 foundation viability 검증 |
| `HD-AMB-01` | 2026-09-26 KST | provenance: Human approval in ChatGPT conversation, 2026-09-26 KST · 확인: Claude Chat conversation record, 2026-09-26 08:49 KST · 사용자 문장 "제가 확인하고 승인했습니다" | 0-A authority 판정 범위 — 전문은 아래 `HD-AMB-01` 블록 |
| `HD-AMB-02` | 2026-09-26 KST | provenance: Human approval in ChatGPT conversation, 2026-09-26 KST · 확인: Claude Chat conversation record, 2026-09-26 08:49 KST · 사용자 문장 "제가 확인하고 승인했습니다" | POLICY_INCLUDED_BY_REFERENCE 지위 신설 — 전문은 아래 `HD-AMB-02` 블록 |

**`HD-AMB-01` 전문**

```text
HD-AMB-01 · 2026-09-26 KST · APPROVED
provenance: Human approval in ChatGPT conversation, 2026-09-26 KST
확인: Claude Chat conversation record, 2026-09-26 08:49 KST
      사용자 문장 "제가 확인하고 승인했습니다"
판정 방식: repository 원문 근거 (기억 아님)

내용:
  - 600020 §1.1 의 직접 0-A authority suspension 대상은
    1차 0-A / 601500 이다
  - 600020 §1.2 의 파생 HOLD 는
    당시 기존 0-A-2 / 0-A-3 / 0-B 에 적용된다
  - 601700 / 601702 는 600020 §2 가 요구한
    재검증 절차에 따라 수행되는 새 0-A authority path 이며,
    기존 601500 suspension 또는 §1.2 HOLD 에
    자동 포함되지 않는다
  - 따라서 601702 를
    "600020 때문에 authority hold 상태" 로 분류하지 않는다
  - 단, 601702 의 모든 내용을 Canonical Migration B2 에
    그대로 구현한다는 뜻이 아니다.
    현재 설계 evidence 로서의 authority 를 인정한다

논증 구조:
  601500 직접 suspension
    ↓
  당시 0-A-2 / 0-A-3 / 0-B 파생 HOLD
    ↓
  600020 이 별도의 새 0-A 수행을 명령
    ↓
  그 새 0-A = 601700
    ↓
  601702 = 그 경로의 Active Human rule declaration

금지 표현:
  "600020 hold = 601500 only" 라는 축약을 사용하지 않는다.
  §1.2 파생 HOLD 의 존재를 가리는 표기를 금지한다.

결정 근거 (원문):
  600020 §1.1  L19-27   601500 AUTHORITY SUSPENDED
  600020 §1.2  L38-40   파생 HOLD — 0-A-2 / 0-A-3 / 0-B
  600020 §2    L101-106 새 0-A 에 대한 구속
                        "기존 601500 을 답안지로 사용하지 않는다"
  600020 §3.1  L160     "새 0-A(601700) 완료 후 실행한다"
  600020 §3    L149-150 "새 0-A 완료 후 재판정"
  601702                Status: Active · Human 전담
                        1단계 업무규칙 선언 · 이후 나선의 상위 근거
  601902 §7    L1126    601702 — ACTIVE · 상위 근거로 인용

배경 참고 (결정 근거 아님):
  600020 §1.3  L44      "기존 구현 Lifecycle 산출물"
  600020 §1.3  L56-57   §46/§47/§48 확정 시점 (2026-07)
  → 이 두 줄은 §1.3 의 취지를 설명하는 배경이며
    HD-AMB-01 의 결정 근거로 사용하지 않는다
```

**`HD-AMB-02` 전문**

```text
HD-AMB-02 · 2026-09-26 KST · APPROVED
provenance: Human approval in ChatGPT conversation, 2026-09-26 KST
확인: Claude Chat conversation record, 2026-09-26 08:49 KST
      사용자 문장 "제가 확인하고 승인했습니다"

내용 — POLICY_INCLUDED_BY_REFERENCE 지위 신설:

  대상 문서:
    010004 · 010630 · 010640 · 010650 · 010660

  원문 lifecycle 은 planning-only 로 유지한다.
  문서 본문을 수정하지 않는다.

  다만 600021 / 601902 가 명시적으로 채택 · 구속한
  section / scope 에 한해
  POLICY_INCLUDED_BY_REFERENCE 로 취급한다.

  이 지위는:
    - Target Specification 의 정책 / 설계 근거로 사용 가능
    - 구현 승인(coding authorization)을 뜻하지 않음
    - 문서 전체를 무조건 승격하지 않음
    - 상위 문서가 실제로 채택한 section / scope 까지만 효력 인정

  용어 구분:
    planning-only
      = 이 문서 자체는 구현 승인을 주지 않는다
    ACTIVE — mandatory by higher authority
      = 상위 결정이 채택한 정책 내용은 현재 설계 근거로 쓴다

  채택 범위 (601902 §7 L1117-1125 기준):
    010004   §7 · §19 · §20 · §24 · §26 · §29
    010640   §2 · §4 · §5 · §6 · §42
             (§41 은 601901 A3 발견 경로이며 TI-N 근거 아님)
    010630   authority gate family · SCOPE_GATE · multi-party
             · §6 · §28
    010650   circuit breaker scope · §35 · anti-pattern
    010660   §4 · §5 · §6

  위 범위 밖의 절은 POLICY_INCLUDED_BY_REFERENCE 가 아니다.
  문서 전체 승격을 금지한다.
```

**UNVERIFIED / PENDING CONFIRMATION**

| HD | 내용 | 상태 |
|---|---|---|
| `HD-CTN-05` | clean baseline 실현성 실측 | **UNVERIFIED** — 사유: 사용자 승인 문장 없음 · 2026-09-26 확인. 이미 수행된 clean baseline 실측 결과는 evidence 로 유효하다 (별개의 사실). |

## §4 진행 · 동결 프로그램

| 상태 | 프로그램 | 비고 |
|---|---|---|
| 방법론 전환 승인됨 (`HD-METHOD-01` · 2026-09-26) | Tenant Authority Foundation Rebuild | `HD-METHOD-02` 에 따라 기존 implementation path 는 deferred. Authority foundation 요구사항과 검증 결과는 Canonical Migration B2 설계 입력으로 유지한다. Canonical Function Inventory 는 Spike 이후 수행한다. 주의: Spike 종료 후 기존 TAF 프로그램을 그대로 재개하는 것이 아니다. TAF 에서 얻은 authority 요구사항을 새 canonical foundation 에 흡수하는 방식이다. |
| SUSPENDED | CTN-1a | Legacy Migration Line HOLD 에 종속 (`HD-METHOD-02`) · Stage 1~6 산출물 보존 · Stage 7 진행하지 않음 |
| 범위 축소 | RG-06 | H03-F2 만 (`HD-CTN-04`) |
| 권위 보류 | 0-A | `600020` |
| 유효한 금지 | `601505` §4 `isolate_tenant` 등 호출 금지 | `600020` L98 |

```text
Legacy Committed Migration Line 0000~0178
  STATUS: HOLD
  NO FURTHER NON-EMERGENCY PATCH
  pending Rebuild Feasibility Spike
  파일 삭제 금지. 실행 이력·포렌식 증거로 보존한다.
  emergency 판단은 Human Decision 으로만 한다.

0179 CTN-1a Prototype
  STATUS: SUSPENDED / PROTOTYPE
  canonical migration line 에 포함하지 않는다
  정식 migration history 로 취급하지 않는다
  삭제·이동·커밋 여부는 별도 Human Decision 으로 정한다

CTN-1a 억제 프로그램
  STATUS: SUSPENDED
  사유: Legacy chain HOLD 에 종속
  Stage 1~6 산출물은 보존한다. Stage 7 은 진행하지 않는다.

Rebuild Feasibility Spike
  STATUS: PENDING
  범위: Tenant / Store / Actor-Membership /
        Authority Kernel / register_waiting

  검증 조건 6건 (Test 0 이 최우선)

  0. 완전히 빈 DB 에
     Spike migration chain 을 canonical order 로
     처음부터 적용            → manual edit / skip / reorder
                                 없이 PASS

  1. tenant A + store B mismatch → DB structural FAIL
  2. user A → tenant B API       → DENY
  3. isolated tenant A → API     → DENY
  4. user A → 허용된 tenant A / store A → PASS
  5. authenticated client →
     internal domain function 직접 호출 → DENY

  판정 규칙:
  Test 0 이 FAIL 이면
  1~5 가 모두 PASS 하더라도
  foundation viability 를 PASS 로 판정하지 않는다.

  Test 0 관련 근거:

    601902 §5 (L1075-L1100) 는
    601902 / 0-A-2 나선 자체가
    테이블 · 컬럼 · 제약명 · 인덱스명 · 함수 signature ·
    role ID · EXECUTE ACL · containment block 판정 위치 ·
    policy permission 모델의 물리 표현을 확정하지 않고
    Stage 4 · 0-C 로 이월했음을 명시한다.

    이는 "기존 INCLUDED 문서에 physical foundation invariant 가 없다"
    는 뜻이 아니다.

    601702 등 기존 authoritative foundation source 에서
    이미 검증 · 확정된 physical invariant 는 B2 입력으로 유지한다.

    B2 에서는:
      - 이미 확정된 foundation invariant 는 재사용하고
      - 601902 가 Stage 4 / 0-C 로 이월한
        미정 physical / authorization / enforcement 부분만
        새 canonical design 에서 확정한다

    Test 0 은 그 결과가 빈 DB 에서 canonical order 로
    완전 replay 가능한지를 검증한다.

Canonical Migration Genesis Rule (B2 chain 제1 규칙)

  각 migration 은 자신보다 앞선 migration 들만
  적용된 상태에서 순서대로 정상 실행되어야 한다.

  어떤 migration 도 미래 migration 의 schema 변경을
  선행조건으로 요구해서는 안 된다.

  후속 migration 이 기존 schema 를 정상적으로
  확장·변경하는 것은 허용한다.

  각 승인 baseline 에서
  빈 DB → latest 까지 canonical order replay 가 PASS 해야 한다.

  참고: 현행 F-REPLAY (0093 이 0140 의 변경을 선행조건으로
  요구하는 구조) 가 이 규칙 부재의 결과다.
```

```text
Canonical Migration B2 — 정의

  B2 =
    기존 0-A / 0-A-2 에서 검증 · 확정된 foundation invariant
    +
    0-C 로 이월된 authorization / enforcement 책임
    +
    HD-METHOD-02 의 Canonical Migration Genesis Rule

    을 Legacy migration chain 을 답안지로 삼지 않고
    빈 DB 에서 새 canonical migration chain 으로 재구성하는 것

  주의:
    B2 를 "0-C 만 구현하는 작업" 으로 축소하지 않는다.
    기초 schema 도 다시 붓는다.
    601702 가 이미 확정한 물리 foundation 규칙
    (예: merchant_accounts.tenant_id NOT NULL UNIQUE FK → tenants ·
     기본 보안 posture RLS ENABLE + FORCE ·
     policy 0개 · owner 외 GRANT 확대 금지)
    은 B2 설계 입력으로 유지한다.

  배경 근거 — 601902 HD-0-A-2R-14 (L1035-1052):
    TI-1 ~ TI-15 는 정책 계약으로 동결됐고
    caller identity resolution · tenant/isolation gate ·
    runtime refusal 은 authorization spiral(0-C)로 이월됐다.
    0-C 는 착수되지 않았다.
```

```text
Canonical Design Invariant 발췌 — 판정 규칙 수정 (2026-09-26)

규칙 ① AUTHORITY_UNRESOLVED 성립 조건
  UNKNOWN 문서가 있다는 사실만으로는 성립하지 않는다.
  아래 4개를 모두 만족하는 UNKNOWN source 가 있을 때만 성립한다.
    1. 실제 본문을 확인했으며
    2. 11개 Required Invariant 중 하나 이상에 대해
       normative rule 후보를 실제로 포함하고 있고
    3. 그 rule 의 현재 authority 가 불명확하며
    4. 더 높은 precedence 의 INCLUDED source / overlay 로
       현재 효력을 해결할 수 없다
  단순 keyword hit · 주변 설명 · implementation history ·
  단순 참조 문서는 AUTHORITY_UNRESOLVED 를 발생시키지 않는다.

규칙 ② 부분 스캔 중 최종 상태
  5개 모듈(Tenant · Store · Actor/Access Membership ·
  Authority Kernel · register_waiting) 전체가 끝나기 전에는
  최종 상태를 확정하지 않는다.
  중간 턴은 SCAN_IN_PROGRESS · Final status NOT YET EVALUATED
  로 보고하고 GAP / CONFLICT / authority ambiguity 만 누적한다.

규칙 ③ T-13 판정
  T-13 (601902 "이 나선이 정하지 않는 것") 은 VERIFIED 다.
  근거: 601902 §5 L1075 제목 + L1077-L1098 목록 + L1100
        "Stage 4 · 0-C 가 정한다"
  provisional 표기를 해제한다.
```

## §5 3-AI 아키텍처 감사 (2026-09-25) — 원자료 그대로

```text
Claude Code  B PARTIAL REBUILD
Codex        B PARTIAL REBUILD
Cursor       A KEEP & REPAIR

Synthesis    Full DB rebuild 는 지지하지 않는다
             함수별 patch 지속도 지지하지 않는다
             Tenant authority foundation 의 구조적 재정비 방향에는 실질적으로 수렴한다
```

> ⚠️ **해석으로 단순화하지 않는다.**

## §6 알려진 구조 문제

**Tenant authority**

```text
authenticated 가 실행 가능한 SECURITY DEFINER   약 446
caller gate                                      약 15
  세 감사의 counting grain 이 달라 canonical inventory 는 아직 없다

tenant × store 복합 FK                           0 / 138
```

**F-REPLAY — 두 상태를 함께 적는다**

```text
numeric-order strict replay          0093 에서 FAIL (23514)
CHANGELOG L177 documented two-stage  177/177 PASS × 2 (2026-09-23)
```

**문서 구조 — 2026-09-25 A1 스캔**

```text
Duplicate ID       166 ID / 352 파일 (같은 폴더 안은 4쌍)
Index 미등록       159
Orphan             128
Stale               13
번호 없는 Markdown  RULE_VIOLATION 0 · EXPLICIT_EXCEPTION 7 · UNCLASSIFIED 1
```

## §7 다음 ONE action

```text
Minimal Canonical Target Specification 추출

범위: Tenant / Store / Actor-Membership /
      Authority Kernel / register_waiting 5개로 한정
입력: 현재 유효한 canonical 설계문서의 invariant 만
금지: 새 철학 문서 작성, 범위 확대

판정 기준:
"설계문서를 얼마나 많이 반영했는가" 가 아니라
"새 migration 하나를 만들기에 invariant 가 충분히 명확한가"

작성 체인:
  Claude Chat  초안 추출
  ChatGPT      Critical Lane second-anchor review
  사용자       Human approval
  Codex        승인된 Specification 만 구현

구현자가 자기 구현 계약을 작성하지 않는다
(000701 §37 author-exclusion)
```

## §9 운영 체제

### 권위 순서

```text
Repository Baseline (이 문서) = 정답
AI 의 기억 · 이전 대화       ≠ 정답

Claude 와 ChatGPT 가 둘 다 "RG-06 진행 중" 이라고 해도
이 문서가 FROZEN 이라고 적었으면 둘 다 틀린 것이다
```

### 역할

| 역할 | 담당 | 책임 |
|---|---|---|
| 운영 앵커 | Claude Chat | 진행 상태 · 문서 번호 · 규칙 · 워크패킷 · 다음 작업 통제 |
| 전략 앵커 | ChatGPT | 전체 아키텍처 · 방법론 · scope drift · patch loop 여부 · 방향 전환 |
| 상태의 정답 | Git Repository | HEAD · canonical 문서 · 현재 baseline |
| 구현 | Codex | 승인된 범위만 코드 · SQL 구현 |
| 전수 검색 | Cursor | repo-wide 영향 범위 · 누락 검색 |
| 최종 승인 | 사용자 | 중요한 방향 결정 |

두 앵커는 서로의 상사가 아니다. 비대칭이다.
Claude 가 매일 개발을 끌고 간다. ChatGPT 는 모든 일을 다시 검토하지 않는다.
잘못된 방향으로 멀리 가기 전에 브레이크를 거는 역할이다.

### Fast Lane / Critical Lane

```text
Fast Lane      일상 개발 80 ~ 90%
               사용자 → Claude Chat → Codex / Cursor → 구현 · 테스트
               예: 메뉴 필드 추가 · UI 수정 · 일반 버그 · 테스트 · 명확한 migration · 색인 등록

Critical Lane  중대 방향 10 ~ 20%
               위 흐름 + ChatGPT second-anchor review
               ChatGPT 판단: 계속 진행 / 범위 축소 / root cause 먼저 / partial rebuild / hold
```

### SECOND ANCHOR REVIEW 트리거

아래 중 하나에 해당하면 Claude 는 사용자에게 `SECOND ANCHOR REVIEW REQUIRED` 를 알린다.

```text
① 구조 · foundation 을 새로 만들거나 바꾼다
② 기존 Human Decision 과 충돌하거나, Claude 가 자신의 이전 판단을 뒤집으려 한다
③ 범위가 처음의 2배 이상이 됐다
④ 워크패킷 3개가 지나도록 사용자 기능이 전진하지 않았다
```

**사용자는 트리거와 무관하게 언제든 직접 SECOND ANCHOR REVIEW 를 호출할 수 있다.
Claude 는 이를 불필요하다고 차단하지 않는다.**
(근거: 2026-09-25 에 Claude 가 트리거 ③ · ④ 에 해당하는 상태를 스스로 자각하지 못한 사례가 있었다)

### 두 앵커의 의견이 다를 때

```text
Claude 의견 · ChatGPT 의견
        ↓ 불일치
각자 1회씩 근거 제시
        ↓
Repository evidence 확인
        ↓
사용자 Human Decision
        ↓
결정 종료
```

**재반박 3라운드 · 4라운드 금지.** 각자 한 번씩만 낸다.

Claude 는 사용자에게 한 화면으로 압축해 올린다.

```text
쟁점 ·  Claude ·  ChatGPT ·  공통점 ·  차이 ·  결정해야 할 것
```

긴 문서는 AI 가 읽고, 사용자는 결정에 필요한 압축본을 읽는다.

### 검증 상한

```text
검증은 기본 최대 2라운드.

2라운드 후에도 Critical blocker 가 남으면
Known Limitation 으로 강등하지 않는다
  → 작업 중단
  → root-cause review / SECOND ANCHOR REVIEW
  → Human Decision

비Critical 잔여사항만 명시적 Known Limitation 또는 후속 구현 항목으로 이관 가능
```

검증 횟수를 제한하는 것과 미해결 위험을 허용하는 것은 다른 문제다.
(근거: 2026-09-25 CTN-1a 한 건에 재검증 4회 · 매 라운드 새 결함)

### 문서 제한

```text
기본 상한   설계 1 · 계약 1 · 검증 1 · 결정로그 1
추가 문서   "왜 기존 문서에 넣을 수 없는가" 를 먼저 밝힌다
```

### 작업 단위

```text
함수 하나씩 고치지 않는다. 구조 하나를 바꾼다
예: 446 개 일괄 default-deny + 필요한 API 만 allowlist
```

### 주간 지표

```text
코드 변경 :
테스트 추가 :
완료 사용자 흐름 :
문서 생성 :
문서 / 코드 커밋 비율 :
워크패킷당 검증 라운드 수 :

Golden Path   대기 [ ] 좌석 [ ] 주문 [ ] 결제 [ ] KDS [ ] DID [ ]

이번 주 실제 제품 전진 : YES / NO
```

**2주 연속 `실제 제품 전진 = NO` 이면 사용자와 ChatGPT 에게 방법론 경고를 올린다.**

참고 (2026-09-25 측정)

```text
7/25 이후 244 커밋 중  migration 변경 14 · 문서만 변경 221
CTN-1a 한 건의 검증 라운드 4회
```

## §8 Last Updated

| 항목 | 값 |
|---|---|
| 일자 | 2026-09-26 KST |
| 갱신자 | Claude Code |
| 갱신 시점의 HEAD | `78f16c5134d1c0dfabb51216311072dacd43db68` |

세션 종료 시 갱신 (SESSION END)
