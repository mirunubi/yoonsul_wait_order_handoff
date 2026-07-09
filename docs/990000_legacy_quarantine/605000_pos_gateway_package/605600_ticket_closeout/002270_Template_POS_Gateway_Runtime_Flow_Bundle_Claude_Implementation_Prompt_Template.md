# 002270_Template_POS_Gateway_Runtime_Flow_Bundle_Claude_Implementation_Prompt_Template.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 02270 |
| Document Type | Template |
| Package | POS Gateway Runtime Flow Implementation Package |
| Bundle | Claude Implementation Prompt |
| Status | Draft for controlled implementation handoff preparation |
| Runtime Implementation | Prohibited unless later approved by explicit gate |
| Corrective Action Execution | Prohibited unless later approved by explicit gate |
| Production Release | Prohibited unless later approved by explicit gate |
| Implementation Hold | Active unless explicitly lifted by approved scope gate |
| Encoding Rule | Preserve UTF-8. Do not normalize encoding. Do not run formatters. |
| Korean-Heavy Rewrite Rule | Claude must not rewrite Korean-heavy documents unless explicitly authorized. |

## 2. Purpose

This template defines the standard prompt format for asking Claude to draft bounded implementation artifacts for a POS Gateway Runtime Flow implementation ticket.

Claude may be used for:

- SQL migration draft generation;
- Backend/API code draft generation;
- Flutter code draft generation;
- test draft generation;
- implementation review notes;
- evidence planning;
- risk and boundary review.

Claude must not be used to apply files, activate runtime behavior, execute tests, mutate production settings, activate credentials, activate webhooks, or rewrite evidence unless a later explicit gate authorizes that action.

## 3. Claude Role Boundary

| Area | Claude May Do | Claude Must Not Do |
|---|---|---|
| MD review | Read and summarize bounded source MDs | Rewrite full documents for style |
| SQL | Draft migration content | Apply migrations |
| Backend/API | Draft bounded code | Apply files or activate endpoints |
| Flutter | Draft bounded UI code | Apply files or invent backend states |
| Tests | Draft test files and commands | Execute tests unless separately authorized |
| Evidence | Draft evidence checklist | Rewrite or delete evidence |
| Security | Draft verifier/replay/guard logic | Activate credentials or webhooks |
| Financial | Draft non-mutating audit logic if authorized | Mutate payment/reconciliation logic without explicit gate |
| Closeout | Draft review/closeout notes | Claim final implementation completion without evidence |

## 4. Required Upstream Inputs

| Input | Required |
|---|---|
| Implementation Ticket ID | Yes |
| Implementation Ticket Package | Yes |
| Code Handoff Checklist | Yes |
| Flow Bundle MD | Yes |
| Overview MD | Yes |
| Logic MD | Yes |
| Module MD | Yes |
| Matrix MD | Yes |
| Authorization Gate Source | Yes |
| Allowed File List | Yes |
| Disallowed File List | Yes |
| SQL Scope | Yes, or explicitly none |
| Backend/API Scope | Yes, or explicitly none |
| Flutter Scope | Yes, or explicitly none |
| Test Scope | Yes, or explicitly none |
| Evidence Requirement | Yes |
| Closeout Requirement | Yes |

Missing upstream inputs must be reported as blockers.

## 5. Claude Prompt Header Template

```text
You are assisting with a controlled POS Gateway Runtime Flow implementation ticket.

Project:
- Project root:
- Repository:
- Branch:
- Implementation Ticket ID:
- Implementation Module Name:
- Target Flow Bundle:
- Implementation Class:
- Authorization Gate Source:
- Implementation Hold State:

Your role:
- Draft bounded implementation artifacts only.
- Do not apply files.
- Do not execute code.
- Do not run tests.
- Do not activate credentials or webhooks.
- Do not modify production settings.
- Do not mutate payment/reconciliation logic unless explicitly authorized.
```

## 6. Source MD Bundle Section

```text
Source MD Bundle:
1. Flow Bundle MD:
2. Overview MD:
3. Logic MD:
4. Module MD:
5. Matrix MD:
6. Code Handoff Checklist:
7. Evidence Packet Template:
8. Implementation Review Packet Template:
9. Closeout Template:

Use these documents as the source of truth.
Do not invent states, tables, files, APIs, or flows that are not supported by the source bundle.
If the source bundle is incomplete, stop and report blockers.
```

## 7. Allowed Scope Section

