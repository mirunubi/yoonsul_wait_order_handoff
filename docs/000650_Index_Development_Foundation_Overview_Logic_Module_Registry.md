# 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Document Number | 00650 |
| Document Type | Index |
| Document Title | Development Foundation Overview Logic Module Registry |
| Status | Draft |
| Owner | Development Foundation / Architecture Governance |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Runtime Band | 64000_Runtime_Flow_Bundle_Registry |

## 2. Purpose

This index defines how development foundation documents are registered, grouped, and connected to runtime Flow Bundle architecture.

The purpose of this registry is to prevent implementation work from being driven by isolated Markdown files. Every implementation-relevant document must be classified into one of three development foundation layers:

1. `01_overview` — whole-system or domain-level map
2. `02_logic` — business rule, state transition, exception, and decision logic
3. `03_module` — implementation mapping, API, function, schema, and code traceability

This registry does not replace the official project naming rule. The official file naming rule remains:

```text
NNNNN_DocumentType_Descriptive_Title.md
```

The `01_overview`, `02_logic`, and `03_module` labels are used as internal development foundation layer tags, section names, and optional subfolder grouping hints.

## 3. Scope

This registry applies to development-facing documentation for:

- CatchMenu guest-facing order and table flow
- Catch & Order SaaS runtime
- POS Gateway integration
- PG/VAN payment and approval flow
- settlement, reconciliation, and audit ledger flow
- admin console operation flow
- AI customer center answer and escalation flow
- store offline / degraded mode / recovery flow
- implementation handoff to Claude Code and Cursor

This registry does not authorize code changes by itself. Code changes remain governed by the runtime Flow Bundle gate documents in the 64000 band.

## 4. Registry Position

```text
00100_project_foundation
  ├─ 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md
  └─ 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md

64000_runtime_flow_bundle_registry
  ├─ 64000_Index_Runtime_Flow_Bundle_Registry.md
  ├─ 64100~64150_Flow_*.md
  ├─ 64200~64220_Matrix_*.md
  └─ 64300~64390_Code_Handoff_Gate_*.md
```

The 00640~00650 foundation documents define how development documentation is structured.
The 64000 band defines how actual implementation work is bundled, checked, tested, and approved.

## 5. Layer Definitions

### 5.1 `01_overview` Layer

The overview layer explains the broad system map.

It answers:

- What is the whole flow?
- Which domains participate?
- Which external systems are involved?
- Where are the trust boundaries?
- Which Flow Bundles are affected?

Typical contents:

- system overview
- domain map
- Mermaid flowchart
- external system boundary
- high-level dependency map
- runtime room / gateway / ledger overview

Official document types that may contain overview content:

- `Index`
- `Readme`
- `Policy`
- `Architecture`
- `Boundary`
- `Flow`
- `Governance`

### 5.2 `02_logic` Layer

The logic layer defines the business and runtime rules.

It answers:

- What states can exist?
- What triggers state transitions?
- What must happen on timeout, duplicate event, cancel, refund, or mismatch?
- Which conditions require retry, DLQ, rollback, manual review, or human approval?
- Which rules are financial-grade and therefore non-bypassable?

Typical contents:

- state machine
- decision table
- exception rule
- retry rule
- cancellation/refund rule
- reconciliation rule
- audit rule
- idempotency rule
- customer protection rule

Official document types that may contain logic content:

- `Policy`
- `SOP`
- `Runbook`
- `Boundary`
- `Spec`
- `Flow`
- `Matrix`
- `Governance`

### 5.3 `03_module` Layer

The module layer maps confirmed logic to implementable software structure.

It answers:

- Which runtime module owns this behavior?
- Which service, API, worker, table, queue, or event schema is involved?
- Which files may be changed?
- Which tests must be added or updated?
- Which evidence must be produced after implementation?

Typical contents:

- API request/response contract
- DB schema mapping
- queue/topic/event mapping
- service/component responsibility
- file-level implementation map
- test target map
- evidence packet requirement

Official document types that may contain module content:

- `Implementation`
- `Spec`
- `Matrix`
- `WorkPackage`
- `Template`
- `Checklist`
- `Evidence`

## 6. Development Documentation Registry Table

