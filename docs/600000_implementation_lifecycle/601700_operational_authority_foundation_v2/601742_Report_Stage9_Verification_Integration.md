# 601742_Report_Stage9_Verification_Integration.md

Status: Active
Lifecycle: Report
Last Updated: 2026-08-24

## Change ID

Workpacket: 601700

## §0 이 문서의 지위

`000701` §9 가 Stage 9 통합자로 지정한 Claude 가 작성한다.

```text
Verifier A   Claude Code   601740   커밋 1f9b442
Verifier B   Cursor        601741   커밋 78a31d3
supplemental Cowork        601739   커밋 614244f
```

**통합자는 설계·계약 문서(`601710`/`601713`/`601716`/`601717`)의 원작자가 아니다.**

> ⚠️ **DocumentType 을 `Report` 로 둔 이유**
>
> `000701` 이 지정한 Stage 9~11 산출물명이 `000002` §1.2 승인 목록에 없다 —
> `VerificationResult`(`601740`) · `MinorOpinion`(`601741`) · `AuditReview`(`601744`).
> **셋 다 G02 ERROR 로 검출된다.** 상세는 §3.4.
> **이 문서가 세 번째 위반을 만들지 않도록 승인 타입 `Report` 를 사용한다.**
> 그 spec conflict 자체는 §5 에 기록한다.

## §1 Verifier A 결과 승계 — `601740`

```text
Test ID inventory   정의 236 / 폐기 1(TP-RT-03) / 활성 235
전건 판정            누락 0
실제 실행            229
PASS 221 / FAIL 8 / SKIP 6

IMPLEMENTATION_DEVIATION_OBSERVED   0
TestPlan 결과   TESTPLAN FAILURES FOUND + NOT FULLY EXECUTED
Stage 9 상태     INCOMPLETE
```

### §1.1 FAIL 8건 — root cause 4건 + 파생 4건

| Test ID | 관측 | 성격 |
|---|---|---|
| `TP-M-07` | O-1 | root — `0171` 내부 순서 |
| `BL-33` | O-2 | root — `stores` 트리거 총계 |
| `TP-R-19` | O-2 | 동일 root |
| `BL-22` | O-3 | root — `stores` 참조 FUNCTION 수 |
| `TP-R-14` | O-3 | 동일 root |
| `TP-M-08` | O-4 | root — clean baseline replay |
| `AC-7` | — | 파생 (TP-R-14 · TP-R-19) |
| `AC-9` | — | 파생 (TP-M-07 · TP-M-08) |

**고유 root cause 는 4건이다.** 「구현 결함 8건」이 아니다.

### §1.2 SKIP 6건

| Test ID | 사유 |
|---|---|
| `TP-RT-04` | `NOT_EXECUTED` — 앱 빌드·테스트 스위트 미실행. delta 에 앱 변경 0건 |
| `TP-RT-08` | `FORBIDDEN_FUNCTION_CALL` — 호출 금지 함수 |
| `TP-RB-03` | `DISPOSABLE_BASELINE_NOT_FAITHFUL` |
| `TP-RB-08` | 동일 |
| `AC-1` | `PRE_IMPLEMENTATION_GATE_NOT_OBSERVABLE_POST_HOC` |
| `AC-13` | `SPEC_CONFLICT_AC13` — §3 참조 |

**PASS 로 추정된 것은 없다.**

## §2 Verifier B concern 처분 — `601741`

### §2.1 제기된 concern

```text
MATERIAL_CONCERN 1건

601740 §1.2 L61 이 601716 의 git blob SHA-256 「일치」를 주장하나
독립 재측정에서 672ED1D1…DC3 이 나왔다.
worktree 에 skip-worktree 가 걸려 index/HEAD 와 내용이 갈라져 있다.
```

### §2.2 판정 — `INVALIDATED`

**통합자가 독립 재측정했다.**

```text
skip-worktree 확인
  git ls-files -v docs | grep '^S'   →  0건

repository blob 바이트 정확 측정
  cmd /c "git cat-file blob HEAD:<601716 경로> > tmp_blob.bin"
  Get-FileHash tmp_blob.bin -Algorithm SHA256

  결과   00C1376EB1230A4B68F27C1479681C5BC95B23A8801EE70364EAACF22719F102
  601717 §10.8 기록값과 완전 일치
```

**무효 사유 2건**

```text
① git ls-files -v 의 H 플래그를 skip-worktree 로 오독했다
   H = cached (정상 추적)
   S = skip-worktree
   docs 하위 2405건이 전부 H 이며 이는 정상 상태를 뜻한다

② SHA 측정 방법이 repository blob 의 바이트 동일성을 보존하지 못했다

   git cat-file -s HEAD:<601716 경로>   →  88800 bytes
   worktree 파일 크기                    →  88800 bytes
   → blob 과 worktree 의 내용이 동일하다

   601741 이 적은 70223 bytes 는 실제 blob 크기와 다르다
   내용이 같은데 다른 해시가 나왔다면 측정 파이프라인이
   바이트를 변형한 것이다

   cmd 리다이렉션으로 바이트 그대로 측정하면 일치한다
```

