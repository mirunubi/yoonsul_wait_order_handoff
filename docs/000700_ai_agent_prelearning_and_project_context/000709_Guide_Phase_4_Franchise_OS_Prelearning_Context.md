# 000709_Guide_Phase_4_Franchise_OS_Prelearning_Context.md

## 1. Purpose

This document is the Phase 4 prelearning context for Claude Cowork, Codex, Cursor, and future AI agents before they design, document, or implement anything related to **Franchise_OS**.

It teaches agents what Phase 4 Franchise_OS means, why it exists, and which runtime and governance layers are in scope—without authorizing implementation.

Phase 4 Franchise_OS must be understood as a **no-outage restaurant operations system**, not merely as a common franchise administration tool. This document helps agents classify scope, define human authority boundaries, and plan failure response, recovery, and evidence. It does **not** authorize runtime implementation, SQL changes, migrations, or production rollout.

## 2. Core Identity

Franchise_OS is a **no-outage restaurant operations system**.

| Common but not the core | Core differentiator |
| --- | --- |
| Headquarters / franchisee administration | No-Outage Store Operations Agent + SOP Runtime |
| SCM | Failure observation, resource judgment, operating SOP selection |
| CRM | Human authority handoff, fallback/degraded operation, recovery evidence |
| Menu and policy distribution | Controlled safe closure when operation is unsafe |

Franchise_OS is **not merely** headquarters/franchisee administration, SCM, CRM, or menu and policy distribution. Those modules are **necessary**, but they are **common**. The unique reason for Franchise_OS is the **Agent + SOP Runtime** that helps the store survive operational failures.

The core differentiator of Franchise_OS is the **No-Outage Store Operations Agent + SOP Runtime**.

When partial failures occur, Franchise_OS must observe the failure, judge available resources, select an operating SOP, hand off final authority to a human operator, support fallback or degraded operation, record recovery evidence, and guide safe closure when operation is unsafe.

The original reason for building Franchise_OS is to help a food-service store **continue operating during partial failures when safe operation is still possible**, and to **guide controlled safe closure when operation is unsafe**.

## 3. Phase Position

Current roadmap context:

| Phase | Summary |
| --- | --- |
| Phase 0 | Foundation, documentation system, development constitution |
| Phase 1 | Catch Menu MVP with OKPOS + Toss POS, KDS, waiting, Mini Kiosk; first-store testbed around **September 2027** (planning context) |
| Phase 1-B | SaaS transition preparation: takeout/delivery app, membership, DID/CMS, ~30 major POS providers (planning context) |
| Phase 2 | `yoonsul_os` store operation foundation: staff, membership, partial inventory (**separate project**) |
| Phase 3 | Kiosk / KDS / DID / CMS / POS integration |
| Phase 1-C | Complete SaaS productization; absorbs common modules from Phase 2 and Phase 3; AI customer center, pgvector, RAG, Digital SOP, full multi-tenant isolation, market launch |
| **Phase 4** | **Franchise_OS** |
| Phase 5 | Franchise_OS AI customer center and integrated support enhancement |
| Phase 6 | Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement |
| Phase 7 | AI readiness and Physical AI Gateway preparation |

Phase 4 builds on Phase 3 store equipment and POS integration. It prepares structured failure, recovery, and authority evidence for Phase 5 and Phase 6; it does not replace them.

## 4. Phase 4 Scope

Phase 4 **must include**:

- No-Outage Store Operations Agent + SOP Runtime
- Human Authority Runtime
- Observation / Input Federation
- Runtime Federation
- Recovery / SOP Federation
- failure detection
- failure classification
- available resource judgment
- operating SOP selection
- fallback operation
- degraded operation
- controlled safe closure
- recovery history
- audit event
- evidence packet
- headquarters / franchisee / store / branch operations
- SCM
- CRM
- menu distribution
- policy distribution
- role and permission management
- approval workflow
- franchise operations dashboard

## 5. No-Outage Store Operations Agent + SOP Runtime

This is the **center** of Franchise_OS.

The Runtime must connect:

