# 000870_Runbook_Development_Foundation_First_Runtime_Diff_Review_And_Rollback.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Runbook |
| Document Role | First Runtime Diff Review And Rollback Runbook |
| Related Closeout | 000790_Index_Development_Foundation_Closeout_And_Runtime_Flow_Linkage.md |
| Related Hydration Guide | 000800_Guide_Development_Foundation_First_Codebase_Hydration_And_Module_Discovery.md |
| Related First Runtime Gate | 000850_Checklist_Development_Foundation_First_Runtime_Code_Change_Gate.md |
| Related Handoff Prompt | 000860_Template_Development_Foundation_First_Runtime_Code_Change_Handoff_Prompt.md |
| Related Source Tree Matrix | 000820_Matrix_Development_Foundation_Source_Tree_To_Module_Document_Map.md |
| Related Owner Register | 000830_Register_Development_Foundation_Repository_Module_Owner_Map.md |
| Related Restricted Register | 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md |
| Related AI Change Audit | 000760_Audit_Development_Foundation_AI_Assisted_Change_Control.md |
| Related Pre-Merge Gate | 000780_Checklist_Development_Foundation_Pre_Merge_And_Release_Gate.md |
| Related Runtime Flow Release Gate | 64390_Checklist_Flow_Bundle_Pre_Merge_And_Release_Gate.md |
| Status | Draft |
| Owner | Architecture / Engineering / QA / Release |
| AI Solo Change | AI may assist review; rollback/merge/release approval requires human decision |

---

## 2. Purpose

This runbook defines how to review the first runtime code change diff and how to roll it back if the change violates scope, tests, evidence, or restricted-zone controls.

The first runtime change is a high-risk project milestone because it moves from documentation into executable behavior.

The governing chain remains:

```text
Overview → Logic → Module → File → Test → Evidence
```

The first runtime diff must prove that it did not break this chain.

---

## 3. Core Rule

A runtime diff may not be accepted simply because it compiles or appears correct.

It must be checked against:

1. approved Flow Bundle
2. approved overview / logic / module documents
3. allowed file list
4. prohibited file list
5. restricted register
6. test plan
7. evidence packet
8. AI audit record
9. exception / waiver log
10. merge and release gates

If the diff exceeds scope, the default action is block and rollback or split.

---

## 4. Diff Review Inputs

| Input | Required |
|---|---:|
| First runtime implementation ticket | Yes |
| Handoff prompt used | Yes if AI was used |
| Changed file list | Yes |
| Git diff | Yes |
| Related Flow Bundle | Yes |
| Related Overview document | Yes |
| Related Logic document | Yes |
| Related Module document | Yes |
| Source tree mapping rows | Yes |
| Restricted file register rows | Yes |
| Test plan and results | Conditional |
| Evidence packet notes | Yes |
| Human approval record for restricted zones | Conditional |

---

## 5. Diff Review Procedure

### Step 1. Confirm Git State

Record:

```text
branch:
git_status:
changed_files:
untracked_files:
```

If unrelated or unknown changes are present, stop and classify before review.

### Step 2. Compare Changed Files Against Allowed Scope

| Check | Pass Condition |
|---|---|
| Every changed file is listed in the ticket | Yes |
| Every changed file is mapped in 00820 | Yes |
| Every changed file has an owner in 00830 | Yes |
| No prohibited file changed | Yes |
| No unrelated formatting-only broad change exists | Yes |

### Step 3. Check Restricted Zone Touch

| Check | Pass Condition |
|---|---|
| Restricted register checked | Yes |
| Restricted file changed? | Must be declared |
| Approval exists if restricted file changed | Required |
| Evidence target exists | Required |
| Tests cover restricted behavior | Required |

If restricted zone was touched without approval, stop and rollback or isolate.

### Step 4. Compare Behavior To Logic Document

| Logic Review Question | Required Result |
|---|---|
| Does diff implement only approved logic rules? | Yes |
| Does diff change state transitions? | Must be documented |
| Does diff change retry/DLQ/replay behavior? | Must be approved/tested |
| Does diff change payment/cancel/refund behavior? | Must be approved |
| Does diff change settlement/audit/security behavior? | Must be approved |
| Does diff create unknown success state? | No |
| Does diff mutate audit history? | No |

### Step 5. Test And Evidence Review

| Check | Pass Condition |
|---|---|
| Required tests added or updated | Yes / Approved waiver |
| Tests actually run or blocker recorded | Yes |
| Test results recorded | Yes |
| Evidence packet updated | Yes |
| AI audit updated if AI was used | Yes |
| Waiver log updated if gap exists | Yes |

---

## 6. First Runtime Diff Review Checklist

