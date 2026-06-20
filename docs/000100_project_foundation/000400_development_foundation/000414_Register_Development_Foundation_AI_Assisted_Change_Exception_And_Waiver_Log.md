# 000414_Register_Development_Foundation_AI_Assisted_Change_Exception_And_Waiver_Log.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Register |
| Document Role | AI-Assisted Change Exception And Waiver Log |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Prompt Pack | 000740_Template_Development_Foundation_AI_Handoff_Prompt_Pack.md |
| Related Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md |
| Related Audit | 000760_Audit_Development_Foundation_AI_Assisted_Change_Control.md |
| Related Runtime Waiver Log | 64350_Register_Flow_Bundle_Implementation_Exception_And_Waiver_Log.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering / QA / Compliance |
| AI Solo Change | Prohibited for waiver approval |

---

## 2. Purpose

This register records exceptions and waivers related to AI-assisted development foundation work.

It prevents skipped gates, missing documents, incomplete tests, unrecorded prompts, or uncertain AI outputs from being silently accepted.

The register applies to:

- ChatGPT-generated documentation
- Claude Code read-only inspection or implementation
- Cursor file-level assistance
- AI-generated tests
- AI-assisted diff review
- AI-assisted evidence preparation
- any AI output that affects development, runtime logic, testing, audit, or release readiness

---

## 3. Core Rule

Exceptions may be recorded.

Exceptions may not automatically be accepted.

A waiver is valid only when:

```text
1. The exception is explicitly documented.
2. The affected Flow Bundle or development document is identified.
3. The risk is described.
4. The owner and approver are identified.
5. The waiver does not violate a non-waivable restricted zone.
6. Compensating control or follow-up action is defined.
7. Evidence is attached or referenced.
```

---

## 4. Non-Waivable Areas

The following items must not be waived for runtime-impacting changes.

| Area | Waivable? | Rule |
|---|---:|---|
| Human approval for payment/cancel/refund changes | No | Required |
| Human approval for settlement/reconciliation changes | No | Required |
| Human approval for audit ledger/tamper-evidence changes | No | Required |
| Human approval for security/secret/credential changes | No | Required |
| Human approval for DB migration/backfill/data repair | No | Required |
| Human approval for production release/deployment | No | Required |
| Evidence packet before production release | No | Required |
| Logic document for runtime behavior change | No | Required |
| Module document for code change | No | Required |
| Restricted file touch report for AI-assisted code change | No | Required |

If any non-waivable item is missing, the change must be blocked.

---

## 5. Potentially Waivable Areas

The following may be waived only with explicit approval and compensating controls.

| Area | Waivable? | Required Compensating Control |
|---|---:|---|
| Full test execution unavailable locally | Conditional | CI run or manual test plan |
| Exact prompt not preserved | Conditional | Reconstructed prompt summary |
| Minor documentation link incomplete | Conditional | Follow-up task with owner |
| Non-critical UI test missing | Conditional | Manual review evidence |
| Read-only inspection incomplete | Conditional | Narrower implementation scope |
| Evidence location not final | Conditional | Temporary evidence reference and due date |
| Low-risk documentation typo without review | Conditional | Batch review later |

---

## 6. Exception / Waiver Log Template

Use this table for active tracking.

| Waiver ID | Date | Related Document / Flow Bundle | Exception Type | Description | Severity | Waiver Requested? | Approved? | Approver | Compensating Control | Due Date | Status |
|---|---|---|---|---|---|---:|---:|---|---|---|---|
| WAIVER-001 | YYYY-MM-DD | TBD | TBD | TBD | Low/Medium/High/Critical | Yes | No | TBD | TBD | TBD | Open |

---

## 7. Exception Types

| Exception Type | Description |
|---|---|
| MISSING_OVERVIEW | Overview document missing or incomplete |
| MISSING_LOGIC | Logic document missing or incomplete |
| MISSING_MODULE | Module map missing or incomplete |
| MISSING_TRACEABILITY | Overview → Logic → Module → File → Test → Evidence chain incomplete |
| MISSING_TEST | Required test missing or not run |
| MISSING_EVIDENCE | Evidence packet missing or incomplete |
| MISSING_PROMPT_RECORD | AI prompt not preserved |
| SCOPE_EXPANSION | AI or developer expanded beyond approved scope |
| RESTRICTED_ZONE_TOUCH | Restricted file or zone touched |
| UNAPPROVED_FILE_CHANGE | File changed outside approved list |
| DIFF_REVIEW_GAP | Diff review incomplete |
| SECURITY_REVIEW_GAP | Security review missing |
| DB_MIGRATION_GAP | Migration plan or rollback evidence missing |
| RELEASE_GATE_GAP | Release checklist incomplete |
| DOCUMENT_CONFLICT | Related MD documents conflict |
| UNKNOWN_SOURCE_SURFACE | Code files not mapped before implementation |
| TEST_ENV_BLOCKER | Tests could not run due to environment limits |

