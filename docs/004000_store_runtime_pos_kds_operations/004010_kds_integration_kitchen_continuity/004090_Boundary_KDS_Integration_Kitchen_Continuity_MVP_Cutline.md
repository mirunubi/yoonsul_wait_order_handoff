# 004090_Boundary_KDS_Integration_Kitchen_Continuity_MVP_Cutline.md

1\. Purpose

This document defines the MVP cutline for KDS integration and kitchen continuity.

The purpose is to separate what must be included in the first viable KDS integration from what should remain as later expansion.

The MVP must protect kitchen continuity before advanced optimization.

A KDS integration is useful only if the store can continue operating safely when KDS is delayed, degraded, unavailable, or partially disconnected.

2\. Scope

This document applies to:

\- KDS integration MVP boundary
\- POS accepted order to KDS ticket projection
\- Basic kitchen ticket lifecycle
\- Retry, remake, and delay policy
\- Degraded operation policy
\- Manual kitchen note fallback
\- Sold-out and menu availability readiness
\- Replay and duplicate prevention
\- Staff adoption readiness
\- Kitchen continuity acceptance criteria

This document does not define:

\- Full KDS vendor integration
\- Full inventory engine
\- Full AI prediction engine
\- Full station optimization
\- Full robot or physical AI handoff
\- Full financial settlement
\- Full customer recovery automation
\- Full HQ analytics product
\- Full implementation schema

3\. MVP Philosophy

The KDS MVP must be designed around operational survival, not feature richness.

The first question is not:

Can the kitchen screen show many advanced features?

The first question is:

Can the kitchen keep preparing the right items safely when the normal KDS flow is imperfect?

Therefore, the MVP must prioritize:

\- Clear POS/KDS boundary
\- Accepted order projection
\- Kitchen ticket visibility
\- Modifier and allergy preservation
\- Basic ticket states
\- Delay/remake/retry handling
\- Duplicate prevention
\- Manual fallback
\- Recovery evidence
\- Staff usability

Advanced automation must wait until the boundary is stable.

4\. Core Principles

The MVP must preserve the following principles:

POS is transaction authority.
KDS is kitchen execution visibility.
KDS ticket is a projection, not an order.
Replay is not mutation.
Retry is not new order creation.
Remake is not automatic refund.
Delay is not automatic compensation.
Manual note is evidence, not POS truth.
Sold-out does not retroactively mutate accepted orders.
Dismissed does not equal resolved.

These principles are mandatory for the MVP.

5\. MVP Must-have Capabilities

The following capabilities are required for MVP readiness.

5.1 POS Accepted Order to KDS Ticket Projection

The MVP must support projection from POS accepted order or accepted order line to KDS ticket.

Minimum requirements:

\- Source order reference
\- Source order line reference
\- Store reference
\- Item display name
\- Quantity
\- Modifier or option display
\- Allergy or caution note
\- Fulfillment type
\- Timing or table context where applicable
\- Ticket creation time
\- Ticket state

The MVP must not allow KDS ticket creation to become commercial order creation.

5.2 POS/KDS Authority Boundary

The MVP must clearly separate:

\- POS accepted order truth
\- KDS kitchen ticket projection
\- Payment state
\- Refund workflow
\- Customer recovery workflow
\- Inventory or menu master authority

The KDS must not mutate payment, refund, loyalty, menu master, inventory master, or customer identity.

5.3 Basic Kitchen Ticket Lifecycle

The MVP must support a simple kitchen ticket lifecycle.

Minimum state families:

Candidate
Sent
Received
Acknowledged or Seen
In Progress
Ready
Completed
Exception

If explicit acknowledgment is too heavy for MVP, the system may use a simplified “Seen” or “Received” state, but the operational meaning must be clear.

5.4 Delay, Retry, and Remake State Families

The MVP must include basic handling for:

\- Delayed
\- Retry Required
\- Remake Required
\- Duplicate Suspected
\- Manual Recovery Required

These states may remain simple, but they must exist as policy-level concepts.

5.5 Modifier and Allergy Preservation

The MVP must preserve preparation-critical information.

Required:

\- Required modifiers
\- Option selections
\- Allergy notes
\- Caution notes
\- Packaging notes where relevant
\- Customer timing notes where relevant

If allergy or caution note cannot be displayed reliably, the ticket must be treated as an exception or fallback case.

5.6 Manual Degraded Operation Path

The MVP must include a manual fallback path for degraded KDS operation.

