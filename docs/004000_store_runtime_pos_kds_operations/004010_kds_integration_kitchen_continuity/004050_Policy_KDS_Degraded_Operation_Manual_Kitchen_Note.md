# 004040_Policy_KDS_Degraded_Operation_Manual_Kitchen_Note

1\. Purpose

This document defines how kitchen operation continues when KDS is unavailable, delayed, stale, partially disconnected, or operationally untrusted.

The purpose is to ensure kitchen continuity without allowing manual fallback to silently replace POS truth, KDS evidence, or recovery review.

A degraded KDS state is an operational continuity problem.

It must not become silent state loss.

2\. Scope

This policy applies to:

\- KDS unavailable state
\- KDS delayed state
\- KDS stale state
\- KDS bridge failure
\- Kitchen screen failure
\- Kitchen printer fallback
\- Manual kitchen note usage
\- POS-to-KDS mismatch handling
\- Staff fallback behavior
\- Recovery and reconciliation after degraded operation

This policy does not define:

\- POS implementation
\- KDS vendor integration
\- Printer protocol
\- Network design
\- SQL schema
\- UI design
\- Refund approval
\- Payment mutation
\- Inventory deduction
\- Staff discipline logic

3\. Core Principle

Kitchen operation must survive KDS failure, but degraded operation must remain auditable.

KDS failure ≠ kitchen shutdown by default
Manual note ≠ POS truth
Fallback evidence ≠ silent mutation
Recovery ≠ overwrite
Replay ≠ new order

Manual fallback exists to keep the kitchen moving.

Manual fallback must preserve enough evidence to reconstruct what happened later.

4\. Degraded Operation Definition

Degraded operation means the normal POS-to-KDS kitchen execution flow cannot be trusted fully.

This may occur even when some systems are still online.

A degraded state exists when staff cannot confidently answer:

\- Which accepted orders require kitchen work?
\- Which tickets have been received?
\- Which tickets are duplicates?
\- Which tickets were started manually?
\- Which modifiers or allergy notes apply?
\- Which tickets were completed?
\- Which tickets require recovery?

5\. Degraded Operation Triggers

Degraded operation may be triggered by:

\- KDS offline
\- KDS screen unavailable
\- KDS bridge failure
\- POS-to-KDS handoff timeout
\- Ticket delivery uncertainty
\- KDS state stale beyond threshold
\- Kitchen printer unavailable
\- Kitchen printer duplicate output
\- Local network partition
\- Device reboot during service
\- Local agent queue uncertainty
\- Staff cannot trust displayed state
\- POS and KDS mismatch
\- Manual order handling already started
\- Allergy or caution note display failure
\- Severe delay in ticket appearance

6\. Degraded Operation Severity

Degraded operation may be classified by severity.

D1: Display Degraded
D2: Handoff Delayed
D3: Ticket State Uncertain
D4: Manual Kitchen Queue Required
D5: Recovery Review Required

6.1 D1 Display Degraded

KDS display is impaired, but POS or printer flow remains reliable.

Example:

\- One station screen unavailable
\- Secondary display used
\- Staff can still confirm tickets

6.2 D2 Handoff Delayed

Tickets arrive late, but eventually appear.

Example:

\- POS accepted order appears in KDS after delay
\- Staff needs temporary verbal confirmation

6.3 D3 Ticket State Uncertain

Staff cannot trust whether ticket was received, started, duplicated, or cancelled.

Example:

\- Retry occurred during network issue
\- Printer printed twice
\- KDS status conflicts with POS

6.4 D4 Manual Kitchen Queue Required

Normal KDS flow cannot support operation.

Staff must maintain manual kitchen notes as the active queue.

6.5 D5 Recovery Review Required

The store cannot safely reconcile degraded operation without manager or HQ review.

Examples:

\- Missing allergy note
\- Duplicate preparation risk
\- Accepted order with no kitchen evidence
\- Kitchen completed item with unclear POS state
\- Manual notes conflict with system records

7\. Manual Kitchen Note Definition

A manual kitchen note is a fallback evidence record created by staff when normal KDS continuity is degraded.

It may be written on paper, printed fallback sheet, local device, or approved emergency form.

