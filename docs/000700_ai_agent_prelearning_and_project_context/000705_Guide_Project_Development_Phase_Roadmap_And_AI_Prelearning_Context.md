# 000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md

## 1. Purpose

This document is required prelearning for Claude Cowork, Codex, Cursor, and future AI agents before they participate in development work for `yoonsul_wait_order_handoff`.

The project is not just Catch Menu. It is a staged franchise SaaS, store runtime, POS/KDS/payment, AI customer center, digital SOP, delivery channel, analytics, and future physical AI gateway project.

This guide explains the development phases, cross-cutting layers, and agent warnings that must be understood before any implementation scope is proposed.

## 2. Overall Development Phase Summary

| phase | summary |
| --- | --- |
| Phase 0 | Foundation, documentation system, AI prelearning, and 51355 development pipeline. |
| Phase 1 | Catch Menu real-store MVP: menu, waiting, takeout request, pickup, Mini Kiosk, basic KDS, OKPOS/Toss POS handoff. |
| Phase 2 | Separate `yoonsul_os` project: staff, membership, partial inventory; not Catch Menu backend; Franchise_OS precursor. |
| Phase 3 | Full Kiosk / KDS / DID / CMS / POS integration; reuses Phase 1 OKPOS/Toss; foundation for Phase 1-C and Phase 4. |
| Phase 3-B | Delivery app, external order channel, and KDS-DID omnichannel expansion. |
| Phase 4 | Franchise_OS no-outage restaurant operations system; Agent + SOP Runtime; builds on Phase 3. |
| Phase 5 | Franchise_OS AI customer center + integrated support; extends 1-C; uses Phase 4 events; prerequisite for Phase 6. |
| Phase 6 | Franchise_OS SaaS conversion + Phase 1 SaaS enhancement; builds on Phase 4/5. |
| Phase 7 | AI readiness + Physical AI Gateway; safety gate, human override, actuation evidence. |

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
| Phase 1 | `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` |
| Phase 2 | `000707_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md` |
| Phase 3 | `000708_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md` |
| Phase 4 | `000709_Guide_Phase_4_Franchise_OS_Prelearning_Context.md` |
| Phase 5 | `000710_Guide_Phase_5_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md` |
| Phase 6 | `000711_Guide_Phase_6_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md` |
| Phase 7 | `000712_Guide_Phase_7_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md` |

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

Phase 1 defines Catch Menu as the first real-store MVP connecting customer entry, waiting, takeout order request, pickup status, Mini Kiosk, basic KDS, and basic OKPOS/Toss POS handoff. See `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` for full boundaries.

### Scope

Catch Menu is not a simple menu page and not the final public SaaS service. It is a bounded store-runtime projection for field validation. Phase 1-B expands SaaS and equipment integration; Phase 6 owns full POS coverage planning.

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

Phase 2 defines `yoonsul_os` as a **separate project** from Catch Menu: single-store internal operations for staff, membership, and partial inventory. It is **not** Catch Menu backend runtime and has **no waiting handoff**. See `000707_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md`.

### Scope

Phase 2 builds Franchise_OS precursor capabilities at single-store scope. Membership packaging/delivery request and minimum payment tracking are in scope; full POS/KDS/DID/CMS, Catch Menu integration, and Franchise_OS full implementation are not.

### Key Runtime Domains

- Staff and role management
- Membership and customer identity
- Partial inventory and menu sellability link
- Membership packaging/delivery request and minimum payment tracking
- Single-store operation audit trail

### Key Risks

- Treating Phase 2 as Catch Menu backend or adding waiting handoff.
- Mixing membership packaging/delivery with Catch Menu takeout request.
- Expanding payment or inventory beyond Phase 2 minimum scope.
- Pulling Franchise_OS implementation forward into Phase 2.

### AI Agent Warning

Agents must understand store runtime before proposing admin, POS, KDS, payment, or customer-center changes.

### Implementation Authorization Rule

Implementation requires approved data model, state boundary, ownership boundary, and rollback plan.

## 7. Phase 3 Kiosk, KDS, DID, CMS, POS

### Purpose

Phase 3 is the **full Kiosk / KDS / DID / CMS / POS integration phase**. It stabilizes store equipment, kitchen display, customer display, content, and POS order/payment consistency. See `000708_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md`.

### Scope

Phase 3 reuses Phase 1 OKPOS and Toss POS foundation and may expand to additional major POS providers with evidence. Output becomes infrastructure for Phase 1-C SaaS productization and Phase 4 Franchise_OS—not Franchise_OS or SaaS launch itself.

### Key Runtime Domains

