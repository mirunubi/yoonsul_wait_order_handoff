# 000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md

## 1. Purpose

This document is the Phase 1 prelearning context for Claude Code, Claude, and future AI agents before they design, document, or implement anything related to the Catch Menu project surface.

It teaches agents what Phase 1 means in this repository: a bounded real-store MVP that connects customer entry, menu browsing, waiting, takeout order request, pickup status, Mini Kiosk basic projection, basic KDS display, and basic POS handoff for OKPOS and Toss POS.

This document helps agents classify scope, avoid false finality, and respect phase boundaries. It does **not** authorize runtime implementation, SQL changes, migrations, payment behavior, or production rollout.

## 2. Naming And Service Clarification

- **Catch Menu** is a **project name / working name** used in Phase 1 documentation and prelearning.
- Catch Menu is **not** necessarily the final public service name, customer-facing brand, trademark, or commercial SaaS product name.
- AI agents must **not** assume that "Catch Menu" is the final confirmed public brand or a completed external SaaS offering.
- The document may still use "Catch Menu" as the internal project name for Phase 1 planning and design.
- The project is **not** expected to become the actual external SaaS service immediately in Phase 1.
- The actual external SaaS service plan is expected **after Phase 5 AI development** is complete enough to support AI customer center, digital SOP, RAG, and operational knowledge workflows.
- The current rough planning target for external SaaS service timing is **early 2029**. This is planning context only, **not** a release commitment or guarantee.
- AI agents must not describe Phase 1 as an immediately complete commercial SaaS service or final public launch.

## 3. Phase Position

Phase 1 comes **after**:

- Phase 0 foundation
- documentation governance
- AI prelearning (`000500` folder)
- the **000701** controlled AI development pipeline (AI-assisted financial-grade development pipeline)

Phase 1 prepares the **first real-store MVP** for field validation in a live store context. It is not a documentation-only phase, but it is still bounded and not a full commercial SaaS rollout.

Phase 1 comes **before**:

| Later phase | Summary |
| --- | --- |
| Phase 1-B | SaaS expansion and broader store equipment integration |
| Phase 2 | `yoonsul_os` store runtime foundation |
| Phase 3 | Kiosk, KDS, DID, CMS, POS integration hardening (beyond Phase 1 basic bounds) |
| Phase 4 | Franchise_OS preparation and operation |
| Phase 5 | AI customer center, digital SOP, RAG, pgvector |
| Phase 6 | Full Catch Menu and Franchise_OS SaaS integration; **full multi-tenant POS coverage planning** |
| Phase 7 | Physical AI Gateway |

## 4. Phase 1 Scope

Phase 1 is **not only a menu UI**. It is the first real-store MVP connecting the Catch Menu project surface with operational store flows.

Phase 1 **includes**:

- customer entry
- menu browsing
- menu categories
- menu detail
- option selection
- sold-out state display
- store open/close state display
- waiting entry
- **takeout order request**
- pickup status
- Mini Kiosk basic screen projection
- basic KDS order display
- basic POS handoff
- **OKPOS basic connection** (Phase 1 limited target)
- **Toss POS basic connection** (Phase 1 limited target)
- staff accept / reject / preparing / ready / completed flow
- simple customer handoff

Phase 1 POS integration is **basic, bounded, and field-validation oriented**. It supports real-store learning; it does not represent full POS provider coverage.

## 5. Takeout Order Request

Takeout order request is a **core Phase 1 feature** because phone takeout orders create store bottlenecks, staff interruption, and inconsistent customer expectations.

Phase 1 should reduce phone-order friction by letting customers submit a structured request through the Catch Menu surface. The first version should treat takeout as an **order intent or request**, not as a fully final paid order.

Use cautious, evidence-backed customer-facing language:

| Allowed progression (when runtime evidence supports each step) | Meaning |
| --- | --- |
| request submitted | Customer intent was captured |
| waiting for store confirmation | Store has not yet accepted |
| store accepted | Staff accepted the request |
| preparing | Store is preparing the order |
| ready for pickup | Customer may be notified to pick up |

Do **not** use false finality unless runtime evidence explicitly supports it, such as:

- payment completed
- order fully confirmed (when only a request exists)
- pickup time guaranteed
- POS settlement complete

Agents must tie customer-facing status text to a defined runtime state source of truth.

## 6. Mini Kiosk / KDS / Basic POS Boundary

Phase 1 **may include**:

- Mini Kiosk basic projection
- KDS basic display
- basic POS handoff
- OKPOS basic connection
- Toss POS basic connection

Phase 1 **does not include**:

- full POS provider coverage
- all major POS providers
- full KDS / DID / CMS integration
- payment reconciliation
- settlement
- refund flows at provider grade
- provider-grade recovery, replay, or dispute handling

OKPOS and Toss POS are the **only** Phase 1 basic POS connection targets. Do not generalize their assumptions to other POS providers.

## 7. Phase 1-B Boundary

Phase 1-B is the **SaaS expansion and broader equipment connection** step after the Phase 1 real-store MVP proves core flows.

Phase 1-B **may include**:

- subscription-style internal SaaS validation
- takeout / pickup / membership app usage for small stores
- additional major POS providers beyond OKPOS and Toss POS
- stronger KDS connection
- DID connection
- CMS connection
- store configuration expansion
- stronger SaaS operation model

Phase 1-B is still **not** the final full POS coverage phase. It expands validation; it does not replace Phase 6 full SaaS and full POS planning.

## 8. Phase 6 Boundary

**Full POS connection planning belongs to Phase 6.**

