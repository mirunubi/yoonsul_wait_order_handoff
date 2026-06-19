# 051355_Guide_AI_Assisted_Financial_Grade_Development_Pipeline_Cursor_Claude_Codex_Automated_Gate_And_Human_Merge.md

## 1. Purpose

This guide defines the AI-assisted financial-grade development pipeline for `yoonsul_wait_order_handoff`.

The goal is to combine Cursor, Claude, Codex, automated verification, and human approval into one controlled development process that can support a financial-grade SaaS system where:

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
- The compressed six-stage operating loop is preserved for daily execution speed.
- The human boundary approval line remains mandatory before Codex touches code.
- Context Snapshot injection is mandatory before Claude design work.
- Raw terminal logs and git diff must be handed to Claude without AI summarization.
- Allowed Operations must be narrower than Allowed Files.
- Every audit and evidence artifact must map back to the active `CHANGE_ID`.
- MVV may not be used for RLS, database migration, financial, provider, audit, evidence, access-control, or production-release changes.
- Context Snapshot must be dieted by cheat sheets, domain slicing, and Cursor-discovered rule references so Claude receives only the relevant rule boundary.
- Full master rules are governance anchors; AI injection should prefer short rule summaries unless a conflict or audit requires the full document.
- Stage 1 must discover not only affected code and docs, but also the minimal rule files needed for Stage 2.
- Stage 4 raw logs should be saved to `raw_logs/` by shell redirection or task scripts so Claude can audit exact terminal output without copy-paste loss.
- Each major domain folder should maintain a thin `_Rules_Summary.md` cheat sheet so future development uses sliced context instead of dumping thousands of planning documents.
- When this guide is adopted as mandatory governance, it should be placed under `sop/system/` and treated as the project development constitution.

---

## 2. Operating Thesis

The project uses AI tools as a divided-control development system.

```text
Cursor sees.
Claude thinks.
Codex edits.
Cursor measures.
Claude judges.
Human owns.
```

No single AI tool is allowed to be trusted as the final authority.

The pipeline is designed around role separation:

- Cursor is strong at repository search, dependency discovery, and terminal execution.
- Claude is strong at architecture, planning, reasoning, and audit.
- Codex is strong at narrow implementation when file scope is locked.
- Automated commands are strong at mechanical verification.
- Human ownership is required for final merge, release, and production risk acceptance.

The resulting process is a six-stage integrity loop.

---

## 3. Final Six-Stage Integrity Loop

```text
[1] Cursor Boundary Scan        -> "Eyes"
    - 영향 파일 검색
    - dependency / import / route / SQL / RLS / test 위치 확인
    - 관련 MD / SOP / policy / index 위치 확인
    - 절대 코딩 금지
    - Output: impact_scope.md

    ↓ context snapshot handoff

[2] Claude Design Pack         -> "Brain"
    - overview.md 생성
    - logic.md 생성
    - test_plan.md 생성
    - change_contract.md 생성
    - 프로젝트 마스터 규칙 준수
    - 허용/금지 파일 목록 작성
    - rollback 기준 작성
    - Human approval line 포함
    - Output: design_pack + approved change_contract.md

    ↓ approved boundary handoff

[3] Codex Isolated Implementation -> "Hands"
    - 지정된 바운더리 내부 구현
    - 작은 diff 유지
    - 불필요한 리팩토링 금지
    - 구현 후 implementation_module.md 생성
    - Output: code diff + implementation_module.md

    ↓ raw verification handoff

[4] Cursor Mechanical Gate      -> "Ruler"
    - 터미널 operator로서 빌드/테스트 실행
    - lint / typecheck / test / migration dry-run / RLS/security check
    - idempotency / duplicate / unknown-state test
    - raw terminal log 수집
    - git diff / git diff --stat / git diff --check 수집
    - Output: verification_result.md + raw logs + git diff

    ↓ raw log + diff handoff

[5] Claude Independent Audit    -> "Judge"
    - implementation_module.md 검토
    - verification_result.md 검토
    - raw terminal error log 검토
    - git diff 직접 검토
    - 3,000개 규칙 매칭
    - 금융 사고 반례 시나리오 교차 감사
    - Output: audit_review.md

    ↓ owner decision handoff

[6] Human Merge / Release       -> "Owner"
    - 최종 diff 직접 확인
    - audit_review.md 확인
    - verification_result.md 확인
    - unresolved BLOCK 없음 확인
    - commit / merge / release 승인
    - Output: human_merge_checklist.md + release_evidence.md
```

