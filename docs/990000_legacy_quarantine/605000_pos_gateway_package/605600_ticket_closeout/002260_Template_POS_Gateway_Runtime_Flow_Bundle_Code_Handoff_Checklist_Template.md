# 002260_Template_POS_Gateway_Runtime_Flow_Bundle_Code_Handoff_Checklist_Template.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 02260 |
| Document Type | Template |
| Package | POS Gateway Runtime Flow Implementation Package |
| Bundle | Code Handoff Checklist |
| Status | Draft for controlled implementation handoff preparation |
| Runtime Implementation | Prohibited unless later approved by explicit gate |
| Corrective Action Execution | Prohibited unless later approved by explicit gate |
| Production Release | Prohibited unless later approved by explicit gate |
| Implementation Hold | Active unless explicitly lifted by approved scope gate |
| Encoding Rule | Preserve UTF-8. Do not normalize encoding. Do not run formatters. |
| Korean-Heavy Rewrite Rule | Cursor must not rewrite Korean-heavy documents. |

## 2. Purpose

This template defines the code handoff checklist that must be completed before a bounded POS Gateway Runtime Flow implementation ticket is handed to Claude, Cursor, or a human developer.

The checklist exists to prevent unsafe implementation, broad refactors, undocumented file changes, SQL drift, untested state transitions, missing audit evidence, and loss of traceability between MD design, SQL, Backend/API, Flutter, tests, evidence, and closeout records.

This template does not authorize runtime implementation, corrective action execution, production deployment, POS provider activation, credential activation, webhook activation, payment mutation, reconciliation mutation, rollback execution, database migration, evidence rewrite, encoding normalization, formatter execution, or Korean-heavy Cursor rewrite.

## 3. Handoff Principle

No code handoff is valid unless the ticket has:

```text
A bounded implementation module
A complete source MD bundle
A selected implementation class
A clear allowed file list
A clear disallowed file list
A SQL boundary
A Backend/API boundary
A Flutter boundary
A test boundary
An evidence requirement
A closeout requirement
A prompt safety block
```

If any of these are missing, do not hand off the ticket.

## 4. Required Upstream Documents

| Source Document | Required Use |
|---|---|
| 002240_Template_POS_Gateway_Runtime_Flow_Bundle_Implementation_Ticket_Package_Template.md | Implementation ticket package source |
| 002250_Checklist_POS_Gateway_Runtime_Flow_Bundle_Implementation_Ticket_Package_Readiness_Checklist.md | Ticket readiness source |
| Authorization Gate Draft / Decision | Defines allowed implementation class |
| Flow Bundle MD | Defines flow boundary |
| Overview MD | Defines purpose |
| Logic MD | Defines state transitions |
| Module MD | Defines implementation boundary |
| Matrix MD | Defines source-test-owner-risk mapping |
| Evidence Packet Template | Defines required evidence |
| Implementation Review Packet Template | Defines implementation review output |
| Closeout Template | Defines closeout/fix guide output |

## 5. Handoff Header Template

```text
Code Handoff ID:
Implementation Ticket ID:
Implementation Module Name:
Target Flow Bundle:
Implementation Class:
Handoff Owner:
Implementation Owner:
Reviewer:
Tool Target: Claude / Cursor / Human Developer / Mixed
Project Root:
Allowed File Set Complete: Yes / No
Disallowed File Set Complete: Yes / No
Source MD Bundle Complete: Yes / No
SQL Scope Complete: Yes / No
Backend/API Scope Complete: Yes / No
Flutter Scope Complete: Yes / No
Test Scope Complete: Yes / No
Evidence Requirement Complete: Yes / No
Closeout Requirement Complete: Yes / No
Implementation Hold State:
```

## 6. Tool Target Decision

| Tool Target | Allowed Role | Restrictions |
|---|---|---|
| Claude | Code drafting, logic explanation, SQL/API/Flutter/test draft generation | Must not apply files unless separate tool/process allows it |
| Cursor | Bounded file application, diff inspection, limited code edits | Must not rewrite Korean-heavy docs, run formatters, normalize encoding, or modify outside scope |
| Human Developer | Manual review, implementation, testing, evidence capture | Must follow same boundaries and evidence rules |
| Mixed | Claude drafts, Cursor applies, human reviews | Must split responsibilities explicitly |

