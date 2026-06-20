# 000401_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu / Catch & Order |
| Band | 00100 Project Foundation / Development Foundation Extension |
| Document Type | Policy |
| Runtime Relationship | Applies to all Flow Bundle, module implementation, and code handoff documentation |
| Status | Draft Baseline |
| Owner | Project Architecture / Development Governance |
| AI Usage Boundary | AI may draft, summarize, and map documents. AI must not independently modify payment, settlement, audit, security, DB migration, secret, or production deployment logic. |

---

## 2. Purpose

This policy defines the **three-layer development documentation model** for CatchMenu / Catch & Order.

The system is no longer treated as a simple restaurant ordering service. It now touches POS, PG/VAN, approval, cancellation, settlement, reconciliation, audit ledger, evidence export, local ledger recovery, and operational release gates. Therefore, implementation must not be driven by a single Markdown file in isolation.

To prevent fragmented development, every major implementation area must be documented through the following three intuitive layers:

1. `01_overview` — system-wide view and process map
2. `02_logic` — business logic, state transitions, decisions, and exceptions
3. `03_module` — concrete implementation mapping, APIs, functions, DB structures, and source-level traceability

This model is used together with the Runtime Flow Bundle Architecture.

---

## 3. Core Principle

A single Markdown file is not an implementation unit.

A Markdown file is a policy, contract, SOP, evidence, matrix, checklist, template, register, audit note, or implementation reference.

Actual development must be controlled through:

```text
Flow Bundle
→ Overview
→ Logic
→ Module
→ File
→ Test
→ Evidence
```

The three-layer model ensures that developers and AI coding assistants can answer these questions before touching code:

```text
1. What is the feature or runtime flow?                  → overview
2. What rule, decision, state, or exception controls it? → logic
3. Which module, API, function, table, or file realizes it? → module
```

---

## 4. Relationship To Runtime Flow Bundle Architecture

The Runtime Flow Bundle documents in the `64000` band remain the implementation control structure.

This foundation policy defines how development documentation should be organized inside or alongside each Flow Bundle.

| Layer | Runtime Flow Bundle Relationship | Function |
|---|---|---|
| `01_overview` | Precedes or summarizes a Flow Bundle | Shows the whole map and interaction path |
| `02_logic` | Defines rules inside each Flow Step | Locks state transitions, decisions, retries, rollbacks, and exceptions |
| `03_module` | Maps logic to actual implementation | Connects runtime rules to code, DB, API, tests, and evidence |

The `64000~64390` documents answer **how Flow Bundle implementation is governed**.

This `00640` policy answers **how development documentation should be layered before, during, and after implementation**.

---

## 5. Three-Layer Documentation Model

### 5.1 `01_overview` — 전체 조망

`01_overview` documents provide the top-level system map.

They are used to understand the big picture before discussing detailed rules or code. These documents should be readable by the project owner, architect, developer, auditor, and AI assistant.

#### Role

```text
전체 시스템의 큰 그림과 모듈 간 상호작용을 한눈에 보여주는 대지도
```

#### Typical File Pattern

```text
01_overview_<domain_or_flow_description>.md
```

Examples:

```text
01_overview_store_runtime_main_flow.md
01_overview_pos_gateway_approval_to_audit_flow.md
01_overview_customer_order_payment_pos_settlement_flow.md
```

Korean descriptions may be used in local planning notes, but repository-ready files should prefer ASCII-safe English names when the file will be committed into Git or referenced by automation.

#### Required Content

| Section | Required Content |
|---|---|
| Purpose | Why this overview exists |
| Scope | Included and excluded runtime areas |
| Actors | Guest, store owner, staff, POS, PG/VAN, gateway, ledger, admin, AI support |
| Macro Flow | High-level sequence from customer action to system state |
| Mermaid Diagram | Large runtime flow diagram where useful |
| Related Flow Bundles | Links to 64000-band Flow Bundle documents |
| Risk Notes | High-level risks such as duplicate payment, missing settlement, offline conflict |

