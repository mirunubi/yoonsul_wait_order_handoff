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
  1. git rev-parse HEAD 를 실행해
     실제 HEAD 와 §2 의 "마지막 작업 커밋" 을 비교한다
  2. 아래 둘 중 하나면 정상으로 판정한다
       - 실제 HEAD 가 §2 기록값과 같다
       - 실제 HEAD 가 §2 기록값의 직계 자식이다
         (이 문서의 SESSION END 갱신 커밋)
     둘 다 아니면 이 문서를 신뢰하지 않는다.
     개발을 시작하기 전에 먼저 재동기화한다.
     판정 근거는 §2 의 off-by-one 주석이다
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

**측정 시각** — 2026-09-27 06:48 KST (evidence commit 직전, 같은 세션의 명령 결과)

| 항목 | 값 | 명령 |
|---|---|---|
| 마지막 작업 커밋 | `65bf9362fb1853a1c58ee5437f618746376b11e1` (`65bf936`) | `git rev-parse HEAD` |
| 브랜치 | `main` (추적 `origin/main`) | `git branch --show-current` |
| ahead / behind | ahead 0 · behind 0 — **OBSERVED_PRE_SESSION_END_COMMIT** · 로컬 추적 ref 기준, `git fetch` 하지 않음 | `git rev-list --left-right --count origin/main...HEAD` → `0	0` |

```text
주 — HEAD 대조 시 off-by-one 처리:
이 문서의 SESSION END 갱신 커밋은
위에 적힌 마지막 작업 커밋의 다음 커밋이다.
따라서 다음 세션 시작 시 실제 HEAD 는
기록값 자신이거나 그 직계 자식(SESSION END 커밋)이다.
둘 중 하나면 정상으로 판정한다.
그 밖이면 재동기화한다.

주 — ahead / behind 의 성격:
ahead / behind 는 세션 종료 커밋 및 push 로 즉시 변하는
관측값이며 다음 세션의 equality gate 로 사용하지 않는다.
다음 세션 시작 시 actual 값을 새로 측정한다.
불일치만으로 baseline drift 로 판정하지 않는다.
```

**미커밋 목록** — `git status --short` 원출력 · **OBSERVED_PRE_SESSION_END_COMMIT**

```text
?? docs/implementation_evidence/b2_canonical_design_invariant_extraction/
```

```text
주:
  위 값은 이번 evidence commit 직전 관측값이다.
  commit 후 working tree 상태는
  최종 보고에서 다시 실측한다.
```

**Check-Governance 합계** — `tools\Check-Governance.ps1 -Top 0`

```text
ERROR    323
WARN      33
REVIEW   153
TOTAL    509
scanned  1701 markdown files · excluded 737
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
| `HD-0179-01` | 2026-09-26 KST | provenance: Human approval in ChatGPT conversation, 2026-09-26 KST · exact quote / exact time: UNVERIFIED_BY_REPOSITORY | 0179 처분 D-2 (archive) — 전문은 아래 `HD-0179-01` 블록 |
| `HD-ACTOR-01` | 2026-09-30 KST | provenance: Human approval declared in Claude Chat conversation, 2026-09-30 KST · 사용자 지시 "이걸 채워주세요" 로 승인 문안 채택 · 승인 문안 초안 출처 ChatGPT conversation, 2026-09-30 KST · 승인 문안 "HD-ACTOR-01 을 승인합니다." | B2 문서 거버넌스 작업 전용 Transitional Actor Override — 전문은 아래 `HD-ACTOR-01` 블록 |
| `HD-STRUCT-01` | 2026-09-30 KST | provenance: Human approval declared in Claude Chat conversation, 2026-09-30 KST · 사용자 지시 "이걸 채워주세요" 로 승인 문안 채택 · 승인 문안 초안 출처 ChatGPT conversation, 2026-09-30 KST · 승인 문안 "번호 방식은 안 A 를 선택합니다 · 위 번호 결정을 반영한 HD-STRUCT-01 을 승인합니다." | Canonical Design Invariant evidence 의 영구 governed 위치 확정 — 전문은 아래 `HD-STRUCT-01` 블록 |

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

**`HD-0179-01` 전문**

```text
HD-0179-01 · 2026-09-26 KST · APPROVED
provenance:
  Human approval in ChatGPT conversation, 2026-09-26 KST
  exact quote / exact time: UNVERIFIED_BY_REPOSITORY

결정 내용:
  0179 처분은 D-2 로 한다.
  sql/migrations/ 에서 제거하고
  docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/
  아래로 basename · 번호 · 확장자를 그대로 유지해 이동한다.

  삭제하지 않는다. 파일명을 바꾸지 않는다.
  archival renaming 이 아니다 (000701 §15.1).

실행 검증 (repository 증거):
  000701 §14.5 불변 경계 4조건 측정 결과
    C1 Stage 12                 NO
    C2 보호 브랜치              NO
    C3 공유환경 적용            NO
    C4 후속 승인 워크패킷 의존  NO
  → Draft 상태이며 이동 가능 (600020 §1.5)

  커밋 9252491 로 disposition 실행 완료
  SHA-256 이동 전후 동일:
    73c2e6b1ea5a2bfaa79b5a6929bff3ae345706c2a579b076102edee44a99a39c
