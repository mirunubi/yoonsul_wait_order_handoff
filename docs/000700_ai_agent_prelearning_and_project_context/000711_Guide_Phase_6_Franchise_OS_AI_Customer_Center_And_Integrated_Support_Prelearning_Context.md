# 000711_Guide_Phase_6_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md

## 1. Purpose

This document is the Phase 6 prelearning context for Claude Code, Claude, and future AI agents before they design, document, or implement anything related to **Franchise_OS AI customer center and integrated support enhancement**.

It teaches agents that Phase 6 is **not** a simple chatbot or generic FAQ layer. Extends the Phase 4 Catch Menu AI Customer Center module using Phase 5 no-outage events, SOP Runtime, and recovery evidence.

This document helps agents classify scope, define human approval boundaries, and plan knowledge evolution workflows. It does **not** authorize runtime implementation, SQL changes, migrations, or production rollout.

## 2. Core Identity

Phase 6 is **Franchise_OS AI customer center and integrated support enhancement**.

| Phase | AI customer center role |
| --- | --- |
| Phase 1-C | Launch-grade AI customer center **core** for Catch Menu SaaS market launch |
| **Phase 6** | **Post–Phase 5 enhancement**: Franchise_OS + full support center for complex HQ/franchisee/store/staff/operator inquiries and failure response |

Phase 6 is **different from** the Phase 1-C launch AI customer center. Phase 1-C provides the **minimum customer-support foundation for SaaS market launch**. Phase 6 comes **after Phase 5 Franchise_OS** and supports the complex inquiries and failure responses that headquarters, franchisees, branches, staff, customer-center agents, and operators actually encounter.

**Phase 6 does not rebuild the AI customer center module.** It extends the standalone module first built in `000709_Guide_Phase_4_Catch_Menu_AI_Customer_Center_Prelearning_Context.md` by attaching Franchise_OS no-outage events, SOP Runtime, and recovery evidence (all Phase 5 outputs) onto that same reusable module.

**Phase 6 core includes:**

- Franchise_OS dedicated AI customer center
- integrated support center enhancement
- Digital SOP enhancement
- RAG / pgvector operational knowledge search
- no-outage operation event–based inquiry response
- failure/recovery/evidence-based Q&A
- repeated inquiry detection
- unresolved inquiry event collection
- SOP creation candidate proposal
- human approval–based SOP reflection
- SOP version / rollback
- knowledge isolation and permission control for HQ / franchisee / staff / customer center

**Core principle:** The AI customer center is **not** the final authority. It finds operational knowledge, explains it, proposes SOP candidates, detects repeated inquiries, and raises approval requests to humans. It must **not** auto-finalize policy changes, final failure-response decisions, refunds, compensation, store closure, or permission changes without human approval.

## 3. Phase Position

Current roadmap context:

| Phase | Summary |
| --- | --- |
| Phase 0 | Foundation, documentation system, development constitution |
| Phase 1 | Catch Menu MVP with OKPOS + Toss POS, KDS, waiting, Mini Kiosk; first-store testbed around **September 2027** (planning context) |
| Phase 1-B | SaaS transition preparation: takeout/delivery app, membership, DID/CMS, ~30 major POS providers (planning context) |
| Phase 2 | `yoonsul_os` store operation foundation: staff, membership, partial inventory (**separate project**) |
| Phase 3 | Kiosk / KDS / DID / CMS / POS integration |
| Phase 1-C | Complete SaaS productization and market launch; **launch-grade AI customer center core** |
| Phase 5 | Franchise_OS no-outage restaurant operations system |
| **Phase 6** | **Franchise_OS AI customer center and integrated support enhancement** |
| Phase 7 | Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement |
| Phase 8 | AI readiness and Physical AI Gateway preparation |

## 4. Phase 6 Central Role

Phase 6 **must**:

- customer-centerize Franchise_OS operational knowledge
- convert no-outage Agent + SOP Runtime events into customer-support knowledge
- support failure-type Q&A
- guide recovery procedures
- provide answers matched to HQ / franchisee / staff permissions
- enable operational SOP search
- recommend Digital SOP
- collect unresolved inquiries
- turn repeated inquiries into SOP creation candidates
- reflect SOP changes only after human approval
- enhance overall customer-center quality
- build support infrastructure for Phase 7 Franchise_OS SaaS conversion

