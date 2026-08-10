# 000751_통제된_AI_개발_파이프라인_가이드.md

> 번역 안내: 이 문서는 `000701` 원문의 한국어 독서용 번역본입니다. 파일명, 경로, 명령어, 산출물명과 재사용 가능한 템플릿 필드명은 실제 작업 시 혼선을 막기 위해 원문 표기를 유지했습니다. 규범 해석이 모호할 때는 원문을 기준으로 합니다.

이전 파일 이름:

`051355_Guide_AI_Assisted_Financial_Grade_Development_Pipeline_Cursor_Claude_Codex_Automated_Gate_And_Human_Merge.md`

정식 위치:

`docs/000700_ai_agent_prelearning_and_project_context/`

거버넌스 분류:

구현 생명주기 기반 / 통제된 AI 개발 파이프라인

런타임 구현 권한:

승인되지 않음

SOP 상태:

기반 거버넌스 가이드이며, 아직 의무 `sop/system` 문서로 승격되지 않았습니다.

2026-07-10부터 Cursor와 Codex는 Claude의 전면적인 거버넌스 아래 종속 실행·조사 도구로 다시 도입되었습니다. 두 도구에는 자체 승인, 자체 스테이징 또는 자체 커밋 권한이 없습니다. 모든 Cursor/Codex 산출물은 Claude의 최종 감사(2026-07-16의 13단계 개편 기준 Stage 11, §3)가 수용하기 전에 다른 모델인 Claude Code가 독립적으로 재검증합니다. 이는 검증을 한 모델 계열에만 맡길 때 생길 수 있는 공통 맹점을 줄이기 위한 의도적인 교차 모델 다양성 보호장치입니다(§26 적대적 감사 패스 요구사항 참조). 영구적으로 철회된 무감독 GPT 권한을 되살리는 것이 아닙니다.

## 1. 목적

이 가이드는 `yoonsul_wait_order_handoff`의 AI 지원 금융급 개발 파이프라인을 정의합니다.

목표는 클로드 코드 실행, 클로드 거버넌스 및 독립적인 감사, 자동 검증 및 인적 승인 등을 통합하여 금융 수준의 SaaS 시스템을 지원할 수 있는 하나의 제어된 개발 프로세스로 결합하는 것입니다.

- 코드는 단순하고 읽을 수 있습니다.
- 자금 이동 로직은 명시적으로 유지됩니다.
- 금융 상태 전이는 멱등성을 유지합니다.
- 공급자, POS, PG/VAN, 은행, 지급, 정산, 대사, 감사 및 증거 로직은 추적 가능하게 유지됩니다.
- 인공지능 도구는 역할에 의해 사용되며 맹목적으로 신뢰되지 않습니다.
- 모든 구현은 나중에 디버깅, 감사 또는 다시 되돌릴 수 있는 충분한 문서와 증거를 남깁니다.
- 3,000개 문서 규모의 프로젝트도 범위, 테스트 가능성 또는 금융 정확성에 대한 통제력을 잃지 않고 빠르게 진행할 수 있습니다.

이 문서는 일반적인 AI 개발 가이드가 아닙니다. 금융급 POS/주문/결제/런타임 환경에서 통제된 구현 루프를 운영하기 위한 프로젝트 거버넌스 가이드입니다.

이 버전의 개정 중 강조:

- **(2026-07-16, 재논의 금지)** §3 was rebuilt from an eight-stage (1/1.5/2/3/4/5/5.5/6/7) 로프에 13 단계 (0-12) 로 루프, 이전 ad hoc §34-§40 다중 주체 검증 Architecture/Contract/Independent 검증, 반 중력의 비결적 병행 역할) 를 직접 번호로 된 파이프라인에 추가하고 독립 검증과 최종 감사 사이에 새로운 명시적인 문서화 단계 (10) 를 추가합니다. 이것은 이미 실제 사용에 유도 된 관행을 공식화하고 유도로 인한 검증 격차를 닫습니다.
- 이 가이드 는 후보 최고 수준의 시스템 SOP / 개발 헌법으로 취급됩니다.
- 파이프 라인은 13단계 (0-12) 로 이루어진 명백한 루프로 실행됩니다. Medium/Full 레벨 변경 (§3 참조, §31) 라이트웨이트 트랙 (§24) 은 영향을 받지 않으며 로그만 남아 있습니다. 인 사람의 승인은 독립적인 단계 7.
- 사람의 승인 기록 (인체 제한 승인 섹션 내부) `ChangeContract.md`) 는 코덱스 코드에 닿기 전까지 의무적으로 남아 있습니다.
- 컨텍스트 스냅샷 주제는 클로드의 3단계 디자인 검토 전에 필수적입니다.
- RAW 터미널 로그와 git diff는 AI 요약 없이 클로드에게 전달되어야 합니다.
- 허용된 동작은 허용된 파일보다 좁아야 합니다.
- 모든 감사 및 증거 산출물은 `CHANGE_ID`.
- MVV는 RLS, 데이터베이스 마이그레이션, 금융, 공급자, 감사, 증거, 액세스 통제 또는 생산 출시 변경에 사용할 수 없습니다.
- 컨텍스트 스냅샷은 요약표, 도메인 슬라이딩, 클로드 코드에서 발견된 규칙 참조에 의해 다이어트되어야하므로 클로드는 관련 규칙 경계를만 받는다.
- 완전한 기본 규칙은 지배의 앵커입니다. AI 주입은 갈등이나 감사가 완전한 문서를 필요로하지 않는 한 짧은 규칙 요약을 선호해야합니다.
- 단계 1/2 (커서 스캔, 클로드 코드 검증 및 설계 초안) 는 영향을 받은 코드 및 문서뿐만 아니라 단계 3에 필요한 최소한의 규칙 파일을 발견해야합니다.
- 9단계 원시 로그 (클로드 코드의 8단계 코덱스 구현의 크로스 모델 재확인) 는 `raw_logs/` 클로드가 복사-붙여넣기 손실 없이 정확한 터미널 출력을 확인할 수 있도록
- 각 주요 도메인 폴더는 `<Domain>RulesSummary.md` 요약표, 즉 미래 개발은 수천 개의 계획 문서를 폐기하는 대신 썰어 된 맥락을 사용합니다.
- 이 가이드 가 강제 지배구조로 채택되면 `sop/system/` 그리고 프로젝트 개발 헌법으로 취급됩니다.
- 역할 분할 개정 (2026-07-08, 2026-07-10, 2026-07-10, 다시 구조화 2026-07-16  참조 §3): 설계 확인, 계약 작성, 계약 확인은 이제 하나의 결합 단계보다는 별도의 단계 (3, 5, 6) 이다. 인적 승인 (지금의 단계 7) 은 실행이 시작되기 전에 존재해야 하는 독립적인 게이트가 남아있다. 클로드의 최종 감사 (지금의 단계 11) 는 독립적인 감사 단계로 남아 있으며, confirm/audit 출력 (`AuditReview.md`)  실행자의 `ImplementationModule.md` (단계 8) 는 자기보고서이며 완성된 증거가 아니며, 11단계 감사가 이루어질 때까지 구속력이 없습니다.
- 25-29 섹션은 이 세션의 SQL 마이그레이션 검증 패스가 내부적으로 일관된 문서 체인이 여전히 실제 시스템 상태에서 완전히 벗어날 수 있음을 밝혀낸 후 추가되었습니다. 이 섹션들은 현실 검증, 적대적 검토, 실질적인 검증에 대한 노력 우선 순위 및 옵션 최선 사례가 아닌 구조적 수정으로 지속 가능한 의사 결정 기록이 필요합니다.
- 역할 분할 개정 (2026-07-10, 단계 번호가 업데이트 2026-07-16): 클로드의 전면적인 거버넌스 아래 커서와 코덱스가 다시 도입됩니다 ( 위의 알림 및 §2, §3 참조). scope/inventory 검색만 합니다  작성도 없고 편집도 없습니다. 2단계 (클로드 코드) 는 커서의 범위와 초안을 확인합니다 `Overview.md`/`Logic.md`. 8단계 (코덱스) 는 승인된 `ChangeContract.md` 한계: 9 단계 (클로드 코드, 더 크루저 (Cursor) 는 독립적으로 코덱스 구현을 재확인합니다. `MinorOpinion.md`, 11단계에서는 명시적으로 다루어야 합니다 (단계 적용 가능성에 대해서는 § 31을 참조하고, 각 도메인별 나비게이션맵에 대해서는 § 32을 참조하여 각 변경에 따라 레벨과 상태를 추적합니다).

---

## 2. 운영 논문

이 프로젝트는 AI 도구를 분할 제어 개발 시스템으로 사용하고 있으며, 하나의 지배권 (클로드) 아래의 다섯 가지 핵심 주역과 비자유적 관찰자 수준의 참가자로 Antigravity (§ 40) 를 사용합니다.

```text
커서 스캔 및 보고 (편찬도 없고 편집도 없다)
클로드 코드는 스캔을 확인하고 디자인을 작성합니다.
클로드는 그 초안을 검토하고 검증 단계를 설정합니다.
코덱스 and/or 커서가 건축을 확인하고 클로드가 통합합니다.
클로드 코드는 계약서를 작성합니다.
코덱스 and/or 커서가 계약서를 확인하고 클로드가 통합됩니다.
인간들은 그 경계를 승인합니다.
코덱스는 경계에 엄격히 적용됩니다.
클로드 코드 (그리고 비평적 계층의 커서) 는 독립적으로 코덱스의 구현을 재확인합니다.
코덱스와 클로드 코드가 이 변화를 기록합니다.
클로드는 판사 (자본 보고서를 신뢰하지 않는다).
인간 소산출물들이 융합되고 해방됩니다.
```

단 하나의 인공지능 도구가 최종 권위로서 신뢰할 수 없습니다. 커서와 코덱스는 또한 자기 승인, 자체 스테이징 또는 자체 커밋에 대한 권한을 가지고 있지 않습니다. 어떤 도구도 생산하는 모든 출력은 클로드의 11 단계 감사가 그것을 받아들일 수 있기 전에 적어도 한 가지 다른 모델의 독립적인 재확인 과정을 통과합니다.

클로드 코드의 설계안은 그 자체로 구속력이 없습니다. `Overview.md` 그리고 `Logic.md` 3단계 및 4단계 건축 검증이 통과되면 클로드가 승인된 설계가 될 것입니다  클로드 코드 작성은 먼저 클로드의 설계 당국으로서의 역할을 제거하지 않고, 첫 번째 초안을 작성하는 사람만 변경합니다. scan/opinion이 두 가지 모델 중 어느 하나라도 생산하는 것은 다른 모델이 독립적으로 다시 확인하기 전까지는 기본 진실으로 취급되지 않습니다.

파이프 라인은 다음과 같은 권한 분할을 중심으로 설계되었습니다.

| 파티 | 권위 와 책임 |
|---|---|
| 가속 | 1단계 scope/inventory 스캔 (검색, 의존성 발견만  편집, 설계 권한이 없습니다). 비평적 계층 하에, 4 단계 (건축 확인), 6 단계 ( 계약 확인), 9 단계 (자립 확인) 에 참여하여 `MinorOpinion.md` 해당 경우: 커서어는 어떤 단계에서도 변경을 차단하거나 승인하거나 요구할 수 없습니다. |
| 클로드 코드 | 2단계: verifies/corrects 커서의 범위, 초안 `Overview.md`/`Logic.md`5단계: 초안 `TestPlan.md`/`ChangeContract.md`. 9단계: 코덱스 시행을 독립적으로 재확인합니다 (자본확인보다는 모형중심검사) `VerificationResult.md` 무분별한 증거 수집을 위한 단계 10: 중요한 문서들을 생산한다 (`Verification.md`, 초안 `Audit.md`). |
| 클로드 | 첫 번째 통과 설계 검토 및 계층 결정 (단계 3), 통합 단계 4/Stage 6 다중 주자 검증 결과, 지배관리 검토 및 무소속 독립적인 최종 감사 (단계 11) 클로드는 커서 스캔, 코덱스 자부 보고 또는 클로드 코드의 검증 보고서를 명목적 가치로 신뢰하지 않습니다 ACCEPT/REJECT 권위는 클로드에게만 달려 있습니다. |
| 코덱스 | 8단계: 인간 승인된 시스템 내에서 엄격히 격리된 실행 `ChangeContract.md` 경계에, 아래 Normal/Critical 또한 4단계와 6단계 검증에 참여합니다 (자신의 출력 중 결코 없습니다).`Module.md`, `NavigationMap.md`코덱스 `ImplementationModule.md` 본격적인 보고가 아니라 완성된 증거가 아니며, 9단계 (Claude Code) 와 11단계 (Claude) 이 모두 검토될 때까지 구속력이 없습니다. |
| 항중력 | 관찰기 기간 동안 1, 4, 6 및 9 단계에 참여하는 비결형 동행 참가자 (§40) PASS/FAIL 판결을 내 |
| 인간 | 7단계 경계 승인, 최종 합병, 방출 및 생산 위험 수용 (단계 12) |

결과 프로세스는 열세 단계 (0-12) 의 완전성 루프입니다 Medium/Full 계층 변경 (§3, §31); 라이트웨이트 트랙 (§24) 은 더 짧은 로그 로그 로그로 남아 있습니다.

---

## 3. 13단계 (012) 완전성 루프

**(2026-07-16 전면 개정, 인간 결정, 재논의 금지) ** 2026-07-16 현재 이것은 13단계 루프 (단계 0~12단계) 입니다 Medium/Full 계층 변경 (§31) 은 2026-07-10 이후 시행된 8 단계 (단계 1 / 1.5 / 2 / 3 / 4 / 5 / 5.5 / 6 / 7) 구조를 대체하고 있습니다.

이 개정은 8단계 구조가 실제 세션 연습에서 유도되었기 때문에 ("단계 2 = 코덱스 테스트플랜을 작성합니다", "단계 5 = 커서 + 항 중력 평행 실행은 공식 검증으로 취급됩니다"), 그리고 그 유도 자체는 검증 격차를 일으켰습니다. 원래 8단계 정신  저자 ≠ 검증기, 의무적인 인간 게이트, 클로드의 유일한 최종 ACCEPT/REJECT  권위  보존됩니다. 어떤 변화들이 단계의 수와 경계: 다중 행위자 architecture/contract 이미 비공식적인 추가로 축적된 검증 규칙 (§34-§40  배우 선택, 크로스-배우 검증 확장, 디자인-실제 두 번째 크로스- 검증, 의무 두 번째 검증, 검증 강도 계층, 항 중력 관찰기 기간) 은 이제 파이프 라인이 실제로 작동하는 방식과 더 이상 일치하지 않는 8 단계 골격 위에 무등한 층으로 앉아있는 대신 번호가 된 파이프 라인에 직접 접는다.

```text
[0] 문제 발견 / 사실 스캔 (정규적이지 않은)
    - 생산자: 누구든 (Human / Cursor / Codex / Claude Code / Antigravity)
    - 검증: 없음 — 경량, 비정기 발생. 정규 사이클(Stage 1) 진입 전 자유 조사 단계.
    - Output: Issue Record (선택, 형식 자유)

    ↓ 정규 주기에 선택적으로 전달

[1] 스캔 -> "눈만"
    - 생산자: Cursor (Eyes Only, 검색/보고만, 설계·구현 금지)
    - 병행: Antigravity [참고용, 비구속 — §40 관찰 기간 원칙 그대로]
    - 절대 구현 코드 작성 금지, 절대 설계 문서 초안 작성 금지 (검색/보고만)
    - 아키텍처/DB/RLS/네이밍 신규 표준 결정 금지 — 불확실하면 "Open Question" 표시
    - 출력: 원료 scope/inventory 보고

    ↓ 스캔 전달

[2] 설계안 -> "제공안안"
    - 생산자: Claude Code
    - Cursor의 스캔 결과를 직접 검증(누락된 파일/의존성/RLS/migration 확인)한 뒤 ImpactScope.md를 확정하고 초안을 작성
    - 출력: Overview.md, Logic.md (안안)
    - 금지: 구현 코드 작성, 신규 아키텍처/DB/RLS/네이밍 표준 확정 (불확실하면 Open Question 표시)

    ↓ 초안 전달

[3] 클로드 퍼스트 패스 리뷰 + Critical/Normal 레벨 결정 -> "뇌"
    - 담당: Claude (저)
    - 내용: Overview.md/Logic.md를 직접 검토, 위험도(Critical/Normal) 판단 후 Stage 4 검증자 구성을 결정
    - Output: 검토 코멘트 + tier 판정

    ↓ 계층 결정의 전달

[4] 건축물 검증
    - 검증 (Normal tier): Codex + Antigravity [참고용]
    - 검증 (Critical tier): Cursor + Codex + Antigravity [참고용]
    - 담당: Claude(저)가 결과 통합/판단 → Human 확인
    - Output: Architecture Review (raw 검증 결과 통합)

    ↓ 검증된 설계 전달

[5] 계약안정 -> "안정안정"
    - 생산자: Claude Code
    - 출력: TestPlan.md, ChangeContract.md

    ↓ 계약 수급

[6] Contract Verification (§37 — 원작자인 Claude Code는 검증자에서 제외)
    - 검증 (Normal tier): Codex + Antigravity [참고용]
    - 검증 (Critical tier): Cursor + Codex + Antigravity [참고용]
    - 담당: Claude(저)가 결과 통합/판단

    ↓ 검증된 계약 전달

[7] 인적 승인 게이트 -> "주인 (게이트) "
    - 담당: Human
    - Overview.md / Logic.md / TestPlan.md / ChangeContract.md 검토, 허용/금지 파일 확정
    - 출력: ChangeContract.md (Human Boundary Approval 섹션 완료)

    ↓ 승인된 국경 전달

[8] 시행 -> "손"
    - 생산자: Codex (승인된 ChangeContract.md 바운더리 내부에서만, 엄격 준수, 작은 diff 유지, 불필요한 리팩토링 금지)
    - Codex는 자기 구현을 스스로 승인/커밋할 권한 없음
    - 출력: 코드 디프리 + ImplementationModule.md (자기보고서, 완료 증명 아님)

    ↓ 원료 검증 전달

[9] Independent Verification (§37 — 원작자인 Codex는 검증자에서 제외)
    - 검증 (Normal tier): Claude Code + Antigravity [참고용]
    - 검증 (Critical tier): Claude Code + Cursor + Antigravity [참고용]
    - 담당: Claude(저)가 결과 통합/판단
    - 출력: VerificationResult.md + raw logs + git diff (Critical tier에서 Cursor가 참여한 경우 MinorOpinion.md도 포함)

    ↓ 문서 전달

[10] 문서화
    - Codex: 간단 문서 (Module.md, NavigationMap 갱신, 000005/000007 색인 등록)
    - Claude Code: 중요 문서 (Verification.md, Audit.md 초안)
    - Output: 갱신된 Module/NavigationMap/색인 문서 + Verification.md + Audit.md 초안

    ↓ 감사의 전달

[11] 최종 감사 -> "사법관"
    - 담당: Claude(저) 단독. 최종 ACCEPT/REJECT 권한은 오직 Claude에게만 있음
    - ImplementationModule.md / VerificationResult.md / Module.md / Verification.md / Audit.md 초안을 액면 그대로 신뢰하지 않고 핵심 주장 재도출, raw git diff 직접 검토
    - 금융 사고 반례 시나리오 교차 감사
    - 출력: AuditReview.md (ACCEPT / APPROVE_WITH_NOTES / BLOCK)

    ↓ 소유자 결정의 전달

[12] 인간 합병/방해 -> "주자"
    - 담당: Human
    - 최종 diff 확인, AuditReview.md 확인, unresolved BLOCK 없음 확인, commit / merge / release 승인
    - 출력: ReleaseEvidence.md (선택) 또는 커밋 자체
```

이 방법은 13단계로 명시된 형태입니다 (Medium/Full 단계 0은 비정규적이며 주어진 변화에서 완전히 건너뛰어질 수 있습니다. 그것은 일반 주기가 시작되기 전에 어떤 행위자가 발견을 기록하도록 허용하기 위해만 존재합니다. 단계 10 (기록) 는 8 단계 구조에 비해 새로운 것입니다. 이전에는 번호가 된 게이트로 존재하지 않았으며, 그 결과로 생성되는 산출물 (`Module.md` / `NavigationMap.md` / `000005`/`000007` 지수 등록 `Verification.md`, `Audit.md` 초안) 은 이전에는 독립적 인 검증과 최종 감사 사이에 명시적인 단계 경계가 없는 배경 지배 요구 사항 (§30, §32) 으로만 존재했습니다. 3, 4, 5, 6 단계는 이전 단계 2의 결합된 "디자인 확인, 다음 계약 잠금" 역할을 별도의 4 단계로 대체합니다.  첫 번째 통과 검토 및 계층화 (3), 다중 주연 아키텍처 검증 (4), 계약 작성 (5) 및 다중 주연 계약 검증 (6)  왜냐하면 단일 오래된 단계 2는 실제로 이미 ad hoc §34-§40 다중 주연 규칙으로 보충되었기 때문에, 이 개정에서는 그 현실을 단계 번호가 자체로 접합니다. `ImplementationModule.md` (단계 8) 는 자기보고이며 완성된 증거가 아닙니다. `VerificationResult.md` 그리고 원료 `git diff`.

### 3.1 항 중력 원칙 (단계 1, 4, 6 및 9에 적용된다)

1/4/6/9단계 모두 병행 지시가 기본값이며, Antigravity의 결과는 어디서든 "참고용, 비구속" — 정식 PASS/FAIL 판정에 영향을 주지 않는다. 관찰 기간 종료 전까지 "Cursor"/"Codex" 표기를 Antigravity로 대체하지 않는다 (§40 원칙 그대로 유지).

---

## 4. 핵심 규칙

```text
AI 편집은 범위 없이 없습니다.
클로드 코드 검증된 커서어 범위를 가지고 있는 설계안은 없습니다.
클로드 검증된 설계 없이 시험 계획이 없습니다.
기록된 인적 승인을 받지 않고 실행이 불가능합니다.
승인된 ChangeContract.md 경계를
원시 로그 없이 검증은 없습니다.
비자비자격차 없이 감사가 없습니다 VerificationResult.md, 그리고 MinorOpinion.md.
인간 소유자가 결정하지 않고 합병할 수 없습니다.
증거 없이 재정적인 변화가 없습니다.
```

금융 정확성에 대한 최종 권위는 인공지능의 대답이 아닙니다.

최종 권한은 다음과 같은 합동 증거입니다.

1. 클로드 코드 영향 범위
2. 클로드 디자인 팩
3. 인간 승인된 파일 경계
4. 클로드 코드 제한적 시행
5. 기계적 검증 출력
6. 무작위 로그와 기트 디퍼스
7. 클로드 독립적인 감사
8. 인간들이 합병과 방출 결정을 내린다.
9. 증거들을 풀어주세요.

---

## 5. 단계 출력 지도

**(2026-07-16 개정)** 13단계 (0-12) 구조를 위해 재건 (§3); 8단계 (1/1.5/2/3/4/5/5.5/6/7) 이 표의 버전

| 단계 | 소유자 | 역할 이름 | 주요 출력 | 주요 위험 통제 |
|---:|---|---|---|---|
| 0 | 누구든 | 사실 스캐너 (정규적이지 않은) | 발행 기록 (선택) | 초기 발견은 나중에 더 높은 비용으로 손실되거나 재발견되었습니다. 게이트가 없습니다. 따라서 검증으로 통제되는 위험은 없습니다. |
| 1 | 커서 (+ 항 중력력, 참조만) | 눈만 | 원료 scope/inventory 보고 (검색만, 작성도 없고 편집도 없다) | 잘못된 파일 범위를, 놓친 의존성, 숨겨진 test/RLS/migration 영향 |
| 2 | 클로드 코드 | 수술 의 손 | `Overview.md` (안안) `Logic.md` (안안) | 커서의 원본 스캔은 비평적으로 신뢰되고 검증되지 않은 설계 초안은 최종으로 잘못 생각됩니다 |
| 3 | 클로드 | 뇌 (첫 번째 합격 검토 + 계층 결정) | 검토 의견 + Critical/Normal 계층 판결 | 스테이지에 지정된 검증기 구성은 잘못되었다 4/6/9; 설계 과정 전에 잘못 판단된 위험 수준 |
| 4 | 코덱스 + 항 중력 (정상) / 커서 + 코덱스 + 항 중력 (평론)  클로드 통합 | 건축물 검증 | 건축 검토 (융합된 원시 검증 결과) | 부적절한 디자인, 숨겨진 금융 위험, 모호한 범위는 한 명의 평론가의 맹목적 점에서 침묵으로 받아들여졌습니다 |
| 5 | 클로드 코드 | 수립자 (계약) | `TestPlan.md`, 초안 `ChangeContract.md` | 검증된 설계 없이 작성된 계약; 잘못된 위험 표면에 적용된 시험 |
| 6 | 코덱스 + 항 중력 (정상) / 커서 + 코덱스 + 항 중력 (평론)  클로드 통합 | 계약 검증 (§37: 클로드 코드, 계약 작성자로서 제외) | 확인 `TestPlan.md`/`ChangeContract.md` | 계약 경계는 broad/narrow, 반전 또는 시험 커버리가 없는, 자작품 계약이 확인되지 않은 |
| 7 | 인간 | 소유자 (문) | `ChangeContract.md` (인간의 국경 승인 섹션이 작성되었습니다) | 승인되지 않은 또는 모호한 파일 경계에서 시작하는 코덱스 |
| 8 | 코덱스 | 손 | 코드 차이 `ImplementationModule.md` | 잘못된 구현, 광범위한 리팩터, 허가되지 않은 변경, 자기보고를 완료 증명으로 잘못 생각, 승인된 경계를 벗어난 구현 |
| 9 | 클로드 코드 + 항중력 (정상) / 클로드 코드 + 커서 + 항중력 (비평)  클로드 통합 (§37: 코덱스 제외, 구현자) | 독립적인 검증 | `VerificationResult.md`, 원시 로그, git diff (+ `MinorOpinion.md` 커서가 비평적 계층에 참여하는 경우) | 타입 오류, 시험 실패 migration/RLS/security 요약에 의해 숨겨진 격차; 독립적인 재확인 없이 신뢰되는 코덱스 자부지 보고; 단일 검증자가 공유하는 맹점 |
| 10 | 코덱스 (단법 문서) / 클로드 코드 (중요한 문서) | 문서화 | `Module.md`, `NavigationMap.md`/인덱스 업데이트 (코덱스); `Verification.md`, 초안 `Audit.md` (클로드 코드) | 추적 가능한 지역이 없는 시행국 module/index 기록; 문서 추적 없이의 감사수산 |
| 11 | 클로드 | 판사 | `AuditReview.md` (ACCEPT / APPROVE_WITH_NOTES / BLOCK) | 논리적 불합리, 금융사고 시나리오, 증거 부족, 거짓 신뢰, 감사되지 않은 자보고는 최종적 것으로 취급되고, 제기된 우려는 침묵으로 무시됩니다 |
| 12 | 인간 | 소유자 | 융합, `ReleaseEvidence.md` (선택) | 맹중공업, 통제되지 않은 생산 방출, 소유하지 않은 위험 |

---

## 6. 의무적 인 컨텍스트 스냅샷 2단계와 3단계 사이에

**(2026-07-16 번호 정합화) ** 구 1.5 단계 (클로드 코드 확인+안안) 은 이제 2 단계; 구 2 단계 (클로드 디자인 검토) 는 이제 3 단계  참조 §3.

2026-07-10 현재, 1단계 (Cursor's raw scan) 는 그 자체로 전달 지점이 아닙니다. Cursor는 작성 권한이 없으며, 그 원본 스캔은 검색에만 있습니다. 이 섹션 전체에 참조되는 컨텍스트 스냅샷은 클로드 코드의 2단계 검증 후 그 스캔의 2단계 검증이 이루어져 있으며, 2단계부터 3단계 경계에 있습니다. 아래의 "Stage 1"에 대한 참조는 결합된 1단계 (Cursor scan) + 2단계 (Claude Code) 를 의미합니다. verification/draft) 에 대해 다른 언급이 없는 한

### 6.1 왜 이 존재 합니까?

3,000개의 문서 저장소에서는 영향 범위를 보고만으로는 충분하지 않습니다.

클로드만 받을 경우 `ImpactScope.md` 그리고 변경 요청에 따라, 그것은 지역적으로 유연하지만 프로젝트 아키텍처, 이름 규칙, 파일 협약, DB 제한, RLS 정책 패턴, 증거 규칙 또는 금융 안전 규칙과 전 세계적으로 불합하는 솔루션을 설계할 수 있습니다.

하지만, 그 반대의 실패도 위험하다.

모든 디자인 사이클이 전체 규칙 기반을 주입하면 클로드는 컨텍스트 부풀어, 무관한 규칙 고정 및 중간에서 손실되는 행동으로 고통받을 수 있습니다. 토큰 비용 증가, 주의 품질이 떨어지고, 현재 모듈의 핵심 위험은 관련없는 지배 텍스트로 희석될 수 있습니다.

따라서, 컨텍스트 스냅샷은 "모든 규칙 문서를 버려야 한다"는 것을 의미하지 않습니다.

### 6.2 컨텍스트 스냅샷 다이어트 규칙

클로드 코드 스테이지 2에서 클로드 스테이지 3로 이동할 때 항상 컨텍스트 스냅샷 팩을 제공하십시오.

팩은 다음으로 되어 있어야 합니다.

- 건축의 유동을 막기 위해 충분히 완성된
- 이 피하기 위해 충분히 작습니다.
- 각 규칙 파일이 포함된 이유를 설명할 수 있을 만큼 추적가능합니다.
- 어떤 규칙이 배제되었는지, 왜 배제되었는지 설명하기에 충분합니다.

우선 순위는 다음과 같습니다.

```text
1. ImpactScope.md
2. 현재 사용자 요구사항 / 변경 요청
3. 마스터 인덱스 또는 마스터 규칙 앵커
4. 모듈에 맞춘 짧은 규칙 요약 / 속임수 표
5. 모듈에 맞춘 도메인 지수 또는 모듈 지수
6. 요약이 충분하지 않기 때문에 필요한 전체 규칙 문서만
7. 관련 SOP / 정책 / 매트릭스 / 단계 1에 의해 발견된 체크리스트 참조
```

스냅샷은 저장소에서 있는 모든 문서를 포함해서는 안 됩니다.

### 6.3 마스터 규칙 요약표 규칙

모든 큰 지배 규칙 문서에는 AI 주입의 짧은 요약이 있어야 합니다.

추천 패턴: 전체 지배 규칙은 이 프로젝트의 6자리 문서 이름의 일반적인 협정을 유지합니다 (000002_Naming_Rules.md); 파이프라인에서 생성된 AI 주입 요약에서만 파스칼케이스와 연결된 파이프라인-아르티팩트 협약이 사용된다 (§33 참조):

```text
전면적인 거버넌스 규칙 (사업 문서 이름 협약):
  NNNNNN_Guide_<Domain>_Policy.md

인공지능 주입 요약 (파이플라인 산출물 협약):
  < 도메인>RulesSummary.md
```

예를 들어:

```text
완전 규칙:
  000900_Guide_RLS_Policy.md

컨텍스트 스냅샷에 주입된 요약:
  RlsRulesSummary.md
```

요약은 대략 20~40 줄이어야 하며, 다음을 포함해야 합니다.

- 협상할 수 없는 제약
- 명칭과 배치 규칙
- 금지된 운영
- 필요한 검사나 증거
- 에스컬레이션 트리거가 전체 문서가 필요해

전체 지배 문서는 진실의 원천으로 남아 있지만, 3단계에서는 일반적으로 요약이 전달되어야 합니다. 그 변화는 높은 위험 경계에 영향을 미치거나 요약은 전체 규칙을 검사해야 한다는 것을 표시하지 않는 한 말이죠.

### 6.4 컨텍스트 슬라이징 매트릭스

컨텍스트 스냅샷은 현재 모듈의 도메인 태그에 의해 슬라이드되어야 합니다.

클로드에게 적용되는 모듈과 일치하는 기본 규칙만 제공되어야 합니다.

| 현재 개발 목표 | 필요 한 컨텍스트 슬롯 | 일반적으로 토큰 저장에 제외 |
|---|---|---|
| POS 통합 / API 게이트웨이 | API 라이트 계약, 공급자 경계가, 무제한성, 웹허크 서명, 복귀 주문, 증거 요약 | 플러터 UI 구성 요소 가이드, DB 마이그레이션 가이드, 스케마 변경이 없는 한, 관련 없는 결제 심도 규칙 |
| 지불 / 취소 / 환불 | 금융 국가 기계, 무소속성, 복제 예방, 공급자 timeout/unknown 상태, 감사 리더, 증거 패키지 customer/store 최종 | UI 레이아웃 규칙, 관련 없는 관리자 콘솔 규칙, 지불하지 않는 제공자의 문서 |
| 수파베이스 / DB / 마이그레이션 | DB 제한, 마이그레이션 규칙 요약 RLS/security 요약, 임차원 격리, 반전 및 건조 운행 규칙 | 플러터 UI 규칙, 공급자 API 가이드 제공자 호출 후 작성하지 않는 한 DB |
| RLS / 액세스 제어 | RLS 요약, 허가 매트릭스, 임차원 격리, 유리 찢어지는, audit/evidence, 최저 특권 규칙 | UI 디자인 가이드, 지불 제공자 지도가 돈 상태가 포함되지 않는 한 |
| 플러터 UI / 국가 관리 | 플러터 상태 전환 규칙, 화면 구성 가이드, 사용자 메시지 최종 규칙, API 클라이언트 계약 | DB 마이그레이션 가이드 settlement/reconciliation 규칙, 은행 결제 심도 규칙 |
| 감사 / 증거 / 공개 | 감사 리더 규칙, 증거 패키지 규칙 CHANGE_ID 규칙 retention/redaction/legal 요약을 유지하고, 증거 가이드를 공개 | UI 레이아웃 규칙, 관련 없는 공급자 문서 |
| 결제 / 조화 / 지불 | 결제 통제 총액, 조화 예외 처리 payout/bank 알려지지 않은 상태, 제조자 검사, 증거 및 감사 규칙 | 플러터 UI 가이드, 일반 화면 구성 문서 |
| 문서만 변경 | 이름 규칙의 요약, 지수 배치, 교차 링크 규칙 H1/filename 규칙, 기록 규칙 | 실행 시간 코드 규칙, RLS 가이드, DB 마이그레이션 가이드 |

모듈이 여러 도메인 태그를 가지고 있다면 필요한 컨텍스트 슬롯의 결합을 포함하지만 전체 문서보다 요약을 선호합니다.

### 6.5 클로드 코드 도움말 규칙 필터링

커서 1 단계의 원본 스캔은 후보자를 표면에 내세워야 합니다 rule/SOP/policy 참고문헌 code/SQL/test 파일, 하지만 3단계에서 필요한 최소한의 규칙에 해당하는 후보자를 정리하는 것은 판단의 요청이 아니라 검색 작업입니다.

클로드 코드는 코드, SQL, 테스트, 문서뿐만 아니라 단계 3에 필요한 최소한의 규칙 파일을 식별해야합니다.

2단계는 다음과 같은 질문을 해야 합니다.

```text
클로드가 이 변화를 안전하게 설계하기 위해 어떤 마스터 인덱스, 도메인 인덱스, 규칙 요약, SOP, 정책, 매트릭스, 체크리스트, 또는 지배 파일을 받아야 합니까?
```

그 결과로 `ImpactScope.md` 특별 섹션에 따라:

```markdown
## Required Context Snapshot Candidates

### Master Anchor
- <master index path>

### Rule Summaries
- <idempotency summary path>
- <RLS summary path if applicable>
- <audit/evidence summary path>

### Full Rules Required
- <full rule path only if summary is insufficient>

### Domain Indexes
- <domain index path>

### Excluded Rule Families
- <rule family> — excluded because <reason>
```

이 방법은 2단계가 첫 번째 컨텍스트 필터로 작용할 수 있게 해줍니다. 3단계는 전체 3,000 문서 기반보다는 필터링된 스냅샷만을 소비합니다.

### 6.6 컨텍스트 스냅샷 출력

2026-07-10부터 컨텍스트 스냅샷은 더 이상 별도의 파일이 아닙니다 `ImpactScope.md`"필요한 컨텍스트 스냅샷 지원자" 섹션 및 관련 분야 (모듈 도메인 태그, 컨텍스트 예산 결정, 알려진 격차, 스냅샷 결정) 는 2 단계에서 클로드 코드에서 제작되었습니다. 전체 템플릿을 참조 8.8. `context_snapshot.md`그 파일은 별도의 산출물으로 더 이상 존재하지 않습니다.

2단계에서 3단계로 전달되는 `ImpactScope.md` 그 자체로 두 번째 선언 파일은 없습니다.

### 6.7 단계 3 신속한 요구 사항

클로드에게 이렇게 말해야 합니다.

```text
컨텍스트 스냅샷을 프로젝트 규칙 경계로 사용하십시오.
이름 붙여주는 협약, DB 협약, RLS 협약, 증거 협약 또는 건축 표준을 재설계하지 마십시오.
포함된 규칙 요약과 전체 규칙만 사용하세요.
지역 변경이 기본 규칙과 충돌하는 경우, 표준을 침묵으로 변경하는 대신 갈등을 표시하십시오.
만약 초상화 사진이 부풀어 나 비관리적으로 보이는 경우 비관리적인 맥락을 나열하고 필요한 규칙을만 따르십시오.
스냅샷이 너무 얇은 것처럼 보이면, 설계 전에 블록하고 실종된 규칙 가족을 요청하십시오.
```

### 6.8 규칙 요약 파일 템플릿

각 고부가가치 도메인은 한 개의 얇은 요약 파일을 가지고 있어야 합니다.

```markdown
# <Domain>RulesSummary.md

## Purpose

## Applies When

## Does Not Apply When

## Non-Negotiable Rules

1.
2.
3.

## Required Evidence

## Required Tests

## Forbidden Operations

## Escalate To Full Rule When

## Full Rule Source

- <path to full governance document>
```

추천된 요약 목표 (PascalCase-joined, §33):

- `CodeConventionRulesSummary.md`
- `DbConstraintAndMigrationRulesSummary.md`
- `RlsAndSecurityRulesSummary.md`
- `FinancialIdempotencyAndDuplicatePreventionRulesSummary.md`
- `AuditLedgerAndEvidencePacketRulesSummary.md`
- `PosGatewayAndProviderCallbackRulesSummary.md`
- `FlutterUiStateAndFinalityMessageRulesSummary.md`
- `DocumentationNamingIndexAndCrosslinkRulesSummary.md`

### 6.8.1 도메인 폴더의 나머지 문서 구성의 요약 규칙

새로운 계획, 정책, SOP 또는 구현 준비 문서가 규모로 추가될 때, 각 주요 도메인 폴더는 또한 한 얇은 규칙 요약 파일을 포함해야합니다.

전체 문서를 복제하는 것이 아니라, 단계 1에 쉽게 발견할 수 있는 파일과 단계 3에 소규모 규칙 패키지를 소비할 수 있도록 하는 것입니다.

추천된 배치 패턴:

```text
<domain_folder>/
  < 도메인>RulesSummary.md
  < 도메인>_Index.md
  <정책 / 계획 / SOP 문서>
```

각 도메인 요약의 최소 내용:

- 이 영역이 적용되는 경우
- 협상할 수 없는 실행 시간 또는 문서화 제한
- 격퇴가 필요한 파일이나 작업
- 필요한 시험이나 증거
- 전체 규칙의 출처 경로
- 이 영역에 대해 일반적으로 배제되는 지배 가족.

나머지 1,500 문서의 빌드오트에서, 이러한 요약은 구현할 때까지 연기하는 것이 아니라 도메인 폴더와 함께 만들어져야 합니다. 30 줄 규칙 요약은 나중에 토큰 부풀이, 잘못된 컨텍스트 디자인 및 아키텍처 유동을 방지할 수 있습니다.

### 6.9 맥락 반 패턴

금지된 스냅샷 행동:

- 다큐멘터리 나무를 주입해
- 전체적인 규칙이 큰 것을 주입하는 것은 요약이 충분할 때입니다.
- UI의 영향을 받지 않고 DB에만 변경되는 UI 규칙을 주입한다.
- 문서화만 하는 변경 사항에 마이그레이션 규칙을 삽입하는 것
- 모든 결제, 결제, 결제, 조화 규칙을 간단한 플러터 UI 복사 변경에 주입합니다.
- 돈의 이동에 대한 자유자재 및 감사 요약을 배제합니다.
- RLS 요약을 제외하는 경우 tenant/access-control 변화
- 클로드가 기본 요약이 있을 때 하나의 로컬 파일에서 프로젝트 표준을 추론할 수 있게 해주는 것.

### 6.10 컨텍스트 다이어트 운영 규칙

```text
컨텍스트 스냅샷은 문서 쓰레기장이 아닙니다.
필터링된 규칙 패키지입니다.

마스터 인덱스는 프로젝트를 니다.
규칙 요약은 매일의 제약을 가지고 있습니다.
도메인 절단으로 집중력을 유지합니다.
클로드 코드는 후보 규칙 파일을 발견합니다.
클로드는 선택한 규칙 경계에만 디자인합니다.
```

---

## 6.11 CHANGE_ID 추적성 규칙

모든 문서, 적절한 경우 코드 댓글, 감사 리저 이벤트, 증거 패키지, 검증 결과 및 공개 기록은 동일한 활성 `CHANGE_ID`.

이 `CHANGE_ID` 실행 패키지의 척추입니다.

필요한 지도:

| 산출물 | 요구 사항 `CHANGE_ID` 위치 | 실패 의 의미 |
|---|---|---|
| `ImpactScope.md` (합병 범위 + 컨텍스트 스냅샷) | `## Change ID` | 범위를 구현에 묶어서는 안 될 수도 있고 클로드가 잘못된 기본 규칙을 사용할 수도 있습니다. |
| `Overview.md` | `## Change ID` | 사업 목적은 감사할 수 없습니다. |
| `Logic.md` | `## Change ID` | 실행 시간 논리는 구현과 연결될 수 없습니다. |
| `TestPlan.md` | `## Change ID` | 테스트는 관련성이 입증될 수 없습니다. |
| `ChangeContract.md` (융합 계약 + 인적 승인을) | `## Change ID` | 승인 범위는 강제할 수 없습니다. |
| `ImplementationModule.md` | `## Change ID` | 코드 디프리는 계약에 묶어질 수 없습니다. |
| `VerificationResult.md` | `## Change ID` | 원자재는 디프에 묶어서는 안 됩니다. |
| `MinorOpinion.md` (Medium/Full (단계) | `## Change ID` | 제2의 의견에 대한 우려는 감사에 관한 변화에 연결될 수 없습니다. |
| `AuditReview.md` | `## Change ID` | 감사는 올바른 변경 사항을 승인할 수 없습니다. |
| 감사 리저 이벤트 | `change_id` 또는 동등한 메타데이터 | 실행 시간 사건은 추적할 수 없습니다. |
| 증거 패키지 매니스트 | `change_id` 필드 | 나중에 증거는 찾을 수 없습니다. |
| `ReleaseEvidence.md` (융합 출력 증거 + 합병 체크리스트) | `Change ID:` | 방출은 재구성될 수 없습니다. |

산출물 중 하나에서 실종되거나 충돌하거나 노후화된 산출물이 있는 경우 `CHANGE_ID`파이프라인이 멈춰야 합니다.

이것은 문서의 결함이 아닙니다.

그것은 감사성 결함이에요.

---

## 7. 9단계와 11단계 사이의 필수 로그 및 Git 차이 전달

**(2026-07-16 번호 정합화)** Old Stage 5/5.5/6 지금 스테이지 9/9 (비평적 계층) 11  참조 §3. 2026-07-10, 비평적 계층이 적용될 때, 이 전달은 9 단계 내에서 커서의 비결제적 미소 의견 검토를 통과합니다 (Medium/Full 단계 11에 도달하기 전에) 코서 는 아래 설명된 동일한 원료 증거 패키지를 받고, `ChangeContract.md` 그리고 코드는  크리티컬-테리어 소수 의견 규칙에 대해 §12.9 참조. 11 단계 클로드는 여전히 9 단계 직접 생산된 모든 것을 수신합니다. `MinorOpinion.md` 패키지

### 7.1 왜 이 존재 하는 이유

9단계는 기계적 검증 단계이고 판단 단계가 아닙니다. 2026-07-10시부터 9단계는 클로드 코드가 독립적으로 코덱스의 8단계 구현을 재확인하는 방식으로 수행합니다.

명령이 실패하고 클로드 코드 또는 다른 인공지능 도구에 의해 실패가 요약되면 가장 중요한 세부 사항이 손실될 수 있습니다.

- 정확한 타입 오류 라인
- 마이그레이션 실패 라인
- RLS 위반 출력
- 실패한 주장
- 복제 키의 제한 세부 사항
- 허가되지 않은 파일 유동
- 코딩 드리프
- 형식성 부작용
- 잘못된 모듈 경계를 보여주는 스택 추적

이 때문에 11단계 클로드 감사는 원전 터미널 출력 및 원전 `git diff`친절한 요약이 아니라

### 7.2 원료 전달 규칙

9단계 출력은 다음을 포함해야 합니다

```text
1. VerificationResult.md
2. 실패한 명령에 대한 전체 원료 터미널 로그
3. 실제로 실행된 전체 명령 목록
4. git -stat
5. git - check
6. git diff--명만
7. 승인된 파일의 전체 git diff 또는 scoped git diff
8. 허용된 범위를 벗어나 변경된 파일 목록,
9. 이동 건조 운용 출력, 적용되는 경우
10. RLS/security 해당 경우 출력을 확인
```

### 7.3 클로드 코드 는 실수 를 숨기지 말아야 한다

클로드 코드는 다음과 같은 질문을 하지 말아야 합니다.

```text
성공했나요?
고칠 수 있어?
실수 를 간단히 요약 해 보십시오.
```

클로드 코드는 다음과 같이 질문해야 합니다.

```text
정확한 명령을 실행하세요.
파일 수정하지 마십시오.
자동으로 고치지 마세요.
실수들을 정리하지 마십시오.
원료 터미널 출력을 반환하십시오.
명령이 실패하면 중지하고 전체 출력을 유지하십시오.
```

### 7.4 원시 로그 저장

추천 폴더 모양:

```text
docs/implementation_evidence/<change_id>/
  08_VerificationResult.md
  raw_logs/
    01_git_diff_stat.txt
    02_git_diff_check.txt
    03_git_diff_name_only.txt
    04_git_diff.patch
    05_lint.log
    06_typecheck.log
    07_test.log
    08_migration_dry_run.log
    09_rls_security_check.log
```

### 7.4.1 원자력 로그 자동화 규칙

원본 로그는 명령어 중도 또는 반복 가능한 로컬 작업 스크립트를 통해 가능한 한 캡처되어야 합니다.

에피소리 소유자 는 고 위험 한 변경 사항 을 위해 터미널 창 에서 수동적 인 복사-붙여넣기 를 의존 하지 말아야 한다. 수동적 복사 는 스택 흔적을 줄여 줄 수 있고, 첫 번째 실패 선 을 생략 하거나, 우연 으로 클로드 가 감사 하기 위해 필요한 정확한 실패 를 요약 할 수 있다.

예를 들어 껍질 패턴:

```bash
CHANGE_ID=<CHANGE_ID>
EVIDENCE_DIR=docs/implementation_evidence/$CHANGE_ID
RAW_LOG_DIR=$EVIDENCE_DIR/raw_logs
mkdir -p "$RAW_LOG_DIR"

git diff --stat > "$RAW_LOG_DIR/01_git_diff_stat.txt"
git diff --check > "$RAW_LOG_DIR/02_git_diff_check.txt" 2>&1
git diff --name-only > "$RAW_LOG_DIR/03_git_diff_name_only.txt"
git diff > "$RAW_LOG_DIR/04_git_diff.patch"
flutter analyze > "$RAW_LOG_DIR/05_flutter_analyze.log" 2>&1
dart test > "$RAW_LOG_DIR/06_dart_test.log" 2>&1
```

프로젝트 특화된 명령어는 Supabase, RLS, SQL 제한, idempotency, 공급자 호출 및 audit/evidence 체크

금융, RLS, 마이그레이션, 공급자, 지불, 결제, 감사 또는 공개 변경 사항에 대해서는 원자력 로그 폴더는 필수 증거가 아니라 편의성이 아닙니다.

### 7.5 11단계 감사 입력 규칙

클로드 오디트는 `raw_logs/`, `git diff`, 그리고 (Medium/Full (단계) `MinorOpinion.md` 직접적으로

클로드는 의존하지 말아야 합니다 `VerificationResult.md` 독자적으로, 그리고 코덱스의 `ImplementationModule.md` 자제 신고만 하는 것 `MinorOpinion.md` 명시적으로 처리되어야 합니다.  인정, 추가 조사 또는 명시된 이유로 해제되어야 합니다.

---

## 8. 단계 1 (과정) 및 단계 2 (클라우드 코드)

2026-07-10부터, 이 섹션은 모든 하류 섹션의 번호를 변경하지 않도록 한 지위 아래 두 개의 별도의 파이프라인 단계를 포함한다. ** 단계 1**는 커서의 원료입니다 scope/inventory 스캔 (검색만, 작성자 권한이 없습니다). ** 단계 2**는 클로드 코드가 그 스캔과 설계 초안을 확인하는 것입니다. 8.1-8.4 부문은 단계 1 (커서) 를 포함하고 있습니다. 8.5-8.8는 단계 2 (클로드 코드) 를 포함하고 있습니다. 8.9-8.10는 단계 2이 생산하는 설계 초안 템플릿입니다.

### 8.1 1단계 역할 (연구자)

커서어는 코드베이스 스카우트로 사용되며, 검색 및 보고만 한다. 커서에는 작성 권한과 설계 권한이 없다.

그 스카우팅 임무는

- 관련 소스 파일
- 관련 테스트 파일
- 관련 SQL 파일
- 관련 수파베이스 마이그레이션
- 관련 RLS 정책
- 관련 공급업체
- 관련 노선
- 관련 수입
- 관련 국가 기계
- 관련 widgets/screens.
- 관련 배경 직업
- 관련 API 처리기
- 관련 문서 참조
- 관련 SOP/정책/매트릭스/검정 목록 참조

커서어는 이 단계에서 코드를 수정하지 않아야 하며, `Overview.md` or `Logic.md`  즉, 2단계 (클로드 코드) 의 임무가 1단계가 아니라

### 8.2 커서 사용 제한

허용:

- 파일 검색
- 의존성 경로를 나열해 보세요.
- 수입 체인을 확인한다.
- API 경로를 확인해 보세요.
- SQL 마이그레이션 역사를 확인합니다.
- 시험의 범위를 확인하세요.
- RLS 정책 위치를 확인하세요.
- 관련 서류를 확인해 주세요.
- 지원자의 파일에 영향을 미치는 것을 보고하십시오.
- 불확실성을 보고하라
- 결정되지 않은 모든 것을 표시하십시오 architecture/DB/RLS/naming 질문하는 대신 "열린 질문"이라고 질문합니다.

금지:

- 코드 편집
- 파일 형식
- 한국인 마크다운을 다시 쓰고 있어요
- 넓은 리팩토리를 운영하고 있습니다.
- 코딩 변경
- 자동 수정 작업을 실행하고 있습니다.
- 생성된 파일을 수정합니다.
- 잠금 파일 수정
- 참고 자료를 확인하지 않고도 파일은 안전하다고 추측합니다.
- 조안 `Overview.md` or `Logic.md`  커서로는 설계안 작성 권한이 없습니다. 이것은 2단계 클로드 코드입니다.
- 새로운 건축, DB, RLS 또는 이름의 컨벤션을 발명하는 것
- 자기 승인을 받거나, 자기 자신을 무대에 올려놓거나, 자기 자신을 위해 어떤 일을 할 수 있는

### 8.3 커서 프롬프트 템플릿

```text
당신은 검색 및 보고만 할 수 있습니다. 당신은 작성 또는 설계가 없습니다.
당국은 생산하지 않습니다 Overview.md or Logic.md, 그것은
별도의 단계

임무:
다음 변경 사항에 대한 전체 영향 범위를 찾아보십시오.

<변화 요약>

검색어:
- 소스 파일
- 시험
- 수입
- 노선
- 국정기
- 데이터베이스 테이블
- 이주
- RLS 정책
- 공급자 통합 파일
- audit/evidence 논리
- monitoring/alert 논리
- 관련 문서
- 관련 SOP / 정책 / 매트릭스 / 체크리스트 파일
- 마스터 지표 및 도메인 지표 참조
- 컨텍스트 스냅샷에 필요한 규칙 요약 파일
- 전체 지배 규칙 파일은 요약이 충분하지 않은 경우에만 필요합니다.
- 샷에서 안전하게 제외될 수 있는 규칙 가족

규칙:
- 어떤 파일도 수정하지 마십시오.
- 포맷을 실행하지 마십시오.
- 코딩을 정상화하지 마십시오.
- PowerShell 세트 컨텐츠를 사용하지 마십시오.
- UTF-8를 보존해
- 한국어 텍스트를 다시 쓰지 마세요.
- 안전성이란 파일 이름만으로는 결론을 내리지 마십시오.
- 구조화된 원료를 반환 scope/inventory 보고만 해야 합니다.
- 초안을 작성하지 마십시오 Overview.md or Logic.md.
- 새로운 건축, DB, RLS, 또는 이름 붙이는 컨벤션을 발명하지 마십시오  결정되지 않은 점을 "오픈 질문"로 표시하십시오.
- 어떤 것도 승인하거나, 진행하거나, 의뢰할 권한은 없습니다. 클로드 코드는 이 보고서를 신뢰하기 전에 독립적으로 확인합니다 (단계 2).
```

### 8.4 단계 1 출력: 원료 Scope/Inventory 보고

커서 1 단계 출력은 원본 보고서이며 아직 신뢰되지 않은 `ImpactScope.md`  그것은 `ImpactScope.md` 클로드 코드 이후만 verifies/corrects 2단계 (8.8) 에 있는

```markdown
# raw scope/inventory report (Cursor, Stage 1 — unverified)

## Change ID

## Change Summary

## Candidate Affected Files

## Direct Dependencies

## Indirect Dependencies

## Database Tables

## Migrations

## RLS Policies

## Tests Found

## Tests Missing

## Provider / POS / PG / VAN / Bank / Payout Impact

## Audit Ledger / Evidence Impact

## Monitoring / Alert Impact

## Related Documentation References

## Related SOP / Policy / Matrix / Checklist References

## Master / Domain Index References

## Risk Notes

## Uncertainties
```

### 8.5 단계 2의 역할 (클로드 코드)

클로드 코드는 커서 1단계 스캔을 확인하고 디자인을 작성합니다. 이것은 실제로 설계 작성 당국이 1단계에서 아닌

클로드 코드는 커서 보고서를 독립적으로 확인해야 합니다. RLS/migration 클로드 코드는 단순히 커서 보고서의 재편을 하지 않아야 합니다.

클로드 코드의 `Overview.md`/`Logic.md` 초안은 구속력이 없습니다. 클로드가 3단계에서 확인한 후에야 승인된 설계가 됩니다. 클로드 코드 초안은 속도 최적화입니다. 최종 설계 권한을 소유하는 사람이 변경되지 않습니다.

클로드 코드는 이 단계에서 코드를 수정해서는 안 됩니다.

### 8.6 클로드 코드 사용 제한 (단계 2)

허용:

- 커서의 후보 파일 목록, 의존성 경로, 수입 체인, API 경로, 마이그레이션 역사, 테스트 커버리지, RLS 정책 위치 및 관련 문서들을 실제 코드베이스에 대해 독립적으로 다시 확인합니다.
- 커서가 놓친 모든 것을 추가하고 커서가 잘못 표시한 모든 것을 제거합니다.
- 최종 완성 `ImpactScope.md` 8.8의 표본을 따라
- 초안 `Overview.md` 8.9의 표본을 따라
- 초안 `Logic.md` 8.10의 표본을 따라
- 결정되지 않은 모든 것을 표시하십시오 architecture/DB/RLS/naming 결정하기보다는 "클로드에게 공개된 질문"이라고 질문합니다.

금지:

- 코드 편집
- 파일 형식
- 한국인 마크다운을 다시 쓰고 있어요
- 넓은 리팩토리를 운영하고 있습니다.
- 코딩 변경
- 자동 수정 작업을 실행하고 있습니다.
- 생성된 파일을 수정합니다.
- 명시적으로 승인되지 않는 한 잠금 파일의 변경
- 커서의 보고서를 신뢰하고 독립적으로 확인하지 않고
- 새로운 건축, DB, RLS, 또는 이름의 컨벤션을 발명하는 `Overview.md`/`Logic.md` 초안
- 치료 `Overview.md`/`Logic.md` 클로드 검증 전에 승인된 초안

### 8.7 클로드 코드 프롬프트 템플릿 (단계 2)

```text
당신은 원자료를 확인하고 있습니다 scope/inventory 커서 (a) 가 만든 스캔
다른 모델이 작성자 권한이 없는 경우
값  실제 코드베이스에 대해 독립적으로 확인합니다.

커서의 원본 보고서는
<CURSOR RAW REPORT>

임무:
1. 각 후보자를 확인 file/dependency/migration/RLS 정책 주
   실제로 존재하고 실제로 관련되어 있습니다.
2. 커서가 놓친 모든 것을 독립적으로 찾아라
3. 최종 완성 ImpactScope.md.
4. 초안 Overview.md.
5. 초안 Logic.md.

규칙:
- 어떤 파일도 수정하지 마십시오.
- 포맷을 실행하지 마십시오.
- 코딩을 정상화하지 마십시오.
- PowerShell 세트 컨텐츠를 사용하지 마십시오.
- UTF-8를 보존해
- 한국어 텍스트를 다시 쓰지 마세요.
- 안전성이란 파일 이름만으로는 결론을 내리지 마십시오.
- 새로운 건축, DB, RLS, 또는 명칭 협약을 발명하지 마십시오.
- 초안을 승인한 것으로 받아들이지 마
```

### 8.8 단계 2 출력: `ImpactScope.md`

```markdown
# ImpactScope.md

## Change ID

## Change Summary

## Candidate Affected Files

## Direct Dependencies

## Indirect Dependencies

## Database Tables

## Migrations

## RLS Policies

## Tests Found

## Tests Missing

## Provider / POS / PG / VAN / Bank / Payout Impact

## Audit Ledger / Evidence Impact

## Monitoring / Alert Impact

## Related Documentation References

## Related SOP / Policy / Matrix / Checklist References

## Master / Domain Index References

## Module Domain Tags

- POS_GATEWAY / PAYMENT / DB / RLS / FLUTTER_UI / AUDIT_EVIDENCE / SETTLEMENT / DOCUMENTATION_ONLY / OTHER

## Required Context Snapshot Candidates

### Master Anchor

- <master index path>

### Rule Summaries

- <code convention summary path>
- <db constraint summary path if applicable>
- <RLS/security summary path if applicable>
- <idempotency summary path if applicable>
- <audit/evidence summary path if applicable>

### Full Rules Required

- <full rule path if required>

### Domain Indexes

- <domain index path>
- <module matrix path>
- <related SOP / Policy / Checklist path>

### Excluded Rule Families

| Excluded Rule Family | Reason |
|---|---|
| <rule family> | Not applicable to this module / summary sufficient / no schema change / no UI impact |

## Context Budget Decision

LEAN / NORMAL / FULL

## Risk Notes

## Uncertainties

## Known Gaps

## Cursor Scan Corrections

What Claude Code added, removed, or corrected relative to Cursor's raw Stage 1 report, and why.

## Files Claude Code Must Not Modify

## Snapshot Decision

READY_FOR_CLAUDE_DESIGN / BLOCKED_NEED_MORE_CONTEXT
```

사용 `LEAN` 서부 파일이 충분할 때 사용 `NORMAL` 또한 작은 수의 완전한 규칙이 필요할 때 `FULL` 단지 종목 간 금융, RLS, 마이그레이션, 공급자, 감사 또는 공개 변경 사항에 대한 요약이 충분하지 않은 경우에만.

### 8.9 `Overview.md` (클로드 코드 초안  3단계 클로드에서 확인)

목적:

- 변화의 높은 수준을 설명해 주세요.
- 사업 목표를 정의하세요.
- 영향을 받은 모듈을 정의하십시오.
- 목표가 아닌 것을 정의하십시오.
- 재정적 영향력을 정의합니다.
- 위험 수준을 정의해
- 클로드 코드가 스스로 해결할 수 없는 문제들이 있습니다.

```markdown
# Overview.md

## Change ID

## Business Purpose

## User / Store / Provider Impact

## Financial Impact Class

## Affected Domains

## Affected Files From Claude Code

## Context Snapshot Used

## Non-Goals

## Expected Behavior

## Out Of Scope

## Risk Summary

## Open Questions For Claude

## Required Approvals

## Draft Status

Draft (Claude Code) / Verified (Claude)
```

### 8.10 `Logic.md` (클로드 코드 초안  3단계 클로드에서 확인)

목적:

- 코딩 전에 정확한 런타임 로직을 정의하십시오.
- 돈 이동 국가 전환을 명시적으로 만들어
- 숨겨진 행동을 방지하세요.

```markdown
# Logic.md

## State Model

## Input Conditions

## Output Conditions

## Success Path

## Failure Path

## Timeout Path

## Unknown State Path

## Idempotency Rule

## Duplicate Prevention Rule

## Retry Rule

## Audit Ledger Rule

## Evidence Rule

## RLS / Permission Rule

## Rollback Rule

## Edge Cases

## Prohibited Behavior

## Open Questions For Claude

## Draft Status

Draft (Claude Code) / Verified (Claude)
```

---

## 9 단계 3/4/5/6 (전 "단계 2")  클로드 디자인 검토, 건축 확인, 계약 작성 및 계약 확인

**(2026-07-16 전면 재작성) ** 옛 단계 2는 "디자인 확인, 그리고 계약 잠금"을 결합하여 클로드에게만 소유되는 한 단계로 나뉘어 있습니다. Critical/Normal 단계 4** (코덱스 및 비중적 단계 아래의 코서 + 반중력 비결적 참조로  기본 규칙에 따라 디자인을 독립적으로 확인합니다. 클로드 통합합니다.) ** 단계 5** (** 클로드 코드**, 클로드가 아닌, 초안 `TestPlan.md`/`ChangeContract.md` 검증된 디자인) 과 ** 스테이지 6** (이번엔 계약의 본인 클로드 코드가 계약의 본인임을 제외한 4단계와 동일한 다중배우 구성) 아래의 4개의 부문 그룹이 일치하도록 명령된다: 9.1-9.7 (단계 3), 9.8-9.11 (단계 4), 9.12-9.15 (단계 5), 9.16-9.19 (단계 6).

### 3단계  클로드 1단계 설계 검토 + 계층 결정

### 9.1 역할

클로드는 첫 번째 통과 설계 검토자로 활동합니다.

클로드에게

- `ImpactScope.md`
- `Overview.md` (클라우드 코드 초안)
- `Logic.md` (클라우드 코드 초안)
- 현재 사업 요구사항
- 컨텍스트 스냅샷에서 필터링 된 규칙 요약
- 전체 지배규칙은 컨텍스트 스냅샷이 요구할 때만
- 관련 프로젝트 규칙
- 금융 안전 요구 사항
- 필요한 경우 기존 SOP 참조

클로드 (Claude) 는 클로드 코드 (Code) 초안을 검토하고,

- verified/corrected `Overview.md`
- verified/corrected `Logic.md`
- 검토 의견
- a Critical/Normal 단계 4의 검증자 구성을 결정하는 계층 판결 (§9.5)

클로드는 직접 작사 오류를 수정할 수 있습니다 `Overview.md`/`Logic.md`. 만약 초안에서 미완성한 영향 범위가 밝혀진다면 (실종 파일,실종 의존성,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실종 파일,실실실험 파일,실실실험함,실실실험,실실실실험,실실실실험,실실실실실실험,실실실실실실험,실실실실실실실실험,실실실실실실실험 RLS/migration 클로드는 그 빈틈을 둘러싼 패치를 하기보다는 2단계 (또는 1단계) 로 돌아가야 합니다.

생산 `TestPlan.md`/`ChangeContract.md` 이 단계에서는 더 이상 클로드의 작업이 아닙니다. 현재는 5 단계에서 이루어지고 있습니다.

### 9.2 3단계 는 하지 말아야 한다

클로드는

- 실행 코드를 작성하고,
- 변경 범위를 간편하게 확대하고,
- 새로운 건축 표준을 발명하고
- 승인된 이름 붙인 시스템 이외의 파일의 이름을 변경
- 명시적사람의 승인 없이 새로운 DB 협정을 만들 수 있습니다.
- 약화 RLS/security/evidence 요구사항
- 테스트를 건너뛰기 때문에 변화가 작다고 보이는데
- 일반적 문법 뒤에 있는 재정적 위험을 숨기기
- 클로드 코드 `Overview.md`/`Logic.md` 기본 규칙과 실제 리포 상태에 대한 검증을 하지 않고 최종적인 초안으로 작성합니다.
- 검증된 문서에 결정을 기록하지 않고 침묵으로 "클로드에 대한 공개 질문"을 해결합니다.
- 4단계 독립적인 다중주체 검증의 대가로 자신의 3단계 검토를 처리합니다. 3단계는 클로드의 첫 번째 통과입니다. 필요에 따라 설정된 35/§36의 크로스 주체 검증이 아닙니다.

### 9.3 클로드 코드의 검증 `Overview.md` 초안

클로드 (Claude Code) 초안 (8.9 템플릿) 은 다음과 같은 점에 대해 확인합니다.

- 마스터 아키텍처, 이름 붙여주는 것, 그리고 도메인 컨벤션
- "피해된 도메인"과 "클로드 코드로부터의 영향을 받은 파일"이 실제 레포 상태와 일치하는지;
- "무적" / "무적"은 인접한 범위를 올바르게 배제하는지 여부는
- "금융영향 클래스"와 "위험총괄"이 실제 변동물들과 일치하는지 여부는;
- "클로드에게 대한 공개 질문" 항목에 대한 답변이 있었는지 또는 이유와 함께 명시적으로 연기되었는지;
- 실행 허가로 문장이 잘못 해석될 수 있는지

클로드 업데이트 `## Draft Status` to `Verified (Claude)` 이 검사가 통과된 후에만, 그리고 어떠한 수정도 기록한다.

### 9.4 클로드 클로드 코드 확인 `Logic.md` 초안

클로드 (Claude Code) 초안 (8.10의 표본) 은 다음과 같이 검증됩니다.

- 프로젝트 재정 규칙에 의해 요구되는 무력, 복제 방지, 시간 제한 및 알려지지 않은 상태 처리
- 국가 모델이 실제 schema/RPC 행동 (예정된 설계뿐만 아니라);
- 감사 리더 / 증거 / RLS 규칙이 전체적이고 기본 규칙과 일치하는지
- "금지된 행동"이 해당 영역에 대한 실제 실패 모드를 포함하는지 여부는
- "클로드에게 대한 공개 질문" 항목에 대한 답변이 있었는지 또는 이유와 함께 명시적으로 연기되었는지

클로드 업데이트 `## Draft Status` to `Verified (Claude)` 이 검사가 통과된 후에만, 그리고 어떠한 수정도 기록한다.

### 9.5 단계 3 단계 결정 규칙

클로드의 계층 판례는 4 단계 (그리고 나중에 6 단계, 9 단계) 가 단일 검증기 (코덱스) 또는 더 완전한 커서+코덱스 구성으로 실행되는지 결정합니다. 이 결정은 이미 설정된 같은 기준을 사용합니다. 새로운 상태 기계 모양, 새로운 이름 지향) 는 어떤 코드도 작성되기 전에 더 완전한 비판적 계층 구성이 필요합니다. § 39에 따르면, 정상적인 계층 ( 단일 검증기) 은 이제 예외가 아니라 기본이 아닙니다. 4/6/9 모두 비평급을 달리고 있습니다.

### 9.6 단계 3 간략한 템플릿

```text
당신은 금융 수준의 SaaS 시스템으로의 클로드 코드 설계 초안을 검토하고 있습니다. 당신은 아직 구현 계약을 생산하지 않습니다.

입력:
- ImpactScope.md
- Overview.md (클라우드 코드 초안)
- Logic.md (클라우드 코드 초안)
- 사용자 요구 사항
- 프로젝트 규칙

임무:
- 체크 Overview.md 그리고 Logic.md 기본 규칙과 실제 리포 상태와 클로드에게 공개된 질문
- 작은 작성 오류를 직접 수정하십시오. 영향 범위 자체가 불완전하다면, 그 차이는 그 공백을 중심으로 설계하는 대신 중단하고 2 단계로 변경을 보내십시오.
- 마크 Overview.md / Logic.md 검증된 상태 (Claude) 의 초안은 검사가 통과된 후에야
- 결정 Critical/Normal 4. 단계에 대한 검증 계층 (§9.5)

규칙:
- 실행 코드를 작성하지 마십시오.
- 초안을 작성하지 마십시오 TestPlan.md or ChangeContract.md 5단계라는 것이 클로드 코드가 맡은 일이야, 여기 있는 당신만이 아니라
- 컨텍스트 스냅샷을 프로젝트 규칙 경계로 사용하십시오.
- 이름 붙여주는 협약, DB 협약, RLS 협약, 증거 협약 또는 건축 표준을 재설계하지 마십시오.
- 지역 요구 사항이 기본 규칙과 충돌하는 경우, 표준을 침묵으로 변경하는 대신 갈등을 표시하십시오.
```

### 9.7 3단계 출력

- verified/corrected `Overview.md`
- verified/corrected `Logic.md`
- 검토 의견
- Critical/Normal 4단계 판결이 내려졌어요

### 4단계  건축물 검증 (다중주연)

### 9.8 역할

4 단계는 클로드 이외의 배우가 어떤 계약도 작성되기 전에 독립적으로 3 단계 검증된 디자인을 다시 확인하는 단계입니다.

구성 (§3항9.5의 계층 결정에 따라):

- **정상적 계층**: 코덱스, 더 비결제적 참조 참가자로서 항 중력 (§40).
- **비평 수준**: 커서와 코덱스, 그리고 비결제적 참조 참가자로서 항중력

클로드는 4단계 검증기 보고서의 모든 것을 하나의 `Architecture Review`, 이후 Human에 단계 5 시작되기 전에 단계 5의 단계와 결과를 알려줍니다. 단계 4의 검증자는 승인, 차단 또는 재설계 권한이 없습니다.

### 9.9 단계 4 검증 체크리스트

4 단계의 검증자마다 독립적으로 클로드가 이미 체크인한 같은 차원을 다시 확인합니다 9.3/9.4                                                                                                                                                                                                

- 이 `Overview.md`/`Logic.md` 마스터 아키텍처, 이름 붙여주는, 그리고 도메인 컨벤션에 맞게?
- 국가 모델이 `Logic.md` 실제와 일치하는 schema/RPC 실제 code/DB디자인 프로라 뿐만 아니라?
- 이 영역에 대한 무력, 복제 방지, 시간제 및 알려지지 않은 상태 처리가 완료되었습니까?
- 감사 리더/증거/RLS 규칙은 전체적이고 기본 규칙과 일치하는가?
- 이 조안의 어느 부분에서는 "현재의 패턴을 재사용하는 것"이라고 설명하고 있는데, 즉 실제 코드 검사를 통해 실제로 새로운 조합이나 변형이 (§36.3 (c) 에 따라) 니까?
- 건축적 불합이 있는 것은 `Overview.md` 그리고 `Logic.md` 자기들?

### 9.10 단계 4 간략한 템플릿

```text
당신은 독립적으로 설계 초안을 확인하고 있습니다 (Overview.md/Logic.md클로드의 3단계 통과를 명목적으로 신뢰하지 마십시오 code/DB 당신이 하는 모든 주장에 대해 정확한 파일+ 라인을 인용하고 (이 인용 요구 사항은 Antigravity를 포함한 모든 참가자에게 적용됩니다.

다음을 받을 수 있습니다
- Overview.md, Logic.md (단계 3 검증)
- ImpactScope.md
- 관련 기본 규칙

임무:
9.9항의 항목을 실제와 비교해 보세요 repository/DB 그 문서들이 자기 자신에 대한 주장에 반하지 않고,

규칙:
- 눈만: 연구 결과를 보고하고, 재설계하지 말고, 승인하거나 차단하지 마십시오.
- 결정되지 않은 모든 점을 스스로 결정하기보다는 열린 질문으로 표시하십시오.
- 출력 목록 concerns/discrepancies, 또는 명시적인 "불안은 발견되지 않았다"라는 진술은 침묵하지 마십시오.
```

### 9.11 4단계 출력: `Architecture Review`

클로드의 4 단계 검증자 보고서의 통합은 하나의 기록으로: 각 검증자 결과, 클로드의 처방 (이용 / 추가 조사 / 이유에서 기각) 및 설계가 5 단계로 진행하는 데 여당하는지

### 5단계  계약안정 (클로드 코드)

### 9.12 역할

클로드 코드, 클로드가 아니라 `TestPlan.md` 그리고 `ChangeContract.md` 단계-4 검증된 `Overview.md`/`Logic.md`. 이것은 이전 2단계에서 가장 중요한 단일 행위자 변화입니다. 8단계 구조에서 클로드가 직접 계약을 제작했고, 2026-07-16 구조에서 클로드 코드가 그 계약을 작성하고 클로드의 역할은 계약 자체를 작성하기보다는 검토 (단계 3) 및 다중 행위자 검증을 통합하는 데 좁아졌습니다.

`ChangeContract.md` 여기 제시된 초안은 6단계 검증과 인격 승인을 받을 때까지 구속력이 없습니다.

### 9.13 `TestPlan.md`

목적:

- 시행하기 전에 필요한 테스트를 정의하십시오.
- 코덱스 8단계에서 행복한 경로 테스트만 만드는 것을 막아주십시오.

```markdown
# TestPlan.md

## Required Unit Tests

## Required Integration Tests

## Required SQL / Migration Tests

## Required RLS Tests

## Required Provider Mock Tests

## Required Idempotency Tests

## Required Duplicate Request Tests

## Required Timeout Tests

## Required Unknown State Tests

## Required Rollback Tests

## Required Audit Ledger Tests

## Required Evidence Packet Tests

## Manual Verification Checklist
```

### 9.14 `ChangeContract.md`

목적:

- 실행 경계를 잠겨라
- 코덱스에 건드리지 않는 것을 말해줘
- 실행이 시작되기 전에 인적 승인을 유지하십시오.

```markdown
# ChangeContract.md

## Change ID

## Allowed Files

## Forbidden Files

## Allowed Operations

Allowed operations must be written as narrow verbs, not broad permissions.

Examples:

- Add one validation branch to `<function_name>`.
- Update the implementation body of `<interface_name>` only.
- Add one targeted unit test file under `<test_path>`.
- Add one SQL constraint in the approved migration file.
- Add one audit ledger event emission at the approved state transition.
- Add one evidence manifest field for the active `CHANGE_ID`.

The contract must explicitly state whether each of the following is allowed or forbidden:

| Operation Type | Decision | Notes |
|---|---|---|
| New source file creation | ALLOWED / FORBIDDEN | Default: FORBIDDEN unless named. |
| New test file creation | ALLOWED / FORBIDDEN | Default: ALLOWED only when named in TestPlan.md. |
| New SQL migration | ALLOWED / FORBIDDEN | Default: FORBIDDEN unless approved by Human Boundary Approval. |
| Existing function body edit | ALLOWED / FORBIDDEN | Must name function or class. |
| Public interface change | ALLOWED / FORBIDDEN | Default: FORBIDDEN. |
| Route/API contract change | ALLOWED / FORBIDDEN | Default: FORBIDDEN. |
| RLS policy edit | ALLOWED / FORBIDDEN | Default: FORBIDDEN; full pipeline required if allowed. |
| Generated file edit | ALLOWED / FORBIDDEN | Default: FORBIDDEN. |
| Lock file edit | ALLOWED / FORBIDDEN | Default: FORBIDDEN. |
| Formatting-only changes | ALLOWED / FORBIDDEN | Default: FORBIDDEN. |
| Korean Markdown rewrite | ALLOWED / FORBIDDEN | Default: FORBIDDEN unless document task. |
| Helper abstraction creation | ALLOWED / FORBIDDEN | Default: FORBIDDEN unless justified. |

Allowed Files are not enough.

A file may be allowed while most operations inside that file remain forbidden.

## Forbidden Operations

Forbidden operations must include both project-wide defaults and change-specific prohibitions.

Default forbidden operations:

- Broad refactor.
- New architecture layer.
- New generic helper framework.
- Unrequested renaming.
- Formatting-only diff.
- Encoding normalization.
- Generated file edit.
- Lock file edit.
- Korean Markdown rewrite.
- Any edit outside approved files.
- Any edit not explicitly covered by Allowed Operations.

## Operation Granularity Rule

Codex must receive the smallest executable operation set that can satisfy the change.

Bad:

```text
허용된 운행:
- 결제 취소 논리를 업데이트
```

좋은 것

```text
허용된 운행:
- In `payment_cancel_callback_handler.dart`, 편집만 `handleCancelCallback()`.
- 상태 전환 전에 무력 검사를 추가 `cancel_requested` to `cancel_confirmed`.
- 감사 이벤트를 추가 `payment.cancel.callback.duplicate_ignored` 복제된 호출을 무시할 때
- 복제 호출 및 알려지지 않은 제공자 상태를 위한 테스트를 추가합니다.

금지된 운행:
- 공급자 인터페이스를 변경하지 마십시오.
- 경로 모양을 바꾸지 마세요.
- 일반 지불 국가 유틸리티를 추가하지 마십시오.
- 결제, 지불 또는 환불 모듈에 손을 들어서는 안 됩니다.
```

## 필요 한 사업 규칙

## 국가 규정

## 필요성 있는 무능력성 규칙

## 필요한 감사 규칙

## 필요성 있는 시험

## 필요한 확인 명령어

## 롤백 요구 사항

## 예상되는 최종 결과물

## 인간적 인 한계 의 승인

승인 / 승인되지 않음

승인자:
시간표:
승인 메모:
```

### 9.15 단계 5 간략한 템플릿

```text
당신은 클로드 코드입니다. 4단계 검증된 설계로 금융 수준의 SaaS 시스템을 위한 구현 계약을 작성하고 있습니다.

입력:
- ImpactScope.md
- Overview.md (단계 3 확인,단계 4 확인)
- Logic.md (단계 3 확인,단계 4 확인)
- 건축 검토 (4단계 출력)
- 사용자 요구 사항
- 프로젝트 규칙

생성:
1. TestPlan.md
2. ChangeContract.md (안안  아직 승인되지 않은; 단계 6가 확인하고 단계 7가 승인)

규칙:
- 아직 실행 코드를 작성하지 마십시오.
- 컨텍스트 스냅샷을 프로젝트 규칙 경계로 사용하십시오.
- 이름 붙여주는 협약, DB 협약, RLS 협약, 증거 협약 또는 건축 표준을 재설계하지 마십시오.
- 지역 요구 사항이 기본 규칙과 충돌하는 경우, 표준을 침묵으로 변경하는 대신 갈등을 표시하십시오.
- 돈 이동 논리를 명확하게 유지하세요.
- 너무 추상화하지 말아요.
- 무제한성, 복제 예방, 시간 제한, 알려지지 않은 상태, 반납, 감사 리더 및 증거 요구사항을 포함합니다.
- 허용된 파일과 금지된 파일들을 포함합니다.
- 자동 확인 명령어를 포함합니다.
- 위험과 필요한 승인을 포함합니다.
```

### 6단계  계약 검증 (다중공업자, §37)

### 9.16 역할

6단계 검증 `TestPlan.md`/`ChangeContract.md` 인간 승인 (단계 7) 이전에. 클로드 코드 37 § 에 따르면, 5단계에서의 계약 자체 작성자 는 6단계 검증자 풀에서 제외된다.

구성 (§3 §9.5의 계층 결정에 따라, 4 단계와 같은 규칙):

- **정상적 계층**: 코덱스, 그리고 비결제적 참조 참가자로서 항 중력
- **비평 수준**: 커서와 코덱스, 그리고 비결제적 참조 참가자로서 항중력

클로드는 6단계 검증기 보고서를 7단계에서 수신되는 검증된 계약에 통합한다.

### 9.17 단계 6 검증 체크리스트

- Do `Allowed Files`/`Forbidden Files`/`Allowed Operations` 실제로 경계를 맞춘 `Overview.md`/`Logic.md` 더 넓은 나 좁은 경계를 설명하지 않는가?
- 모든 것이 `Allowed Operations` 좁은 동사 (운전 비밀성 규칙 9.14에 따라) 를 입력하고, 넓은 허가를 하지 않는가?
- 이 `TestPlan.md` 덮음 idempotency/duplicate/timeout/unknown-state/rollback/audit/evidence 요구 사항 `Logic.md` 전화?
- 계약에 있는 어떤 것도 4단계와 일치하지 않는가 `Architecture Review`?

### 9.18 단계 6 즉흥 템플릿

```text
당신은 임시 계약에 대해 독립적으로 검증하고 있습니다 (TestPlan.md/ChangeContract.md클로드 코드 (Claude Code) 에 의해 작성된 모든 청구에 대한 정확한 파일 + 라인을 적어 주세요 (Antigravity) 에 해당하는 경우 40.3조가 적용됩니다.

다음을 받을 수 있습니다
- TestPlan.md, ChangeContract.md (단계 5 초안)
- Overview.md, Logic.md (단계 4 검증)
- 건축 검토 (4단계 출력)

임무:
9.17에 있는 항목을 확인하여 계약 경계선이 사실 검증된 디자인과 일치하는지 확인합니다.

규칙:
- 눈만: 연구 결과를 보고하고, 재설계하지 말고, 승인하거나 차단하지 마십시오.
- 출력 목록 concerns/discrepancies, 또는 명시적인 "불안은 발견되지 않았다"라는 진술은 침묵하지 마십시오.
```

### 9.19 6단계 출력

확인 `TestPlan.md` 그리고 `ChangeContract.md`7단계 인적 승인 준비. 4단계와 마찬가지로, 제기된 우려는 결코 침묵으로 내려지지 않습니다.

### 9.20 Stage 7 제시 전 Claude의 원문서 직접 검토 필수 (2026-07-18 추가, 실제 사례 기반)

Stage 6(Contract Verification) 검증자들의 raw 결과를 통합해서 "우려사항 해소/미해소"를 판정한 뒤, Human에게 Stage 7(§10 Human Approval) 체크박스를 안내하기 전에, Claude는 반드시 `TestPlan.md`/`ChangeContract.md` 원문 자체를 직접 읽어야 한다. 검증자 보고서를 요약해서 전달하는 것만으로는 불충분하다 — 검증자들이 놓친 것을 Claude가 직접 읽다가 발견하는 경우가 실제로 있었다(`canonical_kds_release_orchestration` 워크패킷, 검증자 3명 전원이 ACCEPT라고 했음에도 Human이 "지시어를 주기 전에 해당 문서 2개를 자체 검증을 해야죠"라고 지적해 막았고, 이후 Claude가 §2.1-§2.5 SQL 실행가능성/§4 EXCEPTION 경로/§6.2-§6.3 회귀테스트/§0 발견경위/Stop Conditions를 라인 단위로 직접 재검토한 뒤에야 Stage 7로 진행함 — 검증자 전원 ACCEPT라는 사실 자체가 Claude 자신의 직접 검토를 생략할 근거가 되지 않는다는 원칙 재확인).

이 직접 검토가 새로운 문제를 발견하면, Stage 5로 되돌려 정정한 뒤 Stage 6을 재실행한다. 문제가 없으면 그제서야 Stage 7(§10 체크박스)을 Human에게 제시한다.

이 원칙은 §9.3/§9.4(Stage 3, `Overview.md`/`Logic.md` 직접 검토)의 연장선이며, "Claude는 어느 단계에서도 다른 행위자의 보고를 액면 그대로 신뢰하지 않고, 최종 감사 권한을 가진 자로서 직접 근거를 재확인한다"는 Stage 11 Final Audit(§13) 원칙이 Stage 7 이전에도 동일하게 적용됨을 명시한다 — Stage 11이 구현 이후의 마지막 방어선이라면, 이 규칙은 구현 착수(Stage 8) 이전, 즉 Human이 되돌릴 수 없는 승인 결정을 내리기 전의 동일한 방어선이다.

---

## 10. 7단계  인간 승인

### 10.1 역할

인간은 설계와 구현 사이의 승인을 위한 게이트입니다.

인간에게 3-6 단계 설계 및 계약 검증 패키지가 전체적으로 제공됩니다.

- `ImpactScope.md`
- 확인 `Overview.md`
- 확인 `Logic.md`
- `TestPlan.md`
- 확인 `ChangeContract.md`

인간은 디자인 패키지를 검토하고 코덱스가 닿을 수 있는 정확한 파일 경계선을 결정합니다. 이것은 스테이지 3-6의 내부의 독립적인 단계가 아닙니다. reviewing/integrating (단계 3, 4, 6) 자체적으로 시행을 승인하지 않습니다.

### 10.2 왜 이 단계 는 독립적 인 단계 인가

인간 승인 을 3-6 단계 로 접는 것 은 "디자인 패키지 완성"을 "인적 승인 된 구현"과 동등 한 것 으로 간주 하는 것 을 쉽게 해 준다.

### 10.3 7단계 출력

As of 2026-07-10, `ChangeContract.md` 단일 합병 산출물  별도의 독립적사람의 승인을 위한 파일은 없습니다. 7 단계는 다음과 같이 만족됩니다:

```text
ChangeContract.md -> ## 사람의 경계 승인 섹션, 작성
```

### 10.4 인간 승인 선언

```text
시행에 승인

허용된 파일:
- < 파일 1>
- <파일 2>
- < 파일 3>

허용된 운행:
- < 좁은 동사, ChangeContract.md 운용 미분성 규칙>

금지:
- 다른 모든 파일
- 문서/** 명시적으로 승인되지 않는 한
- 생성된 파일은 명시적으로 승인되지 않는 한
- 명시적으로 승인되지 않는 한 잠금 파일
- 한국 마크다운 파일, 명시적으로 승인되지 않는 한
- 관련 없는 모듈

코덱스는 승인된 ChangeContract.md코덱스는 자기 승인, 자체 스테이징 또는 자체 커밋에 대한 권한이 없습니다.

승인자:
시간표:
승인 메모:
```

### 10.5 7단계 합격 기준

7단계는 다음 단계에서만 통과됩니다.

- 인간은 읽은 `Overview.md`, `Logic.md`, `TestPlan.md`, 그리고 `ChangeContract.md` (단순히 파일 목록을 지 않았습니다.)
- 허용된 파일과 허용된 동작은 "모두 모듈"보다 명시적이고 좁습니다.
- 디자인 패키지에 해결되지 않은 "클로드에 대한 개방된 질문"은 여기에서 답변되거나 문서화된 이유로 명시적으로 연기됩니다.
- 승인 산출물은 활성 `CHANGE_ID`.

만약 사람이 승인할 준비가 되지 않는다면, 변경은 18부의 루프백 규칙에 따라 3단계 (디자인 격차) 또는 2단계 (범위 격차) 로 돌아갑니다.

---

## 11. 8단계  코데스 일제 한 단계 시행

2026년 7월 10일부터 코덱스는 클로드의 통치 아래 준속 실행 도구로 다시 도입된 스테이지 8의 구현자입니다. 코덱스는 자기 승인, 자체 스테이징 또는 자체 커밋에 대한 권한을 가지고 있지 않습니다.

### 11.1 역할

코덱스는 제한된 실행자 역할을 한다.

코덱스는 다음과 같이 수신합니다.

- `ImpactScope.md`
- `ImpactScope.md`
- `Overview.md`
- `Logic.md`
- `TestPlan.md`
- 승인 `ChangeContract.md`
- `ChangeContract.md` (또는 채용된 사람의 경계 승인 섹션)

코덱스는 허용된 범위 내에서만 시행하고, 엄격히 `ChangeContract.md` 경계를

### 11.2 코덱스 규칙

코덱스는 다음을 해야 합니다

- 차이는 작게 유지하세요.
- 허용된 파일만 수정하세요.
- 넓은 리팩터에서 벗어나십시오.
- 똑똑한 추상화를 피하십시오.
- 관련 없는 포맷을 변경하지 마십시오.
- 한국인 마크다운을 바꾸지 말아요
- 암호를 변경하지 마십시오.
- 승인되지 않는 한 생성된 파일들을 피하십시오.
- 승인되지 않는 한 잠금 파일을 피하십시오.
- 금융 논리 가독성을 유지하세요.
- 추가 또는 업데이트 테스트 `TestPlan.md`.
- 생성 `ImplementationModule.md` 시행 후
- 자기 승인, 자체 스테이징 또는 자체 커밋은 절대 하지 않습니다. 9/6 하류에서 신뢰를 받기 전에 검토가 필수적입니다.

### 11.3 코덱스 간략 한 템플릿

```text
당신은 제한된 실행자입니다. 승인할 권한은 없습니다.
무대, 또는 어떤 일을 수행
클로드의 11단계 감사가 할 수 있기 전에 9단계에서의 작업을 다시 확인합니다
받아들이세요

사용만:
- ImpactScope.md
- ImpactScope.md
- Overview.md
- Logic.md
- TestPlan.md
- 승인 ChangeContract.md

규칙:
- 허용된 파일에서 나열된 파일만 수정합니다.
- 금지된 파일들을 수정하지 마십시오.
- 관련 없는 코드를 재조정하지 마십시오.
- 명시적으로 요구되지 않는 한 새로운 추상화를 도입하지 마십시오.
- UTF-8를 보존해
- 코딩을 정상화하지 마십시오.
- PowerShell 세트 컨텐츠를 사용하지 마십시오.
- 한국어 마크다운을 다시 쓰지 마
- 통화 사이트에서 현금 이동 국가 전환을 명시적으로 유지하십시오.
- 이 문서에 나열된 테스트를 추가하거나 업데이트 TestPlan.md.
- 다른 파일 필요하다면, 멈추고 새로운 단계 7 경계 승인 요청하세요.
- 실행 후, ImplementationModule.md.

출력:
- 코드 변경
- ImplementationModule.md
```

### 11.4 코드 단순성 규칙

재정적 논리는 읽을 수 있어야 합니다.

```text
일반적 서비스 기능 안에 재정적 결정을 숨기지 마십시오.
승인되지 않는 한 프레임워크와 같은 추상화를 만들지 마십시오.
명시적인 상태 전환 기능을 선호합니다.
똑똑한 역동적 배포보다 맑은 상태의 분할을 선호합니다.
작은 이름의 함수를 큰 둥근 논리에 더 선호합니다.
가능한 경우 비변수에 대한 데이터베이스 제한을 선호합니다.
가장 좋은 노력의 복제 검사를 하는 것보다 무력함 키와 고유한 제약이 더 좋습니다.
지루한 코드를 인상적인 코드를 선호합니다.
```

### 11.5 8단계 출력: `ImplementationModule.md`

```markdown
# ImplementationModule.md

## Change ID

## Files Modified

## Summary Of Implementation

## Business Logic Implemented

## State Transitions Implemented

## Idempotency / Duplicate Prevention

## Timeout / Unknown State Handling

## Audit Ledger Changes

## Evidence Packet Changes

## RLS / Permission Changes

## Tests Added Or Modified

## Rollback Notes

## Known Limitations

## Deviations From ChangeContract.md
```

이 부분에서 경각심을 보이는 경우 `ChangeContract.md`코덱스는 명시적으로 명목을 작성해야 합니다.

숨겨진 경각심이 허용되지 않습니다.

만약 변동이 새로운 파일, 새로운 마이그레이션, 새로운 권한, 또는 더 넓은 도메인 영향이 필요한 경우, 구현은 중단되고 3단계로 다시 재설계하고 새로운 7단계 승인을 위해 돌아가야 한다.

---

## 12. 9단계  클로드 코드 독립적인 재확인

2026-07-10시 기준 9단계는 자기 검증이 아닌 크로스 모델 검증입니다. 코덱스 (단계 8) 는 구현을 작성했으며 클로드 코드가 (다른 모델) 는 독립적으로 다시 검증합니다. 이것은 의도적인 다양성 보호입니다. 아래 9단계 (비평적 계층) 과 같은 합리화 및 §26 반대의 면허가 요구 사항입니다.

### 12.1 역할

9단계란 인공지능 판단 단계가 아닙니다.

이것은 기계적 검증 단계이며 코덱스 8 단계의 구현에 따라 수행된다.

클로드 코드가 직접 터미널과, 필요한 경우, CI 파이프라인을 이용하여 수행한다.

9단계 내에서 클로드 코드는 명령 실행자 및 증거 수집자로서만 활동합니다.  검증되는 코드를 작성하지 않았으며, 자신의 9단계 통과를 실제 원료 명령어에서 보여주는 것보다 더 정확한 구현을 증명하는 것으로 간주해서는 안됩니다. (실현성 검증 요구사항 25 참조).

클로드 코드는 새로운 승인된 사이클을 통해 단계 1, 단계 2, 단계 3 또는 단계 7에 명시적으로 반환하지 않는 한 결과를 해석하거나 자동으로 수정하거나 다시 작성해서는 안 됩니다.

### 12.2 클로드 코드가 왜 판사가 아닌지

클로드 코드는 명령을 실행할 수 있지만, 금융의 정확성을 결정하는 데는 신뢰를 받지 말아야 합니다.

9단계 클로드 코드는 다음과 같습니다

```text
터미널 운영자
지휘관
무작위 나무 수집가
디프 수집기
결과 기록기
```

클로드 코드는

```text
코드 수정
건축가
감사원
금융 리스크 심사위원
최종 판사
```

### 12.3 9단계 명령 카테고리

필요한 명령 카테고리:

- Git의 무결성을 구분합니다.
- 정적 분석
- 타입 체크
- 단위 테스트
- 통합 테스트
- 이민 건조한 운영.
- RLS/security 체크
- 무능력 검증
- 복제 요청 테스트
- Timeout/unknown-state 시험
- Audit/evidence 시험

### 12.4 예제 확인 명령어

플러터 / 다트:

```bash
git diff --stat
git diff --check
git diff --name-only

git diff

flutter analyze
dart test
```

수파베이스 / SQL:

```bash
supabase migration list
supabase db diff
supabase db push --dry-run
```

노드 / 타이프스크립트

```bash
npm run lint
npm run typecheck
npm test
```

목표형 시험:

```bash
dart test test/payment/
dart test test/refund/
dart test test/payout/
dart test test/reconciliation/
dart test test/provider/
dart test test/audit/
```

보안/RLS 검사는 프로젝트별로 이루어질 수 있습니다.

```bash
psql -f scripts/check_rls.sql
psql -f scripts/check_financial_constraints.sql
psql -f scripts/check_idempotency_constraints.sql
```

### 12.5 클로드 코드 터미널 9단계

```text
아래와 같이 표시된 명령어만 실행하세요.

규칙:
- 어떤 파일도 수정하지 마십시오.
- 자동으로 고치지 마세요.
- 포맷하지 마세요.
- 실수들을 정리하지 마십시오.
- 전체 원료 출력을 유지하세요.
- 원자 로그를 저장 `docs/implementation_evidence/<change_id>/raw_logs/` 가능하면
- 명령어 중도 또는 반복 가능한 스크립트를 수동 복사-붙여넣기보다 선호합니다.
- 명령이 실패하면, 중지하고 전체 출력 경로를 추가로 전체 출력을 보존하십시오.

명령:
< 명령 목록>
```

### 12.6 9단계 출력: `VerificationResult.md`

```markdown
# VerificationResult.md

## Change ID

## Verification Environment

## Git Diff Summary

## Commands Executed

| Command | Result | Raw Log Path | Notes |
|---|---|---|---|
| git diff --stat | PASS/FAIL | raw_logs/01_git_diff_stat.txt | |
| git diff --check | PASS/FAIL | raw_logs/02_git_diff_check.txt | |
| git diff --name-only | PASS/FAIL | raw_logs/03_git_diff_name_only.txt | |
| git diff | PASS/FAIL | raw_logs/04_git_diff.patch | |
| flutter analyze | PASS/FAIL | raw_logs/05_flutter_analyze.log | |
| dart test | PASS/FAIL | raw_logs/06_dart_test.log | |
| supabase migration dry-run | PASS/FAIL | raw_logs/07_migration_dry_run.log | |
| RLS check | PASS/FAIL | raw_logs/08_rls_check.log | |

## Failed Commands

## Full Error Output

## Raw Log Inventory

## Files Changed Outside Allowed Scope

## Migration Result

## RLS / Security Result

## Idempotency / Duplicate / Unknown-State Result

## Audit / Evidence Result

## Verification Decision

PASS / FAIL / BLOCKED
```

### 12.7 9단계 합격 기준

9단계는 다음 단계에서만 통과됩니다.

- 허가되지 않은 파일은 변경되지 않습니다.
- 정적 분석이 통과됩니다.
- 타입 체크 승격증
- 필요한 검사 합격
- 마이그레이션 건조한 통행 통행
- RLS/security 해당 경우 검사가 통과됩니다.
- 무능력 검사가 통과됐어요
- 복제 요청 테스트가 통과됩니다.
- Timeout/unknown-state 시험 합격
- Audit/evidence 시험 합격
- 코딩이나 포맷 트리프가 감지되지 않습니다.
- 승인 없이 생성되거나 잠금된 파일은 변경되지 않습니다.
- 무작위 로그와 gitdiff은 11단계로 보존됩니다.

### 12.8 9단계 실패 처리

9단계 실패하면

1. 클로드 코드가 직접 수정하지 않도록 하십시오  그것은 코덱스의 구현을 확인하고, 수정의 저작자가 아닙니다.
2. 기록 실패 `VerificationResult.md`.
3. 원료 터미널 출력을 보존합니다.
4. 보존 `git diff` 그리고 `git diff --name-only`.
5. 실패 유형에 따라 3단계 또는 8단계로 돌아가십시오.
6. 만약 실패가 설계 문제로 표시된다면 클로드 설계 검토 (단계 3) 에 다시 돌아가십시오.
7. 만약 실패가 승인된 범위 내에서 실행 오류를 나타낸다면, 원본 오류 로그를 가지고 코덱스 (단계 8) 에 돌아가십시오.
8. 새로운 파일 범위가 필요하다면, 재설계 및 새로운 단계 7 인적 경계 승인에 대한 3 단계로 돌아가십시오.

### 12.9 9단계 (비평적 단계)  경과자 소수 의견 검토

목적: 두 번째, 다른 시각적으로 블라인드 스포트 모델은 동일한 구현과 클로드 코드의 9 단계 검증 출력을 검토하고, 특히 클로드 코드의 승인이 놓쳤을 수 있는 모든 것을 찾고 있습니다 training/prompting 다른 종류의 실패를 발견하는 경향이 있습니다.

적용됩니다. Medium/Full 레이어 변경만 (§31) 라이트웨이트 트랙 (§24) 또는 순전히 기계적 고정에 적용되지 않습니다.

규칙:

- 커서: 승인된 `ChangeContract.md`, 실제 코드와 클로드 코드의 `VerificationResult.md` 9단계부터
- 커서 (Cursor) 는 짧은 `MinorOpinion.md`: 우려, 불일치 또는 의문 사항의 목록 pass/fail 선고는 게이트가 아니라, 검증자가 변경을 차단하거나 승인하거나 요구할 권한이 없습니다.
- 가수들이 아무것도 찾지 못하면 `MinorOpinion.md` 명시적으로 (정확한 통과는 여전히 기록된 출력이며 침묵이 아닙니다.)
- 클로드의 11단계 감사는 반드시 읽어야 합니다 `MinorOpinion.md` 옆으로 `VerificationResult.md` 그리고 원시 차이, 그리고 명시적으로 해결해야 (안, 추가 조사, 또는 왜 거절) 커서  침묵으로 커서 우려 무시 Cursor 제기 된 ACCEPT/REJECT 권위는 클로드에게만 남아 있습니다.

#### 12.9.1 어 Minor Opinion 간략 템플릿

```text
제2의 의견은 불가결합니다.
아니면 변화를 요구할 수도 있습니다. 클로드의 11단계에 대한 우려만 제기할 수 있습니다.
감사에 대한

다음을 받을 수 있습니다
- ChangeContract.md (안정된 경계)
- 실제 코드 차이
- 클로드 코드의 VerificationResult.md (단계 9)

임무:
클로드 코드의 9단계 검증에서 놓친 것을 찾아보세요.
- 이 논리는 일치하지 않습니다 ChangeContract.md or Logic.md
- 가장자리 경우 확인 명령이 실제로 실행되지 않았습니다
- 이 같은 VerificationResult.md 원조의 기록이 실제로 지원하지 않는다는 것을
- 명령에 의해 보고된 경우에도 잘못된 것처럼 보이는 모든 PASS

출력:
- 이 목록은 concerns/discrepancies/questions, OR
- 우려가 발견되지 않았다는 명시적인 진술 (잠잠지 마십시오).

당신은 PASS/FAIL 판례, 당신은 게이트 권한이 없습니다.
```

#### 12.9.2 9단계 (비평 단계) 출력: `MinorOpinion.md`

```markdown
# MinorOpinion.md

## Change ID

## Reviewed Against

- ChangeContract.md
- code diff
- VerificationResult.md (Stage 9)

## Concerns

(List each concern/discrepancy/question. If none, state explicitly: "No concerns found.")

## Not A Verdict

This document is a non-binding second opinion. It carries no approve/block authority. Claude's Stage 11 audit must explicitly address each concern above, but is not obligated to agree with it.
```

---

## 13. 11단계  독립 감사 (11A 클로드 감사 / 11B 채팅GPT 블라인드 감사 / 11C 갈등 분석)

**2026-07-18 구조 변경**: Stage 11은 이제 3개 하위 단계로 구성된다 — **11A**(§13.1-§13.5, Claude의 raw-증거 기반 감사, 기존과 동일), **11B**(§13.8, ChatGPT의 진짜 블라인드 역설계 감사, 신규·모든 워크패킷 의무), **11C**(§13.9, Human이 11A/11B를 직접 대조하는 Conflict Analysis, 신규). 이 세 단계 전체를 근거로 최종 병합 결정을 내리는 것은 **여전히 별도의 Stage 12(§14, Human Merge And Release Evidence)이며, 번호나 구조가 바뀌지 않는다** — Stage 11의 하위단계로 흡수되지 않는다. 근거와 배경은 §13.7(Dual Anchor Principle)을 참고.

### 13.1 11A 단계  역할

클로드는 독립적인 감사를 합니다.

2026-07-10 (단계 번호가 2026-07-16에 업데이트된 참조 §3) 으로, 클로드의 감사는 4개의 개별 당사자 (Cursor (단계 1 스캔, 9단계 비평적-단계 소수 의견) 의 진정한 크로스 모델 검증입니다. 클로드 코드 (단계 2 초안, 5단계 계약 초안, 9단계 재검정), 코덱스 (단계 8 시행), 클로드 자체 (단계 3, 4단계, 6단계 11). 클로드는 코덱스의 구현 자부 보고, 클로드 코드의 스테이지 9 검증 보고, 또는 커서의 스테이지 1 / 스테이지 9 (비평 단계) 출력을 인정하는 대신 원본적 값으로 원본적 차이, 원본적 기록 및 저장소 증거들을 직접 재확인해야 합니다.

클로드에게

- `ImpactScope.md`
- `ImpactScope.md`
- `Overview.md`
- `Logic.md`
- `TestPlan.md`
- 승인 `ChangeContract.md`
- `ChangeContract.md` (또는 채용된 사람의 경계 승인 섹션)
- `ImplementationModule.md` (코덱스의 자발적인 보고)
- `VerificationResult.md` (클로드 코드의 9단계 크로스 모델 재확인)
- `MinorOpinion.md` (지휘자의 9단계 (비평적 계층) 비결제적 제2의 의견, Medium/Full (단계)
- 원료 터미널 로그
- `git diff --stat`
- `git diff --check`
- `git diff --name-only`
- 전체 또는 범위를 `git diff`

클로드는 실행이 계획과 일치하는지 확인하고 계획 자체에는 여전히 숨겨진 실패 모드가 있는지 확인합니다. `ImplementationModule.md` 코덱스의 자발적인 보고서이며 `VerificationResult.md` 클로드 코드의 보고  클로드는 원자재 로그와 차이점 모두 확인해야 하며, 명목적 가치로도 받아들이지 않습니다. `MinorOpinion.md`  Cursor의 우려를 묵묵히 무시하는 것은 허용되지 않지만 클로드는 동의할 의무가 없습니다.

### 13.2 단계 11A  감사 집중

클로드가 검토해야 합니다.

- 코덱스는 승인된 파일만 수정했습니까?
- 코덱스는 계획된 논리를 실행했습니까?
- 코덱스는 엣지 케이스를 넘겼나요?
- 코덱스는 승인되지 않은 추상화를 추가했습니까?
- 테스트는 필요한 금융 위험을 감수했습니까?
- 자동 검증이 통과됐나요?
- 원시 로그 는 요약 으로 숨겨진 경고 를 드러내는가?
- gitdiff는 관련 없는 형식화 또는 코딩 추동을 보여줍니다?
- 금융 사고가 일어날 수 있는 상황인가요?
- 감사 기록이 완료됐나요?
- 이 permissions/RLS 안전해?
- 역전적인가요?
- 증거가 충분할까요?
- 코드는 단순해져 있습니까?
- 구현은 여전히 기본 컨텍스트 스냅샷과 일치합니까?
- 클로드 코드가 2단계에서 잡아야 했던 어떤 것도 커서 1단계 스캔에서 놓쳤나요?
- 모든 관심사를 가지고 있습니다 `MinorOpinion.md` (단계 9 (비평적 계층)) 은 명시적으로 해결됐고, 조용히 떨어지지 않았습니까?

### 13.3 단계 11A  반대의 감사

```text
실행이 잘못되었다고 가정해 봅시다.

검토:
- ImplementationModule.md (코덱스 자부신)
- VerificationResult.md (클로드 코드 크로스 모델 재확인)
- MinorOpinion.md (제2심판의 통행자: Medium/Full (단계)
- 원료 터미널 로그
- git -stat
- git - check
- git diff--명만
- 전체 git 차이
- ImpactScope.md
- ChangeContract.md

위와 같은 것을 명목값으로 받아들이지 마십시오
원조의 차이와 원조의 기록에 대해 주장합니다.
모든 우려의 MinorOpinion.md.

이 변화가 어떻게 일어날 수 있는지 알아보세요.
- 복제 충전
- 복제 환불
- 이중 지불
- 잘못된 지불
- 은행 상태가 알려지지 않은 부정행위
- 결제 불합리
- 제공자 지위 잘못 해석
- RLS 회전
- 감사 리더 실종 사건
- 증거 패킷 격차
- 반전 실패
- customer/store 메시지의 잘못된 결말
- 허가되지 않은 파일 수정
- 승인되지 않은 추상
- 마스터 규칙 위반
```

### 13.4 단계 11A 출력: `AuditReview.md`

`AuditReview.md` 이 confirm/audit 일부 팀들은 이 이름을 선호합니다. `implementation_confirm.md`; 이 프로젝트의 결제, POS 및 다른 실행 시간 진실 도메인 `AuditReview.md` 클로드의 역할은 단순한 확인 체크박스보다는 감사가 되기 때문에 선호합니다.

**2026-07-18부터**: 이 `AuditReview.md`는 Stage 11C(§13.9)에서 Stage 11B(ChatGPT Blind Audit, §13.8)의 결과와 나란히 대조되는 두 입력 중 하나다 — Stage 11A 혼자만으로는 Stage 12(§14) Human 병합 결정의 충분한 근거가 아니다(§13.7 Dual Anchor Principle).

```markdown
# AuditReview.md

## Change ID

## Documents Reviewed

## Raw Logs Reviewed

## Git Diff Summary

## Approved Scope Compliance

PASS / FAIL

## Master Rule / Context Snapshot Compliance

PASS / FAIL

## Logic Compliance

PASS / FAIL

## Test Coverage Review

PASS / FAIL

## Automated Verification Review

PASS / FAIL

## Minor Opinion Review (Stage 9 (Critical tier), Medium/Full Tier)

For each concern raised in `MinorOpinion.md`: ACCEPTED / INVESTIGATED / DISMISSED (with reason). If `MinorOpinion.md` states no concerns were found, note that explicitly here rather than leaving this section blank.

## Raw Error Log Review

## Financial Accident Scenario Review

## Idempotency / Duplicate Prevention Review

## Timeout / Unknown State Review

## RLS / Permission Review

## Audit Ledger Review

## Evidence Packet Review

## Rollback Review

## Code Simplicity Review

## Findings

| Severity | Finding | Required Action |
|---|---|---|

## Audit Decision

APPROVE / APPROVE_WITH_NOTES / BLOCK

## Required Human Review Notes
```

### 13.5 단계 11A 블록 기준

클로드 오디트는 다음과 같은 경우 차단해야 합니다.

- 허가되지 않은 파일들이 변경되었습니다.
- 돈 이동 논리는 모호하다.
- 알려지지 않은 상태는 success/failure 증거가 없는
- 이중 예방이 없어졌습니다.
- 무능력이 없어
- RLS 또는 접근 규칙은 안전하지 않습니다.
- 감사 리더 이벤트가 없어졌습니다.
- 증거 패킷 경로가 없어
- 시험은 필요한 경우를 포함하지 않습니다.
- 롤백은 불가능하거나 문서가 없는 일입니다.
- 코드는 너무 넓거나 추상적이기도 합니다.
- 검증 실패
- 실패한 명령에 대한 원자 로그가 없어
- Git 디프리스는 없어졌습니다.
- 승인 없이 계약에 대한 이행이 이탈했습니다.
- 시행은 기본 규칙과 충돌 `ImpactScope.md`.
- 이 문제에 대한 우려 `MinorOpinion.md` (Medium/Full (제1급) 과 관련한 내용은 명시적으로 다루지 않았습니다.

### 13.6 앵커링 방지 규칙 — Raw 증거로부터의 직접 재도출 (2026-07-18)

Stage 11(최종 감사) 수행 시, Claude는 이전 Stage들에서 이미 형성된 요약/통합 결과 — 설령 그것이 Claude 자신(또는 이전 세션의 자신)이 작성한 것이라 해도 — 를 그대로 신뢰하지 않는다. 핵심 주장(무엇이 바뀌었는가, 무엇이 검증됐는가, 무엇이 아직 미해결인가)은 반드시 다음 원본 증거로부터 직접 재도출해야 한다:

- 원료 차이`git diff`의 실제 텍스트 — 요약이나 서술이 아님)
- raw 실행 로그(테스트/쿼리의 실제 출력 — "통과했다"는 문장이 아님)
- 각 검증자(Cursor/Codex/Antigravity 등)의 원본 raw 보고서 — Claude 자신이 이미 통합한 요약본이 아님

**근거**: Stage 3부터 Stage 11까지 여러 단계에 걸쳐 동일한 Claude가 계속 판단을 내리는 이 파이프라인 구조상, 초기 단계에서 형성된 해석이 후속 단계까지 그대로 지속되는 앵커링(anchoring) 편향 위험이 구조적으로 존재한다 — 인간 검토자가 자기 자신의 이전 결론에 저항하기 어려운 것과 동일한 인지적 함정이다. Stage 11이 단순한 재확인이 아니라 진짜 독립 감사로서 의미를 가지려면, 이전 단계의 통합/요약 결과가 아니라 그 통합의 재료였던 원본 증거를 다시 봐야 한다.

**적용**: 위 세 종류의 원본 증거로부터 핵심 주장을 직접 재도출한 뒤, 그 결과를 이전 단계의 통합 결과와 대조한다 — 일치하면 그대로 ACCEPT 근거로 쓰고, 불일치가 발견되면 그 불일치 자체를 감사 결과에 명시한다(§44.2 Zero Deferred Doubt 원칙과 동일한 정신을 Stage 11에 특화 적용한 것).

(2026-07-18, ChatGPT 교차검증 기반 반영)

### 13.7 Dual Anchor Principle (2026-07-18, 모든 워크패킷 의무 적용)

**원칙**: Stage 11에서는 동일한 AI 계열이 만든 설계를 동일 계열 AI가 최종 진실로 인정하지 않는다. 반드시 독립 모델(ChatGPT 등)이 동일 결론을 별도 경로(진짜 블라인드 — 사전 맥락 없는 새 대화창)에서 재도출하거나, 차이를 명시적으로 보고해야 한다. 이는 모든 워크패킷의 Stage 11에 예외 없이 적용된다.

**근거(2026-07-18 실제 사례로 확립)**: `canonical_kds_release_orchestration` 워크패킷에서, Claude 혼자 내린 Stage 11 ACCEPT 판정에 실제 결함(두 `EXCEPTION` 핸들러가 자신의 감사기록 호출 실패까지는 방어하지 못해, 이중 실패 시 이미 완료된 `payment_ledger` INSERT까지 롤백되는 문제)이 있었다. 이 결함은 ChatGPT의 독립적 재검토가 먼저 잡아냈고, 이후 Cursor+Codex의 fault-injection(실제 라이브 DB 대상 이중 실패 강제 재현)으로 확정됐다 — "같은 AI 계열이 설계하고 같은 AI 계열이 최종 감사하면 앵커링이 발생한다"는 것의 실제 증거다.

**역할 재정의**:

| 역할 | 클로드 | GPT |
|---|---|---|
| 기본 태도 | 설계를 증명 | 설계를 반증 |
| 11A 단계 | Logic/구현이 계약을 충족하는지 확인 | - |
| 11B 단계 | - | 설계문서 없이 raw 자료만으로 블라인드 역설계 |
| 질문 프레임 | "왜 맞는가" | "왜 틀릴 수 있는가" |

### 13.8 Stage 11B — ChatGPT Blind Audit (신규, 모든 워크패킷 의무)

**전제조건 — 진짜 블라인드**: 반드시 이 워크패킷에 대한 사전 논의가 전혀 없었던, 완전히 새로운 ChatGPT 대화창에서 진행한다. 기존에 이 워크패킷을 함께 만들어온 맥락이 있는 대화창을 재사용하면 블라인드가 성립하지 않는다 — 이 경우 Stage 11B는 무효로 간주하고 새 대화창에서 다시 시작해야 한다.

**1단계 — 제공하는 것 (설계문서는 절대 먼저 보여주지 않는다)**:

- 실제 SQL(관련 migration 파일 전문)
- 실제 스키마
- 트리거 / 뷰
- RPC 정의
- 실제 테스트 결과
- raw 로그

`Overview.md`/`Logic.md`/`TestPlan.md`/`ChangeContract.md` 등 Claude Code가 작성한 설계 문서는 이 단계에서 절대 보여주지 않는다.

지시 프레임(그대로 사용):

```text
아래는 실제 SQL/스키마/테스트 결과입니다. 이 시스템이 무슨 구조인지,
어떤 상태머신을 가정하는지, 경계는 어디인지, 어떤 위험이 있는지
처음부터 역설계해주세요.
```

**2단계 — 그 다음에만** Claude의 Stage 11A 감사 결과(설계문서 포함)를 보여주고, 다음 프레임을 그대로 사용:

```text
이게 Claude의 설계와 감사 결과입니다. 당신이 역설계한 것과 차이가
있는지 찾아주세요.
```

**출력**: ChatGPT가 raw 자료만으로 역설계한 시스템 모델, 그리고 Claude의 설계/감사 결과와 대조한 차이점 목록(있다면). "차이 없음"도 명시적 결론으로 기록한다 — 침묵은 허용되지 않는다(§13.5 Block Criteria와 동일한 정신).

### 13.9 Stage 11C — Conflict Analysis (신규)

Human(정영석님)이 Stage 11A(§13.1-§13.6)와 Stage 11B(§13.8)의 결과를 직접 비교한다.

**원칙**:

- PASS/PASS 일치 자체는 **약한 증거**로 취급한다 — 같은 결론에 도달했다는 사실만으로 안심하지 않는다(§38.4 검증방법 독립성 원칙과 동일한 논리).
- **불일치가 나온 지점을 최우선으로 살핀다.**
- 불일치가 실제 결함인지 판단이 서지 않으면, Cursor/Codex에게 fault-injection 등 실제 재현(라이브 DB 대상)으로 확정을 요청한다 — `canonical_kds_release_orchestration` 워크패킷의 이중 실패 검증 사례가 이 절차의 정확한 선례다.

**출력**: 무엇이 일치했는지, 무엇이 불일치했는지, 불일치 중 어느 것이 실제 재현으로 확정 요청됐는지, 그 재현 결과가 무엇이었는지를 기록한 Conflict Analysis 메모 — Stage 12(§14) Human 병합 결정의 입력 중 하나가 된다.

### 13.10 실무 참고사항 (Stage 11B/11C)

- ChatGPT의 Stage 11B는 반드시 새 대화창에서 진행한다 — 기존에 함께 만들어온 맥락이 있는 대화창을 쓰면 진짜 블라인드가 되지 않는다.
- ChatGPT의 지적은 그 자체로 확정하지 않는다 — 반드시 Cursor/Codex의 실제 재현(라이브 DB 대상)으로 확정한 뒤에만 문서/코드에 반영한다(`canonical_kds_release_orchestration` 워크패킷이 표준 절차 선례).
- 이 원칙은 기존 §13.6(앵커링 방지 규칙)/§38.4(검증방법 독립성 원칙)를 **대체하지 않고 보완한다** — §13.6은 "Claude가 자기 자신의 이전 요약을 신뢰하지 말 것"을, §38.4는 "여러 검증자의 방법이 달라야 진짜 독립"을, §13.7(Dual Anchor)은 그중에서도 특히 "Stage 11의 최종 감사는 반드시 다른 AI 계열이 별도로 재도출해야 한다"는 것을 Stage 11에 한해 의무화한 것이다. 셋 다 함께 적용된다.
- Stage 12(§14, Human Merge And Release Evidence)는 번호/구조가 바뀌지 않는다 — Stage 11A/11B/11C 전체를 근거로 최종 병합 결정을 내리는 것은 여전히 Stage 12의 역할이다.

---

## 14. 12 단계  인간 합병 및 증거 를 공개

### 14.1 역할

인간들은 결말 합병과 방출 결정을 합니다.

**2026-07-18부터**: 이 최종 결정은 Stage 11A(`AuditReview.md`) 단독이 아니라, Stage 11B(§13.8, ChatGPT Blind Audit 결과)와 Stage 11C(§13.9, Conflict Analysis 메모) 전체를 근거로 한다(§13.7 Dual Anchor Principle). Stage 12 자체의 번호/구조는 바뀌지 않는다 — 입력이 늘어난 것뿐이다.

인간 평가는

- 최종 차이점
- `AuditReview.md` (단계 11A)
- ChatGPT의 Stage 11B 블라인드 역설계 결과 및 대조 결과.
- Stage 11C Conflict Analysis 메모 (일치/불일치, 불일치 중 실제 재현으로 확정된 항목과 그 결과).
- `VerificationResult.md`.
- 실패하거나 위험한 명령에 대한 원시 로그
- 남은 위험요소
- 메시지를 보내세요
- 증거들을 풀어주세요.

### 14.2 인간 합병 체크리스트

2026-07-10 현재, 통합 체크리스트는 단일 통합의 내부의 섹션입니다 `ReleaseEvidence.md` (전체 템플릿을 참조 14.4) `human_merge_checklist.md` 파일. 체크리스트 항목:

```markdown
## Human Merge Checklist

- [ ] I reviewed git diff.
- [ ] I confirmed only approved files changed.
- [ ] I reviewed ImplementationModule.md.
- [ ] I reviewed VerificationResult.md.
- [ ] I confirmed raw logs exist for required commands.
- [ ] I reviewed AuditReview.md (Stage 11A).
- [ ] I reviewed MinorOpinion.md, if present (Medium/Full tier), and confirmed its concerns were addressed in AuditReview.md.
- [ ] I reviewed ChatGPT's Stage 11B blind reverse-engineering result (genuinely blind, new chat window confirmed).
- [ ] I reviewed the Stage 11C Conflict Analysis memo and confirmed any disagreement was escalated to Cursor/Codex fault-injection reproduction before being accepted or dismissed.
- [ ] I confirmed no unresolved BLOCK finding exists.
- [ ] I confirmed rollback notes exist.
- [ ] I confirmed commit message is correct.
- [ ] I accept the remaining risk.
```

### 14.3 메시지 형식을 채용

```text
<분야>: <단순 변경 요약>

아이디 변경: <CHANGE_ID>
영향: <금융 영향 클래스>
범위를: <이 영향을 받은 도메인>
검증: PASS
감사: 승인
롤백: < 롤백 요약>
증거: <방해 증거 경로>
```

예를 들어:

```text
지불: 부수적 인 인 인력 취소 전화 통환 처리

변경 아이디: PAYMENT_CANCEL_001
영향: 높은_금융_ 영향
범주: 지불, 공급자_status_mapping, 감사_레저
검증: PASS
감사: 승인
롤백: 리버트 콜백 핸들러 및 마이그레이션 20260618_결제_ 취소_이념
증거: docs/release_evidence/PAYMENT_CANCEL_001/
```

### 14.4 `ReleaseEvidence.md` (융합: 석방 증거 + 인간 합병 체크리스트)

```markdown
# ReleaseEvidence.md

## Change ID

## Release Decision

APPROVED / BLOCKED / DEFERRED

## Commit Hash

## Merge Target

## Verification Reference

## Audit Reference

## Raw Log Reference

## Rollback Reference

## Human Merge Checklist

- [ ] I reviewed git diff.
- [ ] I confirmed only approved files changed.
- [ ] I reviewed ImplementationModule.md.
- [ ] I reviewed VerificationResult.md.
- [ ] I confirmed raw logs exist for required commands.
- [ ] I reviewed AuditReview.md (Stage 11A).
- [ ] I reviewed MinorOpinion.md, if present (Medium/Full tier), and confirmed its concerns were addressed in AuditReview.md.
- [ ] I reviewed ChatGPT's Stage 11B blind reverse-engineering result (genuinely blind, new chat window confirmed).
- [ ] I reviewed the Stage 11C Conflict Analysis memo and confirmed any disagreement was escalated to Cursor/Codex fault-injection reproduction before being accepted or dismissed.
- [ ] I confirmed no unresolved BLOCK finding exists.
- [ ] I confirmed rollback notes exist.
- [ ] I confirmed commit message is correct.
- [ ] I accept the remaining risk.

## Monitoring Watch

## Post-Release Notes
```

### 14.5 이주안 변경가능성 규칙 (2026-07-18)

**배경**: `0027`/`0166` 두 사례에서, migration 체크섬 불변성 안전장치(`tools/apply_migrations.py`의 checksum-mismatch 정지 로직)와 같은 워크패킷 안에서의 반복 정정 작업이 충돌했다. 제미나이는 "이미 `git commit`됐는가"를 단일 기준으로 제시했으나, ChatGPT의 분석이 이를 정확히 반박했다 — `git commit` 여부는 로컬 작업 관행의 문제일 뿐, 이 migration이 실제로 "돌이킬 수 없는 상태"가 됐는지와는 무관하다(예: 로컬에만 커밋하고 아직 아무 데도 push/merge/적용하지 않은 경우, 커밋됐다는 사실 자체는 재작성을 막을 이유가 되지 못한다). 대신 이 문서가 이미 갖고 있는 **Stage 12(Human Merge/Release, §14)** 개념을 그대로 판단 기준으로 재사용한다 — "Human이 병합을 승인했는가"가 실제로 의미 있는 불가역성의 경계다.

**Draft Migration**: 다음 4개 조건을 **전부** 충족하는 동안, 해당 migration 파일은 초안(draft)으로 취급되며 같은 파일을 다시 고칠 수 있다.

1. 해당 워크패킷이 아직 Stage 12(Human Merge/Release)를 통과하지 않았다.
2. 이 migration이 보호된 기준 브랜치(`main` 등)에 아직 없다.
3. 어떤 공유 환경에도 아직 적용된 적이 없다.
4. 다른(이후) 워크패킷이 이 migration의 현재 체크섬/동작에 의존하기 시작하지 않았다.

이 4개 조건을 전부 만족하는 동안 파일을 다시 고칠 수는 있지만, **체크섬만 덮어쓰는 것은 허용되지 않는다** — 반드시 이 migration 적용 이전 상태로 로컬 DB를 되돌린 뒤(또는 전체 재실행) 정정된 파일을 다시 적용해야 한다. 파일 내용과 실제 DB 상태는 항상 일치해야 한다.

**불변 경계 (Migration Immutability Boundary)**: 다음 중 **하나라도** 발생하면 그 즉시, 그 migration 파일은 영구 불변으로 전환된다.

1. 인간 Merge/Release 승인(Stage 12).
2. 보호된 기준 브랜치에 포함됨.
3. 어떤 공유 환경에든 적용됨.
4. 다른 승인된 워크패킷이 이 migration을 의존 대상으로 사용하기 시작함.

**경계 이후 정정 (Post-boundary correction)**: 불변 경계를 넘은 뒤에 발견되는 모든 결함은 반드시 **새로운 forward migration(신규 번호)**으로만 처리한다. 체크섬 수정이나 파일 직접 수정은 어떤 경우에도 허용되지 않는다 — `0027`(`canonical_kds_release_orchestration` 워크패킷 이전에 이미 병합·적용된 파일)에 대해 이 원칙이 실제로 적용된 사례: 결함을 `0027` 자체의 수정이 아니라 신규 `0166` migration으로 처리했다.

**도구 지원은 향후 과제로만 명시 (지금 구현 안 함)**: `tools/apply_migrations.py`가 `--draft`/`--strict` 모드를 구분해 이 규칙을 자동으로 강제하도록 개선하는 것은 별도 워크패킷 후보로 남긴다. 지금은 이 원칙을 사람이 직접 판단하여 수동으로 적용한다 — `0027`은 원본 유지 + `0166` 신설로 처리됐고, `0166` 자신이 이번 정정 라운드들에서 다시 고쳐질 수 있는지(Draft 상태인지 이미 불변 경계를 넘었는지)는 Stage 12 통과 여부에 따라 그때그때 판단 대기 상태로 남아있다 — 이것이 이 규칙의 실제 적용 선례다.

---

## 15. 추천 문서 폴더 구조

각 구현 모듈 (완전 단계, §31; 중간 단계) 에 대해 4개의 파일로 통합합니다.

이 파일들은 영구 PascalCase 이름 (§33 참조) 이다.  이후에는 기록물 이름 변경 단계가 일어나지 않는다. 생성 시 파일의 이름이 프로젝트의 생애에 대한 이름이다.

```text
docs/implementation_evidence/<change_id>/
  00_CursorScan.md               (커서  스테이지 1 원본 스캔, 검증되지 않은, 검색만)
  01_ImpactScope.md              (클로드 코드  2 단계; 통합 범위 + 컨텍스트 스냅샷, verifies/corrects 커서 스캔)
  02_Overview.md                 (클로드 코드 초안, 클로드 검증)
  03_Logic.md                    (클로드 코드 초안, 클로드 검증)
  04_TestPlan.md                 (클로드 코드 초안, 단계 5; 클로드 6단계에서 확인)
  05_ChangeContract.md           (클로드 코드 초안, 단계 5; 클로드-확인 단계 6, 단계 7에서 인적 승인; 합병 계약 + 인적 국경 승인 섹션)
  06_ImplementationModule.md     (코덱스  자기보고서, 완성 증명서가 아닙니다)
  07_VerificationResult.md       (클로드 코드  코덱스 9단계 크로스 모델 재확인, 터미널 / CI)
  raw_logs/
    01_git_diff_stat.txt
    02_git_diff_check.txt
    03_git_diff_name_only.txt
    04_git_diff.patch
    05_lint.log
    06_typecheck.log
    07_test.log
    08_migration_dry_run.log
    09_rls_security_check.log
  08_MinorOpinion.md             (Cursor  단계 9 (비평적 계층) 비결제적 제2의 의견 Medium/Full 계층만)
  09_AuditReview.md              (클로드 ) confirm/audit; 코덱스 모듈 + 클로드 코드의 검증 후 선택적으로 선택되지 않습니다)
  10_ReleaseEvidence.md          (인성  합병 방출 증거 + 인간 합병 체크리스트)
```

더 큰 출시:

```text
docs/release_evidence/<release_id>/
  change_manifest.md
  approval_record.md
  test_result.md
  deployment_log.md
  smoke_test.md
  monitoring_watch.md
  rollback_record.md
  closeout.md
```

### 15.1 기록물 변경 사항이 없습니다 (역사적 참고, 2026-07-10)

이 섹션의 이전 개정에서 이 프로젝트의 `604000_workpackets/` 변경사항이 보관된 폴더 (예를 들어 `604311_Boundary_...md`, `604317_Module_...md`, `604319_Audit_...md`) 이 모든 `600000_implementation_lifecycle/` 밴드, `604000_workpackets/`, 떨어지고 `990000_legacy_quarantine/` 이 프로젝트의 역사에서 ([ 참조]CHANGELOG.md's Deferred/decision-log [공정] 및 000005/000007이 움직임의 지수 역사)

2026년 7월 10일 현재 이 프로젝트는 아카이브의 이름 변경 단계 를 전혀 수행 하지 않습니다.`ImpactScope.md`, `Overview.md`, `Logic.md`, `TestPlan.md`, `ChangeContract.md`, `ImplementationModule.md`, `VerificationResult.md`, `MinorOpinion.md`, `AuditReview.md`, `ReleaseEvidence.md`) 는 프로젝트의 생애에 걸쳐 변경된 산출물들의 영구적 인 이름입니다. working-name/archived-name 다른 명칭을 유지해야 하며, 변경이 " 완료"된 것으로 간주되면 두 번째 명칭 변경이 없습니다.

---

## 16. 모든 시행 시제 를 포함 하는 재정적 수준 규칙 (코덱스, 8 단계)

```text
금융급의 시행규칙:
- 코드 간단하고 명시적으로 유지하세요.
- 광범위한 추상화를 도입하지 마십시오.
- 일반 보조기 내부에서 재정적 전환을 숨기지 마세요.
- 무능성을 유지하라
- 재화 이동을 방지합니다.
- 시간제 및 알려지지 않은 제공자 상태를 보수적으로 처리하십시오.
- 공급자가 알려지지 않은 상태가 실패나 성공이라고 생각하지 마세요.
- 현저한 상태 변경에 대한 감사 리더 이벤트 작성
- 증거 경로를 보존해
- RLS를 존중하고 최소한의 특권을 존중해
- 허용된 목록 밖의 파일을 변경하지 마십시오.
- 한국어 마크다운을 다시 쓰지 마
- 코딩을 정상화하지 마십시오.
- 명시적으로 승인되지 않는 한 포맷을 실행하지 마십시오.
- 더 많은 범위가 필요하다면 멈추고 경계 승인 요청하십시오.
```

---

## 17. 재무적 사고 시나리오 를 시험 해야 한다

### 17.1 지불

- 두 번이나 같은 지불 요청이 있습니다.
- 수급시간이 완료된 후
- 사용자 재시험 후 다시 호출이 도착합니다.
- 복제 전화
- 알려지지 않은 승인을 받은 후 취소 요청
- 공급자는 대기 중이라고 하지만 내부 재실험이 시작됐다고 합니다.
- 고객과 마주치는 UI는 공급자의 결말 전에 결제 결제를 표시합니다.

### 17.2 환불/회환

- 재불금 요청 시간제
- SLA를 넘어 환불이 기다리고 있습니다.
- 이전 환불이 알려지지 않은 상태에서 다시 환불을 시도하십시오.
- 반전 성공했지만 재발은 늦었습니다.
- 고객 메시지는 너무 일찍 완료됐다고 합니다.
- 부분 환불 상태는 완전 환불으로 잘못 해석된다.

### 17.3 합의 / 화해

- 실종된 POS 파일
- 실종 PG/VAN 파일
- 복제 합의 파일
- 수정된 결제 파일
- 통제할 수 있는 완전 불합동
- 해결되지 않은 예외로 거의 시도되었습니다.
- 조정 결과는 감사 사건 없이 과장된다.

### 17.4 지불 / 은행

- 은행 확인은 알려지지 않았습니다.
- 은행 파일 복제
- 은행 상태가 알려지지 않은 후 다시 지불 시도
- 상점 은행 계좌는 지불 전에 변경되었습니다.
- 메이커와 체크커는 같은 배우입니다.
- Rejection/return 지도가 없는 이유
- 두 번이나 같은 배급 배치를 제출했습니다.

### 17.5 감사 / 증거

- 감사 리더 작성 실패
- 증거 패킷 매니프트가 없어졌어요
- 편집 프로필이 없어
- 법적인 깃발을 무시했습니다.
- 허가 없이 특권 수출
- 은 유리창은 취소되지 않았습니다.
- 증거가 있지만 변경 인증과 연관되어 있지 않습니다.
- 감사 리더 이벤트가 없어졌습니다 `CHANGE_ID`.
- 감사 대책 사건은 노후 또는 잘못된 `CHANGE_ID`.
- 증거 패키지가 없어졌어요 `CHANGE_ID`.
- 증거 패킷은 노후화되거나 잘못되었습니다 `CHANGE_ID`.
- `VerificationResult.md` 다른 `CHANGE_ID` 이보다 `ImplementationModule.md`.
- 석방 증거는 승인된 `ChangeContract.md`.

---

## 18. 룰리

파이프라인은 항상 선형이 아닙니다.

### 18.1 1단계 / 2단계로 돌아가는 것

커서 스캔 (단계 1) 또는 클로드 코드 (Claude Code) 로 돌아가십시오 verification/draft (단계 2) 다음의 경우

- 새로운 파일이 발견되었습니다.
- 의존의 범위는 불완전했습니다.
- 테스트 파일은 놓쳐졌습니다.
- RLS/migration 영향이 나타납니다.
- 공급자 인터페이스 의존성 표시
- 관련 문서나 SOP 참조가 놓쳐졌습니다.

만약 그 격차가 커서의 원래 스캔으로 이어지는 경우 (커서가 발견해야 했지만 발견하지 못했던 것) 단계 1로 돌아가면 커서의 스캔이 적당했지만 클로드 코드의 스캔이 verification/draft 뭔가 놓쳤어, 바로 2단계로 돌아가

### 18.2 3단계로 돌아가는 것

클로드 설계 검증으로 돌아갑니다.

- 비즈니스 로직은 틀렸어요
- 금융사건이 놓쳐졌어요
- 미지의 국가 처리 사항은 명확하지 않습니다.
- 롤백은 불가능해요
- Audit/evidence 요구사항의 변경
- 승인 범위가 변경됩니다.
- 마스터 규칙 충돌이 발견됩니다.

### 18.3 인간 승인 7 단계 로 돌아

새로운 사람의 승인에 대한 7단계로 돌아가면

- 허용된 파일 목록은 확장되어야 합니다.
- 금지된 파일은 만져봐야 합니다.
- 금융 영향력급이 증가합니다.
- 새로운 이주가 필요해요.
- 새로운 공급자 의존성이 도입됩니다.
- 긴급 경로가 필요합니다.

### 18.4 8단계로 돌아가는 것

코덱스에 반환하는 경우

- 구현 오류는 승인된 범위 내에서 발견됩니다.
- 테스트 실패는 현지이고 설계는 유효합니다.
- 클로드 오디트는 코드 레벨 문제 해결이 가능한 문제점을 발견했습니다.
- 검증 실패는 코드 오류로 인해 발생합니다.

### 18.5 9단계로 돌아갑니다 (그리고 중요한 단계의 커서 참여, Medium/Full (위)

클로드 코드의 크로스 모델 재확인 (9단계) 에 대한 복귀 (제9단계) `MinorOpinion.md` 새로운 차이점을 포함하지 않습니다.

매뉴얼이나 인공지능 검토는 자동화된 검사를 다시 실행하는 것을 대체할 수 없습니다.

### 18.6 11단계로 돌아가는 것

새로운 검증 실행 후 클로드 감사로 돌아가세요.

이전 감사는 새로운 차이점을 승인하지 않습니다.

코덱스 `ImplementationModule.md`  모든 모듈은 완료된 것으로 간주되기 전에 11 단계에 도달해야 합니다.

---

## 19. 초기 개발 에 있어서 최소한 의 타당 한 번역판

전체 파이프라인이 무거운 경우 이 최소 버전을 사용하십시오. 2026-07-10시 현재 이 중층 (§31) 과 정신적으로 겹쳐서 두 가지 모두 산출물 수를 압축합니다. MVV는 또한 배우 수를 압축합니다 (클로드 코드만, Cursor/Codex) 과 초창기 개발, 비금융적 수준의 작업에 대한 가벼운 부근 옵션으로 취급되어야 합니다.

```text
1. Claude Code: 영향 파일 찾기 + Overview.md / Logic.md 초안
2. Claude: context_snapshot 확인 + overview/logic 검증 + TestPlan.md + ChangeContract.md (허가된 파일)
3. Claude Code: approved files only 구현 + ImplementationModule.md
4. Terminal/Claude 코드: git diff --check / flutter 분석 / Dart 테스트 + 원시 로그
5. 클로드: 원자재 로그 + git diff + 모듈 + 테스트 결과 감리 (confirm/audit)
6. Human: final diff 확인 후 commit
```

MVV는 저 위험, 비금융, 허가, 비계획, 비 제공자, 비공개 변경 사항에만 해당한다.

다음의 어느 하나에 해당하는 경우 MVV는 금지됩니다:

- 지불, 취소, 환불, 환불, 지불, 결제, 조화, 제공자 호출, POS 호출, PG/VAN, 은행, 대책, 감사, 증거, 또는 customer/store 최종 논리에는 영향을 미칩니다.
- 수파베이스 RLS, 데이터베이스 정책, 데이터베이스 제한, 데이터베이스 마이그레이션, 기능, 트리거, 저장 정책 또는 서비스 역할 경계가 만져집니다.
- 접근 제어, 역할 허가, staff/admin/store 소유자의 허락, 임차인 격리, 또는 유리 찢어지는 행동에 영향을 미칩니다.
- 공공 API, 공급업체의 API, 라이트 계약, 웹허크 계약 또는 외부 통합 행동에 영향을 미칩니다.
- 생성된 코드, 잠금 파일, 빌드 구성, 배포 구성 또는 CI 구성에 영향을 미칩니다.
- 이 변화는 생산 방출, 반전, 모니터링, 경고, 증거 보존 또는 법적 보유에 영향을 미칠 수 있습니다.

지불, 지불, 결제, 공급자, 감사, 증거, RLS, 액세스 제어, 데이터베이스 마이그레이션 또는 생산 출시 변경에 대한 전체 버전을 사용하십시오.

---

## 20. 매일 운영 체크리스트

```markdown
# daily_ai_development_loop_checklist.md

## Before Design

- [ ] Cursor produced the raw scope/inventory scan without editing files or drafting (Stage 1).
- [ ] Claude Code verified Cursor's scan and produced ImpactScope.md (Stage 2).
- [ ] Claude Code produced Overview.md draft.
- [ ] Claude Code produced Logic.md draft.
- [ ] Context snapshot includes master anchor, required rule summaries, relevant domain references, and explicit exclusions.

## Before Implementation

- [ ] Claude reviewed Overview.md and Logic.md and set the Critical/Normal tier (Stage 3, Draft Status = Verified).
- [ ] Architecture Verification (Stage 4) completed and integrated by Claude.
- [ ] Claude Code produced TestPlan.md and draft ChangeContract.md (Stage 5).
- [ ] Contract Verification (Stage 6) completed and integrated by Claude.
- [ ] Human reviewed the full design pack (ImpactScope/Overview/Logic/TestPlan/ChangeContract) in Stage 7.
- [ ] Human approved allowed files and allowed operations.
- [ ] ChangeContract.md's Human Boundary Approval section is filled in.

## During Implementation

- [ ] Codex edited only allowed files.
- [ ] Codex kept diff small.
- [ ] Codex avoided broad refactor.
- [ ] Codex created ImplementationModule.md (self-report — not treated as complete on its own).

## Verification

- [ ] git diff --stat captured.
- [ ] git diff --check captured.
- [ ] git diff --name-only captured.
- [ ] git diff captured.
- [ ] lint/typecheck/test commands run.
- [ ] migration/RLS/security checks run where applicable.
- [ ] raw logs preserved.
- [ ] VerificationResult.md written by Claude Code (Stage 9 cross-model re-verification of Codex's implementation).
- [ ] (Critical tier) MinorOpinion.md written by Cursor within Stage 9, including an explicit "no concerns found" statement if applicable.

## Documentation

- [ ] Codex produced/updated Module.md and NavigationMap.md/index registration (Stage 10).
- [ ] Claude Code produced Verification.md and a draft Audit.md (Stage 10).

## Audit And Merge

- [ ] Claude reviewed ImplementationModule.md.
- [ ] Claude reviewed VerificationResult.md.
- [ ] Claude reviewed MinorOpinion.md (Medium/Full tier) and explicitly addressed every concern raised.
- [ ] Claude reviewed raw logs.
- [ ] Claude reviewed git diff.
- [ ] AuditReview.md produced APPROVE or APPROVE_WITH_NOTES.
- [ ] Human reviewed final diff.
- [ ] Human confirmed no BLOCK remains.
- [ ] Release evidence created.
```

---

## 21. 한 페이지 간 운영 요약

**(2026-07-16 개정)** As of 2026-07-16, this is a thirteen-stage (0-12) summary for Medium/Full 레벨 변경 (§3, §31) 는 이 요약의 8 단계 버전을 대체합니다. 라이트웨이트 트랙 (§24) 은 이 모든 것을 건너뛰고 로그만 유지됩니다.

```text
[0] 문제 발견 / 사실 스캔 (정규적이지 않은)
    출력: 발행 기록 (선택)
    규칙: 정규 주기가 시작되기 전에 누구나 발견을 기록할 수 있습니다. 검증도 없고, 게이트도 없습니다.

[1] 스캔 (거미, + 항 중력 참조)
    출력: 원료 scope/inventory 보고 (검색만)
    규칙: 검색 및 보고만 합니다. 설계도 작성하지 마십시오. 실행 코드를 작성하지 마십시오. approval/block 권위

[2] 설계안 (클로드 코드)
    출력: Overview.md (안안) Logic.md (안안)
    규칙: 커서 스캔을 독립적으로 확인하고 신뢰하기 전에. 설계 설계. 실행 코드를 절대 작성하지 마십시오. 결정되지 않은 설계 포인트를 클로드에게 공개 질문으로 표시하십시오.

[3] 클로드 퍼스트 패스 리뷰 + Critical/Normal 계층 결정
    출력: 검토 의견 + 계층 판결
    규칙: 클로드 리뷰 Overview.md/Logic.md 직접적으로 4단계 검증자가 얼마나 필요한지 결정합니다.

[4] 건축 검증 (Codex + Antigravity, 또는 Cursor + Codex + Antigravity క్రి트릭 레벨에서 클로드 통합)
    출력: 건축 검토 (융합 검증 결과)
    규칙: 계약서를 작성하기 전에 설계안이 기본 규칙과 repo 상태에 맞게 확인한다.

[5] 계약안정 (클로드 코드)
    출력: TestPlan.md, 초안 ChangeContract.md
    규칙: 검증된 디자인에서 허용된 파일 경계를 작성합니다.

[6] 계약 검증 (Codex + Antigravity, 또는 Cursor + Codex + Antigravity, Critical Tier; Claude를 통합하고, §37는 Claude Code를 계약의 자체 작성자로 배제하고)
    출력: 확인 TestPlan.md/ChangeContract.md

[7] 사람의 승인 게이트
    출력: ChangeContract.md (인간의 국경 승인 섹션이 작성되었습니다)
    규칙: 전체 디자인 패키지를 읽어 보세요. 파일 및 동작을 잠금 할 수 있습니다. 코덱스는 이 없이 시작될 수 없습니다.

[8] 시행 (코덱스)
    출력: 코드 차이 ImplementationModule.md
    규칙: 승인된 파일만 편집하고, 엄격히 ChangeContract.md자제보고서, 완성된 증거가 아니라 자제 승인 권한이 없습니다.

[9] 독립 검증 (클로드 코드 + 항 중력 또는 클로드 코드 + 커서 + 항 중력 비중적 수준에서 클로드; 클로드 통합; § 37는 코덱스를 구현의 자체 저자로 배제합니다)
    출력: VerificationResult.md, 원시 로그, git diff (+ MinorOpinion.md 커서가 비평적 계층에 참여하는 경우)
    규칙: 코덱스 구현의 크로스 모델 확인, 자진 확인이 아닙니다. 명령어를 실행하세요. 수정하지 마십시오. 오류를 숨기지 마십시오. 깨끗한 패스는 여전히 기록되어야 합니다. 침묵하지 않습니다.

[10] 문서 (코덱스: 간단한 문서; 클로드 코드: 중요한 문서)
    출력: Module.md, NavigationMap.md/index 업데이트 (코덱스) Verification.md, 초안 Audit.md (클로드 코드)
    규칙: 실행은 추적 가능한 문서 추적 없이 최종 감사에 도달하지 않습니다.

[11] 최종 감사 (Claude, 혼자)
    출력: AuditReview.md (ACCEPT / APPROVE_WITH_NOTES / BLOCK)
    규칙: 원시 로그를 직접 검토하고 그 차이를 확인합니다. 실행이 잘못되었다고 가정합니다. MinorOpinion.md 8단계 후 절대 이 일을 놓치지 마세요 ACCEPT/REJECT 권위는 클로드에게만 달려 있습니다.

[12] 인간 합병/방해
    출력: 약속 ReleaseEvidence.md (선택)
    규칙: 인간에게 최종 위험은 있습니다.
```

---

## 22. 권위 있는 통치 위치

이 문서는 비례적인 가이드로서가 아니라 최고 수준의 시스템 SOP 후보로 취급되어야 합니다.

추천된 위치:

```text
repository_root/
  소프
    시스템/
      000701_Guide_Controlled_AI_Development_Pipeline.md
```

설계 지배 검토 중인 동안 대체 배치:

```text
repository_root/
  문서를 /
    000700_ai_agent_prelearning_and_project_context/
      000701_Guide_Controlled_AI_Development_Pipeline.md
```

(현재 위치 `600000_implementation_lifecycle/` 이 섹션의 이전 개정에서 여기에 이름을 올린 밴드는 `990000_legacy_quarantine/` 2026-07-10  참조 §15.1  따라서 더 이상 유효한 대체 배치가 아닙니다.)

배치 규칙:

- 이 문서가 조언적이라면, `docs/000700_ai_agent_prelearning_and_project_context/`.
- 서류가 필수적이라면 `sop/system/`.
- SOP로 이동하면 구현 라이프사이클 문서 및 루트 인덱스에서 크로스 링크를 추가하십시오.
- 활성 개발 헌법으로 채택되면 루트 마스터 지수와 모든 구현 라이프사이클 지수에서 참조하십시오.

소유자 입양 규칙:

```text
실제 금융, POS, 공급자, RLS, 마이그레이션, 감사 또는 출시 구현이 시작되면 이 파일을 선택적으로 취급하지 마십시오.

이러한 도메인들에 대해서는, 이 가이드는 엄격한 SOP가 이를 대체하지 않는 한 제어 SOP입니다.
```

---

## 23. 최종 통치 선언

이 가이드는 AI가 지원하는 개발을 무분별하게 만들지 않고 빠르게 만들기 위해 존재합니다.

프로젝트가 빠르게 진행될 수 있는 것은 각 변경 사항이 다음으로 표시된 경우에만:

1. 경계 발견 (커서 스캔, 클로드 코드 검증)
2. 컨텍스트 스냅샷 다이어트와 도메인 슬라이딩
3. 인간 승인된 계약
4. 코덱스 시행을 좁히기
5. 원자력기술 검증 (클로드 코드 크로스 모델 검증, 커서 (Cursor) 의 비결제적 두 번째 의견 Medium/Full (제1급)
6. 클로드 독립 감사
7. 인간 소유.

운영 약속은 다음과 같습니다.

```text
실수도 일어날 수 있습니다.
하지만 승인된 모듈 경계 안에 갇혀 있어야 합니다.
원조의 로그에서 볼 수 있는
추적가능한 CHANGE_ID,
썰어진 컨텍스트 스냅샷으로 집중되는
그리고 재무적 정확성을 위협할 때 합병하기 전에 차단됩니다.
```

이것은 개발 헌법입니다 `yoonsul_wait_order_handoff` 보다 엄격한 SOP 또는 정책으로 대체될 때까지.

## 24. 가벼운 검증-충돌 수정 트랙

2026-07-10까지 변경되지 않은 Cursor/Codex 다시 도입 (§1 및 §2-3 근처의 통지 참조). 이 트랙은 여전히 클로드 코드만이며, 여전히 커서 스캔 또는 코덱스의 구현이 필요하지 않습니다.

이 트랙은 다음 모든 것이 유지되는 경우에만 적용됩니다:

1. 이 작업은 인간 승인 과정에서 발견된 기존, 아직 적용되지 않은 파일의 수정입니다 verification/audit 이미 진행 중인 패스 (예를 들어 실제 결함을 찾기 위해 순차적으로 마이그레이션을 실행하는 것)
2. 수정은 새로운 파일, 새로운 테이블, 새로운 마이그레이션 번호, 새로운 권한 또는 단일 파일 수정 이외의 변경 사항을 도입하지 않습니다 (파일 범위에 따라 기존의 "다른 파일이 필요하다면 중지하십시오" 규칙과 동일합니다. 이 트랙은 해당 규칙을 포기하지 않으며 범위에 있는 수정 사항에 대한 공식적인 문헌 요구 사항만 포기합니다).
3. 수정은 다음과 같은 것 중 하나입니다: 문법 수정, 구석기 참조 수정 (제정된 "어떤 쪽이 부담을 부담하는 것" 표준에 따라 repo 전체 grep 증거에 의해 뒷받침됩니다) 또는 application-layer/environment-detection 0034 DB-명보호 수정과 같은 수정
4. 인간 소유자는 현재 검증 승인을 위해 이 트랙에 진입하는 것을 명시적으로 허가했다 (하나의 승인은 전체 승인을 포함하고, 각 파일마다 한 권이 아닙니다).

이 트랙 아래:

- 클로드 코드는 ImpactScope.md/Overview.md/Logic.md/TestPlan.md/ChangeContract.md 각 개별 고정
- 클로드 코드는 여전히 실행 테이블의 모든 수정 사항을 기록해야 합니다: 파일, 발행, 수정 적용, 검증 결과
- 클로드 코드는 1~7 단계 과정 (공식 산출물 + 독립적인 인 사람의 승인) 을 완료하고,
  - 수정은 새로운 비즈니스 로직 추론을 요구합니다 (역학적 수정이 아닙니다),
  - 두 가지 타당된 수정 사항은 명확한 증거가 없는 의미있는 다른 타협을 가지고 있습니다.
  - 새로운 전격 file/migration/table/permission 필요하고,
  - 파일은 결제, 보안 격리, RLS 또는 금융 결제 논리와 관련된 것이 아닙니다. 그리고 수정은 순수한 문법 수정이 아닙니다 (즉, 금융 수준의 논리에 대한 의미적 변경은 항상 완전한 프로세스를 필요로합니다. 예외는 없습니다).
- 클로드의 11단계 독립 감사는 여전히 후시효로 적용됩니다. staging/commit 클로드는 전체 배트의 실행 로그를 검토하고 실제 파일의 차이와 실시간 DB 상태에 대한 샘플을 확인합니다. 다른 단계 11 감사와 마찬가지로

이 트랙은 이미 승인된, 이미 확장된 검증 승인을 제외한 새로운 기능, 새로운 스케마 또는 작업에 적용되지 않습니다.

## 25. 실체 확인 요구 (기본과 시스템 간격)

11단계 감사가 표시되지 않습니다 ACCEPT/PASS 문서의 십자 참조에만 기초하여 그 참조들이 얼마나 내부적으로 일관적이거나 정확하게 인용되었는지 상관없이. 실행 시태에 관한 트랙을 닫는 모든 감사 (데이터베이스 스키마, 배포된 함수, 실행 서비스, 외부 API) 는 실제 실시간 목표에 대한 적어도 한 번의 직접적이고 재생 가능한 검사를 포함해야 합니다. build/compile  단순히 이전 문서의 주장을 검토하는 것이 아닙니다.

전례: A4 0065 문서 트랙 (604520-604524) 은 내부적으로 완벽했다  각 인용 된 라인 번호와 카운트는 독립적인 재 추리에서 정확히 일치했다  그러나 기본 데이터베이스에는 주장 된 객체 중 0이있었습니다. 그 체인의 어느 단계도 실제 데이터베이스에 대한 문의가 없었기 때문에. 문서 체인은 결함이 없으며 여전히 존재하지 않는 시스템을 설명 할 수 있습니다. "PASS"실현지 확인 시간표와 명령 로그 없이 실행시간에 영향을 미치는 변경 사항에 대한 11단계 판례가 유효하지 않습니다.

## 26. 반대의적 인 감사 자격증 요구

11 단계의 감사가 금융적 수준, 보안 또는 임차별 격리 영향으로 경로를 닫는 경우 적어도 한 감사 승인이 명시적으로 적대적 인 것이어야 합니다.  비슷한 훈련과 자극 패턴을 공유하는 모델들은 블라인드 스팟을 공유하는 경향이 있으며, 유사한 패스 사이의 반복적인 합의는 독립적인 검증이 아닌 상관성 있는 실패 위험의 증거입니다.

이 프로젝트는 이미 독립된 패스들 사이의 의견 충돌에서 실제 가치를 관찰했습니다 (예를 들어 021632-021642 catalog/policy 분할 판결, 070390 Audit/Closeout/Index  진정한 분열은 하나의 확정 패스가 놓칠 수 없었던 실제 모호함을 드러냈다. 적대적 프레임링은 의도적으로 사용되어야 하며, 서로 다른 이 된 패스 사이의 우연한 불일치로 남겨지지 않아야 한다.

## 27. 절차적 검사가 자동화 됩니다. Human/AI 실질적 인 검증 을 위한 시간

순전히 기계적인 검사 (H1 일치 파일 이름, 6 자릿수 사전 표시, 금지 행동 목록, 허용 범위 안에 있는 파일) 는 가능한 한 스크립트 된 리팅으로 시행되어야 하며, AI 검토 시간으로 적용되지 않습니다. AI 검토 시간 (클로드의 단계) 3/4/6/11 클로드 코드의 단계 1/8/9 논리 (logic) 는 실제로 주장하는 것을 수행하고, run/compile/apply, 수정하면 실제로 결함을 해결할 수 있을까요?

검토 여부는 대부분의 내용을 절차적 준수에 소비하고 그 기반 시스템이 실제로 작동하는지 여부에 거의 또는 전혀 소비하지 않는다면, 그것은 검토가 잘못된 종류의 가치로 유도된 신호입니다.

## 28. 문서 는 시험 을 지배 한다. 그 는 그 들 의 대체 가 아니다

실행 시간에 영향을 미치는 모든 변경 사항 (SQL, RPC, 응용 논리) 에 대해서는 Overview/Logic/Module/TestPlan 체인은 참조하고, 실제적인 경우 실제 자동화된 테스트 또는 재생 가능한 검증 스크립트를 실행해야 합니다 (예를 들어, 프로젝트의 자신의 `tools/apply_migrations.py` 시험 의 의도를 프로라에서만 설명하기 보다는 `TestPlan.md` 실제 시스템에 대해 실제로 실행된 적이 없는 것은 실행되지 않은 청구보다 더 큰 증거 무게를 가지고 있지 않습니다.

자동화 없는 곳 test/verification 도구가 아직 주어진 영역에 대해 존재하고 있기 때문에 도구는 동일한 영역에 대한 추가 설명 문서를 만드는 것보다 유효하고 종종 더 높은 우선 순위 1-8 단계로 전달됩니다.

## 29. 가벼운 결정 로그 (시션 레벨 ADR)

대화에서 결정된 중요한 통치 또는 범위 결정 (예를 들어 "종합 번호 대역을 제거하고 재건", "툴 권한 구조를 변경", "현실 확인 없이 트랙을 받아들이십시오, 왜냐하면 X") 은 짧은, 추가만 결정 로그 항목에 기록되어야 합니다.

전례: 이 세션의 자체 "600000 밴드 전체를 떨어뜨리십시오" 결정은 채팅 역사에서만 존재했습니다. 여러 개의 별도의 클로드 코드 세션은 나중에 기록이 없었고 처음부터 다시 정리되어야 했으며, 검증 시간을 낭비하고 침묵으로 다시 소송되거나 결코 수신하지 않은 세션에 의해 반대의 위험이 발생했습니다.

이 로그의 형식과 위치는 의도적으로 나중에 별도의 통치 결정에 남겨집니다. 이 섹션에서는 이러한 결정이 영구적인 곳에서 기록되어야만 하고, 전체 산출물 사슬을 직접 통과해야한다는 것을 정합니다.

## 30. 모듈별 변경 역사 ( 단일 파일, 첨부-만): `ChangeHistory.md`

모든 module/component/domain (SQL 스키마 도메인, 플러터 기능 모듈, 관리된 문서 팩) 는 정확히 1 개의 실행 역사 로그를 유지해야 합니다 `ChangeHistory.md`, 시간이 지남에 따라  변경에 따라 새로운 파일은 없습니다 (이 사건에 따라 한 문서의 605900 패턴은이 경우 명시적으로 금지되어 있으며, 이 파이프 라인의 다른 곳과 같은 추론입니다).

형식 (하나) row/entry 변경 사항: 날짜 변경 사항 설명 reason/evidence        audit/test.

이전에 실패하거나 수정된 모듈을 수정하기 전에, 클로드 Code/Claude 먼저 그 모듈의 `ChangeHistory.md` 이 프로젝트는 반드시 해야 하며 선택적으로 하지 않습니다.  로그는 구체적으로 존재하기 때문에, 향후 세션 (이 프로젝트에서 반복적으로 보여준 바와 같이 이전 세션의 기억이 없는) 는 이미 시도된 실패한 접근 방식을 반복하거나 결정된 결정을 재고하지 않습니다.

11단계 (클로드 감사) 는 해당 모듈의 `ChangeHistory.md` 이 경우 ACCEPT 이 모든 변화의 일부분은 감사의 종료이며 별도의 임무가 아닙니다.

SQL: `catchmenu_meta.migration_history` (이 세션에 이미 구축된 DB 테이블) 는 데이터 레벨의 역사입니다.`sql/migrations/CHANGELOG.md`, 하나의 실행 파일) 는 각 수정 (왜, 단지 무엇을)  DB 테이블의 답변은 "X가 적용되었는가", 글로그는 "X가 필요했을 이유는"에 대한 답변을 기록합니다. `sql/migrations/CHANGELOG.md` 이 법은 `ChangeHistory.md` 이름의 협약: 산업 표준의 작은 글자를 유지합니다 `CHANGELOG.md` 이 협약은 프로젝트 자체의 지배 체제 이외의 도구와 기여자들에 의해 널리 인정되기 때문입니다.

## 31. 산출물 중량 층

11개의 예술품의 전체 연쇄 (`CursorScan.md` 통행 `ReleaseEvidence.md`, § 15), 전체 계층에만 적용된다. 두 가지 가벼운 계층이 있다:

- **하단급*: §24의 기존 규칙 (호기만, 공식적인 산출물도 없다).
- **중층*: 신형 features/moderate 변경 사항은 financial-grade/security/RLS/payment-affecting. 11개 대신 4개의 통합 파일을 생성합니다.
  - `DesignPack.md` = ImpactScope (범위 + 컨텍스트 스냅샷) + 개요 + 논리 섹션이 하나의 문서로 결합
  - `TestAndContract.md` = 테스트플랜 + 변경 계약 섹션 합쳐
  - `ImplementationAndVerification.md` = 구현 모듈 + 검증 결과 섹션이 결합
  - `AuditAndRelease.md` = AuditReview + 인적 국경 승인 기록 + 발매증명 섹션 합쳐

  모든 요구 사항 CHANGE_ID 추적성 및 단계 게이트 규칙 (6.11, 단계 7 승인을, 단계 11 독립 감사) 는 여전히 완전히 적용됩니다
- **완전 계층** (현재 11 파일 체인, §15: `CursorScan` 통행 `ReleaseEvidence`): 지불, 보안 격리, RLS, 금융 결제, 또는 크로스 임차인 논리와 관련된 변경 사항에 대해 예외 없이 의무적으로  §24의 승화 기준과 동일한 비 협상 가능한 목록.

인간 소유자 또는 클로드 (단계 3) 는 변경에 따라 `DesignPack.md` / `Overview.md`헤더가

## 32. 도메인 내비게이션맵 요구사항

모든 통치자가 domain/module (SQL 스키마 도메인, 플러터 기능 모듈, 이 파이프라인에 해당하는 모든 폴더) `NavigationMap.md`  하나의 구조화된 지표, 서사지 로그가 아닙니다 (그것이 `ChangeHistory.md`형식: 변경 사항에 한 줄, 기둥: ID 변경 날짜lightweight/medium/fullopen/approved/implemented/verified/audited/released                                                                                                                                                                                               

`NavigationMap.md` "이 영역에서 어떤 변화가 있고 어떤 상태가 있는 것"에 대해 한눈에 대답합니다. `ChangeHistory.md` "왜 각 변경이 이루어졌는가"에 대한 답변이 있습니다.

`NavigationMap.md` 7단계 (고용) 및 12단계 (고용) 에서 최소  신규 행이 승인 시, 상태 업데이트 시 업데이트되어야 합니다.

## 33. 파이프라인 산출물 파일 이름 협약 (파스칼사건과 합쳐)

2026-07-10 현재, 이 가이드에서 정의된 파이프라인 생성 산출물들은 모두 파스칼케이스에 연결된 파일 이름을 사용하며 밑그림과 6자리 사전이 없습니다. `ImpactScope.md`, `Overview.md`, `Logic.md`, `TestPlan.md`, `ChangeContract.md`, `ImplementationModule.md`, `VerificationResult.md`, `MinorOpinion.md`, `AuditReview.md`, `ReleaseEvidence.md`, `ChangeHistory.md`, `NavigationMap.md`, `CursorScan.md`, 그리고 중소 계층 통합 파일 `DesignPack.md`, `TestAndContract.md`, `ImplementationAndVerification.md`, `AuditAndRelease.md`. 각 도메인 규칙의 요약 속임수 표 (§6.3, §6.8) 는 동일한 협정을 따르고 있습니다: `<Domain>RulesSummary.md`.

이 프로젝트는 이미 이 프로젝트에서 사용되고 있는 다른 두 개의 이름 시스템과 구별되는 협약이며, 그 어느 것도 대체하지 않습니다.

- ** 프로젝트 문서**`docs/` 관리 된 내용) 이 프로젝트의 자신의 6자리 `Title_Case_With_Underscores` 협약 `000002_Naming_Rules.md`  이 섹션에 영향을 받지 않습니다.
- **`sql/migrations/CHANGELOG.md`** 의도적으로 명시적으로 언급된 예외 (§30) `CHANGELOG.md` 명칭이 아닌 `ChangeHistory.md`, 그 이름은 프로젝트의 지배 체제 밖의 도구와 기여자들에 의해 인식되기 때문입니다.

- 아니 working-name/archived-name 구별 및 나중에 변경 단계 수행되지 않습니다 (§15.1)  PascalCase 산출물 이름 1/2 변경이 활발하거나 오래 전에 공개되었는지에 관계없이 변경이 참조되는 기간 동안 생성합니다.

**(2026-07-11 개정, 2026-07-16 번호 정합화)** Stage 12 머지 승인 완료 후에는 예외적으로 `000001` §5.4.2의 영구 archive 절차가 적용되어, 통합 작업 파일로 쓰였던 산출물이 개별 승인 DocumentType 단위로 6자리 번호 문서로 이전된다. 위 문단이 말하는 "permanent from creation"은 Stage 1-11 진행 중 단계에서의 파일명 불변성을 의미하며, Stage 12 이후 영구 보관 이전 자체를 금지하지 않는다. 상세 절차는 `000001` §5.4.2 참고.

## 34. 배우 선발 규칙 (Cost/Capability-Based, 2026-07-11)

기존 §3(2026-07-16부터 13단계(0-12) 파이프라인, Stage별 소유자)과 별개로, 실무적으로 어느 도구에 어떤 작업을 맡길지에 대한 원칙:

### 34.1 Cursor — 대용량/전수 스캔

- 대용량 파일 전수 검사, 디렉토리 트리 전체 스캔, 광범위 grep에 적합.
- **제약**: 한글 파일을 처리하는 과정에서 인코딩을 자주 깨뜨리는 경향이 확인됨 (2026-07-11, 900160~179 계열 파일에서 실제 손상 사례 발견). 한글 본문이 포함된 파일의 내용을 다루는 작업에는 Cursor를 신뢰하지 말고, 인코딩 검증은 별도로 거칠 것.
- 000001 §1("Cursor must not edit Korean body text")과 일치하는 방향 — 이번 발견이 그 규칙의 실제 근거 사례가 됨.

### 34.2 Codex — 간단한 수정/검증, 비용 절감

- 단순 반복 검증(인코딩 체크, 컬럼 존재 확인, 체크섬 계산 등), 소규모 in-place 수정(§24 Lightweight Track 등)에 우선 활용.
- Claude Code보다 비용이 저렴하고 이런 작업엔 충분한 정확도.

### 34.3 Claude Code — 검증/크리티컬 작업

- 규칙 준수가 중요한 작업(ChangeContract 준수, 저자 분리 원칙, Stage 2/5 설계·계약 산출물 작성), 감사·재검증 성격의 작업에 사용.
- Codex보다 느리고 비싸지만 규칙을 정확히 따르는 경향이 더 강함 — 크리티컬 경로에는 이 특성이 더 중요.

### 34.4 선택 기준 요약

| 작업 성격 | 우선 도구 |
|---|---|
| 대용량 파일/트리 전체 스캔 (한글 없음 또는 스캔만) | 가속 |
| 한글 본문이 있는 파일의 내용 검증/처리 | Cursor 지양, Codex 또는 Claude Code |
| 단순/반복 검증, 소규모 §24 수정 | 코덱스 |
| ChangeContract 준수 구현, 규칙 정확성이 중요한 작업 | 클로드 코드 |
| 설계/감사/최종 판단 | 클로드 (무대) 3/4/6/11) |

## 35. 종목 간 검증 확충 규칙 (2026-07-11)

배경: 600210 워크패킷(Flutter 게스트 customer_id 연동)에서, Codex가 구현(Stage 8)하고 Claude Code가 검증(Stage 9)했으나, 이후 Cursor에게 독립 재검증을 별도로 시켰더니 Claude Code/Codex 둘 다 놓친 발견(하드코딩된 tenant_id/store_id가 실제 테스트 값과 동일함)이 나왔다. 이는 §3의 8단계 파이프라인이 "각 Stage를 서로 다른 행위자가 맡는다"는 원칙을 지켰음에도, 정작 최종 검증은 여전히 "구현자(Codex)를 검증한 그 한 명(Claude Code)"에게만 의존했기 때문이다 — 검증자가 1명이면 그 1명의 사각지대는 그대로 남는다.

### 35.1 원칙

Medium tier 이상(§31)의 구현이 완료되면, Stage 9(Claude Code 검증) 이후 **구현에 관여하지 않은 제3의 행위자(Cursor 우선, Cursor가 부적합하면 Codex)**에게 Eyes-Only 독립 재검증을 최소 1회 추가로 받는다. 이는 Stage 9의 Critical-tier Cursor 세컨오피니언 조항(§12.9)와 별개로, Medium tier에도 적용되는 경량 버전이다.

### 35.2 절차

1. Stage 11(Claude 감사) 이전 또는 병행하여, Cursor에게 다음을 Eyes-Only로 지시한다:
   - 구현 파일 전체를 처음부터 직접 읽을 것 (이전 Stage 보고를 신뢰하지 말 것)
   - ChangeContract의 Allowed/Forbidden 파일 준수 여부 재확인
   - 설계 문서(Overview/Logic)와 실제 코드의 일치 여부 재확인
   - 하드코딩된 값, 에러 핸들링 누락, 그 외 설계 문서에 없는 임의 판단이 섞였는지 전수 스캔
2. Cursor는 판단/권고를 최소화하고 Open Question으로만 보고한다 (기존 Stage 1 원칙 그대로 적용).
3. 새로운 발견이 나오면 Human이 처리 방침(즉시 수정 vs Known Limitation 문서화 vs 후속 워크패킷)을 결정한다 — Claude나 Cursor가 스스로 결정하지 않는다.

### 35.3 이 규칙이 적용되지 않는 경우

- Lightweight tier(§24) 성격의 단순 fix에는 적용하지 않는다 (과도한 오버헤드).
- Low tier(§31) 문서 전용 변경에는 적용하지 않는다.

### 35.4 근거

이 규칙은 검증자 다양성(actor diversity)이 실제로 결함을 잡아낸 사례(600210, 2026-07-11)에 기반한다. 동일한 자료를 같은 방식으로 한 번 더 보는 것(§26이 이미 경고한 "반복 확인은 검증이 아니다")과, 전혀 다른 관점/도구로 처음부터 다시 보는 것은 다르다 — 후자만이 새로운 발견을 낳는다.

## 36. 설계-실제 이중 간판 검증 루프 (2026-07-11)

배경: 600410(KDS capacity gate) 워크패킷에서, Claude Code가 작성한 Overview/Logic/TestPlan/ChangeContract를 Human Approval 직전에 Cursor에게 독립 재검증시켰더니, 큰 그림(설계 방향)은 맞았지만 세부 사실 3건이 실제 코드와 어긋나 있었다(0098이 실제로는 is_overloaded를 안 쓴다는 것, zone 목록 로직이 "기존 패턴 재사용"이 아니라 "두 패턴의 새 조합"이었다는 것, 문서 간 아키텍처 불일치). 이는 §35(Cross-Actor Verification Expansion Rule, 구현 후 재검증)를 설계 단계에도 확장해야 함을 보여준다 — 설계 문서 자체도 액면 그대로 신뢰하면 안 되고, 구현에 들어가기 전에 이미 한 번 걸러야 한다.

### 36.1 원칙

Medium tier 이상(§31)에서, Stage 3-6(Claude 설계 검증 + Architecture/Contract Verification) 완료 후 Stage 7(Human Approval) 이전에 Cursor에게 설계 문서(Overview/Logic/TestPlan/ChangeContract) 독립 재검증을 최소 1회 거친다. 이는 §35(구현 후 재검증)와 별개로 설계 단계에 적용되는 사전 버전이다. (2026-07-16 갱신: 이 사전 재검증은 이제 신규 Stage 4/Stage 6의 Critical-tier Cursor 참여로 공식 흡수되었다 — 아래 36.2 절차는 그 이전 관행을 그대로 기록하며, 현재는 §3의 Stage 4/6 구성으로 대체 적용된다.)

### 36.2 전체 루프 (Medium tier 이상 표준 절차로 확정)

**(2026-07-16 시점 기준: 이 목록은 §36 확정 당시의 옛 8단계 표기로 남긴 역사적 기록이다. 아래 각 항목이 현재 §3의 몇 단계에 해당하는지 괄호로 병기한다.)**

1. 단계 2 (클로드 코드): Overview/Logic 작성 — 현재도 Stage 2
2. 2단계: TestPlan/ChangeContract 작성 및 검증 — 현재는 Stage 5(Claude Code가 초안 작성) + Stage 3/4(Claude 검토·통합)
3. **[신설] Cursor 설계 재검증**: 위 산출물 전체를 원문 대조로 재확인. 불일치 발견 시 Claude Code가 정정 → **필요시 1~2회 반복(티키타카)** → 문서 간 완전 정합 확인될 때까지 — 현재는 Stage 4/6의 Critical-tier Cursor 참여로 흡수
4. Stage 7(Human): 정합화 완료된 최종본에 승인 — 현재도 Stage 7
5. Stage 8(Codex): 구현 — 현재도 Stage 8
6. **[신설] 이중 재검증**: Stage 9(Claude Code) 검증 + 별도 Cursor 독립 재검증(§35 원칙) — 구현 결과도 마찬가지로 한 명의 검증자에만 의존하지 않는다 — 현재는 Stage 9의 Critical-tier 구성(Claude Code + Cursor)으로 흡수
7. Stage 11(Claude): 최종 감사 — 현재도 Stage 11

### 36.3 절차 세부

- Cursor의 설계 재검증은 Eyes-Only 원칙 그대로: 판단/설계 변경 금지, 원문 인용 기반 사실 대조 및 Open Question만 보고
- "불일치"는 다음을 포함: (a) 설계 문서가 서술한 코드 동작과 실제 라이브 코드/DB 상태가 다른 경우, (b) 여러 설계 문서(Overview/Logic/TestPlan/ChangeContract) 간 서로 다른 아키텍처를 전제하는 경우, (c) "기존 패턴 재사용"이라고 서술했으나 실제로는 새로운 조합/변형인 경우
- 반복 한도: 명시적 상한은 두지 않으나, 3회 이상 반복해도 정합 안 되면 설계 자체를 재검토(Stage 3으로 롤백)할 신호로 간주

### 36.4 근거

600410 워크패킷에서 이 루프가 실제로 승인 직전 세부 오류 3건을 잡아냈다(2026-07-11). 구현 후 재검증(§35)만으로는 "설계 자체가 틀린 채로 구현되는" 것을 못 막는다 — 설계 단계에서도 같은 원리(다른 행위자, 원문 대조)가 필요함을 실증했다.

## 37. 검증자 할당자 저작자 확인 규칙 (2026-07-11)

배경: 600410 워크패킷 진행 중, Claude(Human의 조력자)가 0151의 재검증을 Cursor "그리고" Codex 양쪽에 지시하려 했으나, Codex는 0151을 직접 구현한 당사자였다 — 즉 구현자에게 자기 산출물의 독립 재검증을 맡기려 한 실수였다. Human이 이를 즉시 지적해 Codex 지시는 취소되고 Cursor만 진행했다. 이는 §35/§36이 "다른 행위자"를 요구한다고 명시했음에도, 실제 지시를 내리는 시점에 "이번 산출물의 원작자가 누구였는지"를 확인하는 절차가 없어 발생한 오류다.

### 37.1 원칙

§35(구현 후 재검증), §36(설계 후 재검증)에 따라 검증 작업을 배정하기 전에, 반드시 다음을 먼저 확인한다:

1. 이번 산출물(설계 문서 또는 구현 코드)을 실제로 작성한 행위자가 누구인지(Claude Code 단독, Codex 단독, 또는 여러 라운드에 걸쳐 혼합 작성됐는지)
2. 그 행위자를 검증자 후보에서 제외
3. 남은 후보 중에서 검증자를 선정(일반적으로 Cursor가 우선, Cursor가 부적합한 성격의 작업이면 그 다음으로 적합한 제3자)

### 37.2 절차

- Claude(파이프라인 지시자 역할)는 검증 지시문을 작성하기 직전에 "이 산출물의 최근 작성/수정 이력(git log, 또는 이번 세션의 지시 이력)"을 스스로 재확인하고, 지시문 서두에 "원작자: OOO, 따라서 검증자는 OOO 제외"를 명시한다.
- Human이 검증자 지정을 요청할 때도, 원작자와 겹치면 그 사실을 Claude가 먼저 알리고 대안을 제시한다(Human이 명시적으로 "그래도 이렇게 해달라"고 하지 않는 한 원작자=검증자 배정을 하지 않는다).

### 37.3 예외

동일 행위자가 "구현 → 자체 문법/실행 오류 재현"처럼 즉각적인 자기 오류 확인을 하는 것은 예외로 허용한다(예: 오늘 0151의 `array_agg` 문법 오류를 Codex 스스로 재현한 사례) — 이는 §35/§36이 요구하는 "다른 관점의 독립 재검증"을 대체하지 않으며, 별도로 그 독립 재검증은 여전히 필요하다.

## 38. 위험별 검증 강도 계층 (2026-07-11)

배경: §35/§36/§37이 "다른 행위자가 검증한다"는 원칙을 세웠으나, 매번 3개 행위자(Cursor/Codex/Claude Code) 전부를 동원하면 작업 적체가 발생한다(Human 관찰, 600910 워크패킷 진행 중). 검증 강도는 "이번 산출물이 실제로 무엇을 바꾸는가"에 비례해야 한다.

### 38.1 원칙

| 산출물 성격 | 필요 검증 인원 |
|---|---|
| 이미 확정된 설계를 문서 양식에 정리(TestPlan/ChangeContract 등, 판단 없이 옮겨적기) | 1명(통상 Claude Code) |
| 신규 설계 초안(Overview/Logic, 판단 포함) | 1명 독립 재검증(§36, 통상 Cursor) |
| 실제 코드/DB 변경(구현) | 2명 이중 재검증(§35, Claude Code + Cursor) |

### 38.2 판단 기준

"실제로 라이브 DB나 소스 코드를 바꾸는가?" — 바꾸면 이중검증(§35), 안 바꾸고 문서만 정리하면 단일검증으로 충분. 설계 문서라도 새로운 아키텍처 판단(예: zone 순회 방식, 상태명 통일 방향)이 들어가면 §36 재검증 필요, 이미 정해진 내용을 양식에 옮기는 것뿐이면 불필요.

### 38.3 예외

검증자가 작업 도중 "이 판단은 예상보다 크다"고 스스로 인지하면(예: 이번처럼 함수 오버로드 발견), 원래 배정보다 상위 등급 검증을 요청할 수 있다.

### 38.4 검증 방법 독립성 원칙 (2026-07-18)

**배경**: §35-§39가 "몇 명이 검증하는가"(인원수 축)를 규율해왔으나, 복수 검증자가 전부 PASS를 낸 경우에도 그 PASS들이 진짜 독립적인 증거인지는 별도로 판단해야 한다 — 인원수가 같아도 검증 방법이 같으면 사실상 같은 관찰을 여러 번 반복한 것에 불과하다.

**원칙**: 복수 검증자가 모두 PASS를 낸 경우, Claude는 그들이 (a) 같은 방법(예: 셋 다 같은 문서를 읽고 동의)으로 도달했는지, (b) 서로 다른 방법(예: 하나는 실제 재현, 하나는 정적 코드 대조, 하나는 라이브 DB 직접 조회)으로 도달했는지를 구분해야 한다. **서로 다른 검증 방법의 수렴이 같은 방법의 반복보다 훨씬 강한 증거다** — 방법이 같으면 그 방법 자체의 공통 사각지대(shared blind spot)를 아무도 잡아내지 못한다(§26 Adversarial Audit Pass Requirement가 "같은 모델 계열 안에 머물면 공통 사각지대 위험이 있다"고 한 것과 동일한 논리를, 검증자 인원이 아니라 검증 *방법*의 축에 적용한 것).

**적용**: Critical tier 검증을 지시할 때, 가능하면 검증자별로 서로 다른 접근법을 쓰도록 유도한다 — 예를 들어 한 검증자는 문서-코드 정합성만 정적으로 대조하고, 다른 검증자는 실제 라이브 DB에서 재현 테스트를 실행하고, 필요하면 세 번째 검증자는 코드만 보고(문서 없이) 독립적으로 재구성하도록 지시하는 식이다. 검증 지시문 작성 시 "다른 AI + 다른 검증 방법 + 다른 입력 순서"라는 세 축을 명시적으로 고려한다 — 이 구조는 §45(Post-MVP Fable 블라인드 역설계 계획)의 Pass A-D 설계에서도 동일하게 적용될 후보로 기록한다.

(2026-07-18, ChatGPT 교차검증 기반 반영)

## 39. 의무적 이중 검증 표준 (2026-07-11)

배경: §38이 "산출물 성격에 따라 검증 강도를 차등화"하도록 했으나, Human 결정으로 이를 상향 조정한다: 앞으로 모든 검증은 최소 이중(2인 이상의 서로 다른 행위자)으로 진행한다. 이는 §38의 "1명으로 충분" 등급을 폐기하는 것이 아니라, 그 등급의 적용을 Human이 명시적으로 승인한 경우로 제한한다는 뜻이다 — §38을 대체하지 않고, 그 위에 추가되어 기본 적용 범위를 좁히는 상위 규칙이다.

### 39.1 원칙

- 기본값: Cursor + Codex 이중 검증(또는 상황에 맞는 다른 두 행위자 조합).
- §38의 "1명으로 충분" 등급은 이제 예외이며, Human이 그때그때 명시적으로 지정해야만 적용된다.
- 원작자는 검증자에서 제외되는 원칙(§37)은 그대로 유지 — 이중 검증도 원작자를 뺀 나머지 중에서 선정한다.

### 39.2 도구 구성 변화 반영

Cursor의 모바일 환경 미지원으로 인해, Gemini Anti-Gravity CLI를 대안으로 시험 중이다. 도구 구성이 확정되면 이 섹션을 갱신한다 — 현재는 Open Item으로 기록만 한다.

### 39.3 예외

Human이 특정 작업에 대해 "이번엔 단일 검증으로" 명시적으로 지정한 경우에만 §38 기준으로 되돌아간다.

## 40. Tool Trial: Gemini Antigravity Observer Period (2026-07-13, 정정)

배경: Cursor는 이 프로젝트에서 실질적으로 코딩 역할을 수행한 적이 없으며(§34에서 이미 "코딩 능력이 이 프로젝트와 안 맞음"으로 확인됨), 방대한 문서/코드 전수 검색(Eyes-Only) 용도로만 써왔다. 파일을 직접 다룰 수 있는 행위자가 3개(Claude Code, Codex, 세 번째) 필요한 구조였고, 그 세 번째 자리가 Cursor였다. Cursor의 모바일 환경 미지원 공백을 메우기 위해 Gemini Antigravity("안티")를 시험 도입했다(§39.2에서 Open Item으로 기록됐던 그 시험).

**Human 결정(2026-07-13, 재논의 금지) — 즉시 대체 아님, 관찰 기간 후 조건부 대체**: 안티를 Cursor의 즉시 대체가 아니라, 최소 1개월간 옵저버로 병행 운영한다. 이 기간 안티의 산출물은 참고용일 뿐 정식 검증 판정(§35/§36/§39)에 반영하지 않는다 — Cursor가 계속 정식 검증자 역할을 수행한다. 신제품(Antigravity)이 아직 안정화 단계일 수 있어, 실전에서 검증되지 않은 도구를 곧바로 핵심 파이프라인 자리에 앉히는 것은 위험하다는 판단이다 — 첫 온보딩 응답에서 안티가 스스로의 역할을 Eyes-Only보다 넓게(설계+감사까지) 오인했던 사례도 이 신중한 접근의 근거가 됐다.

### 40.1 관찰 기간 중 역할 분리 — "3중 검토" 표준 절차 (2026-07-13 갱신)

**Human 결정(2026-07-13)**: 관찰 기간 동안, 앞으로 §35/§36 검증이 필요한 모든 작업(Medium tier 이상)에 대해 Antigravity에게도 동일한 지시문을 병행 전달하는 것을 **표준 절차**로 한다 — 매번 개별 판단하지 않고 기본값으로 실행한다. 데이터 축적을 가속화하기 위함이다.

Medium tier 이상 검증 시 기본 구성("3중 검토"):

- **정식 검증자 2명(Claude Code + Cursor 또는 Codex, §35/§36/§39 기준)**: PASS/FAIL 판정에 반영. 이 기간 동안 §35/§36/§37/§39의 "Cursor" 표기는 그대로 유지되며 Antigravity로 대체되지 않는다.
- **Antigravity**: 동일 지시문을 병행 전달한다(기본값, 매번 개별 판단 불필요). 결과는 Verification 문서에 "참고용, 비공식"으로만 기록한다 — 정식 PASS/FAIL 판정에 영향을 주지 않는다. 판단·설계·수정 금지(Eyes-Only 원칙, §1의 Cursor 역할 정의와 동일 범위)는 이 관찰 기간에도 그대로 적용된다.
- **세 결과 비교**: 정식 검증자 2명 + Antigravity, 세 결과를 나란히 비교해서 안티의 일치율을 암묵적으로 계속 추적한다 — 별도 통계 문서화는 하지 않되, 불일치가 발생하면 그 워크패킷의 Open Question으로 기록한다.

### 40.2 1개월 관찰 후 결정 분기점

1개월 관찰 종료 시점에 다음 두 갈래 중 하나로 Human이 결정한다:

- **안정적으로 잘 따라온 것으로 판단되면**: 내부 파이프라인에서 Cursor를 완전 대체 — 이때 비로소 §35/§36/§37/§39의 "Cursor" 표기가 "Antigravity"로 전환되고, 이후 신규 워크패킷의 지시문/검증 기록도 "Antigravity"로 표기한다(과거 기록은 소급 수정하지 않음).
- **그렇지 않으면**: 최소한 Cursor가 원래 지원 못 하던 영역(모바일 등 외부 활동)에서만 보조 역할로 한정 — Cursor는 정식 검증자 지위를 유지한다.

이 분기점 이전까지는 §40.1의 역할 분리를 그대로 따른다.

### 40.3 안티 지시문 표준 템플릿 (2026-07-15, 실전 관찰 기반 확정)

**번호 조정 안내**: Human 지시문은 이 절을 "§40.2"로 지칭했으나, §40.2는 이미 "1개월 관찰 후 결정 분기점"(2026-07-13 확정)에 배정되어 있어 충돌한다. 기존 §40.2의 내용을 대체/재논의하는 것이 아니므로, 이 절은 §40.3으로, 다음 관찰 사례 기록 절은 §40.4로 번호를 조정해 추가한다.

**Human 결정(2026-07-15, 재논의 금지)**: 안티(Antigravity)는 아직 낮은 버전이라, "Eyes-Only"라는 지시어 하나만으로는 원작자 배제라는 역할은 전달되지만 "라인 단위로 원문을 깊이 파고드는" 검증 깊이까지는 전달되지 않는다는 것이 실전으로 반복 확인됐다(사례는 §40.4 참고). 따라서 안티에게 지시할 때는 표준 템플릿에 "라인 인용 필수"를 명시적으로 포함한다.

기존 "Eyes-Only, 다음을 확인하세요..." 형태만으로는 부족함이 확인됐다. 안티에게 보내는 모든 지시문은 다음 문구를 포함해야 한다:

> Eyes-Only. 단, 결론만 요약하지 말고 각 확인 항목마다 실제 코드 원문을 정확한 파일명+라인 번호와 함께 직접 인용할 것. 다른 검증자(Cursor/Codex)의 결론과 다를 수 있으니, 주장하는 결론을 뒷받침하는 정확한 코드 줄을 반드시 보여줄 것 — 원문 인용 없는 결론은 재검증 대상으로 간주한다.

이 문구는 §40.1의 "3중 검토" 표준 절차에서 안티에게 병행 전달하는 모든 지시문에 기본으로 포함한다 — 매번 개별 판단하지 않는다.

### 40.4 관찰 사례 기록 (참고용, §39 근거 자료)

- 2026-07-14: "600000 대역 전체 격리" 오독(§15.1 원문 미확인).
- 2026-07-14: `mark_payment_uncertain` 워크패킷에서 Codex 결과를 그대로 복붙한 가짜 검증(본인 발견 아님).
- 2026-07-15: `601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md` §6("L512가 `kds_tickets.payment_ledger_id` 컬럼을 채운다")의 오류를 Cursor/Codex는 원문 대조로 잡았으나 안티는 놓침 — 원문 인용 없이 결론만 낸 패턴과 일치.

## 41. 세계적 실패감사 요구 (2026-07-13)

배경: `010554_Policy_Four_Layer_Audit_Capture_Trigger_View_OS_Log_And_Nightly_Batch_Reconciliation.md`가 이미 4계층 감사(DB 트리거/뷰-프로젝션/OS 런타임 로그/야간 배치 재조정) 모델을 정의해뒀으나, 그 적용 범위는 `PAYMENT_EVENT`/`REFUND_EVENT`/`SECURITY_EVENT` 등 명시적으로 나열된 고위험 이벤트 카탈로그(§8)에 한정되며, 문서 자체가 "이 문서는 planning-only이며 코딩을 승인하지 않는다"(§26 Runtime Deferral)고 명시한다. Human 결정(2026-07-13)은 이보다 넓은 범위를 요구한다: 위험도와 무관하게, 단순 진단성(diagnostic) 케이스가 아니라 **실제 실패(unhandled exception 등)가 발생하는 모든 경우**에 영구 기록을 요구한다.

**이번 조사 경위(Cursor+Antigravity 이중 조사, 2026-07-13)**: 최초안은 "DB + OS 파일시스템(`RAISE LOG`) 이중 기록"이었다. 조사 결과 `RAISE LOG`는 기술적으로는 작동하지만(`logging_collector = off`로 이번 턴 직접 재확인), 디스크 파일로 남지 않고 Docker의 임시 로그 스트림에만 존재하며, 마이그레이션 코드에 연결된 사례가 없다 — 컨테이너 재시작/로그 로테이션으로 유실될 수 있어 금융권 감사 목적에 부적합함이 조사로 실증됐다. 따라서 "OS 파일시스템 기록" 요구사항은 **폐기**하고, 이미 이 코드베이스에서 검증된 기존 함수 `catchmenu_audit.append_audit_record()`(→ `catchmenu_ledger.audit_records`, append-only)로 단일화한다 — 이번 턴 직접 확인한 결과 49개 마이그레이션 파일이 이미 이 함수를 사용 중이며(`grep -l` 재확인), 새 메커니즘을 만들 필요가 없다.

### 41.1 원칙 (최종 확정)

모든 RPC 함수는 `EXCEPTION` 핸들러 블록을 갖추고, 실패 발생 시 **`catchmenu_audit.append_audit_record()`를 통해 `catchmenu_ledger.audit_records`에 append-only로 영구 기록**한다. 이 경로는 이미 append-only + 영구 보존이 보장되므로 그 자체로 충분하며, 별도의 OS 파일시스템 이중 기록은 요구하지 않는다(위 배경 문단 참고 — 실현 시 오히려 더 불안정한 감사 경로가 된다는 것이 조사로 확인됨). 기록 후 원래 에러를 재발생시키거나(`RAISE`) 적절한 에러 응답을 반환한다 — 조용히 삼키지 않는다.

**`log_diagnostic()`/`diagnostic_logs`와의 구분 — 용도가 다름**: `catchmenu_common.log_diagnostic()`(→ `catchmenu_common.diagnostic_logs`)은 이번 조항이 대체하지 않는다. 이는 "비즈니스 실패는 아니지만 알아둘 만한 상황"(예: `600710`의 게스트+포인트 요청 케이스 — 주문 자체는 정상 진행되지만 클라이언트 버그 추적용으로 남기는 경고)을 위한 **진단성 경고** 채널로 별도 유지한다. `append_audit_record()`는 실제 실패(`EXCEPTION` 발생)를 위한 경로이고, `log_diagnostic()`은 실패가 아닌 정상 흐름 중의 경고를 위한 경로다 — 두 채널은 목적이 다르므로 서로 대체하지 않는다.

### 41.2 §010554와의 관계 — 범위가 다르지 대체가 아님

§010554의 4계층 모델(DB 트리거/뷰-프로젝션/OS 로그/야간 배치)은 **고위험 이벤트 카탈로그**(결제/환불/보안/AI/내보내기 등)에 계속 적용된다 — 이번 §41이 그것을 대체하거나 축소하지 않는다. §41은 그보다 **낮은 문턱**에서 적용되는 별개의 요구사항이다: "이 이벤트가 고위험 카탈로그에 속하는가"와 무관하게, "이 RPC 호출이 처리되지 않은 예외로 실패했는가"만을 기준으로 삼는다. 즉 §010554는 이벤트의 *종류*로 범위를 정하고, §41은 실행의 *결과*(실패 여부)로 범위를 정한다 — 두 기준은 서로 겹칠 수 있으나(예: 결제 RPC의 unhandled exception은 양쪽 모두 해당) 어느 한쪽이 다른 쪽을 포함하지 않는다.

### 41.3 적용 범위

신규/수정되는 함수부터 우선 적용한다 — `600710_place_takeout_order_unassigned_record_fix`의 `place_takeout_order()`가 첫 적용 대상 후보다. 기존 함수 전체에 대한 소급 적용은 이번 조항의 범위가 아니며, 별도 백필(backfill) 워크패킷으로 분리한다.

## 42. §6.5 모든 사람 에게 의무적 인 규칙 Overview.md (2026-07-13)

Human 결정(2026-07-13, 재논의 금지): 모든 `Overview.md`는 `§6.5 Required Context Snapshot Candidates` 섹션을 반드시 포함한다.

이 섹션은 Stage 2/Stage 3가 설계 판단에 실제로 투입한 규칙·문서 후보를 빠뜨리지 않도록 하기 위한 최소 컨텍스트 스냅샷이다. `Overview.md`가 이 섹션을 누락하면 Stage 3 검증에서 반려 사유가 된다.

필수 구조:

1. ♪ 장님 ♪
   - 해당 change의 최상위 판단 근거, Human 결정, 특허/운영/도메인 기준 문서, 또는 "해당 없음"을 명시한다.
2. ** 완전 규칙이 필요**
   - 전체 본문을 읽어야 하는 규칙/설계/근거 문서를 적는다.
   - 단순 파일명 언급과 실제 full-read 필요 문서를 구분한다.
3. ** 도메인 지수**
   - 관련 도메인 폴더의 Index/NavigationMap/Readme 등 흐름·위치 파악용 문서를 적는다.
   - 본문에 인용된 도메인 인덱스가 없으면 "해당 없음"을 명시한다.
4. **제외된 규칙 가족**
   - 이번 change와 무관하다고 본문에서 이미 제외한 문서군/규칙군/파일군을 적는다.
   - 최소 1개 이상 명시해야 한다.

작성 규칙:

- 이미 Overview 본문에서 인용한 문서를 이 4단 구조로 재분류한다.
- 애매한 문서는 임의 배치하지 말고 `Open Question`으로 표시한다.
- `§6.5`는 새 판단을 추가하는 장소가 아니라, Overview 본문에 이미 등장한 근거와 제외 범위를 구조화하는 장소다.
- `§6.5` 작성은 기존 본문 판단을 대체하지 않는다. 기존 §0~§5 본문은 그대로 두고, 컨텍스트 스냅샷 후보만 별도 섹션으로 고정한다.

## 43. 크로스 검증에 대한 위험성 낮은 예외가 없다 (2026-07-14)

**Human 결정(2026-07-14, 재논의 금지)**: "속도보다 무결성이 우선"이라는 프로젝트 철학에 따라, LOW risk 예외를 만들어 단일/이중 검증만으로 ACCEPT하는 것을 원칙적으로 금지한다. "이건 안전한 작업이다"라는 자의적 판단 자체가 새로운 판단 오류 지점이 되기 때문 — 오늘 세션에서 이미 여러 번(Gemini의 잘못된 초기 판단들, Cursor의 체크섬 오탐 등) 확인된 패턴이다.

### 43.1 원칙

문서 작업이든 SQL 작업이든, 위험도와 무관하게 §39(삼중검증 표준)를 항상 완주한다. "순수 문서 정리라서/SQL 미변경이라서 가벼운 검증으로 충분하다"는 판단으로 검증자 수를 줄이지 않는다.

### 43.2 검증자 결원 시 처리

Antigravity(또는 다른 검증자)가 토큰/컨텍스트 부족 등으로 참여 불가능한 경우:

- 다른 행위자(Cursor 등)로 대체 투입한다.
- 또는 결원 상태가 해소될 때까지 대기한다.
- "그냥 이번엔 예외로 단일검증으로 가자"는 선택지는 취하지 않는다.

### 43.3 600520의 처리 (소급 적용 안 함)

`600520`(도메인 폴더 재편) 워크패킷은 이 원칙 확정 이전에 이미 Stage 11 ACCEPT 및 커밋 완료된 사안이므로, 소급 재검증하지 않는다. `600527_Audit.md` Open Item (e)는 "과거 사례로서 이 원칙이 왜 필요한지 보여주는 근거"로 그대로 남긴다.

### 43.4 §38과의 관계

§38(검증 강도 차등화)의 "1명으로 충분" 등급은 §39에 의해 이미 사실상 기본 적용 범위가 좁아진 상태(§39 참고)였으나, 이번 §43으로 그 여지를 완전히 닫는다 — §38의 차등화는 "검증 방법의 깊이"에는 계속 적용 가능하나(예: 어떤 부분을 더 꼼꼼히 볼지), "검증자 숫자 자체를 줄이는 것"에는 더 이상 적용되지 않는다.

## 44. 완전한 추적 기록 및 즉각적인 의심 해소 (2026-07-14)

**Human 결정(2026-07-14, 재논의 금지)**: 시스템 오너는 PL/SQL 개발자 + DBA + 유닉스/리눅스/MS SE 출신이며, "작은 씨앗 하나가 나중에 큰 버그가 된다"는 것을 실무로 체득한 원칙으로 삼는다. 금융권 수준 시스템이므로 모든 파일의 흔적을 빠짐없이 기록하고, 그 감사(audit) 흐름 자체도 문서화한다. 문서가 이 프로젝트의 성공 자산이라는 철학을 명문화한다.

### 44.1 원칙

- 모든 파일 변경은 어떤 형태로든(마이그레이션 헤더 주석, Module 문서, git 커밋 메시지) 그 이유와 경위를 남긴다.
- 감사(audit) 자체의 흐름(누가 언제 무엇을 확인했는지, 어떤 방법으로 검증했는지)도 문서로 남긴다 — 결과만이 아니라 과정도 기록 대상이다.
- 문서는 부수적 산출물이 아니라 이 프로젝트의 핵심 자산으로 취급한다.

### 44.2 의심 즉시 해결 원칙 (Zero Deferred Doubt)

검증 과정에서 확신이 안 서는 지점, 앞뒤가 안 맞는 서술, 출처가 불명확한 주장을 발견하면:

- "일단 넘어가고 나중에 확인하자"는 선택지를 취하지 않는다.
- 그 자리에서 즉시 재검증하거나, 확인 불가능하면 Open Item으로 명시적으로 남기되 "왜 확인이 안 됐는지"까지 기록한다.
- 다수(여러 검증자)가 같은 주장을 해도, 실제 근거(원문/실행결과) 없이는 그 다수결을 그대로 받아들이지 않는다(오늘 §15.1 재검증 사례, Cursor 체크섬 오탐 사례가 실증).

### 44.3 근거

오늘 세션에서 실제로 확인된 사례들:

- `0063`의 오버로드 방치(작은 씨앗) → `confirm_payment_from_provider()`가 이 프로젝트 역사상 최초로 성공적인 E2E 실행에 이르기까지 오래 방치됨(`600510_confirm_payment_from_provider_overload_ambiguity`, `600401_ChangeHistory.md` 2026-07-14 항목).
- Cursor의 체크섬 보고(`0115`, DB `7eba4434...` vs. 주장된 정답 `c588014b...`) 오탐을 재검증 없이 받아들였다면, 실제로 정상인 파일을 훼손할 뻔했다 — 3가지 독립 방법(수동 재계산, `apply_migrations.py` 소스 검토, 실제 재실행)으로 재검증한 결과 DB 체크섬은 이미 정확했다(`600626_Verification.md`).
- §15.1의 "600000_implementation_lifecycle/ 전체 밴드가 990000_legacy_quarantine/로 격리됐다"는 주장을 원문 재확인 없이 받아들였다면, 잘못된 폴더 구조 결정(현재 활성 상태인 `600000_implementation_lifecycle/`을 존재하지 않는 것처럼 취급)을 내렸을 것이다 — 직접 `990000_legacy_quarantine/`을 조사한 결과, 격리된 것은 이 경로의 **이전** 판본(별개의 메타-거버넌스 스킴 81개 파일 + `604000_workpackets/` 166개 파일)이었고, 이후 같은 경로가 지금의 다른 내용으로 **재사용**된 것으로 확인됐다(`000054_Assessment_Workpacket_Overview_Logic_Filename_Convention_Governance_Gap.md`).

## 45. Post-MVP Fable 블라인드 역설계 검증 계획 (향후 계획 — 지금 실행 안 함)

**Status: 계획만 기록. 실행 시점 미정, 이 세션이나 진행 중인 어떤 워크패킷도 이 섹션을 실행 근거로 삼을 수 없다.** MVP(Phase 1/2) 완성 후, Claude Fable 5(장문맥 모델)를 이용해 이 프로젝트 전체 시스템을 기존 설계 문서에 전혀 앵커링되지 않은 상태로 역설계·검증하는 별도 워크스트림을 계획 중이다. ChatGPT가 2026-07-18 제안한 4-Pass 구조를 그대로 이 섹션에 기록한다.

### 45.1 Pass A — 블라인드 역설계 (문서 미제공)

Fable에게 최초로는 기존 `Overview.md`/`Logic.md` 등 설계 문서를 전혀 보여주지 않는다. 제공하는 것:

- 실제 스키마, 함수 정의, 트리거, 뷰, RLS 정책, GRANT
- 실제 호출 관계(누가 누구를 부르는가)
- Flutter/API 호출자
- cron/background job 정의
- 실제 테스트 실행 결과

Fable이 오직 이것들만으로 재구성해야 하는 것:

- 실제 도메인 경계
- 실제 상태 머신
- 실제 권한 모델
- 결제 → KDS 흐름
- 감사 경로
- 실패 복구 경로
- 도달 불가능 상태
- 중복 엔진(같은 상태를 바꾸는 함수가 둘 이상 존재하는 경우)
- 우회 경로
- 고아 함수(호출자 없는 함수)

### 45.2 Pass B — 문서 기반 의도 모델 추출 (Pass A와 별도로, 섞지 않음)

기존 설계 문서(`Overview.md`/`Logic.md` 등)만 보고 다음을 추출한다:

- 의도된 아키텍처
- 정책상 상태 머신
- 정책상 권한 경계
- 금지된 우회 경로
- 예상 복구 경로

이 Pass는 Pass A와 반드시 별도 세션/별도 컨텍스트로 수행해 서로 오염되지 않게 한다 — Pass A 수행자가 Pass B의 문서를 미리 봐서는 안 되고, 그 역도 마찬가지다.

### 45.3 Pass C — As-Designed vs As-Built 비교, 9개 분류

Pass A(실제 구현)와 Pass B(문서상 의도) 사이의 모든 차이를 다음 9개 카테고리 중 하나로 분류한다:

1. **Implementation Defect** — 문서는 맞고 코드가 틀림
2. **Documentation Drift** — 코드는 의도대로 바뀌었지만 문서가 낡음
3. **Architecture Divergence** — 코드와 문서가 서로 다른 모델을 따름
4. **Dead Design** — 문서엔 있으나 미구현
5. **Undocumented Runtime** — 구현됐지만 문서 없음
6. **Duplicate Authority** — 같은 상태를 바꾸는 엔진이 둘 이상
7. **Bypass Path** — 정식 게이트 우회 경로
8. **Orphan Function** — 호출자가 없거나 미완성
9. **False Verification** — PASS로 기록된 문서가 실제 실행 증거와 불일치

### 45.4 Pass D — 실제 시나리오 재생 (정적 역설계로 끝내지 않음)

Pass A-C가 정적 분석에 그치지 않도록, 실제 DB에서 대표 시나리오를 재생하고 그 결과를 역설계한 상태 머신과 대조한다. 최소 다음 시나리오를 포함:

- POS 결제
- Toss 웹훅
- VAN 승인
- 결제 uncertain 복구
- 취소 후 재승인
- KDS 용량의 과잉
- capacity 해소 후 재방출
- 중복 웹훅(재전송)
- no-show 후 늦은 도착
- 테이블 착석과 세션 바인딩

### 45.5 검증 독립성의 3축 — 이 계획에도 적용할 후보

§38.4(검증 방법 독립성 원칙)가 확립한 "다른 AI + 다른 검증 방법 + 다른 입력 순서가 함께 있어야 진짜 독립"이라는 원칙을, 이 Fable 역설계 작업에도 그대로 적용할 후보로 기록한다:

- AI 1: 문서-코드 정합성 검사(정적 대조)
- AI 2: 코드만 보고 역설계(Pass A와 동일한 블라인드 방식)
- AI 3: 실제 DB 실행과 상태 전이 검사(Pass D와 동일한 동적 재현)
- Claude: 셋의 충돌 감사
- Human: 정책 결정

### 45.6 이 섹션의 지위

이 섹션은 계획 기록일 뿐이다 — MVP(Phase 1/2) 완성이 확인된 뒤, Human이 별도로 착수 여부/시점/스코프를 결정한다. 그 전까지는 어떤 진행 중인 워크패킷도 이 섹션의 존재를 실행 승인이나 우선순위 판단의 근거로 사용할 수 없다.

(2026-07-18, ChatGPT 제안 4-Pass 구조 기반 기록)

## 46. Overview 작성 시 근거 MD 파일 목록 명시 의무화 (2026-07-20)

Stage 1(Cursor의 조사)에서 만드는 근거자료(Evidence Pack)는 Claude Code에게 전달되고 끝나는 게 아니라, 그 안의 '관련 MD 파일 전체 목록'이 Stage 2에서 작성되는 Overview 문서 자체에 반드시 포함되어야 한다.

Overview는 다음 섹션을 가져야 한다:

'§근거 문서 목록(Cursor 조사 기반)' - Cursor가 이 워크패킷을 위해 실제로 찾아낸 관련 MD 파일 전체를 경로와 함께 나열한다. 이 목록은:

1. Overview 작성 시점에 실제로 참고한(또는 참고 대상으로 확인했으나 의도적으로 배제한) 모든 관련 문서를 빠짐없이 기록한다
2. 배제한 문서가 있다면 왜 배제했는지 한 줄 근거를 남긴다
3. 이후 이 워크패킷을 검증하거나 재검토하는 사람이 '이 Overview가 실제로 존재하는 관련 문서들을 다 살펴보고 작성됐는지'를 이 목록만으로 확인할 수 있어야 한다

이 원칙의 목적: Overview가 즉흥적으로 작성되지 않고, 실제로 존재하는 관련 자료 전체를 놓고 작성됐다는 걸 사후에도 추적 가능하게 만든다. 601400 검사에서 발견된 것처럼(예: 005191/005241 provider cutline이 서로 다른 시점에 독립적으로 작성되어 충돌한 사례 CH-F04), 관련 문서를 몰랐거나 놓친 채로 새 Overview를 쓰면 같은 충돌이 반복된다.

Stage 4(Architecture Verification)에서 검증자는 이 근거 문서 목록이 실제로 완전한지(Cursor가 놓친 관련 문서가 없는지)도 함께 확인해야 한다.

---

## 47. 6단계 나선 개발방법론 + 단계별 개발순서 (2026-07 확정)

**배경 (재논의 금지)** 이 조항은 601400 설계무결성 검사 프로그램에서 반복적으로 발견된 설계문서-실제 SQL 구현 간 불일치(phantom 컬럼, 상태값 불일치, 번호충돌, "거버넌스 연극" 등)의 근본원인이 "무엇을 어느 순서로, 어떤 검증을 거쳐 만들지"에 대한 상위 방법론의 부재였다는 결론에 따라 확정되었다. §3의 13단계 파이프라인이 "하나의 변경(Workpacket)을 어떻게 만들고 검증하는가"를 규정한다면, 이 §47은 그 위에서 "프로젝트 전체를 어떤 순서와 단위로 쪼개어 진행하는가"를 규정하는 상위 방법론이다.

### 47.1 방법론 개요 — 도메인 단위 나선(spiral) 반복

프로젝트 전체(0~7차 다단계 로드맵)를 한 번에 설계하지 않고, 도메인 단위로 작은 나선(spiral)을 반복한다. 각 나선은 다음 6단계로 구성된다:

1. **업무규칙 선언** (Human 전담, AI 위임 불가) — 이 도메인에서 무엇을 사실로 삼을지 짧게 선언한다.
2. **ERD 초안** (AI: Cursor 조사 + Claude Code 작성) — 선언을 바탕으로 Mermaid ERD를 작성하고, 기존 구현부가 있으면 실제 스키마와 대조한다.
3. **인접 도메인 대조** (AI: Opus/Fable) — 이미 확정된 인접 도메인 설계문서/ERD와 어휘·FK 충돌 여부를 검증한다 (V모델의 핵심 짝짓기).
4. **설계문서 정합화** (AI 작성 + Human 승인) — Overview/Logic을 작성하고, §46 근거문서목록을 의무 첨부한다.
5. **SQL 구현 + 이중검증** (Codex 구현, Cursor + Codex 검증) — 기존 13단계 파이프라인(§3)의 Stage 4-9를 그대로 재사용한다.
6. **나선 종료 판정** (Human) — 이번 나선 종료 여부를 짧게 판정하고, 추가로 "이번에 건드린 게 이전에 끝난 도메인의 확정 계약과 충돌하는지"를 1줄 확인한 후 다음 나선으로 넘어간다.

### 47.2 가드레일 — 먼 미래 단계의 상세설계 금지

현재 나선보다 먼 미래 개발단계(예: Physical AI Gateway, Franchise HQ 등)는 **ERD 상세설계를 금지**하고, 산문 형태의 한 페이지 비전 요약만 유지한다. 예외적으로 미래 단계가 현재 스키마에 물리적 훅(컬럼 등)을 남겨야 하는 경우에만, 1단계(업무규칙 선언)에서 명시적으로 선언한 후 최소한만 허용한다.

### 47.3 현재 확정된 전체 개발 순서

#### 0단계: 운영 권위 기반 (Operational Authority Foundation)

"SaaS 기초"라고 부르지 **않는다** — AI가 SaaS 전체 구현으로 확대 해석할 위험을 방지하기 위함이다.

**0단계 목표**: 모든 SaaS 기능을 완성하는 게 아니라, 이후 어떤 도메인을 만들어도 다시 흔들리지 않을 최소 권위 구조를 확정하고, tenant 1개 / store 1개로 실제 작동시키는 것.

**하위 나선 (순서대로)**:

- **0-A** 임차자 / 회사 / 본부 / 매장
- **0-B** 직원의 신분/시션
- **0-C** Authorization (caller-authorization 공백 해결 포함 — "서버가 신뢰가능한 세션에서 권한을 도출해야지, 클라이언트가 보낸 파라미터를 그대로 믿으면 안 된다"는 원칙을 실제 RPC 아키텍처에 구현)
- **0-D** Customer identity 기반
- **0-E** Menu definition (seed_menu 포함)
- **0-F** Dining table definition (테이블번호 / 좌석수 / 상태)

**반드시 완성해야 하는 것**: tenant 1개, company/HQ 1개, owner 1명, store 1개, 직원 1-2명, 고객신원 생성 가능, 직원 로그인 또는 검증가능한 세션, RPC 호출자 식별 가능, store/tenant 경계검사 가능, 역할별 최소권한검사, 메뉴 seed 및 조회, 테이블번호·좌석수·상태 정의.

**0단계에서 미뤄도 되는 것**: 다중tenant 실제운영UI, 복잡한 요금제, SaaS 과금, tenant 셀프가입, HQ 조직도, 복잡한 직급체계, 세밀한 권한관리화면, 매장간 직원이동, 프랜차이즈계약, 브랜드 다중계층, 완전한 감사 대시보드.

#### 1-1) 멤버십 (설계는 SaaS급 틀, 구현은 tenant1/store1)

- 소속 구조 3층 분리: `person`/`customer_identity`(전역 신원) ↔ `tenant_membership`(브랜드와의 회원관계) ↔ `store_customer_activity`(매장별 이용이력)
- 포인트는 원장방식: `point_account` / `point_ledger` / `point_balance_projection`, 최소 이벤트(EARN / USE / CANCEL_EARN / CANCEL_USE / EXPIRE / MANUAL_ADJUSTMENT)
- 만료배치 / 복잡한 캠페인은 1-1 범위 밖 (원장구조 + 취소의 역거래원칙까지만)

#### 1-2) 관리자페이지 UI

- **목적**: "1호점 운영자가 0단계와 1-1의 데이터를 SQL 없이 생성·조회·수정하고, 1-3 업무를 시작할 수 있게 한다"
- **포함**: 로그인 / 현재tenant·store표시 / 직원세션·권한확인 / 메뉴목록및활성상태 / 테이블목록·번호·좌석수·운영상태 / 회원검색·등록·포인트조회 / 매장영업상태
- **배제**: 매출통계 / 정산 / 마케팅 / 재고 / 직원스케줄

#### 1-3) 대기-사전주문-홀배정 (하나의 거대 워크패킷 금지, 7개 작은 나선으로 분할)

- **1-3A** 대기 등록과 대기열 — [최우선, 최대한 완성]
- **1-3B** 호출·도착·노쇼 — [최우선, 최대한 완성]
- **1-3C** 사전주문 생성과 수정 — [여력되면, 안되면 2차로 이월]
- **1-3D** 결제 전후 사전주문 상태 — [여력되면]
- **1-3E** 홀배정과 착석 — [최우선, 최대한 완성]
- **1-3F** 사전주문 → 홀주문 전환 — [여력되면]
- **1-3G** 취소·복구·감사 — [여력되면]

참고: 1-3A/B/E(대기-입장-홀배정)를 최우선으로 완성하고, 1-3C/D/F(사전주문 관련, KDS/DID/향후POS와 얽혀 복잡함)는 되면 하고 안 되면 2차(매장운영코어)로 이월한다.

#### 1-4) KDS/DID

- **원칙**: 1-3이 "확정된 운영 상태"를 결정하고, 1-4는 그 상태를 "표현·실행"만 한다 (KDS/DID가 주문의 원천이 되면 안 됨).

### 47.4 탈출 조건 (5가지 객관적 트리거 — 감정적 판단 금지)

다음 중 하나라도 해당되면 "벽에 부딪혔다"고 판정하고 탈출을 검토한다:

1. 동일한 핵심 상태모델을 3회 이상 재설계해도 합의되지 않음.
2. 기존 결제/주문 SQL 결함 때문에 1-3 진행이 연속 차단됨.
3. 1-3을 위해 2차 매장운영코어의 핵심 도메인 3개 이상을 선행 구현해야 함.
4. 1호점에서 검증할 수 있는 UI 없이 기반 작업만 계속 증가함.
5. 한 Workpacket이 인접 도메인 4개 이상을 동시에 수정해야 함.

**탈출의 의미**: 실패가 아니라 "1차의 고객 흐름을 억지로 완성하지 않고, 이미 만들어진 운영 권위 기반과 관리자 UI를 2차 매장운영코어의 실사용 기반으로 전환한다"는 뜻이다. 탈출 시 최소한 0단계 + 1-1/1-2(+ 가능한 만큼의 1-3A/B/E)는 그대로 자산으로 남는다.

### 47.5 플랫폼 우선순위

웹앱(전체 파이프라인 완성/검증) → Android → iOS. 뼈대가 완성되어도 화면 개발은 그 자체로 시간이 걸리는 별도 작업이므로 순서를 지킨다.

### 47.6 절대 원칙 (강하게 명문화, 위반 시 즉시 재검토)

1. 0단계는 SaaS 전체 구현이 아니라 운영 권위 최소 기반이다.
2. 설계는 SaaS급이지만 구현은 tenant1/store1 수직 절단이다.
3. 1-3은 하나의 거대 Workpacket이 아니라 여러 개의 작은 업무 나선으로 분리한다.

---

## 48. 나선 착수 전 Cursor 증거수집 표준 템플릿 (2026-07 확정)

**원칙**: "파일이 존재한다"와 "실제로 작동한다"는 완전히 다른 사실이다. Cursor의 착수전 조사는 반드시 이 둘을 구분해서 보고해야 하며, 아래 5단계 분류를 생략하거나 뭉뚱그려서는 안 된다. "어디까지 구현됐는지 찾아라"는 막연한 지시는 Cursor가 문서 목록만 길게 나열하는 결과로 이어지므로 반드시 이 템플릿을 강제한다. 이 조항은 §46(근거 문서 목록 의무화)과 함께, Stage 1(Cursor 조사) 산출물의 최소 품질 기준을 이룬다.

### 48.1 5단계 분류 (모든 대상에 반드시 적용)

- **A. 문서만 존재** — 설계/정책문서는 있으나 그 이상의 근거 없음.
- **B. SQL 객체 존재** — 실제 테이블/함수/제약이 라이브DB 또는 migration에 존재.
- **C. SQL 객체와 문서가 일치** — B의 실제 스키마/함수가 A의 문서 내용과 실제로 부합.
- **D. 로컬 DB에서 실행 검증** — 실제로 호출/실행해봤을 때 성공하는지.
- **E. 호출자/권한까지 포함한 통합 검증** — 실제 호출자가 있는지, 권한검사가 의도대로 작동하는지까지 확인.

### 48.2 대상별 표 형식 (필수)

0단계 착수시 기준 대상 (이후 나선마다 해당 도메인 대상으로 교체):

회사 / 소유자 / 임차자 / 본부 / 상점 / 사용자 정체성 / 고객 정체성 / 직원 정체성 / 세션 / 역할 / 허가 / 회원 / 메뉴 씨앗 / 식탁

**표 항목**: 문서(있음/없음) / DDL(있음/없음) / RPC(있음/없음) / 호출자 또는 권한검사(있음/없음/불완전) / 로컬검증(성공/실패/미확인) / 재사용 판정(그대로재사용/부분재사용/수정후재사용/재작성필요).

| 대상 | 문서 | DDL | RPC | 호출자/권한검사 | 로컬검증 | 재사용 판정 |
|---|---|---|---|---|---|---|
| 회사 | 있음 | 있음 | 없음 | 없음 | 미확인 | 부분재사용 |
| 저장 | 있음 | 있음 | 있음 | 불완전 | 실패 | 수정후재사용 |

(위 두 줄은 형식 참고용 예시이며, 실제 착수 시 전체 대상에 대해 채운다.)

### 48.3 금지사항

- "문서가 존재하므로 구현된 것으로 간주"하는 판단 금지.
- 5단계 중 하나라도 건너뛰고 결론(예: "재사용 가능")을 내리는 것 금지.
- 대상을 표 없이 산문으로만 설명하는 것 금지.

### 48.4 적용범위

이 템플릿은 0단계뿐 아니라, §47의 6단계 나선 어느 도메인이든 착수 전(1단계 직전, 또는 3단계 인접도메인 대조 시) Cursor에게 증거수집을 맡길 때 표준으로 재사용한다.

---

## 49. 개발자 역량 강화 로드맵 (2026-07 확정)

**원칙**: 암기가 아니라 "오늘 발견한 실제 문제를 스스로 다시 설명할 수 있는가"가 학습 완료의 확인 기준이다. 각 항목은 이 프로젝트 자체의 실제 결함/발견에 앵커링되어 있다.

### 49.1 학습 순서

1순위 **우선순위2**(인증/인가, 가장 새롭고 다음 나선 0-C에 바로 필요) → 2순위 **우선순위1 나머지 항목**(0단계 진행하며 자연습득) → 3순위 **우선순위3**(대부분 이미 체험, 복습) → 4순위 **우선순위4**(가장 가볍게).

### 49.2 우선순위1: PostgreSQL과 데이터 정합성 (기존 DBA경력 최대 활용 영역)

- **PK/FK/UNIQUE/CHECK**: `chk_ledger_status`(8개값)를 DBeaver로 직접 열어보고 왜 `REFUND_PENDING`을 거부했는지 설명.
- **Transaction과 Lock**: `ADD COLUMN`을 `CREATE OR REPLACE`보다 먼저 해야 하는 이유(PL/pgSQL 지연바인딩)를 실제 순서를 바꿔 재현.
- **Idempotency**: 웹훅 멱등성 공백을 직접 고쳐보며 `idempotency_keys` 구조 이해.
- **RLS와 권한**: `current_tenant_id()`가 JWT에서 값을 가져오는 코드 직접 읽기.
- **JSONB 사용경계**: `payment_events.event_payload` 패턴 직접 SELECT.
- **함수 오버로드**: 레거시 함수 DROP+재생성 패턴을 migration diff로 확인.
- **Trigger의 책임**: trigger vs RPC내부처리 언제 뭘 쓸지 0단계 설계하며 직접 정하기.
- **Ledger와 상태스냅샷**: mutable vs WORM원장 논쟁을 본인 언어로 정리.
- **Migration 전진호환성**: 배포된 migration 수정 금지 원칙 설명 가능하기.

### 49.3 우선순위2: API와 인증·인가 (최우선 학습 — 가장 새로운 영역)

- **인증 vs 인가 차이**: `staff_login()`(인증) vs `check_staff_permission()`(인가) 구분.
- **JWT/session/caller 맥락**: `current_actor_id()`의 JWT 'sub' 읽는 방식, 실제 JWT를 jwt.io 등으로 직접 디코딩해보기.
- **tenant/store scope**: RLS 정책의 `tenant_id` 사용법, 왜 클라이언트가 `tenant_id`를 파라미터로 보내면 안 되는지.
- **서비스계정(SECURITY DEFINER/service_role)**: `authenticated` vs `service_role` 전용 GRANT 패턴.
- **RPC 호출경계(클라이언트 비신뢰)**: 0-C 나선에서 직접 설계하며 학습.

### 49.4 우선순위3: 테스트와 관측성 (이미 상당부분 체험, 복습위주)

- 단위/통합테스트, DB replay, 상태전이테스트, 로그/에러코드, 감사기록, 재현가능한 실패fixture.

### 49.5 우선순위4: 프론트엔드 (가장 가볍게, 판단력만)

- 화면상태 출처, 서버상태 vs 로컬상태, 중복제출방지, 권한없는 버튼숨김 vs 서버거부, 오류/재시도/로딩표시.

### 49.6 향후 보강 예정 항목 (지금은 만들지 않음, 필요 시점에 추가)

1. 외부연동(POS/PG) 표준 체크리스트 — POS 붙이기 직전에 명문화.
2. 운영데이터 존재 이후 마이그레이션 backfill 전략 — 매장오픈 직전에 명문화.
3. 라이브 장애 감지/알림 체계 — 1-4(KDS/DID) 완료 시점에 함께.
4. 나선 종료시 회귀(regression) 확인 — 도메인이 5-6개 넘어갈 때 추가.
5. **주의**: 규칙을 한꺼번에 다 추가하지 말 것. "규칙이 많아지면 AI도 사람도 지키지 못한다"는 원칙을 지킨다.