```

**`HD-ACTOR-01` 전문**

```text
HD-ACTOR-01 · 2026-09-30 KST · APPROVED
provenance: Human approval declared in Claude Chat
            conversation, 2026-09-30 KST
            사용자 지시 "이걸 채워주세요" 로
            아래 승인 문안을 채택
            승인 문안 초안 출처:
              ChatGPT conversation, 2026-09-30 KST
            승인 문안:
              "HD-ACTOR-01 을 승인합니다."
            Claude Chat confirmation: 2026-09-30 KST

성격
  전역 Actor Mapping 이 아니다.
  B2 문서 거버넌스 작업 전용
  Transitional Actor Override 이다.

  적용 범위
    docs/ 구조 migration
    governance registration
    evidence 이동 · 정합
    번호 배정
    Index · Map · Readme

  비적용 범위
    sql/ migration · runtime 구현 코드 · 함수 · 정책 ·
    애플리케이션 코드
    이 범위의 구현자 전역 변경은 이 결정이 정하지 않는다
    별도 Human Decision (HD-ACTOR-02 등) 으로 확정한다

1. 파이프라인 분류
   Human 은 이번 B2 문서 거버넌스 작업을
   000701 §3 13단계 workpacket pipeline 의 실행으로
   분류하지 않는다.

   근거 (관찰 사실)
     §6.11 L513 의 CHANGE_ID 를 공식 선언한 기록이 없다
       (폴더명 b2_canonical_design_invariant_extraction 이
        change_id 자리에 있는 것은 사실이나,
        CHANGE_ID 선언 절차를 거친 기록은 없다)
     ImpactScope.md · Overview.md · Logic.md 없음
     TestPlan.md · ChangeContract.md 없음
     Human Boundary Approval 섹션 없음
     NavigationMap 항목 없음
     Tenant · Store evidence 커밋도 §3 단계를 거치지 않았다

   tier 규정과의 관계 (원문 확인)
     §31 L2856-L2868 이 정하는 tier 는
       Lightweight / Medium / Full (산출물 tier) 이다.
     Normal / Critical (검증자 구성 tier) 은
       §3 [3] 및 000701 L1170 의
       Per §39 ... Normal tier ... 규정에서 확인된다.

     어느 tier 도 Stage 11 을 면제하지 않는다.

       §31 L2865 (Medium tier · 원문 그대로)
         "All required CHANGE_ID traceability and stage gate
          rules (§6.11, Stage 7 approval, Stage 11 independent
          audit) still apply in full — only the FILE COUNT is
          reduced, not the review rigor."

       §24 L2806
         Lightweight track 에도 Stage 11 독립 감사를
         소급 적용한다 (요약 · 원문은 해당 라인 참조)

     따라서 이 작업은 tier 를 선택해 Stage 11 을 축소하는
     방식으로 처리하지 않는다.

   §13.7 과 §13.8 은 Stage 11 이 호출되는 workpacket 에서
   적용되는 규칙으로 인식하고 그대로 유지한다.
   이번 작업에서는 Stage 11 자체를 호출하지 않는다.

   §3 이 문서 거버넌스 작업에 원래 적용되는지 여부는
   여전히 UNDETERMINED 로 남긴다.
   이 결정이 그것을 확정하지 않는다.

2. 역할
   Human           Final Merge / Closure Authority
   Claude Chat     Primary Anchor / Governance Keeper
                   지시어 작성 · 규칙 해석 · 결정안 작성 ·
                   Governance Audit
   ChatGPT         Independent Reviewer / Challenger
                   (현재 대화창 — 아래 4 참조)
   Claude Code     이 범위의 Primary Implementer
   Codex           이 범위의 Independent Verifier
   Cursor          Independent Verifier (repo-wide 대조) ·
                   Repository Scout / Debugger
                   production write 없음
   Antigravity     Excluded

   Antigravity Excluded 의 근거 (두 가지 · 분리)

     (a) 사용자 상시 지시
         "안티그래피티도 제외입니다"
         이 결정 이전에 내려진 Human 지시이다.

     (b) 기존 governance 기본값과의 관계

         §3.1 L208 의 Antigravity 병행 규정은
         §3 pipeline 내부의 지정 stage 에 관한 규칙이다.

         §40.1 의 Antigravity observer 병행 규정은
         해당 관찰기간과 적용 tier 에 관한 규칙이다.

         이번 B2 문서 거버넌스 작업은
         위 1 에 따라 §3 workpacket pipeline 실행으로
         분류하지 않으며,
         §31 의 Lightweight / Medium / Full tier 를
         이 B2 전용 gate 의 근거로 선택하지 않는다.

     따라서 이 B2 전용 gate 에서는
     Antigravity 를 participant 또는 observer 로
     사용하지 않는다.

     이 결정은 §40 자체를 supersede 하지 않으며,
     §40 관찰기간의 현재 유효성도 확정하지 않는다.

   불변 규칙
     Primary Implementer 와 Independent Verifier 는
     동일 actor 가 될 수 없다
     Independent Verifier 의 판정은 merge 권한이 아니다
     Claude Code 의 자기 보고는
     IMPLEMENTATION_COMPLETED 까지이며
     VERIFIED 또는 PASS 를 스스로 부여할 수 없다

   이 역할표는 계획된 배정이다.
   실제 verifier 배정은 아래 3 의 author-check 실측으로
   확정한다. 역할표가 실측을 대체하지 않는다.

