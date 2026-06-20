# 000418_Template_Development_Foundation_First_Flow_Bundle_Implementation_Ticket.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | First Flow Bundle Implementation Ticket Template |
| Related Closeout | 000790_Index_Development_Foundation_Closeout_And_Runtime_Flow_Linkage.md |
| Related Hydration Guide | 000800_Guide_Development_Foundation_First_Codebase_Hydration_And_Module_Discovery.md |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Traceability Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Handoff Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related AI Prompt Pack | 000740_Template_Development_Foundation_AI_Handoff_Prompt_Pack.md |
| Related Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering / QA |
| AI Solo Change | Ticket drafting allowed; implementation approval prohibited for restricted zones |

---

## 2. Purpose

This template defines the standard ticket format for the first Flow Bundle implementation task after codebase hydration.

The ticket must prevent the unsafe pattern:

```text
single MD file → broad AI implementation → unknown file changes → missing tests/evidence
```

Instead, every implementation ticket must preserve the chain:

```text
Overview → Logic → Module → File → Test → Evidence
```

and the Flow Bundle implementation chain:

```text
Flow Step → Module → File → Test → Evidence
```

---

## 3. When To Use This Ticket

Use this ticket when:

| Situation | Use This Ticket? |
|---|---:|
| First actual implementation work is being prepared | Yes |
| Claude Code will implement an approved Flow Bundle | Yes |
| Cursor will assist with file-level changes | Yes |
| A codebase hydration report has identified candidate modules/files/tests | Yes |
| A restricted zone may be touched | Yes |
| Only a pure documentation file is being drafted | Usually No |

---

## 4. Ticket Template

Use the following structure for each actual Flow Bundle implementation ticket.

---

# <Exact_Ticket_Filename_With_Extension.md>

## 1. Ticket Summary

| Field | Value |
|---|---|
| Ticket ID | IMPL-YYYYMMDD-001 |
| Ticket Name | TBD |
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Related Flow Bundle | TBD |
| Related Overview | TBD |
| Related Logic | TBD |
| Related Module | TBD |
| Related Hydration Report | TBD |
| Related Traceability Matrix | TBD |
| Related Restricted Register | TBD |
| Owner | TBD |
| Target Tool | Claude Code / Cursor / Human / Mixed |
| Status | Draft / Ready / In Progress / Review / Blocked / Done |

---

## 2. Implementation Objective

Describe the narrow and approved objective.

```text
TBD
```

Good objective example:

```text
Implement only the idempotency guard and timeout-state recording for the approved POS Gateway approval Flow Bundle, using the approved Logic and Module documents. Do not modify settlement, audit hash-chain, DB migration, secret, or release files.
```

Bad objective example:

```text
Read the POS Gateway docs and make the payment flow work.
```

---

## 3. Approved Scope

### 3.1 Included Flow Steps

| Flow Step ID | Description | Related Logic Rule | Module |
|---|---|---|---|
| TBD | TBD | TBD | TBD |

### 3.2 Included Files / Modules

| File / Module | Change Allowed? | Expected Change | Related Test |
|---|---:|---|---|
| TBD | Yes | TBD | TBD |

### 3.3 Excluded Scope

| Excluded Area | Reason |
|---|---|
| TBD | TBD |
| Settlement/reconciliation | Not part of this ticket unless explicitly approved |
| Audit hash-chain mutation | Restricted zone |
| DB migration | Requires separate migration approval |
| Secrets/env/deploy | Locked zone |

---

## 4. Required Documents

| Document Type | Filename | Status |
|---|---|---|
| Runtime Flow Bundle | TBD | Required |
| Overview | TBD | Required |
| Logic | TBD | Required |
| Module | TBD | Required for code |
| Hydration Report | TBD | Required when source surface was discovered |
| Traceability Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md | Required |
| Code Handoff Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md | Required |
| Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md | Required |
| AI Change Audit | 000760_Audit_Development_Foundation_AI_Assisted_Change_Control.md | Required when AI used |
| Exception/Waiver Log | 000770_Register_Development_Foundation_AI_Assisted_Change_Exception_And_Waiver_Log.md | Required when exception exists |
| Pre-Merge Gate | 000780_Checklist_Development_Foundation_Pre_Merge_And_Release_Gate.md | Required |

---

## 5. Readiness Gate

| Gate Item | Required | Status | Notes |
|---|---:|---|---|
| Flow Bundle identified | Yes | TBD | TBD |
| Overview exists | Yes | TBD | TBD |
| Logic exists | Yes | TBD | TBD |
| Module exists | Yes | TBD | TBD |
| Source files identified | Yes | TBD | TBD |
| Tests identified | Yes | TBD | TBD |
| Evidence target identified | Yes | TBD | TBD |
| Restricted zones classified | Yes | TBD | TBD |
| Human approval recorded if needed | Conditional | TBD | TBD |
| AI handoff prompt prepared | Conditional | TBD | TBD |

---

## 6. Restricted Zone Check

