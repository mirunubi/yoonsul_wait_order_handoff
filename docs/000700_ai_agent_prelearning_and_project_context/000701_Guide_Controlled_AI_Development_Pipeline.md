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

As of 2026-07-10, Cursor and Codex are reintroduced as subordinate execution/scan tools under Claude's full governance — they hold NO authority to self-approve, self-stage, or self-commit anything. Every Cursor/Codex output is independently re-verified by a different model (Claude Code) before Claude's Stage 6 audit accepts it. This is a deliberate cross-model diversity safeguard (see §26 Adversarial Audit Pass Requirement) against shared blind spots if verification stayed entirely within one model family — it is not a return to unsupervised GPT authority, which remains permanently revoked.

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

- The guide is treated as a candidate top-level system SOP / development constitution.
- The pipeline runs as an explicit eight-stage loop for Medium/Full tier changes (Stage 1.5 and Stage 5.5 added 2026-07-10 alongside the Cursor/Codex reintroduction; see §3, §31). The Lightweight track (§24) is unaffected and remains log-only. Human Approval is a standalone Stage 3, not an implicit line inside Stage 2.
- The human approval record (the Human Boundary Approval section inside `ChangeContract.md`) remains mandatory before Codex touches code.
- Context Snapshot injection is mandatory before Claude design work.
- Raw terminal logs and git diff must be handed to Claude without AI summarization.
- Allowed Operations must be narrower than Allowed Files.
- Every audit and evidence artifact must map back to the active `CHANGE_ID`.
- MVV may not be used for RLS, database migration, financial, provider, audit, evidence, access-control, or production-release changes.
- Context Snapshot must be dieted by cheat sheets, domain slicing, and Claude Code-discovered rule references so Claude receives only the relevant rule boundary.
- Full master rules are governance anchors; AI injection should prefer short rule summaries unless a conflict or audit requires the full document.
- Stage 1/1.5 (Cursor scan, Claude Code verification) must discover not only affected code and docs, but also the minimal rule files needed for Stage 2.
- Stage 5 raw logs (Claude Code's cross-model re-verification of Codex's Stage 4 implementation) should be saved to `raw_logs/` by shell redirection or task scripts so Claude can audit exact terminal output without copy-paste loss.
- Each major domain folder should maintain a thin `<Domain>RulesSummary.md` cheat sheet so future development uses sliced context instead of dumping thousands of planning documents.
- When this guide is adopted as mandatory governance, it should be placed under `sop/system/` and treated as the project development constitution.
- Role split revision (2026-07-08, superseded in part 2026-07-10 below): Stage 2 (Claude) verifies and, where needed, corrects the drafted design, then authors `TestPlan.md` and `ChangeContract.md`. Stage 3 (Human) is a standalone approval gate that must exist before implementation may begin. Stage 6 (Claude) remains the independent audit stage, producing the confirm/audit output (`AuditReview.md`) — the implementer's `ImplementationModule.md` in Stage 4 is a self-report, not a completion proof, and is not binding until Stage 6 audits it.
- Sections 25-29 were added after this session's SQL migration verification pass revealed that internally consistent documentation chains can still diverge completely from actual system state — these sections require reality-checking, adversarial review, effort-prioritization toward substantive verification, and durable decision logging as structural corrections, not optional best practices.
- Role split revision (2026-07-10): Cursor and Codex are reintroduced under Claude's full governance (see the notice above and §2, §3). Stage 1 (Cursor) is scope/inventory search only — no drafting, no editing. Stage 1.5 (Claude Code) verifies Cursor's scope and drafts `Overview.md`/`Logic.md`. Stage 4 (Codex) implements strictly within the approved `ChangeContract.md` boundary. Stage 5 (Claude Code) independently re-verifies Codex's implementation — this is a cross-model check, not self-verification, since Claude Code did not write the implementation. Stage 5.5 (Cursor) produces a non-binding `MinorOpinion.md` second review, which Stage 6 must explicitly address (see §31 for tier applicability, §32 for the per-domain NavigationMap that tracks tier and status per change).

---

## 2. Operating Thesis

The project uses AI tools as a divided-control development system, with five actors under one governance authority (Claude).

```text
Cursor scans and reports (no drafting, no editing).
Claude Code verifies the scan and drafts the design.
Claude verifies the draft, locks the contract.
Human approves the boundary.
Codex implements strictly inside the boundary.
Claude Code independently re-verifies Codex's implementation.
Cursor gives a non-binding second opinion.
Claude judges (does not trust any prior self-report).
Human owns merge and release.
```

No single AI tool is allowed to be trusted as the final authority. Cursor and Codex additionally hold no authority to self-approve, self-stage, or self-commit anything — every output either tool produces passes through at least one different model's independent re-verification before Claude's Stage 6 audit can accept it (see the notice near §1 and §26 Adversarial Audit Pass Requirement).

Claude Code's design draft is not binding by itself. `Overview.md` and `Logic.md` only become the approved design once Claude has verified them in Stage 2 — Claude Code drafting first does not remove Claude's role as design authority, it only changes who produces the first draft. The same non-binding principle applies to Codex's implementation and Cursor's scan/opinion: nothing either of them produces is treated as ground truth until a different model has independently re-checked it.

The pipeline is designed around the following authority split:

| Party | Authority And Responsibility |
|---|---|
| Cursor | Stage 1 scope/inventory scan (search, dependency discovery only — no editing, no design authority). Stage 5.5 non-binding minor-opinion second review of Codex's implementation and Claude Code's Stage 5 verification. Cursor cannot block, approve, or require changes at either stage. |
| Claude Code | Stage 1.5: verifies/corrects Cursor's scope, drafts `Overview.md`/`Logic.md`. Stage 5: independently re-verifies Codex's implementation (cross-model check, not self-verification) and produces `VerificationResult.md` with raw evidence capture. |
| Claude | Design verification, contract lock, governance review, and mandatory independent audit of raw diffs and logs (Stage 2, Stage 6). Claude does not trust Cursor's scan, Codex's self-report, or Claude Code's verification report at face value — Stage 6 re-derives key claims. Final ACCEPT/REJECT authority rests solely with Claude. |
| Codex | Stage 4: isolated implementation strictly within the human-approved `ChangeContract.md` boundary. Codex's `ImplementationModule.md` is a self-report, not a completion proof, and is not binding until Stage 5 (Claude Code) and Stage 6 (Claude) both review it. |
| Human | Implementation approval, final merge, release, and production risk acceptance. |

The resulting process is an eight-stage integrity loop for Medium/Full tier changes (§31); the Lightweight track (§24) remains a shorter, log-only path.

---

## 3. Final Eight-Stage Integrity Loop

As of 2026-07-10 this is an eight-stage loop for Medium/Full tier changes (§31): Stage 1.5 and Stage 5.5 were added alongside the reintroduction of Cursor and Codex as subordinate, non-authoritative tools. The Lightweight track (§24) is unaffected and stays log-only, no Cursor/Codex involvement required for small fixes.

