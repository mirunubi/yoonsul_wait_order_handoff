# 000713_Guide_Phase_8_AI_Readiness_And_Physical_AI_Gateway_Prelearning_Context.md

## 1. Purpose

This document is the Phase 8 prelearning context for Claude Code, Claude, and future AI agents before they design, document, or implement anything related to **AI readiness and Physical AI Gateway**.

It teaches agents that Phase 8 is **not** simple AI feature addition or direct robot/IoT device control. Phase 8 prepares the **safety gate, authority boundary, human override, and evidence system** that must exist before AI connects to real store operations and physical devices.

This document helps agents classify scope and define actuation boundaries. It does **not** authorize runtime implementation, SQL changes, migrations, or production rollout.

## 2. Core Identity

Phase 8 is **AI readiness and Physical AI Gateway**.

Phase 8 builds the **safety gateway structure** that AI must pass through when connecting to store operations, kitchen, devices, sensors, robots, voice, vision, and IoT.

**Phase 8 core includes:**

- AI readiness
- Physical AI Gateway
- sensor event intake
- device event intake
- robot / IoT / vision / voice connection preparation
- human override
- safety gate
- authority boundary
- actuation evidence
- no direct uncontrolled AI actuation
- safe connection between no-outage operations runtime and the physical world
- AI integration preparation on top of Phase 5 Franchise_OS, Phase 6 AI customer center, and Phase 7 SaaS operations

**Core principle:** AI must **not** control physical devices directly at will. Any AI intervention in store operations or physical devices must pass through **Physical AI Gateway**. Every physical control must have **safety gate, authority boundary, human override, evidence**, and rollback or recovery path.

## 3. Phase Position

Current roadmap context:

| Phase | Summary |
| --- | --- |
| Phase 0 | Foundation, documentation system, development constitution |
| Phase 1 | Catch Menu MVP (planning context) |
| Phase 1-B | SaaS transition preparation (planning context) |
| Phase 2 | `yoonsul_os` store operation foundation (**separate project**) |
| Phase 3 | Kiosk / KDS / DID / CMS / POS integration |
| Phase 1-C | Complete SaaS productization and market launch |
| Phase 5 | Franchise_OS no-outage restaurant operations system |
| Phase 6 | AI customer center / Digital SOP / RAG / pgvector / integrated support |
| Phase 7 | Franchise_OS SaaS conversion + Phase 1 SaaS enhancement |
| **Phase 8** | **AI readiness and Physical AI Gateway** |

## 4. AI Readiness

Phase 8’s first purpose is **AI readiness**.

AI readiness is **not** simply attaching an LLM. If AI cannot understand operational events, SOP, failure history, customer-center inquiries, store state, and device state—and still act safely—it must **not** be integrated.

**AI readiness requires:**

- structured operational events
- organized Digital SOP
- clear authority boundaries
- clear tenant boundaries
- separated device-control permissions
- human override structure
- defined safety conditions
- defined prohibited actions
- evidence recording structure
- fallback / recovery path
- separation of AI action **proposal** from actual **actuation**

**AI may:**

- analyze situations
- recommend SOP
- suggest failure cause candidates
- propose action candidates
- draft customer notice wording
- guide staff on next steps
- explain risk level
- request human approval
- summarize evidence

**AI must not without human approval:**

- operate physical devices
- control kitchen equipment
- operate robots
- control gas/electricity-related systems
- decide store closure
- decide continued limited operation
- finalize refund/compensation
- change policy or permissions
- execute actions with safety risk

## 5. Physical AI Gateway

Physical AI Gateway is the **safe intermediate layer** between AI and the physical world.

**Gateway purpose:**

- separate AI recommendations from actual device control
- verify safety conditions before device control
- verify human approval status
- verify authorized user
- verify controllable scope
- verify recovery path on failure
- record every actuation event as evidence

**Why the Gateway is required:** If AI customer center or Agent controls devices directly, risk is unacceptable. Physical control in store operations connects to safety, legal liability, customer harm, and staff harm. AI is **not** the direct controller—it must submit **controlled control requests** through the Gateway.

## 6. Sensor / Device Event Intake

Phase 8 must prepare to collect sensor and device events.

**Collectible events include:**