Phase 6 is the stage where Catch Menu-related SaaS and Franchise_OS SaaS move toward **complete multi-tenant commercial service integration**, including full POS-provider coverage at the service level.

Do **not** pull full POS coverage, all-major-provider support, or final SaaS commercial integration into Phase 1 or Phase 1-B documentation, design, or implementation scope.

## 9. Non-Scope

Phase 1 is **not**:

- final public service launch
- final SaaS service
- full payment implementation
- full POS integration
- all major POS provider support
- full KDS / DID / CMS integration
- delivery app integration
- Franchise_OS
- AI customer center
- Physical AI Gateway
- full commercial SaaS rollout

## 10. Key Runtime Concepts

Agents working on Phase 1 must understand these concepts and trace them to explicit state sources:

| Concept | Phase 1 meaning |
| --- | --- |
| menu projection | Customer-visible menu derived from store runtime; must reflect sold-out and store status |
| store runtime state projection | Open/close and operational gates that block or allow customer actions |
| waiting intent | Customer waiting entry without false queue-time guarantees |
| takeout order request | Structured intent/request, not assumed paid or fully confirmed order |
| pickup handoff | Customer notification boundary when pickup may be available |
| Mini Kiosk projection | Basic in-store kiosk surface; not full kiosk product suite |
| KDS basic display | Basic kitchen display of accepted/preparing orders; not full KDS product |
| basic POS handoff | Bounded handoff to OKPOS or Toss POS; not full gateway lifecycle |
| OKPOS / Toss POS boundary | Phase 1-only POS targets; provider-specific rules must not be generalized |
| sold-out state | Must match menu availability; stale sold-out display is a critical failure |
| store status | Open/close must gate requests and handoff |
| false finality prevention | Customer UI must not imply payment, confirmation, or pickup guarantees without evidence |

## 11. Key Risks

| Risk | Why it matters |
| --- | --- |
| Customer sees sold-out item as available | Creates failed orders and staff rework |
| Customer submits request while store is closed | Wastes staff time and breaks trust |
| Menu / option / price mismatch | Legal, operational, and customer-trust failure |
| Takeout request looks like confirmed order too early | False finality and dispute risk |
| KDS display and POS handoff diverge | Kitchen and front-of-house operate on different truth |
| OKPOS and Toss POS assumptions generalized to all POS providers | Wrong integration design in later phases |
| Staff workflow becomes harder instead of easier | Phase 1 fails its bottleneck-reduction goal |
| Phone order bottleneck is not actually reduced | Phase 1 business value is not achieved |
| Customer personal data collected unnecessarily | Privacy and scope violation |
| AI agents describe Phase 1 as the final SaaS service | Misaligned roadmap, sales, and implementation expectations |

## 12. Required Design Outputs Before Implementation

No Phase 1 implementation may begin without these approved artifacts:

| Output | Requirement |
| --- | --- |
| `impact_scope` | Lists surfaces, stores, POS targets (OKPOS/Toss only), and forbidden zones |
| `context_snapshot` | Smallest complete context for menu, waiting, takeout request, kiosk, KDS, POS handoff |
| `overview` | Phase 1 real-store MVP purpose and boundaries |
| `logic` | State machine for request, staff actions, sold-out, store status, handoff |
| `test_plan` | Closed store, sold-out, mismatch, false finality, POS divergence cases |
| `change_contract` | Explicit allowed files **and** allowed operations |
| `human approval` | Final merge/release authority |

## 13. Implementation Rules

- No implementation without the **000701** controlled AI development pipeline.
- Allowed files are not enough; **allowed operations** must also be specified.
- Even UI work must define the **runtime state source of truth**.
- Customer-facing finality language must be **evidence-backed**.
- Mini Kiosk, KDS, and POS features must remain **basic and bounded** in Phase 1.
- **OKPOS** and **Toss POS** are the Phase 1 basic POS targets only.
- Do not generalize Phase 1 POS logic to all POS providers.
- Do not represent Phase 1 as a commercial SaaS launch or final public service.
- Do not treat "Catch Menu" as the confirmed final brand name in customer-facing copy without human-approved branding guidance.

## 14. Tool Roles

| Actor | Role in Phase 1 |
| --- | --- |
| Claude Code | Context classification, design, documentation reasoning, risk framing, restricted file creation or implementation **only after approval**, local verification |
| Claude | Design verification and independent audit |
| Human | Final approval, merge, release |

## 15. Relationship To Other Documents

Conceptual cross-references (read before proposing Phase 1 work):

| Document / area | Relationship |
| --- | --- |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | Project-wide phase roadmap; Phase 1 position |
| `000001_Md_Rules.md` | Markdown and documentation discipline |
| `000002_Naming_Rules.md` | File naming and folder placement |
| **000701 controlled AI development pipeline** | Mandatory gate before implementation |
| `000500` AI agent prelearning folder | Shared onboarding entry point |
| `000507` through `000512` | Later phase prelearning; do not merge their scope into Phase 1 |

Phase 1 connects forward to Phase 1-B, Phase 2 store runtime, and later POS/KDS hardening only through **approved handoff boundaries**.

## 16. Final Rule

Phase 1 Catch Menu is **not just UI**.

It is **not** the final public SaaS service.

It is the **first real-store MVP** that connects customer entry, waiting, takeout request, pickup status, Mini Kiosk, basic KDS, and basic POS handoff for **OKPOS and Toss POS**.

Full SaaS service is planned later, after Phase 5 AI development matures, with **early 2029** as a rough planning target only—not a release guarantee.

**No implementation may start** without scope, context, logic, test plan, change contract, and human approval.
