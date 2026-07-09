# 701250_Register_Flow_Bundle_Implementation_Exception_And_Waiver_Log.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 701250 |
| Document Type | Register |
| Document Name | Flow Bundle Implementation Exception And Waiver Log |
| Filename | 701250_Register_Flow_Bundle_Implementation_Exception_And_Waiver_Log.md |
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 700900 Runtime Flow Bundle Registry |
| Status | Draft |
| Owner | System Architecture / Runtime Governance |
| Reviewers | Security, Payment, Settlement, Audit Ledger, QA, Operations |
| Related Index | 700900_Index_Runtime_Flow_Bundle_Registry.md |

---

## 2. Purpose

This register records all implementation exceptions, deferred controls, temporary waivers, blocked modifications, and manual approvals that occur during Flow Bundle-based development.

CatchMenu / Catch & Order is not treated as a simple order application. It touches POS gateway behavior, PG/VAN integration, approval/cancel/refund flows, settlement, audit ledger, reconciliation, secret handling, migration, and operational deployment. Therefore, exceptions must not remain inside chat logs, IDE comments, or informal developer memory.

The purpose of this document is to ensure that every deviation from the approved Flow Bundle path is visible, reviewable, reversible, and connected to evidence.

---

## 3. Scope

This register applies to all Runtime Flow Bundle implementation work under the 700900 band, including but not limited to:

- POS Gateway approval to audit ledger and reconciliation
- Cancel, refund, recovery, and audit flow
- Timeout, retry, DLQ, and replay flow
- Store offline local ledger and resync flow
- Webhook inbound verification and event normalization
- Settlement, dispute, and evidence export flow
- Flow-to-MD dependency mapping
- Flow-to-module implementation mapping
- Flow-to-test coverage mapping
- Claude Code handoff prompt execution
- Cursor IDE assist usage
- Code review and diff control
- Implementation evidence packet submission

This register must be used whenever implementation does not exactly follow the approved Flow Step → Module → File → Test → Evidence sequence.

---

## 4. Core Principle

A waiver is not permission to ignore risk.

A waiver is a controlled record that says:

1. what was not completed,
2. why it was not completed,
3. what risk remains,
4. who approved the risk,
5. when it must be resolved,
6. what evidence proves the decision.

For payment, settlement, audit, security, migration, secret, and deployment boundaries, waiver authority is restricted or prohibited.

---

## 5. Non-Waivable Domains

The following domains must not be changed, bypassed, deferred, or auto-approved by AI tools without human architecture/security/payment review.

| Domain | Waiver Allowed | Rule |
|---|---:|---|
| Payment approval finality | No | Approval state must not be weakened or guessed. |
| Duplicate payment prevention | No | Idempotency and replay control must remain mandatory. |
| Cancel/refund financial state | No | Refund/cancel ledger transitions require explicit verification. |
| Settlement calculation | No | Settlement amount logic must not be modified by AI alone. |
| Audit ledger immutability | No | Audit records must not be deleted, rewritten, or silently corrected. |
| Secret handling | No | Secrets must not be moved into code, logs, prompts, or fixtures. |
| DB migration affecting financial data | No | Migration requires review, rollback, and evidence. |
| Production deployment | No | AI-generated deployment changes require human gate approval. |
| Webhook signature verification | No | External inbound event trust boundary must not be relaxed. |
| Legal/evidence export | No | Evidence export rules must not be bypassed. |

If any implementation proposal touches a non-waivable domain, it must be blocked and escalated.

---

## 6. Waivable Domains With Conditions

The following domains may be temporarily waived only when the risk is low, the impact is local, and a follow-up ticket is created.

| Domain | Waiver Condition |
|---|---|
| Non-financial UI label mismatch | Allowed only if no customer-facing legal/payment wording is affected. |
| Internal developer tooling | Allowed if it does not affect build, deploy, secrets, or migration. |
| Test data naming cleanup | Allowed if no fixture used for payment/security audit is altered. |
| Documentation cross-link cleanup | Allowed if no required dependency is removed. |
| Non-critical logging format | Allowed if audit, security, and payment logs are unaffected. |
| Refactor without behavior change | Allowed only with diff review and test evidence. |
| Temporary test skip | Allowed only when documented with replacement coverage and expiry date. |

---

## 7. Exception Categories

