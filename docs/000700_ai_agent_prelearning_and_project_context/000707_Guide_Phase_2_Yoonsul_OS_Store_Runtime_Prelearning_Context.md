# 000707_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md

## 1. Purpose

This document is the Phase 2 prelearning context for Claude Cowork, Codex, Cursor, and future AI agents before they design, document, or implement anything related to the **`yoonsul_os`** project.

It teaches agents the **responsibility scope and non-scope** of Phase 2 work centered on **staff**, **membership**, and **partial inventory** inside a single-store internal operations foundation.

This document helps agents classify scope, avoid merging Phase 2 with Catch Menu, and avoid pulling Franchise_OS implementation forward. It does **not** authorize runtime implementation, SQL changes, migrations, or production rollout.

## 2. Core Definition

| Statement | Meaning |
| --- | --- |
| Phase 2 is **not** the Catch Menu backend runtime | Catch Menu and Phase 2 are separate projects |
| Phase 2 is a **completely separate project** from Catch Menu | No shared customer-entry or waiting-handoff assumption |
| Phase 2 is a **precursor to Franchise_OS** | Single-store internal operations base before headquarters/franchise structure |
| Phase 2 is **not** Franchise_OS itself | Franchise_OS full implementation belongs to Phase 4 |

**Phase ladder (product position):**

| Phase | Project / role |
| --- | --- |
| Phase 1 | **Catch Menu** — separate customer-entry project |
| Phase 2 | **`yoonsul_os`** — separate in-store operations project (staff, membership, partial inventory) |
| Phase 3 | Preparatory work for Phase 4 Franchise_OS |
| Phase 4 | **Franchise_OS** full implementation |

Phase 2 organizes **single-store internal operations** first. Staff, membership, and partial inventory are built so Phase 3 can prepare data, permission, policy, and store-expansion structures, and Phase 4 can implement Franchise_OS at headquarters and branch level.

## 3. Phase Position

Phase 2 comes **after** Phase 0 foundation, documentation governance, AI prelearning, the **51355** pipeline, and Phase 1 Catch Menu as a **parallel / separate track**—not as Catch Menu's downstream runtime.

Phase 2 comes **before**:

| Later phase | Summary |
| --- | --- |
| Phase 3 | Kiosk, KDS, DID, CMS, POS integration hardening; Franchise_OS preparatory work |
| Phase 4 | Franchise_OS full implementation |
| Phase 5 | AI customer center, digital SOP, RAG, pgvector |
| Phase 6 | Full Catch Menu and Franchise_OS SaaS integration |
| Phase 7 | Physical AI Gateway |

Phase 2 does **not** depend on Catch Menu handoff, waiting runtime, or customer-entry surfaces.

## 4. Central Capabilities (Phase 2 Scope)

Phase 2 **includes** single-store internal operations centered on:

- staff management
- staff roles and permissions
- shift / operation records
- membership
- customer identification
- packaging (takeout) request **within membership / in-store operations**
- delivery request **within membership / in-store operations**
- membership-based payment
- order and payment history
- **partial inventory** (not full ERP)
- minimum inventory state linked to menu sellability
- basic management functions required for store operation

## 5. Staff Capabilities

Phase 2 staff scope **includes**:

| Area | Requirement |
| --- | --- |
| Staff accounts | Identifiable staff actors for store operations |
| Staff roles | Role model for operational separation |
| Admin vs staff authority | Manager/admin vs line-staff permission boundary |
| Shift / operation state | Work status and operational context |
| Action audit trail | Record of who performed sensitive actions |
| Unauthorized action blocking | Functions blocked when role lacks permission |
| Per-staff handling history | Traceability for staff-driven operations |

## 6. Membership Capabilities

Phase 2 membership scope **includes**:

- customer identification
- regular-customer (loyalty) management
- order and payment history
- membership tier or basic membership state
- packaging request (membership / in-store channel)
- delivery request (membership / in-store channel)
- payment tied to membership flows
- reorder possibility
- coupons, stamps, or points only at **minimum** or explicitly **expandable** scope—do not over-build loyalty complexity in Phase 2 by default

