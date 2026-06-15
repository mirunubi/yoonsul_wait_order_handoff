# 14048_Matrix_Data_Flow_Runtime_Ownership_Implementation_Extraction

## 1. Purpose

This document defines the data flow index, runtime ownership matrix, provider dependency mapping, UI surface linkage, test linkage, and implementation extraction matrix policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined data-flow-based folder organization and batch sorting.

This document defines how documents should be indexed across:

- data flow
- runtime owner
- provider dependency
- UI surface
- evidence path
- test requirement
- implementation backlog item
- phase
- priority

The purpose is to make high-volume Markdown documentation usable for future implementation.

This document does not create the actual index, implement automation, generate backlog items, or modify repository files.

It defines the indexing and extraction policy only.

---

## 2. Scope

This document covers:

- data flow index
- runtime ownership matrix
- provider dependency matrix
- UI surface matrix
- evidence path matrix
- test linkage matrix
- implementation extraction matrix
- document-to-backlog mapping
- phase and priority tagging
- readiness status tracking
- no-implementation boundary

This document does not cover:

- final database schema
- final index generator
- final implementation backlog tool
- final project management system
- final CI validation
- final UI implementation
- final provider adapter implementation
- final production release workflow

---

## 3. Core Principle

A document becomes implementation-useful only when its flow, owner, dependency, test, and backlog implications are visible.

The project must follow this rule:

> Markdown documents should not remain isolated files. Each important document must eventually be connected to a data flow, runtime owner, provider dependency, UI surface, evidence path, test requirement, and implementation extraction record.

Documentation volume alone does not create readiness.

Traceable mapping creates readiness.

---

## 4. Why Matrix Indexing Is Required

The project will contain many documents.

A simple folder tree cannot answer everything.

Implementation requires questions such as:

- Which documents affect payment approval?
- Which documents affect KDS ticket creation?
- Which documents define Mini Kiosk session state?
- Which provider docs affect Toss?
- Which documents require security tests?
- Which UI surfaces display payment uncertainty?
- Which documents produce implementation backlog items?
- Which documents are Phase 1 blockers?
- Which documents are deferred to Phase 2 or Phase 3?

A matrix index allows the project to answer these questions.

---

## 5. Matrix Index Families

Recommended matrix families:

| Matrix | Purpose |
| ------ | ------- |
| Data Flow Index | maps documents to system data flows |
| Runtime Ownership Matrix | maps documents to runtime authority owner |
| Provider Dependency Matrix | maps documents to provider family |
| UI Surface Matrix | maps documents to screens and roles |
| Evidence Path Matrix | maps documents to audit/evidence output |
| Test Linkage Matrix | maps documents to required tests |
| Implementation Extraction Matrix | maps reviewed documents to backlog items |
| Phase Matrix | maps documents to Phase 1, 2, 3, or deferred |
| Priority Matrix | maps documents to P0~P6 priority |

These matrices may be separate files or sections in an index.

---

## 6. Data Flow Index

The Data Flow Index should map each document to one or more data flows.

Recommended fields:

- flow id
- flow name
- source runtime
- target runtime
- document number
- document title
- primary or secondary relevance
- input data
- output data
- state transition
- failure mode
- evidence produced
- related tests
- implementation impact
- status

Example data flow ids:

- `CUSTOMER_SESSION_FLOW`
- `ORDER_INTENT_FLOW`
- `PAYMENT_APPROVAL_FLOW`
- `REFUND_CANCEL_FLOW`
- `PROVIDER_EVENT_FLOW`
- `LOCAL_DAEMON_FLOW`
- `KDS_TICKET_FLOW`
- `MINI_KIOSK_FLOW`
- `SUPPORT_RECOVERY_FLOW`
- `EXPORT_REPORT_FLOW`
- `SAAS_BILLING_FLOW`
- `FRANCHISE_GOVERNANCE_FLOW`

---

## 7. Runtime Ownership Matrix

The Runtime Ownership Matrix should identify who owns truth and authority.

Recommended runtime owners:

