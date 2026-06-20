# 000708_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md

## 1. Purpose

This document is the Phase 3 prelearning context for Claude Cowork, Codex, Cursor, and future AI agents before they design, document, or implement anything related to **Kiosk / KDS / DID / CMS / POS integration**.

It teaches agents what Phase 3 means, which equipment and integration layers are in scope, and how Phase 3 relates to earlier and later phases—without authorizing implementation.

This document helps agents classify scope, define state authority, and plan reliability and recovery. It does **not** authorize runtime implementation, SQL changes, migrations, or production rollout.

## 2. Phase 3 Identity

Phase 3 is the **full Kiosk / KDS / DID / CMS / POS integration phase**.

The Phase 3 output becomes an infrastructure foundation for Phase 4 Franchise_OS, but Phase 3 itself must be defined by store equipment, kitchen display, customer display, content management, POS integration, order/payment consistency, and operational reliability.

| True identity | Phase 3 meaning |
| --- | --- |
| Equipment integration phase | Kiosk, Mini Kiosk enhancement, KDS, DID, CMS, POS |
| Operational reliability phase | Order, payment, cancel/refund consistency across surfaces |
| Evidence and recovery phase | Retry, idempotency, degraded mode, audit, manual recovery |

**Do not use these as the main definition:**

- Phase 3 is Franchise_OS preparation.
- Phase 3 is mainly Franchise_OS pre-work.
- Phase 3 focuses on headquarters/franchisee operations.
- Phase 3 is SCM/CRM preparation.

Phase 3 **stabilizes** the real-store equipment, order, payment, kitchen, display, and content integration layer. Phase 4 Franchise_OS later **depends on** this stability; Phase 3 is not Franchise_OS itself.

## 3. Phase Position

Current roadmap context:

| Phase | Summary |
| --- | --- |
| Phase 0 | Foundation, documentation system, development constitution |
| Phase 1 | Catch Menu MVP with OKPOS + Toss POS, KDS, waiting, Mini Kiosk; first-store testbed around **September 2027** (planning context) |
| Phase 1-B | SaaS transition preparation: takeout/delivery app, membership, DID/CMS, ~30 major POS providers (planning context) |
| Phase 2 | `yoonsul_os` store operation foundation: staff, membership, partial inventory (**separate project**) |
| **Phase 3** | **Kiosk / KDS / DID / CMS / POS integration** |
| Phase 1-C | Complete SaaS productization; absorbs common modules from Phase 2 and Phase 3; AI customer center, pgvector, RAG, Digital SOP, full multi-tenant isolation, market launch |
| Phase 4 | Full Franchise_OS implementation |
| Phase 5 | Franchise_OS AI customer center and integrated support enhancement |
| Phase 6 | Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement |
| Phase 7 | AI readiness and Physical AI Gateway preparation |

Phase 3 builds on Phase 1 OKPOS/Toss POS and equipment foundations. It prepares integration evidence for Phase 1-C and Phase 4; it does not replace them.

## 4. Phase 3 Scope

Phase 3 **includes**:

- Kiosk
- Mini Kiosk enhancement
- KDS
- DID
- CMS
- POS integration
- order state consistency
- payment state consistency
- cancel/refund state consistency
- kitchen routing
- pickup/display callout
- menu / price / option synchronization
- sold-out and availability synchronization
- equipment failure handling
- retry
- idempotency
- duplicate prevention
- manual recovery
- degraded mode
- audit event
- evidence packet

## 5. Kiosk Scope

Phase 3 Kiosk work **includes**:

- customer order input
- menu selection
- option selection
- quantity selection
- order number generation
- payment entry
- receipt or pickup number projection
- store-mode aware UI
- unavailable item handling
- fallback when kiosk cannot complete the order
- prevention of false finality (payment complete, order confirmed, pickup guaranteed without evidence)

## 6. KDS Scope

Phase 3 KDS work **includes**:

- kitchen order display
- station routing
- order bump
- preparing / ready state
- cancel and correction reflection
- duplicate display prevention
- kitchen workload visibility
- mismatch detection between order state and kitchen state

## 7. DID Scope

