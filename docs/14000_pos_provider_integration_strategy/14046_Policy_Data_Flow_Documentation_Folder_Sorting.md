# 14046_Policy_Data_Flow_Documentation_Folder_Sorting

## 1. Purpose

This document defines the data-flow-based documentation folder reorganization, batch sorting, document cluster alignment, implementation-readiness grouping, and PC-side folder normalization policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined high-velocity Markdown production and batch review control.

This document defines how high-volume Markdown documents should be periodically reorganized according to data flows, not only document numbers.

The project may generate many documents quickly.

If documents are produced in large batches, folder cleanup may be reduced later only if each batch is organized by clear data-flow clusters.

This document does not move files, create folders, implement automation, or change repository structure.

It defines folder reorganization policy only.

---

## 2. Scope

This document covers:

- data-flow-based folder organization
- batch sorting strategy
- document cluster strategy
- source-to-runtime-to-output grouping
- provider flow grouping
- payment flow grouping
- KDS flow grouping
- Mini Kiosk flow grouping
- SaaS and Franchise OS flow grouping
- mobile inbox sorting
- PC import sorting
- implementation backlog extraction support
- no-implementation boundary

This document does not cover:

- final directory tree
- final script-based folder movement
- final index generator
- final code implementation
- final database schema
- final provider adapter implementation
- final UI implementation
- final CI validation

---

## 3. Core Principle

Documents should eventually be organized by how data moves through the system.

The project must follow this rule:

> Document numbers preserve sequence, but folders should support implementation by grouping related data flows, runtime ownership, authority boundaries, and evidence paths.

A folder should help answer:

    Where does this data come from?
    Who validates it?
    Who owns authority?
    Where does it go?
    What evidence is produced?
    What happens when it fails?

---

## 4. Why Data Flow Folders Matter

Numbered documents are useful for creation order.

But implementation requires flow-based grouping.

Examples:

- POS order flow
- payment approval flow
- refund/cancel flow
- KDS ticket flow
- Mini Kiosk session flow
- provider webhook flow
- local daemon flow
- support access flow
- export/report flow
- SaaS billing flow
- Franchise OS governance flow

If folders follow data flows, implementation mapping becomes easier.

---

## 5. Folder Organization Axes

Documents may be organized by these axes:

| Axis | Meaning |
| ---- | ------- |
| Runtime Ownership | POS, KDS, Bridge, Agent, Payment, Support, SaaS |
| Data Flow | order, payment, refund, KDS, support, export, billing |
| Provider Family | Toss, OKPOS, PAYCO, Smartro, KICC, NICE, Hyphen |
| Phase | Phase 1, Phase 2, Phase 3 |
| Security Boundary | secrets, masking, tenant isolation, audit |
| UI Surface | Mini Kiosk, Store Tablet, Owner Dashboard, Support Console |
| Evidence Path | incident, test result, audit, pilot evidence |
| Business Layer | SaaS pricing, franchise billing, pilot conversion |

Folders should support these axes without becoming too fragmented.

---

## 6. Recommended Top-Level Folder Families

Recommended future top-level document families:

    docs/
      00000_foundation/
      04000_runtime_security/
      04500_security_foundation/
      04700_documentation_governance/
      04800_implementation_mapping/
      04900_test_catalog/
      05000_provider_integration/
      05200_mini_kiosk_and_kiosk/
      05300_saas_provider_strategy/
      05400_pilot_saas_pricing_customer_lifecycle/
      05500_mobile_workflow_and_batch_control/
      06000_data_flows/
      07000_ui_surfaces/
      08000_franchise_os_linkage/
      _index/
      _archive/
      _mobile_inbox/

This is a planning recommendation.

Final folder names may be normalized later.

---

## 7. Data Flow Folder Family

Recommended data flow folder family:

    docs/06000_data_flows/

Possible subfolders:

    06010_customer_session_flow/
    06020_order_intent_flow/
    06030_payment_approval_flow/
    06040_refund_cancel_flow/
    06050_pos_provider_event_flow/
    06060_kds_ticket_flow/
    06070_mini_kiosk_flow/
    06080_support_recovery_flow/
    06090_export_report_flow/
    06100_saas_billing_flow/
    06110_franchise_governance_flow/

These folders should eventually collect documents that describe how data moves.

---

## 8. Provider Integration Folder Family

Recommended provider folder family:

    docs/05000_provider_integration/

Possible subfolders:

    provider_register/
    provider_adapters/
    toss/
    okpos/
    payco/
    smartro/
    kicc/
    nice/
    hyphen/
    api_hub/
    local_daemon/
    cloud_open_api/
    hardware_partner/
    provider_tests/
    provider_evidence/

Provider-specific docs should stay close to adapter and evidence docs.

