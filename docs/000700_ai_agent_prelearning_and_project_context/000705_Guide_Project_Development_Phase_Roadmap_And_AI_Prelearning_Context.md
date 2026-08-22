# 000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md

> ⚠️ **2026-08-22 범위 변경 — 실행 계층 외부 위임**
>
> Phase 1 / Phase 3 / Phase 3-B 의 실행 계층(KDS · DID · CMS · Kiosk 화면,
> 배달 채널 직접 수집) 자체 개발이 **범위에서 제외**되었다.
>
> 판정 문서: `000718_Governance_Execution_Layer_Externalization_Roadmap_Revision.md`
>
> **아래 본문은 변경 전 서술을 그대로 보존한 것이다.**
> 해당 Phase 를 인용할 때는 `000718` §1 을 함께 확인한다.
>
> Core 의 책임(Canonical Menu / Modifier / Order / Payment Authority)과
> provider 교체 가능성은 유지된다(`000718` §3·§4).

## 1. Purpose

This document is required prelearning for Claude Code, Claude, and future AI agents before they participate in development work for `yoonsul_wait_order_handoff`.

The project is not just Catch Menu. It is a staged franchise SaaS, store runtime, POS/KDS/payment, AI customer center, digital SOP, delivery channel, analytics, and future physical AI gateway project.

This guide explains the development phases, cross-cutting layers, and agent warnings that must be understood before any implementation scope is proposed.

## 2. Overall Development Phase Summary

| phase | summary |
| --- | --- |
| Phase 0 | Foundation, documentation system, AI prelearning, and the 000701 controlled AI development pipeline. |
| Phase 1 | Catch Menu real-store MVP: menu, waiting, takeout request, pickup, Mini Kiosk, basic KDS, OKPOS/Toss POS handoff. |
| Phase 2 | Separate `yoonsul_os` project: staff, membership, partial inventory; not Catch Menu backend; Franchise_OS precursor. |
| Phase 3 | Full Kiosk / KDS / DID / CMS / POS integration; reuses Phase 1 OKPOS/Toss; foundation for Phase 1-C and Phase 5. |
| Phase 3-B | Delivery app, external order channel, and KDS-DID omnichannel expansion. |
| Phase 4 | Catch Menu AI Customer Center: standalone, reusable AI customer center module built independent of Franchise_OS; Phase 6 later extends it. |
| Phase 5 | Franchise_OS no-outage restaurant operations system; Agent + SOP Runtime; builds on Phase 3. |
| Phase 6 | Franchise_OS AI Customer Center: extends the Phase 4 module with Phase 5 no-outage events, SOP Runtime, and recovery evidence; prerequisite for Phase 7. |
| Phase 7 | Franchise_OS SaaS conversion + Phase 1 SaaS enhancement; builds on Phase 5/6. |
| Phase 8 | AI readiness + Physical AI Gateway; safety gate, human override, actuation evidence. |

> ⚠️ 위 표의 **Phase 1 / Phase 3 / Phase 3-B** 는 2026-08-22 판정으로 범위가 축소되었다.
>
> | phase | 변경 |
> |---|---|
> | Phase 1 | `basic KDS` 자체 개발 제외 |
> | Phase 3 | Kiosk · KDS · DID · CMS 화면 자체 개발 제외. provider 연동으로 대체 |
> | Phase 3-B | 배달 채널 직접 통합 제외. 실행 provider 수신분 활용 |
>
> `000718` §1.1 참조.

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
| Phase 4 | `000709_Guide_Phase_4_Catch_Menu_AI_Customer_Center_Prelearning_Context.md` |
| Phase 5 | `000710_Guide_Phase_5_Franchise_OS_Prelearning_Context.md` |
| Phase 6 | `000711_Guide_Phase_6_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md` |
| Phase 7 | `000712_Guide_Phase_7_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md` |
| Phase 8 | `000713_Guide_Phase_8_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md` |

## 4. Phase 0 Foundation

### Purpose

Phase 0 is not a product feature phase. It is the documentation, governance, AI prelearning, and controlled development pipeline phase that makes safe development possible.

### Scope