This six-stage form is the daily execution version of the pipeline. It intentionally compresses the earlier seven-stage version by embedding the human implementation approval inside Stage 2 as an explicit approval line rather than treating it as a separate full stage.

---

## 4. Core Rule

```text
No AI edits without scope.
No scope without design.
No design without test plan.
No implementation without allowed files.
No verification without raw logs.
No audit without git diff.
No merge without human owner decision.
No financial change without evidence.
```

The final authority for financial correctness is not an AI answer.

The final authority is the combined evidence of:

1. Cursor impact scope.
2. Claude design pack.
3. Human-approved file boundary.
4. Codex limited implementation.
5. Mechanical verification output.
6. Raw logs and git diff.
7. Claude independent audit.
8. Human merge and release decision.
9. Release evidence.

---

## 5. Stage Output Map

| Stage | Owner | Role Name | Main Output | Main Risk Controlled |
|---:|---|---|---|---|
| 1 | Cursor | Eyes | `impact_scope.md` | Wrong file scope, missed dependency, hidden test/RLS/migration impact |
| 2 | Claude + Human approval line | Brain | `overview.md`, `logic.md`, `test_plan.md`, `change_contract.md` | Poor design, hidden financial risk, ambiguous scope |
| 3 | Codex | Hands | Code diff, `implementation_module.md` | Incorrect implementation, broad refactor, unauthorized changes |
| 4 | Cursor terminal / local terminal / CI | Ruler | `verification_result.md`, raw logs, git diff | Type errors, test failures, migration/RLS/security gaps hidden by summaries |
| 5 | Claude | Judge | `audit_review.md` | Logic mismatch, financial accident scenario, evidence gap, false confidence |
| 6 | Human | Owner | Commit, merge, `release_evidence.md` | Blind merge, uncontrolled production release, unowned risk |

---

## 6. Mandatory Context Snapshot Between Stage 1 And Stage 2

### 6.1 Why This Exists

In a 3,000-document repository, an impact scope report alone is not enough.

If Claude receives only `impact_scope.md` and a change request, it may design a solution that is locally plausible but globally inconsistent with project architecture, naming rules, file conventions, DB constraints, RLS policy patterns, evidence rules, or financial safety rules.

However, the opposite failure is also dangerous.

If every design cycle injects the entire rule base, Claude may suffer from context bloat, irrelevant-rule fixation, and lost-in-the-middle behavior. Token cost increases, attention quality drops, and the current module's core risk may be diluted by unrelated governance text.

Therefore, the context snapshot must not mean "dump every rule document." It means "inject the smallest rule-complete bundle needed for this change."

### 6.2 Context Snapshot Diet Rule

When moving from Cursor Stage 1 to Claude Stage 2, always provide a context snapshot bundle.

The bundle must be:

- Complete enough to prevent architecture drift.
- Small enough to prevent token bloat.
- Traceable enough to explain why each rule file was included.
- Explicit enough to state which rules were excluded and why.

The preferred order is:

```text
1. impact_scope.md
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

Recommended pattern:

```text
Full governance rule:
  <domain>_Policy_Guide.md

AI injection summary:
  <domain>_Rules_Summary.md
```

Example:

```text
Full rule:
  RLS_Policy_Guide.md

Summary injected into context snapshot:
  RLS_Rules_Summary.md
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

### 6.5 Cursor-Assisted Rule Filtering

Stage 1 must search for applicable rule files as part of the boundary scan.

Cursor must not only find code, SQL, tests, and documents. It must also identify the minimal rule files needed for Stage 2.

Stage 1 must ask:

```text
Which master index, domain index, rule summary, SOP, Policy, Matrix, Checklist, or governance file must Claude receive to design this change safely?
```

The result should be written into `impact_scope.md` under a dedicated section:

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

This allows Stage 1 to act as the first context filter. Stage 2 then consumes only the filtered snapshot rather than the entire 3,000-document base.

### 6.6 Context Snapshot Output

The handoff from Stage 1 to Stage 2 should include a small manifest.