- `CUSTOMER_SESSION_RUNTIME`
- `MINI_KIOSK_RUNTIME`
- `POS_RUNTIME`
- `PAYMENT_RUNTIME`
- `PROVIDER_GATEWAY_RUNTIME`
- `KDS_RUNTIME`
- `KDS_BRIDGE_RUNTIME`
- `LOCAL_AGENT_RUNTIME`
- `SUPPORT_RUNTIME`
- `AUDIT_RUNTIME`
- `EXPORT_RUNTIME`
- `SAAS_BILLING_RUNTIME`
- `FRANCHISE_OS_RUNTIME`
- `SECURITY_RUNTIME`

Recommended fields:

- runtime owner
- document number
- document title
- authority type
- allowed action
- prohibited action
- state owned
- state observed
- evidence responsibility
- implementation implication
- test implication

This prevents authority confusion.

---

## 8. Authority Type Values

Recommended authority type values:

- `SOURCE_OF_TRUTH`
- `VALIDATION_AUTHORITY`
- `OBSERVATION_ONLY`
- `RECOMMENDATION_ONLY`
- `DISPLAY_ONLY`
- `EXECUTION_AUTHORITY`
- `PAYMENT_AUTHORITY`
- `KITCHEN_EXECUTION_AUTHORITY`
- `SUPPORT_REVIEW_AUTHORITY`
- `AUDIT_RECORD_AUTHORITY`
- `EXPORT_AUTHORITY`
- `BILLING_AUTHORITY`
- `GOVERNANCE_AUTHORITY`

Rules:

- recommendation is not execution
- observation is not authority
- payment signal is not payment truth
- provider event is not Yoonsul truth until validated
- UI display is not runtime ownership
- evidence is not approval

---

## 9. Provider Dependency Matrix

The Provider Dependency Matrix should map documents to providers and provider families.

Recommended provider families:

- `TOSS`
- `OKPOS`
- `PAYCO`
- `SMARTRO`
- `KICC`
- `NICE`
- `IMU`
- `HYPHEN`
- `MINOR_POS`
- `HARDWARE_PARTNER`
- `API_HUB`
- `LOCAL_DAEMON`
- `CLOUD_OPEN_API`
- `PAYMENT_GATEWAY`
- `VAN_PROVIDER`
- `KIOSK_VENDOR`

Recommended fields:

- provider
- architecture family
- document number
- document title
- dependency type
- phase
- evidence status
- blocker status
- related data flow
- related runtime owner
- related tests
- implementation readiness

Provider mapping protects the project from uncontrolled provider expansion.

---

## 10. Provider Dependency Type Values

Recommended values:

- `PRIMARY_BASE`
- `REQUIRED_COMPATIBILITY`
- `SECONDARY_CHANNEL`
- `PHASE2_CANDIDATE`
- `PHASE3_ECOSYSTEM`
- `EVIDENCE_ONLY`
- `TEST_ONLY`
- `DEFERRED`
- `BLOCKED`
- `REJECTED_FOR_NOW`

Current strategic defaults:

| Provider | Dependency Type |
| -------- | --------------- |
| Toss | PRIMARY_BASE |
| OKPOS | REQUIRED_COMPATIBILITY |
| PAYCO | SECONDARY_CHANNEL |
| Smartro | PHASE2_CANDIDATE |
| KICC | PHASE2_CANDIDATE |
| NICE | PHASE2_CANDIDATE |
| I'M U | PHASE2_CANDIDATE |
| Hyphen | PHASE2_CANDIDATE |
| Minor POS | PHASE3_ECOSYSTEM |
| Hardware Partner | PHASE3_ECOSYSTEM |

---

## 11. UI Surface Matrix

The UI Surface Matrix should map documents to UI screens and user roles.

Recommended UI surfaces:

- `MINI_KIOSK_CUSTOMER_UI`
- `STORE_TABLET_UI`
- `KDS_UI`
- `OWNER_DASHBOARD_UI`
- `SUPPORT_CONSOLE_UI`
- `PROVIDER_STATUS_UI`
- `PAYMENT_RECOVERY_UI`
- `INCIDENT_REVIEW_UI`
- `FRANCHISE_HQ_DASHBOARD_UI`
- `MOBILE_STAFF_UI`
- `ADMIN_CONFIGURATION_UI`

Recommended fields:

- UI surface
- user role
- document number
- document title
- data displayed
- action allowed
- action prohibited
- masking requirement
- state source
- evidence created
- related runtime owner
- related data flow
- implementation status

UI must follow runtime authority.

---

## 12. UI Action Classification

Recommended UI action classes:

- `VIEW_ONLY`
- `CREATE_INTENT`
- `REQUEST_ACTION`
- `CONFIRM_REVIEW`
- `ESCALATE`
- `ANNOTATE`
- `EXPORT_REQUEST`
- `SUPPORT_REVIEW`
- `CONFIGURE`
- `APPROVE`
- `BLOCKED_ACTION`

Rules:

- customer UI cannot approve payment truth
- support UI cannot silently mutate runtime truth
- owner dashboard cannot override payment state without authorized workflow
- KDS UI controls kitchen execution only within KDS authority
- Mini Kiosk can create order intent, not payment truth
- provider status UI displays provider state, not provider authority transfer

---

## 13. Evidence Path Matrix

The Evidence Path Matrix should map documents to evidence outputs.

Recommended evidence paths:

- `AUDIT_EVENT`
- `PROVIDER_EVENT_EVIDENCE`
- `PAYMENT_EVIDENCE`
- `REFUND_CANCEL_EVIDENCE`
- `KDS_TICKET_EVIDENCE`
- `MINI_KIOSK_SESSION_EVIDENCE`
- `SUPPORT_CASE_EVIDENCE`
- `PILOT_EVIDENCE_PACKET`
- `TEST_RESULT_EVIDENCE`
- `EXPORT_APPROVAL_EVIDENCE`
- `SECURITY_INCIDENT_EVIDENCE`
- `BILLING_DECISION_EVIDENCE`
- `FRANCHISE_GOVERNANCE_EVIDENCE`

Recommended fields:

- evidence path
- source document
- source runtime
- event type
- masking rule
- retention rule
- authority boundary
- review owner
- related test
- implementation implication

Evidence path is essential for auditability.

---

## 14. Test Linkage Matrix

The Test Linkage Matrix should map documents to required tests.

Recommended test families:

- `SECURITY_TEST`
- `RLS_ACCESS_TEST`
- `IDEMPOTENCY_TEST`
- `WEBHOOK_SIGNATURE_TEST`
- `REPLAY_TEST`
- `DUPLICATE_EVENT_TEST`
- `PAYMENT_UNCERTAINTY_TEST`
- `REFUND_CANCEL_TEST`
- `KDS_DUPLICATE_TICKET_TEST`
- `MINI_KIOSK_SESSION_TEST`
- `SUPPORT_MASKING_TEST`
- `EXPORT_APPROVAL_TEST`
- `PROVIDER_FAILURE_TEST`
- `LOCAL_DAEMON_TIMEOUT_TEST`
- `PILOT_EVIDENCE_TEST`
- `UI_AUTHORITY_TEST`
- `BILLING_LIFECYCLE_TEST`

Recommended fields:

- test id
- test family
- source document
- risk covered
- expected result
- failure condition
- evidence required
- priority
- phase
- implementation dependency

Test linkage prevents policy from remaining unverified.

---

## 15. Implementation Extraction Matrix

The Implementation Extraction Matrix should turn reviewed docs into backlog items.

Recommended fields:

- extraction id
- source document
- section reference
- requirement summary
- runtime owner
- data flow
- provider dependency
- UI surface
- evidence path
- test requirement
- security impact
- phase
- priority
- implementation status
- deferred reason
- owner

Extraction should occur only after review.

Do not implement directly from unreviewed draft.

---

## 16. Extraction ID Format

Recommended format:

    IMPL-EXTRACT-[DOCUMENT-NUMBER]-[NUMBER]

