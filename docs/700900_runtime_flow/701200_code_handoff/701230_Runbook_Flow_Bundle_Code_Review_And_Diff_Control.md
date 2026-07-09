# 701230_Runbook_Flow_Bundle_Code_Review_And_Diff_Control.md

## 1. Document Purpose

This runbook defines the mandatory code review and diff control procedure for the CatchMenu / Catch & Order Runtime Flow Bundle implementation lane.

The purpose of this document is to prevent AI-assisted implementation from being treated as a collection of isolated Markdown-driven edits. Every implementation change must be reviewed against the approved Flow Bundle architecture, dependency graph, module impact map, test coverage map, and evidence requirements.

This runbook applies after a Flow Bundle has passed the code handoff readiness gate and before any implementation is merged, deployed, or promoted.

## 2. Document Identity

| Field | Value |
|---|---|
| Document Number | 701230 |
| Document Type | Runbook |
| Filename | 701230_Runbook_Flow_Bundle_Code_Review_And_Diff_Control.md |
| Band | 700900 Runtime Flow Bundle Registry |
| System Class | System SOP / Runtime Governance |
| Related Index | 700900_Index_Runtime_Flow_Bundle_Registry.md |
| Primary Consumers | Owner, Architect, Claude Code Operator, Cursor Operator, Reviewer, QA, Security Reviewer |
| AI Execution Status | Review-assisted only; final approval must be human-controlled |

## 3. Scope

This runbook covers:

1. Flow Bundle diff intake.
2. AI-generated code review boundary control.
3. Changed-file classification.
4. Restricted-area violation detection.
5. Flow Step to Module to File to Test to Evidence trace verification.
6. Runtime behavior review.
7. Database, migration, secret, settlement, audit, and deployment guard checks.
8. Merge readiness decision.
9. Rejection and rollback procedure.

This runbook does not authorize direct production deployment.

## 4. Core Review Principle

A code diff is not reviewed as a set of files.

A code diff is reviewed as a change to a Flow Bundle.

The reviewer must always ask:

1. Which Flow Bundle does this diff implement or modify?
2. Which Flow Steps are affected?
3. Which modules are impacted?
4. Which files changed?
5. Which tests prove the intended behavior?
6. Which evidence artifacts prove the runtime and audit behavior?
7. Did the diff touch any restricted area?
8. Is the change reversible?

## 5. Related Documents

| Document | Relationship |
|---|---|
| 700900_Index_Runtime_Flow_Bundle_Registry.md | Parent registry |
| 701000_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval to audit ledger flow |
| 701010_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel, refund, recovery, and audit flow |
| 701020_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout, retry, DLQ, and replay flow |
| 701030_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Store offline local ledger and resync flow |
| 701040_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook verification and normalization flow |
| 701050_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement, dispute, and evidence export flow |
| 701100_Matrix_Flow_To_MD_Dependency_Graph.md | MD dependency verification |
| 701110_Matrix_Flow_To_Module_Implementation_Map.md | Module impact verification |
| 701120_Matrix_Flow_To_Test_Coverage_Map.md | Test coverage verification |
| 701200_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md | Pre-code handoff gate |
| 701210_Template_Flow_Bundle_Claude_Code_Handoff_Prompt.md | Claude Code handoff control |
| 701220_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md | Cursor assist boundary |

## 6. Review Entry Conditions

A diff may enter review only when all conditions below are met.

| Gate | Required Condition | Status |
|---|---|---|
| Flow Bundle declared | The implementation references one approved Flow Bundle ID | Required |
| Flow Steps listed | The changed Flow Steps are listed by ID or name | Required |
| Module map linked | Related modules are mapped to 701110 | Required |
| Test map linked | Related test coverage is mapped to 701120 | Required |
| Evidence target defined | Evidence outputs are named | Required |
| Restricted area statement present | AI operator declares whether restricted areas were touched | Required |
| Diff is inspectable | Full diff is available before merge | Required |
| Rollback path exists | Revert or rollback plan exists | Required |

If any condition is missing, the review must stop.

## 7. Restricted Area Rule