- store operation events
- failure detection
- failure type classification
- resource availability judgment
- operating SOP selection
- human authority handoff
- fallback operation
- degraded operation
- recovery workflow
- audit trail
- evidence packet
- safe closure decision support

**Core principle:**

The store should not close easily.
If partial operation is still safe, the system should help the store continue operating through fallback or degraded operation.
If safe operation is not possible, the system must guide controlled safe closure.

**Agent responsibility:**

- observe
- diagnose
- classify
- correlate
- recommend
- select candidate SOP
- hand off to human authority
- record recovery evidence
- support recovery synchronization

**Agent must not:**

- become the final legal or operational authority
- approve store operation without a human
- approve safe closure without a human
- execute payment/refund/settlement decisions without a human-approved operation path
- change franchise policy without authority
- hide uncertainty or unknown state

## 6. Observation / Input Federation

Franchise_OS must observe and classify many failure sources.

**Input domains include:**

- Main Server / Cloud failure
- authentication server failure
- database failure
- network / internet failure
- delivery app or external API failure
- POS failure
- Kiosk failure
- Mini Kiosk failure
- WebApp failure
- KDS failure
- kitchen display failure
- DID failure
- CMS failure
- tablet failure
- store Wi-Fi failure
- electricity failure
- gas failure
- printer failure
- payment provider failure
- POS provider failure
- local server failure
- government emergency order
- partial failure
- compound failure

**Important:** The system must not treat a failure only as a technical error code. It must judge **how the failure affects store operation**.

| Example | Operational meaning |
| --- | --- |
| POS failure | May mean payment failure, order transmission failure, receipt printing failure, or status sync failure—each requires a different SOP |
| Internet failure | May block external orders, but local KDS/POS/Kiosk operation may still be possible |
| KDS failure | May not mean the store cannot take orders; may require kitchen print, tablet, or manual kitchen handoff |

## 7. Resource Availability Judgment

Franchise_OS must judge what is **still available** during failure.

The system must evaluate:

- POS availability
- Kiosk availability
- Mini Kiosk availability
- KDS availability
- DID availability
- WebApp availability
- tablet availability
- local server availability
- cloud server availability
- internet availability
- store Wi-Fi availability
- printer availability
- payment availability
- cash payment availability
- kitchen operation availability
- staff availability
- inventory availability
- ingredient availability
- gas safety
- electricity safety
- external delivery channel availability
- headquarters server availability
- store network availability

**Core question:**

What still works?

This is more important than only asking:

What failed?

## 8. SOP Selection

After failure type and available resources are identified, Franchise_OS must select an **operating SOP**.

**SOP examples:**

- server failure SOP
- internet failure SOP
- POS failure SOP
- Kiosk failure SOP
- KDS failure SOP
- DID failure SOP
- CMS failure SOP
- payment failure SOP
- delivery app failure SOP
- electricity failure SOP
- gas failure SOP
- compound failure SOP
- limited operation SOP
- temporary manual order SOP
- temporary tablet Kiosk SOP
- direct POS order SOP
- customer notice SOP
- safe closure SOP
- recovery synchronization SOP
- audit log review SOP

**Important:** SOP is not only a document. SOP is an **operational transition mechanism**.

## 9. Human Authority Runtime

Franchise_OS must preserve **human authority**.

**Human roles include:**

- decide
- authorize
- execute
- own
- take responsibility

**The Agent can:**

- detect a failure
- classify a failure
- analyze impact
- recommend an operating mode
- suggest an SOP
- hand off to staff or manager
- guide recovery
- record evidence

**The Agent must not:**

- finalize store operation continuation without human authority
- finalize safe closure without human authority
- finalize payment/refund/settlement without human-approved operation path
- finalize policy change without authority
- finalize permission change without authority
- become the responsible owner of a store operation decision

Final authority belongs to human operators such as owner, manager, store manager, or headquarters administrator.

## 10. Runtime Federation

Franchise_OS must coordinate multiple runtime systems.

**Runtime Federation includes:**

