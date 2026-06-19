# 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Runbook |
| Document Role | Codebase Read-Only Inspection Runbook |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Status | Draft |
| Owner | Architecture / Engineering / QA |
| AI Solo Change | Read-only inspection allowed; code modification prohibited without handoff approval |

---

## 2. Purpose

This runbook defines the safe read-only codebase inspection procedure before any Claude Code, Cursor, or human implementation task begins.

The goal is to discover the actual implementation surface without changing code.

The inspection must identify:

1. Candidate runtime modules.
2. Candidate source files.
3. Candidate API endpoints.
4. Candidate DB tables and migrations.
5. Candidate queues, jobs, and event handlers.
6. Existing tests.
7. Restricted files or No-AI-Solo zones.
8. Missing module documentation that must be created before code handoff.

---

## 3. Core Rule

Read-only inspection is allowed before implementation.

Code modification is not allowed during this stage.

```text
Allowed:
- list files
- search symbols
- inspect imports
- inspect routes
- inspect schemas
- inspect tests
- inspect migrations
- summarize findings
- update documentation only when requested

Prohibited:
- edit source code
- edit DB migrations
- edit secrets or environment files
- run destructive commands
- change production config
- auto-fix lint or formatting
- refactor files
- commit changes
```

---

## 4. When To Use This Runbook

Use this runbook when:

| Situation | Use Read-Only Inspection? |
|---|---:|
| Source files are unknown | Yes |
| Module document is incomplete | Yes |
| Existing implementation must be mapped to Logic rules | Yes |
| Claude/Cursor will be asked to modify code later | Yes |
| A bug needs traceability from behavior to code | Yes |
| A restricted zone may be touched | Yes |
| Only new pure Markdown policy is being drafted | Usually No |

---

## 5. Required Inputs

Before inspection starts, collect:

| Input | Required |
|---|---:|
| Task objective | Yes |
| Related overview document | Required when available |
| Related logic document | Required when runtime behavior exists |
| Related Flow Bundle | Required when runtime flow exists |
| Existing module document | Required if available |
| Suspected module/file path | Optional |
| Known restricted zones | Required |
| Test scope | Optional |
| Evidence target | Optional |

---

## 6. Inspection Output Format

The inspection result must be returned in this structure:

```text
inspection_scope
candidate_modules
candidate_files
candidate_apis
candidate_tables_or_migrations
candidate_events_queues_jobs
candidate_tests
restricted_zone_findings
missing_documents
implementation_risk_notes
recommended_next_step
```

No code change diff should exist after read-only inspection.

---

## 7. Read-Only Inspection Steps

### Step 1. Confirm Repository And Branch State

| Check | Purpose |
|---|---|
| Current repository path | Confirm correct project |
| Current branch | Avoid inspecting wrong branch |
| Git status | Detect existing uncommitted changes |
| Recent commits | Understand active work context |

Required output:

```text
repo_path:
branch:
git_status_summary:
recent_commit_notes:
```

If uncommitted changes already exist, record them before proceeding.  
Do not modify or clean them.

---

### Step 2. Locate Candidate Domain Area

Search for directories and filenames related to the task.

Example search terms:

```text
payment
pos
gateway
approval
cancel
refund
settlement
reconciliation
audit
ledger
webhook
idempotency
retry
dlq
replay
provider
kds
order
```

Required output:

| Candidate Path | Reason |
|---|---|
| <path> | <why this path may be relevant> |

---

### Step 3. Locate Runtime Entry Points

Inspect only.

| Entry Type | Examples |
|---|---|
| API routes | REST/RPC handlers |
| Controllers | Request boundary |
| Services | Business logic |
| Adapters | Provider integration |
| Workers | Queue/DLQ/replay jobs |
| Webhook handlers | External inbound boundary |
| Schedulers | Settlement/reconciliation jobs |
| Admin actions | Manual recovery or approval |

Required output:

| Entry Point | Type | Related Flow Step | Risk |
|---|---|---|---|

---

### Step 4. Locate Data Models

Inspect schemas, migrations, ORM models, and database access layers.

| Data Area | Examples |
|---|---|
| Order state | orders, order_items, order_status |
| Payment state | payment_attempts, payment_events |
| Provider event | provider_events, webhook_events |
| Audit ledger | audit_events, append-only ledger |
| Recovery | recovery_tasks, dlq_entries |
| Settlement | settlement_batches, reconciliation_results |
| Admin approval | approval_requests, waiver_logs |

Required output:

| Table / Model / Migration | Purpose | Related Logic | Restricted? |
|---|---|---|---:|

---

### Step 5. Locate Tests

Search for tests that already cover the candidate files.

| Test Type | Examples |
|---|---|
| Unit | guards, validators, state transitions |
| Integration | API → service → DB |
| Contract | provider request/response |
| Fault injection | timeout, duplicate, mismatch |
| Security | signature, replay, secret leak |
| Audit | append-only evidence, hash chain |
| Migration | schema forward/backward |

Required output:

| Test File | Covered Area | Missing Scenario |
|---|---|---|

---

### Step 6. Locate Restricted Zone Files

Classify candidate files against the No-AI-Solo zone.

| Restricted Zone | File Examples |
|---|---|
| Payment | approval, cancel, refund, capture |
| Settlement | reconciliation, settlement export |
| Audit | ledger append, hash chain, evidence export |
| Security | auth, signature, token, secret, credential |
| DB migration | migration files, schema changes |
| Deployment | CI/CD, production config, infra |
| Secret | env, vault, key rotation |

Required output:

| File | Restricted Zone | AI Solo Allowed? | Required Approval |
|---|---|---:|---|

---

## 8. Safe Command Guidance

The following commands are generally read-only when used carefully:

```text
pwd
git status --short
git branch --show-current
git log --oneline -5
find . -maxdepth <n> -type f
grep -R "<term>" <path>
rg "<term>"
ls
cat <file>
sed -n '<start>,<end>p' <file>
```

Avoid commands that modify files, install packages, apply formatters, or run migrations.

Do not run:

```text
npm run fix
eslint --fix
prettier --write
prisma migrate
supabase db push
git add
git commit
git clean
rm
mv
cp over source files
```

Test execution may be allowed only after the task owner approves it, because some test suites can mutate local DB state or require secrets.

---

## 9. Inspection To Module Document Mapping

After inspection, update or create the related Module Document with the following mapping:

| Inspection Finding | Module Document Section |
|---|---|
| Candidate modules | Runtime Module Map |
| Candidate files | Source File Map |
| API handlers | API / Interface Map |
| Tables/migrations | Data Model Map |
| Queues/jobs/events | Event / Queue / Job Map |
| Functions/classes | Function / Class Responsibility Map |
| Tests | Test Map |
| Restricted files | No-AI-Solo Zone Check |
| Risks | Change Control / Release Readiness |

---

## 10. Inspection Result Template

Use this template for inspection notes.

```text
# Read-Only Inspection Result

## Scope
- Task:
- Related Flow Bundle:
- Related Overview:
- Related Logic:
- Related Module:

## Repository State
- Repo path:
- Branch:
- Git status:
- Existing uncommitted changes:

## Candidate Modules
| Module | Reason | Risk |
|---|---|---|

## Candidate Files
| File | Role | Related Logic | Restricted? |
|---|---|---|---:|

## Candidate APIs
| API / Handler | Direction | Related Flow Step |
|---|---|---|

## Candidate Tables / Migrations
| Table / Migration | Purpose | Restricted? |
|---|---|---:|

## Candidate Queues / Jobs / Events
| Item | Producer | Consumer | Retry/DLQ? |
|---|---|---|---|

## Candidate Tests
| Test File | Existing Coverage | Missing Coverage |
|---|---|---|

## Restricted Zone Findings
| File / Area | Restriction | Required Approval |
|---|---|---|

## Missing Documents
| Missing Item | Required Next Action |
|---|---|

## Recommended Next Step
- Documentation-only
- Create/update Module Document
- Create/update Test Coverage Map
- Human approval required
- Ready for Claude Code handoff
- Ready for Cursor limited assist
- Blocked
```

---

## 11. Read-Only Inspection Approval Gate

Before moving from inspection to implementation:

| Gate | Required |
|---|---:|
| Inspection result documented | Yes |
| Candidate files identified | Yes |
| Restricted zones classified | Yes |
| Module Document updated | Yes when code impact exists |
| Test Coverage Map updated | Yes when implementation impact exists |
| Evidence packet target identified | Yes |
| Human approval recorded for restricted zones | Required when applicable |
| Code handoff prompt rewritten with actual file scope | Yes |

---

## 12. Failure And Stop Conditions

Stop inspection and escalate if:

| Stop Condition | Required Action |
|---|---|
| Repository path is unclear | Ask project owner to confirm path |
| Git status shows unknown active edits | Record and request review |
| Secrets or credentials are exposed | Stop and open security incident note |
| Migration files are required but undocumented | Block implementation |
| Payment/settlement/audit/security files are involved without approval | Block AI implementation |
| Source mapping conflicts with existing MD docs | Update dependency graph before code work |
| Test suite requires production credentials | Do not run tests; document blocker |

---

## 13. Relationship With Claude Code And Cursor

Claude Code may perform read-only inspection only when instructed to do so.

Cursor may assist with symbol navigation and file search, but must not auto-edit during inspection.

Recommended wording:

```text
Perform read-only inspection only.
Do not modify files.
Do not run formatters.
Do not run migrations.
Do not commit.
Return candidate files, modules, tests, restricted zones, and missing documentation.
```

---

## 14. Summary

Read-only inspection is the safe bridge between documentation and code handoff.

It allows the project to discover actual module/file/test surfaces without letting AI tools guess or modify restricted areas.

The inspection must feed back into:

```text
Overview → Logic → Module → File → Test → Evidence
```

Only after this chain is complete may implementation proceed.