A manual kitchen note records what the kitchen saw, prepared, delayed, remade, stopped, or completed during degraded operation.

A manual kitchen note is not a commercial order.

A manual kitchen note is not payment authority.

A manual kitchen note is not refund authority.

8\. Manual Kitchen Note Minimum Fields

A manual kitchen note should include the following fields where available.

Time
Order reference if available
Source channel if known
Item
Quantity
Modifier
Allergy or caution note
Fulfillment type
Table or pickup context
Staff initials
Kitchen state
Reason for manual note
Mismatch or uncertainty flag

If order reference is unavailable, the note must preserve enough context for later matching.

9\. Manual Note Kitchen State Values

Manual kitchen notes may use simple state labels.

Examples:

Seen manually
Started manually
Delayed manually
Ready manually
Completed manually
Remade manually
Stopped manually
Duplicate suspected
Mismatch found
Needs manager review

These labels are fallback evidence states.

They do not replace POS or KDS authoritative state.

10\. Manual Note Authority Boundary

Manual kitchen notes may support:

\- Kitchen continuity
\- Staff coordination
\- Later reconciliation
\- Customer recovery review
\- Duplicate review
\- Waste review
\- Delay evidence
\- Remake evidence
\- Audit reconstruction

Manual kitchen notes must not:

\- Create a revenue order
\- Capture payment
\- Approve refund
\- Mutate loyalty
\- Change menu master
\- Change inventory master
\- Silently cancel accepted order
\- Silently mark customer received
\- Delete KDS ticket history
\- Overwrite POS state

11\. Fallback Modes

11.1 Screen Unavailable but POS Available

If KDS screen is unavailable but POS remains usable, staff may reference POS accepted orders for kitchen work.

Required controls:

\- Preserve order reference
\- Capture item and modifier
\- Preserve allergy/caution notes
\- Record manual note if KDS state is not recoverable
\- Reconcile later

11.2 POS Accepted but KDS Delayed

If POS accepted order exists but KDS ticket is delayed, staff may begin manual tracking only if store policy allows kitchen start from POS confirmation.

Required controls:

\- Mark handoff delayed
\- Avoid duplicate preparation when KDS later appears
\- Compare manual note with KDS ticket after recovery
\- Mark duplicate suspected if needed

11.3 Printer Fallback

If kitchen printer is used as fallback, printed ticket must preserve:

\- Order reference
\- Item and quantity
\- Modifier
\- Allergy/caution
\- Time
\- Fulfillment context

Printer output may become fallback evidence, but duplicate prints must be controlled.

11.4 Full Manual Kitchen Queue

If KDS and printer are unavailable or untrusted, staff may operate from a manual kitchen queue.

Required controls:

\- Assign one staff member or manager to maintain queue order
\- Use consistent note format
\- Preserve allergy/caution visibly
\- Mark completed work
\- Mark delayed work
\- Mark remakes separately
\- Preserve all sheets or digital notes for reconciliation

11.5 Recovery Review Mode

After degraded operation, manager or authorized staff must reconcile manual notes against POS and KDS records.

Recovery review must append evidence.

Recovery review must not silently overwrite history.

12\. Degraded Operation Entry Procedure

When degraded operation begins:

1\. Identify the degraded trigger.
2\. Mark the affected area or station.
3\. Choose fallback mode.
4\. Assign staff responsibility.
5\. Preserve order references where possible.
6\. Preserve allergy/caution notes.
7\. Avoid duplicate preparation.
8\. Record manual notes.
9\. Notify manager if severity requires.
10\. Prepare for later reconciliation.

The goal is continuity with traceability.

13\. Degraded Operation Exit Procedure

When normal KDS flow appears restored:

1\. Stop creating new manual notes unless still needed.
2\. Collect all manual notes, printed tickets, and staff records.
3\. Compare manual records with POS accepted orders.
4\. Compare manual records with KDS tickets.
5\. Identify missing tickets.
6\. Identify duplicate tickets.
7\. Identify modifier or allergy note mismatch.
8\. Identify cancelled or stopped work.
9\. Mark unresolved cases for review.
10\. Append recovery evidence.

