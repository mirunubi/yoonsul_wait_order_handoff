# 000415_Checklist_Development_Foundation_Pre_Merge_And_Release_Gate.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Checklist |
| Document Role | Development Foundation Pre-Merge And Release Gate |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Handoff Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Inspection Runbook | 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md |
| Related Inspection Report Template | 000720_Template_Development_Foundation_Read_Only_Inspection_Report.md |
| Related Role Guide | 000730_Guide_Development_Foundation_Claude_Cursor_Role_Separation.md |
| Related Prompt Pack | 000740_Template_Development_Foundation_AI_Handoff_Prompt_Pack.md |
| Related Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md |
| Related AI Change Audit | 000760_Audit_Development_Foundation_AI_Assisted_Change_Control.md |
| Related Exception Log | 000770_Register_Development_Foundation_AI_Assisted_Change_Exception_And_Waiver_Log.md |
| Related Runtime Release Gate | 64390_Checklist_Flow_Bundle_Pre_Merge_And_Release_Gate.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering / QA / Compliance |
| AI Solo Change | Prohibited for merge/release approval |

---

## 2. Purpose

This checklist determines whether a development foundation change is ready for merge or release.

It is used after implementation, test update, documentation update, or AI-assisted change work has been completed.

The checklist verifies that the project chain remains intact:

```text
Overview → Logic → Module → File → Test → Evidence
```

For runtime-impacting changes, it also verifies alignment with the Runtime Flow Bundle gate:

```text
Flow Step → Module → File → Test → Evidence
```

---

## 3. Gate Decision Types

| Decision | Meaning |
|---|---|
| Merge Allowed | Change may be merged into the target branch |
| Merge Allowed With Follow-Up | Low-risk follow-up exists and is recorded |
| Release Allowed | Change may be included in production release |
| Release Blocked | Change may merge only after release blockers are resolved |
| Merge Blocked | Change cannot merge |
| Human-Only Review Required | AI-assisted approval is not sufficient |
| Documentation-Only Accepted | No runtime release gate required |

---

## 4. Scope Classification

Classify the change before applying the checklist.

| Scope Question | Answer |
|---|---|
| Is this documentation-only? | Yes / No |
| Does this change runtime behavior? | Yes / No |
| Does this change source code? | Yes / No |
| Does this change tests? | Yes / No |
| Does this touch payment/cancel/refund? | Yes / No |
| Does this touch settlement/reconciliation/dispute? | Yes / No |
| Does this touch audit ledger/tamper-evidence/legal hold? | Yes / No |
| Does this touch security/webhook signature/secret/credential? | Yes / No |
| Does this touch DB migration/schema/backfill? | Yes / No |
| Does this touch production deployment/release/rollback? | Yes / No |
| Was AI involved? | Yes / No |

---

## 5. Development Foundation Chain Check

| Gate Item | Required | Status | Evidence |
|---|---:|---|---|
| Overview document exists or is not required | Yes | TBD | TBD |
| Logic document exists for runtime behavior | Conditional | TBD | TBD |
| Module document exists for code changes | Conditional | TBD | TBD |
| File mapping is complete | Conditional | TBD | TBD |
| Test mapping is complete | Conditional | TBD | TBD |
| Evidence packet is defined | Conditional | TBD | TBD |
| Traceability matrix is updated | Conditional | TBD | TBD |
| Related Runtime Flow Bundle is linked | Conditional | TBD | TBD |
| Downstream documents affected are listed | Yes | TBD | TBD |

---

## 6. Code Change Review Gate

Use this section when source code changed.

| Check | Required | Status | Evidence |
|---|---:|---|---|
| Changed files are listed | Yes | TBD | TBD |
| Changed files match approved Module Document | Yes | TBD | TBD |
| Unapproved file changes are absent | Yes | TBD | TBD |
| Restricted file check completed | Yes | TBD | TBD |
| No unrelated broad refactor included | Yes | TBD | TBD |
| API/schema changes are documented | Conditional | TBD | TBD |
| DB/migration changes have approval | Conditional | TBD | TBD |
| Security/secret changes have approval | Conditional | TBD | TBD |
| Audit/ledger changes have approval | Conditional | TBD | TBD |
| Release/deploy config changes have approval | Conditional | TBD | TBD |