```markdown
# context_snapshot.md

## Change ID

## Included Scope File

- impact_scope.md

## Module Domain Tags

- POS_GATEWAY / PAYMENT / DB / RLS / FLUTTER_UI / AUDIT_EVIDENCE / SETTLEMENT / DOCUMENTATION_ONLY / OTHER

## Included Master Anchor

- <master index path>

## Included Rule Summaries

- <code convention summary path>
- <db constraint summary path if applicable>
- <RLS/security summary path if applicable>
- <idempotency summary path if applicable>
- <audit/evidence summary path if applicable>

## Included Full Rules

- <full rule path if required>

## Included Domain References

- <domain index path>
- <module matrix path>
- <related SOP / Policy / Checklist path>

## Excluded References

| Excluded Rule Family | Reason |
|---|---|
| <rule family> | Not applicable to this module / summary sufficient / no schema change / no UI impact |

## Context Budget Decision

LEAN / NORMAL / FULL

## Known Gaps

## Snapshot Decision

READY_FOR_CLAUDE_DESIGN / BLOCKED_NEED_MORE_CONTEXT
```

Use `LEAN` when summary files are sufficient. Use `NORMAL` when a small number of full rules are also required. Use `FULL` only for cross-domain financial, RLS, migration, provider, audit, or release changes where summaries are not enough.

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
# <Domain>_Rules_Summary.md

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

Recommended summary targets:

- `Code_Convention_Rules_Summary.md`
- `DB_Constraint_And_Migration_Rules_Summary.md`
- `RLS_And_Security_Rules_Summary.md`
- `Financial_Idempotency_And_Duplicate_Prevention_Rules_Summary.md`
- `Audit_Ledger_And_Evidence_Packet_Rules_Summary.md`
- `POS_Gateway_And_Provider_Callback_Rules_Summary.md`
- `Flutter_UI_State_And_Finality_Message_Rules_Summary.md`
- `Documentation_Naming_Index_And_Crosslink_Rules_Summary.md`

### 6.8.1 Domain Folder Summary Rule For The Remaining Document Buildout

When new planning, policy, SOP, or implementation-readiness documents are added at scale, each major domain folder should also carry one thin rule summary file.

The purpose is not to duplicate the full documents. The purpose is to give Stage 1 an easy file to discover and Stage 2 a small rule packet to consume.

Recommended placement pattern:

```text
<domain_folder>/
  <domain>_Rules_Summary.md
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
Cursor discovers candidate rule files.
Claude designs only inside the selected rule boundary.
```

---

## 6.11 CHANGE_ID Traceability Rule

Every document, code comment where appropriate, audit ledger event, evidence packet, verification result, and release record must carry the same active `CHANGE_ID`.

The `CHANGE_ID` is the spine of the implementation packet.

Required mapping:

| Artifact | Required `CHANGE_ID` Position | Failure Meaning |
|---|---|---|
| `impact_scope.md` | `## Change ID` | Scope cannot be tied to implementation. |
| `context_snapshot.md` | `## Change ID` | Claude may use wrong master rules. |
| `overview.md` | `## Change ID` | Business purpose cannot be audited. |
| `logic.md` | `## Change ID` | Runtime logic cannot be tied to implementation. |
| `test_plan.md` | `## Change ID` | Tests cannot be proven relevant. |
| `change_contract.md` | `## Change ID` | Approval scope cannot be enforced. |
| `implementation_module.md` | `## Change ID` | Code diff cannot be tied to contract. |
| `verification_result.md` | `## Change ID` | Raw log cannot be tied to diff. |
| `audit_review.md` | `## Change ID` | Audit cannot approve the correct change. |
| audit ledger event | `change_id` or equivalent metadata | Runtime event cannot be traced. |
| evidence packet manifest | `change_id` field | Evidence cannot be found later. |
| release evidence | `Change ID:` | Release cannot be reconstructed. |

If any artifact has a missing, conflicting, or stale `CHANGE_ID`, the pipeline must stop.

This is not a documentation defect.

It is an auditability failure.

---

## 7. Mandatory Raw Log And Git Diff Handoff Between Stage 4 And Stage 5

### 7.1 Why This Exists

Stage 4 is a mechanical verification stage, not a judgment stage.

If a command fails and the failure is summarized by Cursor or another AI tool, the most important details may be lost:

- exact type error line;
- migration failure line;
- RLS violation output;
- failed assertion;
- duplicate-key constraint detail;
- unauthorized file drift;
- encoding drift;
- formatter side effect;
- stack trace showing wrong module boundary.

