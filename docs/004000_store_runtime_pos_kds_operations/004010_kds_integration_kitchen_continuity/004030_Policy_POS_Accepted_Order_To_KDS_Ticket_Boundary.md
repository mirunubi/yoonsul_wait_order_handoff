# 004030_Policy_POS_Accepted_Order_To_KDS_Ticket_Boundary.md

1\. Purpose

This document defines the boundary between a POS accepted order and a KDS ticket.

The purpose is to prevent the KDS from being treated as transaction authority and to prevent the POS from being treated as the kitchen execution surface.

A POS accepted order is the commercial and transaction source.

A KDS ticket is the kitchen execution projection derived from that accepted order.

2\. Scope

This policy applies to:

\- POS accepted order records
\- POS accepted order lines
\- KDS ticket creation
\- POS-to-KDS handoff boundary
\- KDS ticket replay and recovery
\- Duplicate prevention
\- Cancellation race handling
\- Kitchen ticket projection rules
\- Boundary event families

This policy does not define:

\- Full POS schema
\- Full KDS schema
\- KDS vendor protocol
\- Kitchen display UI
\- Printer implementation
\- Inventory engine
\- Payment gateway implementation
\- Refund automation
\- Loyalty engine implementation

3\. Boundary Statement

The POS accepted order and the KDS ticket must be treated as different objects with different authority.

POS accepted order \= commercial/transaction truth
KDS ticket \= kitchen execution projection

The POS accepted order owns the commercial meaning of the order.

The KDS ticket owns the kitchen-facing work visibility derived from the accepted order.

A KDS ticket must never become the source of transaction truth.

4\. Core Principles

4.1 POS Remains Transaction Authority

The POS or equivalent transaction-authoritative order service remains the authority for:

\- Order acceptance
\- Payment state
\- Order total
\- Tax or service charge
\- Discount state
\- Commercial cancellation
\- Refund eligibility
\- Settlement reference
\- Transaction audit trail

4.2 KDS Remains Kitchen Execution Projection

The KDS remains the surface for:

\- Kitchen ticket visibility
\- Station routing
\- Preparation state
\- Delay state
\- Retry state
\- Remake state
\- Ready state
\- Completion state
\- Kitchen exception state

4.3 Boundary Crossing Is Projection, Not Mutation

When a POS accepted order crosses into KDS, it crosses as a kitchen projection.

The projection may be replayed, delayed, split, merged, or marked for remake, but it must not mutate the accepted order truth without an authorized upstream event.

4.4 Replay Does Not Mean New Order

A replayed KDS ticket must preserve the original accepted order reference.

Replay means re-sending or reconstructing kitchen visibility.

Replay does not create a new commercial order.

5\. POS Accepted Order Definition

A POS accepted order is an order that the transaction-authoritative system has accepted as valid for the store's order flow.

Depending on the store mode, this may include:

\- Paid counter order
\- Paid kiosk order
\- Paid mobile order
\- Table postpaid order accepted by staff
\- Manager-approved recovery order
\- House-account order
\- Staff meal order approved under policy
\- Test order explicitly routed to kitchen

A POS accepted order is not merely a customer cart, menu selection, draft order, or payment attempt.

6\. POS Accepted Order Data Families

A POS accepted order may include:

\- Order id
\- Store id
\- Order channel
\- Customer reference, if applicable
\- Table or seating context, if applicable
\- Order line references
\- Menu item references
\- Quantity
\- Modifier and option selections
\- Discount data
\- Tax or service charge data
\- Payment state
\- Settlement reference
\- Cancellation state
\- Refund state
\- Staff reference
\- Created time
\- Accepted time
\- Audit trail reference

Not all data families should cross into KDS.

The KDS should receive only what is needed for kitchen execution, safety, timing, and fulfillment.

7\. KDS Ticket Definition

A KDS ticket is a kitchen execution work unit derived from a POS accepted order or accepted order line.

A KDS ticket may represent:

\- One accepted order
\- One accepted order line
\- A group of accepted order lines
\- A station-specific subset
\- A timed fulfillment group
\- A remake work unit
\- A manually recovered kitchen work unit

