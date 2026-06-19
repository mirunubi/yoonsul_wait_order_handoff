# 000505_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md

## 1. Purpose

This document is required prelearning for Claude Cowork, Codex, Cursor, and future AI agents before they participate in development work for `yoonsul_wait_order_handoff`.

The project is not just Catch Menu. It is a staged franchise SaaS, store runtime, POS/KDS/payment, AI customer center, digital SOP, delivery channel, analytics, and future physical AI gateway project.

This guide explains the development phases, cross-cutting layers, and agent warnings that must be understood before any implementation scope is proposed.

## 2. Overall Development Phase Summary

| phase | summary |
| --- | --- |
| Phase 0 | Foundation, documentation system, AI prelearning, and 51355 development pipeline. |
| Phase 1 | Catch Menu customer entry, menu, and order handoff MVP. |
| Phase 2 | `yoonsul_os` store operation, staff, membership, inventory, and store runtime foundation. |
| Phase 3 | Kiosk, KDS, DID, CMS, POS integration, Toss, OKPOS, and financial-grade hardening. |
| Phase 3-B | Delivery app, external order channel, and KDS-DID omnichannel expansion. |
| Phase 4 | Franchise OS headquarters and branch operation control system. |
| Phase 5 | AI customer center, digital SOP, RAG, pgvector, and self-evolving SOP knowledge. |
| Phase 6 | Full Catch Menu and Franchise OS SaaS integration. |
| Phase 7 | Physical AI Gateway, IoT, robot, vision, voice, and real-world actuation boundary. |

## 3. Phase Detail Format

Each phase must be understood through these lenses:

- Purpose
- Scope
- Key Runtime Domains
- Key Risks
- AI Agent Warning
- Implementation Authorization Rule

## 3.1 Phase-Specific Prelearning Documents

| phase | document |
| --- | --- |
| Phase 1 | `000506_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` |
| Phase 2 | `000507_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md` |
| Phase 3 | `000508_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md` |
| Phase 4 | `000509_Guide_Phase_4_Franchise_OS_Prelearning_Context.md` |
| Phase 5 | `000510_Guide_Phase_5_AI_Customer_Center_Digital_SOP_RAG_Pgvector_Prelearning_Context.md` |
| Phase 6 | `000511_Guide_Phase_6_Catch_Menu_Franchise_OS_SaaS_Prelearning_Context.md` |
| Phase 7 | `000512_Guide_Phase_7_Physical_AI_Gateway_Prelearning_Context.md` |

## 4. Phase 0 Foundation

### Purpose

Phase 0 is not a product feature phase. It is the documentation, governance, AI prelearning, and controlled development pipeline phase that makes safe development possible.

### Scope

Phase 0 connects the `051355` development pipeline, `600000` implementation lifecycle, `700000` runtime flow bundle, and `000500` AI agent prelearning folder.

### Key Runtime Domains

- Documentation governance
- Context slicing
- WorkPackage readiness
- Impact scope discovery
- Human approval gate
- AI role separation

### Key Risks

- AI agents misunderstand the project as a small menu page.
- Implementation begins before scope is approved.
- Allowed files are listed without allowed operations.
- Context is dumped broadly instead of sliced.

### AI Agent Warning

Claude Cowork, Codex, and Cursor must not restart project understanding from zero on every task. They must use this prelearning folder and the 51355 pipeline as the shared entry point.

### Implementation Authorization Rule

Phase 0 never authorizes runtime implementation by itself. Implementation requires impact scope, context snapshot, overview, logic, test plan, change contract, and human approval.

## 5. Phase 1 Catch Menu

### Purpose

Phase 1 defines Catch Menu as the customer-facing menu and order-entry projection.

### Scope

Catch Menu is not a simple menu page. It is a store-runtime projection that connects menu, option, sold-out status, store status, order handoff, and customer request flow.

### Key Runtime Domains

- Customer menu surface
- Store status projection
- Menu and option availability
- Sold-out state
- Customer order handoff

### Key Risks

- Treating the customer surface as independent from store runtime.
- Losing consistency between menu state and store operation state.
- Creating customer-facing states without handoff evidence.

### AI Agent Warning

