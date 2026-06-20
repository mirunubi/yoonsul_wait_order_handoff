# 000407_Checklist_Development_Foundation_Code_Handoff_Readiness.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Checklist |
| Document Role | Development Foundation Code Handoff Readiness Checklist |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Related Flow Handoff Gate | 64300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering / QA |
| AI Solo Change | Prohibited for payment, settlement, audit, security, DB migration, secret, and release readiness approval |

---

## 2. Purpose

This checklist determines whether a development task is ready to be handed off to Claude Code, Cursor, or a human developer.

It exists because CatchMenu / Catch&Order implementation must not be driven from a single MD file.

The required development chain is:

```text
Overview → Logic → Module → File → Test → Evidence
```

A task is not ready for code handoff until the checklist confirms that the overview, logic, module, file, test, and evidence links are complete.

---

## 3. Handoff Decision Summary

| Decision | Meaning |
|---|---|
| Ready for Claude Code Flow Bundle implementation | All required documents, mappings, tests, evidence targets, and approval gates are ready |
| Ready for Cursor limited IDE assist | Scope is narrow, file-specific, and does not touch restricted areas |
| Ready for human-only implementation | Restricted zone or unresolved ambiguity requires direct human control |
| Documentation-only update allowed | No runtime behavior, file, test, or release impact |
| Blocked | Required overview, logic, module, test, evidence, or approval is missing |

---

## 4. Pre-Handoff Scope Classification

Before any code handoff, classify the task.

| Scope Question | Answer | Gate |
|---|---|---|
| Is this a documentation-only change? | Yes / No | If Yes, code gate may not be required |
| Does this change runtime behavior? | Yes / No | If Yes, full chain required |
| Does this touch payment, cancel, refund, settlement, audit, security, DB migration, secret, or deployment? | Yes / No | If Yes, No-AI-Solo gate required |
| Does this require source file modification? | Yes / No | If Yes, Module Document required |
| Does this require tests? | Yes / No | If Yes, Test Coverage Map required |
| Does this require release evidence? | Yes / No | If Yes, Evidence Packet required |

---

## 5. Development Foundation Readiness Checklist

### 5.1 Overview Readiness

| Check | Required | Status |
|---|---:|---|
| Parent overview document exists | Yes | TBD |
| Overview defines whole flow context | Yes | TBD |
| Overview identifies actors and systems | Yes | TBD |
| Overview includes runtime boundary diagram or Mermaid flow | Yes | TBD |
| Overview links to related Flow Bundle | Yes | TBD |
| Overview identifies downstream logic documents | Yes | TBD |

### 5.2 Logic Readiness

| Check | Required | Status |
|---|---:|---|
| Logic document exists | Yes | TBD |
| State model is defined | Yes | TBD |
| Event model is defined | Yes | TBD |
| Decision rules are defined | Yes | TBD |
| Validation rules are defined | Yes | TBD |
| Timeout/retry/DLQ/replay rules are defined when relevant | Conditional | TBD |
| Cancel/refund/reversal rules are defined when relevant | Conditional | TBD |
| Audit and evidence rules are defined | Yes | TBD |
| Security rules are defined where boundary exists | Conditional | TBD |
| No-AI-Solo zone classification is complete | Yes | TBD |

### 5.3 Module Readiness

| Check | Required | Status |
|---|---:|---|
| Module document exists | Yes when code impact exists | TBD |
| Runtime modules are identified | Yes | TBD |
| Source files are identified or inspection task is defined | Yes | TBD |
| API/interface map is defined when applicable | Conditional | TBD |
| DB table/schema map is defined when applicable | Conditional | TBD |
| Queue/job/event map is defined when applicable | Conditional | TBD |
| Function/class responsibility map is defined when source exists | Conditional | TBD |
| Security implementation map is defined when applicable | Conditional | TBD |

### 5.4 File/Test/Evidence Readiness

| Check | Required | Status |
|---|---:|---|
| Expected changed files are listed | Yes | TBD |
| Restricted files are listed and protected | Yes | TBD |
| Required unit tests are identified | Conditional | TBD |
| Required integration tests are identified | Conditional | TBD |
| Required contract tests are identified | Conditional | TBD |
| Required fault injection tests are identified | Conditional | TBD |
| Required security tests are identified | Conditional | TBD |
| Required audit/evidence tests are identified | Conditional | TBD |
| Evidence packet target is defined | Yes | TBD |

---

## 6. Runtime Flow Bundle Alignment

The development foundation handoff must align with the 64000 Runtime Flow Bundle Registry.

| Runtime Flow Check | Required | Status |
|---|---:|---|
| Related Flow Bundle is identified | Yes | TBD |
| MD Dependency Graph is complete | Yes | TBD |
| Module Impact Map is complete | Yes | TBD |
| Test Coverage Map is complete | Yes | TBD |
| Flow Step → Module → File → Test → Evidence chain is complete | Yes | TBD |
| Code handoff gate is passed | Yes | TBD |
| Diff control runbook is linked | Yes | TBD |
| Implementation review packet is linked | Yes | TBD |
| Pre-merge/release gate is linked | Yes | TBD |