- KDS
- POS
- Kiosk
- Mini Kiosk
- WebApp
- CMS
- DID
- HR
- Payroll
- Inventory
- SCM
- CRM
- Fulfillment
- Membership
- Coupon
- Payment
- Local Server
- Cloud Server
- Agent Server

**Purpose:** When some systems are alive and others are down, Franchise_OS must determine which combination can keep the store operating.

**Examples:**

- POS is down, but KDS and tablet are alive.
- Internet is down, but local server and Kiosk/KDS are alive.
- Kiosk is down, but POS and staff tablet are alive.
- DID is down, but KDS and staff callout are alive.
- CMS is down, but previously deployed menu content can still be used.
- Delivery app channel is down, but in-store and phone orders are possible.

## 11. Recovery / SOP Federation

Franchise_OS must support **recovery** after failure.

**Recovery includes:**

- failure recovery
- resynchronization
- missing order check
- duplicate order check
- duplicate payment check
- cancel/refund state verification
- KDS/POS state realignment
- CMS content redeployment
- DID display state recovery
- temporary manual order entry
- temporary operation record cleanup
- audit log storage
- recovery history record

**Important:** Operational continuity is not enough. After recovery, the data must be **reconciled**.

**Recovery checks must include:**

- Was any order lost?
- Was any order duplicated?
- Was any payment duplicated?
- Was any cancel/refund missed?
- Does KDS completion state match POS state?
- Were manual orders entered back into the system?
- Is any customer notice still required?
- Is audit/evidence preserved?

## 12. Operating Continuity Decision

Franchise_OS must support three operating decisions.

### 12.1 Continue Operation

Use when the failure is partial and safe operation is still possible.

**Examples:**

- DID failure
- CMS failure
- one Kiosk failure
- non-critical display failure
- external delivery channel failure while in-store operation is safe

### 12.2 Limited / Fallback Operation

Use when normal operation is difficult but a safe alternative exists.

**Examples:**

- Kiosk disabled and POS direct ordering is used.
- Internet disabled and local orders are processed.
- KDS disabled and kitchen print/manual handoff is used.
- external delivery app disabled and only in-store or phone orders continue.
- POS status sync delayed and manual recovery mode is used.

### 12.3 Safe Closure

Use when operation is unsafe or legally/physically impossible.

**Examples:**

- electricity and gas are both unavailable
- fire
- flooding
- government emergency order
- food safety risk
- operation cannot be tracked safely
- payment/order state is too uncertain to continue safely

**Core principle:**

Continue if safe.
Limit if necessary.
Close safely if unsafe.

## 13. General Franchise Modules And Their Correct Position

SCM, CRM, menu distribution, policy distribution, role management, approval workflow, audit, and evidence are **required**. However, they must **support** the no-outage operations runtime. They are **not** the primary differentiator.

### SCM

SCM must support operational continuity by exposing supply and ingredient state.

It may support:

- headquarters ingredient/product management
- store ordering
- supply request
- inbound confirmation
- partial inventory linkage
- sold-out and availability impact
- supply event log
- branch supply status
- supply exception handling

SCM must help the system answer:

Can the store keep selling this menu item?
Can the store continue with a reduced menu?
Is this a supply issue, inventory issue, or operational issue?

### CRM

CRM must support customer guidance, recovery, compensation, membership support, and franchise customer operations.

It may support:

- customer management
- regular customer management
- membership customer management
- affected customer identification
- customer notice after failure
- coupon or compensation workflow
- branch-level customer relationship
- brand-level customer relationship
- minimal personal data collection
- customer data access control

CRM must help the system answer:

Which customers were affected by the failure?
Who needs notice?
Who may need compensation?
Which customer data can staff access?

### Menu / Policy Distribution

Menu and policy distribution must support both normal operations and fallback operations.

It may support:

- headquarters standard menu
- store-level menu override
- price exception
- option exception
- menu deployment
- menu rollback
- policy deployment
- store exception policy
- operating hour policy
- takeout policy
- delivery policy
- membership policy
- discount policy

It must help the system answer:

What can this store sell right now?
Which policy applies during this failure?
Can the branch use an exception?

### Role / Permission / Approval Workflow