| Review Item | Required | Status | Notes |
|---|---:|---|---|
| Branch and git status recorded | Yes | TBD | TBD |
| Changed files listed | Yes | TBD | TBD |
| Changed files match ticket | Yes | TBD | TBD |
| Changed files mapped in 00820 | Yes | TBD | TBD |
| Module owners confirmed in 00830 | Yes | TBD | TBD |
| Restricted register checked | Yes | TBD | TBD |
| Restricted approvals present if needed | Conditional | TBD | TBD |
| Logic rules preserved | Yes | TBD | TBD |
| Module document still accurate | Yes | TBD | TBD |
| Tests added/updated as required | Conditional | TBD | TBD |
| Test results recorded or blocker logged | Yes | TBD | TBD |
| Evidence packet updated | Yes | TBD | TBD |
| AI audit updated if AI used | Conditional | TBD | TBD |
| Waiver log updated if needed | Conditional | TBD | TBD |
| Merge blockers resolved | Yes | TBD | TBD |

---

## 7. Rollback Decision Matrix

| Finding | Default Action |
|---|---|
| Unapproved file changed | Rollback that file or split change |
| Restricted file changed without approval | Rollback immediately and escalate |
| Secret/env/deploy file changed unexpectedly | Rollback immediately and open security/release review |
| Migration changed unexpectedly | Rollback and require DB migration gate |
| Audit ledger/tamper behavior changed unexpectedly | Rollback and require compliance review |
| Payment/settlement behavior changed unexpectedly | Rollback and require financial review |
| Tests missing for runtime behavior | Block merge; add tests or approved waiver |
| Evidence missing | Block release |
| Broad refactor included | Split or rollback unrelated refactor |
| Logic document no longer matches implementation | Update logic/module docs and re-approve |

---

## 8. Safe Rollback Rules

Rollback must preserve existing work and avoid destructive cleanup.

Preferred safe rollback methods:

```text
1. inspect diff first
2. revert only the unapproved changed file or hunk
3. preserve unrelated user changes
4. do not run git clean unless explicitly approved
5. do not reset whole branch unless explicitly approved
6. record rollback reason and evidence
```

Avoid:

```text
git reset --hard
git clean -fd
rm -rf
blind checkout of entire tree
deleting untracked files
```

unless the human owner explicitly approves and confirms no unrelated local work exists.

---

## 9. Rollback Record Template

Use this form if any part of the first runtime change is rolled back.

```text
# Rollback Record

## Summary
- Rollback ID:
- Date:
- Related ticket:
- Related Flow Bundle:
- Reason:

## Scope
- Files rolled back:
- Files preserved:
- Restricted zone involved:
- Human approver:

## Risk
- Runtime impact:
- Payment impact:
- Settlement impact:
- Audit impact:
- Security impact:
- DB/migration impact:
- Release impact:

## Evidence
- Diff before rollback:
- Diff after rollback:
- Tests run after rollback:
- Evidence packet:
- Waiver/exception record:

## Final State
- Git status:
- Remaining changed files:
- Next action:
```

---

## 10. AI-Assisted Diff Review Prompt

Use this prompt when asking Claude Code or Cursor to assist with diff review.

```text
Review the current diff only.

Do not modify files.
Do not auto-fix.
Do not format.
Do not commit.
Do not deploy.

Compare the diff against:
- first runtime implementation ticket
- allowed file list
- prohibited file list
- source tree to module map
- restricted file register
- overview / logic / module documents
- test requirements
- evidence requirements

Return:
1. changed_files
2. unapproved_changed_files
3. restricted_zone_touched
4. missing_approvals
5. logic_mismatch
6. missing_tests
7. missing_evidence
8. rollback_recommendation
9. merge_risk_summary
```

---

## 11. Human Review Sign-Off

| Sign-Off Item | Owner | Required |
|---|---|---:|
| Scope review | Architecture / Engineering | Yes |
| Logic review | Architecture / Product | Yes for runtime behavior |
| Code review | Engineering | Yes |
| Test review | QA | Yes |
| Restricted-zone review | Relevant owner | Conditional |
| Evidence review | QA / Compliance | Conditional |
| Merge decision | Human owner | Yes |
| Release decision | Release owner | Conditional |

---

## 12. Merge Decision

| Field | Value |
|---|---|
| Diff Review Complete? | Yes / No |
| Rollback Required? | Yes / No |
| Rollback Complete? | Yes / No / N/A |
| Tests Complete? | Yes / No / Conditional |
| Evidence Complete? | Yes / No / Conditional |
| Restricted Approval Complete? | Yes / No / N/A |
| Merge Decision | Allowed / Blocked / Split Required |
| Decision Owner | TBD |
| Decision Date | YYYY-MM-DD |

---

## 13. Summary

The first runtime diff must be reviewed as a controlled artifact, not as casual code output.

A safe first runtime change is:

```text
narrow
mapped
owned
within allowed files
free of unapproved restricted changes
tested or test-blocker documented
evidenced
human-reviewed
rollback-ready
```

If the diff violates these rules, rollback or split the change before merge.