The following areas must not be modified by AI alone.

| Restricted Area | Rule |
|---|---|
| Payment approval execution | Human architect review required |
| Cancel and refund execution | Human architect review required |
| Settlement calculation | Human finance/audit review required |
| Audit ledger immutability | Human security/audit review required |
| Reconciliation logic | Human finance/audit review required |
| Database migration | Human DB owner review required |
| Secret handling | Human security owner review required |
| Webhook credential verification | Human security owner review required |
| Production deployment scripts | Human release owner review required |
| Legal hold and evidence export | Human legal/audit review required |

Any diff touching these areas is not automatically rejected, but it must be escalated and cannot be merged under AI-only review.

## 8. Diff Intake Procedure

### 8.1 Identify Flow Bundle

The reviewer records:

| Item | Value |
|---|---|
| Flow Bundle ID |  |
| Flow Bundle Document |  |
| Implementation Branch |  |
| Commit Range |  |
| AI Agent Used | Claude Code / Cursor / Manual / Mixed |
| Operator |  |
| Reviewer |  |
| Review Date |  |

### 8.2 Classify Change Type

| Change Type | Description | Review Level |
|---|---|---|
| Documentation only | MD, README, comments only | Standard |
| Test only | Adds or changes tests without runtime behavior change | Standard |
| Runtime behavior | Changes application logic | Elevated |
| Integration boundary | Changes API, webhook, adapter, or provider mapping | Elevated |
| Ledger-affecting | Changes order/payment/audit/settlement state | Restricted |
| Migration-affecting | Changes schema, seed, index, RLS, trigger, function | Restricted |
| Secret/security-affecting | Changes key handling, signature, credential, vault, ACL | Restricted |
| Deployment-affecting | Changes build, CI/CD, infra, production config | Restricted |

## 9. Flow Step Trace Review

Every changed file must be mapped to a Flow Step.

| Changed File | Module | Flow Step | Reason for Change | Test Evidence | Reviewer Decision |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

Rules:

1. A changed runtime file without a Flow Step mapping is not allowed.
2. A changed test file without a mapped runtime behavior is not enough.
3. A changed schema or migration file requires restricted review.
4. A changed security or secret file requires restricted review.
5. A changed audit or settlement file requires evidence review.

## 10. MD Dependency Consistency Review

The reviewer verifies that the implementation does not contradict the approved MD dependency graph.

| Check | Required Result | Status |
|---|---|---|
| Parent flow document referenced | Yes |  |
| Related Policy documents respected | Yes |  |
| Related SOP documents respected | Yes |  |
| Related WorkPackage documents respected | Yes |  |
| Related Audit documents respected | Yes |  |
| Related Evidence documents respected | Yes |  |
| No orphan implementation logic | Yes |  |

If implementation behavior introduces a new policy decision, the code must not be merged until the related MD document is created or updated.

## 11. Module Impact Review

The reviewer checks the changed modules against the approved Module Implementation Map.

| Module | Expected Impact | Actual Diff Impact | Match? | Notes |
|---|---|---|---|---|
| POS Gateway Adapter |  |  |  |  |
| Payment State Machine |  |  |  |  |
| Audit Ledger Writer |  |  |  |  |
| Reconciliation Engine |  |  |  |  |
| Webhook Receiver |  |  |  |  |
| DLQ Replay Worker |  |  |  |  |
| Local Ledger Sync |  |  |  |  |
| Evidence Exporter |  |  |  |  |
| Admin Console Surface |  |  |  |  |
| Observability Layer |  |  |  |  |

Unexpected module impact must be explained and approved.

## 12. File-Level Diff Review

The reviewer classifies each changed file.

| File | Category | AI Touch Allowed? | Human Review Needed? | Decision |
|---|---|---|---|---|
|  | Runtime | Conditional | Yes if ledger/payment/security |  |
|  | Test | Yes | Standard review |  |
|  | Documentation | Yes | Standard review |  |
|  | Migration | No AI-only merge | DB owner required |  |
|  | Config | Conditional | Security/release review if sensitive |  |
|  | Secret | No AI-only merge | Security owner required |  |
|  | CI/CD | No AI-only merge | Release owner required |  |