| Layer | Registry Role | Primary Question | Output Before Coding |
|---|---|---|---|
| 01_overview | System Map | What is the flow and boundary? | Runtime Flow Diagram / Domain Map |
| 02_logic | Rule Model | What rules and exceptions control behavior? | State / Decision / Exception Logic |
| 03_module | Implementation Map | Which modules and files implement it? | Module Impact Map / File-Test-Evidence Map |

## 7. Required Cross-Link Rules

Every development-facing document must declare at least one of the following references:

1. related overview document
2. related logic document
3. related module document
4. related runtime Flow Bundle
5. related test coverage map
6. related evidence packet

No implementation document should exist without a parent overview or logic reference.

No module-level implementation should proceed unless the relevant logic document is stable enough to determine:

- state transitions
- exception handling
- idempotency behavior
- rollback/retry behavior
- audit evidence requirement

## 8. Flow Bundle Connection Rule

The development foundation layers connect to Flow Bundle architecture as follows:

```text
01_overview
  ↓ defines system/domain map
02_logic
  ↓ defines state, rule, exception, decision behavior
03_module
  ↓ maps logic to module, file, test, evidence
64000 Flow Bundle Gate
  ↓ controls actual implementation handoff
Claude Code / Cursor
  ↓ produces code diff only within approved scope
Test + Evidence
  ↓ returns result to Flow Bundle registry
```

A Flow Bundle must not be handed to Claude Code or Cursor until the related overview, logic, module, test, and evidence references are sufficiently identified.

## 9. Relationship With 64000 Runtime Flow Bundle Band

The 00640~00650 development foundation documents are higher-level rules.
The 64000 band is the implementation governance lane.

| Foundation Item | Runtime Flow Bundle Item | Relationship |
|---|---|---|
| 01_overview | MD Dependency Graph / Runtime Flow Diagram | Defines what must be visible before implementation |
| 02_logic | Flow document / state and exception section | Defines what behavior must be implemented |
| 03_module | Module Impact Map | Defines where implementation may occur |
| Test/Evidence | Test Coverage Map / Evidence Packet | Defines how completion is proven |

## 10. Intake Classification Rule

When a new document, external opinion, patent note, legal review, security note, or implementation request arrives, classify it in the following order:

1. Does it change the overview map?
2. Does it change business/runtime logic?
3. Does it change module/file/API/schema implementation?
4. Does it affect a 64000 Flow Bundle?
5. Does it require test coverage update?
6. Does it require evidence packet update?
7. Does it touch a No-AI-Solo Zone?

If the answer to 2, 3, 4, 5, 6, or 7 is yes, it must not be treated as a simple documentation update.

## 11. No-AI-Solo Zone Reminder

The following areas must never be modified by AI alone:

- payment approval logic
- cancellation/refund financial state
- settlement/reconciliation logic
- audit ledger immutability logic
- DB migration
- secret handling
- production deployment
- security boundary
- customer financial dispute evidence
- legal retention and export policy

Any document classified into these areas must be routed through the human approval gate defined in the 64300~64390 band.

## 12. Suggested Next Foundation Documents

The following documents may be created after this registry:

```text
000660_Template_Development_Foundation_Overview_Document.md
000670_Template_Development_Foundation_Logic_Document.md
000680_Template_Development_Foundation_Module_Document.md
00690_Checklist_Development_Foundation_Document_To_Flow_Bundle_Readiness.md
```

These documents should provide reusable templates for overview, logic, and module documentation without breaking the official file naming rule.

## 13. Completion Criteria

This registry is complete when:

- the project recognizes overview / logic / module as development documentation layers;
- official file naming remains `NNNNN_DocumentType_Descriptive_Title.md`;
- implementation work is still controlled by Flow Bundle gates;
- new documents can be classified before being handed to Claude Code or Cursor;
- No-AI-Solo Zone documents are not routed as ordinary AI coding tasks.

## 14. Summary

This registry establishes the development documentation map for CatchMenu / Catch & Order.

The core principle is:

```text
A Markdown file is a knowledge unit.
A Flow Bundle is an implementation unit.
Overview, logic, and module documents are the bridge between the two.
```