3. §37 적용 판정 (원문이 증명한 범위)
   §37 의 author 는 "설계 문서 또는 구현 코드" 및
   ChangeContract 의 실제 작성자다
   (000701 L2986 · L1452).

   지시어 작성자를 §37 의 author 로 규정한 원문은 없다.
   L2992 는 Claude 를 "파이프라인 지시자 역할" 로 부르며
   §37 을 적용할 의무를 지운다.
   제외 대상이 아니라 검사 수행자다.

   따라서
     §37 author-exclusion 규칙상,
     Claude Chat 이 지시어를 작성했다는 사실만으로
     Claude Chat 을 해당 구현 산출물의 author 로 취급하거나
     검증 또는 감사 역할에서 제외할 근거는 없다.

   §37 은 §3 [6] 과 [9] 에 적용되며
   [11] 은 §37 을 참조하지 않는다.

   §37.1 L2988 은 검증자 선정에서
   "일반적으로 Cursor가 우선" 이라고 적는다.
   아래 6 의 Cursor 배치가 이와 정합한다.

   §37.2 절차 준수 (적용 범위)
     verification handoff 또는
     verifier assignment 를 포함하는 write batch 지시어에는

       원작자: <write 완료 후 §37.2 재측정>
       검증자 제외: <재측정한 author set>
       예정 검증자: <actor 2명>

     를 서두에 명시한다.

     실행 전에는 예정 검증자이고,
     실행 후 handoff 시점에 확정 검증자가 된다.

     순수 READ-ONLY 조사 지시어처럼
     검증자를 배정하지 않는 작업에는
     이 필드를 의무화하지 않는다.

   이번 B2 범위의 author-check 원칙

     planned repository write actor
       Claude Code

     approved decision content provenance
       Human / Claude Chat

     이 구분의 목적은, §37 author-check 를 적용할 때
     "HD 문안을 누가 만들었는가" 와
     "실제 repository write 를 누가 했는가" 를
     혼동하지 않게 하는 것이다.

     단, §37 의 author 또는 verifier exclusion 은
     위 역할표만으로 사전에 확정하지 않는다.

     각 write batch 완료 후 verification handoff 직전에
     git diff / git log / 해당 세션의 작성 · 수정 이력을
     다시 확인하여 이번 산출물의 실제 author set 을
     확정한다 (§37.1 (1) · §37.2).

     가능한 결과
       단독 authorship
       또는
       여러 actor 의 mixed authorship

     그 author set 에 포함된 actor 전원을
     verifier 후보에서 제외한다.

     planned Independent Verifier
       Cursor + Codex (아래 6 참조)

     단, handoff 시 author-check 결과 Cursor 또는 Codex 가
     해당 산출물의 author set 에 포함되어 있으면
     그 actor 를 verifier 로 사용하지 않고 STOP 하여
     대체 verifier 를 Human 또는 Claude Chat 에 요청한다.

     Batch 1 의 explicit verification authority 는
     §37 author-exclusion 을 supersede 하지 않는다.

4. ChatGPT 대화창 자격 구분
   §13.8 L2178 은 Blind Audit 을
   "사전 논의가 전혀 없었던, 완전히 새로운 ChatGPT 대화창"
   에서 수행하도록 요구한다.

   현재 ChatGPT 대화창
     Reviewer / Challenger
     이 작업의 지시어를 계속 검토했으므로
     §13.8 Blind Audit 자격이 없다

   새 ChatGPT 대화창
     필요 시 Stage 11B Blind Auditor

   Reviewer 역할과 Blind Auditor 역할을
   같은 대화창이 겸할 수 없다.

5. §13.7 계열 묶음 인지

   원문이 정하는 것
     §13.7 은 Stage 11 에 한해
     동일 AI 계열 내부의 설계에서 최종 감사까지만으로
     최종 진실을 확정하는 것을 허용하지 않고,
     다른 AI 계열의 독립 재도출을 의무화한다
     (L2163 · L2224 · 확립 근거 사례 L2165).

   이 결정이 정하는 것
     이 B2 actor 분류에서는
     Claude Chat 과 Claude Code 를
     §13.7 의 same-family side 로 취급한다.

     §13.7 원문이 이 두 이름을 한 계열로 직접 지목한 것은
     아니다. 이 분류는 이 Human Decision 의 판단이다.

   따라서
     Claude Chat 의 Governance Audit 은
     §13.7 이 요구하는 "다른 계열 재도출" 을
     충족하는 것으로 간주하지 않는다.
     또한 아래 6 의 이중 검증 인원으로도 세지 않는다.

     Stage 11 이 호출되는 작업에서는
     §13.7 을 우회하지 않는다.

