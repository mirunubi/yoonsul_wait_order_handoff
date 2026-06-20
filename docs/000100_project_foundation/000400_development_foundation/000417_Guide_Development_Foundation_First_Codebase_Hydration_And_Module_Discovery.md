# 000417_Guide_Development_Foundation_First_Codebase_Hydration_And_Module_Discovery.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Guide |
| Document Role | First Codebase Hydration And Module Discovery Guide |
| Related Development Foundation Closeout | 000790_Index_Development_Foundation_Closeout_And_Runtime_Flow_Linkage.md |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Traceability Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Handoff Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Read-Only Inspection Runbook | 000710_Runbook_Development_Foundation_Codebase_Read_Only_Inspection.md |
| Related Inspection Report Template | 000720_Template_Development_Foundation_Read_Only_Inspection_Report.md |
| Related Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Status | Draft |
| Owner | Product / Architecture / Engineering |
| AI Solo Change | Read-only discovery allowed; source modification prohibited without approved handoff |

---

## 2. Purpose

This guide defines the first safe procedure for hydrating the actual codebase context and discovering implementation modules.

It is used when the project is ready to move from documentation planning into real repository inspection.

The objective is not to modify code.  
The objective is to build the first trustworthy map from documentation to implementation.

The required chain remains:

```text
Overview → Logic → Module → File → Test → Evidence
```

The first codebase hydration must produce enough information to create or update:

```text
03_module documents
source tree to module maps
restricted file registers
test coverage maps
AI handoff prompts
implementation tickets
```

---

## 3. Why This Step Exists

CatchMenu / Catch&Order now has financial-grade implementation risk.

The system may touch:

- POS gateway
- PG/VAN approval/cancel/refund
- settlement and reconciliation
- audit ledger
- webhook signature verification
- retry/DLQ/replay
- offline local ledger
- DB migration
- secret and credential boundaries
- production release gates

Therefore, codebase discovery must be controlled before code modification begins.

This guide prevents the following unsafe pattern:

```text
Read one MD file → ask AI to implement → AI searches broadly → AI edits unrelated files → tests/evidence missing → financial/audit/security risk.
```

---

## 4. Hydration Definition

In this project, codebase hydration means:

| Term | Meaning |
|---|---|
| Repository hydration | Confirm repository path, branch, structure, package/runtime stack, and current state |
| Module hydration | Identify actual modules and source folders that correspond to documented domains |
| Flow hydration | Connect Runtime Flow Bundle steps to actual code surfaces |
| Test hydration | Locate existing tests and missing coverage areas |
| Restriction hydration | Register actual restricted files and zones |
| Evidence hydration | Identify where implementation evidence will be stored |

Hydration is read-only unless a later approved handoff explicitly permits changes.

---

## 5. Entry Criteria

Do not start first codebase hydration unless the following are available:

| Item | Required |
|---|---:|
| Development Foundation bundle 00640~00790 | Yes |
| Runtime Flow Bundle baseline 64000~64390 | Recommended |
| Repository path | Yes |
| Current branch or working branch rule | Yes |
| Git status awareness | Yes |
| Read-only inspection runbook | Yes |
| Inspection report template | Yes |
| Restricted zone register | Yes |
| Known priority Flow Bundle | Recommended |

---

## 6. First Hydration Scope

The first hydration should not inspect the entire project at maximum depth unless necessary.

Recommended first scope:

```text
1. repository root and top-level folders
2. package/runtime stack
3. app/API route structure
4. modules/services folder structure
5. DB/schema/migration folders
6. test folders
7. env/deploy/CI folders only as restricted path discovery
8. POS/payment/audit/security candidate folders
```

Avoid deep implementation edits, dependency upgrades, auto-formatting, or migration execution.

---

## 7. First Hydration Output

The first hydration must produce:

| Output | Purpose |
|---|---|
| Repository Overview | Confirms project structure and stack |
| Source Tree Summary | Shows top-level and key module folders |
| Candidate Module Map | Maps domain names to actual folders/files |
| Candidate Restricted File List | Seeds 00750 restricted register |
| Candidate Test Map | Shows existing and missing tests |
| Candidate Flow Bundle Linkage | Connects 64000-band flows to code surfaces |
| Missing Documentation List | Identifies required overview/logic/module docs |
| Next Implementation Ticket Recommendation | Defines first safe code handoff candidate |

---

## 8. Read-Only Command Boundary

Allowed read-only commands:

```text
pwd
git status --short
git branch --show-current
git log --oneline -5
find . -maxdepth 2 -type d
find . -maxdepth 3 -type f
rg "<term>"
ls
cat package.json
cat pyproject.toml
cat pnpm-workspace.yaml
cat turbo.json
sed -n '1,160p' <file>
```

