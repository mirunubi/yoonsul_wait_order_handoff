# 000709_Guide_Phase_4_Catch_Menu_AI_Customer_Center_Prelearning_Context.md

## 1. Purpose

This document is the Phase 4 prelearning context for Claude Code, Claude, and future AI agents before they design, document, or implement anything related to **Catch Menu AI Customer Center**.

Phase 4 builds the **AI customer center module first**, independent of Franchise_OS SOP Runtime. Phase 6 (Franchise_OS AI Customer Center) later **extends this same module** — it does not rebuild it.

This document does **not** authorize runtime implementation, SQL changes, migrations, or production rollout.

## 2. Core Identity

Phase 4 is **Catch Menu's own AI customer center**, built as a reusable module before Franchise_OS exists.

| True identity | Phase 4 meaning |
| --- | --- |
| Module-first phase | Build the AI customer center architecture (RAG pipeline, unresolved-inquiry tracking, SOP-candidate flow) before attaching Franchise_OS SOP Runtime |
| Catch Menu scope only | Answers customer inquiries about menu, waiting, pickup, order status |
| Reusable foundation | Phase 6 attaches Franchise_OS SOP Runtime, recovery evidence, and role isolation onto this same module |

**Do not use as the main definition:**
- Phase 4 is a full Franchise_OS AI customer center.
- Phase 4 requires Franchise_OS SOP Runtime or no-outage events to function.

## 3. Phase Position

| Phase | Summary |
| --- | --- |
| Phase 1 | Catch Menu real-store MVP |
| Phase 2 | `yoonsul_os` store runtime (separate project) |
| Phase 3 | Kiosk / KDS / DID / CMS / POS integration |
| **Phase 4** | **Catch Menu AI Customer Center (this document)** |
| Phase 5 | Franchise_OS no-outage restaurant operations system |
| Phase 6 | Franchise_OS AI Customer Center — extends Phase 4's module with Phase 5 events |
| Phase 7 | Full SaaS integration |
| Phase 8 | AI readiness and Physical AI Gateway |

Phase 4 comes after Phase 1 (Catch Menu must exist for there to be customer inquiries) and does **not** depend on Phase 5 Franchise_OS.

## 4. Phase 4 Scope

Phase 4 **includes**:

- customer inquiry intake (menu, waiting, pickup, order status questions)
- FAQ-style answers grounded in Catch Menu's own knowledge (menu content, store hours, basic policy)
- RAG/pgvector search pipeline, scoped to Catch Menu knowledge sources only
- unresolved-inquiry logging
- repeated-inquiry detection (signal for future SOP candidates)
- minimal SOP-candidate flagging (no automatic SOP publishing)
- human review path for anything the module cannot answer confidently

Phase 4 **does not include**:

- Franchise_OS SOP Runtime integration
- no-outage event consumption
- recovery evidence consumption
- role-based isolation across HQ/franchisee/staff (single Catch Menu context only)
- refund, compensation, or policy decisions

## 5. Relationship To Phase 6 (Critical)

Phase 6 does not rebuild the AI customer center. Phase 6 **extends** the Phase 4 module by attaching:

- Franchise_OS no-outage events (Phase 5 output)
- SOP Runtime and recovery evidence (Phase 5 output)
- Role-based answer isolation (HQ / franchisee / staff / agent / customer)
- Human approval workflow for official SOP publishing

The RAG pipeline, unresolved-inquiry tracking, and SOP-candidate flow built in Phase 4 must be designed so Phase 6 can attach these inputs **without rearchitecting the module**. This is the central design risk of Phase 4: if the Phase 4 module is built too narrowly for Catch Menu alone, Phase 6 will end up rebuilding it instead of extending it.

## 6. Key Runtime Concepts

| Concept | Phase 4 meaning |
| --- | --- |
| inquiry intake | Structured customer question capture tied to Catch Menu context only |
| RAG search | Retrieval scoped to Catch Menu knowledge (menu, hours, pickup policy) |
| unresolved inquiry | Question the module could not answer confidently; logged for review |
| repeated inquiry | Same unresolved question recurring; signal for a future SOP candidate |
| SOP candidate (minimal) | Flag only; Phase 4 does not auto-publish SOP |
| module reusability | Architecture must allow Phase 6 to attach Franchise_OS inputs later |

## 7. Key Risks

| Risk | Why it matters |
| --- | --- |
| Module built too narrowly for Catch Menu only | Phase 6 must rebuild instead of extend — defeats Phase 4's purpose |
| RAG sources not clearly scoped | Answers leak store-runtime or Franchise_OS-level assumptions that don't exist yet |
| Auto-answering low-confidence questions | Wrong customer-facing information without human review |
| No unresolved-inquiry logging | Phase 6 has no signal data to build SOP candidates from later |
| Treating this as a full customer-service chatbot | Overbuilds Phase 4 scope prematurely |

## 8. Required Design Outputs Before Implementation

| Output | Requirement |
| --- | --- |
| `impact_scope` | Catch Menu knowledge sources, inquiry surfaces, explicit Franchise_OS exclusion |
| `context_snapshot` | Catch Menu-only context; no Franchise_OS SOP Runtime assumptions |
| `overview` | Phase 4 as standalone, Phase-6-extensible module |
| `logic` | RAG pipeline, unresolved-inquiry tracking, SOP-candidate flagging |
| `test_plan` | Low-confidence handling, unresolved logging, repeated-inquiry detection |
| `change_contract` | Allowed files and operations; no Franchise_OS runtime paths |
| `human approval` | Final merge and release authority |

## 9. Implementation Rules

- No implementation without the `000701` controlled AI development pipeline.
- Allowed files are not enough; allowed operations must also be specified.
- RAG knowledge sources must be explicitly scoped to Catch Menu content.
- Low-confidence answers must route to human review, not auto-answer.
- The module's data model must not hardcode Catch-Menu-only assumptions that would block Phase 6 extension (e.g., inquiry records should carry a tenant/scope field even if only one value is used today).

## 10. Tool Roles

| Actor | Role in Phase 4 |
| --- | --- |
| Claude Code | Boundary scan, design drafting, implementation within approved scope, local verification |
| Claude | Design verification, contract lock, independent audit |
| Human | Final approval, merge, release |

## 11. Relationship To Other Documents

| Document / area | Relationship |
| --- | --- |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | Project-wide phase roadmap |
| `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` | Source of the knowledge domain Phase 4 answers questions about |
| `000710_Guide_Phase_5_Franchise_OS_Prelearning_Context.md` | Provides the SOP Runtime/events that Phase 6 later attaches |
| `000711_Guide_Phase_6_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md` | Extends this Phase 4 module |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | Mandatory gate before implementation |

## 12. Final Rule

Phase 4 builds Catch Menu's AI customer center as a standalone, reusable module.

Phase 6 does not rebuild it — Phase 6 attaches Franchise_OS SOP Runtime, recovery evidence, and role isolation onto this same module.

No implementation may start without scope, context, logic, test plan, change contract, and human approval.