For this reason, Stage 5 Claude Audit must receive raw terminal output and raw `git diff`, not only a friendly summary.

### 7.2 Raw Handoff Rule

The Stage 4 output must include:

```text
1. verification_result.md
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

### 7.3 Cursor Must Not Hide Errors

Cursor must not be asked:

```text
Did it succeed?
Can you fix it?
Summarize the error briefly.
```

Cursor must be asked:

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
  08_verification_result.md
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

### 7.5 Stage 5 Audit Input Rule

Claude Audit must receive `raw_logs/` and `git diff` directly.

Claude must not rely on `verification_result.md` alone.

---

## 8. Stage 1 — Cursor Boundary Scan

### 8.1 Role

Cursor is used as a codebase scout.

Its job is to find:

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

Cursor must not modify code in this stage.

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

Forbidden:

- Editing code.
- Formatting files.
- Rewriting Korean Markdown.
- Running broad refactors.
- Changing encoding.
- Running automated fixes.
- Modifying generated files.
- Modifying lock files unless explicitly approved.
- Guessing that a file is safe without checking references.

### 8.3 Cursor Prompt Template

```text
You are only allowed to search and report.

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
- Return only a structured impact report.
```

### 8.4 Stage 1 Output: `impact_scope.md`

```markdown
# impact_scope.md

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

## Required Context Snapshot Candidates

### Master Anchor

### Rule Summaries

### Full Rules Required

### Domain Indexes

### Excluded Rule Families

## Risk Notes

## Uncertainties

## Files Cursor Must Not Modify
```

---

## 9. Stage 2 — Claude Design Pack And Boundary Approval

### 9.1 Role

Claude acts as the senior architect.

Claude receives:

- `impact_scope.md`
- `context_snapshot.md`
- current business requirement
- filtered rule summaries from the context snapshot
- full governance rules only when the context snapshot requires them
- relevant project rules
- financial safety requirements
- existing SOP references if needed

Claude produces:

- `overview.md`
- `logic.md`
- `test_plan.md`
- `change_contract.md`

The human then confirms the approved file boundary inside the Stage 2 package before Codex is allowed to implement.

This keeps the daily loop at six stages while preserving the essential approval control.

### 9.2 Stage 2 Must Not Do

Claude must not:

- write implementation code;
- broaden the change scope casually;
- invent new architecture standards;
- rename files outside the approved naming system;
- create new DB conventions without explicit approval;
- weaken RLS/security/evidence requirements;
- skip tests because the change looks small;
- hide financial risk behind generic wording.

### 9.3 `overview.md`

Purpose:

- Explain the change at a high level.
- Define business goal.
- Define affected modules.
- Define non-goals.
- Define financial impact.
- Define risk level.

```markdown
# overview.md

## Change ID

## Business Purpose

## User / Store / Provider Impact

## Financial Impact Class

## Affected Domains

## Affected Files From Cursor

## Context Snapshot Used

## Non-Goals

## Expected Behavior

## Out Of Scope

## Risk Summary

## Required Approvals
```

### 9.4 `logic.md`

Purpose:

- Define exact runtime logic before coding.
- Make money-moving state transitions explicit.
- Prevent hidden behavior.

```markdown
# logic.md

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
```

### 9.5 `test_plan.md`

Purpose:

- Define required tests before implementation.
- Prevent Codex from creating only happy-path tests.

```markdown
# test_plan.md

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

### 9.6 `change_contract.md`

Purpose:

- Lock the implementation boundary.
- Tell Codex what it may and may not touch.
- Preserve a human approval line before implementation begins.

```markdown
# change_contract.md

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
| New test file creation | ALLOWED / FORBIDDEN | Default: ALLOWED only when named in test_plan.md. |
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

### 9.7 Human Approval Statement Inside Stage 2

```text
Approved for implementation.

Allowed files:
- <file 1>
- <file 2>
- <file 3>

