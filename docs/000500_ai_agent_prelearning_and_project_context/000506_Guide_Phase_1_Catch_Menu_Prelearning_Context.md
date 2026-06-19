# 000506_Guide_Phase_1_Catch_Menu_Prelearning_Context.md

## 1. Purpose

Phase 1 explains Catch Menu as the customer-facing menu and order-entry surface for the broader store-runtime and franchise SaaS system.

This document is prelearning for Claude, Codex, Cursor, and future AI agents before they work on this phase.

It helps agents understand the phase before implementation planning. It does not authorize implementation.

## 2. Phase Position

Phase 1 is the customer entry and MVP projection phase. It turns store runtime state into customer-visible menu, option, availability, and order-handoff behavior.

## 3. Core Scope

- Customer menu entry
- Menu category browsing
- Menu detail review
- Option selection
- Sold-out display
- Store open/close display
- Order handoff creation
- QR order, mobile web, and app projection possibility
- Kiosk reuse possibility
- Customer handoff starting point

## 4. Non-Scope

- Actual payment implementation
- Direct POS/KDS implementation
- DID implementation
- Delivery app integration
- Full Franchise_OS implementation
- AI customer center implementation
- Physical AI implementation

## 5. Key Runtime Concepts

- Customer-facing projection
- Store-runtime dependency
- Menu availability state
- Sold-out state
- Store operating state
- Order handoff boundary
- Customer privacy boundary

## 6. Key Risks

- Customer sees stale menu as orderable
- Order handoff is created when store is closed
- Option, price, or menu information diverges from runtime
- Order handoff looks like confirmed order
- Catch Menu UI falsely confirms POS/KDS/payment state
- Customer personal information is collected without scope

## 7. Required Pre-Implementation Documents

- impact_scope for the customer-facing Catch Menu surface
- context_snapshot covering menu, option, sold-out, store status, and order handoff dependencies
- overview of Catch Menu as store-runtime customer-facing projection
- logic for menu availability, option selection, store status, order intent, and customer handoff
- test_plan for stale state, sold-out, closed-store, and handoff boundary cases
- change_contract that explicitly excludes payment, POS, KDS, and confirmed-order mutation
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


Phase 1 depends on Phase 2 store runtime and later connects to Phase 3 POS/KDS/payment only through approved handoff boundaries.

## 10. Final Rule

Catch Menu is not just UI. It is the customer-facing projection of store runtime, and no runtime implementation may begin before the 51355 pipeline gate is passed.
