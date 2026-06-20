# 004210_Policy_KDS_Station_Routing.md

1\. Purpose

This document defines the policy-level rules for routing KDS tickets to kitchen stations.

The purpose is to ensure that accepted kitchen work is displayed to the right preparation area without allowing station routing to mutate POS order truth, payment state, menu master, inventory master, or customer identity.

Station routing exists to support kitchen execution.

Station routing is not transaction authority.

2\. Scope

This policy applies to:

\- KDS ticket station routing
\- Kitchen station grouping
\- Item-to-station mapping
\- Modifier-based routing
\- Allergy/caution routing
\- Fulfillment-based routing
\- Split ticket routing
\- Merged ticket routing
\- Manual station reassignment
\- Degraded operation station fallback
\- MVP station routing cutline

This policy does not define:

\- POS payment logic
\- Refund logic
\- Inventory deduction
\- Recipe execution details
\- Staff payroll
\- Full kitchen layout design
\- Vendor-specific KDS screen implementation
\- Robot or physical AI routing
\- Automatic labor optimization

3\. Core Principle

Station routing determines where kitchen work should be seen and prepared.

Station routing does not determine whether an order commercially exists.

POS accepted order \= commercial truth
KDS ticket \= kitchen work projection
Station route \= kitchen preparation destination

A station route may split, group, prioritize, or display kitchen work.

A station route must not create a new commercial order line.

A station route must not hide preparation-critical information.

4\. Station Definition

A station is a kitchen work area, role area, display group, preparation lane, or fulfillment point responsible for part of the food execution process.

A station may be physical or logical.

Examples:

\- Hot station
\- Cold station
\- Rice station
\- Roll/wrap station
\- Bowl/salad station
\- Noodle station
\- Drink station
\- Soup station
\- Packing station
\- Pickup handoff station
\- Delivery packing station
\- Quality check station
\- Manager review station

The MVP may use fewer stations than the final operating model.

5\. Station Routing Definition

Station routing means assigning a KDS ticket, ticket line, or ticket segment to one or more kitchen stations.

Routing may be based on:

\- Item category
\- Preparation method
\- Temperature
\- Required equipment
\- Modifier
\- Allergy/caution requirement
\- Fulfillment type
\- Packaging requirement
\- Timing requirement
\- Staff role
\- Store layout
\- Operational mode
\- Degraded operation mode

Routing should be predictable enough for staff to trust during service.

6\. Routing Authority Boundary

6.1 POS Authority

POS remains authority for:

\- Accepted order
\- Order line
\- Payment state
\- Order total
\- Commercial cancellation
\- Refund workflow
\- Settlement reference

Station routing must not mutate these.

6.2 Menu or Recipe Authority

Menu or recipe policy may define standard preparation station hints.

Examples:

\- Kimbap item routes to roll/wrap station
\- Warm bowl routes to hot station and packing station
\- Drink routes to drink station
\- Soup routes to soup station

Station routing may use these hints, but routing does not own menu master or recipe master.

6.3 KDS Authority

KDS may display and manage kitchen station routing for execution.

KDS may:

\- Show ticket at station
\- Split ticket by station
\- Merge station work units
\- Mark station progress
\- Mark delay or exception
\- Mark station completion
\- Request manual review

KDS must not:

\- Create commercial order
\- Mutate payment
\- Approve refund
\- Delete accepted order line
\- Disable menu master
\- Mutate inventory master
\- Hide allergy/caution notes
\- Treat station completion as customer receipt

7\. MVP Station Families

For MVP, station families should remain simple.

Recommended MVP station families:

Main Kitchen
Cold / Assembly
Hot / Cook
Drink / Beverage
Packing / Handoff
Manager Review

If the store starts with a compact kitchen, MVP may collapse stations further:

Kitchen
Packing
Manager Review

The policy should allow expansion without changing POS order truth.

8\. Expanded Station Families

Later expansion may include:

Rice Prep
Roll / Wrap
Bowl / Salad
Noodle
Soup
Protein
Side
Drink
Dessert
Packing
Delivery Packing
Pickup Shelf
Quality Check
Allergy-Sensitive Prep
Manager Review
Recovery / Remake

Expanded station design should be introduced only when staff workflow can support it.

Too many stations in MVP may increase service confusion.

