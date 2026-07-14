# 000054_Assessment_Workpacket_Overview_Logic_Filename_Convention_Governance_Gap

Status: Draft — Human decision required (§4)
Lifecycle: Assessment
Owner: TBD
Last Updated: 2026-07-14

## §0 DocumentType 정정 (지시받은 "Overview.md" 대신 "Assessment" 사용)

지시문은 이 문서를 "Overview.md"로 작성하라고 했으나, `000002_Naming_Rules.md` §1.2.1을 직접 확인한 결과 `Overview`는 **"Group C — Implementation Lifecycle Only (600000 band)"**로 명시되어 있고, "구현 WorkPackage 전용"이며 "`Overview`를 일반 설명 문서나 계획 문서에 사용하지 않습니다"라고 명시적으로 금지되어 있다. 이 문서는 구현 작업이 아니라 거버넌스 위반 조사·선택지 비교이므로, `Overview`를 그대로 쓰면 **이 문서가 조사하는 바로 그 종류의 명명 규칙 위반을 스스로 저지르게 된다.**

대신 `Assessment`(Group A: "평가, 위험 분석, 적합성 분석, 비교 검토")를 사용한다 — 이번 작업의 실제 성격(두 위반 확인 + 선택지 비교, 결정은 Human)과 정확히 일치한다. `000009`의 유사 선례("Report"로 거버넌스 정정 기록)도 참고했으나, `Report`는 "실행 후 결과"(Group B)로 이 문서가 아직 결정되지 않은 선택지를 다룬다는 점과 맞지 않아 `Assessment`를 선택했다.

## §1 `000701` §15/§33 원문 재확인 (직접 읽음, Cursor/Codex 결과 재확인 완료)

### §1.1 §15 "Recommended Document Folder Structure" (L2063-2112)

핵심 문장(L2067): **"These are permanent PascalCase names (see §33) — no archival renaming step happens later; the name a file is given at creation is its name for the life of the project."**

파일 목록(L2069-2092)은 전부 접두사 없는 순수 PascalCase 이름이다: `00_CursorScan.md`, `01_ImpactScope.md`, `02_Overview.md`, `03_Logic.md`, `04_TestPlan.md`, `05_ChangeContract.md`, `06_ImplementationModule.md`, `07_VerificationResult.md`, `08_MinorOpinion.md`, `09_AuditReview.md`, `10_ReleaseEvidence.md` — 앞의 두 자리 숫자는 **파일시스템 정렬용 로컬 순번일 뿐, 프로젝트 문서 번호가 아니다**(§1.2.2에서 재확인, 아래 §3 참고). 경로는 `docs/implementation_evidence/<change_id>/`다.

§15.1(L2108-2112, "No Archival Renaming"): "As of 2026-07-10, this project performs no archival renaming step at all... There is no working-name/archived-name distinction to maintain, and no second renaming pass to perform when a change is considered 'done.'"

**결론**: §15 어디에도 "600xxx Overview/Logic 파일은 제목 생략 가능"이라는 예외가 없다. 오히려 §15는 애초에 six-digit-prefixed `600xxx_Overview.md` 형태 자체를 규정하지 않는다 — `docs/implementation_evidence/<change_id>/Overview.md`(접두사 없음)가 유일하게 정의된 형태다.

### §1.2 §33 "Pipeline Artifact Filename Convention (PascalCase-Joined)" (L2551-2562)

핵심 문장(L2552-2553): **"As of 2026-07-10, every pipeline-generated artifact defined in this guide uses a PascalCase-joined filename with no underscores and no six-digit prefix: `ImpactScope.md`, `Overview.md`, `Logic.md`, `TestPlan.md`, `ChangeContract.md`, `ImplementationModule.md`, `VerificationResult.md`, `MinorOpinion.md`, `AuditReview.md`, `ReleaseEvidence.md`, `ChangeHistory.md`, `NavigationMap.md`, `CursorScan.md`..."**

두 개의 예외를 명시적으로 열거한다(L2555-2558) — 둘 다 이번 사례와 무관:
- **Project documentation**(`docs/` governed content)은 `000002_Naming_Rules.md`의 six-digit-prefixed `Title_Case_With_Underscores` 규칙을 그대로 쓴다 — "unaffected by this section."
- `sql/migrations/CHANGELOG.md`는 명시적 예외.