A KDS ticket must preserve traceability to its source accepted order or accepted order line.

8\. KDS Ticket Data Families

A KDS ticket may include:

\- Source order reference
\- Source order line reference
\- Ticket reference
\- Store reference
\- Kitchen station reference
\- Item display name
\- Quantity
\- Modifier display
\- Allergy or caution note
\- Fulfillment type
\- Table or pickup context
\- Timing note
\- Staff note
\- Ticket state
\- Delay marker
\- Retry marker
\- Remake marker
\- Exception marker
\- Created time
\- Sent time
\- Received time
\- Acknowledged time
\- Ready time
\- Completed time

The KDS ticket should not expose unnecessary commercial, financial, or sensitive customer data.

9\. What Must Cross the Boundary

The following information should cross from POS accepted order to KDS ticket when relevant.

9.1 Stable References

The KDS ticket must preserve stable references.

Examples:

\- POS accepted order reference
\- POS accepted order line reference
\- Store reference
\- Ticket reference
\- Correlation reference for replay or recovery

Stable references are required to prevent duplicate kitchen work and to support recovery.

9.2 Kitchen-readable Item Data

The KDS must receive enough item information for preparation.

Examples:

\- Item display name
\- Quantity
\- Kitchen category
\- Station routing hint
\- Set or bundle context, if needed
\- Packaging requirement, if needed

9.3 Modifiers and Options

Modifiers and options must cross when they affect preparation, safety, packaging, timing, or customer satisfaction.

Examples:

\- No onion
\- Extra sauce
\- Spicy level
\- Rice amount
\- Protein option
\- Temperature option
\- Separate sauce
\- Packaging option

Modifier loss must be treated as a kitchen exception risk.

9.4 Allergy and Caution Notes

Allergy and caution notes must cross the boundary when present.

These notes must not be treated as ordinary optional comments.

If the KDS cannot display allergy or caution notes reliably, the ticket must enter exception or fallback handling.

9.5 Fulfillment Context

The KDS must know how the food will be fulfilled.

Examples:

\- Dine-in
\- Takeout
\- Delivery
\- Pickup reservation
\- Table order
\- Waiting customer
\- Group order
\- Staff meal
\- Recovery order

Fulfillment context affects preparation sequence, packaging, and handoff.

9.6 Timing Context

Timing context should cross when it affects kitchen sequencing.

Examples:

\- Immediate preparation
\- Hold until called
\- Reserved pickup time
\- Table course timing
\- Delayed customer arrival
\- Batch timing request

Timing context should be clear enough to prevent premature or late preparation.

10\. What Must Not Cross as Authority

The following data may be referenced only when necessary, but must not cross as KDS authority.

10.1 Payment Mutation Authority

The KDS must not mutate:

\- Payment captured state
\- Payment failed state
\- Payment cancellation
\- Payment retry
\- Payment method
\- Settlement state

10.2 Refund Authority

The KDS must not approve, reject, or execute refunds.

A remake or delay marker may become evidence for a customer recovery workflow, but it is not a refund decision.

10.3 Loyalty Authority

The KDS must not mutate:

\- Points
\- Coupons
\- Membership tier
\- Customer wallet
\- Subscription balance
\- Rewards

10.4 Menu Master Authority

The KDS must not mutate:

\- Menu master item
\- Item price
\- Item category
\- Recipe master
\- Nutrition master
\- Allergen master
\- Standard modifier definition

10.5 Inventory Master Authority

The KDS must not mutate inventory master truth.

The KDS may display a kitchen-level shortage signal or sold-out conflict, but inventory truth must remain outside KDS authority.

10.6 Customer Identity Authority

The KDS must not mutate customer identity.

Kitchen staff should not need full customer profile data to prepare a ticket.

10.7 Staff Payroll or HR Authority

The KDS must not mutate staff payroll, attendance, role assignment, or HR records.

KDS staff actions may become operational evidence, but not HR payroll authority by themselves.