Examples:

    IMPL-EXTRACT-05530-001
    IMPL-EXTRACT-05290-003
    IMPL-EXTRACT-05420-002

Alternative flow-based format:

    IMPL-[FLOW-ID]-[NUMBER]

Examples:

    IMPL-PAYMENT_APPROVAL_FLOW-001
    IMPL-KDS_TICKET_FLOW-002

Final format may be normalized later.

---

## 17. Implementation Status Values

Recommended values:

- `NOT_EXTRACTED`
- `EXTRACTION_PENDING`
- `EXTRACTED`
- `BACKLOG_DRAFT`
- `BACKLOG_REVIEWED`
- `READY_FOR_IMPLEMENTATION`
- `BLOCKED`
- `DEFERRED`
- `IMPLEMENTED`
- `TESTED`
- `SUPERSEDED`
- `REJECTED`

During documentation sprint, most items should remain `NOT_EXTRACTED` or `EXTRACTION_PENDING`.

---

## 18. Phase Matrix

The Phase Matrix should classify each document or backlog item.

Recommended phase values:

- `PHASE_0_DOCUMENTATION`
- `PHASE_1_MVP_CORE`
- `PHASE_1_PROVIDER_BASE`
- `PHASE_1_SECURITY_REQUIRED`
- `PHASE_1_UI_REQUIRED`
- `PHASE_1_PILOT_REQUIRED`
- `PHASE_2_PROVIDER_EXPANSION`
- `PHASE_2_SAAS_EXPANSION`
- `PHASE_3_FRANCHISE_OS`
- `PHASE_3_HARDWARE_ECOSYSTEM`
- `DEFERRED`
- `REJECTED`

Phase prevents uncontrolled implementation.

---

## 19. Priority Matrix

Recommended priority values:

- `P0_CRITICAL_SECURITY`
- `P1_IMPLEMENTATION_BLOCKER`
- `P2_PHASE1_REQUIRED`
- `P3_PHASE2_REQUIRED`
- `P4_STRATEGIC`
- `P5_DEFERRED`
- `P6_ARCHIVE`

Priority should consider:

- security risk
- payment risk
- KDS risk
- provider blocker
- pilot readiness
- SaaS revenue relevance
- Franchise OS timing
- implementation dependency

Not all documents are equally urgent.

---

## 20. Document Matrix Record

Each important document may eventually have a matrix record.

Recommended fields:

    Document Number:
    Document Title:
    File Path:
    Primary Folder:
    Document Status:
    Primary Data Flow:
    Secondary Data Flows:
    Runtime Owner:
    Provider Dependencies:
    UI Surfaces:
    Evidence Paths:
    Test Families:
    Phase:
    Priority:
    Implementation Extraction Status:
    Related Documents:
    Superseded By:
    Notes:

This can be stored in an index file or spreadsheet later.

---

## 21. Matrix Status Values

Recommended matrix status values:

- `UNMAPPED`
- `PARTIALLY_MAPPED`
- `FLOW_MAPPED`
- `OWNER_MAPPED`
- `PROVIDER_MAPPED`
- `UI_MAPPED`
- `TEST_MAPPED`
- `EXTRACTION_READY`
- `EXTRACTED`
- `REVIEWED`
- `SUPERSEDED`
- `ARCHIVED`

Mapping can be progressive.

Do not require full mapping during first draft generation.

---

## 22. Progressive Mapping Rule

High-volume documents should be mapped progressively.

### 22.1 First Pass

- document number
- title
- path
- status

### 22.2 Second Pass

- primary folder
- primary data flow
- runtime owner

### 22.3 Third Pass

- provider dependency
- UI surface
- evidence path

### 22.4 Fourth Pass

- test family
- phase
- priority

### 22.5 Fifth Pass

- implementation extraction

This prevents index work from stopping document production.

---

## 23. Matrix Review Cadence

Recommended cadence:

| Cadence | Work |
| ------- | ---- |
| Daily | minimal index update for new docs |
| Twice Weekly | data flow and folder mapping |
| Weekly | runtime owner and provider mapping |
| Weekly | duplicate and superseded review |
| Biweekly | implementation extraction review |
| Monthly | phase and priority recalibration |

Cadence may adjust based on document volume.

---

## 24. Data Flow To Runtime Rule

Each data flow must have runtime owner mapping.

Examples:

| Data Flow | Runtime Owner |
| --------- | ------------- |
| ORDER_INTENT_FLOW | Mini Kiosk Runtime / POS Runtime |
| PAYMENT_APPROVAL_FLOW | Payment Runtime |
| REFUND_CANCEL_FLOW | Payment Runtime / Support Runtime |
| PROVIDER_EVENT_FLOW | Provider Gateway Runtime |
| LOCAL_DAEMON_FLOW | Provider Gateway Runtime / Local Agent Runtime |
| KDS_TICKET_FLOW | KDS Runtime |
| SUPPORT_RECOVERY_FLOW | Support Runtime |
| SAAS_BILLING_FLOW | SaaS Billing Runtime |
| FRANCHISE_GOVERNANCE_FLOW | Franchise OS Runtime |

If runtime owner is unclear, implementation must pause.

---

## 25. Runtime To UI Rule

Each runtime state exposed to users should map to UI surface.

Examples:

| Runtime State | UI Surface |
| ------------- | ---------- |
| Payment uncertainty | Payment Recovery UI / Support Console |
| KDS delay | KDS UI / Owner Dashboard |
| Provider failure | Provider Status UI / Support Console |
| Mini Kiosk session timeout | Mini Kiosk Customer UI / Support Console |
| Pilot incident | Incident Review UI |
| SaaS billing change | Admin Configuration UI / Owner Dashboard |
| Franchise store comparison | Franchise HQ Dashboard |

UI must not create unowned states.

---

## 26. Provider To Test Rule

Each provider dependency should map to tests.

Examples:

| Provider | Required Test |
| -------- | ------------- |
| Toss | webhook signature, idempotency, replay, rate limit |
| OKPOS | local daemon timeout, duplicate order, POS unavailable |
| PAYCO | reservation vs approval, callback validation, refund/cancel |
| Smartro | local agent timeout, table order timing |
| KICC | VAN approval, net cancel, terminal mismatch |
| NICE | payment approval, firewall/allowlist, settlement |
| Hyphen | hub/downstream mismatch, abstraction evidence |

Provider dependency without test mapping is not implementation-ready.

---

## 27. Evidence To Test Rule

Every evidence path should have at least one test or review method.

Examples:

- payment evidence -> payment uncertainty test
- KDS evidence -> duplicate ticket test
- support evidence -> masking and scoped session test
- export evidence -> export approval test
- pilot evidence -> evidence packet completeness review
- billing evidence -> lifecycle decision review

Evidence without verification is weak.

---

## 28. Extraction Gate

A document may enter implementation extraction only when:

1. document is complete
2. document number is stable
3. folder is assigned
4. primary data flow is known
5. runtime owner is known
6. security impact is reviewed
7. test implication is identified
8. phase is assigned
9. priority is assigned
10. no major contradiction remains

Draft documents should not bypass this gate.

---

## 29. Implementation Backlog Anti-Creep Rule

Not every document becomes backlog.

Documents may be:

- policy only
- strategy only
- deferred
- evidence template
- index
- readiness checklist
- implementation source
- test source
- support source
- UI source
- archive

Backlog extraction should be selective.

---

## 30. Matrix Storage Recommendation

Recommended future files:

    docs/_index/
      Document_Master_Index.md
      Data_Flow_Index.md
      Runtime_Ownership_Matrix.md
      Provider_Dependency_Matrix.md
      UI_Surface_Matrix.md
      Evidence_Path_Matrix.md
      Test_Linkage_Matrix.md
      Implementation_Extraction_Matrix.md
      Phase_Priority_Matrix.md

This is a recommendation only.

Final format may be Markdown, CSV, spreadsheet, or database later.

---

## 31. Markdown Table Versus Spreadsheet

