# 002280_Template_POS_Gateway_Runtime_Flow_Bundle_Cursor_File_Application_Prompt_Template.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 02280 |
| Document Type | Template |
| Package | POS Gateway Runtime Flow Implementation Package |
| Bundle | Cursor File Application Prompt |
| Status | Draft for controlled implementation handoff preparation |
| Runtime Implementation | Prohibited unless later approved by explicit gate |
| Corrective Action Execution | Prohibited unless later approved by explicit gate |
| Production Release | Prohibited unless later approved by explicit gate |
| Implementation Hold | Active unless explicitly lifted by approved scope gate |
| Encoding Rule | Preserve UTF-8. Do not normalize encoding. Do not run formatters. |
| Korean-Heavy Rewrite Rule | Cursor must not rewrite Korean-heavy documents. |

## 2. Purpose

This template defines the standard prompt format for using Cursor to apply bounded file changes for a POS Gateway Runtime Flow implementation ticket.

Cursor is used only for controlled file application, limited patching, diff inspection, and bounded verification. Cursor must not be used for broad refactoring, Korean-heavy document rewriting, encoding normalization, formatter execution, credential activation, webhook activation, production setting changes, payment/reconciliation mutation, evidence rewrite, or changes outside the allowed file list.

This template does not authorize implementation by itself. Cursor may apply files only when a later explicit gate authorizes the implementation class and allowed file set.

## 3. Cursor Role Boundary

| Area | Cursor May Do | Cursor Must Not Do |
|---|---|---|
| File application | Apply listed file changes only | Modify files outside allowed list |
| Diff inspection | Return git diff summary | Hide unrelated changes |
| SQL | Create or modify listed migration files only | Apply migrations unless separately authorized |
| Backend/API | Modify listed files only | Activate live endpoints or credentials |
| Flutter | Modify listed files only | Invent backend states |
| Tests | Create or modify listed test files | Execute tests unless separately authorized |
| MD | Update explicitly allowed English-safe handoff docs | Rewrite Korean-heavy documents |
| Formatting | Preserve existing style locally | Run formatters or normalize encoding |
| Evidence | Append evidence notes if allowed | Rewrite or delete evidence |

## 4. Required Upstream Inputs

| Input | Required |
|---|---|
| Implementation Ticket ID | Yes |
| Code Handoff Checklist | Yes |
| Claude Draft Output or Human Patch Plan | Yes |
| Allowed File List | Yes |
| Disallowed File List | Yes |
| Project Root | Yes |
| Current Branch | Yes |
| Pre-Work Git Status | Yes |
| SQL Scope | Yes, or explicitly none |
| Backend/API Scope | Yes, or explicitly none |
| Flutter Scope | Yes, or explicitly none |
| Test Scope | Yes, or explicitly none |
| Evidence Requirement | Yes |
| Closeout Requirement | Yes |

Missing upstream inputs must block Cursor work.

## 5. Cursor Prompt Header Template

```text
You are applying a bounded implementation ticket in Cursor.

Project root:
Repository:
Current branch:
Implementation Ticket ID:
Implementation Module Name:
Implementation Class:
Authorization Gate Source:
Code Handoff Checklist:
Claude Draft Output / Patch Plan:
Implementation Hold State:

Your role:
- Apply only the explicitly listed file changes.
- Do not modify files outside the allowed file list.
- Do not run formatters.
- Do not normalize encoding.
- Do not rewrite Korean-heavy documents.
- Do not perform broad refactors.
- Do not activate credentials or webhooks.
- Do not modify production settings.
- Do not run tests unless explicitly authorized.
- Return touched file list, diff summary, and any blockers.
```

## 6. Pre-Work Verification Prompt Section

```text
Before editing:
1. Confirm project root.
2. Confirm current branch.
3. Run git status.
4. List dirty files.
5. List untracked files.
6. Stop if unrelated dirty files exist and are not explicitly acknowledged.
7. Confirm allowed file list.
8. Confirm disallowed file list.
9. Confirm implementation class.
10. Confirm no formatter or encoding normalization will be run.
```

Cursor must not begin changes before this check is complete.

## 7. Allowed File List Section

```text
Allowed files:
1.
2.
3.

Allowed operations:
- Create:
- Modify:
- Read only:

Only these files may be changed.
If a required change appears to need another file, stop and report it as a blocker.
```

## 8. Disallowed File List Section