11\. Boundary Event Families

The POS-to-KDS boundary should be represented by explicit event families.

11.1 POS\_ACCEPTED

The transaction-authoritative system accepted the order.

This event is the upstream basis for kitchen projection.

11.2 KDS\_TICKET\_CANDIDATE\_CREATED

A kitchen-relevant projection candidate was created from the accepted order or accepted order line.

This does not mean the kitchen has seen the ticket.

11.3 KDS\_TICKET\_SENT

The system attempted to send the ticket to KDS, printer, bridge, or local kitchen endpoint.

Sent does not guarantee receipt.

11.4 KDS\_TICKET\_RECEIVED

The KDS endpoint, bridge, printer, or local kitchen device received the ticket payload.

Received does not guarantee staff acknowledgment.

11.5 KDS\_TICKET\_ACKNOWLEDGED

Kitchen staff or authorized kitchen device acknowledged the ticket.

This is the earliest strong signal that kitchen execution awareness exists.

11.6 KDS\_TICKET\_FAILED

The ticket handoff failed or became uncertain.

This should trigger retry, fallback, or manual recovery depending on severity.

11.7 KDS\_TICKET\_DUPLICATE\_SUSPECTED

A ticket may have been duplicated due to retry, replay, stale response, or manual fallback overlap.

Duplicate-suspected tickets must not silently create repeated kitchen work.

11.8 KDS\_TICKET\_REPLAYED

The kitchen projection was replayed.

Replay must preserve the original accepted order reference.

11.9 KDS\_TICKET\_MANUAL\_RECOVERY\_REQUIRED

The system cannot guarantee normal kitchen ticket delivery or state continuity.

Manual kitchen note or manager recovery may be required.

12\. Boundary State Model

A simplified POS-to-KDS boundary may follow this structure.

POS\_ACCEPTED
→ KDS\_TICKET\_CANDIDATE\_CREATED
→ KDS\_TICKET\_SENT
→ KDS\_TICKET\_RECEIVED
→ KDS\_TICKET\_ACKNOWLEDGED

Exception paths may include:

KDS\_TICKET\_FAILED
KDS\_TICKET\_DUPLICATE\_SUSPECTED
KDS\_TICKET\_REPLAYED
KDS\_TICKET\_MANUAL\_RECOVERY\_REQUIRED

This document defines policy-level states only. Runtime enum design may be defined later.

13\. Projection Idempotency

The KDS ticket projection must be idempotent where possible.

The same accepted order line should not create multiple active kitchen work units unless an explicit split, remake, or recovery reason exists.

Recommended identity anchors:

\- Source order reference
\- Source order line reference
\- Ticket purpose
\- Station route
\- Fulfillment segment
\- Remake sequence, if applicable
\- Replay sequence, if applicable

Idempotency is required to reduce duplicate food preparation.

14\. Ticket Split at Boundary

A POS accepted order may create multiple KDS tickets.

Valid split reasons include:

\- Station routing
\- Hot/cold separation
\- Drink/food separation
\- Packaging separation
\- Allergy isolation
\- Timing difference
\- Course sequence
\- Batch preparation

Ticket split must not create new commercial order lines.

Each split ticket must preserve source references.

15\. Ticket Merge at Boundary

Multiple accepted order lines may be grouped into one KDS work unit when operationally appropriate.

Valid merge reasons include:

\- Same item
\- Same station
\- Same table
\- Same timing window
\- Same batch
\- Same fulfillment route

Ticket merge must not hide:

\- Quantity
\- Modifier differences
\- Allergy notes
\- Caution notes
\- Customer timing requirements

If safety notes differ, merging should be avoided unless the highest caution level remains visible.

16\. Cancellation Race Conditions

Cancellation race conditions occur when an order or item changes after POS acceptance while the KDS handoff is pending or active.

Common cases:

\- Cancelled before KDS candidate creation
\- Cancelled after candidate creation but before sent
\- Cancelled after sent but before received
\- Cancelled after received but before acknowledged
\- Cancelled after acknowledged but before in progress
\- Cancelled after in progress
\- Cancelled after ready
\- Cancelled after completed