Phase 0 connects the `000701` controlled AI development pipeline, `600000` implementation lifecycle, `700000` runtime flow bundle, and `000500` AI agent prelearning folder.

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

Claude Code and Claude must not restart project understanding from zero on every task. They must use this prelearning folder and the 000701 controlled AI development pipeline as the shared entry point.

### Implementation Authorization Rule

Phase 0 never authorizes runtime implementation by itself. Implementation requires impact scope, context snapshot, overview, logic, test plan, change contract, and human approval.

## 5. Phase 1 Catch Menu

### Purpose

Phase 1 defines Catch Menu as the first real-store MVP connecting customer entry, waiting, takeout order request, pickup status, Mini Kiosk, basic KDS, and basic OKPOS/Toss POS handoff. See `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` for full boundaries.

> ⚠️ **범위 변경 (2026-08-22)**: `basic KDS` 자체 개발이 제외되었다.
> 주방 실행은 외부 provider 가 담당하며,
> Core 는 Kitchen Dispatch Contract 까지 책임진다(`000718` §4).

### Scope

Catch Menu is not a simple menu page and not the final public SaaS service. It is a bounded store-runtime projection for field validation. Phase 1-B expands SaaS and equipment integration; Phase 7 owns full POS coverage planning.

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

> ⚠️ **범위 변경 (2026-08-22)**: 아래 항목이 자체 개발 범위에서 제외되었다.
>
> ```text
> Kiosk and Mini Kiosk enhancement
> KDS kitchen display and station routing
> DID pickup callout and customer display
> CMS content and menu synchronization
> ```
>
> 아래는 유지된다.
>
> ```text
> Order, payment, cancel/refund state consistency
> Retry, idempotency, degraded mode, audit, and evidence
> ```
>
> `000718` §1.2 참조.

### Scope

Phase 3 reuses Phase 1 OKPOS and Toss POS foundation and may expand to additional major POS providers with evidence. Output becomes infrastructure for Phase 1-C SaaS productization and Phase 5 Franchise_OS—not Franchise_OS or SaaS launch itself.

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

> ⚠️ **범위 변경 (2026-08-22)**: 배달앱·외부 주문 채널을 **각각 직접 연동하지 않는다.**
> 실행 provider 가 다수 채널을 수신하는 경우 그것을 활용한다.
>
> 다만 **외부 채널 주문을 우리 시스템이 받지 않는 것은 Deferred 이지 불필요가 아니다.**
> 재고 차감 · 통합 매출 · 메뉴 분석 · 자동 발주가 전부 외부 채널 판매를 필요로 한다.
>
> `000718` §1.3 / `601710` §3.1 참조.

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

## 9. Phase 4 Catch Menu AI Customer Center

### Purpose

Phase 4 builds Catch Menu's own AI customer center as a standalone, reusable module, independent of Franchise_OS SOP Runtime. See `000709_Guide_Phase_4_Catch_Menu_AI_Customer_Center_Prelearning_Context.md`.

### Scope

Module-first phase: RAG pipeline, unresolved-inquiry tracking, and SOP-candidate flow scoped to Catch Menu knowledge only (menu, hours, pickup policy). Does not depend on Phase 5 Franchise_OS. Phase 6 later extends this same module — it does not rebuild it.

### Key Runtime Domains

- Customer inquiry intake (menu, waiting, pickup, order status)
- RAG/pgvector search scoped to Catch Menu knowledge sources
- Unresolved-inquiry logging and repeated-inquiry detection
- Minimal SOP-candidate flagging (no auto-publish)
- Human review path for low-confidence answers

### Key Risks

- Module built too narrowly for Catch Menu only, forcing Phase 6 to rebuild instead of extend.
- RAG sources not clearly scoped; answers leak Franchise_OS-level assumptions that don't exist yet.
- Auto-answering low-confidence questions without human review.

### AI Agent Warning

This is a standalone module, not a preview of Franchise_OS AI customer center. Do not assume Franchise_OS SOP Runtime, no-outage events, or role-based tenant isolation are in scope here — those arrive in Phase 6.

### Implementation Authorization Rule

Implementation requires Catch-Menu-scoped knowledge boundary, low-confidence routing rule, and human approval.

## 10. Phase 5 Franchise OS

