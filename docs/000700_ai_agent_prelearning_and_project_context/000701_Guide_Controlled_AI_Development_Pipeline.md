# 000701_Guide_Controlled_AI_Development_Pipeline.md

Former File Name:

`051355_Guide_AI_Assisted_Financial_Grade_Development_Pipeline_Cursor_Claude_Codex_Automated_Gate_And_Human_Merge.md`

Canonical Location:

`docs/000700_ai_agent_prelearning_and_project_context/`

Governance Classification:

Implementation Lifecycle Foundation / Controlled AI Development Pipeline

Runtime Implementation Authorization:

Not Granted

SOP Status:

Foundation governance guide, not yet promoted to mandatory `sop/system` document.

As of 2026-07-10, Cursor and Codex are reintroduced as subordinate execution/scan tools under Claude's full governance — they hold NO authority to self-approve, self-stage, or self-commit anything. Every Cursor/Codex output is independently re-verified by a different model (Claude Code) before Claude's Final Audit (Stage 11 as of the 2026-07-16 thirteen-stage restructure, §3) accepts it. This is a deliberate cross-model diversity safeguard (see §26 Adversarial Audit Pass Requirement) against shared blind spots if verification stayed entirely within one model family — it is not a return to unsupervised GPT authority, which remains permanently revoked.

## 1. Purpose

This guide defines the AI-assisted financial-grade development pipeline for `yoonsul_wait_order_handoff`.

The goal is to combine Claude Code execution, Claude governance and independent audit, automated verification, and human approval into one controlled development process that can support a financial-grade SaaS system where:

- Code remains simple and readable.
- Money-moving logic remains explicit.
- Financial state transitions remain idempotent.
- Provider, POS, PG/VAN, bank, payout, settlement, reconciliation, audit, and evidence logic remain traceable.
- AI tools are used by role, not trusted blindly.
- Every implementation leaves enough documentation and evidence to debug, audit, or roll back later.
- A 3,000-document-scale project can still move quickly without losing control of scope, testability, or financial correctness.

This document is not a general AI development guide. It is a project governance guide for operating a controlled implementation loop in a financial-grade POS/order/payment/runtime environment.

Revision emphasis for this version:

- **(2026-07-16, 재논의 금지)** §3 was rebuilt from an eight-stage (1/1.5/2/3/4/5/5.5/6/7) loop into a thirteen-stage (0-12) loop, folding the previously ad hoc §34-§40 multi-actor verification practices (tiered Architecture/Contract/Independent Verification, Antigravity's non-binding parallel role) directly into the numbered pipeline, and adding a new explicit Documentation stage (10) between independent verification and final audit. This formalizes practices that had already drifted into actual use and closes the verification gaps that drift had caused — see §3 for the full mapping and rationale.
- The guide is treated as a candidate top-level system SOP / development constitution.
- The pipeline runs as an explicit thirteen-stage (0-12) loop for Medium/Full tier changes (see §3, §31). The Lightweight track (§24) is unaffected and remains log-only. Human Approval is a standalone Stage 7.
- The human approval record (the Human Boundary Approval section inside `ChangeContract.md`) remains mandatory before Codex touches code.
- Context Snapshot injection is mandatory before Claude's Stage 3 design review.
- Raw terminal logs and git diff must be handed to Claude without AI summarization.
- Allowed Operations must be narrower than Allowed Files.
- Every audit and evidence artifact must map back to the active `CHANGE_ID`.
- MVV may not be used for RLS, database migration, financial, provider, audit, evidence, access-control, or production-release changes.
- Context Snapshot must be dieted by cheat sheets, domain slicing, and Claude Code-discovered rule references so Claude receives only the relevant rule boundary.
- Full master rules are governance anchors; AI injection should prefer short rule summaries unless a conflict or audit requires the full document.
- Stage 1/2 (Cursor scan, Claude Code verification and design draft) must discover not only affected code and docs, but also the minimal rule files needed for Stage 3.
- Stage 9 raw logs (Claude Code's cross-model re-verification of Codex's Stage 8 implementation) should be saved to `raw_logs/` by shell redirection or task scripts so Claude can audit exact terminal output without copy-paste loss.
- Each major domain folder should maintain a thin `<Domain>RulesSummary.md` cheat sheet so future development uses sliced context instead of dumping thousands of planning documents.
- When this guide is adopted as mandatory governance, it should be placed under `sop/system/` and treated as the project development constitution.
- Role split revision (2026-07-08, superseded 2026-07-10, restructured again 2026-07-16 — see §3): design verification, contract drafting, and contract verification are now separate stages (3, 5, 6) rather than one combined stage. Human Approval (now Stage 7) remains a standalone gate that must exist before implementation may begin. Claude's Final Audit (now Stage 11) remains the independent audit stage, producing the confirm/audit output (`AuditReview.md`) — the implementer's `ImplementationModule.md` (Stage 8) is a self-report, not a completion proof, and is not binding until Stage 11 audits it.
- Sections 25-29 were added after this session's SQL migration verification pass revealed that internally consistent documentation chains can still diverge completely from actual system state — these sections require reality-checking, adversarial review, effort-prioritization toward substantive verification, and durable decision logging as structural corrections, not optional best practices.
- Role split revision (2026-07-10, stage numbers updated 2026-07-16): Cursor and Codex are reintroduced under Claude's full governance (see the notice above and §2, §3). Stage 1 (Cursor) is scope/inventory search only — no drafting, no editing. Stage 2 (Claude Code) verifies Cursor's scope and drafts `Overview.md`/`Logic.md`. Stage 8 (Codex) implements strictly within the approved `ChangeContract.md` boundary. Stage 9 (Claude Code, plus Cursor under Critical tier) independently re-verifies Codex's implementation — this is a cross-model check, not self-verification, since Claude Code did not write the implementation. Under Critical tier, Cursor's participation in Stage 9 produces a non-binding `MinorOpinion.md`, which Stage 11 must explicitly address (see §31 for tier applicability, §32 for the per-domain NavigationMap that tracks tier and status per change).

---

## 2. Operating Thesis

The project uses AI tools as a divided-control development system, with five core actors under one governance authority (Claude), plus Antigravity as a non-authoritative observer-tier participant (§40).

```text
Cursor scans and reports (no drafting, no editing).
Claude Code verifies the scan and drafts the design.
Claude reviews the draft and sets the verification tier.
Codex and/or Cursor verify the architecture; Claude integrates.
Claude Code drafts the contract.
Codex and/or Cursor verify the contract; Claude integrates.
Human approves the boundary.
Codex implements strictly inside the boundary.
Claude Code (plus Cursor under Critical tier) independently re-verifies Codex's implementation.
Codex and Claude Code document the change.
Claude judges (does not trust any prior self-report).
Human owns merge and release.
```

No single AI tool is allowed to be trusted as the final authority. Cursor and Codex additionally hold no authority to self-approve, self-stage, or self-commit anything — every output either tool produces passes through at least one different model's independent re-verification before Claude's Stage 11 audit can accept it (see the notice near §1 and §26 Adversarial Audit Pass Requirement).

Claude Code's design draft is not binding by itself. `Overview.md` and `Logic.md` only become the approved design once Claude has reviewed them in Stage 3 and Stage 4's architecture verification has passed — Claude Code drafting first does not remove Claude's role as design authority, it only changes who produces the first draft. The same non-binding principle applies to Codex's implementation and Cursor's scan/opinion: nothing either of them produces is treated as ground truth until a different model has independently re-checked it.

The pipeline is designed around the following authority split:

| Party | Authority And Responsibility |
|---|---|
| Cursor | Stage 1 scope/inventory scan (search, dependency discovery only — no editing, no design authority). Under Critical tier, participates in Stage 4 (architecture verification), Stage 6 (contract verification), and Stage 9 (independent verification), producing a non-binding `MinorOpinion.md` where applicable. Cursor cannot block, approve, or require changes at any stage. |
| Claude Code | Stage 2: verifies/corrects Cursor's scope, drafts `Overview.md`/`Logic.md`. Stage 5: drafts `TestPlan.md`/`ChangeContract.md`. Stage 9: independently re-verifies Codex's implementation (cross-model check, not self-verification) and produces `VerificationResult.md` with raw evidence capture. Stage 10: produces the important documentation (`Verification.md`, draft `Audit.md`). |
| Claude | First-pass design review and tier decision (Stage 3), integrates Stage 4/Stage 6 multi-actor verification results, governance review, and mandatory independent Final Audit of raw diffs and logs (Stage 11). Claude does not trust Cursor's scan, Codex's self-report, or Claude Code's verification report at face value — Stage 11 re-derives key claims. Final ACCEPT/REJECT authority rests solely with Claude. |
| Codex | Stage 8: isolated implementation strictly within the human-approved `ChangeContract.md` boundary. Under Normal/Critical tier, also participates in Stage 4 and Stage 6 verification (never of its own output). Stage 10: produces simple documentation (`Module.md`, `NavigationMap.md`/index updates). Codex's `ImplementationModule.md` is a self-report, not a completion proof, and is not binding until Stage 9 (Claude Code) and Stage 11 (Claude) both review it. |
| Antigravity | Non-binding parallel participant in Stage 1, 4, 6, and 9 during the observer period (§40) — reference only, never counted toward a PASS/FAIL verdict. |
| Human | Stage 7 boundary approval, final merge, release, and production risk acceptance (Stage 12). |

The resulting process is a thirteen-stage (0-12) integrity loop for Medium/Full tier changes (§3, §31); the Lightweight track (§24) remains a shorter, log-only path.

---

## 3. Thirteen-Stage (0–12) Integrity Loop

**(2026-07-16 전면 개정, Human 결정, 재논의 금지)** As of 2026-07-16 this is a thirteen-stage loop (Stage 0 through Stage 12) for Medium/Full tier changes (§31), superseding the eight-stage (Stage 1 / 1.5 / 2 / 3 / 4 / 5 / 5.5 / 6 / 7) structure that had been in effect since 2026-07-10. The Lightweight track (§24) is unaffected and stays log-only.

This revision exists because the eight-stage structure had drifted from actual session practice ("Stage 2 = Codex writes TestPlan", "Stage 5 = Cursor+Antigravity parallel run treated as formal verification"), and that drift itself caused verification gaps. The original eight-stage spirit — author ≠ verifier, a mandatory human gate, and Claude's sole final ACCEPT/REJECT authority — is preserved. What changes is the stage count and boundaries: the multi-actor architecture/contract verification rules that had already accumulated as informal add-ons (§34-§40 — Actor Selection, Cross-Actor Verification Expansion, Design-Implementation Double Cross-Verification, Mandatory Dual Verification, Verification Intensity Tiering, the Antigravity Observer Period) are now folded directly into the numbered pipeline instead of sitting as an unnumbered layer on top of an eight-stage skeleton that no longer matched how the pipeline actually ran.

```text
[0] Issue Discovery / Fact Scan (Non-Regular)
    - 생산자: 누구든 (Human / Cursor / Codex / Claude Code / Antigravity)
    - 검증: 없음 — 경량, 비정기 발생. 정규 사이클(Stage 1) 진입 전 자유 조사 단계.
    - Output: Issue Record (선택, 형식 자유)

    ↓ optional handoff into the regular cycle

[1] Scan -> "Eyes Only"
    - 생산자: Cursor (Eyes Only, 검색/보고만, 설계·구현 금지)
    - 병행: Antigravity [참고용, 비구속 — §40 관찰 기간 원칙 그대로]
    - 절대 구현 코드 작성 금지, 절대 설계 문서 초안 작성 금지 (검색/보고만)
    - 아키텍처/DB/RLS/네이밍 신규 표준 결정 금지 — 불확실하면 "Open Question" 표시
    - Output: raw scope/inventory report

    ↓ scan handoff

[2] Design Draft -> "Drafting Hands"
    - 생산자: Claude Code
    - Cursor의 스캔 결과를 직접 검증(누락된 파일/의존성/RLS/migration 확인)한 뒤 ImpactScope.md를 확정하고 초안을 작성
    - Output: Overview.md, Logic.md (draft)
    - 금지: 구현 코드 작성, 신규 아키텍처/DB/RLS/네이밍 표준 확정 (불확실하면 Open Question 표시)

    ↓ draft handoff

[3] Claude First-Pass Review + Critical/Normal Tier Decision -> "Brain"
    - 담당: Claude (저)
    - 내용: Overview.md/Logic.md를 직접 검토, 위험도(Critical/Normal) 판단 후 Stage 4 검증자 구성을 결정
    - Output: 검토 코멘트 + tier 판정

    ↓ tier decision handoff

[4] Architecture Verification
    - 검증 (Normal tier): Codex + Antigravity [참고용]
    - 검증 (Critical tier): Cursor + Codex + Antigravity [참고용]
    - 담당: Claude(저)가 결과 통합/판단 → Human 확인
    - Output: Architecture Review (raw 검증 결과 통합)

    ↓ verified design handoff

[5] Contract Drafting -> "Drafting Hands"
    - 생산자: Claude Code
    - Output: TestPlan.md, ChangeContract.md

    ↓ contract handoff

[6] Contract Verification (§37 — 원작자인 Claude Code는 검증자에서 제외)
    - 검증 (Normal tier): Codex + Antigravity [참고용]
    - 검증 (Critical tier): Cursor + Codex + Antigravity [참고용]
    - 담당: Claude(저)가 결과 통합/판단

    ↓ verified contract handoff

[7] Human Approval Gate -> "Owner (Gate)"
    - 담당: Human
    - Overview.md / Logic.md / TestPlan.md / ChangeContract.md 검토, 허용/금지 파일 확정
    - Output: ChangeContract.md (Human Boundary Approval 섹션 완료)

    ↓ approved boundary handoff

[8] Implementation -> "Hands"
    - 생산자: Codex (승인된 ChangeContract.md 바운더리 내부에서만, 엄격 준수, 작은 diff 유지, 불필요한 리팩토링 금지)
    - Codex는 자기 구현을 스스로 승인/커밋할 권한 없음
    - Output: code diff + ImplementationModule.md (자기보고서, 완료 증명 아님)

    ↓ raw verification handoff

[9] Independent Verification (§37 — 원작자인 Codex는 검증자에서 제외)
    - 검증 (Normal tier): Claude Code + Antigravity [참고용]
    - 검증 (Critical tier): Claude Code + Cursor + Antigravity [참고용]
    - 담당: Claude(저)가 결과 통합/판단
    - Output: VerificationResult.md + raw logs + git diff (Critical tier에서 Cursor가 참여한 경우 MinorOpinion.md도 포함)

    ↓ documentation handoff

[10] Documentation
    - Codex: 간단 문서 (Module.md, NavigationMap 갱신, 000005/000007 색인 등록)
    - Claude Code: 중요 문서 (Verification.md, Audit.md 초안)
    - Output: 갱신된 Module/NavigationMap/색인 문서 + Verification.md + Audit.md 초안

    ↓ audit handoff

[11] Final Audit -> "Judge"
    - 담당: Claude(저) 단독. 최종 ACCEPT/REJECT 권한은 오직 Claude에게만 있음
    - ImplementationModule.md / VerificationResult.md / Module.md / Verification.md / Audit.md 초안을 액면 그대로 신뢰하지 않고 핵심 주장 재도출, raw git diff 직접 검토
    - 금융 사고 반례 시나리오 교차 감사
    - Output: AuditReview.md (ACCEPT / APPROVE_WITH_NOTES / BLOCK)

    ↓ owner decision handoff

[12] Human Merge / Release -> "Owner"
    - 담당: Human
    - 최종 diff 확인, AuditReview.md 확인, unresolved BLOCK 없음 확인, commit / merge / release 승인
    - Output: ReleaseEvidence.md (선택) 또는 커밋 자체
```

This is the explicit thirteen-stage form (Medium/Full tier). Stage 0 is non-regular and may be skipped entirely for a given change — it exists only to let any actor record a finding before the regular cycle starts. Stage 10 (Documentation) is new relative to the eight-stage structure: it did not previously exist as a numbered gate, and the artifacts it produces (`Module.md` / `NavigationMap.md` / `000005`/`000007` index registration, `Verification.md`, `Audit.md` draft) previously existed only as background governance requirements (§30, §32) with no explicit stage boundary between independent verification and final audit. Stages 3, 4, 5, and 6 replace the old Stage 2's combined "verify the design, then lock the contract" role with four separate steps — first-pass review and tiering (3), multi-actor architecture verification (4), contract drafting (5), and multi-actor contract verification (6) — because the single old Stage 2 had, in practice, already been supplemented by the ad hoc §34-§40 multi-actor rules; this revision folds that reality into the stage numbering itself. `ImplementationModule.md` (Stage 8) remains a self-report, not a completion proof — it is not binding until Stage 9's independent re-verification and Stage 11's audit both review it against `VerificationResult.md` and the raw `git diff`.

### 3.1 Antigravity Principle (Applies To Stages 1, 4, 6, And 9)

1/4/6/9단계 모두 병행 지시가 기본값이며, Antigravity의 결과는 어디서든 "참고용, 비구속" — 정식 PASS/FAIL 판정에 영향을 주지 않는다. 관찰 기간 종료 전까지 "Cursor"/"Codex" 표기를 Antigravity로 대체하지 않는다 (§40 원칙 그대로 유지).

---

## 4. Core Rule

```text
No AI edits without scope.
No design draft without a Claude Code-verified Cursor scope.
No test plan without Claude-verified design.
No implementation without a recorded human approval.
No implementation outside the approved ChangeContract.md boundary.
No verification without raw logs.
No audit without git diff, VerificationResult.md, and MinorOpinion.md.
No merge without human owner decision.
No financial change without evidence.
```

The final authority for financial correctness is not an AI answer.

The final authority is the combined evidence of:

1. Claude Code impact scope.
2. Claude design pack.
3. Human-approved file boundary.
4. Claude Code limited implementation.
5. Mechanical verification output.
6. Raw logs and git diff.
7. Claude independent audit.
8. Human merge and release decision.
9. Release evidence.

---

## 5. Stage Output Map

**(2026-07-16 개정)** Rebuilt for the thirteen-stage (0-12) structure (§3); supersedes the eight-stage (1/1.5/2/3/4/5/5.5/6/7) version of this table.

| Stage | Owner | Role Name | Main Output | Main Risk Controlled |
|---:|---|---|---|---|
| 0 | Anyone | Fact Scanner (Non-Regular) | Issue Record (optional) | Early findings lost or re-discovered later at higher cost; no gate, so no risk controlled by verification — only a capture point |
| 1 | Cursor (+ Antigravity, reference only) | Eyes Only | Raw scope/inventory report (search only, no drafting, no editing) | Wrong file scope, missed dependency, hidden test/RLS/migration impact |
| 2 | Claude Code | Drafting Hands | `Overview.md` (draft), `Logic.md` (draft) | Cursor's raw scan trusted uncritically; unverified design draft mistaken for final |
| 3 | Claude | Brain (First-Pass Review + Tier Decision) | Review comments + Critical/Normal tier verdict | Wrong verifier composition assigned to Stage 4/6/9; risk level misjudged before design proceeds |
| 4 | Codex + Antigravity (Normal) / Cursor + Codex + Antigravity (Critical) — Claude integrates | Architecture Verification | Architecture Review (integrated raw verification results) | Poor design, hidden financial risk, ambiguous scope silently accepted from a single reviewer's blind spot |
| 5 | Claude Code | Drafting Hands (Contract) | `TestPlan.md`, draft `ChangeContract.md` | Contract drafted without a verified design; tests scoped to the wrong risk surface |
| 6 | Codex + Antigravity (Normal) / Cursor + Codex + Antigravity (Critical) — Claude integrates | Contract Verification (§37: Claude Code excluded, as contract author) | Verified `TestPlan.md`/`ChangeContract.md` | Contract boundary too broad/narrow, missing rollback or test coverage, self-authored contract unchecked |
| 7 | Human | Owner (Gate) | `ChangeContract.md` (Human Boundary Approval section filled in) | Codex starting on an unapproved or ambiguous file boundary |
| 8 | Codex | Hands | Code diff, `ImplementationModule.md` | Incorrect implementation, broad refactor, unauthorized changes, self-report mistaken for completion proof, implementation outside the approved boundary |
| 9 | Claude Code + Antigravity (Normal) / Claude Code + Cursor + Antigravity (Critical) — Claude integrates (§37: Codex excluded, as implementer) | Independent Verification | `VerificationResult.md`, raw logs, git diff (+ `MinorOpinion.md` when Cursor participates under Critical tier) | Type errors, test failures, migration/RLS/security gaps hidden by summaries; Codex's self-report trusted without independent re-verification; blind spots shared by a single verifier |
| 10 | Codex (simple docs) / Claude Code (important docs) | Documentation | `Module.md`, `NavigationMap.md`/index updates (Codex); `Verification.md`, draft `Audit.md` (Claude Code) | Implementation lands without traceable module/index records; audit proceeds without a documentation trail |
| 11 | Claude | Judge | `AuditReview.md` (ACCEPT / APPROVE_WITH_NOTES / BLOCK) | Logic mismatch, financial accident scenario, evidence gap, false confidence, unaudited self-report treated as final, a raised concern silently ignored |
| 12 | Human | Owner | Commit, merge, `ReleaseEvidence.md` (optional) | Blind merge, uncontrolled production release, unowned risk |

---

## 6. Mandatory Context Snapshot Between Stage 2 And Stage 3

**(2026-07-16 번호 정합화)** Old Stage 1.5 (Claude Code verify+draft) is now Stage 2; old Stage 2 (Claude design review) is now Stage 3 — see §3.

As of 2026-07-10, Stage 1 (Cursor's raw scan) is not itself the handoff point — Cursor has no drafting authority and its raw scan is search-only. The context snapshot referenced throughout this section is assembled after Claude Code's Stage 2 verification of that scan, at the Stage 2-to-Stage 3 boundary. References to "Stage 1" below mean the combined Stage 1 (Cursor scan) + Stage 2 (Claude Code verification/draft) unless otherwise noted.

### 6.1 Why This Exists

In a 3,000-document repository, an impact scope report alone is not enough.

If Claude receives only `ImpactScope.md` and a change request, it may design a solution that is locally plausible but globally inconsistent with project architecture, naming rules, file conventions, DB constraints, RLS policy patterns, evidence rules, or financial safety rules.

However, the opposite failure is also dangerous.

If every design cycle injects the entire rule base, Claude may suffer from context bloat, irrelevant-rule fixation, and lost-in-the-middle behavior. Token cost increases, attention quality drops, and the current module's core risk may be diluted by unrelated governance text.

Therefore, the context snapshot must not mean "dump every rule document." It means "inject the smallest rule-complete bundle needed for this change."

### 6.2 Context Snapshot Diet Rule

When moving from Claude Code Stage 2 to Claude Stage 3, always provide a context snapshot bundle.

The bundle must be:

- Complete enough to prevent architecture drift.
- Small enough to prevent token bloat.
- Traceable enough to explain why each rule file was included.
- Explicit enough to state which rules were excluded and why.

The preferred order is:

```text
1. ImpactScope.md
2. current user requirement / change request
3. master index or master rule anchor
4. short rule summaries / cheat sheets matched to the module
5. domain index or module index matched to the module
6. only the full rule documents needed because the summary is insufficient
7. related SOP / Policy / Matrix / Checklist references discovered by Stage 1
```

The snapshot must not include every document in the repository.

### 6.3 Master Rule Cheat Sheet Rule

Every large governance rule document should have a short AI-injection summary.

Recommended pattern. The full governance rule keeps this project's normal six-digit doc-naming convention (000002_Naming_Rules.md); only the pipeline-generated AI-injection summary uses the PascalCase-joined pipeline-artifact convention (see §33):

```text
Full governance rule (project doc-naming convention):
  NNNNNN_Guide_<Domain>_Policy.md

AI injection summary (pipeline artifact convention):
  <Domain>RulesSummary.md
```

Example:

```text
Full rule:
  000900_Guide_RLS_Policy.md

Summary injected into context snapshot:
  RlsRulesSummary.md
```

The summary should be roughly 20 to 40 lines and contain only:

- Non-negotiable constraints.
- Naming and placement rules.
- Forbidden operations.
- Required tests or evidence.
- Escalation triggers requiring the full document.

The full governance document remains the source of truth, but Stage 3 should normally receive the summary unless the change touches a high-risk boundary or the summary flags a need to inspect the full rule.

### 6.4 Context Slicing Matrix

The context snapshot must be sliced by the current module's domain tags.

Claude should receive only the master rules that match the module being implemented.

| Current Development Target | Required Context Slots | Usually Excluded To Save Tokens |
|---|---|---|
| POS integration / API Gateway | API route contract, provider boundary, idempotency, webhook signature, callback ordering, evidence summary | Flutter UI component guide, broad DB migration guide unless schema changes, unrelated settlement deep rules |
| Payment / Cancel / Refund | financial state machine, idempotency, duplicate prevention, provider timeout/unknown status, audit ledger, evidence packet, customer/store finality | UI layout rules, unrelated admin console rules, non-payment provider docs |
| Supabase / DB / Migration | DB constraints, migration rule summary, RLS/security summary, tenant isolation, rollback and dry-run rules | Flutter UI rules, provider API guide unless provider callbacks write DB |
| RLS / Access Control | RLS summary, permission matrix, tenant isolation, break-glass, audit/evidence, least-privilege rules | UI design guide, payment provider mapping unless money state is involved |
| Flutter UI / State Management | Flutter state transition rules, screen composition guide, user message finality rule, API client contract | DB migration guide, settlement/reconciliation rules, bank payout deep rules |
| Audit / Evidence / Release | audit ledger rule, evidence packet rule, CHANGE_ID rule, retention/redaction/legal hold summary, release evidence guide | UI layout rules, unrelated provider docs |
| Settlement / Reconciliation / Payout | settlement control totals, reconciliation exception handling, payout/bank unknown status, maker-checker, evidence and audit rules | Flutter UI guide, generic screen composition docs |
| Documentation-only change | naming rule summary, index placement, cross-linking rule, H1/filename rule, archive rule | runtime code rules, RLS guide, DB migration guide unless referenced |

If the module has multiple domain tags, include the union of the required context slots, but still prefer summaries over full documents.

### 6.5 Claude Code-Assisted Rule Filtering

Cursor's Stage 1 raw scan should surface candidate rule/SOP/policy references alongside code/SQL/test files, but curating those candidates into the minimal rule set Stage 3 actually needs is a judgment call, not a search task — it belongs to Claude Code's Stage 2 verification pass, not Cursor's Stage 1 scan.

Claude Code must not only find code, SQL, tests, and documents. It must also identify the minimal rule files needed for Stage 3.

Stage 2 must ask:

```text
Which master index, domain index, rule summary, SOP, Policy, Matrix, Checklist, or governance file must Claude receive to design this change safely?
```

The result should be written into `ImpactScope.md` under a dedicated section:

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

This allows Stage 2 to act as the first context filter. Stage 3 then consumes only the filtered snapshot rather than the entire 3,000-document base.

### 6.6 Context Snapshot Output

As of 2026-07-10, the context snapshot is no longer a separate file — it is folded into `ImpactScope.md`'s "Required Context Snapshot Candidates" section and related fields (Module Domain Tags, Context Budget Decision, Known Gaps, Snapshot Decision), produced by Claude Code in Stage 2. See 8.8 for the full template. This section previously described a standalone `context_snapshot.md`; that file no longer exists as a separate artifact.

The handoff from Stage 2 to Stage 3 is `ImpactScope.md` itself — there is no second manifest file to produce.

### 6.7 Stage 3 Prompt Requirement

Claude must be told:

```text
Use the context snapshot as the project rule boundary.
Do not redesign naming conventions, DB conventions, RLS conventions, evidence conventions, or architecture standards.
Use only the included rule summaries and full rules unless you explicitly identify a missing rule gap.
If the local change conflicts with the master rules, flag the conflict instead of silently changing the standard.
If the snapshot appears bloated or irrelevant, list the irrelevant context and proceed only with the required rules.
If the snapshot appears too thin, block and request the missing rule family before design.
```

### 6.8 Rule Summary File Template

Each high-value domain should have one thin summary file.

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

Recommended summary targets (PascalCase-joined, §33):

- `CodeConventionRulesSummary.md`
- `DbConstraintAndMigrationRulesSummary.md`
- `RlsAndSecurityRulesSummary.md`
- `FinancialIdempotencyAndDuplicatePreventionRulesSummary.md`
- `AuditLedgerAndEvidencePacketRulesSummary.md`
- `PosGatewayAndProviderCallbackRulesSummary.md`
- `FlutterUiStateAndFinalityMessageRulesSummary.md`
- `DocumentationNamingIndexAndCrosslinkRulesSummary.md`

### 6.8.1 Domain Folder Summary Rule For The Remaining Document Buildout

When new planning, policy, SOP, or implementation-readiness documents are added at scale, each major domain folder should also carry one thin rule summary file.

The purpose is not to duplicate the full documents. The purpose is to give Stage 1 an easy file to discover and Stage 3 a small rule packet to consume.

Recommended placement pattern:

```text
<domain_folder>/
  <Domain>RulesSummary.md
  <domain>_Index.md
  <full planning / policy / SOP documents...>
```

Minimum contents for each domain summary:

- when this domain applies;
- non-negotiable runtime or documentation constraints;
- files or operations that require escalation;
- required tests or evidence;
- the full-rule source paths;
- rule families that are usually excluded for this domain.

For the remaining 1,500-document buildout, these summaries should be created alongside the domain folders rather than postponed until implementation. A 30-line rule summary can prevent later token bloat, wrong-context design, and architecture drift.

### 6.9 Context Anti-Patterns

Forbidden snapshot behavior:

- Injecting the entire docs tree.
- Injecting a large full rule when a summary would suffice.
- Injecting UI rules into DB-only changes without UI impact.
- Injecting migration rules into documentation-only changes.
- Injecting every payment, settlement, payout, and reconciliation rule into a simple Flutter UI copy change.
- Omitting idempotency and audit summaries for money-moving changes.
- Omitting RLS summaries for tenant/access-control changes.
- Allowing Claude to infer project standards from one local file when master summaries exist.

### 6.10 Context Diet Operating Rule

```text
The context snapshot is not a document dump.
It is a filtered rule packet.

Master index anchors the project.
Rule summaries carry the daily constraints.
Domain slicing keeps attention focused.
Claude Code discovers candidate rule files.
Claude designs only inside the selected rule boundary.
```

---

## 6.11 CHANGE_ID Traceability Rule

Every document, code comment where appropriate, audit ledger event, evidence packet, verification result, and release record must carry the same active `CHANGE_ID`.

The `CHANGE_ID` is the spine of the implementation packet.

Required mapping:

| Artifact | Required `CHANGE_ID` Position | Failure Meaning |
|---|---|---|
| `ImpactScope.md` (merged scope + context snapshot) | `## Change ID` | Scope cannot be tied to implementation, or Claude may use wrong master rules. |
| `Overview.md` | `## Change ID` | Business purpose cannot be audited. |
| `Logic.md` | `## Change ID` | Runtime logic cannot be tied to implementation. |
| `TestPlan.md` | `## Change ID` | Tests cannot be proven relevant. |
| `ChangeContract.md` (merged contract + human approval) | `## Change ID` | Approval scope cannot be enforced. |
| `ImplementationModule.md` | `## Change ID` | Code diff cannot be tied to contract. |
| `VerificationResult.md` | `## Change ID` | Raw log cannot be tied to diff. |
| `MinorOpinion.md` (Medium/Full tier) | `## Change ID` | Second-opinion concerns cannot be tied to the change under audit. |
| `AuditReview.md` | `## Change ID` | Audit cannot approve the correct change. |
| audit ledger event | `change_id` or equivalent metadata | Runtime event cannot be traced. |
| evidence packet manifest | `change_id` field | Evidence cannot be found later. |
| `ReleaseEvidence.md` (merged release evidence + merge checklist) | `Change ID:` | Release cannot be reconstructed. |

If any artifact has a missing, conflicting, or stale `CHANGE_ID`, the pipeline must stop.

This is not a documentation defect.

It is an auditability failure.

---

## 7. Mandatory Raw Log And Git Diff Handoff Between Stage 9 And Stage 11

**(2026-07-16 번호 정합화)** Old Stage 5/5.5/6 are now Stage 9/9 (Critical tier)/11 — see §3. As of 2026-07-10, when Critical tier applies, this handoff passes through Cursor's non-binding minor-opinion review within Stage 9 (Medium/Full tier only) before reaching Stage 11. Cursor receives the same raw evidence package described below, plus `ChangeContract.md` and the code diff — see §12.9 for the Critical-tier minor-opinion rules. Stage 11 Claude still receives everything Stage 9 produced directly; Cursor's Critical-tier participation does not filter or gate what reaches Stage 11, it only adds `MinorOpinion.md` to the package.

### 7.1 Why This Exists

Stage 9 is a mechanical verification stage, not a judgment stage. As of 2026-07-10, Stage 9 is performed by Claude Code independently re-verifying Codex's Stage 8 implementation — a cross-model check, not self-verification.

If a command fails and the failure is summarized by Claude Code or another AI tool, the most important details may be lost:

- exact type error line;
- migration failure line;
- RLS violation output;
- failed assertion;
- duplicate-key constraint detail;
- unauthorized file drift;
- encoding drift;
- formatter side effect;
- stack trace showing wrong module boundary.

For this reason, Stage 11 Claude Audit must receive raw terminal output and raw `git diff`, not only a friendly summary.

### 7.2 Raw Handoff Rule

The Stage 9 output must include:

```text
1. VerificationResult.md
2. full raw terminal log for every failed command
3. full command list actually executed
4. git diff --stat
5. git diff --check
6. git diff --name-only
7. full git diff or scoped git diff for approved files
8. list of files changed outside allowed scope, if any
9. migration dry-run output, if applicable
10. RLS/security check output, if applicable
```

### 7.3 Claude Code Must Not Hide Errors

Claude Code must not be asked:

```text
Did it succeed?
Can you fix it?
Summarize the error briefly.
```

Claude Code must be asked:

```text
Run the exact commands.
Do not modify files.
Do not auto-fix.
Do not summarize away errors.
Return the raw terminal output.
If a command fails, stop and preserve the full output.
```

### 7.4 Raw Log Storage

Recommended folder shape:

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

### 7.4.1 Raw Log Automation Rule

Raw logs should be captured by command redirection or a repeatable local task script whenever possible.

The owner should not rely on manual copy-paste from a terminal window for high-risk changes. Manual copying can truncate stack traces, omit the first failing line, or accidentally summarize away the exact failure Claude needs to audit.

Example shell pattern:

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

Project-specific commands may be added for Supabase, RLS, SQL constraints, idempotency, provider callbacks, and audit/evidence checks.

For financial, RLS, migration, provider, payout, settlement, audit, or release changes, the raw log folder is mandatory evidence, not a convenience.

### 7.5 Stage 11 Audit Input Rule

Claude Audit must receive `raw_logs/`, `git diff`, and (Medium/Full tier) `MinorOpinion.md` directly.

Claude must not rely on `VerificationResult.md` alone, and must not rely on Codex's `ImplementationModule.md` self-report alone. Every concern raised in `MinorOpinion.md` must be explicitly addressed — accepted, investigated further, or dismissed with a stated reason — never silently ignored (see §12.9 and §32).

---

## 8. Stage 1 (Cursor) And Stage 2 (Claude Code) — Scope Scan And Design Draft

As of 2026-07-10, this section covers two separate pipeline stages under one heading to avoid renumbering every downstream section: **Stage 1** is Cursor's raw scope/inventory scan (search only, no drafting authority). **Stage 2** is Claude Code's verification of that scan plus the design draft. Subsections 8.1-8.4 cover Stage 1 (Cursor); 8.5-8.8 cover Stage 2 (Claude Code); 8.9-8.10 are the design-draft templates Stage 2 produces.

### 8.1 Stage 1 Role (Cursor)

Cursor is used as a codebase scout only — search and report, nothing else. Cursor has no drafting authority and no design authority.

Its scouting job is to find:

- Related source files.
- Related test files.
- Related SQL files.
- Related Supabase migrations.
- Related RLS policies.
- Related providers.
- Related routes.
- Related imports.
- Related state machines.
- Related widgets/screens.
- Related background jobs.
- Related API handlers.
- Related documentation references.
- Related SOP / Policy / Matrix / Checklist references.

Cursor must not modify code in this stage, and must not draft `Overview.md` or `Logic.md` — that is Stage 2's job (Claude Code), not Stage 1's.

### 8.2 Cursor Usage Boundary

Allowed:

- Search files.
- List dependency paths.
- Identify import chains.
- Identify API routes.
- Identify SQL migration history.
- Identify test coverage.
- Identify RLS policy locations.
- Identify related docs.
- Report candidate affected files.
- Report uncertainty.
- Mark any undecided architecture/DB/RLS/naming question as "Open Question" instead of deciding it.

Forbidden:

- Editing code.
- Formatting files.
- Rewriting Korean Markdown.
- Running broad refactors.
- Changing encoding.
- Running automated fixes.
- Modifying generated files.
- Modifying lock files.
- Guessing that a file is safe without checking references.
- Drafting `Overview.md` or `Logic.md` — Cursor has no design-drafting authority; this belongs to Claude Code in Stage 2.
- Inventing new architecture, DB, RLS, or naming conventions.
- Self-approving, self-staging, or self-committing anything.

### 8.3 Cursor Prompt Template

```text
You are only allowed to search and report. You have no drafting or design
authority — do not produce Overview.md or Logic.md, that happens in a
separate stage.

Task:
Find the full impact scope for the following change:

<CHANGE SUMMARY>

Search for:
- source files
- tests
- imports
- routes
- state machines
- database tables
- migrations
- RLS policies
- provider integration files
- audit/evidence logic
- monitoring/alert logic
- related docs
- related SOP / Policy / Matrix / Checklist files
- master index and domain index references
- rule summary files required for context snapshot
- full governance rule files required only if summaries are insufficient
- rule families that can be safely excluded from the snapshot

Rules:
- Do not modify any file.
- Do not run formatters.
- Do not normalize encoding.
- Do not use PowerShell Set-Content.
- Preserve UTF-8.
- Do not rewrite Korean text.
- Do not infer safety from filename alone.
- Return a structured raw scope/inventory report only.
- Do not draft Overview.md or Logic.md.
- Do not invent new architecture, DB, RLS, or naming conventions — mark undecided points as "Open Question".
- You have no authority to approve, stage, or commit anything. Claude Code independently verifies this report before it is trusted (Stage 2).
```

### 8.4 Stage 1 Output: Raw Scope/Inventory Report

Cursor's Stage 1 output is a raw report, not yet the trusted `ImpactScope.md` — it becomes `ImpactScope.md` only after Claude Code verifies/corrects it in Stage 2 (8.8).

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

### 8.5 Stage 2 Role (Claude Code)

Claude Code verifies Cursor's Stage 1 scan and drafts the design. This is where design-drafting authority actually lives — not in Stage 1.

Claude Code must independently check Cursor's report for missed files, missed dependencies, missed RLS/migration impact, and missed rule references before trusting any of it. Claude Code must not simply reformat Cursor's report — it must verify it the same way Claude verifies Claude Code's own draft in Stage 3.

Claude Code's `Overview.md`/`Logic.md` draft is not binding. It becomes the approved design only after Claude verifies it in Stage 3. Claude Code drafting first is a velocity optimization — it does not change who owns final design authority.

Claude Code must not modify code in this stage.

### 8.6 Claude Code Usage Boundary (Stage 2)

Allowed:

- Independently re-check Cursor's candidate file list, dependency paths, import chains, API routes, migration history, test coverage, RLS policy locations, and related docs against the actual codebase.
- Add anything Cursor missed; remove anything Cursor mis-flagged.
- Finalize `ImpactScope.md` following the template in 8.8.
- Draft `Overview.md` following the template in 8.9.
- Draft `Logic.md` following the template in 8.10.
- Mark any undecided architecture/DB/RLS/naming question as "Open Question for Claude" instead of deciding it.

Forbidden:

- Editing code.
- Formatting files.
- Rewriting Korean Markdown.
- Running broad refactors.
- Changing encoding.
- Running automated fixes.
- Modifying generated files.
- Modifying lock files unless explicitly approved.
- Trusting Cursor's report without independently checking it.
- Inventing new architecture, DB, RLS, or naming conventions inside the `Overview.md`/`Logic.md` draft.
- Treating the `Overview.md`/`Logic.md` draft as approved before Claude verification.

### 8.7 Claude Code Prompt Template (Stage 2)

```text
You are verifying a raw scope/inventory scan produced by Cursor (a
different model with no drafting authority). Do not trust it at face
value — independently check it against the actual codebase.

Cursor's raw report:
<CURSOR RAW REPORT>

Task:
1. Verify each candidate file/dependency/migration/RLS policy Cursor
   listed actually exists and is actually relevant.
2. Search independently for anything Cursor may have missed.
3. Finalize ImpactScope.md.
4. Draft Overview.md.
5. Draft Logic.md.

Rules:
- Do not modify any file.
- Do not run formatters.
- Do not normalize encoding.
- Do not use PowerShell Set-Content.
- Preserve UTF-8.
- Do not rewrite Korean text.
- Do not infer safety from filename alone.
- Do not invent new architecture, DB, RLS, or naming conventions in the draft — mark undecided points as "Open Question for Claude".
- Do not treat the draft as approved. Claude verifies it in Stage 3.
```

### 8.8 Stage 2 Output: `ImpactScope.md`

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

Use `LEAN` when summary files are sufficient. Use `NORMAL` when a small number of full rules are also required. Use `FULL` only for cross-domain financial, RLS, migration, provider, audit, or release changes where summaries are not enough.

### 8.9 `Overview.md` (Claude Code Draft — Verified By Claude In Stage 3)

Purpose:

- Explain the change at a high level.
- Define business goal.
- Define affected modules.
- Define non-goals.
- Define financial impact.
- Define risk level.
- Surface open questions Claude Code could not resolve on its own.

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

### 8.10 `Logic.md` (Claude Code Draft — Verified By Claude In Stage 3)

Purpose:

- Define exact runtime logic before coding.
- Make money-moving state transitions explicit.
- Prevent hidden behavior.

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

## 9. Stage 3/4/5/6 (Formerly "Stage 2") — Claude Design Review, Architecture Verification, Contract Drafting, And Contract Verification

**(2026-07-16 전면 재작성)** Old Stage 2 combined "verify the design, then lock the contract" into one stage owned solely by Claude. §3's 2026-07-16 restructure splits that into four stages with different owners: **Stage 3** (Claude reviews the design and sets the Critical/Normal tier), **Stage 4** (Codex and, under Critical tier, Cursor — plus Antigravity as a non-binding reference — independently verify the design against master rules; Claude integrates), **Stage 5** (**Claude Code**, not Claude, drafts `TestPlan.md`/`ChangeContract.md` from the verified design), and **Stage 6** (the same multi-actor composition as Stage 4, this time verifying the contract; §37 excludes Claude Code as the contract's own author). The four groups of subsections below are ordered to match: 9.1-9.7 (Stage 3), 9.8-9.11 (Stage 4), 9.12-9.15 (Stage 5), 9.16-9.19 (Stage 6).

### Stage 3 — Claude First-Pass Design Review + Tier Decision

### 9.1 Role

Claude acts as the first-pass design reviewer — not, as under the old Stage 2, the sole producer of the implementation contract.

Claude receives:

- `ImpactScope.md`
- `Overview.md` (Claude Code draft)
- `Logic.md` (Claude Code draft)
- current business requirement
- filtered rule summaries from the context snapshot
- full governance rules only when the context snapshot requires them
- relevant project rules
- financial safety requirements
- existing SOP references if needed

Claude reviews the Claude Code draft and produces:

- verified/corrected `Overview.md`
- verified/corrected `Logic.md`
- review comments
- a Critical/Normal tier verdict (§9.5) that determines Stage 4's verifier composition

Claude may correct minor drafting errors directly in `Overview.md`/`Logic.md`. If the draft reveals an incomplete impact scope (missed files, missed dependencies, missed RLS/migration impact), Claude must loop back to Stage 2 (or Stage 1 if the gap traces back to Cursor's original scan) rather than patching around the gap.

Producing `TestPlan.md`/`ChangeContract.md` is no longer Claude's job at this stage — that now happens in Stage 5, performed by Claude Code from the Stage-3-reviewed, Stage-4-verified design (§9.12).

### 9.2 Stage 3 Must Not Do

Claude must not:

- write implementation code;
- broaden the change scope casually;
- invent new architecture standards;
- rename files outside the approved naming system;
- create new DB conventions without explicit approval;
- weaken RLS/security/evidence requirements;
- skip tests because the change looks small;
- hide financial risk behind generic wording;
- accept the Claude Code `Overview.md`/`Logic.md` draft as final without checking it against master rules and the actual repo state;
- silently resolve an "Open Question For Claude" without recording the decision in the verified document;
- treat its own Stage 3 review as a substitute for Stage 4's independent multi-actor verification — Stage 3 is Claude's own first pass, not the cross-actor check §35/§36 established as necessary.

### 9.3 Claude Verifies Claude Code's `Overview.md` Draft

Claude checks the Claude Code draft (template in 8.9) against:

- master architecture, naming, and domain conventions;
- whether "Affected Domains" and "Affected Files From Claude Code" match the actual repo state;
- whether "Non-Goals" / "Out Of Scope" correctly exclude adjacent scopes;
- whether "Financial Impact Class" and "Risk Summary" are consistent with the real invariants at stake;
- whether every "Open Questions For Claude" entry has been answered or explicitly deferred with a reason;
- whether wording could be misread as implementation authorization.

Claude updates `## Draft Status` to `Verified (Claude)` only after these checks pass, and records any correction made.

### 9.4 Claude Verifies Claude Code's `Logic.md` Draft

Claude checks the Claude Code draft (template in 8.10) against:

- idempotency, duplicate-prevention, timeout, and unknown-state handling required by project financial rules;
- whether the state model matches the actual schema/RPC behavior (not just the intended design);
- whether audit ledger / evidence / RLS rules are complete and consistent with master rules;
- whether "Prohibited Behavior" covers the real failure modes for this domain;
- whether every "Open Questions For Claude" entry has been answered or explicitly deferred with a reason.

Claude updates `## Draft Status` to `Verified (Claude)` only after these checks pass, and records any correction made.

### 9.5 Stage 3 Tier Decision Rule

Claude's tier verdict determines whether Stage 4 (and later Stage 6, Stage 9) run with a single verifier (Codex) or the fuller Cursor+Codex composition. This decision uses the same criteria §38.1/§38.2 already established: does this change actually touch live DB or source code, or does it merely restate an already-settled design in a document template? A new architectural judgment (e.g. a new state-machine shape, a new naming direction) requires the fuller Critical-tier composition even before any code is written. Per §39, Normal tier (single verifier) is now the exception, not the default — it applies only when Human has explicitly authorized it for the change at hand; absent that, Stage 4/6/9 all run Critical tier.

### 9.6 Stage 3 Prompt Template

```text
You are reviewing a Claude Code design draft for a financial-grade SaaS system. You are not producing the implementation contract yet — that is a later stage.

Input:
- ImpactScope.md
- Overview.md (Claude Code draft)
- Logic.md (Claude Code draft)
- user requirement
- project rules

Task:
- Check Overview.md and Logic.md against master rules, the real repo state, and every "Open Questions For Claude" entry.
- Correct minor drafting errors directly. If the impact scope itself is incomplete, stop and send the change back to Stage 2 instead of designing around the gap.
- Mark Overview.md / Logic.md Draft Status as Verified (Claude) only after checks pass.
- Decide the Critical/Normal verification tier (§9.5) for Stage 4.

Rules:
- Do not write implementation code.
- Do not draft TestPlan.md or ChangeContract.md — that is Stage 5's job, performed by Claude Code, not by you here.
- Use the context snapshot as the project rule boundary.
- Do not redesign naming conventions, DB conventions, RLS conventions, evidence conventions, or architecture standards.
- If local requirements conflict with master rules, flag the conflict instead of silently changing the standard.
```

### 9.7 Stage 3 Output

- verified/corrected `Overview.md`
- verified/corrected `Logic.md`
- review comments
- Critical/Normal tier verdict, handed to Stage 4

### Stage 4 — Architecture Verification (Multi-Actor)

### 9.8 Role

Stage 4 is where an actor other than Claude independently re-checks the Stage-3-verified design before any contract is written — the practical application of §35/§36 (cross-actor verification) now folded directly into the numbered pipeline instead of sitting beside it as an ad hoc add-on.

Composition (per §3, §9.5's tier decision):

- **Normal tier**: Codex, plus Antigravity as a non-binding reference participant (§40).
- **Critical tier**: Cursor and Codex, plus Antigravity as a non-binding reference participant.

Claude integrates whatever the Stage 4 verifiers report into a single `Architecture Review`, then informs Human of the tier and outcome before Stage 5 begins. Stage 4 verifiers have no authority to approve, block, or redesign — they report findings; Claude decides what to do with them.

### 9.9 Stage 4 Verification Checklist

Each Stage 4 verifier independently re-checks the same dimensions Claude already checked in 9.3/9.4 — the point is a second, differently-blind-spotted look, not a rubber stamp of Claude's Stage 3 pass:

- Does `Overview.md`/`Logic.md` match master architecture, naming, and domain conventions?
- Does the state model in `Logic.md` match the actual schema/RPC behavior, verified by reading the real code/DB, not just the design prose?
- Are idempotency, duplicate-prevention, timeout, and unknown-state handling complete for this domain?
- Are audit ledger / evidence / RLS rules complete and consistent with master rules?
- Does any part of the draft describe "reusing an existing pattern" that is, on inspection of the actual code, really a new combination or variant (per §36.3(c))?
- Is there any architectural inconsistency between `Overview.md` and `Logic.md` themselves?

### 9.10 Stage 4 Prompt Template

```text
You are independently verifying a design draft (Overview.md/Logic.md) that Claude has already reviewed once. Do not trust Claude's Stage 3 pass at face value — read the actual code/DB yourself and cite exact file+line for every claim you make (this citation requirement applies to every participant, including Antigravity — see §40.3).

You receive:
- Overview.md, Logic.md (Stage 3-verified)
- ImpactScope.md
- relevant master rules

Task:
Check the items in §9.9 against the real repository/DB state, not against the documents' own claims about themselves.

Rules:
- Eyes-Only: report findings, do not redesign, do not approve or block.
- Mark any undecided point as an Open Question rather than deciding it yourself.
- Output a list of concerns/discrepancies, or an explicit "no concerns found" statement — do not stay silent.
```

### 9.11 Stage 4 Output: `Architecture Review`

Claude's integration of the Stage 4 verifier report(s) into a single record: per-verifier findings, Claude's disposition of each (accepted / investigated further / dismissed with reason), and whether the design is now cleared to proceed to Stage 5. A raised concern is never silently dropped, per the same standard §37/§12.9 already establish for later stages.

### Stage 5 — Contract Drafting (Claude Code)

### 9.12 Role

**Claude Code**, not Claude, drafts `TestPlan.md` and `ChangeContract.md` from the Stage-4-verified `Overview.md`/`Logic.md`. This is the single most significant actor change from the old Stage 2: under the eight-stage structure, Claude produced the contract directly; under the 2026-07-16 restructure, Claude Code drafts it and Claude's role narrows to reviewing (Stage 3) and integrating multi-actor verification (Stage 4, Stage 6) rather than authoring the contract itself.

`ChangeContract.md` produced here is a draft. It does not become binding until Stage 6 verifies it and the human approves it in the standalone Stage 7 (Human Approval) below.

### 9.13 `TestPlan.md`

Purpose:

- Define required tests before implementation.
- Prevent Codex from creating only happy-path tests at Stage 8.

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

Purpose:

- Lock the implementation boundary.
- Tell Codex what it may and may not touch.
- Preserve a human approval line before implementation begins.

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
Allowed Operations:
- Update payment cancellation logic.
```

Good:

```text
Allowed Operations:
- In `payment_cancel_callback_handler.dart`, edit only `handleCancelCallback()`.
- Add an idempotency check before state transition from `cancel_requested` to `cancel_confirmed`.
- Add audit event `payment.cancel.callback.duplicate_ignored` when duplicate callback is ignored.
- Add tests for duplicate callback and unknown provider status.

Forbidden Operations:
- Do not change provider interface.
- Do not change route shape.
- Do not add a generic payment state utility.
- Do not touch settlement, payout, or refund modules.
```

## Required Business Rules

## Required State Rules

## Required Idempotency Rules

## Required Audit Rules

## Required Tests

## Required Verification Commands

## Rollback Requirements

## Expected Final Deliverables

## Human Boundary Approval

Approved / Not Approved

Approver:
Timestamp:
Approval Notes:
```

### 9.15 Stage 5 Prompt Template

```text
You are Claude Code, drafting the implementation contract from a Stage 4-verified design for a financial-grade SaaS system.

Input:
- ImpactScope.md
- Overview.md (Stage 3-verified, Stage 4-verified)
- Logic.md (Stage 3-verified, Stage 4-verified)
- Architecture Review (Stage 4 output)
- user requirement
- project rules

Create:
1. TestPlan.md
2. ChangeContract.md (draft — not yet approved; Stage 6 verifies it, Stage 7 approves it)

Rules:
- Do not write implementation code yet.
- Use the context snapshot as the project rule boundary.
- Do not redesign naming conventions, DB conventions, RLS conventions, evidence conventions, or architecture standards.
- If local requirements conflict with master rules, flag the conflict instead of silently changing the standard.
- Keep money-moving logic explicit.
- Do not over-abstract.
- Include idempotency, duplicate prevention, timeout, unknown status, rollback, audit ledger, and evidence requirements.
- Include allowed files and forbidden files.
- Include automated verification commands.
- Include risks and required approvals.
```

### Stage 6 — Contract Verification (Multi-Actor, §37)

### 9.16 Role

Stage 6 verifies `TestPlan.md`/`ChangeContract.md` before Human Approval (Stage 7). Per §37, Claude Code — the contract's own author at Stage 5 — is excluded from the Stage 6 verifier pool.

Composition (per §3, §9.5's tier decision, same rule as Stage 4):

- **Normal tier**: Codex, plus Antigravity as a non-binding reference participant.
- **Critical tier**: Cursor and Codex, plus Antigravity as a non-binding reference participant.

Claude integrates the Stage 6 verifier report(s) into the verified contract that Stage 7 receives.

### 9.17 Stage 6 Verification Checklist

- Do `Allowed Files`/`Forbidden Files`/`Allowed Operations` actually match the boundary `Overview.md`/`Logic.md` describe — not a broader or narrower boundary?
- Is every `Allowed Operations` entry a narrow verb (per the Operation Granularity Rule, 9.14), not a broad permission?
- Does `TestPlan.md` cover the idempotency/duplicate/timeout/unknown-state/rollback/audit/evidence requirements `Logic.md` calls for?
- Is anything in the contract inconsistent with the Stage 4 `Architecture Review`?

### 9.18 Stage 6 Prompt Template

```text
You are independently verifying an implementation contract (TestPlan.md/ChangeContract.md) drafted by Claude Code. Cite exact file+line for every claim (§40.3 applies if you are Antigravity).

You receive:
- TestPlan.md, ChangeContract.md (Stage 5 draft)
- Overview.md, Logic.md (Stage 4-verified)
- Architecture Review (Stage 4 output)

Task:
Check the items in §9.17. Confirm the contract boundary actually matches the verified design — no broader, no narrower.

Rules:
- Eyes-Only: report findings, do not redesign, do not approve or block.
- Output a list of concerns/discrepancies, or an explicit "no concerns found" statement — do not stay silent.
```

### 9.19 Stage 6 Output

Verified `TestPlan.md` and `ChangeContract.md`, ready for Stage 7 Human Approval. As with Stage 4, a raised concern is never silently dropped — Claude's integration records what was accepted, investigated further, or dismissed with a stated reason.

### 9.20 Stage 7 제시 전 Claude의 원문서 직접 검토 필수 (2026-07-18 추가, 실제 사례 기반)

Stage 6(Contract Verification) 검증자들의 raw 결과를 통합해서 "우려사항 해소/미해소"를 판정한 뒤, Human에게 Stage 7(§10 Human Approval) 체크박스를 안내하기 전에, Claude는 반드시 `TestPlan.md`/`ChangeContract.md` 원문 자체를 직접 읽어야 한다. 검증자 보고서를 요약해서 전달하는 것만으로는 불충분하다 — 검증자들이 놓친 것을 Claude가 직접 읽다가 발견하는 경우가 실제로 있었다(`canonical_kds_release_orchestration` 워크패킷, 검증자 3명 전원이 ACCEPT라고 했음에도 Human이 "지시어를 주기 전에 해당 문서 2개를 자체 검증을 해야죠"라고 지적해 막았고, 이후 Claude가 §2.1-§2.5 SQL 실행가능성/§4 EXCEPTION 경로/§6.2-§6.3 회귀테스트/§0 발견경위/Stop Conditions를 라인 단위로 직접 재검토한 뒤에야 Stage 7로 진행함 — 검증자 전원 ACCEPT라는 사실 자체가 Claude 자신의 직접 검토를 생략할 근거가 되지 않는다는 원칙 재확인).

이 직접 검토가 새로운 문제를 발견하면, Stage 5로 되돌려 정정한 뒤 Stage 6을 재실행한다. 문제가 없으면 그제서야 Stage 7(§10 체크박스)을 Human에게 제시한다.

이 원칙은 §9.3/§9.4(Stage 3, `Overview.md`/`Logic.md` 직접 검토)의 연장선이며, "Claude는 어느 단계에서도 다른 행위자의 보고를 액면 그대로 신뢰하지 않고, 최종 감사 권한을 가진 자로서 직접 근거를 재확인한다"는 Stage 11 Final Audit(§13) 원칙이 Stage 7 이전에도 동일하게 적용됨을 명시한다 — Stage 11이 구현 이후의 마지막 방어선이라면, 이 규칙은 구현 착수(Stage 8) 이전, 즉 Human이 되돌릴 수 없는 승인 결정을 내리기 전의 동일한 방어선이다.

---

## 10. Stage 7 — Human Approval

### 10.1 Role

The human is the approval gate between design and implementation.

The human receives the full Stage 3-6 design and contract-verification pack:

- `ImpactScope.md`
- verified `Overview.md`
- verified `Logic.md`
- `TestPlan.md`
- verified `ChangeContract.md`

The human reviews the design pack and decides the exact file boundary Codex may touch. This is a standalone stage, not a line item inside Stage 3-6 — Claude Code drafting the contract (Stage 5) and Claude reviewing/integrating it (Stage 3, 4, 6) does not itself authorize implementation.

### 10.2 Why This Is A Standalone Stage

Folding human approval into Stage 3-6 makes it easy to treat "the design pack is finished" as equivalent to "a human approved implementation." They are not the same event. Keeping Stage 7 separate forces an explicit, timestamped decision to exist before Codex is allowed to touch any file, and gives that decision its own artifact instead of a buried checkbox.

### 10.3 Stage 7 Output

As of 2026-07-10, `ChangeContract.md` is the single merged artifact — there is no separate standalone approval file. Stage 7 is satisfied by:

```text
ChangeContract.md -> ## Human Boundary Approval section, filled in
```

### 10.4 Human Approval Statement

```text
Approved for implementation.

Allowed files:
- <file 1>
- <file 2>
- <file 3>

Allowed Operations:
- <narrow verb, per ChangeContract.md Operation Granularity Rule>

Forbidden:
- all other files
- docs/** unless explicitly approved
- generated files unless explicitly approved
- lock files unless explicitly approved
- Korean Markdown files unless explicitly approved
- unrelated modules

Codex may implement only the approved ChangeContract.md, strictly within its boundary. Codex has no authority to self-approve, self-stage, or self-commit anything beyond this.

Approver:
Timestamp:
Approval Notes:
```

### 10.5 Stage 7 Pass Criteria

Stage 7 passes only when:

- The human has read `Overview.md`, `Logic.md`, `TestPlan.md`, and `ChangeContract.md` (not just skimmed the file list).
- Allowed Files and Allowed Operations are both explicit and narrower than "the whole module."
- Any "Open Questions For Claude" left unresolved in the design pack are either answered here or explicitly deferred with a documented reason.
- The approval artifact carries the active `CHANGE_ID`.

If the human is not ready to approve, the change returns to Stage 3 (design gap) or Stage 2 (scope gap) per the Loopback Rules in Section 18.

---

## 11. Stage 8 — Codex Isolated Implementation

As of 2026-07-10, Codex is the Stage 8 implementer, reintroduced as a subordinate execution tool under Claude's governance. Codex holds no authority to self-approve, self-stage, or self-commit anything — its output is a self-report, not a completion proof, and is not binding until Stage 9 (Claude Code, a different model, cross-model re-verification) and Stage 11 (Claude, independent audit) both review it.

### 11.1 Role

Codex acts as the restricted implementer.

Codex receives:

- `ImpactScope.md`
- `ImpactScope.md`
- `Overview.md`
- `Logic.md`
- `TestPlan.md`
- approved `ChangeContract.md`
- `ChangeContract.md` (or the filled Human Boundary Approval section)

Codex implements only within the allowed scope, strictly enforcing the `ChangeContract.md` boundary.

### 11.2 Codex Rules

Codex must:

- Keep diff small.
- Modify only allowed files.
- Avoid broad refactor.
- Avoid clever abstraction.
- Avoid changing unrelated formatting.
- Avoid changing Korean Markdown.
- Avoid changing encoding.
- Avoid generated files unless approved.
- Avoid lock files unless approved.
- Preserve financial logic readability.
- Add or update tests required by `TestPlan.md`.
- Generate `ImplementationModule.md` after implementation.
- Never self-approve, self-stage, or self-commit — Codex's job ends at producing the diff and its self-report; Stage 9/6 review is mandatory before anything downstream trusts it.

### 11.3 Codex Prompt Template

```text
You are the restricted implementer. You have no authority to approve,
stage, or commit anything — a different model independently
re-verifies your work in Stage 9 before Claude's Stage 11 audit can
accept it.

Use only:
- ImpactScope.md
- ImpactScope.md
- Overview.md
- Logic.md
- TestPlan.md
- approved ChangeContract.md

Rules:
- Modify only files listed in Allowed Files.
- Do not modify Forbidden Files.
- Do not refactor unrelated code.
- Do not introduce new abstraction unless explicitly required.
- Preserve UTF-8.
- Do not normalize encoding.
- Do not use PowerShell Set-Content.
- Do not rewrite Korean Markdown.
- Keep money-moving state transitions explicit at call site.
- Add or update tests listed in TestPlan.md.
- If you need another file, stop and request a new Stage 7 boundary approval.
- After implementation, create ImplementationModule.md.

Output:
- code changes
- ImplementationModule.md
```

### 11.4 Code Simplicity Rules

Financial logic must remain readable.

```text
Do not hide financial decisions inside generic utility functions.
Do not create framework-like abstractions unless approved.
Prefer explicit state transition functions.
Prefer clear condition branches over clever dynamic dispatch.
Prefer small, named functions over large nested logic.
Prefer database constraints for invariants where possible.
Prefer idempotency keys and unique constraints over best-effort duplicate checks.
Prefer boring code over impressive code.
```

### 11.5 Stage 8 Output: `ImplementationModule.md`

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

If there are deviations from `ChangeContract.md`, Codex must list them explicitly.

Hidden deviation is not allowed.

If a deviation requires a new file, new migration, new permission, or wider domain impact, implementation must stop and return to Stage 3 for redesign and a new Stage 7 approval.

---

## 12. Stage 9 — Claude Code Independent Re-Verification

As of 2026-07-10, Stage 9 is a cross-model check, not self-verification: Codex (Stage 8) wrote the implementation, and Claude Code (a different model) independently re-verifies it here. This is a deliberate diversity safeguard, same rationale as Stage 9 (Critical tier) below and §26 Adversarial Audit Pass Requirement.

### 12.1 Role

Stage 9 is not an AI judgment stage.

It is a mechanical verification stage, performed against Codex's Stage 8 implementation.

It is performed by Claude Code using the direct terminal and, where applicable, the CI pipeline.

Within Stage 9, Claude Code acts only as a command runner and evidence collector — it did not write the code being verified, and must not treat its own Stage 9 pass as proof the implementation is correct beyond what the raw commands actually show (see §25 Reality-Verification Requirement).

Claude Code must not interpret, auto-fix, or rewrite results unless the process explicitly returns to Stage 1, Stage 2, Stage 3, or Stage 7 with a new approved cycle.

### 12.2 Why Claude Code Is Not The Judge

Claude Code can execute commands, but it should not be trusted to decide financial correctness.

In Stage 9, Claude Code is only:

```text
Terminal operator.
Command runner.
Raw log collector.
Diff collector.
Result recorder.
```

Claude Code is not:

```text
Code fixer.
Architect.
Auditor.
Financial risk reviewer.
Final judge.
```

### 12.3 Stage 9 Command Categories

Required command categories:

- Git diff integrity.
- Static analysis.
- Type check.
- Unit test.
- Integration test.
- Migration dry-run.
- RLS/security check.
- Idempotency test.
- Duplicate request test.
- Timeout/unknown-state test.
- Audit/evidence test.

### 12.4 Example Verification Commands

Flutter / Dart:

```bash
git diff --stat
git diff --check
git diff --name-only

git diff

flutter analyze
dart test
```

Supabase / SQL:

```bash
supabase migration list
supabase db diff
supabase db push --dry-run
```

Node / TypeScript if applicable:

```bash
npm run lint
npm run typecheck
npm test
```

Targeted tests:

```bash
dart test test/payment/
dart test test/refund/
dart test test/payout/
dart test test/reconciliation/
dart test test/provider/
dart test test/audit/
```

Security / RLS checks may be project-specific:

```bash
psql -f scripts/check_rls.sql
psql -f scripts/check_financial_constraints.sql
psql -f scripts/check_idempotency_constraints.sql
```

### 12.5 Claude Code Terminal Prompt For Stage 9

```text
Run only the commands listed below.

Rules:
- Do not modify any file.
- Do not auto-fix.
- Do not format.
- Do not summarize away errors.
- Preserve full raw output.
- Save raw logs to `docs/implementation_evidence/<change_id>/raw_logs/` when possible.
- Prefer command redirection or a repeatable script over manual copy-paste.
- If a command fails, stop and preserve the full output path plus the full output.

Commands:
<COMMAND LIST>
```

### 12.6 Stage 9 Output: `VerificationResult.md`

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

### 12.7 Stage 9 Pass Criteria

Stage 9 passes only when:

- No unauthorized files are changed.
- Static analysis passes.
- Typecheck passes.
- Required tests pass.
- Migration dry-run passes.
- RLS/security checks pass where applicable.
- Idempotency tests pass.
- Duplicate request tests pass.
- Timeout/unknown-state tests pass.
- Audit/evidence tests pass.
- No encoding or formatting drift is detected.
- No generated or lock file changed without approval.
- Raw logs and git diff are preserved for Stage 11.

### 12.8 Stage 9 Failure Handling

If Stage 9 fails:

1. Do not let Claude Code fix directly — it is verifying Codex's implementation, not authoring the fix.
2. Record failure in `VerificationResult.md`.
3. Preserve raw terminal output.
4. Preserve `git diff` and `git diff --name-only`.
5. Return to Stage 3 or Stage 8 depending on failure type.
6. If the failure indicates a design problem, return to Claude design review (Stage 3).
7. If the failure indicates implementation bug within approved scope, return to Codex (Stage 8) with the raw failure log.
8. If new file scope is required, return to Stage 3 for redesign and a new Stage 7 human boundary approval.

### 12.9 Stage 9 (Critical tier) — Cursor Minor-Opinion Review

Purpose: a second, differently-blind-spotted model reviews the same implementation and Claude Code's Stage 9 verification output, specifically looking for anything Claude Code's pass might have missed — this is the practical application of §26 (Adversarial Audit Pass Requirement): models with different training/prompting tend to catch different failure classes.

Applies to Medium/Full tier changes only (§31). Does not apply to the Lightweight track (§24) or purely mechanical fixes.

Rules:

- Cursor receives: the approved `ChangeContract.md`, the actual code diff, and Claude Code's `VerificationResult.md` from Stage 9.
- Cursor produces a short `MinorOpinion.md`: a list of any concerns, discrepancies, or questions — NOT a pass/fail verdict, NOT a gate. Cursor has no authority to block, approve, or require changes.
- If Cursor finds nothing, `MinorOpinion.md` states that explicitly (a clean pass is still a recorded output, not silence).
- Claude's Stage 11 audit MUST read `MinorOpinion.md` alongside `VerificationResult.md` and the raw diff, and MUST explicitly address (accept, investigate further, or explain why dismissed) any concern Cursor raised — silently ignoring a Cursor concern is not permitted, but Claude is not obligated to agree with it. The final ACCEPT/REJECT authority remains solely with Claude.

#### 12.9.1 Cursor Minor-Opinion Prompt Template

```text
You are giving a non-binding second opinion. You cannot block, approve,
or require changes — you can only raise concerns for Claude's Stage 11
audit to address.

You receive:
- ChangeContract.md (approved boundary)
- the actual code diff
- Claude Code's VerificationResult.md (Stage 9)

Task:
Look for anything Claude Code's Stage 9 verification might have missed:
- logic that doesn't match ChangeContract.md or Logic.md
- edge cases the verification commands didn't actually exercise
- claims in VerificationResult.md that the raw logs don't actually support
- anything that looks wrong even if the commands reported PASS

Output:
- A list of concerns/discrepancies/questions, OR
- An explicit statement that no concerns were found (do not stay silent).

You are not producing a PASS/FAIL verdict. You have no gate authority.
```

#### 12.9.2 Stage 9 (Critical tier) Output: `MinorOpinion.md`

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

## 13. Stage 11 — Independent Audit (11A Claude Audit / 11B ChatGPT Blind Audit / 11C Conflict Analysis)

**2026-07-18 구조 변경**: Stage 11은 이제 3개 하위 단계로 구성된다 — **11A**(§13.1-§13.5, Claude의 raw-증거 기반 감사, 기존과 동일), **11B**(§13.8, ChatGPT의 진짜 블라인드 역설계 감사, 신규·모든 워크패킷 의무), **11C**(§13.9, Human이 11A/11B를 직접 대조하는 Conflict Analysis, 신규). 이 세 단계 전체를 근거로 최종 병합 결정을 내리는 것은 **여전히 별도의 Stage 12(§14, Human Merge And Release Evidence)이며, 번호나 구조가 바뀌지 않는다** — Stage 11의 하위단계로 흡수되지 않는다. 근거와 배경은 §13.7(Dual Anchor Principle)을 참고.

### 13.1 Stage 11A — Role

Claude performs independent audit.

As of 2026-07-10 (stage numbers updated 2026-07-16, see §3), Claude's audit is a genuine cross-model check across four separate parties: Cursor (Stage 1 scan, Stage 9 Critical-tier minor opinion), Claude Code (Stage 2 draft, Stage 5 contract draft, Stage 9 re-verification), Codex (Stage 8 implementation), and Claude itself (Stage 3, Stage 4, Stage 6, Stage 11). Claude must re-verify the raw diff, raw logs, and repository evidence directly rather than trusting Codex's implementation self-report, Claude Code's Stage 9 verification report, or Cursor's Stage 1 / Stage 9 (Critical tier) output at face value — Claude re-derives key claims rather than accepting any prior party's summary.

Claude receives:

- `ImpactScope.md`
- `ImpactScope.md`
- `Overview.md`
- `Logic.md`
- `TestPlan.md`
- approved `ChangeContract.md`
- `ChangeContract.md` (or the filled Human Boundary Approval section)
- `ImplementationModule.md` (Codex's self-report)
- `VerificationResult.md` (Claude Code's Stage 9 cross-model re-verification)
- `MinorOpinion.md` (Cursor's Stage 9 (Critical tier) non-binding second opinion, Medium/Full tier)
- raw terminal logs
- `git diff --stat`
- `git diff --check`
- `git diff --name-only`
- full or scoped `git diff`

Claude checks whether the implementation matches the plan and whether the plan itself still has hidden failure modes. `ImplementationModule.md` is Codex's self-report and `VerificationResult.md` is Claude Code's report — Claude must verify both against the raw logs and diff, not accept either at face value. Every concern raised in `MinorOpinion.md` must be explicitly addressed (accepted, investigated further, or dismissed with a stated reason) — silently ignoring a Cursor concern is not permitted, though Claude is not obligated to agree with it.

### 13.2 Stage 11A — Audit Focus

Claude must review:

- Did Codex modify only approved files?
- Did Codex implement the planned logic?
- Did Codex skip edge cases?
- Did Codex add unapproved abstraction?
- Did tests cover required financial risks?
- Did automated verification pass?
- Do raw logs reveal warnings hidden by summary?
- Does git diff show unrelated formatting or encoding drift?
- Are there financial accident scenarios?
- Are audit logs complete?
- Are permissions/RLS safe?
- Is rollback realistic?
- Is evidence sufficient?
- Does code remain simple?
- Does the implementation still match the master context snapshot?
- Did Cursor's Stage 1 scan miss anything Claude Code should have caught in Stage 2?
- Has every concern in `MinorOpinion.md` (Stage 9 (Critical tier)) been explicitly addressed, not silently dropped?

### 13.3 Stage 11A — Contrarian Audit Prompt

```text
Assume the implementation is wrong.

Review:
- ImplementationModule.md (Codex self-report)
- VerificationResult.md (Claude Code cross-model re-verification)
- MinorOpinion.md (Cursor non-binding second opinion, if Medium/Full tier)
- raw terminal logs
- git diff --stat
- git diff --check
- git diff --name-only
- full git diff
- ImpactScope.md
- ChangeContract.md

Do not accept any of the above at face value — re-derive the key
claims yourself against the raw diff and raw logs. Explicitly address
every concern raised in MinorOpinion.md.

Find how this change could cause:
- duplicate charge
- duplicate refund
- duplicate payout
- wrong payout
- unknown bank status mishandling
- settlement mismatch
- provider status misinterpretation
- RLS bypass
- audit ledger missing event
- evidence packet gap
- rollback failure
- customer/store message false finality
- unauthorized file modification
- unapproved abstraction
- master rule violation
```

### 13.4 Stage 11A Output: `AuditReview.md`

`AuditReview.md` is the confirm/audit artifact. Some teams prefer the name `implementation_confirm.md`; for payment, POS, and other runtime-truth domains in this project, `AuditReview.md` is preferred because Claude's role here is auditor, not a simple confirmation checkbox.

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

### 13.5 Stage 11A Block Criteria

Claude Audit must block if:

- Unauthorized files were changed.
- Money-moving logic is ambiguous.
- Unknown status is treated as success/failure without evidence.
- Duplicate prevention is missing.
- Idempotency is missing.
- RLS or access rule is unsafe.
- Audit ledger event is missing.
- Evidence packet path is missing.
- Tests do not cover required cases.
- Rollback is impossible or undocumented.
- Code is too broad or too abstract.
- Verification failed.
- Raw logs are missing for failed commands.
- Git diff is missing.
- Implementation deviated from contract without approval.
- Implementation conflicts with master rules from `ImpactScope.md`.
- A concern raised in `MinorOpinion.md` (Medium/Full tier) was not explicitly addressed.

### 13.6 앵커링 방지 규칙 — Raw 증거로부터의 직접 재도출 (2026-07-18)

Stage 11(최종 감사) 수행 시, Claude는 이전 Stage들에서 이미 형성된 요약/통합 결과 — 설령 그것이 Claude 자신(또는 이전 세션의 자신)이 작성한 것이라 해도 — 를 그대로 신뢰하지 않는다. 핵심 주장(무엇이 바뀌었는가, 무엇이 검증됐는가, 무엇이 아직 미해결인가)은 반드시 다음 원본 증거로부터 직접 재도출해야 한다:

- raw diff(`git diff`의 실제 텍스트 — 요약이나 서술이 아님)
- raw 실행 로그(테스트/쿼리의 실제 출력 — "통과했다"는 문장이 아님)
- 각 검증자(Cursor/Codex/Antigravity 등)의 원본 raw 보고서 — Claude 자신이 이미 통합한 요약본이 아님

**근거**: Stage 3부터 Stage 11까지 여러 단계에 걸쳐 동일한 Claude가 계속 판단을 내리는 이 파이프라인 구조상, 초기 단계에서 형성된 해석이 후속 단계까지 그대로 지속되는 앵커링(anchoring) 편향 위험이 구조적으로 존재한다 — 인간 검토자가 자기 자신의 이전 결론에 저항하기 어려운 것과 동일한 인지적 함정이다. Stage 11이 단순한 재확인이 아니라 진짜 독립 감사로서 의미를 가지려면, 이전 단계의 통합/요약 결과가 아니라 그 통합의 재료였던 원본 증거를 다시 봐야 한다.

**적용**: 위 세 종류의 원본 증거로부터 핵심 주장을 직접 재도출한 뒤, 그 결과를 이전 단계의 통합 결과와 대조한다 — 일치하면 그대로 ACCEPT 근거로 쓰고, 불일치가 발견되면 그 불일치 자체를 감사 결과에 명시한다(§44.2 Zero Deferred Doubt 원칙과 동일한 정신을 Stage 11에 특화 적용한 것).

(2026-07-18, ChatGPT 교차검증 기반 반영)

### 13.7 Dual Anchor Principle (2026-07-18, 모든 워크패킷 의무 적용)

**원칙**: Stage 11에서는 동일한 AI 계열이 만든 설계를 동일 계열 AI가 최종 진실로 인정하지 않는다. 반드시 독립 모델(ChatGPT 등)이 동일 결론을 별도 경로(진짜 블라인드 — 사전 맥락 없는 새 대화창)에서 재도출하거나, 차이를 명시적으로 보고해야 한다. 이는 모든 워크패킷의 Stage 11에 예외 없이 적용된다.

**근거(2026-07-18 실제 사례로 확립)**: `canonical_kds_release_orchestration` 워크패킷에서, Claude 혼자 내린 Stage 11 ACCEPT 판정에 실제 결함(두 `EXCEPTION` 핸들러가 자신의 감사기록 호출 실패까지는 방어하지 못해, 이중 실패 시 이미 완료된 `payment_ledger` INSERT까지 롤백되는 문제)이 있었다. 이 결함은 ChatGPT의 독립적 재검토가 먼저 잡아냈고, 이후 Cursor+Codex의 fault-injection(실제 라이브 DB 대상 이중 실패 강제 재현)으로 확정됐다 — "같은 AI 계열이 설계하고 같은 AI 계열이 최종 감사하면 앵커링이 발생한다"는 것의 실제 증거다.

**역할 재정의**:

| 역할 | Claude | ChatGPT |
|---|---|---|
| 기본 태도 | 설계를 증명 | 설계를 반증 |
| Stage 11A | Logic/구현이 계약을 충족하는지 확인 | - |
| Stage 11B | - | 설계문서 없이 raw 자료만으로 블라인드 역설계 |
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

## 14. Stage 12 — Human Merge And Release Evidence

### 14.1 Role

Human performs final merge and release decision.

**2026-07-18부터**: 이 최종 결정은 Stage 11A(`AuditReview.md`) 단독이 아니라, Stage 11B(§13.8, ChatGPT Blind Audit 결과)와 Stage 11C(§13.9, Conflict Analysis 메모) 전체를 근거로 한다(§13.7 Dual Anchor Principle). Stage 12 자체의 번호/구조는 바뀌지 않는다 — 입력이 늘어난 것뿐이다.

The human reviews:

- Final diff.
- `AuditReview.md` (Stage 11A).
- ChatGPT의 Stage 11B 블라인드 역설계 결과 및 대조 결과.
- Stage 11C Conflict Analysis 메모 (일치/불일치, 불일치 중 실제 재현으로 확정된 항목과 그 결과).
- `VerificationResult.md`.
- Raw logs for failed or risky commands.
- Any remaining risks.
- Commit message.
- Release evidence.

### 14.2 Human Merge Checklist

As of 2026-07-10, the merge checklist is a section inside the single merged `ReleaseEvidence.md` (see 14.4 for the full template) rather than a separate `human_merge_checklist.md` file. The checklist items:

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

### 14.3 Commit Message Format

```text
<domain>: <short change summary>

Change ID: <CHANGE_ID>
Impact: <financial impact class>
Scope: <affected domain>
Verification: PASS
Audit: APPROVED
Rollback: <rollback summary>
Evidence: <release evidence path>
```

Example:

```text
payment: enforce idempotent cancel callback handling

Change ID: PAYMENT_CANCEL_001
Impact: high_financial_impact
Scope: payment, provider_status_mapping, audit_ledger
Verification: PASS
Audit: APPROVED
Rollback: revert callback handler and migration 20260618_payment_cancel_idempotency
Evidence: docs/release_evidence/PAYMENT_CANCEL_001/
```

### 14.4 `ReleaseEvidence.md` (Merged: Release Evidence + Human Merge Checklist)

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

### 14.5 Migration Draft Mutability Rule (2026-07-18)

**배경**: `0027`/`0166` 두 사례에서, migration 체크섬 불변성 안전장치(`tools/apply_migrations.py`의 checksum-mismatch 정지 로직)와 같은 워크패킷 안에서의 반복 정정 작업이 충돌했다. 제미나이는 "이미 `git commit`됐는가"를 단일 기준으로 제시했으나, ChatGPT의 분석이 이를 정확히 반박했다 — `git commit` 여부는 로컬 작업 관행의 문제일 뿐, 이 migration이 실제로 "돌이킬 수 없는 상태"가 됐는지와는 무관하다(예: 로컬에만 커밋하고 아직 아무 데도 push/merge/적용하지 않은 경우, 커밋됐다는 사실 자체는 재작성을 막을 이유가 되지 못한다). 대신 이 문서가 이미 갖고 있는 **Stage 12(Human Merge/Release, §14)** 개념을 그대로 판단 기준으로 재사용한다 — "Human이 병합을 승인했는가"가 실제로 의미 있는 불가역성의 경계다.

**Draft Migration**: 다음 4개 조건을 **전부** 충족하는 동안, 해당 migration 파일은 초안(draft)으로 취급되며 같은 파일을 다시 고칠 수 있다.

1. 해당 워크패킷이 아직 Stage 12(Human Merge/Release)를 통과하지 않았다.
2. 이 migration이 보호된 기준 브랜치(`main` 등)에 아직 없다.
3. 어떤 공유 환경에도 아직 적용된 적이 없다.
4. 다른(이후) 워크패킷이 이 migration의 현재 체크섬/동작에 의존하기 시작하지 않았다.

이 4개 조건을 전부 만족하는 동안 파일을 다시 고칠 수는 있지만, **체크섬만 덮어쓰는 것은 허용되지 않는다** — 반드시 이 migration 적용 이전 상태로 로컬 DB를 되돌린 뒤(또는 전체 재실행) 정정된 파일을 다시 적용해야 한다. 파일 내용과 실제 DB 상태는 항상 일치해야 한다.

**불변 경계 (Migration Immutability Boundary)**: 다음 중 **하나라도** 발생하면 그 즉시, 그 migration 파일은 영구 불변으로 전환된다.

1. Human Merge/Release 승인(Stage 12).
2. 보호된 기준 브랜치에 포함됨.
3. 어떤 공유 환경에든 적용됨.
4. 다른 승인된 워크패킷이 이 migration을 의존 대상으로 사용하기 시작함.

**경계 이후 정정 (Post-boundary correction)**: 불변 경계를 넘은 뒤에 발견되는 모든 결함은 반드시 **새로운 forward migration(신규 번호)**으로만 처리한다. 체크섬 수정이나 파일 직접 수정은 어떤 경우에도 허용되지 않는다 — `0027`(`canonical_kds_release_orchestration` 워크패킷 이전에 이미 병합·적용된 파일)에 대해 이 원칙이 실제로 적용된 사례: 결함을 `0027` 자체의 수정이 아니라 신규 `0166` migration으로 처리했다.

**도구 지원은 향후 과제로만 명시 (지금 구현 안 함)**: `tools/apply_migrations.py`가 `--draft`/`--strict` 모드를 구분해 이 규칙을 자동으로 강제하도록 개선하는 것은 별도 워크패킷 후보로 남긴다. 지금은 이 원칙을 사람이 직접 판단하여 수동으로 적용한다 — `0027`은 원본 유지 + `0166` 신설로 처리됐고, `0166` 자신이 이번 정정 라운드들에서 다시 고쳐질 수 있는지(Draft 상태인지 이미 불변 경계를 넘었는지)는 Stage 12 통과 여부에 따라 그때그때 판단 대기 상태로 남아있다 — 이것이 이 규칙의 실제 적용 선례다.

---

## 15. Recommended Document Folder Structure

For each implementation module (Full tier, §31; Medium tier consolidates these into 4 files, see §31):

These are permanent PascalCase names (see §33) — no archival renaming step happens later; the name a file is given at creation is its name for the life of the project.

```text
docs/implementation_evidence/<change_id>/
  00_CursorScan.md               (Cursor — Stage 1 raw scan, unverified, search only)
  01_ImpactScope.md              (Claude Code — Stage 2; merged scope + context snapshot, verifies/corrects the Cursor scan)
  02_Overview.md                 (Claude Code draft, Claude-verified)
  03_Logic.md                    (Claude Code draft, Claude-verified)
  04_TestPlan.md                 (Claude Code draft, Stage 5; Claude-verified at Stage 6)
  05_ChangeContract.md           (Claude Code draft, Stage 5; Claude-verified at Stage 6, Human-approved at Stage 7; merged contract + Human Boundary Approval section)
  06_ImplementationModule.md     (Codex — self-report, not a completion proof)
  07_VerificationResult.md       (Claude Code — Stage 9 cross-model re-verification of Codex, terminal / CI)
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
  08_MinorOpinion.md             (Cursor — Stage 9 (Critical tier) non-binding second opinion; Medium/Full tier only)
  09_AuditReview.md              (Claude — confirm/audit; not optional after Codex's module + Claude Code's verification)
  10_ReleaseEvidence.md          (Human — merged release evidence + human merge checklist)
```

For larger releases:

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

### 15.1 No Archival Renaming (Historical Note, 2026-07-10)

An earlier revision of this section described mapping the artifact set onto sequential six-digit document numbers under this project's `604000_workpackets/` folder when a change was archived (e.g. `604311_Boundary_...md`, `604317_Module_...md`, `604319_Audit_...md`). That entire `600000_implementation_lifecycle/` band, including `604000_workpackets/`, was dropped and moved to `990000_legacy_quarantine/` earlier in this project's history (see [CHANGELOG.md's Deferred/decision-log entries] and 000005/000007's index history for that move).

As of 2026-07-10, this project performs no archival renaming step at all. The PascalCase-joined names in 15 (`ImpactScope.md`, `Overview.md`, `Logic.md`, `TestPlan.md`, `ChangeContract.md`, `ImplementationModule.md`, `VerificationResult.md`, `MinorOpinion.md`, `AuditReview.md`, `ReleaseEvidence.md`) are the permanent names for a change's artifacts for the life of the project, whether the change is active or long since merged. There is no working-name/archived-name distinction to maintain, and no second renaming pass to perform when a change is considered "done."

---

## 16. Financial-Grade Rules To Put In Every Implementation Prompt (Codex, Stage 8)

```text
Financial-grade implementation rules:
- Keep code simple and explicit.
- Do not introduce broad abstractions.
- Do not hide financial state transitions inside generic helpers.
- Preserve idempotency.
- Prevent duplicate money movement.
- Treat timeout and unknown provider status conservatively.
- Never assume provider unknown state is failure or success.
- Write audit ledger event for material state changes.
- Preserve evidence path.
- Respect RLS and least privilege.
- Do not change files outside allowed list.
- Do not rewrite Korean Markdown.
- Do not normalize encoding.
- Do not run formatters unless explicitly approved.
- If more scope is needed, stop and request boundary approval.
```

---

## 17. Financial Accident Scenarios To Test

### 17.1 Payment

- Same payment request twice.
- Provider timeout after successful charge.
- Callback arrives after user retry.
- Duplicate callback.
- Cancel request after unknown approval.
- Provider says pending but internal retry starts.
- Customer-facing UI marks payment final before provider finality.

### 17.2 Refund / Reversal

- Refund request timeout.
- Refund pending beyond SLA.
- Refund retry while prior refund unknown.
- Reversal success but callback delayed.
- Customer message says complete too early.
- Partial refund state is misread as full refund.

### 17.3 Settlement / Reconciliation

- Missing POS file.
- Missing PG/VAN file.
- Duplicate settlement file.
- Corrected settlement file.
- Control total mismatch.
- Close attempted with unresolved exception.
- Reconciliation result is overwritten without audit event.

### 17.4 Payout / Bank

- Bank confirmation unknown.
- Bank file duplicate.
- Payout retry after unknown bank status.
- Store bank account changed before payout.
- Maker and checker are same actor.
- Rejection/return reason unmapped.
- Same payout batch submitted twice.

### 17.5 Audit / Evidence

- Audit ledger write fails.
- Evidence packet manifest missing.
- Redaction profile missing.
- Legal hold flag ignored.
- Privileged export without approval.
- Break-glass not revoked.
- Evidence exists but is not linked to the change ID.
- Audit ledger event has missing `CHANGE_ID`.
- Audit ledger event has stale or wrong `CHANGE_ID`.
- Evidence packet has missing `CHANGE_ID`.
- Evidence packet has stale or wrong `CHANGE_ID`.
- `VerificationResult.md` references a different `CHANGE_ID` than `ImplementationModule.md`.
- Release evidence cannot be matched to the approved `ChangeContract.md`.

---

## 18. Loopback Rules

The pipeline is not always linear.

### 18.1 Return To Stage 1 / Stage 2

Return to Cursor's scan (Stage 1) or Claude Code's verification/draft (Stage 2) if:

- New affected files are discovered.
- Dependency scope was incomplete.
- Test files were missed.
- RLS/migration impact appears.
- Provider interface dependency appears.
- Related docs or SOP references were missed.

If the gap traces back to Cursor's original scan (something Cursor should have found but didn't), return to Stage 1. If Cursor's scan was adequate but Claude Code's verification/draft missed something, return to Stage 2 directly.

### 18.2 Return To Stage 3

Return to Claude design verification if:

- Business logic is wrong.
- Financial edge case was missed.
- Unknown state handling is unclear.
- Rollback is not possible.
- Audit/evidence requirement changes.
- Approval scope changes.
- Master rule conflict is discovered.

### 18.3 Return To Stage 7 Human Approval

Return to Stage 7 for a new human approval if:

- Allowed file list must expand.
- Forbidden file must be touched.
- Financial impact class increases.
- New migration is needed.
- New provider dependency is introduced.
- Emergency path is needed.

### 18.4 Return To Stage 8

Return to Codex if:

- Implementation bug is found within approved scope.
- Test failure is local and design remains valid.
- Claude Audit finds fixable code-level issue.
- Verification failure is caused by code error.

### 18.5 Return To Stage 9 (And Its Critical-Tier Cursor Participation, Medium/Full Tier)

Return to Claude Code's cross-model re-verification (Stage 9) after every implementation change. If the tier includes Stage 9 (Critical tier), Cursor's minor-opinion review must also re-run against the new diff — a prior `MinorOpinion.md` does not cover a new diff.

No manual or AI review can substitute for rerunning automated checks.

### 18.6 Return To Stage 11

Return to Claude Audit after every new verification run.

A previous audit does not approve a new diff.

Codex's `ImplementationModule.md` is never sufficient by itself — every module must reach Stage 11 before it can be considered done.

---

## 19. Minimum Viable Version For Early Development

When the full pipeline is heavy, use this minimum version. As of 2026-07-10 this overlaps in spirit with the Medium tier (§31) — both compress the artifact count; the MVV additionally compresses the actor count (Claude Code alone, no Cursor/Codex) and should be treated as the Lightweight-adjacent option for early-development, non-financial-grade work.

```text
1. Claude Code: 영향 파일 찾기 + Overview.md / Logic.md 초안
2. Claude: context_snapshot 확인 + overview/logic 검증 + TestPlan.md + ChangeContract.md (allowed files)
3. Claude Code: approved files only 구현 + ImplementationModule.md
4. Terminal/Claude Code: git diff --check / flutter analyze / dart test + raw logs
5. Claude: raw logs + git diff + module + test result 감리 (confirm/audit)
6. Human: final diff 확인 후 commit
```

The MVV is only for low-risk, non-financial, non-permission, non-schema, non-provider, non-release changes.

The MVV is forbidden when any of the following are true:

- Payment, cancel, refund, reversal, payout, settlement, reconciliation, provider callback, POS callback, PG/VAN, bank, ledger, audit, evidence, or customer/store finality logic is touched.
- Supabase RLS, database policy, database constraint, database migration, function, trigger, storage policy, or service-role boundary is touched.
- Access control, role permission, staff/admin/store owner permission, tenant isolation, or break-glass behavior is touched.
- Public API, provider API, route contract, webhook contract, or external integration behavior is touched.
- Generated code, lock files, build configuration, deployment configuration, or CI configuration is touched.
- The change may affect production release, rollback, monitoring, alerting, evidence retention, or legal hold.

For payment, payout, settlement, provider, audit, evidence, RLS, access control, database migration, or production release changes, use the full version.

---

## 20. Daily Operating Checklist

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

## 21. One-Page Operating Summary

**(2026-07-16 개정)** As of 2026-07-16, this is a thirteen-stage (0-12) summary for Medium/Full tier changes (§3, §31) — supersedes the eight-stage version of this summary. The Lightweight track (§24) skips all of this and stays log-only.

```text
[0] Issue Discovery / Fact Scan (non-regular)
    Output: Issue Record (optional)
    Rule: Anyone may record a finding before the regular cycle starts. No verification, no gate.

[1] Scan (Cursor, + Antigravity reference)
    Output: raw scope/inventory report (search only)
    Rule: Search and report only. Never draft design, never write implementation code. No approval/block authority.

[2] Design Draft (Claude Code)
    Output: Overview.md (draft), Logic.md (draft)
    Rule: Independently check Cursor's scan before trusting it. Draft design. Never write implementation code. Flag undecided design points as Open Questions For Claude.

[3] Claude First-Pass Review + Critical/Normal Tier Decision
    Output: review comments + tier verdict
    Rule: Claude reviews Overview.md/Logic.md directly and decides how many verifiers Stage 4 needs.

[4] Architecture Verification (Codex + Antigravity, or Cursor + Codex + Antigravity under Critical tier; Claude integrates)
    Output: Architecture Review (integrated verification results)
    Rule: Verify the design draft against master rules and repo state before any contract is written.

[5] Contract Drafting (Claude Code)
    Output: TestPlan.md, draft ChangeContract.md
    Rule: Draft the allowed-file boundary from the verified design — do not approve it.

[6] Contract Verification (Codex + Antigravity, or Cursor + Codex + Antigravity under Critical tier; Claude integrates; §37 excludes Claude Code as the contract's own author)
    Output: verified TestPlan.md/ChangeContract.md

[7] Human Approval Gate
    Output: ChangeContract.md (Human Boundary Approval section filled in)
    Rule: Read the full design pack. Lock allowed files and operations. Codex may not start without this.

[8] Implementation (Codex)
    Output: code diff, ImplementationModule.md
    Rule: Edit only approved files, strictly within ChangeContract.md. Stop if scope expands. This is a self-report, not proof of completion. No self-approval authority.

[9] Independent Verification (Claude Code + Antigravity, or Claude Code + Cursor + Antigravity under Critical tier; Claude integrates; §37 excludes Codex as the implementation's own author)
    Output: VerificationResult.md, raw logs, git diff (+ MinorOpinion.md when Cursor participates under Critical tier)
    Rule: Cross-model check of Codex's implementation, not self-verification. Run commands. Do not fix. Do not hide errors. A clean pass must still be recorded, not left silent.

[10] Documentation (Codex: simple docs; Claude Code: important docs)
    Output: Module.md, NavigationMap.md/index updates (Codex); Verification.md, draft Audit.md (Claude Code)
    Rule: Implementation does not reach Final Audit without a traceable documentation trail.

[11] Final Audit (Claude, alone)
    Output: AuditReview.md (ACCEPT / APPROVE_WITH_NOTES / BLOCK)
    Rule: Review raw logs and diff directly. Assume implementation is wrong. Explicitly address every MinorOpinion.md concern. Never skip this after Stage 8. Final ACCEPT/REJECT authority rests solely with Claude.

[12] Human Merge / Release
    Output: commit, ReleaseEvidence.md (optional)
    Rule: Human owns final risk.
```

---

## 22. Recommended Governance Placement

This document should be treated as a top-level system SOP candidate, not as a casual guide.

Recommended placement:

```text
repository_root/
  sop/
    system/
      000701_Guide_Controlled_AI_Development_Pipeline.md
```

Alternative placement while still in design governance review:

```text
repository_root/
  docs/
    000700_ai_agent_prelearning_and_project_context/
      000701_Guide_Controlled_AI_Development_Pipeline.md
```

(Its current location. The `600000_implementation_lifecycle/` band named here in an earlier revision of this section was quarantined to `990000_legacy_quarantine/` on 2026-07-10 — see §15.1 — so it is no longer a valid alternative placement.)

Placement rule:

- If the document is advisory, keep it under `docs/000700_ai_agent_prelearning_and_project_context/`.
- If the document is mandatory, move it to `sop/system/`.
- If moved to SOP, add cross-links from implementation lifecycle docs and root index.
- If adopted as the active development constitution, reference it from the root master index and from every implementation lifecycle index.

Owner adoption rule:

```text
Do not treat this file as optional once real financial, POS, provider, RLS, migration, audit, or release implementation begins.

For those domains, this guide is the controlling SOP unless a stricter SOP supersedes it.
```

---

## 23. Final Governance Declaration

This guide exists to make AI-assisted development fast without making it reckless.

The project may move quickly only when each change is boxed by:

1. Boundary discovery (Cursor scan, Claude Code verification).
2. Context snapshot diet and domain slicing.
3. Human-approved contract.
4. Narrow Codex implementation.
5. Raw-log mechanical verification (Claude Code cross-model check, Cursor non-binding second opinion on Medium/Full tier).
6. Independent Claude audit.
7. Human ownership.

The operating promise is:

```text
A mistake may happen.
But it must remain trapped inside the approved module boundary,
visible in raw logs,
traceable by CHANGE_ID,
focused by a sliced context snapshot,
and blocked before merge when it threatens financial correctness.
```

This is the development constitution for `yoonsul_wait_order_handoff` until superseded by a stricter SOP or Policy.

## 24. Lightweight Verification-Bugfix Track

Unchanged by the 2026-07-10 Cursor/Codex reintroduction (see the notice near §1 and §2-3). This track is still Claude Code-only, still does not require Cursor's scan or Codex's implementation — small bugfixes under this track do not need the full multi-actor pipeline.

This track applies only when ALL of the following hold:

1. The work is a fix to an existing, not-yet-applied file discovered during a human-approved verification/audit pass already in progress (e.g. running migrations sequentially to find real defects).
2. The fix does not introduce a new file, new table, new migration number, new permission, or any change outside the single file being fixed (per-file scope, same as the existing "if you need another file, stop" rule — this track does NOT waive that rule, it only waives the formal-artifact requirement for in-scope fixes).
3. The fix is one of: syntax correction, stale reference correction (backed by repo-wide grep evidence per the established "which side is load-bearing" standard), or an application-layer/environment-detection correction of the same kind as the 0034 DB-name-guard fix.
4. The human owner has explicitly authorized entering this track for the current verification pass (a single authorization covers the whole pass, not one per file).

Under this track:

- Claude Code may diagnose and fix issues without producing ImpactScope.md/Overview.md/Logic.md/TestPlan.md/ChangeContract.md for each individual fix.
- Claude Code must still log every fix in a running table: file, issue, fix applied, verification result — this log substitutes for the formal artifacts and is the audit trail for this track.
- Claude Code must STOP and escalate to full Stage 1-7 process (formal artifacts + standalone Human Approval) when:
  - the fix requires new business-logic inference (not a mechanical correction),
  - two plausible fixes have meaningfully different tradeoffs with no clear evidence for which is correct,
  - a new forward file/migration/table/permission is needed,
  - the file touches payment, security-isolation, RLS, or financial settlement logic AND the fix is not a pure syntax correction (i.e. any semantic change to financial-grade logic always requires full process, no exception).
- Claude's Stage 11 independent audit still applies retroactively: before staging/commit of the full batch, Claude reviews the running log and spot-verifies a sample against the actual file diffs and live DB state, same as any other Stage 11 audit — this track shortens the front-end gates, not the back-end audit.

This track does not apply to designing new features, new schema, or any work outside an already-approved, already-scoped verification pass.

## 25. Reality-Verification Requirement (Doc-to-System Gap)

No Stage 11 audit may be marked ACCEPT/PASS based on document cross-references alone, no matter how internally consistent or precisely cited those references are. Every audit that closes a track touching runtime state (database schema, deployed functions, running services, external APIs) must include at least one direct, reproducible check against the actual live target — a query, a test execution, an API call, a build/compile — not just a review of prior documents' claims.

Precedent: the A4 0065 documentation track (604520-604524) was internally perfect — every cited line number and count matched exactly on independent re-derivation — yet the underlying database had zero of the claimed objects, because no step in that chain ever queried the actual database. A document chain can be flawless and still describe a system that doesn't exist. "PASS" without a reality-check timestamp and command log is not a valid Stage 11 verdict for any runtime-touching change.

## 26. Adversarial Audit Pass Requirement

For any Stage 11 audit closing a track with financial-grade, security, or cross-tenant-isolation impact, at least one audit pass must be explicitly adversarial: instructed to find a reason the prior work is wrong, not to confirm it is right. A second same-style confirmatory pass is not a substitute — models sharing similar training and prompting patterns tend to share blind spots, and repeated agreement between similar passes is evidence of correlated failure risk, not independent verification.

This project has already observed real value from disagreement between independent passes (e.g. the 021632-021642 catalog/policy split verdicts, the 070390 Audit/Closeout/Index disagreement) — genuine splits surfaced real ambiguity that a single confirmatory pass would have missed. Adversarial framing should be used deliberately, not left to accidental disagreement between differently-prompted passes.

## 27. Procedural Checks Are Automated; Human/AI Time Goes To Substantive Verification

Checks that are purely mechanical (H1-matches-filename, six-digit prefix present, forbidden-action list present, file inside allowed scope) must be enforced by scripted linting wherever possible, not by AI review time. AI review time (Claude's Stage 3/4/6/11 review, Claude Code's Stage 1/8/9 work) should be weighted toward substantive verification: does the logic actually do what it claims, does the change actually run/compile/apply, does the fix actually resolve the defect when executed.

If a review pass spends most of its content on procedural conformance and little or none on whether the underlying system actually works, that is a sign the review has drifted toward the wrong kind of value.

## 28. Documentation Governs Tests; It Does Not Replace Them

For any runtime-affecting change (SQL, RPC, application logic), the Overview/Logic/Module/TestPlan chain must reference and, where practical, trigger an actual automated test or reproducible verification script (e.g. the project's own `tools/apply_migrations.py` pattern) rather than describing test intent in prose alone. A written `TestPlan.md` that is never actually executed against a real system carries no more evidential weight than an unexecuted claim.

Where no automated test/verification tooling exists yet for a given domain, creating that tooling is itself a valid, often higher-priority Stage 1-8 deliverable than producing additional descriptive documents for the same domain.

## 29. Lightweight Decision Log (Session-Level ADR)

Significant governance or scope decisions made in conversation (e.g. "drop and rebuild an entire numbered band," "change tool authority structure," "accept a track without reality-verification because X") must be recorded in a short, append-only decision log entry — not left to exist only inside a chat transcript. Each entry: date, decision, one-paragraph rationale, what it supersedes if anything.

Precedent: this session's own "drop the entire 600000 band" decision existed only in chat history; multiple separate Claude Code sessions later had no record of it and had to be re-briefed from scratch, wasting verification time and creating risk of the decision being silently re-litigated or contradicted by a session that never received it.

This log's format and location are intentionally left for a later, separate governance decision — this section only establishes that such decisions must be recorded somewhere durable, not that they must go through the full artifact chain themselves.

## 30. Per-Module Change History (Single-File, Append-Only): `ChangeHistory.md`

Every module/component/domain (a SQL schema domain, a Flutter feature module, a governed doc bundle) must maintain exactly ONE running history log named `ChangeHistory.md`, appended to over time — never a new file per change (the 605900 pattern of one document per event is explicitly forbidden here, same reasoning as elsewhere in this pipeline).

Format (one row/entry per change): date | change description | reason/evidence | outcome | linked audit/test.

Before attempting a fix to any module that previously failed or was modified, Claude Code/Claude must first read that module's `ChangeHistory.md` in full. This is mandatory, not optional — the log exists specifically so future sessions (which have no memory of prior sessions, as demonstrated repeatedly in this project) don't repeat already-tried-and-failed approaches or re-litigate settled decisions.

Stage 11 (Claude audit) must append one entry to the relevant module's `ChangeHistory.md` upon ACCEPT of any change — this is part of closing the audit, not a separate task.

For SQL: `catchmenu_meta.migration_history` (the DB table already built this session) is the data-level history; a companion human-readable log (`sql/migrations/CHANGELOG.md`, one running file) records the narrative reasoning behind each fix (why, not just what) — the DB table answers "was X applied," the changelog answers "why was X necessary." `sql/migrations/CHANGELOG.md` is a deliberate exception to the `ChangeHistory.md` naming convention: it keeps the industry-standard lowercase `CHANGELOG.md` name because that convention is widely recognized by tooling and contributors outside this project's own governance system.

## 31. Artifact Weight Tiers

The 11-artifact full chain (`CursorScan.md` through `ReleaseEvidence.md`, §15) applies only to the Full tier. Two lighter tiers exist:

- **Lightweight tier**: §24's existing rule (log-only, no formal artifacts).
- **Medium tier**: for new features/moderate changes that are not financial-grade/security/RLS/payment-affecting. Produces 4 consolidated files instead of 11:
  - `DesignPack.md` = ImpactScope (scope + context snapshot) + Overview + Logic sections combined in one document
  - `TestAndContract.md` = TestPlan + ChangeContract sections combined
  - `ImplementationAndVerification.md` = ImplementationModule + VerificationResult sections combined
  - `AuditAndRelease.md` = AuditReview + Human Boundary Approval record + ReleaseEvidence sections combined

  All required CHANGE_ID traceability and stage gate rules (§6.11, Stage 7 approval, Stage 11 independent audit) still apply in full — only the FILE COUNT is reduced, not the review rigor.
- **Full tier** (existing 11-file chain, §15: `CursorScan` through `ReleaseEvidence`): mandatory, no exception, for any change touching payment, security-isolation, RLS, financial settlement, or cross-tenant logic — same non-negotiable list as §24's escalation criteria.

The human owner or Claude (Stage 3) selects the tier per change, stated explicitly in the `DesignPack.md` / `Overview.md`'s header.

## 32. Domain NavigationMap Requirement

Every governed domain/module (a SQL schema domain, a Flutter feature module, any folder subject to this pipeline) must maintain one `NavigationMap.md` — a single structured index, not a narrative log (that's `ChangeHistory.md`'s job, §30). Format: one row per change, columns: change ID | date | tier (lightweight/medium/full) | status (open/approved/implemented/verified/audited/released) | links to that change's actual artifact files (wherever they live).

`NavigationMap.md` answers "what changes exist in this domain and what state are they in" at a glance. `ChangeHistory.md` answers "why was each change made." These are complementary and both required — do not merge them into one file.

`NavigationMap.md` must be updated at Stage 7 (approval) and Stage 12 (release) at minimum — new row on approval, status update on release.

## 33. Pipeline Artifact Filename Convention (PascalCase-Joined)

As of 2026-07-10, every pipeline-generated artifact defined in this guide uses a PascalCase-joined filename with no underscores and no six-digit prefix: `ImpactScope.md`, `Overview.md`, `Logic.md`, `TestPlan.md`, `ChangeContract.md`, `ImplementationModule.md`, `VerificationResult.md`, `MinorOpinion.md`, `AuditReview.md`, `ReleaseEvidence.md`, `ChangeHistory.md`, `NavigationMap.md`, `CursorScan.md`, and the Medium-tier consolidated files `DesignPack.md`, `TestAndContract.md`, `ImplementationAndVerification.md`, `AuditAndRelease.md`. Per-domain rule summary cheat sheets (§6.3, §6.8) follow the same convention: `<Domain>RulesSummary.md`.

This is a distinct convention from two other naming systems already in use in this project, and does not replace either of them:

- **Project documentation** (`docs/` governed content) uses this project's own six-digit-prefixed `Title_Case_With_Underscores` convention per `000002_Naming_Rules.md` — unaffected by this section.
- **`sql/migrations/CHANGELOG.md`** is a deliberate, explicitly-noted exception (§30) — it keeps the industry-standard lowercase `CHANGELOG.md` name rather than becoming `ChangeHistory.md`, because that name is recognized by tooling and contributors outside this project's governance system.

There is no working-name/archived-name distinction and no renaming step performed later (§15.1) — a PascalCase artifact name is permanent from the moment Stage 1/2 creates it through however long the change remains referenced, whether the change is active or long since released.

**(2026-07-11 개정, 2026-07-16 번호 정합화)** Stage 12 머지 승인 완료 후에는 예외적으로 `000001` §5.4.2의 영구 archive 절차가 적용되어, 통합 작업 파일로 쓰였던 산출물이 개별 승인 DocumentType 단위로 6자리 번호 문서로 이전된다. 위 문단이 말하는 "permanent from creation"은 Stage 1-11 진행 중 단계에서의 파일명 불변성을 의미하며, Stage 12 이후 영구 보관 이전 자체를 금지하지 않는다. 상세 절차는 `000001` §5.4.2 참고.

## 34. Actor Selection Rule (Cost/Capability-Based, 2026-07-11)

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
| 대용량 파일/트리 전체 스캔 (한글 없음 또는 스캔만) | Cursor |
| 한글 본문이 있는 파일의 내용 검증/처리 | Cursor 지양, Codex 또는 Claude Code |
| 단순/반복 검증, 소규모 §24 수정 | Codex |
| ChangeContract 준수 구현, 규칙 정확성이 중요한 작업 | Claude Code |
| 설계/감사/최종 판단 | Claude (Stage 3/4/6/11) |

## 35. Cross-Actor Verification Expansion Rule (2026-07-11)

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

## 36. Design-Implementation Double Cross-Verification Loop (2026-07-11)

배경: 600410(KDS capacity gate) 워크패킷에서, Claude Code가 작성한 Overview/Logic/TestPlan/ChangeContract를 Human Approval 직전에 Cursor에게 독립 재검증시켰더니, 큰 그림(설계 방향)은 맞았지만 세부 사실 3건이 실제 코드와 어긋나 있었다(0098이 실제로는 is_overloaded를 안 쓴다는 것, zone 목록 로직이 "기존 패턴 재사용"이 아니라 "두 패턴의 새 조합"이었다는 것, 문서 간 아키텍처 불일치). 이는 §35(Cross-Actor Verification Expansion Rule, 구현 후 재검증)를 설계 단계에도 확장해야 함을 보여준다 — 설계 문서 자체도 액면 그대로 신뢰하면 안 되고, 구현에 들어가기 전에 이미 한 번 걸러야 한다.

### 36.1 원칙

Medium tier 이상(§31)에서, Stage 3-6(Claude 설계 검증 + Architecture/Contract Verification) 완료 후 Stage 7(Human Approval) 이전에 Cursor에게 설계 문서(Overview/Logic/TestPlan/ChangeContract) 독립 재검증을 최소 1회 거친다. 이는 §35(구현 후 재검증)와 별개로 설계 단계에 적용되는 사전 버전이다. (2026-07-16 갱신: 이 사전 재검증은 이제 신규 Stage 4/Stage 6의 Critical-tier Cursor 참여로 공식 흡수되었다 — 아래 36.2 절차는 그 이전 관행을 그대로 기록하며, 현재는 §3의 Stage 4/6 구성으로 대체 적용된다.)

### 36.2 전체 루프 (Medium tier 이상 표준 절차로 확정)

**(2026-07-16 시점 기준: 이 목록은 §36 확정 당시의 옛 8단계 표기로 남긴 역사적 기록이다. 아래 각 항목이 현재 §3의 몇 단계에 해당하는지 괄호로 병기한다.)**

1. Stage 2(Claude Code): Overview/Logic 작성 — 현재도 Stage 2
2. Stage 2(Claude): TestPlan/ChangeContract 작성 및 검증 — 현재는 Stage 5(Claude Code가 초안 작성) + Stage 3/4(Claude 검토·통합)
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

## 37. Verifier Assignment Author-Check Rule (2026-07-11)

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

## 38. Verification Intensity Tiering by Risk (2026-07-11)

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

## 39. Mandatory Dual Verification Standard (2026-07-11)

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

## 41. Universal Failure Audit Requirement (2026-07-13)

배경: `010554_Policy_Four_Layer_Audit_Capture_Trigger_View_OS_Log_And_Nightly_Batch_Reconciliation.md`가 이미 4계층 감사(DB 트리거/뷰-프로젝션/OS 런타임 로그/야간 배치 재조정) 모델을 정의해뒀으나, 그 적용 범위는 `PAYMENT_EVENT`/`REFUND_EVENT`/`SECURITY_EVENT` 등 명시적으로 나열된 고위험 이벤트 카탈로그(§8)에 한정되며, 문서 자체가 "이 문서는 planning-only이며 코딩을 승인하지 않는다"(§26 Runtime Deferral)고 명시한다. Human 결정(2026-07-13)은 이보다 넓은 범위를 요구한다: 위험도와 무관하게, 단순 진단성(diagnostic) 케이스가 아니라 **실제 실패(unhandled exception 등)가 발생하는 모든 경우**에 영구 기록을 요구한다.

**이번 조사 경위(Cursor+Antigravity 이중 조사, 2026-07-13)**: 최초안은 "DB + OS 파일시스템(`RAISE LOG`) 이중 기록"이었다. 조사 결과 `RAISE LOG`는 기술적으로는 작동하지만(`logging_collector = off`로 이번 턴 직접 재확인), 디스크 파일로 남지 않고 Docker의 임시 로그 스트림에만 존재하며, 마이그레이션 코드에 연결된 사례가 없다 — 컨테이너 재시작/로그 로테이션으로 유실될 수 있어 금융권 감사 목적에 부적합함이 조사로 실증됐다. 따라서 "OS 파일시스템 기록" 요구사항은 **폐기**하고, 이미 이 코드베이스에서 검증된 기존 함수 `catchmenu_audit.append_audit_record()`(→ `catchmenu_ledger.audit_records`, append-only)로 단일화한다 — 이번 턴 직접 확인한 결과 49개 마이그레이션 파일이 이미 이 함수를 사용 중이며(`grep -l` 재확인), 새 메커니즘을 만들 필요가 없다.

### 41.1 원칙 (최종 확정)

모든 RPC 함수는 `EXCEPTION` 핸들러 블록을 갖추고, 실패 발생 시 **`catchmenu_audit.append_audit_record()`를 통해 `catchmenu_ledger.audit_records`에 append-only로 영구 기록**한다. 이 경로는 이미 append-only + 영구 보존이 보장되므로 그 자체로 충분하며, 별도의 OS 파일시스템 이중 기록은 요구하지 않는다(위 배경 문단 참고 — 실현 시 오히려 더 불안정한 감사 경로가 된다는 것이 조사로 확인됨). 기록 후 원래 에러를 재발생시키거나(`RAISE`) 적절한 에러 응답을 반환한다 — 조용히 삼키지 않는다.

**`log_diagnostic()`/`diagnostic_logs`와의 구분 — 용도가 다름**: `catchmenu_common.log_diagnostic()`(→ `catchmenu_common.diagnostic_logs`)은 이번 조항이 대체하지 않는다. 이는 "비즈니스 실패는 아니지만 알아둘 만한 상황"(예: `600710`의 게스트+포인트 요청 케이스 — 주문 자체는 정상 진행되지만 클라이언트 버그 추적용으로 남기는 경고)을 위한 **진단성 경고** 채널로 별도 유지한다. `append_audit_record()`는 실제 실패(`EXCEPTION` 발생)를 위한 경로이고, `log_diagnostic()`은 실패가 아닌 정상 흐름 중의 경고를 위한 경로다 — 두 채널은 목적이 다르므로 서로 대체하지 않는다.

### 41.2 §010554와의 관계 — 범위가 다르지 대체가 아님

§010554의 4계층 모델(DB 트리거/뷰-프로젝션/OS 로그/야간 배치)은 **고위험 이벤트 카탈로그**(결제/환불/보안/AI/내보내기 등)에 계속 적용된다 — 이번 §41이 그것을 대체하거나 축소하지 않는다. §41은 그보다 **낮은 문턱**에서 적용되는 별개의 요구사항이다: "이 이벤트가 고위험 카탈로그에 속하는가"와 무관하게, "이 RPC 호출이 처리되지 않은 예외로 실패했는가"만을 기준으로 삼는다. 즉 §010554는 이벤트의 *종류*로 범위를 정하고, §41은 실행의 *결과*(실패 여부)로 범위를 정한다 — 두 기준은 서로 겹칠 수 있으나(예: 결제 RPC의 unhandled exception은 양쪽 모두 해당) 어느 한쪽이 다른 쪽을 포함하지 않는다.

### 41.3 적용 범위

신규/수정되는 함수부터 우선 적용한다 — `600710_place_takeout_order_unassigned_record_fix`의 `place_takeout_order()`가 첫 적용 대상 후보다. 기존 함수 전체에 대한 소급 적용은 이번 조항의 범위가 아니며, 별도 백필(backfill) 워크패킷으로 분리한다.

## 42. §6.5 Mandatory Rule For Every Overview.md (2026-07-13)

Human 결정(2026-07-13, 재논의 금지): 모든 `Overview.md`는 `§6.5 Required Context Snapshot Candidates` 섹션을 반드시 포함한다.

이 섹션은 Stage 2/Stage 3가 설계 판단에 실제로 투입한 규칙·문서 후보를 빠뜨리지 않도록 하기 위한 최소 컨텍스트 스냅샷이다. `Overview.md`가 이 섹션을 누락하면 Stage 3 검증에서 반려 사유가 된다.

필수 구조:

1. **Master Anchor**
   - 해당 change의 최상위 판단 근거, Human 결정, 특허/운영/도메인 기준 문서, 또는 "해당 없음"을 명시한다.
2. **Full Rules Required**
   - 전체 본문을 읽어야 하는 규칙/설계/근거 문서를 적는다.
   - 단순 파일명 언급과 실제 full-read 필요 문서를 구분한다.
3. **Domain Indexes**
   - 관련 도메인 폴더의 Index/NavigationMap/Readme 등 흐름·위치 파악용 문서를 적는다.
   - 본문에 인용된 도메인 인덱스가 없으면 "해당 없음"을 명시한다.
4. **Excluded Rule Families**
   - 이번 change와 무관하다고 본문에서 이미 제외한 문서군/규칙군/파일군을 적는다.
   - 최소 1개 이상 명시해야 한다.

작성 규칙:

- 이미 Overview 본문에서 인용한 문서를 이 4단 구조로 재분류한다.
- 애매한 문서는 임의 배치하지 말고 `Open Question`으로 표시한다.
- `§6.5`는 새 판단을 추가하는 장소가 아니라, Overview 본문에 이미 등장한 근거와 제외 범위를 구조화하는 장소다.
- `§6.5` 작성은 기존 본문 판단을 대체하지 않는다. 기존 §0~§5 본문은 그대로 두고, 컨텍스트 스냅샷 후보만 별도 섹션으로 고정한다.

## 43. No Low-Risk Exception For Cross-Verification (2026-07-14)

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

## 44. Complete Trace Recording And Immediate Doubt Resolution (2026-07-14)

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
- KDS capacity overload
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
