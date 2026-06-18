# 000900_Template_Development_Foundation_First_Codebase_Hydration_Command_Pack.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Template |
| Document Role | First Codebase Hydration Command Pack |
| Related First Codebase Entry Closeout | 000890_Index_Development_Foundation_First_Codebase_Entry_Closeout.md |
| Related Hydration Guide | 000800_Guide_Development_Foundation_First_Codebase_Hydration_And_Module_Discovery.md |
| Related Hydration Evidence | 000840_Evidence_Development_Foundation_First_Codebase_Hydration_Report.md |
| Related Source Tree Matrix | 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md |
| Related Owner Register | 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md |
| Related Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md |
| Related Runtime Flow Registry | 64000_Index_Runtime_Flow_Bundle_Registry.md |
| Status | Draft |
| Owner | Architecture / Engineering / QA |
| AI Solo Change | Read-only command preparation allowed; source modification prohibited |

---

## 2. Purpose

This command pack provides the first safe read-only command and prompt set for hydrating the actual repository context.

It is designed to be pasted into Claude Code, Cursor, or a human terminal checklist when the project is ready to inspect the local codebase.

The command pack must not modify files.

The governing chain remains:

```text
Overview → Logic → Module → File → Test → Evidence
```

The command pack supports discovery of:

```text
Repository → Source Tree → Module → File → Test → Restricted Zone → Evidence
```

---

## 3. Absolute Safety Rule

During first hydration:

```text
Do not modify files.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage.
Do not commit.
Do not deploy.
Do not run destructive cleanup.
```

Allowed purpose:

```text
observe
list
search
summarize
record
map
classify
```

---

## 4. Target Repository

Default expected local repository:

```text
D:\workspace\yoonsul_wait_order_handoff
```

If the repository path differs, record the actual path in the hydration evidence packet.

---

## 5. Human Terminal Command Pack

Run only read-only commands.

### 5.1 Repository Identity

```powershell
cd D:\workspace\yoonsul_wait_order_handoff
pwd
git branch --show-current
git status --short
git log --oneline -5
```

Record output into:

```text
000840_Evidence_Development_Foundation_First_Codebase_Hydration_Report.md
```

### 5.2 Top-Level Tree

PowerShell:

```powershell
Get-ChildItem -Force | Select-Object Mode,Length,LastWriteTime,Name
Get-ChildItem -Directory | Select-Object Name
```

Git Bash / Unix-like:

```bash
find . -maxdepth 2 -type d | sort
find . -maxdepth 2 -type f | sort
```

### 5.3 Runtime Stack Discovery

PowerShell:

```powershell
Get-ChildItem -Force package.json,pnpm-workspace.yaml,yarn.lock,package-lock.json,pnpm-lock.yaml,turbo.json,tsconfig.json,pyproject.toml,requirements.txt,go.mod,Cargo.toml -ErrorAction SilentlyContinue
```

Git Bash / Unix-like:

```bash
ls -la package.json pnpm-workspace.yaml yarn.lock package-lock.json pnpm-lock.yaml turbo.json tsconfig.json pyproject.toml requirements.txt go.mod Cargo.toml 2>/dev/null
```

If files exist, inspect only the safe header or dependency summary. Do not run install/update.

### 5.4 Candidate Domain Search

Use `rg` if available.

```powershell
rg -n "pos|gateway|payment|approval|cancel|refund|settlement|reconciliation|audit|ledger|webhook|signature|idempotency|retry|dlq|replay|offline|local|sync|kds|order" . --glob "!node_modules/**" --glob "!.git/**"
```

If `rg` is not available, use:

```powershell
Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notmatch "\.git|node_modules|dist|build" } | Select-String -Pattern "pos|gateway|payment|approval|cancel|refund|settlement|reconciliation|audit|ledger|webhook|signature|idempotency|retry|dlq|replay|offline|local|sync|kds|order"
```

### 5.5 Test Discovery

```powershell
Get-ChildItem -Recurse -File | Where-Object { $_.FullName -match "test|spec|__tests__" } | Select-Object FullName
```

Git Bash / Unix-like:

```bash
find . -type f \( -name "*test*" -o -name "*spec*" \) | sort
find . -type d -name "__tests__" | sort
```

### 5.6 DB / Migration Discovery

```powershell
Get-ChildItem -Recurse -Directory | Where-Object { $_.FullName -match "migration|migrations|schema|prisma|supabase|db|database" } | Select-Object FullName
```

### 5.7 Config / Secret / Deploy Restricted Discovery

Do not open secret values. Identify paths only.

```powershell
Get-ChildItem -Recurse -Force | Where-Object { $_.FullName -match "\.env|secret|vault|credential|deploy|infra|\.github|workflow|docker|compose|k8s|helm" } | Select-Object FullName
```