Phase 3 DID work **includes**:

- order number display
- ready-for-pickup callout
- pickup guidance
- store congestion display policy
- alignment with KDS state
- prevention of DID callout before the order is actually ready

## 8. CMS Scope

Phase 3 CMS work **includes**:

- menu image management
- menu description management
- banner and event content
- Kiosk display content
- DID display content
- store-level content configuration
- content deployment
- rollback
- prevention of CMS/POS menu mismatch

## 9. POS Integration Strategy

Phase 3 POS integration **starts from the Phase 1 OKPOS and Toss POS foundation**.

| Requirement | Rule |
| --- | --- |
| Reuse Phase 1 foundation | Phase 3 must reuse Phase 1 OKPOS and Toss POS basic connection |
| No silent redesign | Do not throw away or redesign that foundation without explicit human-approved change contract |
| Controlled expansion | Phase 3 may expand to additional major POS providers where feasible |
| Strategic goal | Build broader POS integration foundation so Phase 1-C Catch Menu SaaS full POS connection and market launch become easier |

Phase 3 POS work **is responsible for**:

- reusing Phase 1 OKPOS and Toss POS connection
- expanding POS adapter boundaries
- comparing provider differences
- creating a POS provider capability matrix
- normalizing order events
- normalizing payment events
- normalizing cancel/refund events
- normalizing status events
- detecting provider-specific limitations
- validating Kiosk / KDS / DID / CMS consistency with POS state
- preparing evidence for later SaaS-level POS expansion

Phase 3 POS work **must not**:

- claim every POS provider is production-ready without evidence
- hide provider differences
- treat payment success and order success as the same event
- skip reconciliation design where provider state requires it
- skip retry and duplicate prevention
- skip manual recovery
- pull Phase 1-C commercial SaaS launch responsibility into Phase 3
- pull Phase 6 full SaaS operational maturity into Phase 3

## 10. Relationship To Phase 1-C

Phase 3 POS and equipment integration becomes a **technical foundation** for Phase 1-C.

Phase 1-C uses the Phase 3 integration foundation to productize Catch Menu SaaS with broader POS support, AI customer center, pgvector, RAG, Digital SOP, full multi-tenant isolation, onboarding, support, and market launch.

| Phase | Role |
| --- | --- |
| Phase 3 | Integration foundation |
| Phase 1-C | SaaS productization and market launch |

## 11. Relationship To Phase 4 Franchise_OS

Phase 4 Franchise_OS will build on the stable Kiosk / KDS / DID / CMS / POS integration layer created in Phase 3.

Phase 4 **adds** (not Phase 3 main scope):

- SCM
- CRM
- headquarters / franchisee operations
- store and branch management
- policy distribution
- menu distribution
- approval workflow
- franchise management dashboard
- franchise-level audit and evidence review

Phase 3 must **not** implement SCM or CRM as its main scope. Phase 3 must **not** implement the full Franchise_OS headquarters/franchisee operation system.

## 12. Relationship To Phase 6

Phase 6 is **Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement**.

Phase 6 is where the SaaS operation model becomes more mature across both Franchise_OS SaaS and the earlier Catch Menu SaaS path.

Phase 6 **may include**:

- tenant isolation hardening
- billing / subscription model
- admin console
- franchise tenant / store tenant relationship
- SaaS-level audit and evidence
- release governance
- long-term provider support policy

Phase 3 should **prepare integration evidence**, not claim Phase 6-level SaaS maturity.

## 13. Non-Scope

Phase 3 is **not**:

- Catch Menu MVP (Phase 1 bounded scope)
- Catch Menu SaaS market launch
- Phase 1-C complete SaaS productization
- `yoonsul_os` staff / membership / partial inventory project (Phase 2)
- SCM implementation
- CRM implementation
- full Franchise_OS implementation
- Franchise_OS SaaS conversion (Phase 6)
- AI customer center full implementation
- Digital SOP automatic evolution
- Physical AI Gateway
- robot / IoT / sensor / vision control

## 14. Key Risks