---

## 7. AI Tool Assignment Rule

| Tool / Actor | Allowed Role | Not Allowed |
|---|---|---|
| Claude Code | Flow Bundle implementation agent after complete handoff packet | Starting from one MD file or guessing missing context |
| Cursor | IDE assist, local diff review, narrow file-level edits | Owning whole financial/runtime Flow Bundle alone |
| ChatGPT | Documentation drafting, mapping, checklist generation, review support | Approving restricted code changes alone |
| Human Owner | Approval, restricted change review, release gate | Delegating No-AI-Solo zone approval to AI |

---

## 8. No-AI-Solo Zone Gate

If any answer is `Yes`, AI-only implementation is prohibited.

| Restricted Area | Touched? | Human Approval Required | Evidence Required |
|---|---:|---:|---|
| Payment approval | TBD | Yes | approval record |
| Payment cancel/refund/reversal | TBD | Yes | approval record |
| Settlement/reconciliation | TBD | Yes | reconciliation evidence |
| Audit ledger / tamper-evidence | TBD | Yes | audit evidence |
| Webhook signature/security | TBD | Yes | security evidence |
| Secret/token/credential | TBD | Yes | secret control evidence |
| DB migration/schema | TBD | Yes | migration plan and rollback evidence |
| Production release/deployment | TBD | Yes | release gate evidence |

---

## 9. Handoff Packet Contents

A ready handoff packet must contain:

```text
1. Work objective
2. Related Flow Bundle filename
3. Overview document filename
4. Logic document filename
5. Module document filename
6. MD Dependency Graph
7. Module Impact Map
8. Test Coverage Map
9. No-AI-Solo zone classification
10. Expected changed files
11. Restricted files
12. Required tests
13. Required evidence packet
14. Review and release gate references
```

---

## 10. Claude Code Handoff Minimum Prompt Shape

Claude Code should receive a prompt similar to the following:

```text
You are implementing one approved Flow Bundle.

Do not treat a single MD file as the implementation unit.
Use the following chain:
Overview → Logic → Module → File → Test → Evidence.

Read:
- <overview document>
- <logic document>
- <module document>
- <runtime flow bundle>
- <dependency graph>
- <module impact map>
- <test coverage map>
- <no-ai-solo zone matrix>
- <code review and diff control runbook>

Allowed scope:
- <allowed files/modules>

Prohibited scope:
- payment/settlement/audit/security/DB migration/secret/release areas unless explicitly approved
- any file not listed in the approved module map

Return:
- changed_files
- tests_added_or_updated
- test_results
- evidence_packet
- restricted_area_touch_report
- unresolved_questions
```

---

## 11. Cursor Assist Minimum Prompt Shape

Cursor should receive a narrower prompt:

```text
Assist only with the approved file-level task below.

Do not expand scope.
Do not modify restricted areas.
Do not infer missing Flow Bundle context.
Use the approved Logic and Module documents as the source of truth.

Allowed file(s):
- <file>

Task:
- <narrow task>

Required output:
- diff summary
- tests affected
- risk note
```

---

## 12. Block Conditions

Handoff must be blocked if any of the following are true:

| Block Condition | Action |
|---|---|
| No overview document | Create overview first |
| No logic document for runtime behavior | Create logic first |
| No module document for code change | Create module map first |
| No test coverage map | Define test map first |
| No evidence target | Create evidence packet target first |
| Restricted area touched without human approval | Stop and request approval |
| Source files unknown | Perform read-only codebase inspection first |
| Conflicting MD documents | Resolve dependency graph conflict first |
| AI prompt asks to modify broad codebase without Flow Bundle scope | Reject and rewrite prompt |

---

## 13. Approval Record

| Approval Item | Approver | Date | Evidence |
|---|---|---|---|
| Overview approved | TBD | TBD | TBD |
| Logic approved | TBD | TBD | TBD |
| Module map approved | TBD | TBD | TBD |
| Test map approved | TBD | TBD | TBD |
| Restricted zone approval | TBD | TBD | TBD |
| Code handoff approved | TBD | TBD | TBD |
| Pre-merge approved | TBD | TBD | TBD |
| Release approved | TBD | TBD | TBD |

---

## 14. Final Readiness Decision

| Decision Field | Value |
|---|---|
| Task Name | TBD |
| Related Flow Bundle | TBD |
| Readiness Decision | Ready / Ready with restrictions / Human-only / Documentation-only / Blocked |
| Reason | TBD |
| Allowed Tool | Claude Code / Cursor / Human / Documentation-only |
| Required Human Approval | Yes / No |
| Evidence Packet | TBD |

---

## 15. Summary

This checklist is the development foundation gate before code handoff.

It enforces the chain:

```text
Overview → Logic → Module → File → Test → Evidence
```

When the chain is complete, Claude Code may implement at Flow Bundle scope and Cursor may assist at IDE/file scope.

When the chain is incomplete, runtime implementation must be blocked or narrowed to safe documentation-only work.