```text
Disallowed files and patterns:
1. Production secrets
2. Credential files
3. Webhook live configuration
4. Production deployment configuration
5. Korean-heavy MD files outside the allowed list
6. Evidence archive files unless explicitly append-only
7. Migration history outside the ticket
8. Payment/reconciliation live logic outside approved scope
9. Unrelated modules
10. Any file not listed in the allowed file list
```

Any attempt to edit disallowed files must stop the task.

## 9. Patch Source Section

```text
Patch Source:
- Claude draft output:
- Human patch plan:
- SQL migration draft:
- Backend/API draft:
- Flutter draft:
- Test draft:
- Evidence note draft:

Use the patch source only within the allowed file list.
Do not invent additional changes.
Do not broaden scope.
If the patch source conflicts with the source MD or handoff checklist, stop and report the conflict.
```

## 10. SQL Application Instruction

Use this section only if SQL file application is explicitly authorized.

```text
SQL file application:
- Allowed SQL files:
- Operation:
- Migration application: Prohibited unless separately authorized
- Rollback notes required: Yes / No
- Data preservation notes required: Yes / No

Apply only the listed SQL file changes.
Do not run migrations.
Do not change unrelated migration files.
Do not alter production data.
```

## 11. Backend/API Application Instruction

Use this section only if Backend/API file application is explicitly authorized.

```text
Backend/API file application:
- Allowed Backend/API files:
- Operation:
- Endpoint changes:
- Service changes:
- Validator changes:
- Normalizer changes:
- Audit append changes:
- DLQ/quarantine changes:
- Provider adapter changes:
- Error handler changes:

Apply only the listed file changes.
Do not activate live provider behavior.
Do not add credentials.
Do not modify production settings.
```

## 12. Flutter Application Instruction

Use this section only if Flutter file application is explicitly authorized.

```text
Flutter file application:
- Allowed Flutter files:
- Operation:
- Screen changes:
- Widget changes:
- Route changes:
- State display changes:
- Error UI changes:
- Manual review UI changes:
- Localization key changes:

Apply only the listed file changes.
Do not invent backend states.
Do not change unrelated UI flows.
```

## 13. Test Application Instruction

Use this section only if test file application is explicitly authorized.

```text
Test file application:
- Allowed test files:
- Unit tests:
- Integration tests:
- State transition tests:
- Security tests:
- Financial audit tests:
- Failure / DLQ tests:
- UI tests:
- Test execution: Prohibited unless separately authorized

Apply only test files listed here.
Do not execute tests unless explicit authorization is included.
```

## 14. Korean And Encoding Safety Section

```text
Korean / Encoding Safety:
- Preserve UTF-8.
- Do not normalize encoding.
- Do not run formatters.
- Do not rewrite Korean-heavy documents.
- Do not rewrite full documents for style.
- Do not change line endings globally.
- Do not use tools that rewrite whole files.
- Do not use PowerShell Set-Content.
- Do not use broad search-and-replace across Korean text.
```

This section is mandatory in every Cursor prompt.

## 15. Evidence And Review Output Requirement

Cursor must return:

```text
Cursor Output:
1. Pre-work git status summary
2. Touched file list
3. File-by-file change summary
4. SQL files changed
5. Backend/API files changed
6. Flutter files changed
7. Test files changed
8. Evidence notes
9. Blockers encountered
10. Tests run, if authorized
11. Tests not run, with reason
12. Post-work git status summary
13. Diff summary
14. Excluded scope confirmation
```

Cursor must not claim implementation closeout without an evidence packet and review packet.

## 16. Excluded Scope Confirmation

Cursor must explicitly confirm:

```text
Excluded Scope Confirmation:
- Production release: not performed
- Credential activation: not performed
- Webhook activation: not performed
- Payment/reconciliation mutation outside scope: not performed
- Runtime implementation outside ticket: not performed
- Corrective action execution outside scope: not performed
- Evidence rewrite: not performed
- Encoding normalization: not performed
- Formatter execution: not performed
- Korean-heavy document rewrite: not performed
- Files outside allowed list: not modified
```

## 17. Cursor Prompt Full Template