## 5. Franchise_OS AI Customer Center

The Franchise_OS AI customer center is **not** a chatbot that handles only end-customer questions. It must understand Franchise_OS operating structure, failure response, SOP, policy, approval workflow, SCM, CRM, membership, and POS/KDS/DID/CMS integration state.

**Target users:**

- headquarters administrator
- franchisee owner
- branch manager
- staff
- customer-center agent
- operations manager
- technical support staff
- end customer (where appropriate)

**Example inquiries:**

- What should the store do when a failure occurs?
- Which SOP should be selected for a POS failure?
- Is limited operation possible when KDS stops?
- How should customer callout work when DID is not displaying?
- When CMS menu and POS menu differ, what is source of truth?
- How to verify when HQ policy was not deployed to a branch?
- Who approves a franchisee price exception request?
- How to handle a menu item that cannot be sold due to SCM supply delay?
- Who approves CRM customer compensation or coupon issuance?
- How to verify missing orders or duplicate payments after a failure?

## 6. Integrated Support Center

Phase 6 is **not** only a Franchise_OS customer center. It is **integrated support center enhancement**.

**Full support center scope includes:**

- Catch Menu SaaS support
- Franchise_OS support
- POS/KDS/DID/CMS integration inquiries
- takeout/delivery/membership inquiries
- HQ/franchisee operation inquiries
- staff permission/role inquiries
- failure/recovery inquiries
- Digital SOP inquiries
- payment/order/cancel/refund state inquiries
- operating policy inquiries

The Phase 1-C launch AI customer center is the **basic support foundation**. Phase 6 **extends** it to include Franchise_OS and no-outage operation runtime—not replace it.

## 7. Digital SOP Enhancement

Phase 6 Digital SOP is **not** static document search. It is an operational knowledge system that evolves from real operation events and inquiry events.

**Digital SOP must cover:**

- failure response SOP
- recovery SOP
- limited operation SOP
- safe closure SOP
- POS failure SOP
- KDS failure SOP
- DID failure SOP
- CMS failure SOP
- payment failure SOP
- missing order SOP
- duplicate order SOP
- duplicate payment SOP
- customer notice SOP
- HQ approval SOP
- franchisee exception approval SOP
- SCM supply delay SOP
- CRM customer compensation SOP
- membership error SOP

SOP is not only a document. SOP is an **operational transition guide** and the **basis for customer-center answers**.

## 8. RAG / pgvector Role

RAG and pgvector are the **knowledge search layer**. They are **not** the final authority.

**Roles:**

- search related SOP
- search related policy
- search past cases by failure type
- search operation event records
- search evidence packets
- generate customer-center answer candidates
- search similar inquiries
- support repeated-inquiry pattern detection

**Warning:** Search results must **not** become the sole final basis for an answer. Answers must also verify permission, latest SOP, policy, operating state, and human approval status.

## 9. Unresolved Inquiry Event

When the AI customer center cannot answer, the inquiry must **not** end as silent failure. Unresolved inquiries are **inputs for operational knowledge evolution**.

**Unresolved inquiry events must record:**

- inquirer type
- inquiry domain
- inquiry content
- referenced SOP (if any)
- reference failure reason
- answer-failure reason
- similar existing inquiries
- store or tenant occurrence
- sensitive-information flag
- human-agent escalation need
- SOP-candidate need

## 10. Repeated Inquiry Detection

Repeated unresolved inquiries of the same type should become **SOP creation candidates**.

| Count | Action |
| --- | --- |
| 1 | log event |
| 2 | show similar-inquiry candidate |
| 3+ | propose SOP creation candidate |
| after human approval | generate SOP draft |
| after review | incorporate into Digital SOP |
| after deploy | version management |
| if problem | rollback |

Repeated inquiries are **not** customer-center quality failure—they are signals that the knowledge system should grow.

## 11. SOP Creation Candidate Workflow

Phase 6 requires an **SOP creation candidate workflow**:

1. new inquiry occurs
2. existing SOP/RAG search fails
3. unresolved inquiry event recorded
4. repetition detected
5. SOP creation candidate generated
6. human approval requested
7. after approval, Agent generates SOP draft
8. human review
9. incorporate into Digital SOP
10. version recorded
11. deploy
12. maintain rollback-ready state

**Important:** AI must **not** finalize an operating SOP as official documentation without human approval. AI creates candidates; humans approve.