---

## 9. Mini Kiosk And Kiosk Folder Family

Recommended Mini Kiosk folder family:

    docs/05200_mini_kiosk_and_kiosk/

Possible subfolders:

    session_identity/
    payment_flow/
    device_trust/
    customer_ui/
    provider_gateway/
    recovery/
    hardware/
    tests/
    evidence/

Mini Kiosk documents should remain separate from full POS provider docs when they define customer-facing flow.

---

## 10. Pilot And SaaS Folder Family

Recommended SaaS and pilot folder family:

    docs/05400_pilot_saas_pricing_customer_lifecycle/

Possible subfolders:

    pilot_rollout/
    pilot_store_register/
    pilot_evidence_packets/
    pilot_retrospectives/
    paid_conversion/
    customer_success/
    churn_feedback/
    pricing_experiments/
    renewal_exit/
    franchise_signals/

This cluster supports commercial validation and early SaaS learning.

---

## 11. Mobile Workflow Folder Family

Recommended mobile workflow folder family:

    docs/05500_mobile_workflow_and_batch_control/

Possible subfolders:

    mobile_capture/
    pc_import/
    conflict_recovery/
    batch_logs/
    daily_summaries/
    weekly_consolidation/
    inbox_cleanup/
    workflow_index/

This folder should hold workflow policies and future daily batch logs.

---

## 12. UI Surface Folder Family

Recommended UI folder family:

    docs/07000_ui_surfaces/

Possible subfolders:

    store_tablet/
    owner_dashboard/
    support_console/
    mini_kiosk_ui/
    kds_ui/
    provider_status_ui/
    payment_recovery_ui/
    incident_review_ui/
    franchise_hq_dashboard/

UI documents should be organized by screen owner and authority boundary.

---

## 13. Franchise OS Linkage Folder Family

Recommended Franchise OS linkage folder family:

    docs/08000_franchise_os_linkage/

Possible subfolders:

    hq_store_data_flow/
    franchise_billing/
    owner_dashboard/
    store_comparison/
    sop_training/
    menu_governance/
    provider_standardization/
    pilot_to_franchise/
    saas_packaging/
    multi_store_support/

Franchise OS docs should not be mixed with first-store-only operational docs unless they directly define linkage.

---

## 14. Data Flow Sorting Rule

When sorting a document, ask:

1. What data enters the system?
2. What runtime receives it?
3. What validation occurs?
4. What authority boundary applies?
5. What state changes?
6. What evidence is produced?
7. What UI displays it?
8. What support path uses it?
9. What provider is involved?
10. What downstream system consumes it?

The answer determines folder placement.

---

## 15. Primary Folder Rule

Each document should have one primary folder.

The primary folder is determined by the document’s main purpose.

Examples:

- Provider adapter mapping document -> provider integration
- Payment recovery state document -> data flows or payment recovery
- Mini Kiosk session document -> Mini Kiosk folder
- SaaS pricing document -> SaaS pricing folder
- Mobile Git workflow document -> mobile workflow folder
- Franchise OS billing document -> Franchise OS linkage or SaaS billing folder

Avoid copying the same document into multiple folders.

Use index/cross-reference instead.

---

## 16. Cross-Reference Instead Of Duplication

If a document belongs to multiple concerns, keep one primary file and cross-reference it.

Example:

    Payment recovery document:
      primary: data_flows/payment_approval_flow
      references: provider_integration, support_recovery, Mini Kiosk UI

Do not duplicate file under all three folders.

Duplication creates divergence.

---

## 17. Batch Sorting Strategy

High-speed production should be sorted in stages.

### 17.1 Stage 1: Inbox Capture

All new mobile docs enter:

    docs/_mobile_inbox/

### 17.2 Stage 2: Number Range Grouping

Group by number:

    05470~05520 mobile workflow
    05340~05460 SaaS pricing and pilot
    05240~05330 provider strategy

### 17.3 Stage 3: Topic Cluster Sorting

Move to topic folders:

    provider integration
    pilot SaaS
    mobile workflow
    data flows

### 17.4 Stage 4: Data Flow Reclassification

Later, refine by flow:

    payment flow
    KDS flow
    Mini Kiosk flow
    provider event flow

### 17.5 Stage 5: Implementation Mapping

Extract requirements into implementation backlog.

This prevents early over-sorting.

---

## 18. Interim Folder Rule

During rapid drafting, use interim folders.

Examples:

    docs/_mobile_inbox/
    docs/_sorting_pending/
    docs/_review_pending/
    docs/_data_flow_reclass_pending/

Interim folders should be temporary.

They should be cleared during weekly consolidation.

---

## 19. Folder Depth Rule

Avoid excessive folder depth.