Normal display recovery does not automatically mean operational recovery is complete.

14\. Recovery and Reconciliation

Recovery means comparing fallback evidence with system records and resolving uncertainty.

Recovery should answer:

\- Was every accepted kitchen item seen?
\- Was every prepared item tied to an accepted order or approved recovery reason?
\- Were any items duplicated?
\- Were any items missed?
\- Were any modifiers lost?
\- Were any allergy/caution notes lost?
\- Were any cancelled items prepared?
\- Were any prepared items not handed off?
\- Which cases require manager review?
\- Which cases require customer recovery?

Recovery must be append-only in principle.

Recovery must not erase the degraded event.

15\. POS and Manual Note Mismatch

Possible mismatch cases:

\- POS accepted order exists, but no manual note exists
\- Manual note exists, but POS order cannot be found
\- Manual note quantity differs from POS line
\- Manual note modifier differs from POS line
\- Allergy note missing from manual note
\- Manual note says completed, POS says cancelled
\- POS says accepted, manual note says stopped
\- Manual note says remade, but no remake approval exists

Mismatch must be flagged.

Mismatch must not be silently resolved.

16\. KDS and Manual Note Mismatch

Possible mismatch cases:

\- KDS ticket exists, but manual note also created duplicate work
\- Manual note exists because KDS was delayed
\- KDS says received, staff says not seen
\- KDS says completed, manual note says delayed
\- KDS ticket missing modifier
\- KDS ticket missing allergy/caution
\- KDS replay created duplicate ticket
\- Printer output conflicts with screen state

Mismatch must be reviewed based on evidence.

17\. Allergy and Caution Handling During Fallback

Allergy and caution notes must remain visible during degraded operation.

If allergy or caution data cannot be confirmed, the ticket should not be treated as normal.

Fallback allergy rules:

\- Preserve allergy/caution note in large or explicit format.
\- Do not merge allergy-sensitive items casually.
\- Confirm uncertain allergy/caution notes with front staff or POS.
\- Mark missing allergy note as safety exception.
\- Escalate unresolved allergy uncertainty to manager.

Allergy note loss is a safety issue, not a formatting issue.

18\. Sold-out and Availability During Fallback

If item availability changes during degraded operation, staff must record:

\- Time of availability issue
\- Item affected
\- Quantity affected if known
\- Whether POS accepted orders already exist
\- Whether kitchen preparation started
\- Whether substitution or recovery is needed
\- Staff or manager source

Sold-out during fallback must not silently remove accepted orders.

If sold-out affects accepted orders, recovery or manager review is required.

19\. Remake During Fallback

If a remake occurs during degraded operation, manual note must record:

\- Original order reference if available
\- Item
\- Quantity
\- Remake reason
\- Staff source
\- Approval source if required
\- Time
\- Whether original item was wasted, served, or stopped

Fallback remake is kitchen work evidence.

It is not automatic compensation.

20\. Delay During Fallback

If a delay occurs during degraded operation, manual note should record:

\- Delayed item
\- Approximate delay start time
\- Reason if known
\- Customer-facing impact
\- Staff notified
\- Whether manager review is needed

Delay evidence may support customer communication and later analysis.

Delay evidence does not automatically approve refund.

21\. Duplicate Risk During Fallback

Duplicate risk is high during fallback.

Common causes:

\- KDS ticket appears after manual note started
\- Printer prints after staff already copied order
\- POS staff verbally calls order twice
\- Local agent replays after reconnect
\- Staff creates duplicate manual sheet
\- Remake is confused with original ticket

When duplicate risk exists, mark Duplicate Suspected.

Do not prepare again unless the kitchen lead or manager confirms.

22\. Staff Roles During Degraded Operation

Possible role responsibilities:

22.1 Kitchen Lead

\- Maintains kitchen execution order
\- Confirms manual queue
\- Controls duplicate risk
\- Escalates safety issues

22.2 Front Staff

\- Confirms POS accepted order
\- Provides customer timing or table context
\- Communicates safe delay message
\- Preserves customer-facing calm

22.3 Manager