```text
Allowed Work:
- SQL draft:
- Backend/API draft:
- Flutter draft:
- Test draft:
- Evidence note draft:
- Review note draft:

Allowed Files:
1.
2.
3.

Allowed Output Types:
- Proposed SQL migration content
- Proposed Backend/API code blocks
- Proposed Flutter code blocks
- Proposed test code blocks
- File-by-file change plan
- Test plan
- Evidence plan
- Risk notes
```

Claude must not modify files directly.

## 8. Disallowed Scope Section

```text
Disallowed Work:
- Do not apply file changes.
- Do not execute runtime implementation.
- Do not execute corrective action.
- Do not activate credentials.
- Do not activate webhooks.
- Do not modify production settings.
- Do not run migrations.
- Do not run tests unless later explicitly authorized.
- Do not mutate payment, cancellation, refund, settlement, or reconciliation logic unless explicitly authorized.
- Do not delete or rewrite evidence.
- Do not normalize encoding.
- Do not run formatters.
- Do not rewrite Korean-heavy documents.
- Do not change files outside the allowed file list.
- Do not perform broad refactors.
```

## 9. SQL Draft Instruction Template

Use this only if SQL is in scope.

```text
SQL Scope:
- Tables:
- Indexes:
- Constraints:
- RLS policies:
- Functions / triggers:
- Seed / reference data:
- Migration file name:
- Migration application: Prohibited unless later approved

Task:
Draft SQL migration content only.
Include comments explaining purpose.
Include rollback notes where appropriate.
Do not assume migration execution.
Do not change existing schema outside the allowed scope.
```

## 10. Backend/API Draft Instruction Template

Use this only if Backend/API is in scope.

```text
Backend/API Scope:
- Endpoints:
- Services:
- Validators:
- Normalizers:
- Audit append path:
- DLQ / quarantine path:
- Provider adapter:
- Error handler:
- Files:

Task:
Draft bounded Backend/API code only.
Preserve existing interfaces unless the source MD explicitly requires changes.
Include validation, audit append, failure handling, and owner-visible errors where required.
Do not activate endpoints or live provider behavior.
Do not modify files outside the allowed list.
```

## 11. Flutter Draft Instruction Template

Use this only if Flutter is in scope.

```text
Flutter Scope:
- Screens:
- Widgets:
- Routes:
- Status display rules:
- Error states:
- Manual review UI:
- Localization keys:
- Files:

Task:
Draft bounded Flutter UI code only.
Only display states defined in the Logic MD.
Do not invent backend states.
Do not add customer-facing behavior outside scope.
Do not modify files outside the allowed list.
```

## 12. Test Draft Instruction Template

Use this only if tests are in scope.

```text
Test Scope:
- Unit tests:
- Integration tests:
- State transition tests:
- Security boundary tests:
- Financial audit boundary tests:
- Failure / DLQ tests:
- UI tests:
- Regression tests:
- Test files:
- Test execution: Prohibited unless later approved

Task:
Draft test code or test plan only.
Map each test to a source MD rule and expected evidence output.
Do not execute tests.
```

## 13. State Logic Instruction

```text
State Logic Rules:
- Use only states defined in the Logic MD.
- Use only transitions defined in the Logic MD or Matrix MD.
- Every transition must have:
  - from_state
  - event
  - guard / condition
  - to_state
  - audit event
  - error path
  - test mapping

If a required state or transition is missing, stop and report a blocker.
```

## 14. Security Instruction

```text
Security Rules:
- Do not expose secrets.
- Do not create plaintext secret storage.
- Do not activate credentials.
- Do not activate webhooks.
- Include signature verification if webhook ingestion is in scope.
- Include nonce/replay guard if webhook/event ingestion is in scope.
- Include access control checks where required.
- Include audit integrity checks where required.
- Route unclear security scope to Security Owner.
```

## 15. Financial Audit Instruction

```text
Financial Audit Rules:
- Do not mutate payment, cancellation, refund, settlement, or reconciliation logic unless explicitly authorized.
- If financial tables are read, document read-only scope.
- If financial audit events are generated, make them append-only.
- Include ledger impact notes where applicable.
- Route unclear financial scope to Financial Audit Owner.
```

## 16. Evidence Output Requirement

Claude must return an evidence plan:

```text
Evidence Plan:
- SQL evidence:
- Backend/API evidence:
- Flutter evidence:
- Test evidence:
- Audit evidence:
- Error / DLQ evidence:
- Security evidence:
- Financial audit evidence:
- Screenshots / UI evidence:
- Known gaps:
- Residual risks:
```