#### Example Scope

```text
Customer order
→ payment intent
→ POS approval request
→ approval result
→ internal ledger append
→ audit event append
→ settlement reconciliation
→ evidence export
```

---

### 5.2 `02_logic` — 비즈니스 로직 및 예외 규칙

`02_logic` documents define how the system decides, transitions, retries, cancels, rolls back, reconciles, and escalates.

They are the most important layer for preventing data corruption.

#### Role

```text
상태 전이, 판단 기준, 예외 처리, 보상 처리, 재시도, 롤백, 감사 조건을 못 박는 규칙 문서
```

#### Typical File Pattern

```text
02_logic_<domain_or_flow_description>.md
```

Examples:

```text
02_logic_payment_engine_transaction_and_network_cancel_rules.md
02_logic_pos_gateway_auth_token_refresh_and_signature_rules.md
02_logic_audit_ledger_reconciliation_and_dispute_rules.md
02_logic_offline_local_ledger_resync_conflict_rules.md
```

#### Required Content

| Section | Required Content |
|---|---|
| State Definitions | Pending, Requested, Approved, Failed, Cancelled, Refunded, Reconciled, Disputed, Exported, etc. |
| State Transition Rules | Allowed and forbidden transitions |
| Decision Rules | Conditions, branching logic, validation order |
| Idempotency Rules | Duplicate prevention keys and replay behavior |
| Retry Rules | Retry count, backoff, timeout, DLQ entry conditions |
| Compensation Rules | Cancel, refund, reverse, manual review, evidence hold |
| Exception Scenarios | Network timeout, POS unreachable, partial approval, amount mismatch, webhook replay |
| Audit Requirements | What must be logged before and after state change |
| No-AI-Solo Zone | Whether the logic belongs to payment, settlement, audit, security, migration, secret, or deployment control |

#### Mandatory Logic Rule

No implementation may start from `03_module` alone.

A module implementation must reference either:

```text
01_overview + 02_logic
```

or

```text
Flow Bundle + 02_logic
```

If the logic layer is missing, the implementation request must be rejected or converted into a documentation task first.

---

### 5.3 `03_module` — 상세 구현 명세

`03_module` documents map confirmed logic to concrete implementation details.

They are not the source of business truth. They are implementation traceability documents that show how the confirmed logic was realized in code and infrastructure.

#### Role

```text
확정된 logic을 실제 코드, API, 함수, DB, queue, event, test, evidence 구조로 추적 가능하게 연결하는 구현 명세
```

#### Typical File Pattern

```text
03_module_<domain_or_flow_description>.md
```

Examples:

```text
03_module_payment_engine_api_and_data_structure.md
03_module_pos_gateway_webhook_normalizer_and_event_queue.md
03_module_audit_ledger_append_only_writer_and_reconciliation_job.md
03_module_offline_local_ledger_storage_and_resync_worker.md
```

#### Required Content

| Section | Required Content |
|---|---|
| Module Responsibility | What the module owns and does not own |
| Source File Map | Expected or actual source files |
| API Contract | Request/response fields, validation, error codes |
| Function/Class Map | Key functions, classes, services, workers |
| DB Mapping | Tables, columns, indexes, constraints, ledger fields |
| Queue/Event Mapping | Topics, queues, DLQ, replay keys, event payloads |
| Security Mapping | Secret usage, signature validation, encryption boundary |
| Test Mapping | Unit, integration, contract, failure, audit tests |
| Evidence Mapping | Logs, audit rows, reconciliation reports, exported packets |
| Diff Trace | Links to implementation review packet and code diff |

#### Mandatory Module Rule

A `03_module` document must never introduce new business behavior that is absent from `02_logic`.

If a developer or AI assistant discovers a missing rule while writing `03_module`, the correct action is:

```text
Stop implementation
→ update 02_logic
→ update related Flow Bundle matrix
→ pass review gate
→ then update 03_module
```

---

## 6. Repository Naming Boundary

The project-level official filename rule remains:

```text
<number>_<DocumentType>_<Description>.md
```

Examples:

```text
000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md
64000_Index_Runtime_Flow_Bundle_Registry.md
64100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md
64210_Matrix_Flow_To_Module_Implementation_Map.md
64370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md
```

The `01_overview`, `02_logic`, and `03_module` labels are **development foundation subtypes**, not replacements for the official numbered project document naming rule.

They may be used in one of two ways:

### Option A — As Internal Development Notes

```text
01_overview_pos_gateway_approval_flow.md
02_logic_pos_gateway_approval_state_rules.md
03_module_pos_gateway_approval_api_and_db_map.md
```

Use this option inside temporary implementation folders, Claude handoff folders, or local planning folders.

### Option B — As Project-Governed Documents

```text
64510_Overview_POS_Gateway_Approval_To_Audit_Runtime_Flow.md
64520_Logic_POS_Gateway_Approval_State_Transition_And_Exception_Rules.md
64530_Module_POS_Gateway_Approval_API_DB_Event_And_Test_Map.md
```

Use this option when the documents become repository-governed project artifacts.

---

## 7. Development Routine

### 7.1 Design Routine

```text
Step 1. Select Flow Bundle or feature area
Step 2. Read the related 01_overview document
Step 3. Draft or update 02_logic document
Step 4. Validate state transitions and exception rules
Step 5. Update MD dependency, module impact, and test coverage maps
Step 6. Only then prepare implementation handoff
```

### 7.2 Implementation Routine

```text
Step 1. Claude Code receives Flow Bundle + overview + logic + module boundary
Step 2. Claude Code proposes implementation plan and affected files
Step 3. Human checks No-AI-Solo Zone boundaries
Step 4. Code is modified only within approved scope
Step 5. Cursor may assist with localized IDE-level review or diff inspection
Step 6. Tests are executed and evidence is attached
Step 7. 03_module document is updated from actual implementation
```

### 7.3 Debugging Routine

When a bug occurs, investigation must follow this order:

```text
1. overview — What feature or runtime flow is affected?
2. logic    — Which rule, state transition, exception, or compensation path failed?
3. module   — Which API, function, DB table, queue, event, or file implements that rule?
4. test     — Which test should have caught it?
5. evidence — Which log, audit row, or reconciliation packet proves what happened?
```

This prevents random code chasing and forces every bug to be tied back to business logic and operational evidence.

---

## 8. AI Assistant Usage Rules

### 8.1 Claude Code

Claude Code may be used as a Flow Bundle implementation agent only after the following are available:

```text
- Related overview document or Flow Bundle overview section
- Related logic document or confirmed logic section
- Module boundary document or expected module map
- Test coverage map
- No-AI-Solo Zone check
- Human approval where required
```

Claude Code must not be asked to implement from a single MD file without Flow context.

### 8.2 Cursor

Cursor is used as IDE assistance, not as the primary architecture agent.

Allowed Cursor roles:

```text
- Local file inspection
- Small scoped refactor
- Diff review
- Type error fix
- Test file lookup
- Code navigation
- Implementation consistency check
```

Restricted Cursor roles:

```text
- Rewriting payment flows alone
- Changing settlement logic alone
- Modifying audit ledger append rules alone
- Changing DB migrations alone
- Handling secrets alone
- Modifying production deployment scripts alone
- Making broad multi-module architectural changes without Flow Bundle handoff
```

---

## 9. No-AI-Solo Zone Alignment

The following areas require human approval and must not be changed by AI alone:

```text
- Payment approval and cancellation logic
- Refund and reversal logic
- Settlement and reconciliation logic
- Audit ledger append-only and tamper-evidence rules
- DB migration and schema changes
- Secret handling, token rotation, signature verification
- Production deployment and release gates
- Financial evidence export
- Consumer protection, dispute, and regulatory evidence flow
```

