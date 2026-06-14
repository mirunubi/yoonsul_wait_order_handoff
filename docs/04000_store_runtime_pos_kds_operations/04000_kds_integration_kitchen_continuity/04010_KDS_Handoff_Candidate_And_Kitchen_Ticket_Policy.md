04010 KDS Handoff Candidate And Kitchen Ticket Policy

1\. Purpose

This document defines which accepted order data may become a KDS handoff candidate and how kitchen tickets should be treated within the kitchen execution flow.

The purpose is to prevent confusion between commercial order authority and kitchen execution visibility.

The KDS exists to help the kitchen receive, understand, prepare, delay, retry, remake, and complete accepted food work. It does not create commercial order truth.

2\. Scope

This policy applies to:

\- POS accepted orders that may require kitchen preparation
\- KDS ticket creation candidates
\- Kitchen ticket lifecycle visibility
\- Kitchen station routing readiness
\- Ticket split and merge policy
\- Staff note and modifier handling
\- KDS handoff failure handling
\- Basic kitchen continuity requirements

This policy does not define:

\- Payment authorization
\- Refund approval
\- Loyalty mutation
\- Inventory master ownership
\- Menu master ownership
\- Customer identity ownership
\- Financial settlement
\- Full KDS vendor integration implementation

3\. Core Principle

A KDS handoff candidate is not an order.

A KDS ticket is not a transaction.

A kitchen ticket is a projection of accepted kitchen work derived from a POS accepted order or equivalent transaction-authoritative source.

The POS remains the transaction authority.

The KDS remains the kitchen execution visibility layer.

POS accepted order \= commercial truth
KDS ticket \= kitchen execution projection

4\. KDS Handoff Candidate Definition

A KDS handoff candidate is a prepared, structured, kitchen-relevant projection of an accepted order or accepted order line that may be sent to the KDS.

A candidate becomes valid only when the upstream order state has passed the minimum acceptance threshold required for kitchen work.

A candidate may exist before the kitchen sees it, but it must not be treated as completed kitchen work.

5\. Kitchen Ticket Definition

A kitchen ticket is the work unit displayed, routed, printed, or otherwise presented to kitchen staff for preparation.

A kitchen ticket may represent:

\- A full order
\- A single item line
\- A group of item lines
\- A station-specific subset
\- A delayed batch
\- A remake work unit
\- A recovery work unit

A kitchen ticket must preserve reference to the accepted order or accepted order line from which it originated.

6\. Candidate Eligibility

An order or order line may become a KDS handoff candidate only when all required conditions are satisfied.

6.1 POS Accepted

The order must be accepted by the POS or equivalent transaction-authoritative service.

Draft carts, browsing states, and unaccepted customer selections are not eligible.

6.2 Payment or Settlement State Is Sufficient

The order must meet the store's kitchen-start rule.

Examples:

\- Paid order
\- Store-approved postpaid table order
\- House-account order accepted by staff
\- Franchise-approved internal test order
\- Manager-approved recovery order

The KDS must not decide whether payment is sufficient.

6.3 Item Is Kitchen-preparable

The item must require kitchen action or fulfillment handling.

Examples:

\- Cooked food
\- Assembled food
\- Packed food
\- Drink preparation
\- Timed pickup item
\- Remake item

Non-kitchen items should be excluded unless the store explicitly routes them to KDS for fulfillment visibility.

6.4 Item Is Not Cancelled Before Kitchen Acceptance

If an item is cancelled before being sent or acknowledged by the kitchen, it should not create a normal kitchen ticket.

If already sent, the cancellation must be expressed as a cancellation or stop-work event, not as silent deletion.

6.5 Store and Kitchen Routing Context Exists

The candidate must include enough context to determine where the kitchen work belongs.

Minimum routing context may include:

\- Store
\- Fulfillment type
\- Item category
\- Kitchen station
\- Table or pickup context
\- Priority or timing note, if applicable

7\. Candidate Exclusion

The following must not become normal KDS handoff candidates:

\- Unpaid cart
\- Draft order
\- Customer browsing state
\- Rejected POS order
\- Failed payment order
\- Refund-only record
\- Loyalty-only transaction
\- Coupon-only transaction
\- Cancelled order before acceptance
\- Test event not approved for kitchen display
\- Non-kitchen item without explicit fulfillment routing

8\. Ticket Data Classes

A KDS ticket may include only the data needed for kitchen execution, safety, timing, and fulfillment.

8.1 Required Data

At minimum, a KDS ticket should include:

\- Order reference
\- Order line reference
\- Item display name
\- Quantity
\- Fulfillment type
\- Kitchen routing context
\- Created or accepted time
\- Ticket state

8.2 Conditional Data

The ticket may include:

\- Modifiers
\- Option groups
\- Allergy or caution note
\- Table or seating context
\- Pickup time
\- Customer timing request
\- Staff note
\- Bundle or set-menu context
\- Delay reason
\- Remake reason
\- Priority flag

8.3 Restricted Data

The KDS ticket should not expose unnecessary data such as:

\- Full customer identity
\- Full payment details
\- Loyalty balance
\- Refund details
\- Internal financial settlement
\- Sensitive customer profile information
\- Staff payroll information

9\. Authority Boundary

9.1 POS Authority

The POS or transaction-authoritative order service owns:

\- Accepted order truth
\- Payment state
\- Order total
\- Discount application
\- Tax or service charge
\- Commercial cancellation state
\- Refund eligibility state
\- Transaction audit trail

9.2 KDS Authority

The KDS owns or displays:

\- Kitchen ticket visibility
\- Kitchen work state
\- Station routing view
\- Preparation progress
\- Delay marker
\- Retry marker
\- Remake marker
\- Ready marker
\- Completed marker
\- Kitchen exception marker

9.3 KDS Prohibitions

The KDS must not:

\- Create a revenue order
\- Mutate payment state
\- Approve refunds
\- Change loyalty points
\- Change customer identity
\- Change menu master
\- Change inventory master
\- Silently delete accepted items
\- Retroactively change accepted order truth
\- Treat dismissed ticket as resolved exception

10\. Kitchen Ticket Lifecycle

A standard kitchen ticket lifecycle may include the following states.

Candidate
→ Sent
→ Received
→ Acknowledged
→ In Progress
→ Ready
→ Completed

Exception states may include:

Send Failed
Receive Failed
Duplicate Suspected
Delayed
Retry Required
Remake Required
Cancelled Before Kitchen Start
Stopped After Kitchen Start
Manual Recovery Required

The exact runtime enum may be defined later. This document defines the policy-level state families only.

11\. Candidate State

A candidate is a prepared projection that has not yet become visible kitchen work.

A candidate may fail before being sent to KDS.

Candidate failure must be logged if the accepted order still requires kitchen work.

A candidate must not be counted as kitchen-acknowledged work.

12\. Sent State

A sent ticket means the system attempted to deliver the candidate to KDS.

Sent does not guarantee that kitchen staff saw the ticket.

The system should distinguish between sent, received, and acknowledged where possible.

13\. Received State

A received ticket means the KDS endpoint, screen, printer, bridge, or local agent received the ticket payload.

Received does not guarantee that staff started work.

14\. Acknowledged State

An acknowledged ticket means kitchen staff or an authorized kitchen device accepted the ticket into active kitchen awareness.

Acknowledgment may be automatic only if the store policy explicitly permits it.

For MVP, manual staff acknowledgment is preferred where operationally feasible.

15\. In Progress State

In progress means the kitchen has started or committed to preparing the ticket.

Once a ticket reaches in progress, cancellation handling must be explicit.

Silent removal is prohibited.

16\. Ready State

Ready means the kitchen has completed preparation and the item is ready for handoff, pickup, packing, serving, or downstream fulfillment.

Ready does not mean payment is completed unless the POS separately confirms it.

17\. Completed State

Completed means the kitchen execution responsibility for the ticket is closed.

Completed does not mean:

\- Customer received the item
\- Delivery was successful
\- Payment was settled
\- Refund risk is gone
\- Complaint window is closed

18\. Ticket Split Policy

A POS accepted order may be split into multiple KDS tickets when required for kitchen execution.

Valid split reasons include:

\- Station routing
\- Item category
\- Preparation timing
\- Cold/hot separation
\- Drink/food separation
\- Batch cooking
\- Allergy isolation
\- Table course sequencing

Split tickets must preserve the original order and line references.

Split tickets must not create duplicate commercial order lines.

19\. Ticket Merge Policy

Multiple order lines may be merged into a kitchen work unit when appropriate.

Valid merge reasons include:

\- Batch preparation
\- Same station
\- Same item
\- Same timing window
\- Same table group
\- Operational efficiency

Merged tickets must not hide individual item quantities or allergy/caution requirements.

If allergy or caution notes differ, merging should be avoided unless the merged ticket clearly preserves the highest safety requirement.

20\. Modifier and Option Handling

Modifiers and options must be passed clearly enough for kitchen execution.

Examples:

\- No onion
\- Extra sauce
\- Spicy level
\- Rice amount
\- Protein option
\- Packaging option
\- Separate sauce
\- Allergy caution

Modifier loss is a kitchen safety and customer recovery risk.

A ticket with missing required modifier data should enter exception handling instead of being silently prepared.

21\. Allergy and Caution Notes

Allergy and caution notes must be treated as high-priority kitchen information.

The KDS should visually or operationally distinguish allergy/caution notes from ordinary customer preference notes.

If KDS is degraded, allergy/caution notes must be preserved in manual kitchen notes.

Failure to preserve allergy/caution notes is not a minor display issue. It is an operational safety issue.

22\. Staff Notes

Staff notes may be included in the KDS ticket when relevant to kitchen execution.

Examples:

\- Customer requested later pickup
\- Table wants food together
\- VIP recovery order
\- Re-fire after delay
\- Packaging separately
\- Hold until staff call

Staff notes must not be used to bypass formal refund, remake, or payment policy.

23\. Fulfillment Context

The ticket should clearly indicate the fulfillment context.

Examples:

\- Dine-in
\- Takeout
\- Delivery
\- Waiting customer
\- Pickup reservation
\- Table order
\- Group order
\- Staff meal
\- Recovery order

Fulfillment context affects timing, packaging, sequencing, and customer communication.

24\. KDS Handoff Failure Handling

If a KDS handoff fails, the system must not assume the kitchen received the work.

Failure handling may include:

\- Retry
\- Re-send
\- Manual kitchen note
\- Printer fallback
\- Staff alert
\- Manager confirmation
\- Recovery queue
\- Post-recovery reconciliation

A failed KDS handoff must not create a duplicate POS order.

Replay means re-sending the kitchen projection. Replay does not mutate the original commercial order.

25\. Duplicate Ticket Risk

Duplicate tickets may occur when:

\- POS sends again after timeout
\- KDS bridge retries without idempotency
\- Staff manually prints while system retries
\- Network partition recovers
\- Local agent replays stale queue
\- Vendor integration returns uncertain status

Duplicate risk must be handled through stable references and duplicate-suspected states.

A duplicate-suspected ticket should be reviewed before kitchen work is repeated.

26\. Cancellation Race Conditions

A cancellation race condition occurs when an order or item is cancelled while KDS handoff is in progress.

Possible cases:

\- Cancelled before ticket sent
\- Cancelled after sent but before received
\- Cancelled after received but before acknowledged
\- Cancelled after acknowledged but before in progress
\- Cancelled after in progress
\- Cancelled after ready

Each case requires explicit policy.

General rule:

The later the kitchen state, the more explicit the stop, remake, waste, or recovery evidence must be.

27\. Sold-out Interaction

Sold-out state may prevent future orderability.

Sold-out state must not silently remove already accepted order lines.

If an item becomes sold out after acceptance, the accepted order must enter exception or recovery handling.

The KDS may display the issue, but it must not unilaterally mutate POS truth.

28\. Menu Availability Interaction

Menu availability should be checked before POS acceptance where possible.

After POS acceptance, KDS receives accepted kitchen work.

If menu availability and accepted order truth conflict, the conflict must be resolved through exception handling, not silent mutation.

29\. Degraded Operation Interaction

If KDS is unavailable, delayed, stale, or partially disconnected, the store must continue through a defined degraded operation path.

Possible fallback modes include:

\- POS screen reference
\- Kitchen printer
\- Manual kitchen note
\- Staff runner
\- Local agent queue
\- Manager-controlled recovery list

Manual notes are fallback evidence. They are not transaction authority.

30\. Staff Visibility Rules

Kitchen staff should see only the information needed to prepare and fulfill the ticket safely.

Store managers may see broader context such as delay, recovery, and mismatch states.

HQ may see aggregate reliability, failure, and audit evidence.

Customer-facing visibility must be safe, non-blaming, and simplified.

31\. Metrics

The following metrics may be derived from KDS tickets:

\- Candidate creation count
\- Ticket sent count
\- Ticket receive failure count
\- Acknowledgment time
\- Ticket age
\- In-progress duration
\- Ready duration
\- Completion duration
\- Retry count
\- Remake count
\- Duplicate-suspected count
\- Manual recovery count
\- Degraded operation count

Metrics are for operational improvement, not automatic blame.

32\. Audit and Evidence

Important events should be auditable.

Examples:

\- Candidate created
\- Ticket sent
\- Ticket received
\- Ticket acknowledged
\- Ticket delayed
\- Ticket retried
\- Ticket remade
\- Ticket completed
\- Ticket failed
\- Manual fallback used
\- Duplicate suspected
\- Cancellation race detected
\- Sold-out conflict detected

Audit evidence must preserve enough reference to reconstruct the flow.

33\. Non-goals

This document does not define:

\- SQL schema
\- API contract
\- Flutter UI
\- KDS vendor protocol
\- Printer driver behavior
\- Inventory engine
\- AI prediction model
\- Staff scheduling
\- Financial settlement
\- Refund automation

34\. Acceptance Criteria

This policy is ready when:

\- KDS handoff candidate is clearly defined
\- Kitchen ticket is clearly separated from POS order truth
\- Candidate eligibility and exclusion rules are documented
\- Ticket lifecycle state families are documented
\- Ticket split and merge policy is documented
\- Modifier, allergy, and staff note handling are documented
\- KDS authority boundary is explicit
\- Duplicate and replay risk are addressed
\- Cancellation race conditions are recognized
\- Sold-out and menu availability interaction is documented
\- Degraded operation dependency is acknowledged
\- No implementation-specific runtime decision is forced

35\. Open Questions

\- Should MVP require manual kitchen acknowledgment, or is automatic received state enough?
\- Should ticket split occur before KDS handoff or inside KDS?
\- Should drink preparation be routed through the same KDS policy or separate fulfillment display?
\- Should table course sequencing be included in MVP?
\- How much customer timing information should be visible to kitchen staff?
\- Should duplicate-suspected tickets be hidden, marked, or blocked?
\- Should sold-out conflict automatically create a manager review case?
\- What is the minimum fallback format when both KDS and printer are unavailable?