## 12. Human Approval Boundary

The AI customer center must **not** finalize without human approval:

- refund
- compensation
- bulk coupon issuance
- policy change
- price change
- menu deployment
- branch exception approval
- permission change
- safe closure
- continued limited operation
- failure liability judgment
- legal/contractual answer finalization
- official SOP deployment

**AI may:**

- search related documents
- recommend SOP candidates
- summarize operation history
- classify inquiries
- generate answer drafts
- request human approval
- provide evidence links
- guide next actions

## 13. Role-Based Answer Isolation

Phase 6 AI customer center must vary answer scope by user type.

| User type | Answer scope |
| --- | --- |
| HQ administrator | brand-wide policy, branch issues, SCM/CRM summary, audit/evidence review, approval workflow |
| Franchisee owner | own store/branch info, operating SOP, failure/recovery records, customer inquiries, HQ policy lookup |
| Staff | procedures within own permission, kitchen/order/customer SOP, escalate to manager on failure, limited sensitive data |
| Customer-center agent | response SOP, customer notice wording, failure impact scope, compensation/refund approval need, escalation path |
| End customer | order status, pickup/takeout/delivery guidance, store notices, minimal personal data exposure |

## 14. Franchise_OS Operational Event Utilization

Phase 6 must use operational events produced by Phase 5 Franchise_OS.

**Events to utilize:**

- failure detection event
- failure classification event
- SOP selection event
- human approval event
- limited-operation transition event
- safe-closure judgment event
- recovery start event
- recovery complete event
- missing-order verification event
- duplicate-payment verification event
- customer notice event
- SCM supply delay event
- CRM compensation event
- policy change event
- permission change event
- evidence packet creation event

These events must be **structured** for accurate AI customer-center answers.

## 15. Integrated Support Center Enhancement

Phase 6 must enhance customer-center **operations** itself.

**Enhancement items:**

- inquiry type classification
- priority classification
- escalation rules
- human-agent handoff
- HQ / franchisee / staff inquiry separation
- customer vs operation inquiry separation
- failure vs general usage inquiry separation
- answer basis links
- SOP reference links
- evidence references
- consultation record storage
- repeated-inquiry statistics
- unresolved-inquiry statistics
- SOP enhancement candidate reports

## 16. Relationship To Phase 1-C

Phase 1-C includes **launch-grade AI customer center core** for market launch. Its purpose is Catch Menu SaaS launch and initial customer-support foundation.

Phase 6 **extends**—does not discard—the Phase 1-C AI customer center to cover Franchise_OS and the full support center.

| Phase | Role |
| --- | --- |
| Phase 1-C | Launch-grade AI customer center core |
| Phase 6 | Franchise_OS + full support center enhancement |

## 17. Relationship To Phase 5

Phase 5 implements Franchise_OS as the no-outage restaurant operations system: failure events, SOP Runtime, Human Authority Runtime, recovery evidence, SCM, CRM, policy, and approval workflow.

Phase 6 **converts** Phase 5 operational knowledge and events into customer-center knowledge.

| Phase | Role |
| --- | --- |
| Phase 5 | Operations runtime |
| Phase 6 | AI customer center that explains and supports the operations runtime |

## 18. Relationship To Phase 7

Phase 7 is Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement. Franchise_OS cannot be sold as SaaS without a customer-support system in place.

Phase 6 is a **prerequisite** for Phase 7.

**Without Phase 6:**

- SaaS onboarding is difficult
- HQ/franchisee inquiry response is difficult
- failure-response inquiries accumulate
- SOP does not stay current
- operational knowledge stays in people's heads
- customer-center cost explodes during SaaS expansion

## 19. Relationship To Phase 8

Phase 8 is AI readiness and Physical AI Gateway preparation. Phase 6 Digital SOP, operation events, failure/recovery history, and customer-center inquiry data become the foundation for Phase 8 AI integration.

However, Phase 6 AI customer center must **not** directly control physical devices. In Phase 8, Physical AI must still pass through safety gate, human override, authority boundary, and evidence.

## 20. Non-Scope

Phase 6 is **not**:

- Phase 1-C market launch itself
- Phase 5 Franchise_OS core implementation
- Phase 7 Franchise_OS SaaS conversion
- Phase 8 Physical AI device control
- automatic official SOP deployment without human approval
- refund/compensation/policy change without human approval
- safe-closure or continued limited-operation decision without human approval
- treating RAG search results as final authority
- treating pgvector as permission system
- unnecessary collection of customer personal data