- Kiosk and Mini Kiosk enhancement
- KDS kitchen display and station routing
- DID pickup callout and customer display
- CMS content and menu synchronization
- POS integration (Phase 1 OKPOS/Toss reuse; controlled provider expansion)
- Order, payment, cancel/refund state consistency
- Retry, idempotency, degraded mode, audit, and evidence

### Key Risks

- Treating Phase 3 as Franchise_OS preparation or SaaS market launch.
- Payment success conflated with order success; KDS/DID/POS state divergence.
- CMS/POS menu mismatch; duplicate order/payment on retry.
- Broad POS readiness claims without provider-specific evidence.

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

Phase 4 Franchise_OS is a **no-outage restaurant operations system**. See `000709_Guide_Phase_4_Franchise_OS_Prelearning_Context.md`.

### Scope

Core differentiator: No-Outage Store Operations Agent + SOP Runtime. Required supporting modules: SCM, CRM, menu/policy distribution, role/approval, audit/evidence. Builds on Phase 3 integration foundation.

### Key Runtime Domains

- Agent + SOP Runtime, Human Authority Runtime
- Observation/Input Federation, Runtime Federation, Recovery/SOP Federation
- Failure classification, resource judgment, fallback/degraded operation, safe closure
- SCM, CRM, menu/policy distribution, approval workflow, franchise dashboard

### Key Risks

- Reducing Franchise_OS to common SCM/CRM admin software.
- Agent treated as final authority; human approval bypassed.
- Missing Runtime Federation or recovery reconciliation.

### AI Agent Warning

Continue if safe. Limit if necessary. Close safely if unsafe. Agent recommends; humans decide.

### Implementation Authorization Rule

Implementation requires approval workflow, ownership boundary, evidence trail, and rollback rule.

## 10. Phase 5 AI Customer Center, Digital SOP, RAG, pgvector

### Purpose

Phase 5 is **Franchise_OS AI customer center and integrated support enhancement**. See `000710_Guide_Phase_5_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md`.

### Scope

Extends Phase 1-C launch AI customer center using Phase 4 no-outage events, SOP Runtime, and recovery evidence. Not a FAQ chatbot; RAG/pgvector are search layers, not final authority.

### Key Runtime Domains

- Franchise_OS + integrated support center enhancement
- Digital SOP evolution from operation and inquiry events
- RAG/pgvector search, unresolved/repeated inquiry, SOP candidate workflow
- Role-based answer isolation (HQ/franchisee/staff/agent/customer)
- Human approval for official SOP, refund, policy, and closure decisions

### Key Risks

- Reducing Phase 5 to generic FAQ chatbot; disconnect from Phase 4 events.
- Auto-deploying SOP without human approval; RAG-only answers.
- Missing role isolation or tenant-safe support design for Phase 6.

### AI Agent Warning

AI explains and recommends; humans approve. Unresolved inquiries feed SOP evolution.

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

Phase 6 is **Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement**. See `000711_Guide_Phase_6_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md`.

### Scope

Dual center: Franchise_OS SaaS productization (Phase 4 output) and Phase 1-C SaaS operational enhancement. Common SaaS foundation with separated product boundaries. Phase 5 is prerequisite.

### Key Runtime Domains

- Tenant isolation (HQ/franchisee/store/branch)
- Billing/subscription/plan model linked to permissions and support scope
- SaaS admin console, onboarding/migration, release governance
- Provider support policy, audit/evidence, AI customer center linkage

### Key Risks

- Treating Phase 6 as UI completion or first Franchise_OS implementation.
- Weak tenant isolation; AI/RAG crossing tenant boundaries.
- Official provider support or SaaS claims without billing/evidence/support readiness.

### AI Agent Warning

Phase 6 productizes and operates SaaS; it does not re-implement Phase 4/5 core or Phase 7 Physical AI control.

### Implementation Authorization Rule

Implementation requires tenant isolation proof, release gate, rollback plan, and audit evidence.

## 12. Phase 7 Physical AI Gateway

### Purpose

Phase 7 is **AI readiness and Physical AI Gateway**. See `000712_Guide_Phase_7_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md`.

### Scope

Prepares safety gate, authority boundary, human override, and actuation evidence before AI connects to sensors, robots, voice, vision, IoT, and devices. Builds on Phase 4/5/6—not direct device control.

### Key Runtime Domains

- AI readiness, Physical AI Gateway, sensor/device event intake
- Voice/vision/robot/IoT preparation (observation vs controllable)
- Safety gate, human override, actuation evidence, tenant-safe AI judgment

### Key Risks

- AI directly controlling devices; missing safety gate or human override.
- Sensor/voice/vision treated as certain truth; actuation without evidence.
- Bypassing Phase 4 no-outage principles or Phase 6 tenant isolation.

### AI Agent Warning

AI proposes; Gateway gates; humans approve. No uncontrolled physical actuation.

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