Do not implement Catch Menu UI or behavior unless the store-runtime boundary and handoff flow are in scope.

### Implementation Authorization Rule

Implementation requires a scoped customer-entry WorkPackage and approved runtime boundary.

## 6. Phase 2 yoonsul_os Store Runtime

### Purpose

Phase 2 defines `yoonsul_os` as the store operation foundation for staff, membership, inventory, order handoff, and store operating state.

### Scope

This phase is not simple CRUD. It becomes the operation base that later POS, KDS, payment, admin, and AI customer center workflows depend on.

### Key Runtime Domains

- Store operation state
- Staff and role management
- Membership and customer identity
- Inventory and availability
- Order handoff

### Key Risks

- Building isolated CRUD screens with no runtime state model.
- Missing tenant/store ownership boundaries.
- Creating data without future POS/KDS/payment compatibility.

### AI Agent Warning

Agents must understand store runtime before proposing admin, POS, KDS, payment, or customer-center changes.

### Implementation Authorization Rule

Implementation requires approved data model, state boundary, ownership boundary, and rollback plan.

## 7. Phase 3 Kiosk, KDS, DID, CMS, POS

### Purpose

Phase 3 brings kiosk, KDS, DID, CMS, POS integration, Toss, OKPOS, and payment-adjacent runtime into the system.

### Scope

POS, payment, and KDS can create financial accidents and operating accidents, so financial-grade hardening is required.

### Key Runtime Domains

- Kiosk order submission
- KDS projection and ticket state
- DID callout and customer display
- CMS and menu synchronization
- POS provider integration
- Toss and OKPOS integration
- Payment authorization, cancel, refund, and settlement evidence

### Key Risks

- Duplicate payment or duplicate order creation
- Unknown provider state
- Missing audit trail
- Missing rollback or replay evidence
- Payment state mutation without authority

### AI Agent Warning

Agents must always mention idempotency, duplicate prevention, unknown provider state, audit/evidence, and rollback when discussing this phase.

### Implementation Authorization Rule

No implementation may proceed without financial-grade impact scope, test plan, evidence plan, rollback plan, and human approval.

## 8. Phase 3-B Delivery And External Channels

### Purpose

Phase 3-B expands into delivery app, external order channel, and KDS-DID omnichannel runtime.

### Scope

This phase connects to the `750000_delivery_app_channel_integration` bundle.

### Key Runtime Domains

- Delivery app official API
- No scraping boundary
- Webhook and polling intake
- HMAC, OAuth, and IP allowlist
- KDS routing
- DID callout
- Privacy masking
- Field evidence

### Key Risks

- Treating delivery integration as simple API intake.
- Missing channel-to-kitchen-to-customer runtime flow.
- Accepting unofficial scraping or weak provider evidence.

### AI Agent Warning

Delivery integration must be understood as channel-to-kitchen-to-customer runtime flow, not just external API ingestion.

### Implementation Authorization Rule

Implementation requires provider evidence, security boundary, event contract, replay plan, and human approval.

## 9. Phase 4 Franchise OS

### Purpose

Phase 4 defines the headquarters and branch operation control system.

### Scope

Franchise OS includes store onboarding, menu distribution, policy distribution, branch/store management, approval workflow, evidence review, and compliance control.

### Key Runtime Domains

- Headquarters control
- Branch and store governance
- Menu and policy distribution
- Approval workflow
- Evidence review
- Compliance control

### Key Risks

- Treating admin as CRUD instead of a control room.
- Missing branch/store authorization.
- Allowing policy changes without evidence.

### AI Agent Warning

Admin is a control room, not a generic settings panel.

### Implementation Authorization Rule

Implementation requires approval workflow, ownership boundary, evidence trail, and rollback rule.

## 10. Phase 5 AI Customer Center, Digital SOP, RAG, pgvector

### Purpose

Phase 5 defines the AI customer center as a controlled knowledge gateway.

### Scope

The AI customer center is not free chat. It uses approved SOP, policy, runbook, and checklist context. `pgvector` is not the final authority; it is a vector search layer for retrieving approved documents.

### Key Runtime Domains