The KDS must not silently delete tickets in these cases.

The cancellation state must be projected as a stop, cancel, exception, or recovery signal depending on kitchen progress.

17\. Cancellation Boundary Policy

General rules:

\- Before kitchen awareness, cancellation may stop ticket creation.
\- After ticket sent, cancellation should be explicitly communicated.
\- After staff acknowledgment, cancellation requires visible stop-work handling.
\- After in-progress, cancellation may require waste, recovery, or manager review.
\- After ready, cancellation is no longer a simple kitchen deletion.
\- After completed, cancellation belongs mainly to customer recovery, refund, or settlement workflow.

KDS cancellation display is kitchen execution visibility, not commercial cancellation authority.

18\. Sold-out Boundary Policy

Sold-out state should prevent future order acceptance where possible.

Sold-out state must not retroactively remove already accepted order lines.

If a sold-out conflict appears after POS acceptance, the order must enter exception handling.

Possible handling:

\- Prepare if ingredient still exists
\- Substitute with approval
\- Delay
\- Customer recovery
\- Manager review
\- Refund workflow outside KDS

The KDS may show the conflict but must not mutate the accepted order truth.

19\. Menu Availability Boundary Policy

Menu availability belongs upstream of POS acceptance where possible.

After POS acceptance, KDS receives the accepted kitchen work projection.

If menu availability and accepted order truth conflict, the conflict must be resolved through explicit exception handling.

Silent mutation is prohibited.

20\. Delay Boundary Policy

KDS delay states are kitchen execution states.

Delay markers may inform:

\- Staff coordination
\- Customer message
\- Recovery review
\- Operations metric
\- Future improvement

Delay markers do not automatically authorize:

\- Refund
\- Compensation
\- Point grant
\- Order cancellation
\- Staff penalty

21\. Remake Boundary Policy

A remake ticket may be created from a kitchen, quality, customer recovery, or delivery issue.

A remake ticket must preserve:

\- Original order reference
\- Original line reference if applicable
\- Remake reason
\- Approval source if required
\- Remake sequence

A remake ticket is kitchen execution work.

A remake ticket is not automatically a refund or compensation decision.

22\. Retry Boundary Policy

Retry is a technical or operational attempt to deliver or recover a KDS ticket.

Retry must not create duplicate commercial order lines.

Retry must not create duplicate kitchen work unless the previous ticket state is known or explicitly marked uncertain.

If ticket receipt is uncertain, the ticket should be marked duplicate-suspected or manual-recovery-required.

23\. Replay and Recovery

Replay means reconstructing or re-sending a KDS projection from the original accepted order source.

Replay is allowed for:

\- KDS delivery failure
\- Bridge failure
\- Device recovery
\- Printer failure
\- Local cache recovery
\- Audit reconstruction
\- Staff recovery review

Replay must not:

\- Create a new POS order
\- Change payment state
\- Change order total
\- Hide original failure
\- Overwrite original event history
\- Remove manual recovery evidence

Replay appends evidence. Replay does not mutate history.

24\. Manual Fallback Boundary

Manual kitchen notes may be used when the KDS boundary is degraded.

Manual notes may record:

\- What staff prepared
\- What staff saw
\- What was missing
\- What was delayed
\- What was remade
\- What mismatch occurred

Manual notes are evidence.

Manual notes are not transaction authority.

After recovery, manual notes must be reconciled against POS accepted orders and KDS tickets.

25\. Degraded Operation Boundary

A degraded boundary exists when POS and KDS cannot maintain reliable handoff or state continuity.

Possible triggers:

\- KDS offline
\- KDS bridge failure
\- Printer failure
\- Local network partition
\- Ticket state uncertainty
\- Excessive delivery delay
\- Device display failure
\- Staff cannot trust ticket order

During degraded operation, the store must preserve:

\- Order reference when available
\- Item and quantity
\- Modifier and allergy information
\- Time
\- Staff note
\- Recovery evidence

26\. Duplicate Prevention Policy