## 7. Partial Inventory Capabilities

Phase 2 inventory is **not** full ERP inventory.

| Principle | Phase 2 meaning |
| --- | --- |
| Scope | Minimum inventory needed for store operation |
| Focus | Ingredient-level items that affect menu sellability |
| Priority | Operational sold-out judgment over exact cost/accounting inventory |
| Audit | Inventory change log is required |
| Link | Inventory state must connect to menu availability where applicable |

Do not expand Phase 2 inventory into full cost accounting, procurement ERP, or franchise-wide supply chain.

## 8. Packaging And Delivery Request (Membership Scope)

Packaging and delivery requests in Phase 2 are **not** the same as Catch Menu Phase 1 takeout order request.

| Aspect | Phase 2 rule |
| --- | --- |
| Channel | Membership customers or in-store membership functions |
| Definition | Part of **membership / store operations**, not Catch Menu customer entry |
| Payment | May require payment within membership flows (see §9) |
| Separation | Do not merge with Catch Menu waiting, handoff, or customer-entry language |

When cross-phase context is needed, state only: **separate from Phase 1 Catch Menu**.

## 9. Payment (Phase 2 Minimum)

Membership-based packaging and delivery requests **require payment capability** in Phase 2.

Phase 2 payment tracking **includes** (minimum):

- payment state
- payment history
- failure records
- cancel-required state

Phase 2 payment **does not include** (defer to later phases):

- full PG/POS reconciliation
- settlement and provider-grade dispute handling
- refund automation at enterprise grade
- full financial closeout

## 10. Relationship To Catch Menu (Phase 1)

**Catch Menu and Phase 2 `yoonsul_os` are completely separate projects.**

Agents working on Phase 2 must **not** use or imply:

- Catch Menu backend runtime
- waiting handoff
- customer queue handoff
- customer entry surface ownership
- Mini Kiosk / KDS / POS basic handoff from Phase 1
- Phase 1 order accept / reject flow as Phase 2 responsibility

If phase relationship must be mentioned, use only neutral wording such as **separate from Phase 1 Catch Menu**.

## 11. Relationship To Franchise_OS

Phase 2 is the **precursor stage** before Franchise_OS.

| Step | Action |
| --- | --- |
| Phase 2 | Organize staff, membership, and partial inventory for a **single store** |
| Phase 3 | Prepare data structures, permission structures, policy structures, and store-expansion structures for Franchise_OS |
| Phase 4 | Implement Franchise_OS itself (headquarters, branch, approval, rollout) |

Do not pull Franchise_OS headquarters/branch control-room implementation into Phase 2.

## 12. Non-Scope

Phase 2 is **not**:

- Catch Menu backend runtime
- waiting handoff
- customer queue handoff
- Mini Kiosk / KDS / POS handoff (Phase 1 bounded integration)
- Phase 1 order accept / reject processing
- full POS integration
- full KDS / DID / CMS integration
- official delivery-app API integration
- Franchise_OS full implementation
- AI customer center
- automatic SOP generation
- Physical AI Gateway
- robot / IoT / sensor actuation integration
- full PG settlement, reconciliation, and refund hardening

## 13. Key Runtime Concepts

| Concept | Phase 2 meaning |
| --- | --- |
| single-store operations | All Phase 2 defaults assume one store context unless explicitly approved otherwise |
| staff authority | Role-gated operations with audit trail |
| membership identity | Customer identification inside store operations, not Catch Menu guest session |
| partial inventory | Operational sold-out support, not ERP |
| menu sellability link | Inventory affects whether items can be sold |
| membership packaging/delivery request | In-store membership channel; not Catch Menu takeout request |
| minimum payment tracking | State and history without full settlement stack |
| Franchise_OS precursor | Foundation only; not franchise control room |