## 13. Test Coverage Review

The reviewer verifies tests against the Flow to Test Coverage Map.

| Test Type | Required For | Review Question | Status |
|---|---|---|---|
| Unit test | Module logic | Does the module behave correctly in isolation? |  |
| Contract test | External POS/PG/VAN boundary | Does the provider contract hold? |  |
| Integration test | Cross-module flow | Does the full Flow Step chain work? |  |
| Idempotency test | Retry/replay/payment safety | Does repeated input avoid double effects? |  |
| Failure injection test | Timeout/offline/webhook duplicate | Does failure produce safe state? |  |
| Reconciliation test | Ledger vs external record | Are mismatches detected and classified? |  |
| Security test | Signature/secret/access | Are unauthorized events rejected? |  |
| Evidence test | Audit/export packet | Can proof be generated and verified? |  |
| Regression test | Existing flows | Did previous approved behavior remain intact? |  |

A Flow Bundle diff cannot be accepted with only happy-path tests.

## 14. Runtime Behavior Review

The reviewer checks whether the diff changes runtime behavior safely.

| Behavior Area | Required Review |
|---|---|
| Order state transition | Validate legal state transitions only |
| Payment state transition | Validate idempotency and duplicate prevention |
| Cancel/refund transition | Validate reversal and partial failure recovery |
| Timeout handling | Validate ambiguous outcome quarantine |
| Retry policy | Validate bounded retries and no storm amplification |
| DLQ policy | Validate reason code and replay guard |
| Offline sync | Validate local ledger conflict handling |
| Webhook normalization | Validate canonical event conversion |
| Reconciliation | Validate mismatch classes and escalation |
| Evidence export | Validate trace completeness and immutability |

## 15. Financial-Grade Review Questions

The reviewer must answer these questions before approval.

1. Can this change create duplicate approval, duplicate cancel, or duplicate refund?
2. Can this change hide an ambiguous payment outcome?
3. Can this change overwrite or mutate an audit ledger entry?
4. Can this change break reconciliation between internal ledger and PG/VAN records?
5. Can this change expose a secret or weaken signature verification?
6. Can this change cause replay without idempotency protection?
7. Can this change silently drop a webhook event?
8. Can this change allow settlement without complete evidence?
9. Can this change deploy without rollback?
10. Can this change create a state that is not represented in MD policy?

Any “yes” answer requires escalation.

## 16. Evidence Review

The implementation must produce or update evidence artifacts.

| Evidence Type | Required Content | Status |
|---|---|---|
| Diff summary | Changed files, modules, Flow Steps |  |
| Test result | Passed test names and failure notes |  |
| Runtime trace | Sample event flow or trace ID |  |
| Ledger proof | Before/after state or immutable append proof |  |
| Reconciliation proof | Match/mismatch scenario result |  |
| Security proof | Signature/unauthorized event rejection result |  |
| Replay proof | Idempotency and duplicate suppression result |  |
| Rollback proof | Revert or migration rollback path |  |
| Reviewer signoff | Human approval record |  |

## 17. AI Agent Review Boundary

AI may assist with:

1. Summarizing diffs.
2. Mapping changed files to Flow Steps.
3. Identifying missing tests.
4. Detecting suspicious module impact.
5. Drafting review notes.
6. Generating non-authoritative checklists.

AI must not independently approve:

1. Payment logic changes.
2. Settlement logic changes.
3. Audit immutability changes.
4. DB migrations.
5. Secret handling changes.
6. Production deployment changes.
7. Legal evidence export changes.

## 18. Claude Code Review Prompt Pattern

When Claude Code is used for review assistance, the operator must provide this structure:

```text
You are reviewing a CatchMenu / Catch & Order Flow Bundle implementation.
Do not approve the change.
Do not modify files unless explicitly instructed.
Analyze the diff only.

Flow Bundle:
[FLOW_DOCUMENT]

Related matrices:
[MD_DEPENDENCY_GRAPH]
[MODULE_IMPLEMENTATION_MAP]
[TEST_COVERAGE_MAP]

Diff:
[COMMIT_RANGE_OR_DIFF]

Tasks:
1. Map each changed file to Flow Step, Module, Test, and Evidence.
2. Identify any restricted area touched.
3. Identify missing tests.
4. Identify possible duplicate approval/cancel/refund/replay risk.
5. Identify audit ledger or reconciliation risk.
6. Produce review notes only.
```