Tool responsibilities must not overlap ambiguously.

## 7. Project Root And Branch Check

| Check ID | Requirement | Required Result | Status |
|---|---|---|---|
| ROOT-02260-001 | Project root | Must be specified | Pending |
| ROOT-02260-002 | Repository name | Must be specified | Pending |
| ROOT-02260-003 | Current branch | Must be recorded before work | Pending |
| ROOT-02260-004 | Git status before work | Must be recorded before work | Pending |
| ROOT-02260-005 | Dirty files before work | Must be listed or explicitly none | Pending |
| ROOT-02260-006 | Untracked files before work | Must be listed or explicitly none | Pending |
| ROOT-02260-007 | Worktree safety | Must not overwrite unrelated work | Pending |

Do not begin file changes if unrelated dirty files exist and are not acknowledged.

## 8. Source MD Bundle Check

| Check ID | MD Role | Required Result | Status |
|---|---|---|---|
| MD-02260-001 | Flow Bundle MD | Present | Pending |
| MD-02260-002 | Overview MD | Present | Pending |
| MD-02260-003 | Logic MD | Present | Pending |
| MD-02260-004 | Module MD | Present | Pending |
| MD-02260-005 | Matrix MD | Present | Pending |
| MD-02260-006 | Implementation Ticket Package | Present | Pending |
| MD-02260-007 | Ticket Readiness Checklist | Present | Pending |
| MD-02260-008 | Evidence Packet Template | Present | Pending |
| MD-02260-009 | Implementation Review Packet Template | Present | Pending |
| MD-02260-010 | Closeout Template | Present | Pending |

The handoff must cite exact filenames.

## 9. Allowed File List Template

| File ID | Path | File Type | Operation | Owner | Notes |
|---|---|---|---|---|---|
| ALLOW-02260-001 | Pending | SQL / Backend / Flutter / Test / MD | Create / Modify / Read only | Pending | Pending |

Only files listed here may be modified.

## 10. Disallowed File List Template

| File ID | Path / Pattern | Reason | Enforcement |
|---|---|---|---|
| DENY-02260-001 | Production secrets | Secret safety | Block |
| DENY-02260-002 | Credential files | Security boundary | Block |
| DENY-02260-003 | Webhook live config | Activation boundary | Block |
| DENY-02260-004 | Production deployment config | Release boundary | Block |
| DENY-02260-005 | Korean-heavy MD files outside allowed list | Cursor safety | Block |
| DENY-02260-006 | Unrelated modules | Scope boundary | Block |
| DENY-02260-007 | Evidence archive files | Evidence preservation | Block unless review-only |
| DENY-02260-008 | Migration history outside ticket | Data safety | Block |
| DENY-02260-009 | Payment/reconciliation live logic outside scope | Financial boundary | Block |

Disallowed files must not be edited.

## 11. SQL Handoff Check

| Check ID | SQL Requirement | Required Result | Status |
|---|---|---|---|
| SQL-02260-001 | SQL files listed | Present or not applicable | Pending |
| SQL-02260-002 | Migration names listed | Present if SQL is in scope | Pending |
| SQL-02260-003 | Tables read listed | Present or explicitly none | Pending |
| SQL-02260-004 | Tables written listed | Present or explicitly none | Pending |
| SQL-02260-005 | Constraints/indexes listed | Present or explicitly none | Pending |
| SQL-02260-006 | RLS policy impact listed | Present or explicitly none | Pending |
| SQL-02260-007 | Migration application authorization | Explicitly allowed or prohibited | Pending |
| SQL-02260-008 | Rollback notes | Present if SQL is in scope | Pending |
| SQL-02260-009 | Data preservation notes | Present if SQL is in scope | Pending |

SQL migration application is prohibited unless explicitly authorized by the implementation class.

## 12. Backend/API Handoff Check