- temperature sensors
- refrigerator temperature
- cooking equipment state
- electricity state
- gas state
- door open/close
- camera/vision events
- voice command events
- robot status events
- POS device state
- Kiosk device state
- KDS device state
- DID device state
- printer state
- network state
- store congestion
- kitchen workload
- order delay state

**Important:** Sensor events are **inputs to operational judgment**, not raw truth. Sensor data can be wrong—AI must **not** finalize physical control from a single sensor reading.

## 7. Voice / Vision / Robot / IoT Preparation

Phase 8 prepares voice, vision, robot, and IoT integration.

**Voice:** staff voice commands, kitchen voice KDS, failure voice reporting, customer callout assist — requires confirmation due to misrecognition risk.

**Vision:** cooking state, queue detection, congestion, pickup area state, safety hazard detection — requires privacy and misrecognition controls.

**Robot:** serving, pickup assist, transport, kitchen assist robots — requires human traffic and safety radius consideration.

**IoT:** refrigerators, cooking equipment, lighting, DID, Kiosk, sensors, kitchen equipment — distinguish **controllable** vs **observation-only** devices.

## 8. Human Override

Human override is one of Phase 8’s **most important** principles.

Every AI integration and physical control must allow **human interruption**.

**Human override is required when:**

- AI judgment is uncertain
- sensor values conflict
- customer safety is affected
- staff safety is affected
- device control fails
- behavior differs from expectation
- operator must switch to manual handling
- legal/hygiene/safety judgment is needed

Human override is **not** a simple button. It must include permission, logging, recovery procedure, and responsibility boundaries.

## 9. Safety Gate

Physical AI Gateway must include a **safety gate**.

**Safety gate must verify:**

- whether AI may control the device
- whether the user has approval authority
- whether control is safe in current store state
- whether the action affects customer/staff safety
- whether it conflicts with other device states
- whether recovery is possible on failure
- whether manual stop is possible
- whether evidence will be recorded
- whether an SOP exists
- whether human approval is required for this action

**AI control without safety gate is forbidden.**

## 10. Authority Boundary

Phase 8 must define clear authority boundaries.

**Authority subjects:** AI Agent, store staff, manager, franchisee owner, HQ administrator, technical support, customer-center agent, platform administrator.

**Permission types:** observe, recommend, request approval, execute, interrupt, recover, audit.

**AI default permissions:** observe, analyze, recommend, request approval, organize evidence.

**AI default prohibitions:** physical control without human approval; safety decisions without human approval; refund/compensation; policy/permission changes without human approval.

## 11. Actuation Evidence

Physical control or operational intervention must leave **evidence**.

**Must record:**

- what event occurred
- who requested action
- what AI judged
- what SOP was referenced
- who approved
- what device was controlled
- state before and after control
- failure and recovery status
- human override usage
- customer/staff impact
- follow-up action need

Actuation evidence must be usable across Phase 5 Franchise_OS, Phase 6 AI customer center, and Phase 7 SaaS operations.

## 12. Relationship To Phase 5

Phase 5 Franchise_OS is the no-outage restaurant operations system: detect failure, select SOP, hand off to humans, support limited operation or safe closure.

Phase 8 prepares AI and physical device integration **on top of** that runtime.

Phase 8 must **not** break Phase 5 principles: human authority, SOP selection, recovery evidence, and safe-closure boundary remain mandatory.

## 13. Relationship To Phase 6

Phase 6 provides AI customer center, Digital SOP, RAG, pgvector, and integrated support enhancement.

Phase 8 uses Phase 6 Digital SOP and operational knowledge as the basis for AI/Physical AI integration.

However, Phase 6 AI customer center must **not** directly control physical devices. In Phase 8, AI customer center may recommend and guide—but physical control must pass through **Physical AI Gateway**.

## 14. Relationship To Phase 7

Phase 7 is Franchise_OS SaaS conversion plus Phase 1 SaaS enhancement.

Phase 8 AI/Physical AI expansion is safe only on Phase 7 SaaS operating foundation.

**Phase 7 must provide:** tenant isolation, SaaS admin console, billing/subscription, AI customer center linkage, audit/evidence, release governance, provider support policy, onboarding/support system.

Phase 8 uses this SaaS foundation to prepare AI integration.

## 15. Non-Scope

Phase 8 is **not**:

- first implementation of Phase 5 Franchise_OS core
- first implementation of Phase 6 AI customer center core
- first implementation of Phase 7 Franchise_OS SaaS conversion
- robot control without human approval
- device control without human approval
- gas/electricity control without human approval
- safe closure without human approval
- continued limited operation without human approval
- AI as final responsible authority
- automatic judgment from sensor data alone
- physical control without evidence
- AI judgment ignoring tenant boundaries
- vision/voice processing without privacy protection

## 16. Key Risks

| Risk | Impact |
| --- | --- |
| AI directly controls physical devices | Safety incident, liability |
| No human override | Cannot stop unsafe action |
| No safety gate | Uncontrolled actuation |
| No authority boundary | Wrong actor executes control |
| Trusting sensor errors as truth | Wrong physical action |
| Voice misrecognition as execute command | Unintended device operation |
| Vision without privacy control | Compliance violation |
| Robot paths ignore human safety | Injury risk |
| Treating kitchen equipment control lightly | Fire/safety incident |
| Actuation without evidence | No audit or recovery |
| AI auto-decides safe closure during failure | Unsafe or wrong closure |
| Bypassing Phase 5 no-outage principles | Operational chaos |
| Phase 6 customer center as physical controller | Authority violation |
| Phase 7 tenant isolation missing; cross-store AI reference | Data leakage |

## 17. Required Design Outputs Before Implementation

No Phase 8 implementation may begin without:

| Output | Requirement |
| --- | --- |
| `impact_scope` | Gateway, intake domains, actuation boundaries |
| `context_snapshot` | Phase 5/6/7 dependencies, permission and tenant map |
| `overview` | AI readiness and Gateway purpose |
| `logic` | Safety gate, override, proposal vs actuation, evidence |
| `test_plan` | False sensor/voice/vision, missing override, unsafe actuation |
| `change_contract` | Allowed files **and** operations; forbidden direct control |
| `human approval` | Final merge and release authority |

## 18. Implementation Rules

- No implementation without the **000701** controlled AI development pipeline.
- Allowed files are not enough; **allowed operations** must also be specified.
- AI is **not** the final authority.
- No physical device control without **Physical AI Gateway**.
- No device control without **safety gate**.
- No device control without **human override** capability.
- Every actuation must leave **evidence**.
- Sensor/voice/vision input must be treated as **uncertain**.
- AI judgment must be **tenant-safe**.
- Do **not** bypass Phase 5 no-outage operating principles.
- Separate Phase 6 knowledge search from Phase 8 physical control.
- Expand AI integration only on Phase 7 SaaS operating foundation.

## 19. Tool Roles

| Actor | Role in Phase 8 |
| --- | --- |
| Claude Code | Context classification, design, documentation reasoning, restricted file creation or implementation **only after approval**, local verification |
| Claude | Design verification and independent audit |
| Human | Final approval, merge, release |

## 20. Relationship To Other Documents

| Document / area | Relationship |
| --- | --- |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | Project-wide phase roadmap |
| `000710_Guide_Phase_5_Franchise_OS_Prelearning_Context.md` | No-outage runtime principles to preserve |
| `000711_Guide_Phase_6_Franchise_OS_AI_Customer_Center_And_Integrated_Support_Prelearning_Context.md` | Digital SOP knowledge; not physical controller |
| `000712_Guide_Phase_7_Franchise_OS_SaaS_And_Phase_1_SaaS_Enhancement_Prelearning_Context.md` | SaaS foundation for safe AI expansion |
| `000001_Md_Rules.md` / `000002_Naming_Rules.md` | Documentation discipline |
| **000701 controlled AI development pipeline** | Mandatory gate before implementation |
| `000500` AI agent prelearning folder | Shared onboarding entry point |

## 21. Final Rule

Phase 8 is AI readiness and Physical AI Gateway.
Before AI connects to store operations, sensors, robots, voice, vision, IoT, or device control, safety gate, authority boundary, human override, and actuation evidence must be in place.
AI is not the final authority.
Physical control must pass through Physical AI Gateway and must not execute without human approval and safety conditions.
Phase 8 prepares AI integration on top of Phase 5 no-outage operating principles, Phase 6 Digital SOP knowledge foundation, and Phase 7 SaaS operating foundation.
No implementation may start without scope, context, logic, test plan, change contract, and human approval.