9\. Item-based Routing

Item-based routing assigns a ticket line based on item category or preparation type.

Examples:

Item Type| Possible Station
Kimbap| Roll / Wrap
Warm bowl| Hot / Cook \+ Packing
Salad bowl| Cold / Assembly
Noodle| Noodle / Hot
Soup| Soup / Hot
Drink| Drink / Beverage
Packaged side| Packing
Recovery remake| Recovery / Remake or original station \+ manager review

Item-based routing should preserve original order and line references.

10\. Modifier-based Routing

Modifiers may affect station routing.

Examples:

\- Extra grilled protein may require hot station.
\- Separate sauce may require packing station.
\- No onion may require assembly awareness.
\- Spicy level may require sauce station or assembly awareness.
\- Warmed item may require hot station.
\- Cold-only request may require cold station.

Modifier-based routing must not lose the modifier text.

If routing depends on modifier data and modifier data is missing, the ticket should enter exception handling.

11\. Allergy and Caution Routing

Allergy and caution notes may require special routing or visibility.

Examples:

\- Allergy-sensitive prep route
\- Manager review route
\- Do-not-merge route
\- High-visibility caution label
\- Separate packing route
\- Staff confirmation route

Allergy/caution routing must prioritize safety over speed.

An allergy/caution note must not be hidden by split or merge routing.

If station routing cannot preserve allergy/caution visibility, the ticket must be treated as exception or manual recovery required.

12\. Fulfillment-based Routing

Fulfillment type may affect station route.

Examples:

Fulfillment Type| Routing Impact
Dine-in| Table handoff or serving sequence
Takeout| Packing station
Delivery| Delivery packing station
Pickup reservation| Timing and pickup shelf
Waiting customer| Front handoff visibility
Group order| Batch or group packing
Staff meal| Internal fulfillment path
Recovery order| Manager/recovery visibility

Fulfillment-based routing should help staff prepare the right packaging, timing, and handoff.

It must not mutate commercial order truth.

13\. Timing-based Routing

Timing requirements may affect route or display sequence.

Examples:

\- Hold until called
\- Prepare at pickup time
\- Serve together
\- Course sequencing
\- Delay due to prep batch
\- Delivery partner delayed
\- Customer not seated yet

Timing-based routing must be visible enough to prevent premature preparation.

If timing is uncertain, the ticket should be marked for staff confirmation rather than hidden.

14\. Split Ticket Routing

A single POS accepted order may create multiple KDS station tickets.

Valid split reasons include:

\- Different preparation stations
\- Hot/cold separation
\- Drink/food separation
\- Packing separation
\- Allergy isolation
\- Timing separation
\- Course sequence
\- Batch preparation

Split routing must preserve:

\- Source order reference
\- Source order line reference
\- Quantity
\- Modifier
\- Allergy/caution note
\- Fulfillment context
\- Split reason

Split routing must not create duplicate commercial order lines.

15\. Merge Ticket Routing

Multiple ticket lines may be merged into one station work unit when operationally useful.

Valid merge reasons include:

\- Same item
\- Same station
\- Same table
\- Same batch
\- Same fulfillment time
\- Same packaging flow

Merge routing must not hide:

\- Quantity
\- Modifier differences
\- Allergy/caution notes
\- Customer timing notes
\- Recovery/remake distinction

If safety notes differ, merging should be avoided unless the highest caution level remains clearly visible.

16\. Multi-station Ticket Policy

Some items may require more than one station.

Examples:

\- Warm bowl: hot protein station \+ cold assembly \+ packing
\- Noodle set: noodle station \+ side station \+ packing
\- Drink combo: kitchen food station \+ drink station \+ packing
\- Delivery order: kitchen station \+ packing station \+ pickup handoff

Multi-station tickets must define whether station completion is independent or whether final completion requires all station segments.

For MVP, avoid overly complex multi-station dependency unless operationally necessary.

17\. Station Completion Policy

Station completion means a station has completed its assigned kitchen work.

Station completion does not necessarily mean:

\- The full order is ready
\- The customer received the item
\- Payment is complete
\- Delivery handoff occurred
\- Complaint risk is closed

A full ticket may require all required station segments to reach ready before the order is ready for handoff.

18\. Station Delay Policy