| Check ID | Backend/API Requirement | Required Result | Status |
|---|---|---|---|
| API-02260-001 | Backend/API files listed | Present or not applicable | Pending |
| API-02260-002 | Endpoints listed | Present or explicitly none | Pending |
| API-02260-003 | Services listed | Present or explicitly none | Pending |
| API-02260-004 | Validators listed | Present or explicitly none | Pending |
| API-02260-005 | Normalizers listed | Present or explicitly none | Pending |
| API-02260-006 | Audit append path listed | Present or explicitly none | Pending |
| API-02260-007 | DLQ/quarantine path listed | Present or explicitly none | Pending |
| API-02260-008 | Provider adapter path listed | Present or explicitly none | Pending |
| API-02260-009 | Error handler listed | Present or explicitly none | Pending |
| API-02260-010 | File application authorization | Explicitly allowed or prohibited | Pending |

Backend/API edits must remain inside allowed files.

## 13. Flutter Handoff Check

| Check ID | Flutter Requirement | Required Result | Status |
|---|---|---|---|
| FLT-02260-001 | Flutter files listed | Present or not applicable | Pending |
| FLT-02260-002 | Screens listed | Present or explicitly none | Pending |
| FLT-02260-003 | Widgets listed | Present or explicitly none | Pending |
| FLT-02260-004 | Routes listed | Present or explicitly none | Pending |
| FLT-02260-005 | State display rules listed | Present or explicitly none | Pending |
| FLT-02260-006 | Error state UI listed | Present or explicitly none | Pending |
| FLT-02260-007 | Manual review UI listed | Present or explicitly none | Pending |
| FLT-02260-008 | Localization keys listed | Present or explicitly none | Pending |
| FLT-02260-009 | File application authorization | Explicitly allowed or prohibited | Pending |

Flutter work must not invent backend states that are not defined in Logic MD.

## 14. State Logic Handoff Check

| Check ID | State Logic Requirement | Required Result | Status |
|---|---|---|---|
| LOGIC-02260-001 | State transitions listed | Present or not applicable | Pending |
| LOGIC-02260-002 | Event triggers listed | Present | Pending |
| LOGIC-02260-003 | Guards/conditions listed | Present or explicitly none | Pending |
| LOGIC-02260-004 | Duplicate handling listed | Present if event ingestion is in scope | Pending |
| LOGIC-02260-005 | Replay handling listed | Present if webhook/event ingestion is in scope | Pending |
| LOGIC-02260-006 | Timeout/unknown handling listed | Present if provider calls are in scope | Pending |
| LOGIC-02260-007 | Audit append failure handling listed | Present if audit in scope | Pending |
| LOGIC-02260-008 | DLQ/quarantine routing listed | Present if failure path in scope | Pending |
| LOGIC-02260-009 | Manual review triggers listed | Present or explicitly none | Pending |
| LOGIC-02260-010 | Test mapping listed | Present | Pending |

Code must not implement state transitions not present in the source MD bundle.

## 15. Security Handoff Check

| Check ID | Security Requirement | Required Result | Status |
|---|---|---|---|
| SEC-02260-001 | Secret handling boundary | Defined | Pending |
| SEC-02260-002 | Credential activation | Prohibited unless explicitly authorized | Pending |
| SEC-02260-003 | Webhook activation | Prohibited unless explicitly authorized | Pending |
| SEC-02260-004 | Signature verification logic | Defined if applicable | Pending |
| SEC-02260-005 | Nonce/replay guard | Defined if applicable | Pending |
| SEC-02260-006 | Access control | Defined | Pending |
| SEC-02260-007 | Audit integrity | Defined | Pending |
| SEC-02260-008 | Security tests | Defined or explicitly none | Pending |
| SEC-02260-009 | Security owner approval | Present or not applicable with rationale | Pending |

Security-sensitive work must not proceed without explicit boundaries.

## 16. Financial Audit Handoff Check

| Check ID | Financial Requirement | Required Result | Status |
|---|---|---|---|
| FIN-02260-001 | Payment mutation boundary | Prohibited unless explicitly authorized | Pending |
| FIN-02260-002 | Cancellation mutation boundary | Prohibited unless explicitly authorized | Pending |
| FIN-02260-003 | Refund mutation boundary | Prohibited unless explicitly authorized | Pending |
| FIN-02260-004 | Settlement mutation boundary | Prohibited unless explicitly authorized | Pending |
| FIN-02260-005 | Reconciliation mutation boundary | Prohibited unless explicitly authorized | Pending |
| FIN-02260-006 | Ledger impact | Defined or explicitly none | Pending |
| FIN-02260-007 | Financial audit tests | Defined or explicitly none | Pending |
| FIN-02260-008 | Financial audit owner approval | Present or not applicable with rationale | Pending |