| Code | Category | Description |
|---|---|---|
| EXC-FLOW | Flow Step Exception | Approved Flow Step sequence was not followed. |
| EXC-MD | MD Dependency Exception | Required source MD was missing, stale, or conflicting. |
| EXC-MOD | Module Boundary Exception | Implementation touched a module outside approved scope. |
| EXC-FILE | File Scope Exception | Files changed outside the approved file list. |
| EXC-TEST | Test Coverage Exception | Required tests were missing, skipped, or failed. |
| EXC-EVD | Evidence Exception | Evidence packet was incomplete or missing. |
| EXC-AI | AI Tool Boundary Exception | Claude/Cursor exceeded allowed role or touched forbidden scope. |
| EXC-SEC | Security Exception | Security boundary, secret, RBAC, signature, or trust rule was affected. |
| EXC-PAY | Payment Exception | Approval/cancel/refund/idempotency/payment finality was affected. |
| EXC-AUD | Audit Ledger Exception | Ledger, reconciliation, export, or immutability rule was affected. |
| EXC-DB | Database/Migration Exception | Schema, migration, seed, or data correction risk exists. |
| EXC-OPS | Deployment/Operations Exception | Runtime config, deploy, rollback, or operational runbook was affected. |

---

## 8. Severity Classification

| Severity | Meaning | Required Action |
|---|---|---|
| S0 | Informational deviation with no runtime impact | Record only, reviewer acknowledgment required. |
| S1 | Low-risk local deviation | Record, owner approval, follow-up date. |
| S2 | Moderate implementation risk | Architecture review and test evidence required. |
| S3 | High-risk financial/security/runtime risk | Block merge until review and remediation. |
| S4 | Critical payment/audit/security breach risk | Stop work, escalate, incident-style review required. |

Any exception in EXC-PAY, EXC-AUD, EXC-SEC, EXC-DB, or EXC-OPS must default to S3 or S4 unless explicitly downgraded by human review.

---

## 9. Required Register Fields

Every exception or waiver entry must include the following fields.

| Field | Required | Description |
|---|---:|---|
| Register ID | Yes | Unique ID for the exception entry. |
| Date | Yes | Date recorded. |
| Flow Bundle ID | Yes | Related 641xx or 642xx document. |
| Flow Step | Yes | Exact step affected. |
| Category | Yes | Exception category code. |
| Severity | Yes | S0-S4. |
| Description | Yes | What happened. |
| Expected Control | Yes | What should have happened. |
| Actual Deviation | Yes | What deviated. |
| Impacted Module | Yes | Runtime module affected. |
| Impacted File(s) | Yes | File paths changed or proposed. |
| Impacted Test(s) | Yes | Test cases affected or missing. |
| Evidence Link | Yes | Evidence packet, log, diff, screenshot, or test output. |
| AI Tool Involved | Yes | Claude Code, Cursor, manual, or mixed. |
| Waiver Requested | Yes | Yes/No. |
| Waiver Decision | Yes | Approved/Rejected/Blocked/Pending. |
| Approver | Conditional | Required for any waiver. |
| Expiry Date | Conditional | Required for temporary waiver. |
| Remediation Plan | Yes | How to close the exception. |
| Closure Evidence | Conditional | Required when closed. |
| Status | Yes | Open / Blocked / Approved Temporary / Remediated / Closed. |

---

## 10. Register Table Template

| Register ID | Date | Flow Bundle ID | Flow Step | Category | Severity | Description | Impacted Module | Impacted File(s) | Waiver Decision | Approver | Expiry Date | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| FBE-YYYYMMDD-001 | YYYY-MM-DD | 701000 | FS-01 | EXC-TEST | S2 | Required integration test missing | pos_gateway_adapter | TBD | Pending | TBD | YYYY-MM-DD | Open |

---

## 11. Detailed Entry Template

```markdown
## FBE-YYYYMMDD-001

| Field | Value |
|---|---|
| Register ID | FBE-YYYYMMDD-001 |
| Date | YYYY-MM-DD |
| Flow Bundle ID | 701000_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md |
| Flow Step | FS-XX |
| Category | EXC-TEST |
| Severity | S2 |
| AI Tool Involved | Claude Code / Cursor / Manual / Mixed |
| Waiver Requested | Yes / No |
| Waiver Decision | Approved / Rejected / Blocked / Pending |
| Approver | Name / Role |
| Expiry Date | YYYY-MM-DD |
| Status | Open / Blocked / Approved Temporary / Remediated / Closed |

### Description

Describe the exception.

### Expected Control

Describe the approved control from the Flow Bundle.

### Actual Deviation

Describe what actually happened.

### Impacted Module(s)

- module_name

### Impacted File(s)

- path/to/file

### Impacted Test(s)

- test_name

### Evidence

- Diff:
- Test output:
- Review note:
- Evidence packet:

### Risk Assessment

Describe business, financial, security, audit, and operational risk.

### Remediation Plan

Describe how this will be fixed.

### Closure Evidence

Describe evidence required to close this entry.
```

---

## 12. AI Tool Boundary Rules

### 12.1 Claude Code

Claude Code may be used as a Flow Bundle implementation agent only when:

- 700900 index is referenced,
- the relevant 641xx Flow document is referenced,
- 701100 dependency graph is referenced,
- 701110 module map is referenced,
- 701120 test coverage map is referenced,
- 701200 readiness gate is passed,
- 701210 handoff prompt is used,
- non-waivable domains are explicitly excluded or human-reviewed.

Claude Code output must be checked against this exception register before merge.

### 12.2 Cursor

Cursor may be used as an IDE assistant only when:

- the target file list is bounded,
- the requested change is local,
- payment/settlement/audit/security/secret/migration/deploy boundaries are not modified,
- the diff is reviewed manually,
- tests and evidence are attached.

Cursor must not be treated as the owner of the Flow Bundle implementation.

---

## 13. Mandatory Exception Triggers

An exception entry must be created when any of the following occurs:

1. AI modifies files outside approved scope.
2. AI proposes DB migration affecting payment or audit data.
3. AI changes idempotency, retry, DLQ, or replay behavior.
4. AI weakens webhook verification or signature validation.
5. AI changes settlement calculation or reconciliation logic.
6. AI removes, rewrites, or suppresses audit ledger events.
7. AI introduces secrets into code, logs, prompts, fixtures, or docs.
8. Required tests are skipped or replaced with manual assertion only.
9. Evidence packet is missing.
10. Implementation references a stale or missing MD dependency.
11. Runtime module ownership is unclear.
12. Production deploy, rollback, or environment config is changed.
13. Manual hotfix is applied outside Flow Bundle control.
14. A reviewer cannot determine whether the change is safe.

---

## 14. Waiver Approval Matrix

| Severity | Waiver Authority | Merge Allowed Before Closure |
|---|---|---:|
| S0 | Flow owner | Yes |
| S1 | Flow owner + QA | Conditional |
| S2 | Architecture + QA | Conditional with expiry |
| S3 | Architecture + Security/Payment/Audit owner | No, unless emergency reviewed |
| S4 | Incident-level approval | No |

Payment, settlement, audit ledger, security, secret, migration, and production deployment exceptions require domain owner review even if severity appears low.

---

## 15. Status Lifecycle

```text
Detected
  ↓
Recorded
  ↓
Classified
  ↓
Reviewed
  ↓
Approved Temporary / Rejected / Blocked
  ↓
Remediated
  ↓
Evidence Attached
  ↓
Closed
```

No exception may move to Closed without closure evidence.

---

## 16. Closure Criteria

An exception can be closed only when:

- the root cause is documented,
- the affected Flow Step is identified,
- the impacted modules and files are listed,
- tests have been executed or explicitly replaced with approved equivalent evidence,
- the evidence packet is attached,
- the approver has signed off,
- any temporary waiver has expired or been resolved,
- the relevant Flow Bundle document has been updated if the exception revealed a real documentation gap.

---

## 17. Cross-References

| Document | Relationship |
|---|---|
| 700900_Index_Runtime_Flow_Bundle_Registry.md | Parent registry index |
| 701000_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval/reconciliation Flow Bundle |
| 701010_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel/refund Flow Bundle |
| 701020_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout/retry/DLQ Flow Bundle |
| 701030_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Offline local ledger Flow Bundle |
| 701040_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook verification Flow Bundle |
| 701050_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement/dispute/evidence Flow Bundle |
| 701100_Matrix_Flow_To_MD_Dependency_Graph.md | MD dependency map |
| 701110_Matrix_Flow_To_Module_Implementation_Map.md | Module implementation map |
| 701120_Matrix_Flow_To_Test_Coverage_Map.md | Test coverage map |
| 701200_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md | Pre-code readiness gate |
| 701210_Template_Flow_Bundle_Claude_Code_Handoff_Prompt.md | Claude Code handoff template |
| 701220_Template_Flow_Bundle_Cursor_IDE_Assist_Prompt.md | Cursor IDE assist template |
| 701230_Runbook_Flow_Bundle_Code_Review_And_Diff_Control.md | Diff control and review runbook |
| 701240_Evidence_Flow_Bundle_Implementation_Review_Packet.md (file not yet created — pending Evidence packet gate) | Evidence packet template |

---

## 18. Governance Notes

This register is part of the 700900 Runtime Flow Registry band. It is not an operational SOP and does not belong in the 00010-49999 Operation SOP range.

It is also not a replacement for 50000+ System SOPs. If an exception reveals a recurring system governance issue, the issue must be promoted to a System SOP or linked to an existing one.

The register exists to prevent a hidden implementation drift between MD documentation, AI coding output, runtime module boundaries, tests, and audit evidence.

---

## 19. Final Rule

No Flow Bundle implementation is considered complete if it has unresolved exceptions without approved closure evidence.
