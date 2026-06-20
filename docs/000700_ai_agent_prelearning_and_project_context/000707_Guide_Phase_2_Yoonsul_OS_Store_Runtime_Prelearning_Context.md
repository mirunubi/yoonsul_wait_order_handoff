# 000507_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md

## 1. Purpose

Phase 2 explains `yoonsul_os` as the store operation foundation for staff, membership, inventory, order handoff, and runtime state.

This document is prelearning for Claude, Codex, Cursor, and future AI agents before they work on this phase.

It helps agents understand the phase before implementation planning. It does not authorize implementation.

## 2. Phase Position

Phase 2 is the store-runtime foundation phase that later POS, KDS, payment, admin, and AI customer center systems rely on.

## 3. Core Scope

- Staff role and permission model
- Store operating state
- Order intake, acceptance, preparation, pickup flow
- Membership base structure
- Inventory link and sold-out state
- Menu availability runtime
- Staff operation
- Manual fallback starting point

## 4. Non-Scope

- Direct payment provider implementation
- KDS screen implementation
- DID implementation
- Delivery app integration
- Franchise-wide control room implementation
- AI customer center implementation

## 5. Key Runtime Concepts

- Store runtime state
- Staff authority
- Membership identity boundary
- Inventory and sold-out consistency
- Manual fallback
- Order handoff state machine

## 6. Key Risks

- Customer order state diverges from staff operation state
- Inventory or sold-out state diverges from menu availability
- Staff permission misuse
- Membership/customer information misuse
- Store operating state conflicts with POS/KDS/payment

## 7. Required Pre-Implementation Documents

- impact_scope for staff, membership, inventory subset, store runtime, availability, and handoff behavior
- context_snapshot covering staff operation, store operating state, sold-out/runtime availability, and downstream dependency boundaries
- overview of Yoonsul OS as the store-runtime operating foundation
- logic for order handoff, staff operation, store status, membership boundary, and runtime availability
- test_plan for permission misuse, stale availability, manual fallback, and handoff state transitions
- change_contract that limits changes to approved store-runtime scope
- human approval before any implementation activity

## 8. Implementation Gate

This document is not an implementation authorization.

Actual implementation must pass through the 51355 pipeline. Implementation is forbidden unless impact_scope, context_snapshot, overview, logic, test_plan, change_contract, and human approval exist.

Allowed files are not enough. Allowed operations must also be specified.

Cursor is only an optional inspection helper for related-file discovery and raw evidence collection.

Claude Cowork is responsible for design, audit, and document classification.

Codex is responsible only for limited implementation or document generation inside approved files and approved operations.

Human is responsible for final approval, merge, and release.

## 9. Related Folders And Documents

Cross-references:

- `000505_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md`
- `051355` AI-assisted financial-grade development pipeline
- `600000` implementation lifecycle
- `700000` runtime flow bundle
- `000500` AI agent prelearning folder


Phase 2 supports Phase 1 customer projection and prepares Phase 3 POS/KDS/payment integration.

## 10. Final Rule

Yoonsul OS store runtime is not simple CRUD; it is the operating foundation that later POS, KDS, payment, admin, and AI customer center flows depend on.