Financial logic must not be inferred from UI or provider assumptions.

## 17. Test Handoff Check

| Check ID | Test Requirement | Required Result | Status |
|---|---|---|---|
| TEST-02260-001 | Test files listed | Present or not applicable | Pending |
| TEST-02260-002 | Unit tests defined | Present or explicitly none | Pending |
| TEST-02260-003 | Integration tests defined | Present or explicitly none | Pending |
| TEST-02260-004 | State transition tests defined | Present or explicitly none | Pending |
| TEST-02260-005 | Security tests defined | Present or explicitly none | Pending |
| TEST-02260-006 | Financial audit tests defined | Present or explicitly none | Pending |
| TEST-02260-007 | Failure/DLQ tests defined | Present or explicitly none | Pending |
| TEST-02260-008 | UI tests defined | Present or explicitly none | Pending |
| TEST-02260-009 | Test execution command listed | Present if test execution authorized | Pending |
| TEST-02260-010 | Test execution authorization | Explicitly allowed or prohibited | Pending |

Test execution must not be assumed.

## 18. Evidence Handoff Check

| Check ID | Evidence Requirement | Required Result | Status |
|---|---|---|---|
| EVD-02260-001 | Evidence Packet ID planned | Present | Pending |
| EVD-02260-002 | SQL evidence requirement | Present if SQL in scope | Pending |
| EVD-02260-003 | Backend/API evidence requirement | Present if backend/API in scope | Pending |
| EVD-02260-004 | Flutter evidence requirement | Present if Flutter in scope | Pending |
| EVD-02260-005 | Test evidence requirement | Present if tests in scope | Pending |
| EVD-02260-006 | Audit evidence requirement | Present if audit in scope | Pending |
| EVD-02260-007 | Error/DLQ evidence requirement | Present if failure path in scope | Pending |
| EVD-02260-008 | Security evidence requirement | Present if security path in scope | Pending |
| EVD-02260-009 | Financial audit evidence requirement | Present if financial path in scope | Pending |
| EVD-02260-010 | Evidence preservation rule | Present | Pending |

Evidence must be captured after implementation or test actions.

## 19. Closeout Handoff Check

| Check ID | Closeout Requirement | Required Result | Status |
|---|---|---|---|
| CLO-02260-001 | Implementation Review Packet planned | Present | Pending |
| CLO-02260-002 | Closeout file planned | Present | Pending |
| CLO-02260-003 | Fix guide planned | Present | Pending |
| CLO-02260-004 | Changed file list requirement | Present | Pending |
| CLO-02260-005 | Test result requirement | Present | Pending |
| CLO-02260-006 | Evidence link requirement | Present | Pending |
| CLO-02260-007 | Excluded scope preservation requirement | Present | Pending |
| CLO-02260-008 | Known risk requirement | Present | Pending |
| CLO-02260-009 | Rollback/recovery notes requirement | Present if applicable | Pending |
| CLO-02260-010 | Final closeout decision requirement | Present | Pending |

A handoff without closeout requirements is incomplete.

## 20. Prompt Safety Handoff Check

| Check ID | Prompt Safety Rule | Required Result | Status |
|---|---|---|---|
| PS-02260-001 | Preserve UTF-8 | Present | Pending |
| PS-02260-002 | Do not normalize encoding | Present | Pending |
| PS-02260-003 | Do not run formatters | Present | Pending |
| PS-02260-004 | Do not rewrite Korean-heavy documents | Present | Pending |
| PS-02260-005 | Do not rewrite full documents for style | Present | Pending |
| PS-02260-006 | Do not modify files outside allowed scope | Present | Pending |
| PS-02260-007 | Do not activate credentials or webhooks | Present | Pending |
| PS-02260-008 | Do not modify production settings | Present | Pending |
| PS-02260-009 | Do not mutate payment/reconciliation logic unless authorized | Present | Pending |
| PS-02260-010 | Return changed file list | Present | Pending |
| PS-02260-011 | Return test list | Present | Pending |
| PS-02260-012 | Return evidence notes | Present | Pending |

Unsafe prompts must be rejected before tool use.

## 21. Handoff Decision Record