### Purpose

Phase 5 Franchise_OS is a **no-outage restaurant operations system**. See `000710_Guide_Phase_5_Franchise_OS_Prelearning_Context.md`.

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

## 11. Phase 6 AI Customer Center, Digital SOP, RAG, pgvector

### Purpose

Phase 6 is **Franchise_OS AI customer center and integrated support enhancement**. See `000711_Guide_Phase_6_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md`.

### Scope

Extends the Phase 4 Catch Menu AI Customer Center module using Phase 5 no-outage events, SOP Runtime, and recovery evidence — does not rebuild it. Not a FAQ chatbot; RAG/pgvector are search layers, not final authority.

### Key Runtime Domains

- Franchise_OS + integrated support center enhancement
- Digital SOP evolution from operation and inquiry events
- RAG/pgvector search, unresolved/repeated inquiry, SOP candidate workflow
- Role-based answer isolation (HQ/franchisee/staff/agent/customer)
- Human approval for official SOP, refund, policy, and closure decisions

### Key Risks

- Reducing Phase 6 to generic FAQ chatbot; disconnect from Phase 5 events.
- Auto-deploying SOP without human approval; RAG-only answers.
- Missing role isolation or tenant-safe support design for Phase 7.

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

## 12. Phase 7 Full SaaS Integration

### Purpose

Phase 7 is **Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement**. See `000712_Guide_Phase_7_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md`.

### Scope

Dual center: Franchise_OS SaaS productization (Phase 5 output) and Phase 1-C SaaS operational enhancement. Common SaaS foundation with separated product boundaries. Phase 6 is prerequisite.

### Key Runtime Domains

- Tenant isolation (HQ/franchisee/store/branch)
- Billing/subscription/plan model linked to permissions and support scope
- SaaS admin console, onboarding/migration, release governance
- Provider support policy, audit/evidence, AI customer center linkage

### Key Risks

- Treating Phase 7 as UI completion or first Franchise_OS implementation.
- Weak tenant isolation; AI/RAG crossing tenant boundaries.
- Official provider support or SaaS claims without billing/evidence/support readiness.

### AI Agent Warning

Phase 7 productizes and operates SaaS; it does not re-implement Phase 5/6 core or Phase 8 Physical AI control.

### Implementation Authorization Rule

Implementation requires tenant isolation proof, release gate, rollback plan, and audit evidence.

## 13. Phase 8 Physical AI Gateway

### Purpose

Phase 8 is **AI readiness and Physical AI Gateway**. See `000713_Guide_Phase_8_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md`.

### Scope

Prepares safety gate, authority boundary, human override, and actuation evidence before AI connects to sensors, robots, voice, vision, IoT, and devices. Builds on Phase 5/6/7—not direct device control.

### Key Runtime Domains

- AI readiness, Physical AI Gateway, sensor/device event intake
- Voice/vision/robot/IoT preparation (observation vs controllable)
- Safety gate, human override, actuation evidence, tenant-safe AI judgment

### Key Risks

- AI directly controlling devices; missing safety gate or human override.
- Sensor/voice/vision treated as certain truth; actuation without evidence.
- Bypassing Phase 5 no-outage principles or Phase 7 tenant isolation.

### AI Agent Warning

AI proposes; Gateway gates; humans approve. No uncontrolled physical actuation.

### Implementation Authorization Rule

Implementation requires safety boundary, permission model, actuation evidence, fallback, human override, and human approval.

## 14. Cross-Cutting Layers

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

## 15. AI Agent Instruction

Claude uses this document to understand phases, runtime domains, authority boundaries, risks, design implications, audit expectations, and document classification.

Claude Code uses this document to keep boundary scan, drafting, and restricted implementation aligned to the correct phase and context slice, and to stay inside approved allowed files and approved allowed operations only.

The human owner uses this document as a reminder that final approval, merge, and release stay human-owned.

## 16. Final Rule

This project is not just a menu.

AI must not inspect one phase and assume it understands the whole system.

Before implementation, phase, context slice, impact scope, logic, test plan, change contract, and human approval are required.

No implementation without impact scope, context snapshot, logic, test plan, change contract, human approval.