6. B2 문서 거버넌스 전용 Gate Set

   §39 Mandatory Dual Verification 준수

     §39 (L3029 "## 39. Mandatory Dual Verification Standard")
     는 검증을 최소 이중으로 수행하도록 요구한다.

     이번 B2 gate 의 planned verifier 조합은
       Cursor + Codex
     로 한다.

     직접 근거
       §39.1 L3035
         "기본값: Cursor + Codex 이중 검증(또는 상황에 맞는 다른 두 행위자 조합)."

     참고 근거 (직접 근거로 쓰지 않음)
       §40.1 L3059
         "정식 검증자 2명(Claude Code + Cursor 또는 Codex,
          §35/§36/§39 기준)"

       이 문구는 §39 본문이 아니라
       §40 (L3047 "## 40. Tool Trial: Gemini Antigravity
       Observer Period") 의 §40.1 (L3053) 안에 있다.

       또 문법상
         Claude Code + (Cursor 또는 Codex)
       로 읽히므로 Cursor + Codex 조합의 직접 근거가 아니다.
       §39 계열의 복수 검증 구조를 확인하는
       참고 근거로만 둔다.

     따라서 이 gate set 은 §39 의 면제를 구하지 않는다.
     §39 를 충족한다.

   verifier 확정 절차 (§3 과 동일 원칙)

     이번 batch 의 planned repository write actor 는
     Claude Code 이다.

     write 완료 후 §37 author-check 에서
     actual author set 이 Claude Code 단독으로 확인되면,
     Claude Code 를 verifier 에서 제외하고
     planned dual verifier 인 Cursor + Codex 를 확정한다.

     actual author set 에 Cursor 또는 Codex 가 포함되면
     해당 actor 는 verifier 에서 제외하고 STOP 한다.
     대체 verifier 를 Human 또는 Claude Chat 이 정한다.

   Human 은 B2 문서 거버넌스 작업에 한해
   다음 gate set 을 승인한다.

     Human
       변경 boundary 승인

     Claude Code
       write
       자기 보고는 IMPLEMENTATION_COMPLETED 까지

     Codex
       independent diff verification
       PASS / FAIL

     Cursor
       independent repo-wide 대조 verification
       (참조 정합 · 파일시스템과 Index / Map 대조 ·
        잔존 옛 경로 참조 검색)
       PASS / FAIL
       production write 없음

     Claude Chat
       Governance Audit
       raw diff · 원문 · governance 정합 직접 검토
       AUDIT_CLEAR / BLOCK
       이중 검증 인원에 포함되지 않는다

     Human
       최종 수용 · commit 또는 closure 결정

   두 검증자의 판정이 갈리면 해소하지 않고
   양쪽 원문을 그대로 Human 또는 Claude Chat 에 올린다.

   §3 와 §13 Stage 11 과 판정 의미를 구분한다.

     Codex 와 Cursor   PASS / FAIL
     Claude Chat       AUDIT_CLEAR / BLOCK
     Human             최종 수용 / closure

   Stage 11 에서 사용하는
     Final ACCEPT / REJECT authority 및
     AuditReview.md 의
     ACCEPT / APPROVE_WITH_NOTES / BLOCK
   표현은 이 B2 전용 gate set 에서 사용하지 않는다.

   이 gate set 은 위 적용 범위에만 쓴다.
   sql/ · runtime · application code 에는 적용하지 않는다.

7. Conflict / Precedence Rule
   이 B2 적용 범위에 한하여,
   000701 §3 또는 000752 §9 등 기존 actor 규정이
   구현자를 Codex 로 지정하는 것으로 해석되는 경우에도,

   HD-ACTOR-01 의 B2-specific actor assignment 가
   그 actor assignment 에 한해서 우선한다.

   이 override 는 오직 actor assignment 에 한정한다.

   §3 의 stage structure ·
   author-exclusion (§37) ·
   §39 이중 검증 인원 규정 ·
   verification discipline ·
   Human gate ·
   Stage 11 과 Stage 12 규칙의 일반 효력까지
   supersede 하지 않는다.

   §39 는 위 6 에서 면제하지 않고 충족한다.
   Antigravity 제외는 §40 기본값의 supersede 가 아니다
   (위 2 참조).

   §3 이 B2 작업에 원래 적용되는지 여부는
   여전히 UNDETERMINED 로 남긴다.

8. 향후 적용 예고
   B2 가 실제 canonical migration chain 구현(sql/)으로
   넘어가는 시점부터는
   §3 workpacket pipeline 과
   §13.6 · §13.7 · §13.8 (11A / 11B / 11C) 이
   전면 적용된다.

   그 시점의 11B Blind Audit 은
   새 ChatGPT 대화창에서 수행한다.
   현재 Reviewer 대화창은 그 역할을 맡을 수 없다.

   sql/ 구현의 구현자 지정은 이 결정이 정하지 않는다
   (HD-ACTOR-02 등 별도 결정).

9. 발효 시점
   이 Mapping 은 Batch 1 의 repository 반영이
   이중 독립 검증과 Human 수용을 거친 뒤 발효한다.

   Batch 1 자체는 Human 이 부여한
   Batch 1 전용
     explicit execution authority    (Claude Code)
     explicit verification authority (Cursor 와 Codex)
   로 수행한다.

   이 explicit authority 는 §37 author-exclusion 과
   §39 이중 검증 요건을 supersede 하지 않는다
   (위 3 과 6 참조).

10. 000752 §9 정합화 (Batch 1 필수)
    다음 줄을 이 결정에 맞춰 갱신한다.
    기존 항목을 삭제하지 않고 적용 범위를 구분해 서술한다.

      §9 역할 표의 `운영 앵커 · Claude Chat` 행
            역할명 정합 (Primary Anchor /
            Governance Keeper · Governance Audit)
      §9 역할 표의 `전략 앵커 · ChatGPT` 행
            Independent Reviewer / Challenger
      §9 역할 표의 `구현 · Codex` 행
            B2 문서 거버넌스 범위에서는 Claude Code
            (범위 구분 명시 · 기존 항목 유지)
      §9 의 `Fast Lane` 경로
            사용자 -> Claude Chat -> Codex / Cursor -> 구현
            B2 문서 거버넌스 범위의 경로를 구분해 기재

    갱신하지 않으면 같은 문서가 상충하는 역할 표
    두 개를 보유한다.
```

**`HD-STRUCT-01` 전문**

```text
HD-STRUCT-01 · 2026-09-30 KST · APPROVED
provenance: Human approval declared in Claude Chat
            conversation, 2026-09-30 KST
            사용자 지시 "이걸 채워주세요" 로
            아래 승인 문안을 채택
            승인 문안 초안 출처:
              ChatGPT conversation, 2026-09-30 KST
            승인 문안:
              "번호 방식은 안 A 를 선택합니다.
               Canonical Design Invariant Evidence 의
               영구 문서번호를 다음과 같이 확정합니다.
                 500000_Readme_Canonical_Design_Invariant_
                   Evidence.md
                 500001_Evidence_Canonical_Design_Invariant_
                   Tenant.md
                 500002_Evidence_Canonical_Design_Invariant_
                   Store.md
               이 결정은 미래 문서번호를 예약하는 결정이
               아닙니다. 향후 문서번호는 실제 문서 생성
               시점에 기존 governance 에 따라 next available
               number 를 다시 측정하여 배정합니다.
               위 번호 결정을 반영한 HD-STRUCT-01 을
               승인합니다."
            Claude Chat confirmation: 2026-09-30 KST

내용 - Canonical Design Invariant evidence 의
       영구 governed 위치 확정

  1. 지위 선언
     Human 은 다음 두 파일을 governed document 로 선언한다.

       docs/implementation_evidence/
         b2_canonical_design_invariant_extraction/00_Tenant.md
       동 폴더/01_Store.md

     선언의 관찰 근거
       두 파일이 머리에 Status: Active ·
       Lifecycle: Evidence · DocumentType: Evidence 를
       스스로 선언한다
       Evidence 는 000002 §1.2 Group B 의
       승인 DocumentType 이다
       후속 모듈이 이 파일을 기준원으로 읽는다
       (01_Store.md L30 · L31 · L45 · L50 · L105)
       문서 간 안정 evidence ID 참조가 성립했다
       (01_Store.md 의 XREF (T-N) 18회 · 고유 10개)
       Coverage Matrix 와 Required Invariant 판정을 보유하며
       세션을 넘어 유지된다

     이 선언은 Human Decision 으로 지위를 정하는 것이며,
     두 파일이 과거에 이미 governed 였다고 소급 판정하지
     않는다. 기존 커밋을 위반 상태로 만들지 않는다.

     선언의 효과

       Batch 1 은 두 파일을
       "governed Evidence 로 지정되었으며
        structural migration 대기 중"
       인 대상으로 등록한다.

       000001 §5 L44 · §5.0 L57 · 000002 §1 L15 의
       six-digit naming 과 governed location 의무는
       Batch 2 Structural Migration 의 atomic 적용과 동시에
       발효하고 충족한다.

       Batch 1 완료와 Batch 2 완료 사이의 상태를
       기존 파일에 대한 새로운 governance violation 으로
       판정하지 않는다.

       Batch 2 가 시작된 뒤에는
       이름 변경 · 이동 · Index / Map / Readme 정합을
       하나의 atomic migration 으로 완료해야 한다.

  2. 위치 - 500000 evidence band
     근거
       000002 §4 L373: 500000~599999 는
       evidence · audit · legal hold · export ·
       retention · compliance packet 예약 영역이다.
       이 evidence 는 구현 산출물의 증거가 아니라
       기존 canonical source 로부터 design invariant 를
       발췌 · 감사한 Evidence 이므로
       600000 의 "implementation evidence" 보다
       500000 의 성격에 대응한다.

     배제
       600000: 600020 §1.3 이 600000 대역을
       NON-AUTHORITATIVE BY DEFAULT 로 판정했다.
       기준원을 기본 비권위 대역에 두지 않는다.

       000700: Readme 의 범위 서술
       (AI prelearning · project context · onboarding)
       과 발췌 evidence 의 성격이 다르다.

  3. 폴더 번호 - band root (500000)
     Dry-Run 실측 결과 band root 사용안과
     하위 번호 사용안이 모두 RULE_SUPPORTED 이며
     ONLY RULE-COMPATIBLE CANDIDATE 가 없었다.

     규칙이 둘 다 허용하므로 기존 형태를 따른다.
       band root 를 폴더로 쓰는 형태는
       600000 · 700000 · 900000 · 990000 네 건이 존재한다
       band root 를 비워 두고 하위 번호만 최상위에 두는
       형태는 저장소에 없다

     이 선택은 선례로 허용을 만든 것이 아니라,
     규칙이 허용하는 두 안 중에서 기존 관행을 택한 것이다.

  4. 배정 대상과 파일명

     폴더
       docs/500000_canonical_design_invariant_evidence/

     파일
       500000_Readme_Canonical_Design_Invariant_Evidence.md
       500001_Evidence_Canonical_Design_Invariant_Tenant.md
       500002_Evidence_Canonical_Design_Invariant_Store.md

     영구 이름에 프로그램 단계명(B2)을 넣지 않는다.
     이 문서의 지위는 Canonical Design Invariant Evidence 이며,
     B2 는 그 지위가 아니라 생산 프로그램의 이름이다.

     provenance 는 각 파일의 머리 필드로 보존한다.
       Origin Program: B2 Canonical Design Invariant Extraction
       Original Path:
         docs/implementation_evidence/
           b2_canonical_design_invariant_extraction/<원래 파일명>

     H1 은 각 파일명과 동일하게 맞춘다
     (000002 §6 L419-L421 · Check-Governance G09 (000001 §2 / 000002 §6)).

     Readme 와 Evidence 는 000002 §1.2 의
     승인 DocumentType 이다.

     번호 방식 - 연번 (Human 선택)

       Human 은 연번 방식을 선택한다.
       500000 · 500001 · 500002

       근거
         아래 5 의 무예약 방침과 자동 정합한다.
         next available 측정이 항상 다음 번호를
         반환하므로 별도 numbering policy 를
         신설할 필요가 없다.

       검토했으나 선택하지 않은 안
         10단위 lane (500000 · 500010 · 500020)
         이 안은 폴더 Readme 에 10단위 lane 을
         정식 번호 배정 규칙으로 선언해야 성립한다.
         선언 없이 쓰면 next available 측정이 500001 을
         반환해 이후 문서가 역순으로 배정된다.
         현재 evidence 문서를 모듈당 여러 하위 문서로
         분할할 계획이 확인되지 않아,
         새 배정 규칙을 신설할 실익이 작다고 판단했다.

       이 결정은 500001 과 500002 두 번호를
       실제 생성 대상에 배정하는 것이며,
       미래 문서번호를 예약하는 결정이 아니다.

  5. 미래 문서번호를 예약하지 않는다
     Dry-Run 결과 개별 문서번호 예약을 지원하는 조항은
     RESERVATION_UNDETERMINED 였다
     (대역과 범위 단위 예약만 000002 §3 · §4 에 존재).

     이번 migration 에서 배정하는 번호는
     위 세 개뿐이다.

     Actor · Authority Kernel · register_waiting ·
     압축 결과 문서의 번호는 각 문서를 실제로 생성하는
     시점에 000005 기준 next available number 를
     다시 측정해 배정한다.

     폴더 구조의 예상도를 그리는 것은 무방하나,
     생성되지 않은 문서번호에 RESERVED 지위를 부여하지
     않는다.

  6. 작업의 성격 정의
     이 작업은 archival renaming 이 아니다.
     temporary 이며 governance-excluded 인 위치에 생성된
     governed Evidence 를 canonical governed namespace 로
     교정 이전하는 structural migration 이다.

     근거
       000701 §15.1 L2414-L2418 은
       change artifact 의 working-name 과
       archived-name 이중 이름 유지를 부정하는 조항이며,
       이 두 파일은 change artifact 가 아니고
       이전 후에도 이름을 하나만 갖는다.

       000701 §33 L2889 및 000001 §5.4.2 L172 가
       영구 보관 위치로의 이전 자체를 금지하지
       않는다고 명시한다.

  7. Stage archive trigger 는 이 결정의 근거가 아니다
     000001 §5.4.2 L178 은 Stage 7,
     000701 §33 L2889 는 Stage 12 로
     archive trigger 를 다르게 적는다.

     또 000001 §5.4.2 L166 의 적용 대상은
     lifecycle DocumentType 9종이며
     Evidence 는 그 목록에 없다.

     이 Evidence 에 Stage 7 또는 Stage 12 archive trigger 가
     직접 적용되는지는 기존 원문만으로 확정되지 않는다
     (UNDETERMINED).

     따라서 HD-STRUCT-01 은 어느 trigger 도 이전의 근거로
     사용하지 않는다.
     이번 structural migration 의 근거는
     §1 의 governed document 선언과 그에 따르는
     six-digit naming 및 location 의무이다.

     Stage 7 과 Stage 12 불일치 자체는 BL-6 으로 분리한다.

  8. evidence ID 불변
     T-1 ~ T-42 · C-1 ~ C-4 · S-1 ~ S-15 · CS-1 ~ CS-5 와
     XREF (T-N) · XREF (C-N) 표기는 이전 후에도 유지한다.
     이번 structural migration 에 한하여 Human 은

       docs/implementation_evidence/b2_canonical_design_invariant_extraction/00_Tenant.md
       docs/implementation_evidence/b2_canonical_design_invariant_extraction/01_Store.md

     안에 현재 존재하는 T · C · S · CS 계열 식별자와
     XREF 표기를 migration 과정에서 변경 · 재부여 · 삭제하지
     않는 것으로 결정한다.

     이 결정은 project document number 규칙이나
     향후 Evidence 전체에 적용되는 identifier 체계를
     신설하지 않는다.
     구조 이전을 이유로 재부여하지 않는다.

  9. Governance TOTAL
     이전 후 TOTAL 변동은 실패가 아니다.
     제외 경로를 벗어나 검사 대상이 되는 것이
     이 작업의 목적이다.
     이전 baseline (TOTAL 509 · excluded 738 files ·
     43 directories) 를 기록하고,
     이전 후 측정값의 변동 원인을
     신규 governed 파일과 등록에 대조한다.

     tools/GovernanceExclusions.ps1 L22 의
     implementation_evidence 패턴은 유지한다.
     Dry-Run 실측 결과 601700 · ctn1a · order_sessions
     3개 폴더 24개 파일이 남는다.

 10. 000752 §2 의 과거 관측값은 수정하지 않는다
     §2 의 git status 관측 블록(현 L74)은
     측정 시점의 사실 기록이다.
     경로가 바뀌었다는 이유로 사후 수정하지 않는다.
     다음 SESSION END 의 §2 rollover 에서
     현재값으로 교체된다.

 11. Batch 구성
     Batch 1  Governance Registration
                000752 §3 HD-ACTOR-01 · HD-STRUCT-01 등재
                000752 §9 역할 표 정합화
     Batch 2  Structural Migration (atomic)
                폴더와 Readme 신규 · git mv 2건 ·
                H1 교체 · provenance 머리 필드 추가
                01_Store.md basename 참조 7곳
                000005 · 000007 · 000000_Readme_Root §3
     Batch 3  Closure
                000752 §4 BL-5 RESOLVED

     각 batch 는
       Human 승인 -> Claude Code write ->
       Cursor + Codex PASS/FAIL ->
       Claude Chat AUDIT_CLEAR/BLOCK ->
       Human 수용
     순서를 따른다 (HD-ACTOR-01 §6).

     BL-5 는 Claude Code implementation batch 에서
     RESOLVED 로 닫지 않는다.

 12. 미결 항목
     BL-5  implementation_evidence 정의와 용도 불일치
           Batch 3 에서 이 범위에 한해 RESOLVED
     BL-6  000001 §5.4.2 Stage 7 과 000701 §33 Stage 12
           archive trigger 불일치
           (신규 · 이번 작업의 blocker 아님)

     OBSERVATION_ONLY / GOVERNANCE_HYGIENE
     (정식 backlog 로 승격하지 않는다 ·
      이번 migration 의 blocker 아님 ·
      이번 작업에서 고치지 않는다)
       000000_Readme_Root §3 에 실재하지 않는 폴더 9건
       (011500 · 016000 · 018000 · 019000 · 023000 ·
        025000 · 027000 · 029000 · Temp) 등재
       000000_Readme_Root §3 에
       실재하는 600000 · 990000 누락
       000005 의 절이 번호순으로 정렬되어 있지 않음
       000005 L2906 "## 149" (601500) 절 아래에
       601700 · 601800 · 601900 · 602000 행 혼입
       602000 Readme §2 가 소유 구간을 602999 로
       자체 축소 선언 (000002 §2.1 계산은 603999)
       000005 에 실제 파일 없는 등재 9건
       (deprecated forwarder 2 · 파일명 drift 6 ·
        quarantine 1)
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
| 권위 보류 | 0-A 1차 (`601500`) | `600020` §1.1 직접 suspension · §1.2 파생 HOLD 는 당시 기존 0-A-2 / 0-A-3 / 0-B 에 적용 · `601700` / `601702` 는 §2 의 새 0-A authority path 이며 위 suspension / 파생 HOLD 에 자동 포함되지 않음 — `HD-AMB-01` |
| 유효한 금지 | `601505` §4 `isolate_tenant` 등 호출 금지 | `600020` L98 |

```text
Legacy Committed Migration Line 0000~0178
  STATUS: HOLD
  NO FURTHER NON-EMERGENCY PATCH
  pending Rebuild Feasibility Spike
  파일 삭제 금지. 실행 이력·포렌식 증거로 보존한다.
  emergency 판단은 Human Decision 으로만 한다.
  2026-09-26 기준 sql/migrations/ 의 번호형 migration line 은
  Legacy committed migration line 0000~0178 과 정렬되었다
  (커밋 9252491).

0179 CTN-1a Prototype
  STATUS: SUSPENDED / PROTOTYPE
  canonical migration line 에 포함하지 않는다
  처분은 `HD-0179-01` 로 결정되었다 (D-2 · archive) · 삭제하지 않는다
  DISPOSITION: ARCHIVED (HD-0179-01 · 커밋 9252491)
  현재 위치:
    docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/
    0179_ctn1a_revoke_isolate_tenant_execute.sql
  sql/migrations/ 에는 더 이상 존재하지 않는다.
  local DB 적용 이력은 사실로 보존한다 (601513).

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

### Backlog

이번에 고치지 않는다. 기록만 한다.

```text
BL-1  602061 이 000005 · 000007 에 미등재
      (커밋된 상태의 drift)

BL-2  010661 이 000007 에 미등재
      (커밋된 상태의 drift)

BL-3  000005 의 status 컬럼이 authority 근거로 신뢰 불가
      601800 은 본문이 Status: Suspended 인데
      카탈로그는 active 로 표기

BL-4  카탈로그 ↔ 실제 파일 drift

      이전 측정 스냅샷:
        CATALOG_ONLY 9
        FILE_ONLY 154
        docs 실제 .md 2437

      측정 기준:
        HEAD 78f16c5 + 당시 working tree
        2026-09-26
        이후 602060 등재가 완료되었으므로
        현재 수치가 아니다.

      현재 정확한 수치는 차후 hygiene 작업에서 재측정한다.
      이 숫자를 현재값으로 인용하지 않는다.

BL-5  implementation_evidence/ 의 정의와 실제 용도 불일치

      implementation_evidence/ 는
      tools/GovernanceExclusions.ps1 L22
      '^implementation_evidence(/|$)' 로 검사 제외되며
      000001 §5.4.2 는 이를
      "temporary per-change workspace" 로 정의한다.

      그런데 현재 repository 는 CTN-1a evidence 와
      B2 Canonical Design Invariant evidence 처럼
      durable evidence 도 이 경로에 보관한다.

      실제 용도와 exclusion rule 설명이 불일치한다.

      B2 진행 중에는 현 구조를 유지한다.
      경로 · 명칭 · 검사 정책 정비는
      별도 hygiene 작업에서 수행한다.

      B2 blocker 가 아니다.

HD-BASE-01 확인 필요:
  000005 의 000752 등재 행이 HD-BASE-01 을 인용한다.
  이 Human Decision 이 §3 에 실재하는지 확인되지 않았다.
  확인 후 실재하지 않으면 등재 문안을 정정한다.
  확인 결과 (2026-09-26 SESSION END):
    §3 APPROVED 표에 HD-BASE-01 행이 실재한다
    (2026-09-25 22:35 KST · 이 문서 신설 지시).
    등재 문안 정정은 필요하지 않다.
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
Canonical Design Invariant 원문 발췌 재개

  1. Tenant delta 정합화
     - HD-AMB-01 · HD-AMB-02 반영
     - 601702 의 Tenant 관련 선언은 1차 발췌에서
       아직 발췌되지 않았다. 이를 보충한다
     - POLICY_INCLUDED_BY_REFERENCE 채택 범위 중
       Tenant 관련 미반영 evidence 만 보충한다
     - 기존 T-1 ~ T-14 를 처음부터 다시 스캔하지 않는다

  2. 완료 즉시 STEP 3 Store 로 진행

  이후 순서:
    Store → Actor / Access Membership
    → Authority Kernel → register_waiting

완료된 것:
  Tenant 1차 발췌 T-1 ~ T-14 완료
  (HD-AMB-01 / HD-AMB-02 반영 delta 정합화만 남음)
  판정 규칙 ①②③ 확정
  HD-AMB-01 · HD-AMB-02 확정

발췌 완료 후:
  Claude Chat 이 invariant 압축 초안 작성
  → ChatGPT Critical Lane 검토
  → Human 승인
  → Codex 가 승인된 Target Specification 만 구현
  → Rebuild Feasibility Spike (Test 0 + 5)
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
| 운영 앵커 | Claude Chat | 진행 상태 · 문서 번호 · 규칙 · 워크패킷 · 다음 작업 통제 — Primary Anchor / Governance Keeper · Governance Audit (AUDIT_CLEAR / BLOCK) (`HD-ACTOR-01`) |
| 전략 앵커 | ChatGPT | 전체 아키텍처 · 방법론 · scope drift · patch loop 여부 · 방향 전환 — 역할명 Independent Reviewer / Challenger · 현재 Reviewer 대화창은 000701 §13.8 Blind Audit 자격이 없다 (`HD-ACTOR-01`) |
| 상태의 정답 | Git Repository | HEAD · canonical 문서 · 현재 baseline |
| 구현 | Codex | 승인된 범위만 코드 · SQL 구현 — 범위 구분: sql/ · runtime · application code 는 Codex (기존 유지) · B2 문서 거버넌스 범위의 구현은 Claude Code, Codex 는 그 범위의 Independent Verifier (`HD-ACTOR-01` Transitional Actor Override) |
| 전수 검색 | Cursor | repo-wide 영향 범위 · 누락 검색 — B2 문서 거버넌스 범위에서는 Independent Verifier (repo-wide 대조) (`HD-ACTOR-01`) |
| 최종 승인 | 사용자 | 중요한 방향 결정 |

두 앵커는 서로의 상사가 아니다. 비대칭이다.
Claude 가 매일 개발을 끌고 간다. ChatGPT 는 모든 일을 다시 검토하지 않는다.
잘못된 방향으로 멀리 가기 전에 브레이크를 거는 역할이다.

### Fast Lane / Critical Lane

```text
Fast Lane      일상 개발 80 ~ 90%
               사용자 → Claude Chat → Codex / Cursor → 구현 · 테스트
               예: 메뉴 필드 추가 · UI 수정 · 일반 버그 · 테스트 · 명확한 migration · 색인 등록
               B2 문서 거버넌스 범위 (HD-ACTOR-01)
               사용자 → Claude Chat → Claude Code (write) → Cursor + Codex (검증)
                 → Claude Chat (Governance Audit) → 사용자 (수용 · closure)

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

## 세션 갱신 이력

```text
2026-09-26 세션

  커밋 4건
    8e45bf2  000752 Baseline 등재 (B2 handoff anchor)
    4ec423c  CTN-1a Stage 1~6 evidence 보존 (SUSPENDED)
    f7cc5f3  RG-06 미완성 판본 evidence 등재
    9252491  0179 prototype archive (migration line 밖으로)

  Human Decision 4건 확정
    HD-METHOD-02 · HD-AMB-01 · HD-AMB-02 · HD-0179-01

  Check-Governance TOTAL
    511 → 509
    G11 등재 누락 1건 해소 (602060)
    G15 Stage 7 gate WARN 1건 해소 (0179 이동)

  주요 정정
    602060 은 RG-F15 evidence 가 아니라
    RG-06 (H-03) gate 문서의 미완성 판본이다.
    PASS 근거로 인용하지 않는다.
    RG-F15 가 602060 의 HD-3 을 인용하는 방향이다.

  push 상태
    이 갱신 커밋까지 포함해 push 예정.
    push 완료 여부는 다음 세션이 실측으로 확인한다.
```

## §8 Last Updated

| 항목 | 값 |
|---|---|
| 일자 | 2026-09-26 KST |
| 갱신자 | Claude Code |
| 갱신 시점의 HEAD | §2 현재 baseline 의 "마지막 작업 커밋" 참조 — §8 은 별도 HEAD 값을 보유하지 않음 |

세션 종료 시 갱신 (SESSION END)