L2560: "There is no working-name/archived-name distinction and no renaming step performed later (§15.1) — a PascalCase artifact name is permanent from the moment Stage 1/1.5 creates it..."

**결론**: §33 어디에도 "600xxx Overview/Logic은 제목 생략 가능"이라는 예외가 없다. Cursor/Codex의 "못 찾았다"는 결과가 이번 직접 재확인으로 최종 확정됐다.

## §2 `000009` 확인 결과

`000009_Report_Root_Governance_Rules_Correction_Readme_Index_And_Overview_Logic_Module_Model.md` 전체를 검색한 결과, 파일명 형식 자체를 정의하는 조항은 없다. §9("Files Changed By This Governance Correction")가 `docs/00002_Naming_Rules.md`(5자리 표기, 구식 인용 — 실제로는 `000002_Naming_Rules.md`, 6자리)를 언급할 뿐, 그 문서를 파일명 형식의 유일한 권위로 참조한다. `000009`는 `Overview`/`Logic`/`Module`의 **의미**(무엇에 답하는 문서인가)를 정의하지만 **파일명 형식**은 정의하지 않는다.

## §3 `000002_Naming_Rules.md` — 결정적 신규 발견 (지시받은 A/B 선택지의 전제 자체를 넘어서는 사실)

`000002` §1.2.2 "Development Lifecycle Naming And Order"(L151-190)을 직접 읽은 결과, 예상보다 훨씬 근본적인 사실이 확인됐다:

> "Lifecycle documents use a PascalCase-joined filename with **no six-digit prefix**, placed under a per-change evidence folder: `docs/implementation_evidence/<change_id>/<DocumentType>.md`"
>
> "This scheme **superseded the six-digit `604xxx`-band numbering convention** when that band was **quarantined to `990000_legacy_quarantine/` on 2026-07-10** — see `000701` §15.1."

즉 문제는 "600xxx Overview/Logic 파일에 제목이 빠졌다"가 아니다 — **six-digit 접두사가 붙은 `Overview`/`Logic` 파일 형식 자체가, 2026-07-10부로 이미 대체(superseded)된 예전 방식**이다. 이 세션 전체(`600410`~`600627`, 2026-07-13~07-14 작성)에서 사용한 `docs/600000_implementation_lifecycle/600400_kds_did_implementation/<workpacket>/600611_Overview.md` 패턴은, 그 대체가 일어난 지 3-4일 뒤에 만들어진 것이다.

**이 프로젝트 안에서 실제로 확인되는 세 가지 서로 다른 패턴**(이번 턴 `docs/` 전수 조회로 확인):

| 패턴 | 예시 | 접두사 | 제목 | 위치 |
|---|---|---|---|---|
| (a) `000002` §1.1 canonical(제목 포함, 6자리) | `000067_Overview_WP_8A_001_Read_Only_Codebase_Hydration_...md`, `000086_Overview_WP_9A_001_Hydration_Registry_...md` | O(6자리) | **있음** | `docs/` 최상위 |
| (b) `000002`/`000701` 현재 유효 규정(접두사 없음) | `docs/implementation_evidence/<change_id>/Overview.md` | 없음 | 없음(폴더명이 대체) | `docs/implementation_evidence/` |
| (c) **이번 세션 실제 사용 패턴** | `600611_Overview.md` | O(6자리) | **없음** | `docs/600000_implementation_lifecycle/600400_kds_did_implementation/<workpacket>/` |

(c)는 (a)와 (b) 어느 쪽과도 정확히 일치하지 않는다 — (a)처럼 6자리 접두사를 쓰지만 (a)와 달리 제목이 없고, (b)처럼 제목이 없지만 (b)와 달리 6자리 접두사가 있다. 즉 **"제목이 빠졌다"는 지시문의 원 진단은 정확하지만, 근본 원인은 더 크다** — (c) 패턴 자체가 이 프로젝트 안에 명시적으로 정의된 적이 없다.

## §4 선택지 비교 (결정은 Human, 이 문서는 나열만)

### A) `000002`에 "600000 workpacket band는 제목 생략 가능" 예외 신설