```text
[1] Cursor Scope/Inventory Scan -> "Eyes Only"
    - 영향 파일 검색
    - dependency / import / route / SQL / RLS / test 위치 확인
    - 관련 MD / SOP / policy / index 위치 확인
    - 절대 구현 코드 작성 금지, 절대 설계 문서 초안 작성 금지 (검색/보고만)
    - 아키텍처/DB/RLS/네이밍 신규 표준 결정 금지 — 불확실하면 "Open Question" 표시
    - Cursor는 이 단계에서 승인/차단 권한이 없음 — 원시 스캔 결과만 보고
    - Output: raw scope/inventory report (ImpactScope.md draft input)

    ↓ scan handoff (Claude Code verifies before trusting it)

[1.5] Claude Code Verifies Cursor Scope And Drafts Design -> "Drafting Hands"
    - Cursor의 스캔 결과를 직접 검증 (누락된 파일/의존성/RLS/migration 여부 확인)
    - ImpactScope.md 확정
    - Overview.md 초안 작성
    - Logic.md 초안 작성
    - 절대 구현 코드 작성 금지 (design draft 문서만 작성)
    - 아키텍처/DB/RLS/네이밍 신규 표준 결정 금지 — 불확실하면 "Open Question for Claude"로 표시
    - Output: ImpactScope.md (verified), Overview.md (draft), Logic.md (draft)

    ↓ context snapshot handoff

[2] Claude Design Verification And Contract Lock -> "Brain / Judge"
    - Overview.md / Logic.md 초안을 마스터 규칙·invariant·gap 대비 검증
    - 사소한 오류는 직접 수정, impact scope 자체가 불완전하면 Stage 1로 반려(loopback)
    - TestPlan.md 생성
    - ChangeContract.md 생성
    - 프로젝트 마스터 규칙 준수
    - 허용/금지 파일 목록 작성
    - rollback 기준 작성
    - Output: verified Overview.md/Logic.md + TestPlan.md + draft ChangeContract.md (not yet approved)

    ↓ design pack handoff

[3] Human Approval             -> "Owner (Gate)"
    - Overview.md / Logic.md / TestPlan.md / ChangeContract.md 검토
    - 허용 파일 / 금지 파일 확정
    - Codex가 손댈 수 있는 범위를 명시적으로 승인
    - Output: ChangeContract.md (Human Boundary Approval 섹션 작성 완료)

    ↓ approved boundary handoff

[4] Codex Isolated Implementation -> "Hands"
    - 승인된 ChangeContract.md 바운더리 내부에서만 구현 (엄격 준수)
    - 작은 diff 유지
    - 불필요한 리팩토링 금지
    - 구현 후 ImplementationModule.md 생성 (구현자 자기보고서 — 완료 증명 아님)
    - Codex는 자기 구현을 스스로 승인/커밋할 권한 없음
    - Output: code diff + ImplementationModule.md

    ↓ raw verification handoff

[5] Claude Code Independent Re-Verification -> "Cross-Model Ruler"
    - Codex 구현에 대한 독립적 재검증 (자기검증 아님 — 다른 모델에 의한 교차검증)
    - 터미널 operator로서 빌드/테스트 실행
    - lint / typecheck / test / migration dry-run / RLS/security check
    - idempotency / duplicate / unknown-state test
    - 실제 실행/DB 상태 대비 검증 (§25 reality-verification)
    - raw terminal log 수집
    - git diff / git diff --stat / git diff --check 수집
    - Output: VerificationResult.md + raw logs + git diff

    ↓ raw log + diff handoff

[5.5] Cursor Minor-Opinion Review -> "Second Set Of Eyes, Non-Binding"
    - ChangeContract.md + 실제 code diff + Stage 5 VerificationResult.md 검토
    - Claude Code의 Stage 5 검증이 놓쳤을 수 있는 우려사항/불일치/질문 목록 작성
    - Pass/Fail 판정 아님, 게이트 아님 — 승인/차단/수정요구 권한 없음
    - 발견사항 없어도 "발견사항 없음"을 명시적으로 기록 (침묵 금지)
    - Output: MinorOpinion.md (concerns list, or explicit clean-pass statement)
    - 적용 범위: Medium/Full tier만 (§31). Lightweight track(§24)과 순수 기계적 수정에는 적용 안 함.

    ↓ minor opinion + raw log + diff handoff

[6] Claude Independent Audit    -> "Judge"
    - ImplementationModule.md 검토 (자기보고서를 그대로 신뢰하지 않음)
    - VerificationResult.md 검토 (Claude Code의 보고서도 액면 그대로 신뢰하지 않음)
    - MinorOpinion.md 검토 — Cursor가 제기한 모든 우려사항에 명시적으로 응답 (수용/추가조사/기각사유) 필수, 침묵 처리 금지
    - raw terminal error log 검토
    - git diff 직접 검토
    - 핵심 주장 재도출 (re-derive key claims, 액면 신뢰 금지)
    - 3,000개 규칙 매칭
    - 금융 사고 반례 시나리오 교차 감사
    - 최종 ACCEPT/REJECT 권한은 오직 Claude에게만 있음
    - Output: AuditReview.md (confirm/audit) — APPROVE / APPROVE_WITH_NOTES / BLOCK

    ↓ owner decision handoff

[7] Human Merge / Release       -> "Owner"
    - 최종 diff 직접 확인
    - AuditReview.md 확인
    - VerificationResult.md 확인
    - MinorOpinion.md 확인
    - unresolved BLOCK 없음 확인
    - commit / merge / release 승인
    - Output: ReleaseEvidence.md
```

This is the explicit eight-stage form (Medium/Full tier). Earlier revisions of this guide compressed Human Approval into an implicit line inside Stage 2 to save a stage for daily execution speed. This version reinstates Human Approval as a standalone Stage 3: Codex may not begin implementation until a recorded approval artifact exists, separate from Claude's design-verification output. Codex's `ImplementationModule.md` (Stage 4) is a self-report, not a completion proof — it is not binding until Claude Code's Stage 5 cross-model re-verification and Claude's Stage 6 audit both review it against `VerificationResult.md`, `MinorOpinion.md`, and the raw `git diff`.

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

| Stage | Owner | Role Name | Main Output | Main Risk Controlled |
|---:|---|---|---|---|
| 1 | Cursor | Eyes Only | Raw scope/inventory report (search only, no drafting, no editing) | Wrong file scope, missed dependency, hidden test/RLS/migration impact |
| 1.5 | Claude Code | Drafting Hands | `ImpactScope.md` (verified), `Overview.md` (draft), `Logic.md` (draft) | Cursor's raw scan trusted uncritically; unverified design draft mistaken for final |
| 2 | Claude | Brain / Judge | Verified `Overview.md`/`Logic.md`, `TestPlan.md`, draft `ChangeContract.md` | Poor design, hidden financial risk, ambiguous scope, unverified Claude Code draft silently accepted |
| 3 | Human | Owner (Gate) | `ChangeContract.md` (Human Boundary Approval section filled in) | Codex starting on an unapproved or ambiguous file boundary |
| 4 | Codex | Hands | Code diff, `ImplementationModule.md` | Incorrect implementation, broad refactor, unauthorized changes, self-report mistaken for completion proof, implementation outside the approved boundary |
| 5 | Claude Code | Cross-Model Ruler | `VerificationResult.md`, raw logs, git diff | Type errors, test failures, migration/RLS/security gaps hidden by summaries; Codex's self-report trusted without independent re-verification |
| 5.5 | Cursor | Second Set Of Eyes (Non-Binding) | `MinorOpinion.md` (concerns list or explicit clean-pass statement) | Blind spots shared by the Stage 5 verifier going unnoticed; a single model family's correlated failure risk |
| 6 | Claude | Judge | `AuditReview.md` (confirm/audit) | Logic mismatch, financial accident scenario, evidence gap, false confidence, unaudited self-report treated as final, a raised Cursor concern silently ignored |
| 7 | Human | Owner | Commit, merge, `ReleaseEvidence.md` | Blind merge, uncontrolled production release, unowned risk |

---

## 6. Mandatory Context Snapshot Between Stage 1.5 And Stage 2