- Question intake
- Question normalization
- Embedding generation
- pgvector document search
- Tenant, store, RLS, and document-status filtering
- Approved SOP, policy, and runbook context injection
- AI answer generation
- Evidence recording
- Unresolved inquiry logging
- SOP candidate workflow
- Human approval
- Versioning and rollback

### Key Risks

- Hallucinated answers
- Unauthorized document context
- Tenant/store data leakage
- SOP auto-publish without approval
- Missing version and rollback evidence

### AI Agent Warning

AI answers must be grounded in approved documents and recorded evidence.

### Implementation Authorization Rule

Implementation requires knowledge boundary, RLS boundary, evidence plan, unresolved-inquiry policy, and human approval.

### RAG Flow

1. Receive question.
2. Normalize question.
3. Generate embedding.
4. Search similar documents through pgvector.
5. Apply tenant, store, RLS, and document-status filters.
6. Inject only approved SOP, policy, and runbook context.
7. Generate AI answer.
8. Record source document ID and version.
9. Record unresolved inquiry event.
10. Detect repeated unresolved questions.
11. Create SOP candidate.
12. Request human approval.
13. Generate AI Agent SOP draft.
14. Review, publish, version, or rollback.

### New Question SOP Evolution

- One event: log.
- Two events: repeated signal.
- Three or more events: SOP creation candidate.
- Human approval.
- AI Agent draft.
- Review.
- Publish.
- Versioning.
- Rollback.

## 11. Phase 6 Full SaaS Integration

### Purpose

Phase 6 integrates Catch Menu and Franchise OS into a complete SaaS-grade operating system.

### Scope

This phase includes multi-tenant SaaS, RLS, tenant/store isolation, admin console, customer surface, store runtime, evidence, and deployment/release governance.

### Key Runtime Domains

- Multi-tenant SaaS
- Tenant and store isolation
- Customer surface
- Store runtime
- Franchise control
- Security and evidence
- Deployment and release governance

### Key Risks

- Calling the product complete because the UI exists.
- Missing security, evidence, release, or rollback maturity.
- Weak tenant isolation.

### AI Agent Warning

Phase 6 is SaaS-grade integration, not UI completion.

### Implementation Authorization Rule

Implementation requires tenant isolation proof, release gate, rollback plan, and audit evidence.

## 12. Phase 7 Physical AI Gateway

### Purpose

Phase 7 defines the physical AI gateway for safe real-world device control.

### Scope

Physical AI Gateway is not just model integration. It is a safety, permission, evidence, and actuation boundary for real-world devices.

### Key Runtime Domains

- IoT
- Robot
- Camera vision
- Voice KDS
- Kitchen device event
- Human override
- Replay prevention
- Fallback
- Audit evidence

### Key Risks

- AI directly controlling devices without a gateway.
- Missing human override.
- Missing replay prevention.
- Missing actuation audit evidence.

### AI Agent Warning

If AI controls a real-world device, it must pass through a gateway.

### Implementation Authorization Rule

Implementation requires safety boundary, permission model, actuation evidence, fallback, human override, and human approval.

## 13. Cross-Cutting Layers

All phases share these layers:

- Security / RLS / Privacy
- Audit / Evidence / Raw Logs
- Payment / Financial Safety
- Data Model / State Machine
- AI / SOP / Knowledge
- Deployment / Release
- Context Slicing
- Allowed Files / Allowed Operations

Agents must never treat these as optional add-ons.

## 14. AI Agent Instruction

Claude Cowork uses this document to understand phases, runtime domains, authority boundaries, risks, design implications, audit expectations, and document classification.

Cursor is only an optional inspection helper. It may use this document to keep impact search and raw-log collection aligned to the correct phase and context slice.

Codex uses this document to stay inside approved allowed files and approved allowed operations only, whether doing limited implementation or document generation.

The human owner uses this document as a reminder that final approval, merge, and release stay human-owned.

## 15. Final Rule

This project is not just a menu.

AI must not inspect one phase and assume it understands the whole system.

Before implementation, phase, context slice, impact scope, logic, test plan, change contract, and human approval are required.

No implementation without impact scope, context snapshot, logic, test plan, change contract, human approval.