Role, permission, and approval workflow must define who can approve operating decisions.

It may support:

- headquarters administrator
- franchisee owner
- store manager
- staff
- temporary staff
- approver
- auditor
- permission group
- approval request
- pending approval
- approved
- rejected
- held
- rollback request
- permission change log

It must help the system answer:

Who can approve this fallback mode?
Who can approve safe closure?
Who can override a branch policy?
Who owns the decision?

## 14. Relationship To Phase 3

Phase 3 is the **Kiosk / KDS / DID / CMS / POS integration phase**.

Phase 3 creates the store equipment, kitchen display, customer display, content management, POS integration, order/payment consistency, reliability, recovery, audit, and evidence foundation.

Phase 4 Franchise_OS **uses** the Phase 3 integration foundation.

However, Phase 4 is **not** just a continuation of Phase 3. Phase 4 adds the **no-outage store operations runtime** and **franchise-level governance**.

## 15. Relationship To Phase 1-C

Phase 1-C is **complete SaaS productization and market launch**.

Phase 1-C absorbs common modules from Phase 2 and Phase 3, AI customer center, pgvector, RAG, Digital SOP, full multi-tenant isolation, and market launch.

Phase 4 does **not** repeat Phase 1-C market launch.

Phase 4 builds Franchise_OS after the Phase 1-C SaaS productization path is established.

## 16. Relationship To Phase 5

Phase 5 is **Franchise_OS AI customer center and integrated support enhancement**.

Phase 4 must produce structured events, SOP usage records, recovery records, failure categories, customer notice events, approval events, and audit/evidence records.

Phase 5 uses those records to improve:

- headquarters Q&A
- franchisee Q&A
- staff support
- customer center support
- Digital SOP
- RAG / pgvector knowledge retrieval
- unresolved inquiry handling
- SOP creation candidate workflow
- human approval for SOP updates
- versioning and rollback

## 17. Relationship To Phase 6

Phase 6 is **Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement**.

Phase 4 builds Franchise_OS capability.

Phase 6 turns Franchise_OS into a SaaS product and enhances the earlier Phase 1 SaaS path.

Phase 6 **may include**:

- Franchise_OS SaaS productization
- Phase 1 SaaS enhancement
- multi-tenant isolation hardening
- headquarters tenant / franchisee tenant / store tenant separation
- subscription and billing
- SaaS admin console
- provider support policy
- release governance
- SaaS-level audit and evidence
- long-term operations model

Phase 4 must prepare clean domain boundaries and evidence, but it must **not** claim Phase 6 SaaS maturity.

## 18. Relationship To Phase 7

Phase 7 is **AI readiness and Physical AI Gateway preparation**.

Phase 7 may connect AI, IoT, robot, vision, voice, sensor events, and device control.

Phase 4 must **not** directly implement Physical AI control.

However, Phase 4 must preserve the principle that any future AI or physical device action must pass through:

- safety gate
- human override
- authority boundary
- evidence record
- recovery path

## 19. Non-Scope

Phase 4 is **not**:

- Phase 1 Catch Menu MVP
- Phase 1-C SaaS market launch itself
- Phase 3 Kiosk/KDS/DID/CMS/POS implementation itself
- Phase 5 full AI customer center enhancement
- Phase 6 Franchise_OS SaaS conversion
- Phase 7 Physical AI device control
- robot / IoT / sensor / vision direct control
- fully autonomous store operation without human authority
- automatic safe closure without human authority
- generic SCM/CRM-only franchise management software

## 20. Key Risks

