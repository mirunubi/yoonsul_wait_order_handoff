# 064300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md

## 1. Document Control

| Field | Value |
|---|---|
| Document Number | 64300 |
| DocumentType | Checklist |
| Band | 64000 Runtime Flow Bundle Registry |
| System | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Scope | Flow Bundle code handoff readiness gate |
| Primary Audience | Product Owner, Tech Lead, Claude Code Operator, Cursor Operator, QA Lead, Security/Audit Owner |
| Status | Draft |
| Created | 2026-06-17 |
| Naming Rule | Number + DocumentType Prefix + Title |

## 2. Purpose

This checklist defines the minimum readiness gate before any Runtime Flow Bundle is handed off to Claude Code, Cursor, or a human developer for code modification.

The project no longer treats a single Markdown file as a direct implementation unit. A code change may proceed only after the target flow has been mapped through:

1. MD Dependency Graph
2. Runtime Flow Diagram
3. Module Impact Map
4. Test Coverage Map
5. Evidence Collection Plan

This checklist prevents accidental single-file coding, undocumented coupling, unsafe payment changes, broken audit trails, and AI-driven modification of restricted financial/security areas.

## 3. Governing Principle

Implementation must follow this order:

```text
Flow Step → Module → File → Test → Evidence
```

A code change must not begin from an isolated file, isolated bug description, or isolated Cursor prompt.

## 4. Applicable Flow Bundle Documents

| Flow Bundle | Required Before Handoff | Status Column Owner |
|---|---:|---|
| 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Yes | Tech Lead / Audit Owner |
| 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Yes | Tech Lead / Audit Owner |
| 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Yes | Tech Lead / QA Lead |
| 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Yes | Tech Lead / Store Runtime Owner |
| 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Yes | Security Owner / Integration Owner |
| 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Yes | Settlement Owner / Audit Owner |
| 064200_Matrix_Flow_To_MD_Dependency_Graph.md | Yes | Documentation Owner |
| 064210_Matrix_Flow_To_Module_Implementation_Map.md | Yes | Tech Lead |
| 064220_Matrix_Flow_To_Test_Coverage_Map.md | Yes | QA Lead |

## 5. Code Handoff Gate Summary

| Gate | Required Result | Pass/Fail |
|---|---|---|
| G1. Flow Bundle identified | Exact 641xx flow file selected |  |
| G2. Flow scope bounded | Included/excluded flow steps listed |  |
| G3. MD dependency graph attached | Relevant policies, SOPs, WorkPackages, audit docs mapped |  |
| G4. Runtime flow diagram attached | Runtime actors, queues, ledgers, callbacks, failure paths mapped |  |
| G5. Module impact map attached | Affected modules and non-affected modules listed |  |
| G6. File impact candidate list prepared | Candidate code/config/test files listed before edit |  |
| G7. Test coverage map attached | Unit, integration, contract, failure, replay, audit tests mapped |  |
| G8. Evidence plan attached | Log, ledger, reconciliation, export, screenshot, report evidence listed |  |
| G9. Restricted area review completed | Payment/settlement/security/migration/secrets/deploy risk reviewed |  |
| G10. Human approval recorded | Required owner approval captured before code modification |  |

No code handoff is permitted unless every gate is marked Pass or formally waived by the responsible owner.

## 6. Restricted AI Modification Areas

Claude Code and Cursor may assist with analysis, scaffolding, test proposal, refactoring suggestions, and local non-critical implementation work.

They must not independently modify or deploy the following areas:

| Restricted Area | AI Role | Required Human Control |
|---|---|---|
| Payment approval execution | Suggest only | Tech Lead + Payment Owner approval |
| Cancel/refund execution | Suggest only | Tech Lead + Settlement Owner approval |
| PG/VAN credential handling | No direct modification | Security Owner approval |
| Secret rotation and storage | No direct modification | Security Owner approval |
| DB migration affecting financial ledgers | Suggest migration draft only | DBA/Tech Lead approval and rollback plan |
| Settlement calculation | Suggest tests and review notes only | Settlement Owner approval |
| Audit ledger immutability | Suggest verification only | Audit Owner approval |
| Reconciliation rules | Suggest diff analysis only | Audit Owner + Settlement Owner approval |
| Production deployment | No autonomous deployment | Release Manager approval |
| Incident recovery replay | Suggest runbook steps only | Incident Commander approval |

## 7. Required Handoff Packet

Before coding begins, the handoff packet must include:

```text
/HandoffPacket
  /01_FlowBundle
    - selected_641xx_flow_document.md
    - flow_scope_note.md
  /02_DependencyGraph
    - md_dependency_graph.md
    - linked_policy_sop_workpackage_list.md
  /03_RuntimeDiagram
    - runtime_flow_diagram.md
    - failure_path_diagram.md
  /04_ModuleImpact
    - module_impact_map.md
    - file_candidate_list.md
  /05_TestCoverage
    - test_coverage_map.md
    - required_test_case_list.md
  /06_EvidencePlan
    - evidence_collection_plan.md
    - audit_packet_template.md
  /07_Approval
    - owner_approval_record.md
    - restricted_area_review.md
```

The packet may be represented as actual files, a PR template, or a tracked issue bundle, but the content must be complete.

## 8. Flow Scope Confirmation Checklist

| Item | Check |
|---|---|
| The exact Flow Bundle number is specified. |  |
| The business trigger is specified. |  |
| The runtime entry point is specified. |  |
| The terminal state is specified. |  |
| Happy path and failure path are both included. |  |
| External systems are listed. |  |
| Internal ledgers are listed. |  |
| Idempotency boundary is specified. |  |
| Retry and replay boundary is specified. |  |
| Audit evidence boundary is specified. |  |
| Out-of-scope items are explicitly listed. |  |

## 9. MD Dependency Graph Checklist

| Item | Check |
|---|---|
| Related policy documents are listed. |  |
| Related SOP documents are listed. |  |
| Related WorkPackage documents are listed. |  |
| Related audit/governance documents are listed. |  |
| Conflicting or overlapping MD files are identified. |  |
| Missing MD documents are logged as backlog candidates. |  |
| System SOP references use 50000~99999 numbering. |  |
| Operation SOP references use 00010~49999 numbering. |  |
| Cross-links are planned in both directions. |  |

## 10. Runtime Flow Diagram Checklist

| Item | Check |
|---|---|
| Runtime actors are shown. |  |
| POS/PG/VAN boundary is shown. |  |
| Gateway boundary is shown. |  |
| Queue/DLQ/replay boundary is shown where applicable. |  |
| Ledger write sequence is shown. |  |
| Audit event creation point is shown. |  |
| Customer/store visible state transition is shown where applicable. |  |
| Failure and timeout states are shown. |  |
| Manual intervention path is shown. |  |
| Evidence generation point is shown. |  |

## 11. Module Impact Map Checklist

| Item | Check |
|---|---|
| Affected modules are listed. |  |
| Non-affected modules are listed to prevent over-editing. |  |
| Shared utility modules are identified. |  |
| Ledger modules are identified. |  |
| Adapter modules are identified. |  |
| API/controller modules are identified. |  |
| Worker/queue modules are identified. |  |
| Admin/console modules are identified where applicable. |  |
| Evidence/export modules are identified. |  |
| Config/secret/migration touchpoints are flagged. |  |

## 12. File Impact Candidate Checklist

Before Claude Code or Cursor changes files, the operator must prepare a candidate list.

| File Category | Required Review |
|---|---|
| API route/controller files | Yes |
| Domain service files | Yes |
| Adapter/provider files | Yes |
| Queue/worker files | Yes |
| Ledger/repository files | Yes |
| Schema/migration files | Restricted review |
| Config/env/secret files | Restricted review |
| Test files | Yes |
| Audit/evidence templates | Yes |
| Deployment/CI files | Restricted review |

Any file added outside the candidate list must be explained in the PR or implementation record.

## 13. Test Coverage Checklist

| Test Layer | Required For Payment/Settlement Flow | Check |
|---|---:|---|
| Unit test | Yes |  |
| Integration test | Yes |  |
| Contract test with POS/PG/VAN adapter mock | Yes |  |
| Idempotency test | Yes |  |
| Timeout test | Yes |  |
| Retry test | Yes |  |
| DLQ test | Conditional |  |
| Replay test | Conditional |  |
| Ledger consistency test | Yes |  |
| Reconciliation test | Yes |  |
| Audit event test | Yes |  |
| Evidence export test | Yes |  |
| Security signature/credential test | Conditional |  |
| Migration rollback test | Conditional |  |

## 14. Evidence Checklist

| Evidence Type | Required | Check |
|---|---:|---|
| Flow bundle ID captured in implementation note | Yes |  |
| Commit/PR reference captured | Yes |  |
| Test result captured | Yes |  |
| Ledger before/after sample captured | Yes for ledger changes |  |
| Audit event sample captured | Yes |  |
| Reconciliation result captured | Yes for settlement/recon flows |  |
| Failure-path execution evidence captured | Yes |  |
| Replay/DLQ evidence captured | Conditional |  |
| Security validation evidence captured | Conditional |  |
| Human approval record captured | Yes |  |
| Release note captured | Yes if deployed |  |

## 15. Claude Code Handoff Rules