Minimum fallback requirements:

\- Manual kitchen note format
\- Order reference if available
\- Item and quantity
\- Modifier
\- Allergy/caution note
\- Fulfillment type
\- Staff initials
\- Time
\- Manual state
\- Reason for manual note
\- Mismatch flag

Manual fallback is mandatory because KDS failure must not stop the kitchen by default.

5.7 Replay and Duplicate Prevention

The MVP must define how tickets are retried or replayed without creating duplicate kitchen work.

Minimum requirements:

\- Stable source order reference
\- Stable source order line reference
\- Ticket correlation reference
\- Duplicate suspected state
\- Manual review path when receipt is uncertain
\- No new POS order from replay

5.8 Sold-out and Menu Availability Readiness

The MVP must align with menu availability and sold-out policy.

Minimum requirements:

\- Sold-out prevents future orderability where possible
\- Sold-out does not silently remove accepted order lines
\- Sold-out after acceptance becomes exception or recovery case
\- KDS may display conflict but does not mutate POS truth
\- Manual fallback must preserve sold-out conflict notes

5.9 Cancellation Race Awareness

The MVP must recognize that cancellation can race with KDS state.

Minimum cases:

\- Cancelled before KDS ticket sent
\- Cancelled after sent
\- Cancelled after received
\- Cancelled after kitchen start
\- Cancelled after ready

The MVP does not need complex automation, but it must not silently delete visible kitchen work.

5.10 Staff Adoption Readiness

The MVP must be usable under real kitchen conditions.

Minimum readiness:

\- Staff can understand ticket states
\- Staff can see modifiers and allergy notes
\- Staff can mark basic progress
\- Staff can identify delayed or exception tickets
\- Staff knows fallback procedure
\- Staff knows prohibited actions
\- Manager can resolve mismatch cases

6\. MVP Should-have Capabilities

The following capabilities are desirable but not mandatory for first MVP.

6.1 Basic Station Routing

The system should support station routing if the kitchen flow requires it.

Examples:

\- Hot station
\- Cold station
\- Drink station
\- Packing station
\- Pickup station

If station routing is not included in MVP, the ticket must still be readable enough for staff to route manually.

6.2 Customer-safe Delay Message

The system should support safe customer-facing delay messages.

Examples:

\- “Your order is being prepared.”
\- “Preparation may take a little longer than expected.”
\- “A staff member is checking your order.”

The MVP may allow staff-controlled messages before automation.

6.3 Basic KDS Metrics

The MVP should capture simple metrics.

Examples:

\- Ticket count
\- Ticket age
\- Average preparation time
\- Delay count
\- Remake count
\- Retry count
\- Manual recovery count
\- Duplicate suspected count

Metrics are for improvement, not automatic blame.

6.4 Kitchen Note Reconciliation

The MVP should include a simple recovery checklist for manual notes.

The system does not need full automation, but staff must know how to reconcile:

\- Manual notes
\- POS accepted orders
\- KDS tickets
\- Printer fallback
\- Remake notes
\- Sold-out conflicts

6.5 Manager Review Queue

The MVP should support a simple manager review concept for:

\- Duplicate suspected
\- Manual recovery required
\- Sold-out after acceptance
\- Allergy/caution mismatch
\- Cancellation after kitchen start
\- Remake requiring approval

This may be documented before implementation.

7\. Could-have Later Capabilities

The following should be deferred until after MVP stabilization.

7.1 Advanced AI Delay Prediction

AI may later estimate preparation delays, station congestion, or recovery risk.

This must not be part of MVP authority.

AI recommendation must not become automatic execution.

7.2 Automated Station Balancing

Later versions may route tickets dynamically across stations.

MVP should not depend on dynamic balancing.

7.3 Inventory-driven Auto Sold-out

Later versions may connect inventory signals to availability.

MVP should rely on manual or simple availability state unless the inventory module is ready.

Inventory-driven auto sold-out must not disable menu items without policy control.

7.4 Robot or Physical AI Handoff

Physical AI or robot kitchen integration is future-stage.

The MVP should define clean ticket state boundaries so that future physical AI can consume stable kitchen work signals.

Physical AI must not receive financial or refund authority.

7.5 Multi-vendor KDS Bridge Abstraction

Later versions may support multiple KDS vendors through bridge abstraction.

The MVP may document boundaries without building full multi-vendor abstraction.

7.6 Advanced Customer Recovery Automation