A station may mark a ticket delayed when that station cannot proceed normally.

Station delay reasons may include:

\- Ingredient not ready
\- Equipment issue
\- Station overloaded
\- Staff shortage
\- Modifier confirmation needed
\- Allergy/caution review needed
\- Packaging unavailable
\- Previous station not completed
\- Customer timing hold

Station delay is kitchen execution evidence.

Station delay is not refund authority.

19\. Station Remake Policy

A remake may route to:

\- Original station
\- Recovery/remake station
\- Manager review station
\- Quality check station
\- Packing station

A remake station route must preserve:

\- Original order reference
\- Original line reference
\- Remake reason
\- Approval source if required
\- Remake sequence
\- Allergy/caution note

Remake routing must not hide the original ticket history.

20\. Station Retry and Replay Policy

If station routing fails, retry or replay may be required.

Examples:

\- Ticket did not appear at station
\- Wrong station received ticket
\- Station device offline
\- Ticket displayed stale state
\- Local agent replayed route after reconnect
\- Printer route duplicated

Retry or replay must not create duplicate POS order lines.

If the previous station receipt is uncertain, mark Duplicate Suspected or Manual Recovery Required.

21\. Manual Station Reassignment

Manual station reassignment may be needed during service.

Valid reasons include:

\- Station overloaded
\- Staff shortage
\- Device unavailable
\- Equipment failure
\- Kitchen layout change
\- Allergy-sensitive handling
\- Manager decision
\- Degraded operation

Manual reassignment should record:

\- Original station
\- New station
\- Reason
\- Staff/source
\- Time
\- Affected ticket reference

Manual reassignment must not hide original route or erase audit evidence.

22\. Degraded Operation Station Routing

During degraded KDS operation, station routing may become manual.

Fallback methods may include:

\- Paper station labels
\- Printer fallback by station
\- Verbal station callout
\- Manual kitchen queue
\- Manager-controlled routing sheet
\- Simplified all-kitchen queue

During degraded station routing, staff must preserve:

\- Item
\- Quantity
\- Modifier
\- Allergy/caution note
\- Fulfillment type
\- Station or staff assignment
\- Manual state
\- Time
\- Order reference if available

Manual station routing is fallback evidence.

It is not POS truth.

23\. Station Routing and Sold-out Interaction

If an item becomes sold out or temporarily unavailable, station routing must handle the conflict.

Examples:

\- Ticket already accepted but station cannot prepare
\- Station discovers ingredient shortage
\- Station marks prep delayed
\- Station requests manager review
\- Station suggests substitution
\- Station reports limited quantity

The KDS may display sold-out conflict.

The station must not silently remove accepted work.

Sold-out after acceptance must become exception, delay, recovery, substitution review, or cancellation workflow outside KDS authority.

24\. Station Routing and Menu Availability

Menu availability may influence whether future tickets are created.

However, once a POS accepted order is projected to KDS, station routing must not erase the ticket simply because the item later becomes unavailable.

If availability and accepted order conflict, the station should mark exception or manager review.

25\. Station Routing and Customer Visibility

Station routing details should generally remain internal.

Customer-facing messages should not expose detailed station problems.

Allowed customer-safe messages:

Your order is being prepared.
Preparation may take a little longer than expected.
A staff member is checking your item.
Your order is being packed.
Your order is ready.

Avoid:

The hot station is overloaded.
The roll station missed your ticket.
The KDS routed your item wrong.
The staff at station 2 delayed it.

26\. Staff Visibility

Staff-facing views should clearly show:

\- Station assignment
\- Item and quantity
\- Modifier
\- Allergy/caution note
\- Fulfillment type
\- Ticket age
\- Delay marker
\- Remake marker
\- Duplicate suspected marker
\- Manual recovery marker
\- Manager review marker

Station routing should reduce cognitive load, not increase it.

27\. Manager Visibility

Manager view should help answer:

\- Which station is overloaded?
\- Which tickets are delayed?
\- Which tickets are duplicate-suspected?
\- Which station has unresolved exceptions?
\- Which manual reassignment occurred?
\- Which sold-out conflicts came from station?
\- Which tickets need customer recovery?
\- Which station devices are degraded?

Manager visibility is for operational coordination and recovery.

It is not automatic staff blame.