## 21. Key Risks

| Risk | Impact |
| --- | --- |
| AI customer center reduced to simple FAQ chatbot | Misses Franchise_OS operational support value |
| Not connected to Phase 5 operation events | Answers disconnected from real store state |
| SOP candidates deployed without human approval | Unsafe official procedures |
| Over-trusting RAG search as final answer | Wrong policy/SOP guidance |
| Missing role-based answer isolation | Data leakage, wrong authority exposure |
| Mixing HQ/franchisee/staff/customer inquiries | Wrong escalation and liability |
| Treating failure inquiries like general usage | Wrong urgency and SOP |
| Not logging unresolved inquiries | Knowledge system cannot evolve |
| Ignoring repeated inquiries as SOP enhancement signal | Same failures repeat |
| Missing answer basis / evidence links | No audit or review |
| No support system before Phase 7 SaaS | SaaS launch support collapse |
| Customer center assumed to control devices (Phase 8) | Safety and authority violation |

## 22. Required Design Outputs Before Implementation

No Phase 6 implementation may begin without:

| Output | Requirement |
| --- | --- |
| `impact_scope` | AI customer center, Digital SOP, RAG/pgvector, role isolation, event ingestion |
| `context_snapshot` | Phase 5 events, Phase 1-C foundation, tenant/permission boundaries |
| `overview` | Integrated support enhancement purpose and boundaries |
| `logic` | Inquiry flow, unresolved/repeated inquiry, SOP candidate, human approval |
| `test_plan` | Wrong authority, leakage, auto-SOP deploy, RAG-only answers, event gaps |
| `change_contract` | Allowed files **and** operations; AI vs human approval limits |
| `human approval` | Final merge and release authority |

## 23. Implementation Rules

- No implementation without the **000701** controlled AI development pipeline.
- Allowed files are not enough; **allowed operations** must also be specified.
- AI customer center is **not** the final authority.
- Digital SOP official reflection requires **human approval**.
- RAG and pgvector are search/recommendation layers, **not** policy authorities.
- Answers must verify permission, SOP, policy, latest operating state, and evidence together.
- Unresolved inquiries must be recorded as **unresolved inquiry events**.
- Repeated inquiries must convert to **SOP creation candidates**.
- Answer scope must be separated for HQ / franchisee / staff / customer center / end customer.
- Support events and knowledge structure must be designed **tenant-safe** for Phase 7 SaaS.

## 24. Tool Roles

| Actor | Role in Phase 6 |
| --- | --- |
| Claude Code | Context classification, design, documentation reasoning, restricted file creation or implementation **only after approval**, local verification |
| Claude | Design verification and independent audit |
| Human | Final approval, merge, release |

## 25. Relationship To Other Documents

| Document / area | Relationship |
| --- | --- |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | Project-wide phase roadmap |
| `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` | Phase 1 MVP; Phase 1-C launch context |
| `000707_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md` | Separate Phase 2 project |
| `000708_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md` | Phase 3 integration events for support Q&A |
| `000710_Guide_Phase_5_Franchise_OS_Prelearning_Context.md` | Phase 5 operation events and SOP Runtime source |
| `000712_Guide_Phase_7_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md` | Phase 7 SaaS; Phase 6 is prerequisite |
| `000713_Guide_Phase_8_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md` | Phase 8; no direct device control from Phase 6 |
| `000001_Md_Rules.md` / `000002_Naming_Rules.md` | Documentation discipline |
| **000701 controlled AI development pipeline** | Mandatory gate before implementation |
| `000500` AI agent prelearning folder | Shared onboarding entry point |

## 26. Final Rule

Phase 6 is Franchise_OS AI customer center and integrated support enhancement.
It extends the Phase 1-C launch-grade AI customer center to convert Phase 5 Franchise_OS no-outage operation events, SOP Runtime, recovery evidence, SCM, CRM, policy, and approval workflow into customer-support knowledge.
The AI customer center is not the final authority.
RAG and pgvector are search/recommendation layers, not official policy authorities.
Unresolved and repeated inquiries must feed Digital SOP evolution; official SOP reflection is allowed only after human approval.
No implementation may start without scope, context, logic, test plan, change contract, and human approval.