---

## 7. AI-Assisted Change Gate

Use this section when ChatGPT, Claude Code, Cursor, or another AI tool was involved.

| Check | Required | Status | Evidence |
|---|---:|---|---|
| AI tool used is recorded | Yes | TBD | TBD |
| Prompt or prompt summary is recorded | Yes | TBD | TBD |
| Documents provided to AI are listed | Yes | TBD | TBD |
| AI output summary is recorded | Yes | TBD | TBD |
| Changed files from AI work are listed | Conditional | TBD | TBD |
| Restricted-zone touch report is complete | Conditional | TBD | TBD |
| Human review record exists | Yes | TBD | TBD |
| AI did not approve its own restricted change | Yes | TBD | TBD |
| AI change audit record is updated | Yes | TBD | 00760 |
| Exception/waiver log checked | Yes | TBD | 00770 |

---

## 8. Restricted Zone Gate

If any restricted zone is touched, this gate is mandatory.

| Restricted Zone | Touched? | Approval Required | Approval Evidence | Status |
|---|---:|---:|---|---|
| Payment approval/cancel/refund/reversal | TBD | Yes | TBD | TBD |
| Settlement/reconciliation/dispute | TBD | Yes | TBD | TBD |
| Audit ledger/tamper-evidence/legal hold | TBD | Yes | TBD | TBD |
| Security/auth/webhook signature/secret/credential | TBD | Yes | TBD | TBD |
| DB migration/schema/backfill/data repair | TBD | Yes | TBD | TBD |
| Production deployment/release/rollback | TBD | Yes | TBD | TBD |
| PII/payment log masking/export | TBD | Yes | TBD | TBD |
| Provider contract/API schema | TBD | Yes | TBD | TBD |

Rules:

1. Missing approval in a touched restricted zone blocks merge.
2. Missing evidence in a touched restricted zone blocks release.
3. AI may draft analysis but may not approve restricted-zone closure.

---

## 9. Test Gate

| Test Type | Required When | Status | Evidence |
|---|---|---|---|
| Unit | Logic guards, validators, helpers, module functions changed | TBD | TBD |
| Integration | Runtime module boundaries changed | TBD | TBD |
| Contract | Provider/API schema changed | TBD | TBD |
| Fault Injection | Timeout/retry/DLQ/replay behavior changed | TBD | TBD |
| Security | Auth/signature/secret/replay/log masking changed | TBD | TBD |
| Audit | Ledger/evidence/tamper behavior changed | TBD | TBD |
| Migration | DB/schema/backfill changed | TBD | TBD |
| Regression | Defect fix or incident scenario | TBD | TBD |
| Manual QA | UI or workflow requires human verification | TBD | TBD |

If a test cannot be run, record:

```text
test_not_run_reason:
risk:
compensating_control:
approval:
follow_up_due_date:
```

---

## 10. Evidence Gate

| Evidence Item | Required | Status | Location |
|---|---:|---|---|
| Handoff prompt | Conditional | TBD | TBD |
| Read-only inspection report | Conditional | TBD | TBD |
| Module map | Conditional | TBD | TBD |
| Diff review note | Conditional | TBD | TBD |
| Test report | Conditional | TBD | TBD |
| Restricted approval record | Conditional | TBD | TBD |
| Exception/waiver record | Conditional | TBD | TBD |
| Release readiness record | Conditional | TBD | TBD |
| Final decision note | Yes | TBD | TBD |

---

## 11. Documentation Consistency Gate

| Check | Required | Status |
|---|---:|---|
| H1 uses exact full filename with `.md` | Yes | TBD |
| Filename follows `NNNNN_DocumentType_Description.md` | Yes | TBD |
| DocumentType prefix is after number | Yes | TBD |
| Related documents are cross-linked | Yes | TBD |
| Operating SOP and System SOP number ranges are respected | Yes | TBD |
| Runtime Flow Registry band references are consistent | Conditional | TBD |
| Deprecated or superseded docs are identified | Conditional | TBD |
| Open questions are listed | Conditional | TBD |

---

## 12. Runtime Flow Bundle Alignment

