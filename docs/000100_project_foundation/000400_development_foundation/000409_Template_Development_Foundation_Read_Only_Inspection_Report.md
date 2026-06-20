# 000409_Template_Development_Foundation_Read_Only_Inspection_Report.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | Read-Only Codebase Inspection Report Template |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Runbook | 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md |
| Status | Draft |
| Owner | Architecture / Engineering / QA |
| AI Solo Change | Report drafting allowed; code modification and restricted approval prohibited |

---

## 2. Purpose

This template records the result of a read-only codebase inspection.

It is used before Claude Code, Cursor, or a human developer modifies implementation files.

The report must prove that the project inspected the existing codebase safely and identified the actual implementation surface before code handoff.

The report must not contain code changes, secret values, production credentials, or destructive command output.

---

## 3. Inspection Rule

The inspection report is valid only when the inspection was read-only.

Allowed during inspection:

```text
list files
search symbols
inspect routes
inspect services
inspect schemas
inspect tests
inspect migrations
summarize findings
```

Prohibited during inspection:

```text
edit source code
run auto-fixers
change migrations
change secrets
run destructive commands
commit changes
deploy
```

---

## 4. Report Template

Use the structure below for each actual inspection report.

---

# <Exact_Report_Filename_With_Extension.md>

## 1. Inspection Summary

| Field | Value |
|---|---|
| Inspection ID | INSPECT-YYYYMMDD-001 |
| Task Name | TBD |
| Related Flow Bundle | TBD |
| Related Overview Document | TBD |
| Related Logic Document | TBD |
| Related Module Document | TBD |
| Inspection Date | YYYY-MM-DD |
| Inspector | Human / Claude Code / Cursor / ChatGPT-assisted |
| Inspection Mode | Read-only |
| Code Modified? | No |
| Status | Draft / Review / Accepted / Blocked |

---

## 2. Repository State

| Field | Value |
|---|---|
| Repository Path | TBD |
| Branch | TBD |
| Git Status Summary | TBD |
| Existing Uncommitted Changes | None / Listed below |
| Recent Commit Notes | TBD |
| Package / Runtime Stack | TBD |
| Local Environment Notes | TBD |

### 2.1 Existing Uncommitted Changes

| File | Change Type | Owner / Note |
|---|---|---|
| TBD | TBD | TBD |

If uncommitted changes exist, do not overwrite, clean, stage, or commit them during inspection.

---

## 3. Inspection Scope

### 3.1 Included Scope

- TBD
- TBD

### 3.2 Excluded Scope

- TBD
- TBD

### 3.3 Reason For Inspection

```text
TBD
```

Examples:

```text
Source files for the POS Gateway approval flow are not yet mapped.
The Logic Document is ready, but Module Document cannot be completed without read-only codebase inspection.
The task may touch payment, audit, or retry modules, so file-level scope must be discovered before code handoff.
```

---

## 4. Related Documentation

| Document Type | Filename | Status |
|---|---|---|
| Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md | Available |
| Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md | Available |
| Traceability Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md | Available |
| Handoff Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md | Available |
| Inspection Runbook | 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md | Available |
| Runtime Flow Bundle | TBD | TBD |
| Overview Document | TBD | TBD |
| Logic Document | TBD | TBD |
| Module Document | TBD | TBD |
| Test Coverage Map | TBD | TBD |
| Evidence Packet | TBD | TBD |

---

## 5. Commands Or Inspection Methods Used

Record only safe read-only commands or IDE navigation methods.

| Method / Command | Purpose | Result Summary |
|---|---|---|
| `git status --short` | Check local changes | TBD |
| `git branch --show-current` | Check active branch | TBD |
| `rg "<term>"` | Search candidate files | TBD |
| `find . -maxdepth <n> -type f` | Locate files | TBD |
| IDE symbol search | Locate functions/classes | TBD |

Do not include secret values, tokens, credentials, or private runtime payloads.

---

## 6. Candidate Modules

| Module | Candidate Path | Reason | Related Flow Step | Risk |
|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD |

Example:

| Module | Candidate Path | Reason | Related Flow Step | Risk |
|---|---|---|---|---|
| pos_gateway.approval | `src/modules/pos_gateway/` | Approval and provider adapter code appears here | Payment approval request | Payment/retry risk |
| audit_ledger | `src/modules/audit/` | Audit append and evidence logic appears here | Audit evidence append | No-AI-Solo zone |

---

## 7. Candidate Source Files

| File | Observed Role | Related Logic Rule | Restricted Zone? | Notes |
|---|---|---|---:|---|
| TBD | TBD | TBD | TBD | TBD |

Restricted files must be clearly flagged before code handoff.

---

## 8. Candidate APIs / Handlers

| API / Handler | Direction | Caller | Callee | Related Flow Step | Notes |
|---|---|---|---|---|---|
| TBD | Inbound / Outbound / Internal | TBD | TBD | TBD | TBD |

Examples:

| API / Handler | Direction | Caller | Callee | Related Flow Step | Notes |
|---|---|---|---|---|---|
| payment approval route | Inbound | Catch&Order Runtime | POS Gateway | Approval start | Requires idempotency |
| provider webhook route | Inbound | PG/VAN Provider | Webhook Boundary | Webhook verification | Requires signature validation |

---

## 9. Candidate Data Models / Tables / Migrations

| Table / Model / Migration | Purpose | Related Logic Rule | Migration Risk? | Restricted Zone? |
|---|---|---|---:|---:|
| TBD | TBD | TBD | TBD | TBD |

Examples:

| Table / Model / Migration | Purpose | Related Logic Rule | Migration Risk? | Restricted Zone? |
|---|---|---|---:|---:|
| payment_attempts | Payment attempt state and idempotency | LOGIC-R002 | Conditional | Yes |
| provider_events | Raw/normalized provider events | LOGIC-R005 | Conditional | Yes |
| audit_events | Immutable audit evidence | LOGIC-R004 | Yes | Yes |

---

## 10. Candidate Queues / Jobs / Events

| Item | Type | Producer | Consumer | Retry/DLQ? | Related Flow Step |
|---|---|---|---|---|---|
| TBD | Queue / Job / Event | TBD | TBD | TBD | TBD |

Examples:

| Item | Type | Producer | Consumer | Retry/DLQ? | Related Flow Step |
|---|---|---|---|---|---|
| payment.approval.timeout | Event | POS Gateway | Recovery Queue | DLQ required | Timeout handling |
| provider.webhook.received | Queue | Webhook Handler | Normalizer Worker | Retry allowed after verification | Webhook normalization |

---

## 11. Candidate Tests

| Test File | Test Type | Existing Coverage | Missing Coverage | Priority |
|---|---|---|---|---|
| TBD | Unit / Integration / Contract / Fault / Security / Audit | TBD | TBD | TBD |

Test types to check:

```text
unit
integration
contract
fault injection
security
audit
migration
regression
```

---

## 12. Restricted Zone Findings

| File / Area | Restricted Zone | AI Solo Allowed? | Required Approval | Evidence Required |
|---|---|---:|---|---|
| TBD | TBD | No | TBD | TBD |

Restricted zones include:

```text
payment approval
cancel / refund / reversal
settlement / reconciliation
audit ledger
webhook signature / security
secret / token / credential
DB migration / schema
production release / deployment
```

---

## 13. Documentation Gaps

| Missing / Incomplete Item | Impact | Required Next Action | Blocking? |
|---|---|---|---:|
| TBD | TBD | TBD | TBD |

Examples:

| Missing / Incomplete Item | Impact | Required Next Action | Blocking? |
|---|---|---|---:|
| Module Document missing source file map | Cannot hand off code safely | Create/update 03_module document | Yes |
| Test Coverage Map missing timeout scenarios | Retry/DLQ behavior unproven | Update test map | Yes |
| Evidence packet target undefined | Merge/release cannot be proven | Create evidence packet | Yes |

---

## 14. Risk Notes

| Risk ID | Risk | Severity | Mitigation |
|---|---|---|---|
| RISK-001 | TBD | Low / Medium / High / Critical | TBD |

Risk categories:

```text
duplicate payment
unknown external state
audit evidence gap
settlement mismatch
security replay
secret exposure
migration failure
test gap
ambiguous ownership
```

---

## 15. Recommended Next Step

Select one.

| Recommendation | Selected? | Reason |
|---|---:|---|
| Documentation-only update | TBD | TBD |
| Create/update Overview Document | TBD | TBD |
| Create/update Logic Document | TBD | TBD |
| Create/update Module Document | TBD | TBD |
| Create/update Test Coverage Map | TBD | TBD |
| Create/update Evidence Packet | TBD | TBD |
| Human approval required | TBD | TBD |
| Ready for Claude Code handoff | TBD | TBD |
| Ready for Cursor limited assist | TBD | TBD |
| Blocked | TBD | TBD |

---

## 16. Handoff Eligibility Decision

| Field | Value |
|---|---|
| Eligible For Claude Code? | Yes / No / Conditional |
| Eligible For Cursor Assist? | Yes / No / Conditional |
| Human-Only Required? | Yes / No |
| Reason | TBD |
| Required Before Implementation | TBD |
| Evidence Packet Target | TBD |

---

## 17. Inspector Certification

The inspector confirms:

- [ ] Inspection was read-only.
- [ ] No source files were modified.
- [ ] No migrations were changed.
- [ ] No secrets were viewed beyond safe reference names.
- [ ] No credentials or sensitive payloads are copied into this report.
- [ ] Restricted zones are identified.
- [ ] Missing documentation is listed.
- [ ] Recommended next step is explicit.

---

## 18. Summary

This inspection report converts codebase discovery into safe implementation planning.

It must feed the development chain:

```text
Overview → Logic → Module → File → Test → Evidence
```

Code handoff must not proceed until the report's findings are reflected in the Module Document, Test Coverage Map, Evidence Packet, and No-AI-Solo approval gate where required.