```text
Code Handoff Decision:
Implementation Ticket ID:
Implementation Module Name:
Tool Target:
Source MD Bundle State:
Allowed File List State:
Disallowed File List State:
SQL Scope State:
Backend/API Scope State:
Flutter Scope State:
State Logic State:
Security Boundary State:
Financial Audit Boundary State:
Test Scope State:
Evidence Scope State:
Closeout Scope State:
Prompt Safety State:
Decision:
Reviewer:
Review Date:
Conditions:
Required Follow-Up:
```

## 22. Non-Authorization Confirmation

This checklist confirms that the following remain prohibited unless a later approved gate explicitly authorizes them within bounded scope:

```text
Runtime Implementation: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Corrective Action Execution: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Production Release: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
POS Provider Activation: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Credential Activation: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Webhook Activation: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Payment Mutation: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Reconciliation Mutation: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Database Migration: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Rollback Execution: PROHIBITED UNLESS EXPLICITLY AUTHORIZED
Evidence Rewrite: PROHIBITED
Encoding Normalization: PROHIBITED
Formatter Execution: PROHIBITED
Cursor Korean-Heavy Rewrite: PROHIBITED
```

## 23. Downstream Prompt Safety Block

Any downstream prompt derived from this code handoff checklist must include:

```text
Preserve UTF-8.
Do not normalize encoding.
Do not run formatters.
Do not rewrite Korean-heavy documents.
Do not rewrite full documents for style.
Do not execute runtime implementation unless a later approved gate explicitly authorizes it.
Do not execute corrective action unless a later approved gate explicitly authorizes it.
Do not activate credentials or webhooks.
Do not modify production settings.
Do not mutate payment, cancellation, refund, settlement, or reconciliation logic unless explicitly authorized by a later approved gate.
Do not delete or rewrite evidence.
Do not modify files outside the allowed implementation ticket scope.
Return changed file list, test list, and evidence notes.
```

## 24. Failure Handling

| Failure | Required Handling |
|---|---|
| Missing project root | Block handoff |
| Dirty worktree not recorded | Block handoff |
| Missing source MD bundle | Block handoff |
| Missing allowed file list | Block handoff |
| Missing disallowed file list | Block handoff |
| Missing SQL scope | Return for SQL scope repair |
| Missing Backend/API scope | Return for backend/API scope repair |
| Missing Flutter scope | Return for Flutter scope repair |
| Missing state logic | Return to Logic MD / Module MD |
| Missing security boundary | Route to Security Owner |
| Missing financial boundary | Route to Financial Audit Owner |
| Missing test scope | Block handoff |
| Missing evidence requirement | Block handoff |
| Missing closeout requirement | Block handoff |
| Prompt allows broad rewrite | Reject prompt |
| Prompt allows formatter or encoding normalization | Reject prompt |
| Prompt allows Korean-heavy Cursor rewrite | Reject prompt |
| Prompt modifies outside allowed files | Reject prompt |
| Handoff implies production release | Escalate to Governance Owner |

## 25. Recommended Next Document

Recommended next file:

`002270_Template_POS_Gateway_Runtime_Flow_Bundle_Claude_Implementation_Prompt_Template.md`

Alternative next files:

- `02270_Template_POS_Gateway_Runtime_Flow_Bundle_Cursor_File_Application_Prompt_Template.md`
- `02270_Template_POS_Gateway_Runtime_Flow_Bundle_Implementation_Review_Packet_Template.md`
- `02270_Template_POS_Gateway_Runtime_Flow_Bundle_Change_Evidence_Packet_Template.md`

## 26. Final Template Statement

This template defines the code handoff checklist for a bounded POS Gateway Runtime Flow implementation ticket.

```text
Code Handoff Checklist Template: Created
Runtime Implementation: Prohibited unless later approved
Corrective Action Execution: Prohibited unless later approved
Production Release: Prohibited unless later approved
Implementation Hold: Active unless explicitly lifted
Handoff Unit: Source MD + Allowed Files + Disallowed Files + SQL/API/Flutter/Test/Evidence/Closeout Boundaries
Evidence Preservation: Required
UTF-8 Preservation: Required
Encoding Normalization: Prohibited
Formatter Execution: Prohibited
Cursor Korean-Heavy Rewrite: Prohibited
```