Recommended depth:

    docs/[cluster]/[subcluster]/file.md

Avoid:

    docs/[cluster]/[subcluster]/[microtopic]/[phase]/[status]/file.md

Too much depth makes mobile capture and PC review harder.

Use index metadata instead of deep folders.

---

## 20. File Number Preservation

File number must stay unchanged when moved.

Example:

    docs/_mobile_inbox/05520_Data_Flow_Based_Documentation_Folder_Reorganization_And_Batch_Sorting_Policy.md

may move to:

    docs/05500_mobile_workflow_and_batch_control/05520_Data_Flow_Based_Documentation_Folder_Reorganization_And_Batch_Sorting_Policy.md

The number remains 05520.

Folder movement must not imply renumbering.

---

## 21. Data Flow Index

A data flow index should eventually list:

- flow id
- flow name
- source runtime
- target runtime
- documents
- provider dependencies
- UI dependencies
- security dependencies
- test dependencies
- implementation backlog links

Example:

    Flow: PAYMENT_APPROVAL_FLOW
    Source: Mini Kiosk / Provider / POS
    Target: Payment Runtime / Order Handoff / KDS Eligibility
    Docs: 05220, 05350, 05400, 05410
    Tests: 05010, 05070
    Security: 04550, 04590

This supports implementation.

---

## 22. Runtime Ownership Index

Runtime ownership index should group documents by owner:

- POS Runtime
- KDS Runtime
- Bridge Runtime
- Agent Runtime
- Payment Runtime
- Support Runtime
- Provider Gateway
- Mini Kiosk Runtime
- SaaS Billing Runtime
- Franchise OS Runtime

Runtime ownership index helps prevent authority confusion.

---

## 23. Provider Dependency Index

Provider dependency index should list:

- provider
- architecture family
- documents
- phase
- evidence status
- blocker status
- related data flows
- related UI surfaces
- related tests

This connects provider docs to flow docs.

---

## 24. UI Surface Index

UI surface index should list:

- screen
- user role
- data displayed
- actions allowed
- actions prohibited
- source runtime
- evidence produced
- security masking requirement
- related documents

UI must reflect data flow and authority.

---

## 25. Implementation Backlog Index

Implementation backlog index should be extracted later.

It should link:

- document
- section
- requirement
- runtime
- data flow
- UI surface
- provider
- test case
- priority
- phase

Folder organization should make this extraction easier.

---

## 26. Weekly Folder Consolidation

Once per week during high-speed production:

1. pull latest mobile commits
2. review mobile inbox
3. group by document range
4. sort by topic cluster
5. identify data flow cluster
6. move obvious files
7. update minimal index
8. mark pending reclassification
9. check duplicate numbers
10. commit folder consolidation
11. push
12. mobile pulls updated structure

Weekly folder consolidation prevents massive cleanup later.

---

## 27. Mid-Batch Folder Checkpoint

If producing hundreds of documents per day, perform checkpoint after each major cluster.

Examples:

- after provider strategy batch
- after SaaS pricing batch
- after mobile workflow batch
- after UI surface batch
- after data flow batch
- after security expansion batch

Checkpoint should record:

- range produced
- target folder
- pending review
- next range
- likely reclassification

This reduces later chaos.

---

## 28. Folder Move Commit Rule

Folder move commits should be separate from content rewrite when possible.

Good commit examples:

    docs: move mobile workflow policies into workflow cluster
    docs: sort saas pilot policies by lifecycle flow
    docs: organize provider integration docs by provider family
    docs: add data flow folder skeleton for documentation sorting

Avoid mixing:

- file moves
- large content edits
- index rewrite
- implementation changes

Separate moves improve Git history clarity.

---

## 29. Data Flow Folder Skeleton

A future folder skeleton may be created when PC setup is ready.

Suggested skeleton:

    docs/06000_data_flows/
      README.md
      06010_customer_session_flow/
      06020_order_intent_flow/
      06030_payment_approval_flow/
      06040_refund_cancel_flow/
      06050_provider_event_flow/
      06060_kds_ticket_flow/
      06070_mini_kiosk_flow/
      06080_support_recovery_flow/
      06090_export_report_flow/
      06100_saas_billing_flow/
      06110_franchise_governance_flow/

This document only recommends the skeleton.

It does not create it.

---

## 30. Folder Naming Rule

Folder names should be:

- lowercase where practical
- numeric prefix where useful
- English
- underscore-separated
- stable enough for cross-reference
- not too long
- based on data flow or cluster purpose

Avoid:

- vague names
- duplicate folder meanings
- deeply nested temporary folders
- Korean/English mixed folder names for core repo folders
- provider names mixed with data flow unless provider-specific

---