```text
You are Cursor applying a bounded POS Gateway Runtime Flow implementation ticket.

Project root:
Repository:
Current branch:
Implementation Ticket ID:
Implementation Module Name:
Implementation Class:
Authorization Gate Source:
Code Handoff Checklist:
Patch Source:

Pre-work:
- Confirm project root.
- Confirm current branch.
- Run git status.
- List dirty and untracked files.
- Stop if unrelated dirty files exist.

Allowed files:
1.
2.
3.

Disallowed files:
1.
2.
3.

Apply only the listed changes:
- SQL:
- Backend/API:
- Flutter:
- Tests:
- Evidence notes:

Hard rules:
- Preserve UTF-8.
- Do not normalize encoding.
- Do not run formatters.
- Do not rewrite Korean-heavy documents.
- Do not rewrite full documents for style.
- Do not modify files outside allowed list.
- Do not activate credentials or webhooks.
- Do not modify production settings.
- Do not mutate payment, cancellation, refund, settlement, or reconciliation logic unless explicitly authorized.
- Do not delete or rewrite evidence.
- Do not run tests unless explicitly authorized.
- Do not perform broad refactors.
- Do not use PowerShell Set-Content.
- Do not change line endings globally.

Return:
1. Pre-work git status summary
2. Touched file list
3. File-by-file change summary
4. Diff summary
5. Tests run or not run
6. Evidence notes
7. Blockers
8. Excluded scope confirmation
9. Post-work git status summary
```

## 18. Cursor Prompt Completeness Checklist

| Check | Required Result | Status |
|---|---|---|
| Project root included | Present | Pending |
| Current branch included | Present | Pending |
| Implementation ticket ID included | Present | Pending |
| Implementation class included | Present | Pending |
| Authorization source included | Present | Pending |
| Code handoff checklist included | Present | Pending |
| Patch source included | Present | Pending |
| Pre-work git status required | Present | Pending |
| Allowed file list included | Present | Pending |
| Disallowed file list included | Present | Pending |
| SQL scope included or marked none | Present | Pending |
| Backend/API scope included or marked none | Present | Pending |
| Flutter scope included or marked none | Present | Pending |
| Test scope included or marked none | Present | Pending |
| Korean/encoding safety included | Present | Pending |
| Evidence output required | Present | Pending |
| Excluded scope confirmation required | Present | Pending |
| Post-work git status required | Present | Pending |

## 19. Failure Handling

| Failure | Required Handling |
|---|---|
| Missing project root | Stop |
| Missing current branch | Stop |
| Missing allowed file list | Stop |
| Missing disallowed file list | Stop |
| Dirty unrelated files detected | Stop and report |
| Required change needs unlisted file | Stop and report blocker |
| Prompt requests formatter | Refuse formatter step |
| Prompt requests encoding normalization | Refuse normalization |
| Prompt requests Korean-heavy rewrite | Refuse rewrite |
| Prompt requests broad refactor | Refuse refactor |
| Prompt requests credential activation | Refuse and route to Security Owner |
| Prompt requests webhook activation | Refuse and route to Security Owner |
| Prompt requests production change | Refuse and route to Governance Owner |
| Prompt requests payment/reconciliation mutation without approval | Refuse and route to Financial Audit Owner |
| Prompt requests evidence rewrite | Refuse and preserve evidence |
| Prompt requests test execution without approval | Do not run tests; return test-not-run reason |

## 20. Non-Authorization Confirmation

This template confirms that the following remain prohibited unless a later approved gate explicitly authorizes them within bounded scope:

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

## 21. Downstream Prompt Safety Block

Every downstream Cursor prompt must include:

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

## 22. Recommended Next Document

Recommended next file:

`002290_Template_POS_Gateway_Runtime_Flow_Bundle_Implementation_Review_Packet_Template.md`

Alternative next files:

- `02290_Template_POS_Gateway_Runtime_Flow_Bundle_Change_Evidence_Packet_Template.md`
- `02290_Checklist_POS_Gateway_Runtime_Flow_Bundle_Cursor_File_Application_Prompt_Readiness_Checklist.md`
- `02290_Template_POS_Gateway_Runtime_Flow_Bundle_Test_Execution_Evidence_Template.md`

## 23. Final Template Statement

This template defines a controlled Cursor file application prompt for bounded POS Gateway Runtime Flow implementation tickets.

```text
Cursor File Application Prompt Template: Created
Cursor Role: Apply bounded listed file changes only
Runtime Implementation: Prohibited unless later approved
Corrective Action Execution: Prohibited unless later approved
Production Release: Prohibited unless later approved
Implementation Hold: Active unless explicitly lifted
Evidence Preservation: Required
UTF-8 Preservation: Required
Encoding Normalization: Prohibited
Formatter Execution: Prohibited
Cursor Korean-Heavy Rewrite: Prohibited
Broad Refactor: Prohibited
```