Markdown tables are useful for:

- small index
- human-readable docs
- simple review
- Git diff readability

Spreadsheet or CSV may be better for:

- hundreds or thousands of docs
- filtering
- sorting
- phase/priority review
- extraction tracking
- duplicate detection
- implementation planning

The project may begin with Markdown and later migrate index data to spreadsheet or database.

---

## 32. Matrix Update Discipline

Matrix updates should be committed separately when large.

Good commit examples:

    docs: update data flow index for provider policies
    docs: map pilot lifecycle docs to saas billing flow
    docs: add runtime ownership matrix for payment and kds docs
    docs: update provider dependency matrix for Toss and OKPOS

Avoid mixing matrix updates with implementation code.

---

## 33. Matrix Drift Risk

Matrix drift occurs when:

- files move but index path is stale
- documents are superseded but matrix still points to old doc
- provider strategy changes but provider matrix is not updated
- phase changes but priority remains old
- implementation extraction happens from outdated draft
- UI mapping references screen no longer planned
- tests are added but not linked

Matrix drift must be reviewed periodically.

---

## 34. Matrix Drift Mitigation

Mitigations:

- weekly matrix review
- path checks after folder moves
- superseded document tracking
- provider strategy review
- phase recalibration
- duplicate document review
- implementation extraction gate
- commit messages that mention index updates
- avoid copying documents into multiple folders

Matrix accuracy matters more as implementation approaches.

---

## 35. Anti-Patterns

The following are prohibited:

- treating folders as sufficient index
- implementing from unindexed documents
- ignoring runtime owner
- ignoring authority type
- ignoring provider dependency
- ignoring tests
- mapping every document to every flow
- duplicating documents instead of cross-referencing
- letting matrix drift silently
- extracting backlog from superseded docs
- assigning Phase 1 to everything
- assigning P0/P1 to everything
- allowing UI to define runtime state without owner
- allowing provider event to become truth without validation

---

## 36. Non-Goals

This document does not define:

- final index file format
- final spreadsheet design
- final database schema
- final automation
- final implementation backlog tool
- final project management tool
- final UI design
- final test runner
- final CI pipeline

Those belong to later documentation operations and implementation planning.

---

## 37. Readiness Check

This document is ready when the project can answer:

1. Why is matrix indexing required?
2. What matrix families exist?
3. What is Data Flow Index?
4. What is Runtime Ownership Matrix?
5. What authority type values exist?
6. What is Provider Dependency Matrix?
7. What provider dependency values exist?
8. What is UI Surface Matrix?
9. What UI action classes exist?
10. What is Evidence Path Matrix?
11. What is Test Linkage Matrix?
12. What is Implementation Extraction Matrix?
13. What extraction ID format is recommended?
14. What implementation status values exist?
15. What phase values exist?
16. What priority values exist?
17. What fields should a document matrix record include?
18. What matrix status values exist?
19. How does progressive mapping work?
20. What matrix review cadence applies?
21. What data-flow-to-runtime rule applies?
22. What runtime-to-UI rule applies?
23. What provider-to-test rule applies?
24. What evidence-to-test rule applies?
25. What is extraction gate?
26. What is backlog anti-creep rule?
27. Where may matrices be stored?
28. What matrix drift risks exist?
29. What anti-patterns are prohibited?

If these questions cannot be answered, data flow index and implementation extraction matrix planning is incomplete.

---

## 38. Conclusion

High-volume Markdown documentation becomes useful for implementation only when it is indexed by data flow, runtime owner, provider dependency, UI surface, evidence path, test requirement, phase, and priority.

The safe progression is:

    Document Created
        -> Folder Assigned
        -> Data Flow Mapped
        -> Runtime Owner Mapped
        -> Provider/UI/Evidence/Test Mapped
        -> Phase/Priority Assigned
        -> Implementation Extraction Gate
        -> Backlog Item Created

This document prevents the project from drowning in documents and prepares the documentation set for controlled implementation, UI development, provider integration, pilot rollout, SaaS packaging, and Franchise OS linkage.