28\. HQ Visibility

HQ may review station routing evidence for:

\- Kitchen design improvement
\- Menu complexity analysis
\- Station workload analysis
\- Degraded operation frequency
\- Training improvement
\- Vendor reliability review
\- SOP refinement

HQ visibility must not imply HQ directly mutates live store kitchen routing during service unless separate authority policy allows it.

29\. Station Routing Metrics

Possible station routing metrics include:

\- Ticket count by station
\- Average station acknowledgment time
\- Average station preparation time
\- Station delay count
\- Station remake count
\- Station retry count
\- Station duplicate suspected count
\- Manual reassignment count
\- Degraded station routing count
\- Sold-out conflict by station
\- Allergy/caution ticket count by station

Metrics are for improvement.

Metrics must not become automatic punishment.

30\. MVP Routing Cutline

For MVP, station routing should be intentionally simple.

MVP must-have:

Basic station family definition
Item-to-station mapping policy
Modifier preservation
Allergy/caution preservation
Split routing policy
Manual reassignment policy
Degraded station fallback policy
Station routing authority boundary

MVP should-have:

Basic station delay marker
Basic station completion marker
Basic packing station visibility
Manager review station
Simple metrics

Later:

Dynamic station balancing
AI station congestion prediction
Automatic labor-based routing
Robot/physical AI routing
Advanced multi-station dependency engine
Cross-store station optimization

31\. Prohibited Actions

Station routing must not:

\- Create a POS order
\- Delete an accepted order line
\- Mutate payment
\- Approve refund
\- Grant loyalty compensation
\- Disable menu master
\- Mutate inventory master
\- Hide allergy/caution notes
\- Hide modifier differences
\- Treat station completion as customer receipt
\- Treat delay as automatic compensation
\- Treat remake as automatic refund
\- Resolve duplicate-suspected tickets silently
\- Overwrite manual fallback evidence

32\. Audit and Evidence

Important routing events should be auditable where possible.

Examples:

\- Initial station route assigned
\- Ticket split by station
\- Ticket merged by station
\- Station route changed
\- Station acknowledged ticket
\- Station marked delay
\- Station marked ready
\- Station marked completed
\- Station requested remake
\- Station marked duplicate suspected
\- Station entered manual recovery
\- Station routing degraded
\- Station sold-out conflict detected

Evidence should preserve:

\- Ticket reference
\- Source order reference
\- Source line reference
\- Original station
\- New station if changed
\- Reason
\- Staff/source
\- Time
\- Related manual note if applicable

33\. Non-goals

This document does not define:

\- Exact KDS UI
\- Database table structure
\- API endpoint
\- Vendor protocol
\- Printer routing implementation
\- Kitchen physical layout blueprint
\- Full labor assignment engine
\- Recipe automation
\- Inventory deduction
\- Refund workflow
\- Customer compensation logic
\- AI station prediction
\- Robot kitchen execution

34\. Acceptance Criteria

This policy is ready when:

\- Station is clearly defined
\- Station routing is defined as kitchen execution destination
\- POS/KDS authority boundary is preserved
\- MVP station families are proposed
\- Expanded station families are deferred
\- Item-based routing is documented
\- Modifier-based routing is documented
\- Allergy/caution routing is documented
\- Fulfillment-based routing is documented
\- Split and merge routing are documented
\- Multi-station ticket policy is documented
\- Manual station reassignment is documented
\- Degraded station routing is documented
\- Sold-out and availability interaction is documented
\- Customer-safe visibility is documented
\- Metrics and audit expectations are documented
\- Prohibited actions are documented
\- No implementation-specific runtime design is forced

35\. Open Questions

\- Should MVP start with one Kitchen station plus Packing, or split Hot/Cold/Drink from day one?
\- Should station acknowledgment be required separately from ticket acknowledgment?
\- Should packing station completion be required before customer-ready state?
\- Should drink station be part of KDS or separate fulfillment board?
\- Should allergy-sensitive prep be a separate station or a warning layer?
\- Should manager review be a station, a queue, or both?
\- Should delivery packing have separate routing from takeout packing?
\- Should station reassignment require manager approval during peak service?
\- Should station-level metrics be visible to staff or manager only?
\- Should future physical AI receive station route directly or through a translation module?
