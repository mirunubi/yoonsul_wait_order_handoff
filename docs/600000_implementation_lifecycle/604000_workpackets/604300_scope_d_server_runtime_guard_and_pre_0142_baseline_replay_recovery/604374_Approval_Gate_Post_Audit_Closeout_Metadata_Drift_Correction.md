# 604374_Approval_Gate_Post_Audit_Closeout_Metadata_Drift_Correction.md

## 1. Approval Gate Summary

This document opens a narrow documentation-only repair lane for post-audit closeout metadata drift discovered after 604373 closed the directory/index/navigation artifact correction track.

Final approval decision:

```text
APPROVED_FOR_604375_CODEX_IMPLEMENTATION_WITH_STRICT_TWO_FILE_METADATA_BOUNDARY
```

Authorized implementer:

```text
Codex
```

Defect classification:

```text
POST_AUDIT_CLOSEOUT_METADATA_DRIFT
```

This is not a runtime, SQL, migration, replay, or business-logic defect.

## 2. Confirmed Blocker

604373 independently accepted the repair and closed the 604335-604373 directory/index/navigation artifact correction track. Two active navigation documents still describe the audit as pending:

```text
604300_Index_Scope_D_Server_Runtime_Guard.md
- says 604373 remains pending
- says 0069 is deferred until the pending 604373 Audit completes
- lists 604373 as pending / not yet created

604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md
- says the independent 604373 Audit remains pending
- says 604373 has not yet been created
- shows the route ending in 604373 Audit pending
```

Repository truth established by 604373:

```text
604373 exists.
604373 Audit result is PASS / ACCEPT.
The 604335-604373 correction track is CLOSED.
0069 Analysis remains deferred pending a separate Human resume decision.
```

## 3. Approved Numbering Lane

```text
604374 Approval Gate
604375 Implementation by Codex
604376 Verification
604377 independent Audit
```

The lane repairs closeout metadata only. It does not reopen the defect accepted by 604373.

## 4. Authorized Files

604375 may modify exactly these two existing files:

```text
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604300_Index_Scope_D_Server_Runtime_Guard.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md
```

Lifecycle evidence documents 604374-604377 may be created in the same canonical folder according to their assigned stage. Their creation does not authorize edits to any additional repository file.

## 5. Authorized Content Changes

In 604300 Index only:

```text
- replace the claim that 604373 remains pending with CLOSED / accepted status
- replace the claim that 0069 waits for 604373 with the correct rule that 0069 remains deferred pending a separate explicit Human resume decision
- replace the 604373 pending / not-yet-created file-list annotation with completed Audit status
```

In 604306 NavigationMap only:

```text
- replace the claim that 604373 remains pending with CLOSED / accepted status
- replace the claim that 604373 has not yet been created with the fact that it exists and closed the correction track
- change the route endpoint from 604373 Audit pending to 604373 Audit CLOSED
- preserve the rule that 0069 Analysis remains deferred pending a separate explicit Human resume decision
```

No other semantic change is approved.

## 6. Mandatory Preservation Rules

604375 must preserve all of the following:

```text
- 604373 as the immutable historical independent Audit record
- 604337 and 604338 as immutable historical verification/audit records
- 604340-604369 buffer and historical collision records
- intentional 604351 and 604355 gaps
- existing valid 604350-series document numbering
- canonical folder name and directory structure
- all replay-blocker history through 0068
- 0069 Analysis deferred state
- 0142 not-reached historical context
```

## 7. Explicitly Forbidden Work

```text
Do not open, create, or modify 0069 Analysis.
Do not modify SQL.
Do not modify migrations.
Do not modify runtime code.
Do not modify functions, schemas, tables, tests, seeds, configuration, or lockfiles.
Do not modify 604337.
Do not modify 604338.
Do not modify 604373.
Do not modify 604329-604335 historical prose.
Do not create artifacts in 604340-604369.
Do not create 604351 or 604355 placeholders.
Do not renumber 604350-604359.
Do not modify 000005 or 000007 during 604375.
Do not stage or commit unrelated working-tree changes.
```

## 8. Required 604375 Implementation Record

Codex must create:

```text
604375_Implementation_Post_Audit_Closeout_Metadata_Drift_Correction.md
```

604375 must record:

```text
1. The exact two active metadata files modified.
2. The stale pending/not-created statements removed.
3. The CLOSED/accepted statements added.
4. The separately gated 0069 deferred rule preserved.
5. Confirmation that 604337, 604338, and 604373 were not modified.
6. Confirmation that no SQL, migration, or runtime file was modified.
7. Confirmation that the buffer and intentional gaps were preserved.
```

## 9. Required 604376 Verification

The verifier must create:

```text
604376_Verification_Post_Audit_Closeout_Metadata_Drift_Correction.md
```

604376 must independently verify:

```text
- 604300 contains no claim that 604373 is pending or not created
- 604306 contains no claim that 604373 is pending or not created
- both documents state that 604373 closed the correction track
- both documents keep 0069 Analysis deferred pending explicit Human resume authority
- 604337, 604338, and 604373 are unchanged
- no 0069 Analysis document was created or modified
- no SQL, migration, or runtime change was introduced by this mini pass
- 604340-604369 remains preserved
- 604351 and 604355 remain absent
- git diff --check passes
```

## 10. Required 604377 Audit

The independent auditor must create:

```text
604377_Audit_Post_Audit_Closeout_Metadata_Drift_Correction.md
```

604377 must decide whether the metadata drift is closed without expanding scope or prematurely authorizing 0069 Analysis.

## 11. Commit Readiness And Selective Staging Gate

After 604377 Audit, commit readiness must include:

```text
git diff --check
git status --short
git diff --cached --name-only
git status --short -- sql sql/migrations
```

The final report must distinguish pre-existing SQL/migration working-tree changes from files introduced by this mini pass. No SQL or migration file may be staged.

Approved selective staging manifest for this mini pass:

```text
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604300_Index_Scope_D_Server_Runtime_Guard.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604374_Approval_Gate_Post_Audit_Closeout_Metadata_Drift_Correction.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604375_Implementation_Post_Audit_Closeout_Metadata_Drift_Correction.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604376_Verification_Post_Audit_Closeout_Metadata_Drift_Correction.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604377_Audit_Post_Audit_Closeout_Metadata_Drift_Correction.md
```

This manifest authorizes selective staging only after the files exist and the 604377 Audit accepts the mini pass. It does not authorize staging now and does not authorize a commit containing unrelated changes.

## 12. Final Boundary Decision

```text
PROCEED_TO_604375_IMPLEMENTATION_BY_CODEX
```

604375 must perform only the two-file closeout metadata correction described above. 0069 Analysis remains deferred.