Use this when the change relates to 64000번대 Runtime Flow Bundle documents.

| Flow Gate Item | Required | Status | Evidence |
|---|---:|---|---|
| Flow Bundle document is linked | Yes | TBD | TBD |
| MD Dependency Graph is current | Conditional | TBD | TBD |
| Module Impact Map is current | Conditional | TBD | TBD |
| Test Coverage Map is current | Conditional | TBD | TBD |
| Code Handoff Readiness Gate passed | Conditional | TBD | 64300 |
| Code Review / Diff Control runbook applied | Conditional | TBD | 64330 |
| Implementation Evidence Packet updated | Conditional | TBD | 64340 |
| Exception/Waiver Log checked | Conditional | TBD | 64350 |
| AI Implementation Governance checked | Conditional | TBD | 64360 |
| Human Approval / No-AI-Solo gate checked | Conditional | TBD | 64370 / 64380 |
| Runtime Pre-Merge Release Gate checked | Conditional | TBD | 64390 |

---

## 13. Merge Blockers

Merge is blocked if any of the following is true:

| Blocker | Resolution |
|---|---|
| Runtime behavior changed without Logic document | Create/update Logic document |
| Code changed without Module document | Create/update Module document |
| Changed files not mapped | Update Module and traceability matrix |
| Required tests missing without approved waiver | Add tests or approve waiver where allowed |
| Restricted zone touched without approval | Obtain human approval or revert |
| AI prompt/audit missing for AI-assisted code work | Update audit or reconstruct record |
| Unapproved file change found | Revert or obtain approval |
| Evidence packet missing for material change | Create/update evidence packet |
| Critical waiver open | Resolve or block |
| Secret/migration/release file changed unexpectedly | Stop and escalate |

---

## 14. Release Blockers

Release is blocked if any of the following is true:

| Blocker | Resolution |
|---|---|
| Evidence packet incomplete | Complete evidence |
| Restricted-zone evidence missing | Complete approval and evidence |
| Critical/high waiver open without approved release exception | Resolve before release |
| Required test result missing | Run test or record approved blocker |
| Migration rollback plan missing | Create migration rollback plan |
| Security review missing for security change | Complete security review |
| Audit ledger evidence missing | Complete audit evidence |
| Production release checklist incomplete | Complete release checklist |
| Unknown external provider state risk unresolved | Reconcile before release |

---

## 15. Final Decision Record

| Field | Value |
|---|---|
| Change / PR / Task ID | TBD |
| Related Flow Bundle | TBD |
| Related Overview | TBD |
| Related Logic | TBD |
| Related Module | TBD |
| AI Involved? | Yes / No |
| Restricted Zone Touched? | Yes / No |
| Tests Complete? | Yes / No / Conditional |
| Evidence Complete? | Yes / No / Conditional |
| Open Waivers | None / Listed |
| Merge Decision | Allowed / Allowed with follow-up / Blocked |
| Release Decision | Allowed / Blocked / Not applicable |
| Human Approver | TBD |
| Decision Date | YYYY-MM-DD |
| Notes | TBD |

---

## 16. Checklist Summary

Before merge:

- [ ] Scope is classified.
- [ ] Development foundation chain is complete.
- [ ] Changed files are mapped.
- [ ] AI involvement is audited.
- [ ] Restricted zones are checked.
- [ ] Tests are identified and recorded.
- [ ] Evidence packet is linked.
- [ ] Waivers are reviewed.
- [ ] Merge blockers are resolved.

Before release:

- [ ] Runtime Flow Bundle gate is complete when applicable.
- [ ] Restricted-zone approvals are complete.
- [ ] Test results are recorded.
- [ ] Evidence packet is complete.
- [ ] Release blockers are resolved.
- [ ] Final human decision is recorded.

---

## 17. Summary

This checklist is the development foundation gate before merge and release.

It confirms that implementation remains traceable through:

```text
Overview → Logic → Module → File → Test → Evidence
```

For runtime Flow Bundle work, it must be used together with:

```text
64390_Checklist_Flow_Bundle_Pre_Merge_And_Release_Gate.md
```

Merge or release must be blocked whenever restricted, financial, audit, security, DB, secret, or deployment changes lack approval, test evidence, or traceability.