| Risk | Impact |
| --- | --- |
| POS provider differences underestimated | Wrong adapters, hidden failures, false readiness claims |
| Payment success and order success treated as the same event | False finality, reconciliation gaps |
| Kiosk order and POS order duplicated | Double kitchen load, customer dispute |
| KDS state and POS state diverge | Wrong preparation, wrong pickup |
| DID displays ready before KDS is actually ready | Customer confusion, congestion |
| CMS menu/price/option data diverges from POS data | Wrong orders, trust loss |
| Sold-out status does not synchronize | Customer orders unavailable items |
| Cancel/refund state not reflected everywhere | Orphan payments, kitchen waste |
| Retry creates duplicate order or duplicate payment | Financial and operational incident |
| Provider timeout leaves order in unknown state | Stuck orders without recovery path |
| Manual recovery not possible | Store cannot recover during outage |
| Audit/evidence missing | No post-incident review or SaaS expansion proof |
| Phase 3 described as Franchise_OS implementation | Wrong scope and timeline |
| Phase 3 described as full SaaS market launch | Commercial commitment without productization |

## 15. Required Design Outputs Before Implementation

No Phase 3 implementation may begin without:

| Output | Requirement |
| --- | --- |
| `impact_scope` | Kiosk, KDS, DID, CMS, POS surfaces; provider list with evidence |
| `context_snapshot` | State authority map across order, payment, kitchen, display, CMS |
| `overview` | Phase 3 integration phase purpose and boundaries |
| `logic` | Normalized events, retry/idempotency, recovery, degraded mode |
| `test_plan` | Duplicate, timeout, unknown state, mismatch, false finality cases |
| `change_contract` | Allowed files **and** operations; provider-specific boundaries |
| `human approval` | Final merge and release authority |

## 16. Implementation Rules

- No implementation without the **51355** pipeline.
- Allowed files are not enough; **allowed operations** must also be specified.
- Kiosk / KDS / DID / CMS / POS integration must define **source of truth per state**.
- Payment success, order success, KDS ready, DID callout, and POS completion must be treated as **separate state events**.
- Retry, idempotency, duplicate prevention, manual recovery, and audit evidence are **mandatory design topics**.
- Phase 3 must **reuse** the Phase 1 OKPOS and Toss POS foundation unless a human-approved change contract says otherwise.
- Additional major POS providers may be added only through **controlled provider-specific scope**.
- No broad POS claim may be made without **provider-specific evidence**.

## 17. Tool Roles

| Actor | Role in Phase 3 |
| --- | --- |
| Claude Cowork | Context classification, design, documentation reasoning, audit |
| Codex | Restricted file creation or implementation **only after approval** |
| Cursor | Optional local IDE inspection helper only; **no autonomous edits** |
| Human | Final approval, merge, release |

## 18. Relationship To Other Documents

| Document / area | Relationship |
| --- | --- |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | Project-wide phase roadmap |
| `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` | Phase 1 MVP; OKPOS/Toss foundation to reuse |
| `000707_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md` | Separate Phase 2 project; not Phase 3 main scope |
| `000709_Guide_Phase_4_Franchise_OS_Prelearning_Context.md` | Phase 4 builds on Phase 3 integration layer |
| `000710_Guide_Phase_5_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md` | Later AI support phase |
| `000711_Guide_Phase_6_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md` | SaaS maturity phase |
| `000712_Guide_Phase_7_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md` | Physical AI readiness |
| `000001_Md_Rules.md` / `000002_Naming_Rules.md` | Documentation discipline |
| **51355 development pipeline** | Mandatory gate before implementation |
| `000500` AI agent prelearning folder | Shared onboarding entry point |

## 19. Final Rule

Phase 3 is the full Kiosk / KDS / DID / CMS / POS integration phase.
It is not primarily named as Franchise_OS preparation.
The Phase 3 output becomes an infrastructure foundation for Phase 4 Franchise_OS and Phase 1-C Catch Menu SaaS productization, but Phase 3 itself must stay focused on store equipment, kitchen display, customer display, content management, POS integration, order/payment consistency, reliability, recovery, audit, and evidence.
No implementation may start without scope, context, logic, test plan, change contract, and human approval.