As of 2026-07-10, Stage 1 (Cursor's raw scan) is not itself the handoff point — Cursor has no drafting authority and its raw scan is search-only. The context snapshot referenced throughout this section is assembled after Claude Code's Stage 1.5 verification of that scan, at the Stage 1.5-to-Stage 2 boundary. References to "Stage 1" below mean the combined Stage 1 (Cursor scan) + Stage 1.5 (Claude Code verification/draft) unless otherwise noted.

### 6.1 Why This Exists

In a 3,000-document repository, an impact scope report alone is not enough.

If Claude receives only `ImpactScope.md` and a change request, it may design a solution that is locally plausible but globally inconsistent with project architecture, naming rules, file conventions, DB constraints, RLS policy patterns, evidence rules, or financial safety rules.

However, the opposite failure is also dangerous.

If every design cycle injects the entire rule base, Claude may suffer from context bloat, irrelevant-rule fixation, and lost-in-the-middle behavior. Token cost increases, attention quality drops, and the current module's core risk may be diluted by unrelated governance text.

Therefore, the context snapshot must not mean "dump every rule document." It means "inject the smallest rule-complete bundle needed for this change."

### 6.2 Context Snapshot Diet Rule

When moving from Claude Code Stage 1.5 to Claude Stage 2, always provide a context snapshot bundle.

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

The full governance document remains the source of truth, but Stage 2 should normally receive the summary unless the change touches a high-risk boundary or the summary flags a need to inspect the full rule.

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

Cursor's Stage 1 raw scan should surface candidate rule/SOP/policy references alongside code/SQL/test files, but curating those candidates into the minimal rule set Stage 2 actually needs is a judgment call, not a search task — it belongs to Claude Code's Stage 1.5 verification pass, not Cursor's Stage 1 scan.

Claude Code must not only find code, SQL, tests, and documents. It must also identify the minimal rule files needed for Stage 2.

Stage 1.5 must ask:

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

This allows Stage 1.5 to act as the first context filter. Stage 2 then consumes only the filtered snapshot rather than the entire 3,000-document base.

### 6.6 Context Snapshot Output

As of 2026-07-10, the context snapshot is no longer a separate file — it is folded into `ImpactScope.md`'s "Required Context Snapshot Candidates" section and related fields (Module Domain Tags, Context Budget Decision, Known Gaps, Snapshot Decision), produced by Claude Code in Stage 1.5. See 8.8 for the full template. This section previously described a standalone `context_snapshot.md`; that file no longer exists as a separate artifact.

The handoff from Stage 1.5 to Stage 2 is `ImpactScope.md` itself — there is no second manifest file to produce.

### 6.7 Stage 2 Prompt Requirement

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

The purpose is not to duplicate the full documents. The purpose is to give Stage 1 an easy file to discover and Stage 2 a small rule packet to consume.

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

## 7. Mandatory Raw Log And Git Diff Handoff Between Stage 5 And Stage 6

As of 2026-07-10, this handoff passes through Stage 5.5 (Cursor minor-opinion review, Medium/Full tier only) before reaching Stage 6. Cursor receives the same raw evidence package described below, plus `ChangeContract.md` and the code diff — see §12.9 for Stage 5.5's specific rules. Stage 6 Claude still receives everything Stage 5 produced directly; Stage 5.5 does not filter or gate what reaches Stage 6, it only adds `MinorOpinion.md` to the package.

### 7.1 Why This Exists

Stage 5 is a mechanical verification stage, not a judgment stage. As of 2026-07-10, Stage 5 is performed by Claude Code independently re-verifying Codex's Stage 4 implementation — a cross-model check, not self-verification.

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

For this reason, Stage 6 Claude Audit must receive raw terminal output and raw `git diff`, not only a friendly summary.

### 7.2 Raw Handoff Rule

The Stage 5 output must include:

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

### 7.5 Stage 6 Audit Input Rule

Claude Audit must receive `raw_logs/`, `git diff`, and (Medium/Full tier) `MinorOpinion.md` directly.

Claude must not rely on `VerificationResult.md` alone, and must not rely on Codex's `ImplementationModule.md` self-report alone. Every concern raised in `MinorOpinion.md` must be explicitly addressed — accepted, investigated further, or dismissed with a stated reason — never silently ignored (see §12.9 and §32).

---

## 8. Stage 1 (Cursor) And Stage 1.5 (Claude Code) — Scope Scan And Design Draft

As of 2026-07-10, this section covers two separate pipeline stages under one heading to avoid renumbering every downstream section: **Stage 1** is Cursor's raw scope/inventory scan (search only, no drafting authority). **Stage 1.5** is Claude Code's verification of that scan plus the design draft. Subsections 8.1-8.4 cover Stage 1 (Cursor); 8.5-8.8 cover Stage 1.5 (Claude Code); 8.9-8.10 are the design-draft templates Stage 1.5 produces.

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

Cursor must not modify code in this stage, and must not draft `Overview.md` or `Logic.md` — that is Stage 1.5's job (Claude Code), not Stage 1's.

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
- Drafting `Overview.md` or `Logic.md` — Cursor has no design-drafting authority; this belongs to Claude Code in Stage 1.5.
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
- You have no authority to approve, stage, or commit anything. Claude Code independently verifies this report before it is trusted (Stage 1.5).
```

### 8.4 Stage 1 Output: Raw Scope/Inventory Report

Cursor's Stage 1 output is a raw report, not yet the trusted `ImpactScope.md` — it becomes `ImpactScope.md` only after Claude Code verifies/corrects it in Stage 1.5 (8.8).

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

### 8.5 Stage 1.5 Role (Claude Code)

Claude Code verifies Cursor's Stage 1 scan and drafts the design. This is where design-drafting authority actually lives — not in Stage 1.

Claude Code must independently check Cursor's report for missed files, missed dependencies, missed RLS/migration impact, and missed rule references before trusting any of it. Claude Code must not simply reformat Cursor's report — it must verify it the same way Claude verifies Claude Code's own draft in Stage 2.

Claude Code's `Overview.md`/`Logic.md` draft is not binding. It becomes the approved design only after Claude verifies it in Stage 2. Claude Code drafting first is a velocity optimization — it does not change who owns final design authority.

Claude Code must not modify code in this stage.

### 8.6 Claude Code Usage Boundary (Stage 1.5)

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

### 8.7 Claude Code Prompt Template (Stage 1.5)

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
- Do not treat the draft as approved. Claude verifies it in Stage 2.
```

### 8.8 Stage 1.5 Output: `ImpactScope.md`

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

### 8.9 `Overview.md` (Claude Code Draft — Verified By Claude In Stage 2)

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

### 8.10 `Logic.md` (Claude Code Draft — Verified By Claude In Stage 2)

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

## 9. Stage 2 — Claude Design Verification And Contract Lock

### 9.1 Role

Claude acts as the senior architect and design verifier.

Claude receives:

- `ImpactScope.md`
- `Overview.md` (Claude Code draft)
- `Logic.md` (Claude Code draft)
- `ImpactScope.md`
- current business requirement
- filtered rule summaries from the context snapshot
- full governance rules only when the context snapshot requires them
- relevant project rules
- financial safety requirements
- existing SOP references if needed

Claude verifies the Claude Code draft first, then produces:

- verified/corrected `Overview.md`
- verified/corrected `Logic.md`
- `TestPlan.md`
- `ChangeContract.md`

Claude may correct minor drafting errors directly in `Overview.md`/`Logic.md`. If the draft reveals an incomplete impact scope (missed files, missed dependencies, missed RLS/migration impact), Claude must loop back to Stage 1.5 (or Stage 1 if the gap traces back to Cursor's original scan) rather than patching around the gap.

`ChangeContract.md` produced here is a draft. It does not become binding until the human approves it in the standalone Stage 3 (Human Approval) below — Claude's job in Stage 2 is to make the boundary approvable, not to approve it.

### 9.2 Stage 2 Must Not Do

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
- silently resolve an "Open Question For Claude" without recording the decision in the verified document.

### 9.3 Claude Verifies Claude Code's `Overview.md` Draft

Claude checks the Claude Code draft (template in 8.5) against:

- master architecture, naming, and domain conventions;
- whether "Affected Domains" and "Affected Files From Claude Code" match the actual repo state;
- whether "Non-Goals" / "Out Of Scope" correctly exclude adjacent scopes;
- whether "Financial Impact Class" and "Risk Summary" are consistent with the real invariants at stake;
- whether every "Open Questions For Claude" entry has been answered or explicitly deferred with a reason;
- whether wording could be misread as implementation authorization.

Claude updates `## Draft Status` to `Verified (Claude)` only after these checks pass, and records any correction made.

### 9.4 Claude Verifies Claude Code's `Logic.md` Draft

Claude checks the Claude Code draft (template in 8.6) against:

- idempotency, duplicate-prevention, timeout, and unknown-state handling required by project financial rules;
- whether the state model matches the actual schema/RPC behavior (not just the intended design);
- whether audit ledger / evidence / RLS rules are complete and consistent with master rules;
- whether "Prohibited Behavior" covers the real failure modes for this domain;
- whether every "Open Questions For Claude" entry has been answered or explicitly deferred with a reason.

Claude updates `## Draft Status` to `Verified (Claude)` only after these checks pass, and records any correction made.

### 9.5 `TestPlan.md`

Purpose:

- Define required tests before implementation.
- Prevent Claude Code from creating only happy-path tests.

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

### 9.6 `ChangeContract.md`

Purpose:

- Lock the implementation boundary.
- Tell Claude Code what it may and may not touch.
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

Claude Code must receive the smallest executable operation set that can satisfy the change.

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

### 9.7 Claude Design Prompt Template

```text
You are the senior architect and design verifier for a financial-grade SaaS system.

Input:
- ImpactScope.md
- Overview.md (Claude Code draft)
- Logic.md (Claude Code draft)
- ImpactScope.md
- user requirement
- project rules

Verify first:
- Check Overview.md and Logic.md against master rules, the real repo state, and every "Open Questions For Claude" entry.
- Correct minor drafting errors directly. If the impact scope itself is incomplete, stop and send the change back to Stage 1.5 instead of designing around the gap.
- Mark Overview.md / Logic.md Draft Status as Verified (Claude) only after checks pass.

Then create:
1. TestPlan.md
2. ChangeContract.md

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

---

## 10. Stage 3 — Human Approval

### 10.1 Role

The human is the approval gate between design and implementation.

The human receives the full Stage 2 design pack:

- `ImpactScope.md`
- verified `Overview.md`
- verified `Logic.md`
- `TestPlan.md`
- draft `ChangeContract.md`

The human reviews the design pack and decides the exact file boundary Codex may touch. This is a standalone stage, not a line item inside Stage 2 — Claude producing a design pack does not itself authorize implementation.

### 10.2 Why This Is A Standalone Stage

Folding human approval into Stage 2 makes it easy to treat "Claude finished the design pack" as equivalent to "a human approved implementation." They are not the same event. Keeping Stage 3 separate forces an explicit, timestamped decision to exist before Codex is allowed to touch any file, and gives that decision its own artifact instead of a buried checkbox.

### 10.3 Stage 3 Output

As of 2026-07-10, `ChangeContract.md` is the single merged artifact — there is no separate standalone approval file. Stage 3 is satisfied by:

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

### 10.5 Stage 3 Pass Criteria

Stage 3 passes only when:

- The human has read `Overview.md`, `Logic.md`, `TestPlan.md`, and `ChangeContract.md` (not just skimmed the file list).
- Allowed Files and Allowed Operations are both explicit and narrower than "the whole module."
- Any "Open Questions For Claude" left unresolved in the design pack are either answered here or explicitly deferred with a documented reason.
- The approval artifact carries the active `CHANGE_ID`.

If the human is not ready to approve, the change returns to Stage 2 (design gap) or Stage 1.5 (scope gap) per the Loopback Rules in Section 18.

---

## 11. Stage 4 — Codex Isolated Implementation

As of 2026-07-10, Codex is the Stage 4 implementer, reintroduced as a subordinate execution tool under Claude's governance. Codex holds no authority to self-approve, self-stage, or self-commit anything — its output is a self-report, not a completion proof, and is not binding until Stage 5 (Claude Code, a different model, cross-model re-verification) and Stage 6 (Claude, independent audit) both review it.

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
- Never self-approve, self-stage, or self-commit — Codex's job ends at producing the diff and its self-report; Stage 5/6 review is mandatory before anything downstream trusts it.

### 11.3 Codex Prompt Template

```text
You are the restricted implementer. You have no authority to approve,
stage, or commit anything — a different model independently
re-verifies your work in Stage 5 before Claude's Stage 6 audit can
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
- If you need another file, stop and request a new Stage 3 boundary approval.
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

### 11.5 Stage 4 Output: `ImplementationModule.md`

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

If a deviation requires a new file, new migration, new permission, or wider domain impact, implementation must stop and return to Stage 2 for redesign and a new Stage 3 approval.

---

## 12. Stage 5 — Claude Code Independent Re-Verification

As of 2026-07-10, Stage 5 is a cross-model check, not self-verification: Codex (Stage 4) wrote the implementation, and Claude Code (a different model) independently re-verifies it here. This is a deliberate diversity safeguard, same rationale as Stage 5.5 below and §26 Adversarial Audit Pass Requirement.

### 12.1 Role

Stage 5 is not an AI judgment stage.

It is a mechanical verification stage, performed against Codex's Stage 4 implementation.

It is performed by Claude Code using the direct terminal and, where applicable, the CI pipeline.

Within Stage 5, Claude Code acts only as a command runner and evidence collector — it did not write the code being verified, and must not treat its own Stage 5 pass as proof the implementation is correct beyond what the raw commands actually show (see §25 Reality-Verification Requirement).

Claude Code must not interpret, auto-fix, or rewrite results unless the process explicitly returns to Stage 1, Stage 1.5, Stage 2, or Stage 3 with a new approved cycle.

### 12.2 Why Claude Code Is Not The Judge

Claude Code can execute commands, but it should not be trusted to decide financial correctness.

In Stage 5, Claude Code is only:

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

### 12.3 Stage 5 Command Categories

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

### 12.5 Claude Code Terminal Prompt For Stage 5

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

### 12.6 Stage 5 Output: `VerificationResult.md`

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

### 12.7 Stage 5 Pass Criteria

Stage 5 passes only when:

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
- Raw logs and git diff are preserved for Stage 6.

### 12.8 Stage 5 Failure Handling

If Stage 5 fails:

1. Do not let Claude Code fix directly — it is verifying Codex's implementation, not authoring the fix.
2. Record failure in `VerificationResult.md`.
3. Preserve raw terminal output.
4. Preserve `git diff` and `git diff --name-only`.
5. Return to Stage 2 or Stage 4 depending on failure type.
6. If the failure indicates a design problem, return to Claude design (Stage 2).
7. If the failure indicates implementation bug within approved scope, return to Codex (Stage 4) with the raw failure log.
8. If new file scope is required, return to Stage 2 for redesign and a new Stage 3 human boundary approval.

### 12.9 Stage 5.5 — Cursor Minor-Opinion Review

Purpose: a second, differently-blind-spotted model reviews the same implementation and Claude Code's Stage 5 verification output, specifically looking for anything Claude Code's pass might have missed — this is the practical application of §26 (Adversarial Audit Pass Requirement): models with different training/prompting tend to catch different failure classes.

Applies to Medium/Full tier changes only (§31). Does not apply to the Lightweight track (§24) or purely mechanical fixes.

Rules:

- Cursor receives: the approved `ChangeContract.md`, the actual code diff, and Claude Code's `VerificationResult.md` from Stage 5.
- Cursor produces a short `MinorOpinion.md`: a list of any concerns, discrepancies, or questions — NOT a pass/fail verdict, NOT a gate. Cursor has no authority to block, approve, or require changes.
- If Cursor finds nothing, `MinorOpinion.md` states that explicitly (a clean pass is still a recorded output, not silence).
- Claude's Stage 6 audit MUST read `MinorOpinion.md` alongside `VerificationResult.md` and the raw diff, and MUST explicitly address (accept, investigate further, or explain why dismissed) any concern Cursor raised — silently ignoring a Cursor concern is not permitted, but Claude is not obligated to agree with it. The final ACCEPT/REJECT authority remains solely with Claude.

#### 12.9.1 Cursor Minor-Opinion Prompt Template

```text
You are giving a non-binding second opinion. You cannot block, approve,
or require changes — you can only raise concerns for Claude's Stage 6
audit to address.

You receive:
- ChangeContract.md (approved boundary)
- the actual code diff
- Claude Code's VerificationResult.md (Stage 5)

Task:
Look for anything Claude Code's Stage 5 verification might have missed:
- logic that doesn't match ChangeContract.md or Logic.md
- edge cases the verification commands didn't actually exercise
- claims in VerificationResult.md that the raw logs don't actually support
- anything that looks wrong even if the commands reported PASS

Output:
- A list of concerns/discrepancies/questions, OR
- An explicit statement that no concerns were found (do not stay silent).

You are not producing a PASS/FAIL verdict. You have no gate authority.
```

#### 12.9.2 Stage 5.5 Output: `MinorOpinion.md`

```markdown
# MinorOpinion.md

## Change ID

## Reviewed Against

- ChangeContract.md
- code diff
- VerificationResult.md (Stage 5)

## Concerns

(List each concern/discrepancy/question. If none, state explicitly: "No concerns found.")

## Not A Verdict

This document is a non-binding second opinion. It carries no approve/block authority. Claude's Stage 6 audit must explicitly address each concern above, but is not obligated to agree with it.
```

---

## 13. Stage 6 — Claude Independent Audit

### 13.1 Role

Claude performs independent audit.

As of 2026-07-10, Claude's audit is a genuine cross-model check across four separate parties: Cursor (Stage 1 scan, Stage 5.5 minor opinion), Claude Code (Stage 1.5 draft, Stage 5 re-verification), Codex (Stage 4 implementation), and Claude itself (Stage 2, Stage 6). Claude must re-verify the raw diff, raw logs, and repository evidence directly rather than trusting Codex's implementation self-report, Claude Code's Stage 5 verification report, or Cursor's Stage 1/5.5 output at face value — Claude re-derives key claims rather than accepting any prior party's summary.

Claude receives:

- `ImpactScope.md`
- `ImpactScope.md`
- `Overview.md`
- `Logic.md`
- `TestPlan.md`
- approved `ChangeContract.md`
- `ChangeContract.md` (or the filled Human Boundary Approval section)
- `ImplementationModule.md` (Codex's self-report)
- `VerificationResult.md` (Claude Code's Stage 5 cross-model re-verification)
- `MinorOpinion.md` (Cursor's Stage 5.5 non-binding second opinion, Medium/Full tier)
- raw terminal logs
- `git diff --stat`
- `git diff --check`
- `git diff --name-only`
- full or scoped `git diff`

Claude checks whether the implementation matches the plan and whether the plan itself still has hidden failure modes. `ImplementationModule.md` is Codex's self-report and `VerificationResult.md` is Claude Code's report — Claude must verify both against the raw logs and diff, not accept either at face value. Every concern raised in `MinorOpinion.md` must be explicitly addressed (accepted, investigated further, or dismissed with a stated reason) — silently ignoring a Cursor concern is not permitted, though Claude is not obligated to agree with it.

### 13.2 Audit Focus

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
- Did Cursor's Stage 1 scan miss anything Claude Code should have caught in Stage 1.5?
- Has every concern in `MinorOpinion.md` (Stage 5.5) been explicitly addressed, not silently dropped?

### 13.3 Contrarian Audit Prompt

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

### 13.4 Stage 6 Output: `AuditReview.md`

`AuditReview.md` is the confirm/audit artifact. Some teams prefer the name `implementation_confirm.md`; for payment, POS, and other runtime-truth domains in this project, `AuditReview.md` is preferred because Claude's role here is auditor, not a simple confirmation checkbox.

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

## Minor Opinion Review (Stage 5.5, Medium/Full Tier)

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

### 13.5 Stage 6 Block Criteria

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

---

## 14. Stage 7 — Human Merge And Release Evidence

### 14.1 Role

Human performs final merge and release decision.

The human reviews:

- Final diff.
- `AuditReview.md`.
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
- [ ] I reviewed AuditReview.md.
- [ ] I reviewed MinorOpinion.md, if present (Medium/Full tier), and confirmed its concerns were addressed in AuditReview.md.
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
- [ ] I reviewed AuditReview.md.
- [ ] I reviewed MinorOpinion.md, if present (Medium/Full tier), and confirmed its concerns were addressed in AuditReview.md.
- [ ] I confirmed no unresolved BLOCK finding exists.
- [ ] I confirmed rollback notes exist.
- [ ] I confirmed commit message is correct.
- [ ] I accept the remaining risk.

## Monitoring Watch

## Post-Release Notes
```

---

## 15. Recommended Document Folder Structure

For each implementation module (Full tier, §31; Medium tier consolidates these into 4 files, see §31):

These are permanent PascalCase names (see §33) — no archival renaming step happens later; the name a file is given at creation is its name for the life of the project.

```text
docs/implementation_evidence/<change_id>/
  00_CursorScan.md               (Cursor — Stage 1 raw scan, unverified, search only)
  01_ImpactScope.md              (Claude Code — Stage 1.5; merged scope + context snapshot, verifies/corrects the Cursor scan)
  02_Overview.md                 (Claude Code draft, Claude-verified)
  03_Logic.md                    (Claude Code draft, Claude-verified)
  04_TestPlan.md                 (Claude)
  05_ChangeContract.md           (Claude draft, Human-approved; merged contract + Human Boundary Approval section)
  06_ImplementationModule.md     (Codex — self-report, not a completion proof)
  07_VerificationResult.md       (Claude Code — Stage 5 cross-model re-verification of Codex, terminal / CI)
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
  08_MinorOpinion.md             (Cursor — Stage 5.5 non-binding second opinion; Medium/Full tier only)
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

## 16. Financial-Grade Rules To Put In Every Implementation Prompt (Codex, Stage 4)

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

### 18.1 Return To Stage 1 / Stage 1.5

Return to Cursor's scan (Stage 1) or Claude Code's verification/draft (Stage 1.5) if:

- New affected files are discovered.
- Dependency scope was incomplete.
- Test files were missed.
- RLS/migration impact appears.
- Provider interface dependency appears.
- Related docs or SOP references were missed.

If the gap traces back to Cursor's original scan (something Cursor should have found but didn't), return to Stage 1. If Cursor's scan was adequate but Claude Code's verification/draft missed something, return to Stage 1.5 directly.

### 18.2 Return To Stage 2

Return to Claude design verification if:

- Business logic is wrong.
- Financial edge case was missed.
- Unknown state handling is unclear.
- Rollback is not possible.
- Audit/evidence requirement changes.
- Approval scope changes.
- Master rule conflict is discovered.

### 18.3 Return To Stage 3 Human Approval

Return to Stage 3 for a new human approval if:

- Allowed file list must expand.
- Forbidden file must be touched.
- Financial impact class increases.
- New migration is needed.
- New provider dependency is introduced.
- Emergency path is needed.

### 18.4 Return To Stage 4

Return to Codex if:

- Implementation bug is found within approved scope.
- Test failure is local and design remains valid.
- Claude Audit finds fixable code-level issue.
- Verification failure is caused by code error.

### 18.5 Return To Stage 5 (And Stage 5.5, Medium/Full Tier)

Return to Claude Code's cross-model re-verification (Stage 5) after every implementation change. If the tier includes Stage 5.5, Cursor's minor-opinion review must also re-run against the new diff — a prior `MinorOpinion.md` does not cover a new diff.

No manual or AI review can substitute for rerunning automated checks.

### 18.6 Return To Stage 6

Return to Claude Audit after every new verification run.

A previous audit does not approve a new diff.

Codex's `ImplementationModule.md` is never sufficient by itself — every module must reach Stage 6 before it can be considered done.

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
- [ ] Claude Code verified Cursor's scan and produced ImpactScope.md (Stage 1.5).
- [ ] Claude Code produced Overview.md draft.
- [ ] Claude Code produced Logic.md draft.
- [ ] Context snapshot includes master anchor, required rule summaries, relevant domain references, and explicit exclusions.

## Before Implementation

- [ ] Claude verified Overview.md and Logic.md (Draft Status = Verified).
- [ ] Claude produced TestPlan.md.
- [ ] Claude produced draft ChangeContract.md.
- [ ] Human reviewed the full design pack (ImpactScope/Overview/Logic/TestPlan/ChangeContract) in Stage 3.
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
- [ ] VerificationResult.md written by Claude Code (Stage 5 cross-model re-verification of Codex's implementation).
- [ ] (Medium/Full tier) MinorOpinion.md written by Cursor (Stage 5.5), including an explicit "no concerns found" statement if applicable.

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

As of 2026-07-10, this is an eight-stage summary for Medium/Full tier changes (§31). The Lightweight track (§24) skips all of this and stays log-only.

```text
[1] Cursor Scope/Inventory Scan
    Output: raw scope/inventory report (search only)
    Rule: Search and report only. Never draft design, never write implementation code. No approval/block authority.

[1.5] Claude Code Verifies Cursor Scope And Drafts Design
    Output: ImpactScope.md (verified scope + context snapshot), Overview.md (draft), Logic.md (draft)
    Rule: Independently check Cursor's scan before trusting it. Draft design. Include master anchor plus sliced rule summaries in ImpactScope.md — do not dump the whole rule base. Never write implementation code. Flag undecided design points as Open Questions For Claude.

[2] Claude Design Verification And Contract Lock
    Output: verified Overview.md/Logic.md, TestPlan.md, draft ChangeContract.md
    Rule: Verify the Claude Code draft against master rules and repo state. Draft the allowed-file boundary — do not approve it.

[3] Human Approval
    Output: ChangeContract.md (Human Boundary Approval section filled in)
    Rule: Read the full design pack. Lock allowed files and operations. Codex may not start without this.

[4] Codex Isolated Implementation
    Output: code diff, ImplementationModule.md
    Rule: Edit only approved files, strictly within ChangeContract.md. Stop if scope expands. This is a self-report, not proof of completion. No self-approval authority.

[5] Claude Code Independent Re-Verification
    Output: VerificationResult.md, raw logs, git diff
    Rule: Cross-model check of Codex's implementation, not self-verification. Run commands. Do not fix. Do not hide errors.

[5.5] Cursor Minor-Opinion Review (Medium/Full tier)
    Output: MinorOpinion.md (concerns list or explicit clean-pass statement)
    Rule: Non-binding second opinion looking for what Stage 5 might have missed. No approval/block authority. Silence is not permitted — a clean pass must still be recorded.

[6] Claude Independent Audit
    Output: AuditReview.md (confirm/audit)
    Rule: Review raw logs and diff directly. Assume implementation is wrong. Explicitly address every MinorOpinion.md concern. Never skip this after Stage 4. Final ACCEPT/REJECT authority rests solely with Claude.

[7] Human Merge / Release
    Output: commit, ReleaseEvidence.md
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
- Claude Code must STOP and escalate to full Stage 1-3 process (formal artifacts + standalone Human Approval) when:
  - the fix requires new business-logic inference (not a mechanical correction),
  - two plausible fixes have meaningfully different tradeoffs with no clear evidence for which is correct,
  - a new forward file/migration/table/permission is needed,
  - the file touches payment, security-isolation, RLS, or financial settlement logic AND the fix is not a pure syntax correction (i.e. any semantic change to financial-grade logic always requires full process, no exception).
- Claude's Stage 6 independent audit still applies retroactively: before staging/commit of the full batch, Claude reviews the running log and spot-verifies a sample against the actual file diffs and live DB state, same as any other Stage 6 audit — this track shortens the front-end gates, not the back-end audit.

This track does not apply to designing new features, new schema, or any work outside an already-approved, already-scoped verification pass.

## 25. Reality-Verification Requirement (Doc-to-System Gap)

No Stage 6 audit may be marked ACCEPT/PASS based on document cross-references alone, no matter how internally consistent or precisely cited those references are. Every audit that closes a track touching runtime state (database schema, deployed functions, running services, external APIs) must include at least one direct, reproducible check against the actual live target — a query, a test execution, an API call, a build/compile — not just a review of prior documents' claims.

Precedent: the A4 0065 documentation track (604520-604524) was internally perfect — every cited line number and count matched exactly on independent re-derivation — yet the underlying database had zero of the claimed objects, because no step in that chain ever queried the actual database. A document chain can be flawless and still describe a system that doesn't exist. "PASS" without a reality-check timestamp and command log is not a valid Stage 6 verdict for any runtime-touching change.

## 26. Adversarial Audit Pass Requirement

For any Stage 6 audit closing a track with financial-grade, security, or cross-tenant-isolation impact, at least one audit pass must be explicitly adversarial: instructed to find a reason the prior work is wrong, not to confirm it is right. A second same-style confirmatory pass is not a substitute — models sharing similar training and prompting patterns tend to share blind spots, and repeated agreement between similar passes is evidence of correlated failure risk, not independent verification.

This project has already observed real value from disagreement between independent passes (e.g. the 021632-021642 catalog/policy split verdicts, the 070390 Audit/Closeout/Index disagreement) — genuine splits surfaced real ambiguity that a single confirmatory pass would have missed. Adversarial framing should be used deliberately, not left to accidental disagreement between differently-prompted passes.

## 27. Procedural Checks Are Automated; Human/AI Time Goes To Substantive Verification

Checks that are purely mechanical (H1-matches-filename, six-digit prefix present, forbidden-action list present, file inside allowed scope) must be enforced by scripted linting wherever possible, not by AI review time. AI review time (Claude's Stage 2/6 review, Claude Code's Stage 1/4/5 work) should be weighted toward substantive verification: does the logic actually do what it claims, does the change actually run/compile/apply, does the fix actually resolve the defect when executed.

If a review pass spends most of its content on procedural conformance and little or none on whether the underlying system actually works, that is a sign the review has drifted toward the wrong kind of value.

## 28. Documentation Governs Tests; It Does Not Replace Them

For any runtime-affecting change (SQL, RPC, application logic), the Overview/Logic/Module/TestPlan chain must reference and, where practical, trigger an actual automated test or reproducible verification script (e.g. the project's own `tools/apply_migrations.py` pattern) rather than describing test intent in prose alone. A written `TestPlan.md` that is never actually executed against a real system carries no more evidential weight than an unexecuted claim.

Where no automated test/verification tooling exists yet for a given domain, creating that tooling is itself a valid, often higher-priority Stage 1-4 deliverable than producing additional descriptive documents for the same domain.

## 29. Lightweight Decision Log (Session-Level ADR)

Significant governance or scope decisions made in conversation (e.g. "drop and rebuild an entire numbered band," "change tool authority structure," "accept a track without reality-verification because X") must be recorded in a short, append-only decision log entry — not left to exist only inside a chat transcript. Each entry: date, decision, one-paragraph rationale, what it supersedes if anything.

Precedent: this session's own "drop the entire 600000 band" decision existed only in chat history; multiple separate Claude Code sessions later had no record of it and had to be re-briefed from scratch, wasting verification time and creating risk of the decision being silently re-litigated or contradicted by a session that never received it.

This log's format and location are intentionally left for a later, separate governance decision — this section only establishes that such decisions must be recorded somewhere durable, not that they must go through the full artifact chain themselves.

## 30. Per-Module Change History (Single-File, Append-Only): `ChangeHistory.md`

Every module/component/domain (a SQL schema domain, a Flutter feature module, a governed doc bundle) must maintain exactly ONE running history log named `ChangeHistory.md`, appended to over time — never a new file per change (the 605900 pattern of one document per event is explicitly forbidden here, same reasoning as elsewhere in this pipeline).

Format (one row/entry per change): date | change description | reason/evidence | outcome | linked audit/test.

Before attempting a fix to any module that previously failed or was modified, Claude Code/Claude must first read that module's `ChangeHistory.md` in full. This is mandatory, not optional — the log exists specifically so future sessions (which have no memory of prior sessions, as demonstrated repeatedly in this project) don't repeat already-tried-and-failed approaches or re-litigate settled decisions.

Stage 6 (Claude audit) must append one entry to the relevant module's `ChangeHistory.md` upon ACCEPT of any change — this is part of closing the audit, not a separate task.

For SQL: `catchmenu_meta.migration_history` (the DB table already built this session) is the data-level history; a companion human-readable log (`sql/migrations/CHANGELOG.md`, one running file) records the narrative reasoning behind each fix (why, not just what) — the DB table answers "was X applied," the changelog answers "why was X necessary." `sql/migrations/CHANGELOG.md` is a deliberate exception to the `ChangeHistory.md` naming convention: it keeps the industry-standard lowercase `CHANGELOG.md` name because that convention is widely recognized by tooling and contributors outside this project's own governance system.

## 31. Artifact Weight Tiers

The 11-artifact full chain (`CursorScan.md` through `ReleaseEvidence.md`, §15) applies only to the Full tier. Two lighter tiers exist:

- **Lightweight tier**: §24's existing rule (log-only, no formal artifacts).
- **Medium tier**: for new features/moderate changes that are not financial-grade/security/RLS/payment-affecting. Produces 4 consolidated files instead of 11:
  - `DesignPack.md` = ImpactScope (scope + context snapshot) + Overview + Logic sections combined in one document
  - `TestAndContract.md` = TestPlan + ChangeContract sections combined
  - `ImplementationAndVerification.md` = ImplementationModule + VerificationResult sections combined
  - `AuditAndRelease.md` = AuditReview + Human Boundary Approval record + ReleaseEvidence sections combined

  All required CHANGE_ID traceability and stage gate rules (§6.11, Stage 3 approval, Stage 6 independent audit) still apply in full — only the FILE COUNT is reduced, not the review rigor.
- **Full tier** (existing 11-file chain, §15: `CursorScan` through `ReleaseEvidence`): mandatory, no exception, for any change touching payment, security-isolation, RLS, financial settlement, or cross-tenant logic — same non-negotiable list as §24's escalation criteria.

The human owner or Claude (Stage 2) selects the tier per change, stated explicitly in the `DesignPack.md` / `Overview.md`'s header.

## 32. Domain NavigationMap Requirement

Every governed domain/module (a SQL schema domain, a Flutter feature module, any folder subject to this pipeline) must maintain one `NavigationMap.md` — a single structured index, not a narrative log (that's `ChangeHistory.md`'s job, §30). Format: one row per change, columns: change ID | date | tier (lightweight/medium/full) | status (open/approved/implemented/verified/audited/released) | links to that change's actual artifact files (wherever they live).

`NavigationMap.md` answers "what changes exist in this domain and what state are they in" at a glance. `ChangeHistory.md` answers "why was each change made." These are complementary and both required — do not merge them into one file.

`NavigationMap.md` must be updated at Stage 3 (approval) and Stage 7 (release) at minimum — new row on approval, status update on release.

## 33. Pipeline Artifact Filename Convention (PascalCase-Joined)

As of 2026-07-10, every pipeline-generated artifact defined in this guide uses a PascalCase-joined filename with no underscores and no six-digit prefix: `ImpactScope.md`, `Overview.md`, `Logic.md`, `TestPlan.md`, `ChangeContract.md`, `ImplementationModule.md`, `VerificationResult.md`, `MinorOpinion.md`, `AuditReview.md`, `ReleaseEvidence.md`, `ChangeHistory.md`, `NavigationMap.md`, `CursorScan.md`, and the Medium-tier consolidated files `DesignPack.md`, `TestAndContract.md`, `ImplementationAndVerification.md`, `AuditAndRelease.md`. Per-domain rule summary cheat sheets (§6.3, §6.8) follow the same convention: `<Domain>RulesSummary.md`.

This is a distinct convention from two other naming systems already in use in this project, and does not replace either of them:

- **Project documentation** (`docs/` governed content) uses this project's own six-digit-prefixed `Title_Case_With_Underscores` convention per `000002_Naming_Rules.md` — unaffected by this section.
- **`sql/migrations/CHANGELOG.md`** is a deliberate, explicitly-noted exception (§30) — it keeps the industry-standard lowercase `CHANGELOG.md` name rather than becoming `ChangeHistory.md`, because that name is recognized by tooling and contributors outside this project's governance system.

There is no working-name/archived-name distinction and no renaming step performed later (§15.1) — a PascalCase artifact name is permanent from the moment Stage 1/1.5 creates it through however long the change remains referenced, whether the change is active or long since released.

**(2026-07-11 개정)** Stage 7 머지 승인 완료 후에는 예외적으로 `000001` §5.4.2의 영구 archive 절차가 적용되어, 통합 작업 파일로 쓰였던 산출물이 개별 승인 DocumentType 단위로 6자리 번호 문서로 이전된다. 위 문단이 말하는 "permanent from creation"은 Stage 1-6 진행 중 단계에서의 파일명 불변성을 의미하며, Stage 7 이후 영구 보관 이전 자체를 금지하지 않는다. 상세 절차는 `000001` §5.4.2 참고.

## 34. Actor Selection Rule (Cost/Capability-Based, 2026-07-11)

기존 §3(8단계 파이프라인, Stage별 소유자)과 별개로, 실무적으로 어느 도구에 어떤 작업을 맡길지에 대한 원칙:

### 34.1 Cursor — 대용량/전수 스캔

- 대용량 파일 전수 검사, 디렉토리 트리 전체 스캔, 광범위 grep에 적합.
- **제약**: 한글 파일을 처리하는 과정에서 인코딩을 자주 깨뜨리는 경향이 확인됨 (2026-07-11, 900160~179 계열 파일에서 실제 손상 사례 발견). 한글 본문이 포함된 파일의 내용을 다루는 작업에는 Cursor를 신뢰하지 말고, 인코딩 검증은 별도로 거칠 것.
- 000001 §1("Cursor must not edit Korean body text")과 일치하는 방향 — 이번 발견이 그 규칙의 실제 근거 사례가 됨.

### 34.2 Codex — 간단한 수정/검증, 비용 절감

- 단순 반복 검증(인코딩 체크, 컬럼 존재 확인, 체크섬 계산 등), 소규모 in-place 수정(§24 Lightweight Track 등)에 우선 활용.
- Claude Code보다 비용이 저렴하고 이런 작업엔 충분한 정확도.

### 34.3 Claude Code — 검증/크리티컬 작업

- 규칙 준수가 중요한 작업(ChangeContract 준수, 저자 분리 원칙, Stage 1.5/2 설계 산출물 작성), 감사·재검증 성격의 작업에 사용.
- Codex보다 느리고 비싸지만 규칙을 정확히 따르는 경향이 더 강함 — 크리티컬 경로에는 이 특성이 더 중요.

### 34.4 선택 기준 요약

| 작업 성격 | 우선 도구 |
|---|---|
| 대용량 파일/트리 전체 스캔 (한글 없음 또는 스캔만) | Cursor |
| 한글 본문이 있는 파일의 내용 검증/처리 | Cursor 지양, Codex 또는 Claude Code |
| 단순/반복 검증, 소규모 §24 수정 | Codex |
| ChangeContract 준수 구현, 규칙 정확성이 중요한 작업 | Claude Code |
| 설계/감사/최종 판단 | Claude (Stage 2/6) |

## 35. Cross-Actor Verification Expansion Rule (2026-07-11)

배경: 600210 워크패킷(Flutter 게스트 customer_id 연동)에서, Codex가 구현(Stage 4)하고 Claude Code가 검증(Stage 5)했으나, 이후 Cursor에게 독립 재검증을 별도로 시켰더니 Claude Code/Codex 둘 다 놓친 발견(하드코딩된 tenant_id/store_id가 실제 테스트 값과 동일함)이 나왔다. 이는 §3의 8단계 파이프라인이 "각 Stage를 서로 다른 행위자가 맡는다"는 원칙을 지켰음에도, 정작 최종 검증은 여전히 "구현자(Codex)를 검증한 그 한 명(Claude Code)"에게만 의존했기 때문이다 — 검증자가 1명이면 그 1명의 사각지대는 그대로 남는다.

### 35.1 원칙

Medium tier 이상(§31)의 구현이 완료되면, Stage 5(Claude Code 검증) 이후 **구현에 관여하지 않은 제3의 행위자(Cursor 우선, Cursor가 부적합하면 Codex)**에게 Eyes-Only 독립 재검증을 최소 1회 추가로 받는다. 이는 §5.5(Cursor 세컨오피니언, Full tier 한정)와 별개로, Medium tier에도 적용되는 경량 버전이다.

### 35.2 절차

1. Stage 6(Claude 감사) 이전 또는 병행하여, Cursor에게 다음을 Eyes-Only로 지시한다:
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

Medium tier 이상(§31)에서, Stage 2(Claude 검증) 완료 후 Stage 3(Human Approval) 이전에 Cursor에게 설계 문서(Overview/Logic/TestPlan/ChangeContract) 독립 재검증을 최소 1회 거친다. 이는 §35(구현 후 재검증)와 별개로 설계 단계에 적용되는 사전 버전이다.

### 36.2 전체 루프 (Medium tier 이상 표준 절차로 확정)

1. Stage 1.5(Claude Code): Overview/Logic 작성
2. Stage 2(Claude): TestPlan/ChangeContract 작성 및 검증
3. **[신설] Cursor 설계 재검증**: 위 산출물 전체를 원문 대조로 재확인. 불일치 발견 시 Claude Code가 정정 → **필요시 1~2회 반복(티키타카)** → 문서 간 완전 정합 확인될 때까지
4. Stage 3(Human): 정합화 완료된 최종본에 승인
5. Stage 4(Codex): 구현
6. **[신설] 이중 재검증**: Stage 5(Claude Code) 검증 + 별도 Cursor 독립 재검증(§35 원칙) — 구현 결과도 마찬가지로 한 명의 검증자에만 의존하지 않는다
7. Stage 6(Claude): 최종 감사

### 36.3 절차 세부

- Cursor의 설계 재검증은 Eyes-Only 원칙 그대로: 판단/설계 변경 금지, 원문 인용 기반 사실 대조 및 Open Question만 보고
- "불일치"는 다음을 포함: (a) 설계 문서가 서술한 코드 동작과 실제 라이브 코드/DB 상태가 다른 경우, (b) 여러 설계 문서(Overview/Logic/TestPlan/ChangeContract) 간 서로 다른 아키텍처를 전제하는 경우, (c) "기존 패턴 재사용"이라고 서술했으나 실제로는 새로운 조합/변형인 경우
- 반복 한도: 명시적 상한은 두지 않으나, 3회 이상 반복해도 정합 안 되면 설계 자체를 재검토(Stage 1.5로 롤백)할 신호로 간주

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

배경: §35/§36/§37이 "다른 행위자가 검증한다"는 원칙을 세웠으나, 매번 3개 행위자(Cursor/Codex/Claude Code) 전부를 동원하면 작업 적체가 발생한다(Human 관찰, 600430 워크패킷 진행 중). 검증 강도는 "이번 산출물이 실제로 무엇을 바꾸는가"에 비례해야 한다.

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

## 41. Universal Failure Audit Requirement (2026-07-13)

배경: `010554_Policy_Four_Layer_Audit_Capture_Trigger_View_OS_Log_And_Nightly_Batch_Reconciliation.md`가 이미 4계층 감사(DB 트리거/뷰-프로젝션/OS 런타임 로그/야간 배치 재조정) 모델을 정의해뒀으나, 그 적용 범위는 `PAYMENT_EVENT`/`REFUND_EVENT`/`SECURITY_EVENT` 등 명시적으로 나열된 고위험 이벤트 카탈로그(§8)에 한정되며, 문서 자체가 "이 문서는 planning-only이며 코딩을 승인하지 않는다"(§26 Runtime Deferral)고 명시한다. Human 결정(2026-07-13)은 이보다 넓은 범위를 요구한다: 위험도와 무관하게, 단순 진단성(diagnostic) 케이스가 아니라 **실제 실패(unhandled exception 등)가 발생하는 모든 경우**에 영구 기록을 요구한다.

**이번 조사 경위(Cursor+Antigravity 이중 조사, 2026-07-13)**: 최초안은 "DB + OS 파일시스템(`RAISE LOG`) 이중 기록"이었다. 조사 결과 `RAISE LOG`는 기술적으로는 작동하지만(`logging_collector = off`로 이번 턴 직접 재확인), 디스크 파일로 남지 않고 Docker의 임시 로그 스트림에만 존재하며, 마이그레이션 코드에 연결된 사례가 없다 — 컨테이너 재시작/로그 로테이션으로 유실될 수 있어 금융권 감사 목적에 부적합함이 조사로 실증됐다. 따라서 "OS 파일시스템 기록" 요구사항은 **폐기**하고, 이미 이 코드베이스에서 검증된 기존 함수 `catchmenu_audit.append_audit_record()`(→ `catchmenu_ledger.audit_records`, append-only)로 단일화한다 — 이번 턴 직접 확인한 결과 49개 마이그레이션 파일이 이미 이 함수를 사용 중이며(`grep -l` 재확인), 새 메커니즘을 만들 필요가 없다.

### 41.1 원칙 (최종 확정)

모든 RPC 함수는 `EXCEPTION` 핸들러 블록을 갖추고, 실패 발생 시 **`catchmenu_audit.append_audit_record()`를 통해 `catchmenu_ledger.audit_records`에 append-only로 영구 기록**한다. 이 경로는 이미 append-only + 영구 보존이 보장되므로 그 자체로 충분하며, 별도의 OS 파일시스템 이중 기록은 요구하지 않는다(위 배경 문단 참고 — 실현 시 오히려 더 불안정한 감사 경로가 된다는 것이 조사로 확인됨). 기록 후 원래 에러를 재발생시키거나(`RAISE`) 적절한 에러 응답을 반환한다 — 조용히 삼키지 않는다.

**`log_diagnostic()`/`diagnostic_logs`와의 구분 — 용도가 다름**: `catchmenu_common.log_diagnostic()`(→ `catchmenu_common.diagnostic_logs`)은 이번 조항이 대체하지 않는다. 이는 "비즈니스 실패는 아니지만 알아둘 만한 상황"(예: `600450`의 게스트+포인트 요청 케이스 — 주문 자체는 정상 진행되지만 클라이언트 버그 추적용으로 남기는 경고)을 위한 **진단성 경고** 채널로 별도 유지한다. `append_audit_record()`는 실제 실패(`EXCEPTION` 발생)를 위한 경로이고, `log_diagnostic()`은 실패가 아닌 정상 흐름 중의 경고를 위한 경로다 — 두 채널은 목적이 다르므로 서로 대체하지 않는다.

### 41.2 §010554와의 관계 — 범위가 다르지 대체가 아님

§010554의 4계층 모델(DB 트리거/뷰-프로젝션/OS 로그/야간 배치)은 **고위험 이벤트 카탈로그**(결제/환불/보안/AI/내보내기 등)에 계속 적용된다 — 이번 §41이 그것을 대체하거나 축소하지 않는다. §41은 그보다 **낮은 문턱**에서 적용되는 별개의 요구사항이다: "이 이벤트가 고위험 카탈로그에 속하는가"와 무관하게, "이 RPC 호출이 처리되지 않은 예외로 실패했는가"만을 기준으로 삼는다. 즉 §010554는 이벤트의 *종류*로 범위를 정하고, §41은 실행의 *결과*(실패 여부)로 범위를 정한다 — 두 기준은 서로 겹칠 수 있으나(예: 결제 RPC의 unhandled exception은 양쪽 모두 해당) 어느 한쪽이 다른 쪽을 포함하지 않는다.

### 41.3 적용 범위

신규/수정되는 함수부터 우선 적용한다 — `600450_place_takeout_order_unassigned_record_fix`의 `place_takeout_order()`가 첫 적용 대상 후보다. 기존 함수 전체에 대한 소급 적용은 이번 조항의 범위가 아니며, 별도 백필(backfill) 워크패킷으로 분리한다.