| Restricted Zone | Touched? | Approval Required | Approval Evidence |
|---|---:|---:|---|
| Payment approval/cancel/refund/reversal | TBD | Yes if touched | TBD |
| Settlement/reconciliation/dispute | TBD | Yes if touched | TBD |
| Audit ledger/tamper-evidence/legal hold | TBD | Yes if touched | TBD |
| Security/webhook signature/secret/credential | TBD | Yes if touched | TBD |
| DB migration/schema/backfill/data repair | TBD | Yes if touched | TBD |
| Production release/deployment/rollback | TBD | Yes if touched | TBD |
| PII/payment log masking/export | TBD | Yes if touched | TBD |
| Provider contract/API schema | TBD | Yes if touched | TBD |

If any restricted zone is touched without approval, this ticket is blocked.

---

## 7. Implementation Instructions

### 7.1 General Instructions

```text
Do not treat one MD file as the implementation unit.
Use the approved chain:
Overview → Logic → Module → File → Test → Evidence.

Use the approved Flow Bundle chain:
Flow Step → Module → File → Test → Evidence.

Do not expand scope.
Do not modify unlisted files.
Do not run migrations.
Do not change secrets.
Do not deploy.
Return blockers instead of guessing.
```

### 7.2 Claude Code Instructions

```text
You may implement only the approved Flow Steps and files listed in this ticket.

Before changing files:
1. Confirm documents read.
2. Confirm allowed files.
3. Confirm prohibited files.
4. Confirm restricted zone status.
5. Confirm tests to update.

After changing files:
1. List changed files.
2. List tests added or updated.
3. Report tests run and results.
4. Report restricted zone touch status.
5. Produce evidence packet notes.
6. List unresolved questions.
```

### 7.3 Cursor Instructions

```text
Assist only with the approved narrow file-level task.

Do not expand scope.
Do not modify restricted files.
Do not infer missing Flow Bundle context.
Do not refactor unrelated code.

Return:
- minimal diff summary
- tests affected
- risk note
- restricted area touch report
```

---

## 8. Expected Deliverables

| Deliverable | Required | Owner |
|---|---:|---|
| Code diff | Conditional | Engineering / Claude Code / Cursor |
| Test diff | Conditional | Engineering |
| Updated Module Document | Conditional | Architecture / Engineering |
| Updated Traceability Matrix | Conditional | Architecture |
| Evidence packet | Yes for runtime change | QA / Engineering |
| Restricted approval record | Conditional | Human Owner |
| AI audit record | Conditional | Engineering / QA |
| Waiver record | Conditional | Owner / Approver |

---

## 9. Test Requirements

| Test Type | Required? | Test File / Command | Evidence |
|---|---:|---|---|
| Unit | TBD | TBD | TBD |
| Integration | TBD | TBD | TBD |
| Contract | TBD | TBD | TBD |
| Fault injection | TBD | TBD | TBD |
| Security | TBD | TBD | TBD |
| Audit | TBD | TBD | TBD |
| Migration | TBD | TBD | TBD |
| Regression | TBD | TBD | TBD |

Rules:

1. Do not claim tests passed unless they were actually run.
2. If tests cannot be run, record reason, risk, and compensating control.
3. Runtime Flow Bundle changes require test and evidence mapping before release.

---

## 10. Evidence Requirements

| Evidence | Required? | Location |
|---|---:|---|
| Handoff prompt | Yes when AI used | TBD |
| Documents read list | Yes | TBD |
| Changed files list | Yes when code changed | TBD |
| Restricted zone report | Yes | TBD |
| Test result | Conditional | TBD |
| Human approval | Conditional | TBD |
| Diff review | Yes when code changed | TBD |
| Waiver record | Conditional | TBD |
| Final decision | Yes | TBD |

---

## 11. Review Checklist

Before marking the ticket ready for merge:

- [ ] Objective is narrow and explicit.
- [ ] Related Flow Bundle is listed.
- [ ] Overview, Logic, and Module documents are linked.
- [ ] Allowed files are listed.
- [ ] Excluded files/areas are listed.
- [ ] Restricted zones are classified.
- [ ] Human approval exists where required.
- [ ] Required tests are identified.
- [ ] Evidence target is identified.
- [ ] AI prompt is bounded if AI is used.
- [ ] Diff review is planned.
- [ ] Waivers are logged if any gate is skipped.

---

## 12. Completion Record

| Field | Value |
|---|---|
| Implementation Completed? | Yes / No |
| Changed Files | TBD |
| Tests Added/Updated | TBD |
| Tests Run | TBD |
| Test Results | TBD |
| Evidence Packet | TBD |
| Restricted Zone Touched? | Yes / No |
| Human Approval Complete? | Yes / No / Not applicable |
| Waivers Open? | Yes / No |
| Merge Decision | Allowed / Blocked |
| Release Decision | Allowed / Blocked / Not applicable |
| Reviewer | TBD |
| Review Date | YYYY-MM-DD |

---

## 13. Summary

This ticket template converts a Flow Bundle into a safe implementation task.

It keeps Claude Code, Cursor, and human developers aligned to:

```text
Overview → Logic → Module → File → Test → Evidence
```

and prevents implementation from starting from a single disconnected Markdown file.