If any `01_overview`, `02_logic`, or `03_module` document touches these areas, it must reference the relevant No-AI-Solo governance documents.

---

## 10. Minimum Acceptance Criteria

A development documentation set is acceptable only when it satisfies all of the following:

| Criterion | Required |
|---|---|
| Overview exists | Yes, for major flow or module family |
| Logic exists | Yes, before implementation |
| Module map exists | Yes, before or during implementation |
| Flow Bundle relationship declared | Yes |
| Test coverage mapped | Yes |
| Evidence target declared | Yes |
| AI boundary declared | Yes |
| Human approval gate declared where needed | Yes |

If any required layer is missing, the work must be classified as incomplete documentation, not implementation-ready work.

---

## 11. Practical Example: POS Approval Flow

### 11.1 Overview

```text
01_overview_pos_gateway_approval_to_audit_flow.md
```

Explains:

```text
Customer order
→ payment request
→ POS/PG approval
→ gateway normalization
→ internal approval ledger
→ audit ledger
→ reconciliation readiness
```

### 11.2 Logic

```text
02_logic_pos_gateway_approval_state_transition_and_exception_rules.md
```

Defines:

```text
- Pending → Requested → Approved → Ledgered → Reconciled
- Timeout handling
- Duplicate approval prevention
- Amount mismatch rule
- POS unreachable rule
- Audit append requirement
```

### 11.3 Module

```text
03_module_pos_gateway_approval_api_db_event_and_test_map.md
```

Maps:

```text
- approval request API
- idempotency key validator
- POS adapter
- approval ledger writer
- audit event writer
- reconciliation job
- unit/integration/contract/failure/audit tests
```

---

## 12. Governance Decision

This policy is adopted as the development foundation layer for CatchMenu / Catch & Order.

It does not replace the `64000` Runtime Flow Bundle Architecture.

It sits above and beside it as a general development documentation model:

```text
Project Foundation
→ Development Documentation Model
→ Runtime Flow Bundle Registry
→ Flow Bundle Documents
→ Matrix Documents
→ Code Handoff Gates
→ Implementation Review Evidence
```

The `64400` Runtime Flow Bundle Extension / Change Intake document is temporarily deferred.

New external notes, patent material, security opinions, legal review comments, or architecture ideas must first be classified under this development documentation model before being converted into Flow Bundle changes.

---

## 13. Cross References

| Reference | Relationship |
|---|---|
| 64000_Index_Runtime_Flow_Bundle_Registry.md | Flow Bundle registry baseline |
| 64100_Flow_POS_Gateway_Approval_To_Audit_Ledger_And_Reconciliation.md | Example high-risk approval flow |
| 64200_Matrix_Flow_To_MD_Dependency_Graph.md | MD dependency mapping |
| 64210_Matrix_Flow_To_Module_Implementation_Map.md | Module implementation mapping |
| 64220_Matrix_Flow_To_Test_Coverage_Map.md | Test coverage mapping |
| 64300_Checklist_Flow_Bundle_Code_Handoff_Readiness_Gate.md | Code handoff readiness gate |
| 64370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md | AI solo restriction governance |
| 64380_Register_Flow_Bundle_No_AI_Solo_Zone_Owner_And_Approval_Matrix.md | Owner and approval matrix |
| 64390_Checklist_Flow_Bundle_Pre_Merge_And_Release_Gate.md | Pre-merge and release control |

---

## 14. Closing Rule

Development must not begin from code.

Development must not begin from a single Markdown file.

Development begins from a controlled understanding of:

```text
overview
→ logic
→ module
→ file
→ test
→ evidence
```

This rule protects CatchMenu / Catch & Order from fragmented AI-assisted development, hidden financial-state corruption, untraceable POS behavior, and undocumented audit gaps.