Claude Code may be used only after this checklist is satisfied.

### 15.1 Allowed Claude Code Tasks

- Generate implementation plan from Flow Bundle packet
- Locate candidate files from module map
- Propose code changes within approved file list
- Write or update tests
- Produce diff summary
- Produce risk notes
- Produce evidence checklist draft

### 15.2 Prohibited Claude Code Tasks Without Human Approval

- Modify payment approval semantics
- Modify settlement calculation rules
- Modify audit immutability logic
- Modify secrets, credentials, or signing keys
- Run or apply DB migrations affecting financial ledgers
- Deploy to production
- Execute replay against production data
- Disable tests, guards, or validation gates

## 16. Cursor Handoff Rules

Cursor is an IDE-level assistant, not the Flow Bundle implementation authority.

Cursor may be used for:

- Local file navigation
- Small refactors inside approved file list
- Test file generation
- Type correction
- Documentation cross-link patching
- Diff review assistance

Cursor must not be instructed with a vague prompt such as:

```text
Fix POS gateway approval flow.
```

Cursor prompts must include:

```text
Flow Bundle: 641xx
Approved modules: ...
Approved files: ...
Required tests: ...
Restricted files: ...
Do not modify: ...
Evidence required: ...
```

## 17. Pull Request Template Requirements

Every PR created from a Flow Bundle implementation must include:

```text
Flow Bundle ID:
Related MD Documents:
Runtime Flow Steps Changed:
Modules Changed:
Files Changed:
Tests Added/Updated:
Restricted Area Review:
Evidence Attached:
Rollback Plan:
Human Approvals:
```

A PR without Flow Bundle ID must be rejected for POS/PG/VAN/payment/settlement/audit/security related changes.

## 18. Waiver Rule

A gate may be waived only when all of the following are recorded:

| Waiver Field | Required |
|---|---:|
| Gate ID | Yes |
| Reason | Yes |
| Risk | Yes |
| Compensating control | Yes |
| Expiration or follow-up date | Yes |
| Approver | Yes |

Permanent waiver is not allowed for payment, settlement, audit, security, migration, secret, or production deployment controls.

## 19. Minimum Done Definition

A Flow Bundle implementation is not done when code compiles.

It is done only when:

1. Flow steps are implemented or explicitly deferred.
2. Module and file changes match the approved map.
3. Required tests pass.
4. Failure paths are tested.
5. Ledger/audit evidence is captured.
6. Restricted area approvals are recorded.
7. Rollback path exists.
8. Documentation cross-links are updated.
9. Evidence packet is stored or referenced.

## 20. Related Documents

| Document | Relationship |
|---|---|
| 064000_Index_Runtime_Flow_Bundle_Registry.md | Parent registry |
| 064100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Approval and reconciliation flow |
| 064110_Flow_POS_Gateway_Cancel_Refund_Recovery_And_Audit.md | Cancel/refund recovery flow |
| 064120_Flow_POS_Gateway_Timeout_Retry_DLQ_And_Replay.md | Timeout/retry/DLQ/replay flow |
| 064130_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md | Offline local ledger and resync flow |
| 064140_Flow_POS_Gateway_Webhook_Inbound_Verification_And_Event_Normalization.md | Webhook verification and normalization flow |
| 064150_Flow_POS_Gateway_Settlement_Dispute_And_Evidence_Export.md | Settlement/dispute/evidence export flow |
| 064200_Matrix_Flow_To_MD_Dependency_Graph.md | Dependency graph matrix |
| 064210_Matrix_Flow_To_Module_Implementation_Map.md | Module implementation map |
| 064220_Matrix_Flow_To_Test_Coverage_Map.md | Test coverage map |

## 21. Next Recommended Documents

| Next Number | Candidate File | Purpose |
|---:|---|---|
| 64310 | 064310_Template_Flow_Bundle_Claude_Code_Handoff_Prompt.md | Standard prompt template for Claude Code handoff |
| 64320 | 64320_Template_Flow_Bundle_Cursor_Local_Edit_Guardrail.md | Cursor-safe local edit instruction template |
| 64330 | 64330_Evidence_Flow_Bundle_Implementation_Result_Packet_Template.md | Evidence packet template after implementation |
| 64340 | 64340_Register_Flow_Bundle_Implementation_Risk_And_Waiver_Log.md | Risk and waiver register |

## 22. Final Control Statement

For CatchMenu-Catch&Order, POS/PG/VAN/payment/settlement/audit/security implementation must be controlled at Flow Bundle level.

A single Markdown document may define a policy, SOP, contract, or evidence rule, but it must not be treated as a direct code implementation unit.

The implementation authority is the approved Flow Bundle packet, not an isolated file.