## 14. Key Risks

| Risk | Why it matters |
| --- | --- |
| Treating Phase 2 as Catch Menu backend | Wrong architecture and duplicated customer flows |
| Adding waiting / queue handoff to Phase 2 | Violates phase separation; belongs to Catch Menu / other lanes |
| Mixing membership packaging/delivery with Catch Menu takeout request | Confused customer journeys and state models |
| Expanding payment into full settlement system | Scope creep into Phase 3+ financial hardening |
| Expanding partial inventory into ERP-level stock | Wrong cost, timeline, and ownership model |
| Exposing sensitive functions without staff permission | Security and operational abuse risk |
| Pulling Franchise_OS implementation into Phase 2 | Premature multi-tenant and HQ/branch complexity |
| Building CRUD screens without runtime state model | Staff and membership flows diverge from truth |
| Collecting unnecessary customer personal data | Privacy and scope violation |

## 15. Required Design Outputs Before Implementation

No Phase 2 implementation may begin without:

| Output | Requirement |
| --- | --- |
| `impact_scope` | Staff, membership, partial inventory, payment minimum; explicit Catch Menu exclusion |
| `context_snapshot` | Single-store operations context; no Catch Menu handoff assumptions |
| `overview` | Phase 2 as separate `yoonsul_os` internal operations project |
| `logic` | Staff permissions, membership flows, inventory change log, payment state minimum |
| `test_plan` | Permission denial, inventory sold-out link, payment failure, phase-boundary violations |
| `change_contract` | Allowed files **and** allowed operations; Catch Menu paths forbidden unless approved |
| `human approval` | Final merge and release authority |

## 16. Implementation Rules

- No implementation without the **51355** pipeline.
- Allowed files are not enough; **allowed operations** must also be specified.
- Every feature must define **runtime state source of truth** and **staff authority** requirements.
- Do **not** reference Catch Menu as Phase 2 backend, handoff target, or waiting runtime.
- Packaging/delivery in Phase 2 is **membership / in-store operations** only.
- Payment remains **minimum tracking**; defer reconciliation and settlement hardening.
- Inventory remains **partial and operational**; defer ERP scope.
- Phase 2 remains **single-store** until Phase 3/4 expansion artifacts are approved.
- Do not represent Phase 2 as Franchise_OS or Catch Menu completion.

## 17. Tool Roles

| Actor | Role in Phase 2 |
| --- | --- |
| Claude Cowork | Context classification, design, documentation reasoning, audit, phase-boundary enforcement |
| Codex | Restricted file creation or implementation **only after approval** |
| Cursor | Optional local IDE inspection helper only; **no autonomous edits** |
| Human | Final approval, merge, release |

## 18. Relationship To Other Documents

| Document / area | Relationship |
| --- | --- |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | Project-wide phase map |
| `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` | **Separate project** — do not merge scope |
| `000508` through `000512` | Later phases; Franchise_OS prep and full implementation |
| `000001_Md_Rules.md` / `000002_Naming_Rules.md` | Documentation discipline |
| **51355 development pipeline** | Mandatory gate before implementation |
| `000500` AI agent prelearning folder | Shared onboarding entry point |

## 19. Final Rule

Phase 2 **`yoonsul_os` is not the Catch Menu backend runtime**.

Phase 2 is **completely separate** from Catch Menu.

Phase 2 is the **Franchise_OS precursor** centered on **staff**, **membership**, and **partial inventory** for single-store internal operations.

Phase 2 has **no waiting handoff**.

Within the **membership** domain, **packaging request**, **delivery request**, and **payment** are in scope at minimum operational depth.

| Phase | Definition |
| --- | --- |
| Phase 1 | Catch Menu project |
| Phase 2 | `yoonsul_os` staff / membership / partial inventory |
| Phase 3 | Franchise_OS preparatory work |
| Phase 4 | Franchise_OS full implementation |

**No implementation may start** without scope, context, logic, test plan, change contract, and human approval.