---

## 8. Severity Classification

| Severity | Meaning | Default Action |
|---|---|---|
| Low | Documentation or administrative gap with no runtime effect | Track and fix |
| Medium | Implementation planning gap but no restricted runtime change yet | Fix before handoff |
| High | Runtime change risk, missing test/evidence, or unclear module impact | Block merge until resolved |
| Critical | Restricted zone, money movement, audit, security, DB, secret, or release risk | Block immediately; human approval required |

---

## 9. Waiver Request Form

Use this format when requesting a waiver.

```text
# Waiver Request

## 1. Summary
- Waiver ID:
- Date:
- Requester:
- Related document:
- Related Flow Bundle:
- Exception type:
- Severity:

## 2. Description
- What is missing or deviating from the standard?

## 3. Impact
- Runtime impact:
- Payment impact:
- Settlement impact:
- Audit impact:
- Security impact:
- DB/migration impact:
- Release impact:

## 4. Reason For Waiver
- Why can this not be resolved before proceeding?

## 5. Compensating Control
- What control reduces the risk?

## 6. Follow-Up
- Owner:
- Due date:
- Required artifact:

## 7. Approval
- Approver:
- Decision: Approved / Rejected / Deferred
- Approval date:
- Evidence reference:
```

---

## 10. Waiver Approval Rules

| Severity | Approval Requirement |
|---|---|
| Low | Document owner approval |
| Medium | Architecture or engineering owner approval |
| High | Architecture + engineering + QA approval |
| Critical | Human owner + security/compliance/financial owner depending on zone |

AI tools may draft waiver records but may not approve them.

---

## 11. Waiver Expiration

Every waiver must have an expiration or follow-up condition.

| Waiver Type | Expiration Rule |
|---|---|
| Missing documentation | Must be fixed before next implementation handoff |
| Missing test | Must be fixed before merge or release unless explicitly deferred |
| Missing evidence | Must be fixed before release |
| Read-only inspection gap | Must be fixed before source modification |
| Prompt record gap | Must be reconstructed before audit closeout |
| Restricted-zone approval gap | Cannot expire because waiver is not allowed |

---

## 12. Relationship With Audit And Release

This register feeds the AI-assisted change audit and release gate.

```text
00760 AI-Assisted Change Control Audit
  ↓
00770 Exception And Waiver Log
  ↓
00700 Development Foundation Code Handoff Readiness
  ↓
64390 Flow Bundle Pre-Merge And Release Gate
```

Open high or critical waivers must block merge/release unless an explicit approved exception exists and the area is waivable.

---

## 13. Review Cadence

| Review Type | Frequency |
|---|---|
| Open low/medium waivers | Weekly or before next handoff |
| High waivers | Before merge |
| Critical waivers | Immediate review |
| Waivers linked to release | Before release gate |
| Waivers linked to restricted zones | Immediate escalation |

---

## 14. Closure Checklist

A waiver may be closed only when:

- [ ] The missing artifact was created or updated.
- [ ] The compensating control was completed.
- [ ] The affected Flow Bundle or document was updated.
- [ ] Test/evidence gaps were closed or formally deferred.
- [ ] Restricted-zone approval was recorded where required.
- [ ] The audit record was updated.
- [ ] The closure owner and date are recorded.

---

## 15. Example Waiver Rows

| Waiver ID | Date | Related Document / Flow Bundle | Exception Type | Description | Severity | Waiver Requested? | Approved? | Approver | Compensating Control | Due Date | Status |
|---|---|---|---|---|---|---:|---:|---|---|---|---|
| WAIVER-EX-001 | YYYY-MM-DD | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md | MISSING_TEST | Fault injection test target not yet known before read-only inspection | Medium | Yes | TBD | Architecture | Complete 00720 inspection first | YYYY-MM-DD | Open |
| WAIVER-EX-002 | YYYY-MM-DD | 64120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | MISSING_EVIDENCE | Evidence packet location not finalized | High | Yes | TBD | Engineering / QA | Create evidence packet before merge | YYYY-MM-DD | Open |
| WAIVER-EX-003 | YYYY-MM-DD | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md | RESTRICTED_ZONE_TOUCH | Payment module touched without approval | Critical | No | No | N/A | Block and review immediately | Immediate | Blocked |

---

## 16. Summary

This register is the safety ledger for deviations from the development foundation process.

It does not make unsafe work safe.

It ensures that any deviation from:

```text
Overview → Logic → Module → File → Test → Evidence
```

is visible, reviewed, approved where allowed, and blocked where not allowed.