## 17. Required Claude Output Format

Claude must return the result in this structure.

```text
1. Scope Confirmation
2. Blockers / Missing Inputs
3. File-by-File Change Plan
4. SQL Drafts
5. Backend/API Drafts
6. Flutter Drafts
7. Test Drafts
8. Evidence Plan
9. Risk Notes
10. Excluded Scope Confirmation
11. Handoff Notes For Cursor Or Human Developer
```

If there are blockers, Claude must stop before code drafting.

## 18. Excluded Scope Confirmation

Claude must explicitly confirm:

```text
Excluded Scope Confirmation:
- Production release: excluded
- Credential activation: excluded
- Webhook activation: excluded
- Payment/reconciliation mutation: excluded unless explicitly authorized
- Runtime implementation outside ticket: excluded
- Corrective action execution: excluded unless explicitly authorized
- Evidence rewrite: excluded
- Encoding normalization: excluded
- Formatter execution: excluded
- Korean-heavy document rewrite: excluded
- Files outside allowed list: excluded
```

## 19. Prompt Safety Block

Every Claude implementation prompt must include:

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

## 20. Claude Prompt Completeness Checklist

| Check | Required Result | Status |
|---|---|---|
| Project root included | Present | Pending |
| Implementation ticket ID included | Present | Pending |
| Implementation class included | Present | Pending |
| Authorization source included | Present | Pending |
| Source MD bundle listed | Present | Pending |
| Allowed work listed | Present | Pending |
| Allowed files listed | Present | Pending |
| Disallowed work listed | Present | Pending |
| Disallowed files listed | Present | Pending |
| SQL scope included or marked none | Present | Pending |
| Backend/API scope included or marked none | Present | Pending |
| Flutter scope included or marked none | Present | Pending |
| Test scope included or marked none | Present | Pending |
| State logic rules included | Present | Pending |
| Security rules included | Present | Pending |
| Financial audit rules included | Present | Pending |
| Evidence plan required | Present | Pending |
| Required output format included | Present | Pending |
| Excluded scope confirmation required | Present | Pending |
| Prompt safety block included | Present | Pending |

## 21. Failure Handling

| Failure | Required Handling |
|---|---|
| Missing source MD bundle | Stop and report blocker |
| Missing implementation ticket | Stop and report blocker |
| Missing authorization source | Stop and report blocker |
| Missing allowed file list | Stop and report blocker |
| Missing disallowed file list | Stop and report blocker |
| Missing SQL scope when SQL requested | Stop and report blocker |
| Missing Backend/API scope when backend requested | Stop and report blocker |
| Missing Flutter scope when Flutter requested | Stop and report blocker |
| Missing test scope when tests requested | Stop and report blocker |
| Missing security boundary | Stop or route to Security Owner |
| Missing financial boundary | Stop or route to Financial Audit Owner |
| Prompt asks to apply files | Refuse that part and provide drafts only |
| Prompt asks to run tests without authorization | Refuse execution and provide test plan |
| Prompt asks to activate credentials/webhooks | Refuse and route to Security Owner |
| Prompt asks broad refactor | Refuse and request bounded scope |
| Prompt asks evidence rewrite | Refuse and preserve evidence |

## 22. Recommended Next Document

Recommended next file:

`002280_Template_POS_Gateway_Runtime_Flow_Bundle_Cursor_File_Application_Prompt_Template.md`

Alternative next files:

- `02280_Template_POS_Gateway_Runtime_Flow_Bundle_Implementation_Review_Packet_Template.md`
- `02280_Template_POS_Gateway_Runtime_Flow_Bundle_Change_Evidence_Packet_Template.md`
- `02280_Checklist_POS_Gateway_Runtime_Flow_Bundle_Claude_Implementation_Prompt_Readiness_Checklist.md`

## 23. Final Template Statement

This template defines a controlled Claude implementation prompt for bounded POS Gateway Runtime Flow implementation drafting.

```text
Claude Implementation Prompt Template: Created
Claude Role: Draft bounded artifacts only
Runtime Implementation: Prohibited unless later approved
Corrective Action Execution: Prohibited unless later approved
Production Release: Prohibited unless later approved
Implementation Hold: Active unless explicitly lifted
Evidence Preservation: Required
UTF-8 Preservation: Required
Encoding Normalization: Prohibited
Formatter Execution: Prohibited
Korean-Heavy Rewrite: Prohibited unless explicitly authorized
```
