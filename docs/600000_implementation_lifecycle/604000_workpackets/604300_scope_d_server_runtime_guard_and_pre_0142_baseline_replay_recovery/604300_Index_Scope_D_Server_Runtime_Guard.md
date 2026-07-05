# 604300_Index_Scope_D_Server_Runtime_Guard.md

## 604300 Scope D Server Runtime Guard And Pre-0142 Baseline Replay Recovery

Canonical folder:
`604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/`

This canonical folder combines the original Scope D Server Runtime Guard master
pack with the pre-0142 baseline migration replay recovery lineage. The two concerns
share navigation and directory governance but retain separate implementation gates.

The replay-recovery lineage is not a contiguous `604290-604328` range. Its residual
604290-origin documents were renumbered to `604350`, `604352-604354`, and
`604356-604359`; `604351` and `604355` remain intentional pre-existing gaps.
Hard-collision resolution records occupy `604341-604344`. Directory hygiene,
impact analysis, approval, implementation, verification, and audit records occupy
`604329-604339`. The approved stale-folder-path repair lineage occupies
`604370-604373`; 604373 is the completed independent Audit that accepted and
closed that correction track. The post-audit closeout metadata repair lane uses
`604374-604377`.

Status:
- Master documentation pack completed
- Pre-0142 replay recovery active; blockers through 0068 accepted
- Stale-folder-path repair implemented under 604371, verified PASS under 604372,
  and accepted/CLOSED by the completed 604373 independent Audit
- 0069 Analysis remains deferred pending a separate explicit Human resume decision
- 0142 not yet reached because replay is currently blocked at 0069
- Runtime implementation not authorized
- Sub-workpacket implementation not authorized

Files:
- 604301_Overview_Scope_D_Server_Runtime_Guard.md
- 604302_Logic_Scope_D_Server_Runtime_Guard.md
- 604303_TestPlan_Scope_D_Server_Runtime_Guard.md
- 604304_ChangeContract_Scope_D_Server_Runtime_Guard.md
- 604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md

Directory governance lineage:
- 604329_Analysis_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
- 604330_Approval_Gate_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
- 604331_Implementation_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
- 604332_Verification_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
- 604333_Audit_Workpacket_Directory_Boundary_And_Scope_D_Folder_Merge.md
- 604334_Analysis_Workpacket_Directory_Link_Impact_And_604350_Renumbering_Plan.md
- 604335_Approval_Gate_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md
- 604336_Implementation_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md
- 604337_Verification_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md
- 604338_Audit_Workpacket_Directory_Index_Navigation_Artifact_Correction_And_604350_Renumbering.md
- 604339_Approval_Gate_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md (historical/superseded numbering record)
- 604370_Approval_Gate_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md
- 604371_Implementation_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md
- 604372_Verification_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md
- 604373_Audit_Workpacket_Directory_Stale_Folder_Path_Repair_And_Approval_Traceability_Correction.md (completed; CLOSED)
- 604374_Approval_Gate_Post_Audit_Closeout_Metadata_Drift_Correction.md
- 604375_Implementation_Post_Audit_Closeout_Metadata_Drift_Correction.md
- 604376_Verification_Post_Audit_Closeout_Metadata_Drift_Correction.md (next; not yet created)
- 604377_Audit_Post_Audit_Closeout_Metadata_Drift_Correction.md (pending verification; not yet created)

Boundary:
- 604301~604304 are the Scope D master documentation pack only.
- These files do not authorize SQL, migration, Edge Function, Flutter, Dart, Python, config, or runtime edits.
- 604310~604380 define future sub-workpacket lane names and boundaries only.
- Each sub-workpacket requires its own impact_scope, overview, logic, test_plan, change_contract, human approval, module, verification, and audit.

Navigation:
- `604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md` explains both the Scope D payment route and the separate pre-0142 replay-recovery chain. It does not authorize implementation.

Active sub-workpacket lanes:
- `604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/` — Scope D Slice 00: PaymentLedger / ConfirmPayment Schema Drift Alignment; required precondition for 604310 implementation approval.
- `604260_scope_d_00a_toss_mvp_payment_intent_binding_precondition/` — Scope D Slice 00A: Toss MVP PaymentIntent Binding Precondition; blocking precondition for resuming 604250 implementation.
- `604400_scope_d_01_payment_confirm_idempotency/` — Scope D Slice 01: Payment Confirm Idempotency / Amount Verification. ImpactScope through ChangeContract (`604311`–`604315`) are complete. Implementation is **not next** — see policy update below.

Schema drift precondition (policy update, 2026-07-01):
- A design policy consolidation (`confirm_payment` / Scope D integrity, idempotency, schema drift, legacy POS ACL) identified that `payment_ledger`'s physical schema (`0014`) and `confirm_payment`'s `INSERT` statement (`0098`) are not reconciled — `intent_id` is `NOT NULL` in the DDL but omitted by the RPC, and the DDL's `provider_payment_key` column does not match the RPC's `provider_tx_id`. Implementing `604310`'s idempotency logic on top of this unreconciled insert path would build correctness guarantees on a physically broken write path.
- **604250 Schema Drift Alignment is a required precondition before `604310` implementation.**
- `604310` implementation approval (`604316` Human Approval) remains **deferred** until schema drift alignment is verified/closed, in addition to the eight Required Human Decisions already listed in `604310_Index_Scope_D_01_Payment_Confirm_Idempotency.md`.

604260 is the current next required lane.
604250 implementation stopped under 604256 because Toss MVP has no payment_intent binding.
604250 cannot resume until 604260 closes.
604310 and 604316 remain blocked.
604310 ImpactScope~ChangeContract are complete, but 604310 implementation is blocked until 604250 closes.
604316 Human Approval remains deferred.

Next allowed step:
- `604310` has completed its ImpactScope (`604311`), Overview (`604312`), Logic (`604313`), TestPlan (`604314`), and ChangeContract (`604315`) — see `604310_Index_Scope_D_01_Payment_Confirm_Idempotency.md` for the slice's own status and unresolved decisions.
- **The next required work is schema drift alignment precondition handling** (payment_ledger/confirm_payment physical schema contract, `intent_id` binding, `provider_payment_key` vs `provider_tx_id` naming, undefined `fee_amount` reference risk, confirm_payment compile/dry-run verification) — not `604316` Human Approval directly.
- `604316` Human Approval for `604310` remains deferred until schema drift alignment is closed and every Required Human Decision in `604315` §5 is resolved. It is authored by the Human owner (not Claude, not Codex, not Cursor).
- Codex has no role at this stage. Codex is the restricted Stage 4 implementer and must not draft impact_scope.md, overview.md, logic.md, or any schema-drift-alignment analysis for any Scope D slice — doing so would let the implementer define its own boundary.
- Runtime implementation remains prohibited for `604310` until schema drift alignment closes and `604316` is complete, and for any other future slice (`604320`–`604380`) until that slice repeats the same ImpactScope → Overview → Logic → TestPlan → ChangeContract → Human Approval sequence independently.