| Risk | Impact |
| --- | --- |
| Franchise_OS reduced to a common SCM/CRM system | Core no-outage value lost |
| No-outage operations runtime treated as optional | Store cannot survive partial failures |
| Agent treated as final authority | Unsafe operation, legal/operational liability |
| Human approval bypassed | Unauthorized continuation or closure |
| SOP treated only as static documentation | Staff cannot transition to fallback modes |
| Failure response does not produce recovery evidence | No post-incident review or Phase 5 input |
| Recovery does not reconcile orders, payments, display states | Hidden duplicates, lost orders |
| System recommends continued operation when unsafe | Customer/staff safety risk |
| Safe closure conditions too weak | Store continues in untrackable state |
| Runtime Federation missing | Cannot judge what still works |
| Compound failures treated like single failures | Wrong SOP selected |
| Customer notice omitted | Trust loss, dispute |
| Staff cannot understand fallback mode | Operational chaos |
| Headquarters cannot review what happened | No franchise governance |
| Phase 5 AI customer center cannot use logs (unstructured) | RAG/SOP evolution blocked |
| Phase 6 SaaS conversion difficult (authority/tenant boundaries undefined) | Multi-tenant isolation failure |

## 21. Required Design Outputs Before Implementation

No Phase 4 implementation may begin without:

| Output | Requirement |
| --- | --- |
| `impact_scope` | Agent/SOP runtime, federation layers, SCM/CRM support boundaries |
| `context_snapshot` | Failure sources, resource map, human authority roles, Phase 3 dependencies |
| `overview` | No-outage operations system purpose and boundaries |
| `logic` | Failure classification, SOP selection, handoff, recovery, reconciliation |
| `test_plan` | Partial/compound failure, unsafe continuation, safe closure, recovery gaps |
| `change_contract` | Allowed files **and** operations; Agent vs human authority limits |
| `human approval` | Final merge and release authority |

## 22. Implementation Rules

- No implementation without the **51355** pipeline.
- Allowed files are not enough; **allowed operations** must also be specified.
- Franchise_OS must be centered on **no-outage store operations**.
- SCM and CRM must be designed as **supporting modules** for no-outage operations.
- Agent must observe, diagnose, recommend, hand off, and record recovery.
- **Human authority** must remain final.
- Operating continuity, limited operation, and safe closure must be **separated**.
- Recovery evidence is **mandatory**.
- Runtime Federation is **mandatory**.
- SOP selection is **mandatory**.
- Manual recovery path is **mandatory**.
- Future Phase 5 AI customer center must be able to use structured failure and recovery events.
- Future Phase 6 SaaS conversion must be able to use authority, tenant, and audit boundaries.
- Future Phase 7 Physical AI must not bypass human authority, safety gate, or evidence.

## 23. Tool Roles

| Actor | Role in Phase 4 |
| --- | --- |
| Claude Cowork | Context classification, design, documentation reasoning, audit |
| Codex | Restricted file creation or implementation **only after approval** |
| Cursor | Optional local IDE inspection helper only; **no autonomous edits** |
| Human | Final approval, merge, release |

## 24. Relationship To Other Documents

| Document / area | Relationship |
| --- | --- |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | Project-wide phase roadmap |
| `000706_Guide_Phase_1_Catch_Menu_Prelearning_Context.md` | Phase 1 MVP foundation |
| `000707_Guide_Phase_2_Yoonsul_OS_Store_Runtime_Prelearning_Context.md` | Separate Phase 2 project |
| `000708_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md` | Phase 3 integration foundation Franchise_OS builds on |
| `000710_Guide_Phase_5_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md` | Phase 5 AI customer center enhancement |
| `000711_Guide_Phase_6_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md` | Phase 6 SaaS conversion |
| `000712_Guide_Phase_7_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md` | Phase 7 Physical AI readiness |
| `000001_Md_Rules.md` / `000002_Naming_Rules.md` | Documentation discipline |
| **51355 development pipeline** | Mandatory gate before implementation |
| `000500` AI agent prelearning folder | Shared onboarding entry point |

## 25. Final Rule

Phase 4 Franchise_OS is a no-outage restaurant operations system.
SCM, CRM, menu distribution, policy distribution, role management, approval workflow, audit, and evidence are required modules, but they are not the core differentiator.
The core differentiator is the Agent + SOP Runtime that helps the store continue operating during partial failures, supports fallback or degraded operation when safe, records recovery evidence, and guides controlled safe closure when operation is unsafe.
The Agent is not the final authority.
Final decision, authorization, execution, ownership, and responsibility remain with humans.
No implementation may start without scope, context, logic, test plan, change contract, and human approval.