## 31. Folder Reorganization Risks

Risks:

| Risk | Description |
| ---- | ----------- |
| Broken References | documents point to old paths |
| Duplicate Copies | move creates copy and old file remains |
| Mobile Stale Path | mobile continues editing old folder |
| Index Drift | index does not match moved files |
| Git Conflict | mobile and PC touch same file |
| Lost Draft | file deleted during move |
| Topic Misclassification | document placed in wrong cluster |
| Over-Sorting | folders become too fragmented |
| Under-Sorting | inbox becomes unmanageable |

Risks must be handled through batch commits and pull/push discipline.

---

## 32. Reorganization Mitigation

Mitigations:

- move files on PC only
- commit before large move
- move in batches
- keep document numbers stable
- update minimal index
- do not delete duplicates blindly
- mobile pulls after PC move
- use temporary pending folders
- cross-reference instead of duplicate
- track unresolved placement

Folder cleanup should improve clarity, not create stress.

---

## 33. When To Reorganize

Reorganize folders when:

- a topic cluster reaches 10 to 20 documents
- a data flow becomes clear
- mobile inbox exceeds manageable size
- implementation mapping is about to begin
- duplicate topics appear
- provider documents split by family
- UI documents begin
- SaaS lifecycle documents grow
- Franchise OS linkage documents begin

Do not reorganize after every single document.

Batch reorganization is better.

---

## 34. When Not To Reorganize

Do not reorganize when:

- mobile has unpushed work
- PC has uncommitted conflicting changes
- document generation is mid-stream
- folder purpose is unclear
- index cannot be updated later
- reorganization would delay urgent document capture
- same file is open and edited on mobile
- large implementation changes are staged

Capture first.

Normalize later.

---

## 35. Data Flow Reclassification Status

Recommended statuses:

- `UNCLASSIFIED`
- `TOPIC_SORTED`
- `FLOW_CANDIDATE`
- `FLOW_ASSIGNED`
- `FLOW_INDEXED`
- `RUNTIME_OWNER_ASSIGNED`
- `IMPLEMENTATION_MAPPING_READY`
- `RECLASSIFICATION_PENDING`
- `SUPERSEDED`
- `ARCHIVED`

These statuses may be used later in index.

---

## 36. Anti-Patterns

The following are prohibited:

- sorting only by document number forever
- over-sorting before data flow is understood
- duplicating documents into multiple folders
- moving files on mobile during active sync phase
- renumbering documents because folder changed
- creating deeply nested folder paths too early
- leaving mobile inbox unmanaged
- mixing folder moves with implementation changes
- deleting old versions without duplicate review
- using folders as substitute for index
- ignoring data flow when extracting backlog
- letting UI docs drift away from runtime data flow

---

## 37. Non-Goals

This document does not define:

- final folder tree
- final index schema
- final data flow catalog
- final automation
- final implementation backlog
- final CI validation
- final UI specification
- final provider adapter structure

Those belong to later PC-side repository governance and implementation planning.

---

## 38. Readiness Check

This document is ready when the project can answer:

1. Why should folders follow data flows?
2. What folder organization axes exist?
3. What top-level folder families are recommended?
4. What data flow folder family is recommended?
5. What provider folder family is recommended?
6. What Mini Kiosk folder family is recommended?
7. What SaaS/pilot folder family is recommended?
8. What mobile workflow folder family is recommended?
9. What UI surface folder family is recommended?
10. What Franchise OS linkage folder family is recommended?
11. How is a document sorted by data flow?
12. What is the primary folder rule?
13. Why use cross-reference instead of duplication?
14. What batch sorting strategy applies?
15. What interim folder rule applies?
16. What folder depth rule applies?
17. How is file number preserved?
18. What is data flow index?
19. What is runtime ownership index?
20. What is provider dependency index?
21. What is UI surface index?
22. What is implementation backlog index?
23. What weekly consolidation applies?
24. What mid-batch checkpoint applies?
25. What folder move commit rule applies?
26. When should folders be reorganized?
27. When should folders not be reorganized?
28. What anti-patterns are prohibited?

If these questions cannot be answered, data-flow-based documentation folder organization is incomplete.

---

## 39. Conclusion

High-speed Markdown production should be combined with periodic data-flow-based folder organization.

The safe approach is:

    Produce many docs quickly
        -> store in mobile inbox
        -> pull on PC
        -> sort by topic cluster
        -> later reclassify by data flow
        -> update index
        -> extract implementation backlog from flow-aligned docs

Document numbers preserve creation sequence.

Folders should support implementation flow.

Indexes should connect cross-cutting concerns.

This document ensures that large-scale Markdown production remains usable for future implementation, UI development, provider integration, SaaS rollout, and Franchise OS linkage.