Forbidden:
- all other files
- docs/** unless explicitly approved
- generated files unless explicitly approved
- lock files unless explicitly approved
- Korean Markdown files unless explicitly approved
- unrelated modules

Codex may implement only the approved change_contract.md.
```

### 9.8 Claude Design Prompt Template

```text
You are the senior architect for a financial-grade SaaS system.

Input:
- impact_scope.md
- context_snapshot.md
- user requirement
- project rules

Create:
1. overview.md
2. logic.md
3. test_plan.md
4. change_contract.md

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

## 10. Stage 3 — Codex Isolated Implementation

### 10.1 Role

Codex acts as the restricted implementer.

Codex receives:

- `impact_scope.md`
- `context_snapshot.md`
- `overview.md`
- `logic.md`
- `test_plan.md`
- approved `change_contract.md`

Codex implements only within the allowed scope.

### 10.2 Codex Rules

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
- Add or update tests required by `test_plan.md`.
- Generate `implementation_module.md` after implementation.

### 10.3 Codex Prompt Template

```text
You are the restricted implementer.

Use only:
- impact_scope.md
- context_snapshot.md
- overview.md
- logic.md
- test_plan.md
- approved change_contract.md

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
- Add or update tests listed in test_plan.md.
- If you need another file, stop and request a new Stage 2 boundary approval.
- After implementation, create implementation_module.md.

Output:
- code changes
- implementation_module.md
```

### 10.4 Code Simplicity Rules

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

### 10.5 Stage 3 Output: `implementation_module.md`

```markdown
# implementation_module.md

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

## Deviations From change_contract.md
```

If there are deviations from `change_contract.md`, Codex must list them explicitly.

Hidden deviation is not allowed.

If a deviation requires a new file, new migration, new permission, or wider domain impact, implementation must stop and return to Stage 2.

---

## 11. Stage 4 — Cursor Mechanical Verification Gate

### 11.1 Role

Stage 4 is not an AI judgment stage.

It is a mechanical verification stage.

It should be performed by:

- Direct terminal, or
- Cursor terminal, or
- CI pipeline.

Cursor may be used only as a command runner.

Cursor must not interpret, auto-fix, or rewrite results unless the process explicitly returns to Stage 1, Stage 2, or Stage 3 with a new approved cycle.

### 11.2 Why Cursor Is Not The Judge

Cursor can execute commands, but it should not be trusted to decide financial correctness.

In Stage 4, Cursor is only:

```text
Terminal operator.
Command runner.
Raw log collector.
Diff collector.
Result recorder.
```

Cursor is not:

```text
Code fixer.
Architect.
Auditor.
Financial risk reviewer.
Final judge.
```

### 11.3 Stage 4 Command Categories

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

### 11.4 Example Verification Commands

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

### 11.5 Cursor Terminal Prompt For Stage 4

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

### 11.6 Stage 4 Output: `verification_result.md`

```markdown
# verification_result.md

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

### 11.7 Stage 4 Pass Criteria

Stage 4 passes only when:

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
- Raw logs and git diff are preserved for Stage 5.

### 11.8 Stage 4 Failure Handling

If Stage 4 fails:

1. Do not let Cursor fix directly.
2. Record failure in `verification_result.md`.
3. Preserve raw terminal output.
4. Preserve `git diff` and `git diff --name-only`.
5. Return to Stage 2 or Stage 3 depending on failure type.
6. If the failure indicates a design problem, return to Claude design.
7. If the failure indicates implementation bug within approved scope, return to Codex with the raw failure log.
8. If new file scope is required, return to Stage 2 for a new human boundary approval.

---

## 12. Stage 5 — Claude Independent Audit

### 12.1 Role

Claude performs independent audit.

Claude receives:

- `impact_scope.md`
- `context_snapshot.md`
- `overview.md`
- `logic.md`
- `test_plan.md`
- approved `change_contract.md`
- `implementation_module.md`
- `verification_result.md`
- raw terminal logs
- `git diff --stat`
- `git diff --check`
- `git diff --name-only`
- full or scoped `git diff`

Claude checks whether the implementation matches the plan and whether the plan itself still has hidden failure modes.

### 12.2 Audit Focus

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

### 12.3 Contrarian Audit Prompt

```text
Assume the implementation is wrong.

Review:
- implementation_module.md
- verification_result.md
- raw terminal logs
- git diff --stat
- git diff --check
- git diff --name-only
- full git diff
- context_snapshot.md
- change_contract.md

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

### 12.4 Stage 5 Output: `audit_review.md`

```markdown
# audit_review.md

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

### 12.5 Stage 5 Block Criteria

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
- Implementation conflicts with master rules from `context_snapshot.md`.

---

## 13. Stage 6 — Human Merge And Release Evidence

### 13.1 Role

Human performs final merge and release decision.

The human reviews:

- Final diff.
- `audit_review.md`.
- `verification_result.md`.
- Raw logs for failed or risky commands.
- Any remaining risks.
- Commit message.
- Release evidence.

### 13.2 Human Merge Checklist

```markdown
# human_merge_checklist.md

## Change ID

- [ ] I reviewed git diff.
- [ ] I confirmed only approved files changed.
- [ ] I reviewed implementation_module.md.
- [ ] I reviewed verification_result.md.
- [ ] I confirmed raw logs exist for required commands.
- [ ] I reviewed audit_review.md.
- [ ] I confirmed no unresolved BLOCK finding exists.
- [ ] I confirmed rollback notes exist.
- [ ] I confirmed release evidence exists.
- [ ] I confirmed commit message is correct.
- [ ] I accept the remaining risk.
```

### 13.3 Commit Message Format

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

### 13.4 Release Evidence

```markdown
# release_evidence.md

## Change ID

## Release Decision

APPROVED / BLOCKED / DEFERRED

## Commit Hash

## Merge Target

## Verification Reference

## Audit Reference

## Raw Log Reference

## Rollback Reference

## Monitoring Watch

## Post-Release Notes
```

---

## 14. Recommended Document Folder Structure

For each implementation module:

```text
docs/implementation_evidence/<change_id>/
  01_impact_scope.md
  02_context_snapshot.md
  03_overview.md
  04_logic.md
  05_test_plan.md
  06_change_contract.md
  07_implementation_module.md
  08_verification_result.md
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
  09_audit_review.md
  10_human_merge_checklist.md
  11_release_evidence.md
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

---

## 15. Financial-Grade Rules To Put In Every Codex Prompt

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

## 16. Financial Accident Scenarios To Test

### 16.1 Payment

- Same payment request twice.
- Provider timeout after successful charge.
- Callback arrives after user retry.
- Duplicate callback.
- Cancel request after unknown approval.
- Provider says pending but internal retry starts.
- Customer-facing UI marks payment final before provider finality.

### 16.2 Refund / Reversal

- Refund request timeout.
- Refund pending beyond SLA.
- Refund retry while prior refund unknown.
- Reversal success but callback delayed.
- Customer message says complete too early.
- Partial refund state is misread as full refund.

### 16.3 Settlement / Reconciliation

- Missing POS file.
- Missing PG/VAN file.
- Duplicate settlement file.
- Corrected settlement file.
- Control total mismatch.
- Close attempted with unresolved exception.
- Reconciliation result is overwritten without audit event.

### 16.4 Payout / Bank

- Bank confirmation unknown.
- Bank file duplicate.
- Payout retry after unknown bank status.
- Store bank account changed before payout.
- Maker and checker are same actor.
- Rejection/return reason unmapped.
- Same payout batch submitted twice.

### 16.5 Audit / Evidence

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
- `verification_result.md` references a different `CHANGE_ID` than `implementation_module.md`.
- Release evidence cannot be matched to the approved `change_contract.md`.

---

## 17. Loopback Rules

The pipeline is not always linear.

### 17.1 Return To Stage 1

Return to Cursor boundary scan if:

- New affected files are discovered.
- Dependency scope was incomplete.
- Test files were missed.
- RLS/migration impact appears.
- Provider interface dependency appears.
- Related docs or SOP references were missed.

### 17.2 Return To Stage 2

Return to Claude design if:

- Business logic is wrong.
- Financial edge case was missed.
- Unknown state handling is unclear.
- Rollback is not possible.
- Audit/evidence requirement changes.
- Approval scope changes.
- Master rule conflict is discovered.

### 17.3 Return To Stage 2 Boundary Approval

Return to Stage 2 human boundary approval if:

- Allowed file list must expand.
- Forbidden file must be touched.
- Financial impact class increases.
- New migration is needed.
- New provider dependency is introduced.
- Emergency path is needed.

### 17.4 Return To Stage 3

Return to Codex if:

- Implementation bug is found within approved scope.
- Test failure is local and design remains valid.
- Claude Audit finds fixable code-level issue.
- Verification failure is caused by code error.

### 17.5 Return To Stage 4

Return to mechanical gate after every implementation change.

No manual or AI review can substitute for rerunning automated checks.

### 17.6 Return To Stage 5

Return to Claude Audit after every new verification run.

A previous audit does not approve a new diff.

---

## 18. Minimum Viable Version For Early Development

When the full pipeline is heavy, use this minimum version:

```text
1. Cursor: 영향 파일 찾기
2. Claude: context_snapshot + overview.md + logic.md + test_plan.md + allowed files
3. Codex: approved files only 구현 + implementation_module.md
4. Terminal/Cursor: git diff --check / flutter analyze / dart test + raw logs
5. Claude: raw logs + git diff + module + test result 감리
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

## 19. Daily Operating Checklist

```markdown
# daily_ai_development_loop_checklist.md

## Before Implementation

- [ ] Cursor produced impact_scope.md without editing files.
- [ ] Context snapshot includes master anchor, required rule summaries, relevant domain references, and explicit exclusions.
- [ ] Claude produced overview.md.
- [ ] Claude produced logic.md.
- [ ] Claude produced test_plan.md.
- [ ] Claude produced change_contract.md.
- [ ] Human approved allowed files.

## During Implementation

- [ ] Codex edited only allowed files.
- [ ] Codex kept diff small.
- [ ] Codex avoided broad refactor.
- [ ] Codex created implementation_module.md.

## Verification

- [ ] git diff --stat captured.
- [ ] git diff --check captured.
- [ ] git diff --name-only captured.
- [ ] git diff captured.
- [ ] lint/typecheck/test commands run.
- [ ] migration/RLS/security checks run where applicable.
- [ ] raw logs preserved.
- [ ] verification_result.md written.

## Audit And Merge

- [ ] Claude reviewed implementation_module.md.
- [ ] Claude reviewed verification_result.md.
- [ ] Claude reviewed raw logs.
- [ ] Claude reviewed git diff.
- [ ] audit_review.md produced APPROVE or APPROVE_WITH_NOTES.
- [ ] Human reviewed final diff.
- [ ] Human confirmed no BLOCK remains.
- [ ] Release evidence created.
```

---

## 20. One-Page Operating Summary

```text
[1] Cursor Boundary Scan
    Output: impact_scope.md
    Rule: Search only. Never edit.

[1.5] Context Snapshot
    Output: context_snapshot.md
    Rule: Include master anchor plus sliced rule summaries. Do not dump the whole rule base.

[2] Claude Design Pack
    Output: overview.md, logic.md, test_plan.md, change_contract.md
    Rule: Design only. Lock allowed files. Human approves boundary.

[3] Codex Isolated Implementation
    Output: code diff, implementation_module.md
    Rule: Edit only approved files. Stop if scope expands.

[4] Cursor Mechanical Gate
    Output: verification_result.md, raw logs, git diff
    Rule: Run commands. Do not fix. Do not hide errors.

[5] Claude Independent Audit
    Output: audit_review.md
    Rule: Review raw logs and diff directly. Assume implementation is wrong.

[6] Human Merge / Release
    Output: commit, release_evidence.md
    Rule: Human owns final risk.
```

---

## 21. Recommended Governance Placement

This document should be treated as a top-level system SOP candidate, not as a casual guide.

Recommended placement:

```text
repository_root/
  sop/
    system/
      51355_Guide_AI_Assisted_Financial_Grade_Development_Pipeline_Cursor_Claude_Codex_Automated_Gate_And_Human_Merge.md
```

Alternative placement while still in design governance review:

```text
repository_root/
  docs/
    600000_implementation_lifecycle/
      51355_Guide_AI_Assisted_Financial_Grade_Development_Pipeline_Cursor_Claude_Codex_Automated_Gate_And_Human_Merge.md
```

Placement rule:

- If the document is advisory, keep it under `docs/600000_implementation_lifecycle/`.
- If the document is mandatory, move it to `sop/system/`.
- If moved to SOP, add cross-links from implementation lifecycle docs and root index.
- If adopted as the active development constitution, reference it from the root master index and from every implementation lifecycle index.

Owner adoption rule:

```text
Do not treat this file as optional once real financial, POS, provider, RLS, migration, audit, or release implementation begins.

For those domains, this guide is the controlling SOP unless a stricter SOP supersedes it.
```

---

## 22. Final Governance Declaration

This guide exists to make AI-assisted development fast without making it reckless.

The project may move quickly only when each change is boxed by:

1. Boundary discovery.
2. Context snapshot diet and domain slicing.
3. Human-approved contract.
4. Narrow Codex implementation.
5. Raw-log mechanical verification.
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