\- Declares degraded mode when needed
\- Assigns fallback responsibilities
\- Approves recovery actions
\- Reviews mismatch cases
\- Closes degraded operation after reconciliation

22.4 HQ or Support

\- Reviews repeated failures
\- Analyzes reliability evidence
\- Updates SOP
\- Does not silently rewrite store records

23\. Customer Communication

Customer communication during degraded operation should be calm, simple, and non-technical.

Allowed examples:

\- “Your order is being confirmed by the kitchen.”
\- “Preparation may take a little longer than usual.”
\- “A staff member is checking your item.”
\- “We will confirm your pickup timing shortly.”

Avoid:

\- Blaming the system
\- Blaming staff
\- Explaining internal KDS failure
\- Promising refund without approval
\- Exposing kitchen confusion
\- Giving exact timing if uncertain

24\. Prohibited Actions

During degraded operation, staff must not:

\- Silently delete tickets
\- Ignore allergy/caution notes
\- Prepare duplicate items without review
\- Treat manual note as payment proof
\- Refund from manual note alone
\- Cancel POS order from KDS assumption
\- Hide KDS failure
\- Throw away manual notes before reconciliation
\- Mark dismissed alert as resolved
\- Treat recovered screen as completed recovery
\- Overwrite original event history
\- Merge allergy-sensitive items without clear marking

25\. Evidence Retention

Manual notes, printed fallback tickets, and recovery sheets should be retained according to store policy.

At minimum, degraded operation evidence should be available long enough to support:

\- Same-day reconciliation
\- Customer recovery review
\- Manager audit
\- HQ reliability review
\- Training improvement
\- Vendor troubleshooting if applicable

Exact retention duration may be defined in a separate audit or evidence packet policy.

26\. Metrics

The following metrics may be derived from degraded operation:

\- Degraded mode count
\- Degraded duration
\- Ticket handoff failure count
\- Manual note count
\- Manual queue duration
\- Mismatch count
\- Duplicate suspected count
\- Allergy/caution mismatch count
\- Sold-out conflict count
\- Recovery review count
\- Customer-impacting delay count
\- Printer fallback count
\- Screen fallback count

Metrics are for reliability improvement.

Metrics must not become automatic staff blame.

27\. Training Requirements

Staff training should cover:

\- When to enter degraded mode
\- How to write manual kitchen notes
\- How to preserve allergy/caution notes
\- How to avoid duplicate preparation
\- How to handle KDS delayed tickets
\- How to communicate with customers safely
\- How to collect notes after recovery
\- How to escalate manager review
\- What actions are prohibited

Training should emphasize continuity with evidence.

28\. Non-goals

This document does not define:

\- Full incident response system
\- Full audit evidence packet
\- Exact form template
\- Device failover architecture
\- Local agent implementation
\- Printer configuration
\- Network recovery procedure
\- Refund workflow
\- Compensation policy
\- Inventory adjustment policy
\- Staff disciplinary process

29\. Acceptance Criteria

This policy is ready when:

\- Degraded operation is clearly defined
\- Degraded triggers are documented
\- Manual kitchen note is defined as fallback evidence
\- Manual note minimum fields are documented
\- Authority boundary is explicit
\- Fallback modes are documented
\- Entry and exit procedures are documented
\- Recovery and reconciliation are documented
\- POS/manual mismatch handling is documented
\- KDS/manual mismatch handling is documented
\- Allergy/caution fallback handling is explicit
\- Sold-out during fallback is addressed
\- Duplicate risk is addressed
\- Staff roles are documented
\- Prohibited actions are documented
\- No implementation-specific runtime design is forced

30\. Open Questions

\- What is the minimum degraded duration before manager declaration is required?
\- Should staff use paper, tablet, or printed fallback sheet as the MVP manual note format?
\- Should manual notes be photographed after recovery?
\- Should degraded mode require a store-level incident id?
\- Should allergy/caution mismatch always require manager review?
\- Should POS-to-KDS mismatch automatically block normal closeout?
\- Who can declare recovery complete?
\- Should repeated degraded events trigger HQ review?
\- Should printer fallback be included in MVP or treated as later enhancement?
\- Should customer delay messaging be manual or system-assisted during degraded mode?