Rules:

1. Do not print secret file contents.
2. Do not copy credential values into reports.
3. Mark these paths as restricted or locked candidates.

---

## 6. Claude Code Read-Only Hydration Prompt

Use this prompt if Claude Code performs first hydration.

```text
Perform first codebase hydration in read-only mode only.

Repository:
D:\workspace\yoonsul_wait_order_handoff

Do not modify files.
Do not run formatters.
Do not run migrations.
Do not install packages.
Do not change secrets.
Do not stage or commit.
Do not deploy.
Do not run destructive commands.

Goal:
Map the repository structure to the Development Foundation chain:
Overview → Logic → Module → File → Test → Evidence.

Also map candidate Runtime Flow Bundle links:
Flow Step → Module → File → Test → Evidence.

Read these docs if available:
- 000800_Guide_Development_Foundation_First_Codebase_Hydration_And_Module_Discovery.md
- 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md
- 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md
- 000840_Evidence_Development_Foundation_First_Codebase_Hydration_Report.md
- 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md
- 64000_Index_Runtime_Flow_Bundle_Registry.md

Find:
1. repository path, branch, git status, recent commits
2. top-level source tree
3. runtime stack and package manager
4. candidate POS/payment/audit/security modules
5. candidate API handlers and service modules
6. candidate DB/schema/migration folders
7. candidate test folders/files
8. candidate secret/deploy/restricted paths
9. missing overview/logic/module documents
10. recommended first safe implementation candidate

Return only a report. Do not produce a patch.
```

---

## 7. Cursor Read-Only Hydration Prompt

Use this prompt if Cursor assists with repository navigation.

```text
Use Cursor as read-only IDE navigation.

Do not edit files.
Do not apply suggestions.
Do not run formatters.
Do not run migrations.
Do not change secrets.
Do not stage or commit.

Find candidate files and symbols for:
- POS gateway
- payment approval
- cancel/refund
- timeout/retry/DLQ/replay
- offline local ledger
- webhook verification
- settlement/reconciliation
- audit ledger
- tests
- migrations
- secrets/deploy config

Return:
- candidate file paths
- candidate module names
- candidate test paths
- restricted path candidates
- missing documentation links
- recommended next step
```

---

## 8. Hydration Report Output Shape

The output must follow this shape.

```text
# First Codebase Hydration Output

## Repository
- path:
- branch:
- git_status:
- recent_commits:
- runtime_stack:
- package_manager:

## Source Tree
- top_level:
- app_or_api:
- modules_or_services:
- db_or_migrations:
- tests:
- config_secret_deploy:

## Candidate Modules
| Module | Path | Related Flow Bundle | Confidence | Notes |
|---|---|---|---:|---|

## Candidate Files
| File | Role | Candidate Module | Restricted? | Notes |
|---|---|---|---:|---|

## Candidate Tests
| Test Path | Type | Covered Area | Gap |
|---|---|---|---|

## Candidate Restricted Paths
| Path | Zone Code | Restriction Level | Reason |
|---|---|---|---|

## Documentation Gaps
| Area | Missing Overview | Missing Logic | Missing Module | Priority |
|---|---:|---:|---:|---|

## Recommended Updates
- 00820:
- 00830:
- 00750:
- 00690:
- 64210:
- 64220:

## Recommended First Safe Next Step
- TBD
```

---

## 9. Stop Conditions

Stop hydration if:

| Stop Condition | Required Action |
|---|---|
| Repository path is not the expected project | Stop and correct path |
| Git status shows unknown user edits | Record and ask owner before continuing |
| Secret values are exposed | Stop and open security review |
| Tool tries to edit files | Stop and reset to read-only |
| Migration execution is suggested | Reject and record blocker |
| Deploy/release file must be opened deeply | Mark restricted and stop deep inspection |
| Flow Bundle cannot be mapped | Continue source mapping only, not implementation |

---

## 10. Post-Hydration Updates

After command pack execution, update:

| Document | Update |
|---|---|
| 000840_Evidence_Development_Foundation_First_Codebase_Hydration_Report.md | Fill actual hydration evidence |
| 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md | Add actual paths |
| 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md | Assign module owners |
| 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md | Add actual restricted paths |
| 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md | Link docs to module/file/test/evidence |
| 64210_Matrix_Flow_To_Module_Implementation_Map.md | Update Flow-to-module rows |
| 64220_Matrix_Flow_To_Test_Coverage_Map.md | Update Flow-to-test rows |

---

## 11. Summary

This command pack is the first practical bridge from documentation into repository observation.

It must remain read-only.

It exists to produce the evidence needed before any implementation handoff:

```text
Overview → Logic → Module → File → Test → Evidence
```

No runtime code change should occur from this command pack alone.