**따라서**

```text
contract drift          없음
implementation deviation 없음
601740 §1.2 의 판본 일치 주장   유효
```

> ⚠️ **`601741` 을 수정하지 않는다.**
> 검증자의 finding 은 권위가 아니라 evidence 다.
> **오판을 원본 그대로 보존하고 상위 통합에서 재측정으로 기각하는 것이
> 이 체계가 작동하는 방식이다.**

### §2.3 그 외

```text
discrepancy   0건 — 235/235 대조 완료
IMPLEMENTATION_DEVIATION_OBSERVED = 0 판정에 concern 없음
Stage 8 delta (df49eb56..bc4cd14) 가 §1.1 A-1·A-2 범위 내
AC-13 SKIP · INCOMPLETE 서술 · 권한 준수에 concern 없음
```

## §3 통합자 직접 검토

**`601740` · `601741` · raw_logs 를 직접 읽었다.**

```text
601740   §0 · §1 · §2 · §3 · §4 · §5.1~§5.11 · §6.1~§6.3 · §7 · §8 · §11
601741   전문
raw_logs 11_regression / 14_replay 를 601740 서술과 대조
```

### §3.1 O-2 확인 — 산술적으로 양립 불가

```text
D-19 를 실행하면   stores 에 FK RI 트리거 2건이 생긴다
BL-33 기대값       241 (증가 없음)
실측               243
```

**계약이 FK 생성을 요구하면서 TestPlan 이 트리거 증가를 0 으로 기대했다.**

user-visible 트리거는 여전히 1건(`trg_stores_updated_at`)이므로
TP-R-19 근거란의 「backfill 중 트리거 우회·비활성화 금지」 취지는 충족된다.

### §3.2 O-3 확인 — 158 이 재현되지 않는다

```text
601701 D-3            151
601718 / 601719       158
601740 4가지 측정법    전부 151

0170 · 0171 은 CREATE OR REPLACE FUNCTION 0건
→ 모집단이 이 구현으로 증감할 수 없다
```

**151 vs 158 은 `601702` §2.2 가 이미 미결로 등재한 항목이다.**

### §3.3 O-4 확인 — 이 워크패킷 밖의 원인

```text
clean replay 중단   [93] 0093_create_message_catalog_complete.sql
원인                chk_error_domain
                    canonical 23도메인 / clean replay 18도메인
                    MENU 도메인 부재
canonical 기록      0093 = success=true (2026-07-09)
```

**`0170`·`0171` 에 도달하기 전에 실패했으므로 두 migration 과 무관하다.**

보충 실행(실패 허용)에서 `0170`·`0171` 은 둘 다 `rc=0` 이었으나
절차가 다르므로 TP-M-08 의 PASS 로 적지 않았다. **그 판단이 옳다.**

### §3.4 새 관측 — G02 DocumentType 충돌 3회

```text
000002 §1.2 승인 목록
  Plan / Checklist / SOP / Runbook / Report /
  Evidence / Audit / ADR / WorkPackage / Closeout

000701 §9      산출물명 VerificationResult.md
000701 §12.9   산출물명 MinorOpinion.md
000701 §13.4   산출물명 AuditReview.md

검출

  601740 · 601741 · 601744 각각 G02 ERROR
    'VerificationResult' is not in the approved list
    'MinorOpinion' is not in the approved list
    'AuditReview' is not in the approved list

  601741 은 커밋 시 pre-commit hook 이 직접 출력했다

재현 실패와 그 원인 (2026-08-24 확정)

  2026-08-24 중간 보고에서 「사후 재실행에서 G02 에 잡히지 않았다」는
  관측이 있었고 통합자가 이를 검증 없이 받아들여 §3.4 를 잘못 정정했다.

  원인 두 가지가 이후 확정됐다.

  ① -Top 50 출력 절단
     600000 대역 G02 는 68건인데 50건만 출력된다
     601740 · 601741 이 절단 구간에 있었다

  ② -File a,b 호출이 배열로 넘어가지 않았다
     "0 markdown documents scanned" 상태에서 G02 = 0 을 읽었다

  두 실행 모두 측정 오류이며 G02 는 실제로 검출된다.

체커 승인 목록 실측 (tools/Check-Governance.ps1 L193)

  $GroupC 에 'Verification' 이 있으나 'VerificationResult' 는 없다
  'MinorOpinion' · 'AuditReview' 도 없다
  → 문자열이 달라 매칭되지 않는다
```

