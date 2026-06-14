04030 KDS Retry Remake Delay And Fulfillment Status Policy

1\. Purpose

This document defines the policy-level fulfillment status families for KDS kitchen execution.

The purpose is to separate kitchen execution states from commercial order, payment, refund, loyalty, and settlement states.

KDS fulfillment status helps staff understand whether a kitchen ticket is received, acknowledged, in progress, delayed, ready, completed, retried, remade, or in exception.

A KDS status is kitchen execution evidence.

A KDS status is not payment authority.

2\. Scope

This policy applies to:

\- KDS ticket fulfillment status
\- Retry handling
\- Remake handling
\- Delay handling
\- Ready and completed states
\- Kitchen exception states
\- Duplicate and replay risk
\- Customer-safe visibility
\- Staff-facing kitchen coordination
\- Audit and evidence requirements

This policy does not define:

\- POS payment state
\- Refund approval
\- Loyalty compensation
\- Inventory deduction
\- Staff payroll
\- Customer complaint final decision
\- Vendor-specific KDS protocol
\- Runtime enum implementation
\- UI implementation

3\. Core Principle

KDS status describes kitchen work.

POS status describes transaction truth.

Customer recovery status describes service resolution.

Finance status describes money movement.

These must not be collapsed into one state.

KDS status \= kitchen execution state
POS status \= transaction state
Recovery status \= customer service state
Finance status \= settlement/payment state

A delayed kitchen ticket does not automatically mean refund.

A remake ticket does not automatically mean compensation.

A completed kitchen ticket does not automatically mean customer received the item.

A dismissed KDS alert does not mean the issue is resolved.

4\. Fulfillment Status Families

The KDS may use the following policy-level status families.

Received
Acknowledged
In Progress
Delayed
Ready
Completed
Retry Required
Remake Required
Cancelled Before Kitchen Start
Stopped After Kitchen Start
Exception
Manual Recovery Required
Duplicate Suspected

The exact technical enum may be defined later.

This document defines the operating meaning of each status family.

5\. Received

Received means the KDS endpoint, device, printer, bridge, or local agent received the ticket payload.

Received does not mean:

\- Staff saw the ticket
\- Staff accepted the ticket
\- Kitchen started preparation
\- Payment is complete
\- Customer has been notified

Received is a technical or device-level delivery signal.

6\. Acknowledged

Acknowledged means kitchen staff or an authorized kitchen device has accepted the ticket into kitchen awareness.

Acknowledged does not mean preparation has started.

For MVP, acknowledgment should preferably be explicit if staff workload allows.

Automatic acknowledgment may be allowed only when the store policy accepts that risk.

7\. In Progress

In Progress means the kitchen has started or committed to preparing the ticket.

After this state, cancellation and sold-out conflicts require explicit handling.

Silent deletion is prohibited.

Possible examples:

\- Ingredient prep started
\- Cooking started
\- Assembly started
\- Packaging started
\- Station has pulled the ticket into active work

8\. Delayed

Delayed means the ticket cannot proceed within the expected kitchen flow.

Delay is a kitchen execution signal, not a financial decision.

Delay may require customer communication, manager review, or recovery handling depending on severity.

Delay must be reasoned where possible.

9\. Ready

Ready means kitchen preparation is complete and the item is ready for the next handoff step.

Ready may mean:

\- Ready for counter handoff
\- Ready for table serving
\- Ready for packing
\- Ready for delivery pickup
\- Ready for staff runner
\- Ready for batch release

Ready does not mean:

\- Customer received the item
\- Delivery partner picked up the item
\- Payment was settled
\- Complaint risk is closed

10\. Completed

Completed means kitchen execution responsibility for the ticket is closed.

Completed may be marked when:

\- Item was handed to front staff
\- Item was packed and moved to pickup zone
\- Item was handed to delivery flow
\- Table service handoff was completed
\- Recovery remake was prepared and closed

Completed does not mean the entire customer journey is complete.

11\. Retry Required

Retry Required means the system or operation must attempt ticket delivery, ticket state confirmation, or kitchen projection recovery again.

Retry may be technical or operational.