## 19. Cursor Review Boundary

Cursor may be used to inspect local files and small diffs, but must not be asked to globally rewrite the Flow Bundle.

Allowed Cursor tasks:

1. Explain a selected diff.
2. Check whether a selected file matches the mapped Flow Step.
3. Add a narrow missing test after human instruction.
4. Fix formatting or type errors in approved files.
5. Compare implementation against a specific MD requirement.

Disallowed Cursor tasks:

1. Rewrite payment flow globally.
2. Edit DB migrations without DB owner instruction.
3. Edit secrets, production config, or deployment scripts.
4. Refactor settlement or audit ledger logic without human review.
5. Modify broad file sets without Flow Bundle mapping.

## 20. Merge Decision Table

| Condition | Decision |
|---|---|
| All Flow Step mappings complete, tests pass, no restricted area touched | Approve with standard signoff |
| Restricted area touched but human owner approved | Approve with elevated signoff |
| Missing Flow Step mapping | Reject |
| Missing required test coverage | Reject |
| Audit ledger mutation risk unresolved | Reject |
| Duplicate financial action risk unresolved | Reject |
| Secret exposure risk unresolved | Reject |
| DB migration lacks rollback | Reject |
| Evidence packet missing | Hold |
| Runtime behavior contradicts MD policy | Reject and update MD first |

## 21. Rejection Procedure

If rejected, the reviewer must record:

1. Flow Bundle ID.
2. Commit range.
3. Rejection reason.
4. Restricted area involved, if any.
5. Missing MD dependency, if any.
6. Missing module mapping, if any.
7. Missing test, if any.
8. Required remediation.
9. Whether rollback is required.

Rejected diffs must not be partially merged unless the safe subset is separated into a new review package.

## 22. Rollback Review

Before merge, the reviewer checks rollback readiness.

| Rollback Item | Required? | Status |
|---|---|---|
| Git revert path | Yes |  |
| Feature flag disable path | If runtime behavior changes |  |
| Migration rollback or forward-fix plan | If DB changes |  |
| Queue replay pause path | If retry/DLQ changes |  |
| Webhook disable or quarantine path | If inbound boundary changes |  |
| Settlement hold path | If settlement changes |  |
| Evidence preservation path | If audit/export changes |  |

## 23. Review Output Format

Every Flow Bundle code review must produce the following review note.

```markdown
# Flow Bundle Code Review Note

## Flow Bundle
- Flow Document:
- Commit Range:
- Branch:
- Reviewer:
- Date:

## Changed Files
| File | Module | Flow Step | Restricted? | Decision |
|---|---|---|---|---|

## Tests Reviewed
| Test | Type | Flow Step | Result |
|---|---|---|---|

## Evidence Reviewed
| Evidence | Location | Result |
|---|---|---|

## Restricted Area Review
- Payment:
- Settlement:
- Audit Ledger:
- DB Migration:
- Secret:
- Deployment:

## Decision
- Approved / Approved With Conditions / Held / Rejected

## Required Follow-Up
-
```

## 24. Minimum Acceptance Criteria

A Flow Bundle implementation diff is acceptable only when:

1. It maps to one approved Flow Bundle.
2. Every changed file maps to a Flow Step and Module.
3. All required tests are present and passing.
4. Evidence artifacts exist.
5. Restricted-area changes have human owner approval.
6. No hidden policy decision exists only in code.
7. No audit, settlement, payment, or replay safety question remains unresolved.
8. Rollback or safe forward recovery is available.

## 25. Completion Rule

This runbook is complete when it can be used to review Claude Code, Cursor, or human-authored implementation diffs under the same Flow Bundle control model.

The governing sequence remains:

Flow Step → Module → File → Test → Evidence → Review → Merge Decision