**`SPEC_CONFLICT_OBSERVED` — AC-13(O-5)과 같은 계열이다.**

> ⚠️ **`000701` 이 지정한 Stage 9~11 산출물명 셋이
> 모두 `000002` 승인 목록 밖이다.**
>
> ```text
> 000701 §9      VerificationResult.md
> 000701 §12.9   MinorOpinion.md
> 000701 §13.4   AuditReview.md
> ```
>
> **단발 오류가 아니라 두 상위 규칙의 구조적 불일치다.**
>
> ⚠️ **통합자가 검증 없이 보고를 받아들여 정확한 서술을 부정확하게 바꾼 사례다.**
> `000701` §13.6 이 요구하는 「원본 증거 직접 재도출」이
> **통합 단계에서도 필요하다는 것을 보여준다.**

**세 번째 위반을 만들지 않기 위해 이 문서는 `Report` 를 사용했다.**

## §4 Stage 9 상태 판정

```text
Stage 9 = INCOMPLETE
```

**`601740` 의 판정을 유지한다.**

**사유**

```text
unresolved SPEC_CONFLICT   O-1 · O-2 · O-5 · §3.4 (4건)
EVIDENCE_GAP               O-3 · O-4 · O-8 (3건)
NOT_EXECUTED               O-6 · O-7 (2건)
required test SKIP         6건
```

> ⚠️ **구현 결함 때문이 아니다.**
>
> ```text
> IMPLEMENTATION_DEVIATION_OBSERVED   0
> implementation delta                허용 파일 2건뿐
> 0170 · 0171                         계약과 문자 단위 일치
> COMMENT literal 4건                  exact
> 물리 객체명                          exact
> 금지 조작                            전부 0
> ```
>
> **구현은 계약을 벗어나지 않았다.**
> `INCOMPLETE` 는 spec conflict 와 evidence gap 때문이다.

## §5 Stage 11 / Human 으로 이관

**통합자는 아래를 최종 판정하지 않는다.**

| # | 항목 | 판정해야 할 것 |
|---|---|---|
| I-1 | O-1 `TP-M-07` | TestPlan 문면이 오기인가 / 계약 D·M 순서가 오기인가 / 둘 다 유효하고 참조 무결성만 요구한 것인가 |
| I-2 | O-2 트리거 총계 | TestPlan 기대값 241 을 정정할 것인가 |
| I-3 | O-3 FUNCTION 수 | 158 의 출처를 재조사할 것인가. `601702` §2.2 와 함께 처리 |
| I-4 | O-4 clean replay | `0093` blocker 를 별건으로 다룰 것인가. TP-M-08 을 이 나선에서 요구할 것인가 |
| I-5 | O-5 AC-13 | Stage 9 actor 배정과 AC-13 중 무엇이 우선인가 |
| I-6 | §3.4 DocumentType | `000002` 승인 목록을 확장할 것인가 / `000701` 산출물명을 바꿀 것인가 |
| I-7 | O-8 rollback 기준선 | 역방향 산출물을 요구할 것인가 |

**어느 것도 구현 결함이 아니다.**

## §6 Stage 10 이관

```text
A-3   601722_Module_Operational_Authority_Foundation_V2.md   미생성
A-4   601700 Readme §8 File List
A-5   000005
A-6   000007
```

**색인 3종은 Stage 10 에서 `601722` 와 함께 처리한다**(`601717` §1.2).

`601739` · `601740` · `601741` · 이 문서 모두 아직 미등재이며 **의도된 상태다.**

## §7 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 커밋 |
|---|---|---|
| `601740_VerificationResult_Stage9_…ClaudeCode.md` | 전문 | `1f9b442` |
| `601741_MinorOpinion_Stage9_…Cursor.md` | 전문 | `78a31d3` |
| `601739_Evidence_Stage8_Supplemental_FileScope_Pass_Cowork.md` | §0 · §8 · §9 | `614244f` |
| `601716_TestPlan_…V2.md` | approved SHA-256 | — |
| `601717_ChangeContract_…V2.md` | §1.1 · §1.2 · §1.3 · §1.4 · §4.5 · §10.8 | 승인 기준 커밋 `01cfd45b` (최종 변경 커밋은 `accf0666`) |
| `docs/implementation_evidence/601700/raw_logs/` | 11 · 14 | `1f9b442` · `a2e659c` |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §9 · §12.9 · §37 · §46 | — |
| `000002_Naming_Rules.md` | §1.2 | — |

## §8 이 문서가 하지 않는 것

```text
Stage 9 를 COMPLETE 로 선언하지 않는다
TESTPLAN_DEFECT / CONTRACT_DEFECT 를 최종 확정하지 않는다
601740 · 601741 · 601739 를 수정하지 않는다
색인 3종을 갱신하지 않는다
```

**Stage 11 Audit 과 Human 판정이 남아 있다.**
