# 604339_Approval_Gate_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md

## 1. Document Role

This document is the Approval Gate for the repair pass following:

- `604336_Implementation_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md`
- `604337_Verification_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md`
- `604338_Audit_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md`

This Approval Gate authorizes a narrow documentation-only repair pass for stale folder path corruption introduced by mechanical text replacement during 604336.

This Approval Gate does not authorize SQL changes, migration changes, runtime implementation, or 0069 Analysis creation.

## 2. Audit Basis

604338 accepted the successful parts of 604336 and accepted the verification failure reported by 604337, with two corrections:

1. `604335_Approval_Gate_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md` exists at the expected path and is correctly referenced by 604336.
2. The bogus folder path corruption affects seven files, not six. 604335 itself is also affected.

Therefore, the approval traceability issue is not a missing-file restoration issue. It is a verification traceability correction issue and a process-control note regarding tool visibility / live working-tree snapshots.

## 3. Approved Repair Scope

The implementer is authorized to repair only the following defect:

### 3.1 Bogus Folder Path Defect

The following bogus folder path must be removed from active documentation:

```text
604350_cross_scope_0046_context_builder_baseline_replay_blocker
```

This path never existed and was introduced by mechanical replacement of `604290` with `604350`.

### 3.2 Correct Historical Path

Where the prose is referring to the old pre-merge folder, the correct historical path is:

```text
604290_cross_scope_0046_context_builder_baseline_replay_blocker
```

### 3.3 Correct Current Canonical Path

Where the prose is referring to the current canonical folder, the correct current path is:

```text
604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery
```

The implementer must distinguish historical references from current canonical references. The repair must not blindly replace the bogus path with a single value in every occurrence without reading local context.

## 4. Approved Files

The repair pass is limited to the following seven files inside the canonical folder:

```text
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604329_Analysis_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604330_Approval_Gate_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604331_Implementation_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604332_Verification_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604333_Audit_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604334_Analysis_Workpacket_Directory_Link_Impact_And_604350_Renumbering_Plan.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604335_Approval_Gate_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md
```

No other files are approved for modification.

## 5. Required Repair Rules

The implementer must follow all rules below.

### 5.1 No Mechanical Global Replacement

The implementer must not run an unrestricted repository-wide replacement.

The implementer must inspect each occurrence and determine whether the context describes:

- the historical removed 604290 folder, or
- the current canonical 604300 folder.

### 5.2 Historical Approval Records May Be Corrected Only for Corruption

The 604335 Approval Gate may be edited only to reverse unauthorized mechanical corruption.

The implementer must not alter the decision outcome, scope, authorization, forbidden files, approval wording, or implementation boundaries of 604335.

### 5.3 Preserve Accepted Implementation Results

The following 604336 results remain accepted and must not be undone:

- residual file renumbering to 604350~604359
- 604351 and 604355 remaining as intentional gaps
- renamed file H1 corrections
- 604300_Index correction
- 604306_NavigationMap lane addition
- stale 000005 / 000007 deprecated forwarding handling
- mandatory directory artifact rule
- SQL/migration boundary preservation

### 5.4 Correct the Approval Traceability Record

The implementer may add a note in the implementation result that:

- 604337 reported 604335 as not found,
- 604338 independently verified that 604335 exists and is correctly referenced,
- no restoration of 604335 is required,
- the remaining action is to record the false-negative traceability correction.

This note must not be treated as permission to modify 604337. 604337 is a verification record and should remain as-is unless a separate approval gate authorizes amendment.

## 6. Explicitly Forbidden Work

The following work is not authorized:

- SQL modification
- migration modification
- runtime code modification
- Flutter modification
- RPC modification
- RLS modification
- trigger modification
- function modification
- schema modification
- test fixture modification
- creation of 0069 Analysis
- creation of any 0142 or pre-0142 runtime implementation document
- creation of 604351 or 604355
- repository-wide mechanical replacement
- rewriting 604337 to hide or erase its false-negative finding
- broad cleanup outside the seven approved files

## 7. Required Implementation Output

The implementer must create the next implementation record:

```text
604340_Implementation_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md
```

The H1 must exactly match the full filename including `.md`.

The implementation record must include:

1. this 604339 Approval Gate reference,
2. the seven inspected files,
3. each occurrence repaired,
4. whether each occurrence was historical or current canonical context,
5. confirmation that the bogus path no longer appears in the seven approved files,
6. confirmation that no SQL/migration/runtime files were changed,
7. confirmation that 0069 Analysis was not created,
8. confirmation that 604337 was not rewritten,
9. the approval traceability correction note regarding 604335 existence.

## 8. Required Verification After Implementation

After 604340 implementation, create:

```text
604341_Verification_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md
```

Verification must check:

```text
grep -R "604350_cross_scope_0046_context_builder_baseline_replay_blocker" docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery
```

Expected result:

```text
no active match
```

Verification must also confirm:

- `604335_Approval_Gate_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md` exists.
- 604335 H1 matches its filename.
- 604336 references 604335 by exact filename.
- 604337 remains unchanged unless separately approved.
- no SQL/migration/runtime files changed.
- 0069 Analysis was not created.

## 9. Required Audit After Verification

After 604341 verification, create:

```text
604342_Audit_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md
```

Audit must decide whether:

- the stale bogus folder path defect is closed,
- the 604335 traceability false-negative is recorded and closed,
- the 604336 partial acceptance can be upgraded for this repair scope,
- 0069 Analysis remains deferred.

## 10. Final Approval Decision

Final Approval Decision:

```text
APPROVED_FOR_CODEX_DOCUMENTATION_REPAIR_WITH_STRICT_BOUNDARY
```

Authorized implementer:

```text
Codex
```

Approved modification scope:

```text
Only the seven approved documentation files listed in Section 4.
```

Forbidden scope:

```text
SQL, migrations, runtime code, 0069 Analysis, 604337 amendment, repository-wide replacement, and all files not listed in Section 4.
```

This approval is narrow, corrective, and documentation-only.