Later versions may connect delay/remake to recovery offers.

MVP must not automatically compensate customers from KDS state alone.

8\. Out of MVP

The following are explicitly out of MVP.

Full inventory engine
Automatic refund from KDS
AI-controlled menu disabling
Autonomous kitchen labor assignment
Cross-store kitchen optimization
Robot kitchen execution
Full vendor bridge marketplace
Dynamic recipe modification
Financial settlement mutation from KDS
Customer identity mutation from KDS
Loyalty mutation from KDS
Staff payroll mutation from KDS

These may be considered later only after authority boundaries are stable.

9\. MVP Risk Register

Risk| Description| MVP Control
Duplicate ticket| Retry or replay creates repeated kitchen work| Stable references and Duplicate Suspected state
Missing modifier| Kitchen loses preparation-critical option| Required modifier display and exception handling
Missing allergy note| Safety-critical note not visible| Allergy/caution priority display and fallback preservation
KDS failure| Kitchen cannot see tickets| Manual degraded operation path
POS/KDS mismatch| POS and KDS disagree| Recovery checklist and manager review
Sold-out after acceptance| Accepted item cannot be prepared| Exception/recovery state, no silent mutation
Cancellation race| Order cancelled while kitchen starts| Explicit stop/review handling
Remake confusion| Remake treated as refund or new order| Remake preserves source reference and reason
Delay misuse| Delay becomes automatic compensation| Delay is evidence only
Staff overload| Too many states confuse kitchen| MVP uses simplified state families
Vendor lock-in| KDS-specific assumptions dominate| Policy-level boundary before implementation
Poor audit trail| Failure cannot be reconstructed| Event/evidence expectations

10\. MVP Readiness Checklist

The MVP is not ready unless the following are true.

\[ \] POS accepted order boundary is defined.
\[ \] KDS ticket projection is defined.
\[ \] KDS cannot mutate payment/refund/loyalty/menu/inventory/customer identity.
\[ \] Ticket lifecycle is defined.
\[ \] Modifier and allergy/caution preservation is defined.
\[ \] Retry and replay do not create new orders.
\[ \] Duplicate suspected handling is defined.
\[ \] Remake is separated from refund/compensation.
\[ \] Delay is separated from financial authority.
\[ \] Manual degraded operation path is defined.
\[ \] Manual kitchen note minimum fields are defined.
\[ \] Sold-out after acceptance is handled as exception/recovery.
\[ \] Cancellation race cases are recognized.
\[ \] Staff role expectations are documented.
\[ \] Manager review path is documented.
\[ \] Customer-safe messaging is defined or deferred clearly.
\[ \] Readiness index exists.

11\. Cutline Decision Table

Capability| MVP Status| Reason| Risk if Omitted| Later Expansion Path
POS accepted order to KDS ticket projection| Must-have| Core handoff| Kitchen cannot receive accepted work| Vendor bridge/API implementation
POS/KDS authority boundary| Must-have| Prevents transaction confusion| KDS mutates commercial truth| Formal authorization matrix
Basic ticket lifecycle| Must-have| Staff needs progress visibility| Kitchen loses work state| Detailed enum/state machine
Modifier preservation| Must-have| Preparation correctness| Wrong item/customer dissatisfaction| Structured modifier mapping
Allergy/caution preservation| Must-have| Safety| Safety incident| Dedicated safety display rules
Delay state| Must-have| Kitchen timing visibility| Hidden customer-impacting delay| SLA/customer messaging
Retry state| Must-have| Handoff recovery| Duplicate or lost tickets| Idempotent retry engine
Remake state| Must-have| Recovery kitchen work| Untracked free item or confusion| Recovery workflow integration
Duplicate suspected state| Must-have| Prevents repeated work| Waste and customer confusion| Automated duplicate detection
Manual fallback path| Must-have| KDS failure survival| Kitchen stalls or loses evidence| Local agent fallback
Sold-out conflict handling| Must-have| Menu availability continuity| Accepted orders silently mutate| Inventory integration
Cancellation race awareness| Must-have| Prevents silent deletion| Waste/recovery disputes| Detailed cancellation workflow
Basic station routing| Should-have| Useful kitchen flow| Manual routing burden| Station optimization
Customer-safe delay message| Should-have| Front-of-house clarity| Poor customer communication| Automated message rules
Basic metrics| Should-have| Improvement loop| No reliability learning| Analytics dashboard
Manager review queue| Should-have| Handles ambiguity| Staff resolves complex cases ad hoc| Exception inbox
AI delay prediction| Later| Requires data| Premature automation| Agent recommendation layer
Inventory auto sold-out| Later| Requires inventory maturity| False disabling| Inventory/Menu availability engine
Robot/physical AI handoff| Later| Future architecture| Overbuilt MVP| Physical AI translation module
Multi-vendor bridge| Later| Useful SaaS expansion| Vendor-specific lock-in| Bridge abstraction layer