Duplicate prevention requires stable references and clear state handling.

Duplicate risk increases when:

\- Retry timeout occurs
\- Vendor returns uncertain response
\- Printer prints twice
\- Manual note overlaps with system ticket
\- Local agent replays after reconnect
\- Staff manually recreates ticket
\- Split/merge rules are unclear

Duplicate-suspected tickets must be visible as such.

They must not be treated as normal new work without review.

27\. Boundary Mismatch Cases

Boundary mismatch may occur when POS and KDS disagree.

Examples:

\- POS accepted order exists, but no KDS ticket exists
\- KDS ticket exists, but POS accepted order cannot be confirmed
\- KDS ticket quantity differs from POS order line
\- Modifier missing in KDS
\- Allergy note missing in KDS
\- KDS says completed but POS says cancelled
\- POS says cancelled but KDS says in progress
\- Manual note exists but no KDS ticket exists
\- KDS duplicate exists for one order line

Mismatch must be resolved through review, not silent overwrite.

28\. Customer-facing Impact

The boundary may affect customer-facing messages.

Allowed customer-safe messages may include:

\- Order received
\- Kitchen preparing
\- Preparation delayed
\- Item requires confirmation
\- Staff will assist
\- Pickup time updated
\- Menu item unavailable after order, staff will confirm

Customer messages should avoid:

\- Internal blame
\- Vendor blame
\- Staff blame
\- Technical details
\- Financial promises not approved by policy
\- Refund promises from KDS state alone

29\. Staff-facing Impact

Staff-facing views should clearly distinguish:

\- POS accepted order
\- KDS ticket
\- Manual kitchen note
\- Duplicate-suspected ticket
\- Cancelled ticket
\- Delayed ticket
\- Remake ticket
\- Recovery ticket

Staff should not have to infer commercial truth from KDS display alone.

30\. HQ and Audit Visibility

HQ may need visibility into:

\- Boundary failure rate
\- KDS send failure
\- KDS receive failure
\- Duplicate-suspected count
\- Manual recovery count
\- Replay count
\- Sold-out conflict count
\- Cancellation race count
\- Allergy note missing risk
\- Average handoff delay

This visibility is for reliability improvement and audit, not automatic staff blame.

31\. Security and Privacy

KDS tickets should be privacy-minimized.

The KDS should not expose full customer identity unless operationally necessary.

Sensitive customer data, payment data, and loyalty data should not be displayed to kitchen staff by default.

Kitchen execution does not require broad customer profile visibility.

32\. Non-goals

This document does not define:

\- Database schema
\- API endpoint
\- RPC function
\- KDS UI component
\- Ticket printer driver
\- POS vendor integration code
\- Payment gateway logic
\- Refund workflow implementation
\- Inventory deduction algorithm
\- AI prediction logic
\- Robot kitchen handoff

33\. Acceptance Criteria

This policy is ready when:

\- POS accepted order and KDS ticket are clearly separated
\- POS transaction authority is explicit
\- KDS projection authority is explicit
\- Required boundary-crossing data is documented
\- Prohibited authority crossing is documented
\- Boundary event families are documented
\- Replay and retry are separated from new order creation
\- Duplicate prevention is addressed
\- Cancellation race conditions are documented
\- Sold-out and menu availability boundary rules are documented
\- Manual fallback is treated as evidence, not authority
\- Degraded operation boundary is acknowledged
\- No implementation-specific design is forced

34\. Open Questions

\- Should KDS ticket acknowledgment be required before kitchen work starts in MVP?
\- Should ticket idempotency be controlled by POS order line, KDS ticket id, or both?
\- Should station split happen before KDS handoff or within KDS?
\- Should manual notes be captured in the same recovery queue as failed KDS tickets?
\- Should sold-out conflict automatically block ticket creation or create a manager review ticket?
\- Should customer-facing delay messages be generated from KDS state or staff confirmation?
\- Should delivery orders and dine-in orders share the same boundary event model?
\- Should KDS replay be allowed by staff, manager only, or system only?