Prohibited commands:

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
deploy
```

Tests may be discovered during hydration, but not run unless the owner approves the local test environment.

---

## 9. Hydration Procedure

### Step 1. Confirm Repository Identity

Record:

```text
repo_path:
branch:
git_status:
recent_commits:
package_manager:
runtime_stack:
```

If the repository or branch is unclear, stop.

### Step 2. Capture Source Tree Skeleton

Capture only the relevant tree skeleton.

Recommended grouping:

```text
apps/
packages/
src/
server/
api/
modules/
services/
lib/
db/
migrations/
tests/
__tests__/
docs/
.github/
infra/
deploy/
```

### Step 3. Identify Candidate Domains

Search for core domain terms:

```text
pos
gateway
payment
approval
cancel
refund
settlement
reconciliation
audit
ledger
webhook
signature
idempotency
retry
dlq
replay
offline
local
sync
kds
order
```

### Step 4. Map Candidate Modules

For each candidate module, record:

| Candidate Module | Folder/File | Related Flow | Confidence | Notes |
|---|---|---|---:|---|
| TBD | TBD | TBD | Low/Medium/High | TBD |

### Step 5. Identify Candidate Restricted Files

Seed or update `000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md`.

| File/Folder | Zone Code | Restriction Level | Reason |
|---|---|---|---|
| TBD | RZ-PAY | Restricted | Payment mutation risk |
| TBD | RZ-AUDIT | Restricted | Audit evidence risk |
| TBD | RZ-SEC | Restricted | Security boundary risk |
| TBD | RZ-DB | Restricted | Migration risk |
| TBD | RZ-DEPLOY | Locked | Release risk |

### Step 6. Identify Candidate Tests

Record existing tests and coverage gaps.

| Test Path | Test Type | Candidate Module | Gap |
|---|---|---|---|
| TBD | Unit / Integration / Contract / Fault / Security / Audit | TBD | TBD |

### Step 7. Identify Missing Development Docs

For each important module, decide whether docs are missing.

| Area | Overview Exists? | Logic Exists? | Module Exists? | Required Action |
|---|---:|---:|---:|---|
| POS Gateway Approval | TBD | TBD | TBD | TBD |
| Cancel/Refund | TBD | TBD | TBD | TBD |
| Timeout/Retry/DLQ | TBD | TBD | TBD | TBD |
| Webhook Verification | TBD | TBD | TBD | TBD |
| Settlement/Reconciliation | TBD | TBD | TBD | TBD |

### Step 8. Recommend First Safe Implementation Candidate

The first code change should avoid the most dangerous zone unless full approval is ready.

Recommended first candidates:

| Candidate | Relative Risk | Reason |
|---|---|---|
| Read-only module map generation | Low | No code change |
| Documentation-to-source traceability update | Low | No runtime impact |
| Non-runtime test scaffolding discovery | Low/Medium | Can be controlled |
| Payment logic implementation | High/Critical | Requires full No-AI-Solo approval |
| Settlement/audit/security changes | Critical | Requires human approval and evidence |

---

## 10. Hydration Report Template

Use this condensed output after first hydration.

```text
# First Codebase Hydration Report

## Repository
- path:
- branch:
- git status:
- stack:
- package manager:

## Source Tree Summary
- top-level folders:
- app/API folders:
- module/service folders:
- DB/migration folders:
- test folders:
- restricted/deploy folders:

## Candidate Modules
| Module | Path | Related Flow Bundle | Confidence | Notes |
|---|---|---|---:|---|

## Candidate Restricted Files
| Path | Zone Code | Restriction Level | Reason |
|---|---|---|---|

## Candidate Tests
| Path | Type | Covered Module | Gap |
|---|---|---|---|

## Documentation Gaps
| Area | Missing Overview | Missing Logic | Missing Module | Priority |
|---|---:|---:|---:|---|

## Recommended Next Step
- update 00750 restricted register
- create 00820 source tree to module map
- create first actual module document
- prepare read-only inspection report
- defer implementation
```

---

## 11. Relationship To Future Documents

This guide feeds the following likely documents:

| Next Document | Role |
|---|---|
| 000810_Template_Development_Foundation_First_Flow_Bundle_Implementation_Ticket.md | Ticket template for first implementation handoff |
| 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md | Maps source tree to module docs |
| 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md | Registers module owners |
| 000840_Evidence_Development_Foundation_First_Codebase_Hydration_Report.md | Actual evidence packet for first hydration |
| 000850_Checklist_Development_Foundation_First_Runtime_Code_Change_Gate.md | Final gate before first runtime code change |

---

## 12. Claude/Cursor Prompt For First Hydration

Use this prompt shape.

```text
Perform first codebase hydration in read-only mode.

Do not modify files.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not commit.
Do not deploy.

Goal:
Map the repository structure to the Development Foundation chain:
Overview → Logic → Module → File → Test → Evidence.

Also map candidate Runtime Flow Bundle links:
Flow Step → Module → File → Test → Evidence.

Find:
1. repository structure
2. runtime stack
3. candidate POS/payment/audit/security modules
4. candidate DB/migration folders
5. candidate tests
6. restricted file/folder candidates
7. missing overview/logic/module docs
8. recommended first safe implementation candidate

Return a hydration report.
```

---

## 13. Stop Conditions

Stop hydration if:

| Stop Condition | Required Action |
|---|---|
| Repository path is wrong | Stop and correct path |
| Git status shows unknown edits | Record and ask owner before proceeding |
| Secret values are exposed | Stop and open security review |
| Production config is required for inspection | Do not access; mark restricted |
| AI attempts code modification | Stop and reset scope |
| Migration execution is suggested | Reject during hydration |
| Flow Bundle cannot be identified | Continue documentation-only mapping, not implementation |

---

## 14. Summary

First codebase hydration is the first controlled bridge from documentation to actual repository structure.

It must remain read-only.

Its output must improve the project maps:

```text
Overview → Logic → Module → File → Test → Evidence
```

and

```text
Flow Step → Module → File → Test → Evidence
```

Only after hydration produces a reliable source/module/test/restriction map should Claude Code or Cursor receive implementation work.