12\. Implementation Readiness Gate

Before implementation begins, the following documents should be complete or referenced:

04010 KDS Handoff Candidate And Kitchen Ticket Policy
04020 POS Accepted Order To KDS Ticket Boundary Policy
04030 KDS Retry Remake Delay And Fulfillment Status Policy
04040 KDS Degraded Operation Manual Kitchen Note Policy
04090 KDS Integration Kitchen Continuity MVP Cutline
04099 KDS Integration Kitchen Continuity Index And Readiness Check
04190 Menu Availability Soldout Policy
04199 Menu Availability Soldout Index And Readiness Check

Implementation should not begin if:

\- POS/KDS authority boundary is unclear
\- KDS can mutate transaction truth
\- Manual fallback is missing
\- Allergy/caution note handling is undefined
\- Retry can create duplicate orders
\- Replay overwrites history
\- Sold-out can silently remove accepted items
\- Staff cannot understand fallback procedure

13\. Staff Training Cutline

MVP training must cover:

\- What a KDS ticket is
\- What a KDS ticket is not
\- How to read ticket state
\- How to handle delay
\- How to handle remake
\- How to handle retry or duplicate suspected
\- How to preserve allergy/caution notes
\- How to enter degraded operation
\- How to write manual kitchen notes
\- How to reconcile after recovery
\- When to call manager

Training must be simple enough for service-time use.

14\. Audit Cutline

MVP audit does not need full analytics, but it must preserve enough evidence to answer:

\- Did POS accept the order?
\- Was a KDS candidate created?
\- Was the ticket sent?
\- Was the ticket received or acknowledged?
\- Was the ticket delayed, retried, remade, or completed?
\- Was degraded operation used?
\- Was manual note created?
\- Was duplicate suspected?
\- Was sold-out conflict involved?
\- Was cancellation race involved?
\- Who reviewed unresolved mismatch?

Audit evidence is for reconstruction and improvement.

It is not automatic blame.

15\. Customer Experience Cutline

MVP customer experience should be safe and calm.

The MVP should avoid exposing internal failure details.

Customer-facing states may be simple:

Order received
Preparing
Checking
Delayed
Ready
Staff will assist

The MVP should not expose:

\- KDS failure
\- Vendor failure
\- Staff blame
\- Internal station conflict
\- Refund promise not approved
\- Legal conclusion
\- Technical replay/retry language

16\. Non-goals

This document does not define:

\- Runtime database schema
\- API endpoint design
\- KDS screen layout
\- Printer format
\- Vendor mapping
\- Exact enum values
\- AI prediction logic
\- Inventory deduction
\- Refund workflow
\- Customer compensation formula
\- Staff discipline policy
\- Robot/physical AI execution

17\. Acceptance Criteria

This MVP cutline is ready when:

\- Must-have capabilities are clearly separated from should-have and later capabilities
\- POS/KDS authority boundary is preserved
\- Kitchen continuity is prioritized over advanced optimization
\- Manual degraded operation is mandatory
\- Retry/replay/duplicate prevention are included
\- Remake/delay are separated from refund and compensation
\- Sold-out and menu availability are linked but not over-implemented
\- Staff adoption and training are included
\- Audit and evidence are included
\- Out-of-MVP items are explicitly listed
\- No implementation-specific runtime design is forced

18\. Open Questions

\- Should MVP use explicit Acknowledged state or simplify to Received/Seen?
\- Should station routing be included from day one?
\- Should customer-safe delay messages be manual or system-generated in MVP?
\- Should manager review queue be implemented in MVP or documented only?
\- Should printer fallback be included as MVP or treated as store-specific fallback?
\- Should manual notes be paper-first, tablet-first, or both?
\- Should sold-out after acceptance always create manager review?
\- Should retry be automatic, staff-triggered, or manager-triggered?
\- Should KDS metrics be visible to store manager from MVP?
\- Should delivery and dine-in use the same KDS state model in MVP?