Retry must not create a new commercial order.

Retry must not create duplicate kitchen work unless explicitly confirmed.

12\. Remake Required

Remake Required means the kitchen needs to prepare the item again.

Remake must preserve source order references and reason evidence.

A remake is kitchen work.

A remake is not automatically refund, compensation, loyalty credit, or staff penalty.

13\. Cancelled Before Kitchen Start

Cancelled Before Kitchen Start means the order line or ticket was stopped before kitchen staff began preparation.

This state should preserve traceability.

It must not silently erase the ticket if the ticket was already visible or sent.

14\. Stopped After Kitchen Start

Stopped After Kitchen Start means the kitchen had already started or committed to work, but the work should stop.

This state may require:

\- Waste evidence
\- Manager review
\- Customer recovery review
\- Refund workflow outside KDS
\- Staff note
\- Ingredient impact note

Stopping after kitchen start is operationally different from cancellation before kitchen start.

15\. Exception

Exception means the ticket cannot proceed normally.

Examples:

\- Missing modifier
\- Missing allergy note confirmation
\- Sold-out conflict
\- Menu availability conflict
\- Duplicate suspected
\- KDS state mismatch
\- POS/KDS mismatch
\- Printer failure
\- Ticket stale
\- Staff cannot trust the displayed state
\- Manual note conflict
\- Customer timing conflict

Exception requires review or recovery.

Exception must not be dismissed as resolved without evidence.

16\. Manual Recovery Required

Manual Recovery Required means the system cannot guarantee normal KDS continuity and staff must use a fallback procedure.

Examples:

\- KDS offline
\- KDS bridge unstable
\- Ticket delivery uncertain
\- Kitchen screen unavailable
\- Printer fallback failed
\- POS-to-KDS mismatch unresolved
\- Local network partition
\- Staff manually handled the order before system recovery

Manual recovery must preserve evidence.

Manual recovery is not silent mutation.

17\. Duplicate Suspected

Duplicate Suspected means the same accepted order line may have produced more than one kitchen work signal.

Possible causes:

\- Retry timeout
\- Replay after reconnect
\- Printer duplicate
\- Manual note overlap
\- Staff manually recreated ticket
\- KDS bridge returned uncertain response
\- Split and merge rules were unclear

Duplicate suspected tickets must be reviewed before repeating kitchen work.

18\. Retry Policy

Retry is used to recover delivery, visibility, or state continuity.

18.1 Technical Retry

Technical retry may occur when:

\- KDS endpoint timeout occurs
\- Bridge response is missing
\- Printer response is missing
\- Local agent queue is uncertain
\- Network response is stale
\- Ticket delivery status is unknown

Technical retry should preserve the original accepted order reference and ticket correlation reference.

18.2 Operational Retry

Operational retry may occur when:

\- Staff did not see the ticket
\- Station did not receive the ticket
\- Ticket was routed to wrong station
\- Ticket display was cleared accidentally
\- Kitchen device rebooted
\- Manual fallback needs reconciliation

Operational retry must not create duplicate commercial order lines.

18.3 Retry Safety Rule

Retry must answer one question before repeating kitchen work:

Was the previous ticket only not visible, or was the food already being prepared?

If uncertain, mark Duplicate Suspected or Manual Recovery Required.

18.4 Retry Prohibitions

Retry must not:

\- Create a new POS order
\- Change payment state
\- Change order total
\- Hide original failure
\- Delete original ticket history
\- Duplicate kitchen work without review
\- Treat timeout as proof of non-receipt

19\. Remake Policy

Remake is used when the kitchen must prepare the same item again for an approved operational reason.

19.1 Remake Reason Families

Remake reasons may include:

\- Kitchen quality failure
\- Wrong item prepared
\- Wrong modifier applied
\- Allergy/caution handling issue
\- Customer recovery request
\- Delivery damage
\- Spillage
\- Temperature failure
\- Overcooked or undercooked item
\- Lost item
\- Staff-approved service recovery
\- Manager-approved replacement

19.2 Remake Authority

The authority to request or approve a remake may differ by reason.

Examples:

\- Kitchen lead may initiate quality remake.
\- Manager may approve customer recovery remake.
\- Front staff may request remake review.
\- Delivery damage remake may require recovery workflow.
\- Allergy-related remake may require manager confirmation.

The KDS records remake execution.

The KDS does not define refund or compensation authority.

19.3 Remake Ticket Requirements

A remake ticket should preserve:

\- Original order reference
\- Original order line reference
\- Original ticket reference, if available
\- Remake sequence number
\- Remake reason
\- Requesting staff or source
\- Approval source, if required
\- Time
\- Related customer recovery reference, if any

19.4 Remake Prohibitions

Remake must not:

\- Hide the original failure
\- Delete the original ticket
\- Create an untracked free item
\- Automatically trigger refund
\- Automatically assign blame
\- Bypass allergy/caution rules
\- Bypass sold-out conflict handling

20\. Delay Policy

Delay means kitchen work is slower, blocked, paused, or intentionally held.

20.1 Delay Reason Families

Delay reasons may include:

\- Ingredient delay
\- Prep delay
\- Station congestion
\- Batch timing
\- Equipment issue
\- Staff shortage
\- Order surge
\- Customer timing request
\- Delivery partner timing issue
\- Table course sequencing
\- Sold-out conflict review
\- Modifier confirmation needed
\- Allergy/caution confirmation needed
\- Manual recovery mode

20.2 Delay Severity

Delay severity may be grouped as:

Minor Delay
Operational Delay
Customer-impacting Delay
Recovery-risk Delay
Critical Delay

Severity affects who must see the delay and whether customer communication is needed.

20.3 Delay Visibility

Delay visibility may differ by audience.

Kitchen staff may see operational reason.

Front staff may see customer-safe reason.

Manager may see full reason and recovery risk.

Customer may see only simplified safe message.

HQ may see aggregate metrics and audit evidence.

20.4 Delay Prohibitions

Delay marker must not automatically:

\- Refund the order
\- Cancel the order
\- Grant points
\- Penalize staff
\- Mutate inventory
\- Disable the menu item
\- Promise exact compensation

21\. Fulfillment Completion Policy

Fulfillment completion should close kitchen responsibility only.

It should not close the whole order lifecycle.

A completed KDS ticket may still require:

\- Counter handoff
\- Table service
\- Delivery pickup
\- Customer receipt
\- Payment completion for postpaid table
\- Complaint window
\- Recovery review
\- Settlement

Completed means kitchen work has been completed for that ticket.

22\. Status Authority

22.1 Kitchen Staff Authority

Kitchen staff may update kitchen execution states such as:

\- Acknowledged
\- In Progress
\- Ready
\- Completed
\- Delayed
\- Retry requested
\- Remake requested
\- Exception noted

Actual permission details may be role-based later.

22.2 Manager Authority

Manager may approve or review:

\- Customer recovery remake
\- Critical delay
\- Stop after kitchen start
\- Waste-related exception
\- Sold-out conflict after acceptance
\- Duplicate suspected resolution
\- Manual recovery closure

22.3 POS Authority

POS remains authority for:

\- Accepted order truth
\- Commercial cancellation
\- Payment state
\- Refund workflow trigger
\- Order total
\- Settlement reference

22.4 HQ Authority

HQ may define policy, audit reliability, review patterns, and analyze risk.

HQ visibility does not mean direct kitchen mutation by default.

23\. Customer Visibility

Customer-facing messages should be safe and simple.

Allowed examples:

\- “Your order is being prepared.”
\- “Preparation is taking a little longer than expected.”
\- “A staff member is checking your order.”
\- “Your order is ready for pickup.”
\- “Your item needs confirmation before preparation continues.”

Avoid:

\- Vendor blame
\- Staff blame
\- Internal station details
\- Technical KDS terms
\- Financial promises
\- Legal conclusions
\- Unconfirmed exact recovery promises

24\. Staff Visibility

Staff-facing KDS status should be operationally actionable.

The status should help staff answer:

\- What should be prepared?
\- Where should it be prepared?
\- What is delayed?
\- What needs attention?
\- What was remade?
\- What may be duplicated?
\- What requires manager review?
\- What must be reconciled after fallback?

25\. Audit and Evidence

The following status changes should be auditable where possible:

\- Received
\- Acknowledged
\- In Progress
\- Delayed
\- Ready
\- Completed
\- Retry Required
\- Retry Attempted
\- Remake Required
\- Remake Approved
\- Remake Completed
\- Cancelled Before Kitchen Start
\- Stopped After Kitchen Start
\- Exception Created
\- Manual Recovery Required
\- Duplicate Suspected
\- Duplicate Resolved

Audit should preserve:

\- Time
\- Store
\- Ticket reference
\- Source order reference
\- Source order line reference
\- Staff or system source
\- Reason
\- Previous status
\- New status
\- Recovery reference, if any

26\. Race Conditions

KDS status may race with POS or staff actions.

Examples:

\- POS cancellation while KDS is in progress
\- KDS ready while customer cancels
\- Sold-out marked after POS acceptance
\- Retry occurs while staff manually prepares
\- Remake requested while original ticket completes
\- Delay marked after order was already handed off
\- Printer prints after screen ticket failed
\- Local agent replays after manager manually resolved

Race conditions require explicit state reconciliation.

They must not be resolved by silent overwrite.

27\. Sold-out and Availability Conflict

If a ticket encounters sold-out or availability conflict after acceptance, the ticket should enter exception, delay, or manager review.

Possible handling:

\- Prepare remaining available quantity
\- Confirm substitution
\- Delay until prep becomes available
\- Trigger customer recovery review
\- Trigger refund workflow outside KDS
\- Cancel through POS authority
\- Record waste or shortage evidence

KDS may display and record the conflict.

KDS must not retroactively mutate accepted order truth.

28\. Manual Fallback Interaction

During degraded operation, fulfillment states may be recorded by manual kitchen note.

Manual note states may include:

\- Seen manually
\- Started manually
\- Delayed manually
\- Remade manually
\- Ready manually
\- Completed manually
\- Mismatch found
\- Recovery needed

Manual states must be reconciled later with POS and KDS records.

Manual notes are evidence, not silent replacement.

29\. Metrics

KDS fulfillment status may produce metrics such as:

\- Average acknowledgment time
\- Average in-progress duration
\- Average ready time
\- Average completion time
\- Delay count
\- Delay duration
\- Remake count
\- Retry count
\- Duplicate-suspected count
\- Manual recovery count
\- Exception count
\- Sold-out conflict count
\- Cancellation race count

Metrics should support operational improvement.

Metrics should not automatically become staff punishment.

30\. Non-goals

This document does not define:

\- Database tables
\- API request format
\- Flutter components
\- KDS vendor integration
\- Printer protocol
\- Exact enum values
\- AI prediction model
\- Customer compensation formula
\- Refund approval logic
\- Inventory deduction logic
\- Staff discipline logic

31\. Acceptance Criteria

This policy is ready when:

\- KDS fulfillment status families are defined
\- Retry is separated from replay and new order creation
\- Remake is separated from refund and compensation
\- Delay is separated from financial authority
\- Ready and completed are limited to kitchen execution meaning
\- Exception and manual recovery states are documented
\- Duplicate suspected handling is included
\- Status authority is separated by role/system
\- Customer-safe visibility is defined
\- Audit and evidence expectations are documented
\- Race conditions are acknowledged
\- Sold-out and availability conflicts are handled without silent mutation
\- No implementation-specific runtime design is forced

32\. Open Questions

\- Should MVP include explicit Acknowledged state, or start from Received?
\- Should kitchen staff be able to mark Remake Required directly?
\- Which remake reasons require manager approval?
\- What delay duration should trigger customer-facing message?
\- Should delay severity be automatic or staff-selected?
\- Should Duplicate Suspected block ticket display or display with warning?
\- Should Ready and Completed be separate for all fulfillment types?
\- Should delivery pickup introduce a separate Handoff state?
\- Should manual recovery states use the same status family or a separate evidence packet?
\- Should sold-out conflict create an automatic manager review case?
