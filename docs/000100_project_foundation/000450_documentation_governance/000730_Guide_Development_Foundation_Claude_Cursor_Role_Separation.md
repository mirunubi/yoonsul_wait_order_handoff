# 000730_Guide_Development_Foundation_Claude_Cursor_Role_Separation.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Guide |
| Document Role | Claude Code And Cursor Role Separation Guide |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Runbook | 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md |
| Related Report Template | 000720_Template_Development_Foundation_Read_Only_Inspection_Report.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering |
| AI Solo Change | Role guidance may be drafted by AI; restricted implementation approval may not be delegated to AI |

---

## 2. Purpose

This guide defines the proper separation of responsibilities between Claude Code, Cursor, ChatGPT, and human reviewers during CatchMenu / Catch&Order development.

The project must not treat a single Markdown file as a complete implementation unit.

The required implementation chain is:

```text
Overview → Logic → Module → File → Test → Evidence
```

The required Flow Bundle chain is:

```text
Flow Step → Module → File → Test → Evidence
```

Claude Code may be used as a Flow Bundle implementation agent after the approved handoff packet is complete.  
Cursor may be used as an IDE/file-level assist tool after scope is narrowed.

Neither tool may independently modify payment, settlement, audit, security, DB migration, secret, or production release areas.

---

## 3. Tool Role Summary

| Tool / Actor | Primary Role | Allowed Scope | Prohibited Scope |
|---|---|---|---|
| ChatGPT | Documentation, planning, mapping, prompt drafting, review support | MD drafting, architecture reasoning, checklist, handoff packet preparation | Approving restricted implementation alone |
| Claude Code | Flow Bundle implementation agent | Approved multi-file implementation after full context packet | Starting from one MD file, guessing missing context, restricted solo changes |
| Cursor | IDE assist and narrow file-level support | Symbol navigation, local diff, small scoped edits, review support | Owning whole Flow Bundle, broad autonomous refactor, restricted solo changes |
| Human Owner | Final authority and restricted zone approval | Approval, merge/release decision, restricted review | Delegating restricted approval fully to AI |

---

## 4. Why Separation Is Required

CatchMenu / Catch&Order has financial-grade runtime characteristics:

- POS integration
- PG/VAN boundary
- approval/cancel/refund flows
- settlement and reconciliation
- audit ledger
- webhook verification
- retry/DLQ/replay
- DB migration
- secret and credential handling
- production release

A single MD file cannot represent all implementation consequences.

Therefore, code work must be managed through Flow Bundle and development foundation documents, not isolated policy files.

---

## 5. Claude Code Role

### 5.1 Proper Use

Claude Code is appropriate when:

| Condition | Required |
|---|---:|
| Flow Bundle is identified | Yes |
| Overview document exists | Yes |
| Logic document exists | Yes |
| Module document exists or read-only inspection result exists | Yes |
| Test Coverage Map exists | Yes |
| Evidence target exists | Yes |
| No-AI-Solo zones are classified | Yes |
| Human approval exists when restricted zone is touched | Required |

Claude Code may:

- read multiple related documents
- inspect the codebase in read-only mode
- implement approved Flow Bundle changes
- update tests
- produce change summaries
- produce evidence packet notes
- identify unresolved questions
- refuse unsafe scope expansion

### 5.2 Improper Use

Claude Code must not be asked to:

- “Read this one MD and implement it.”
- “Fix all related files automatically.”
- “Refactor broadly while you are there.”
- “Modify payment/settlement/audit/security/migration/secret/release areas without approval.”
- “Decide whether this financial behavior is acceptable.”
- “Deploy or release automatically.”
- “Clean up unrelated files.”
- “Commit changes without review.”

---

## 6. Cursor Role

### 6.1 Proper Use

Cursor is appropriate when:

| Condition | Required |
|---|---:|
| Exact file or narrow module is known | Yes |
| Logic and module context are available | Yes |
| Restricted zone is not touched or approval exists | Yes |
| Expected diff is small and reviewable | Yes |
| Tests are identified | Yes |

Cursor may:

- help navigate files
- show symbol references
- suggest small local edits
- help write or update tests
- review a diff
- explain local code behavior
- verify that a file matches a Module Document

### 6.2 Improper Use

Cursor must not be used as:

- the owner of full Flow Bundle implementation
- a replacement for architecture mapping
- a broad refactor agent
- a financial logic decision-maker
- a DB migration generator without review
- a security/secret editor without approval
- a production release agent

Cursor should be treated as a precise IDE assistant, not as the project architect.

---

## 7. Human Owner Role

Human review is mandatory for:

| Area | Human Approval Required |
|---|---:|
| Payment approval/cancel/refund/reversal | Yes |
| Settlement/reconciliation/dispute | Yes |
| Audit ledger/tamper-evidence/legal hold | Yes |
| Security/auth/signature/secret/credential | Yes |
| DB migration/schema/data backfill | Yes |
| Production release/deployment/rollback | Yes |
| Financial evidence export | Yes |
| Consumer protection or legal compliance behavior | Yes |

The human owner must decide:

- whether the Flow Bundle is complete enough for implementation
- whether restricted areas are allowed to change
- whether tests and evidence are sufficient
- whether merge/release may proceed

---

## 8. Standard Workflow

```text
1. Write or update Overview
2. Write or update Logic
3. Perform read-only codebase inspection if source surface is unknown
4. Write or update Module document
5. Update traceability matrix
6. Update test coverage map
7. Prepare evidence packet target
8. Check No-AI-Solo zone
9. Give Claude Code Flow Bundle handoff if appropriate
10. Use Cursor only for narrowed IDE/file assistance
11. Review diff against Module map
12. Run/record tests
13. Complete evidence packet
14. Human approval for restricted zones
15. Merge/release gate
```

---

## 9. Claude Code Handoff Template

Use this structure when assigning Claude Code.

```text
You are implementing an approved Flow Bundle.

Do not treat a single MD file as the implementation unit.
Use the chain:
Overview → Logic → Module → File → Test → Evidence.

Read these documents:
- <Overview document>
- <Logic document>
- <Module document>
- <Traceability matrix>
- <Runtime Flow Bundle>
- <Flow-to-MD Dependency Graph>
- <Flow-to-Module Implementation Map>
- <Flow-to-Test Coverage Map>
- <No-AI-Solo Zone matrix>
- <Code review and diff control runbook>

Allowed scope:
- <allowed modules/files>

Prohibited scope:
- any unlisted file
- payment/settlement/audit/security/DB migration/secret/release areas unless specifically approved
- broad refactor
- production deployment
- secret changes
- migration execution

Required output:
- changed_files
- unchanged_restricted_files
- tests_added_or_updated
- test_results
- evidence_packet_notes
- restricted_area_touch_report
- unresolved_questions
```

---

## 10. Cursor Assist Template

Use this structure when assigning Cursor.

```text
Assist only with the approved narrow file-level task.

Do not expand scope.
Do not infer missing Flow Bundle context.
Do not modify restricted areas.
Use the approved Logic and Module documents as the source of truth.

Allowed file(s):
- <file>

Task:
- <specific local edit or inspection>

Required output:
- diff summary
- tests affected
- risk note
- whether any restricted area was touched
```

---

## 11. Read-Only Inspection Prompt

Before code handoff, when file/module locations are unknown:

```text
Perform read-only inspection only.

Do not modify files.
Do not run formatters.
Do not run migrations.
Do not stage or commit.
Do not deploy.

Find:
- candidate modules
- candidate source files
- candidate APIs
- candidate tables/migrations
- candidate queues/jobs/events
- existing tests
- restricted zone files
- missing documentation

Return the result using the read-only inspection report template.
```

---

## 12. Role Decision Matrix

| Task Type | ChatGPT | Claude Code | Cursor | Human |
|---|---:|---:|---:|---:|
| Draft policy/SOP/checklist | Primary | Optional | No | Review |
| Build Flow Bundle map | Primary | Assist | No | Review |
| Read-only codebase inspection | Assist | Primary/Assist | Assist | Review |
| Implement full Flow Bundle | No | Primary after approval | Assist only | Review |
| Narrow file edit | No | Optional | Primary after scope | Review |
| Write tests | Assist | Primary | Assist | Review |
| Review diff | Assist | Assist | Assist | Primary |
| Payment logic change | No approval | Only after approval | Assist only after approval | Required |
| Settlement/audit/security change | No approval | Only after approval | Assist only after approval | Required |
| DB migration | No approval | Only after approval | Assist only after approval | Required |
| Production release | No | No solo | No solo | Required |

---

## 13. Stop Conditions

Stop AI-assisted implementation when:

| Stop Condition | Required Action |
|---|---|
| AI references only one MD file for runtime work | Rebuild Flow Bundle context |
| Source files are unknown | Run read-only inspection |
| Logic rules are ambiguous | Create/update Logic document |
| Module map is missing | Create/update Module document |
| Test map is missing | Create/update Test Coverage Map |
| Restricted zone appears | Require human approval |
| AI proposes broad refactor | Reject and narrow scope |
| AI touches unapproved file | Stop and review diff |
| AI modifies secret/migration/release config | Stop and escalate |
| Test/evidence cannot be produced | Block merge/release |

---

## 14. Required Evidence From AI-Assisted Work

Every AI-assisted implementation must produce:

| Evidence | Required |
|---|---:|
| Handoff prompt used | Yes |
| Documents read | Yes |
| Files changed | Yes |
| Files intentionally not changed | Yes |
| Restricted zone report | Yes |
| Test files added/updated | Conditional |
| Test results | Yes when tests are run |
| Known gaps | Yes |
| Human review record | Yes for restricted work |
| Release gate record | Yes before release |

---

## 15. Summary

Claude Code and Cursor should not compete for the same role.

Claude Code is the Flow Bundle implementation agent after the full handoff packet is ready.  
Cursor is the IDE/file-level assist tool after the scope is narrowed.

Both are subordinate to the project chain:

```text
Overview → Logic → Module → File → Test → Evidence
```

Both are blocked from solo-changing restricted financial, audit, security, DB migration, secret, and production release areas.