**장점**:
- 오늘까지의 실제 관행(이 세션 전체, 수십 개 파일)을 그대로 인정 — 소급 rename 불필요, 즉시 실행 비용 0.
- 폴더 경로(`<workpacket_name>/`)가 이미 사실상 제목 역할을 하고 있음(`600610_takeout_session_type_fix/600611_Overview.md`에서 폴더명이 맥락 제공) — 완전히 근거 없는 예외는 아님.

**단점**:
- §3에서 확인했듯, 애초에 "6자리 접두사 + Overview/Logic" 형식 자체가 2026-07-10부로 대체된 것이므로, 이 예외를 신설해도 **더 근본적인 문제(위치/접두사 체계 자체가 현재 규정과 다름)는 해결되지 않는다** — 증상만 봉합.
- `000701`/`000002` 두 문서 모두 "PascalCase, no six-digit prefix"를 "as of 2026-07-10"이라는 명시적 날짜와 함께 서술 — 이 예외를 신설하려면 그 날짜 이후 결정을 사실상 뒤집는 셈이 되어, 왜 되돌리는지 근거가 별도로 필요.
- 표(§3)의 (a) 패턴(과거 `000067`/`000086`)과의 형평성 문제 — 그쪽은 제목 포함인데 왜 600000 band만 예외를 두는지 설명 필요.

### B) 앞으로 만드는 파일부터 제목 포함, 과거 파일은 유지

**장점**:
- `000002` §1.1의 canonical 6자리 형식과 즉시 일치(`600067`류 선례와 동일한 형태로 돌아감).
- 과거 파일을 건드리지 않아 링크/참조 깨짐 위험 없음.

**단점**:
- §3의 근본 문제(6자리 접두사 체계 자체가 대체됨)는 여전히 해결되지 않음 — 제목을 붙여도 여전히 "현재 유효 규정과 다른 세 번째 패턴"으로 남는다.
- 과거 파일(`600410`~`600627`)과 신규 파일 사이에 두 가지 형식이 영구 공존 — 프로젝트 전체 일관성 저하.
- "언제부터 B를 적용하는가"의 경계가 모호(다음 워크패킷부터? 이번 세션의 미완료 항목부터?).

### C) (이번 조사에서 새로 드러난 선택지, 지시문에는 없었음) `000002`/`000701`이 이미 규정한 현재 유효 형식으로 이전

`docs/implementation_evidence/<change_id>/Overview.md`(접두사 없음) 형식으로 신규 워크패킷부터 전환.

**장점**: 별도 예외 신설이나 규칙 재해석 없이, **이미 확정되어 있는 규정을 그대로 따르는 것**뿐이다 — 새 결정이 필요 없다.

**단점**: 이번 세션에서 쓴 `docs/600000_implementation_lifecycle/600400_kds_did_implementation/` 폴더 구조 자체와 어긋나므로, A/B보다 변경 폭이 크다(폴더 위치까지 바뀜). `600401_ChangeHistory.md`/`600402_NavigationMap.md`처럼 이미 이 세션에서 폴더 단위로 관행화된 보조 문서들과의 관계도 재설계 필요.

**투명 공개**: 지시문은 A/B만 검토하라고 했으나, §3의 발견이 두 선택지의 전제 자체(현재 유효 규정이 정확히 무엇인지)에 영향을 주므로 C도 함께 제시한다 — 셋 중 어느 것을 고를지는 순전히 Human 결정이며, 이 문서는 권고하지 않는다.

## §5 `000053` 색인 등록 (명백한 누락, 직접 처리)

`000005_Index_Document_Number.md`/`000007_Map_Full_Directory.md`에 `000053`(및 이 문서 `000054`) 행을 추가했다 — diff는 별도로 첨부.

## §6 Open Items

- A/B/C 중 선택 — Human 결정 필요, 이 문서는 결정하지 않음.
- 선택 이후 실제 rename 실행 여부와 범위(이번 세션 전체 vs 향후 신규분만)는 이 문서 범위 밖.
- §3 표의 (a) 패턴(`000067`/`000086`, `WP_8A_001`/`WP_9A_001` 계열)이 왜 (b)로 이관되지 않고 여전히 남아있는지도 별도 확인 필요 — 이번 조사 범위 밖.
