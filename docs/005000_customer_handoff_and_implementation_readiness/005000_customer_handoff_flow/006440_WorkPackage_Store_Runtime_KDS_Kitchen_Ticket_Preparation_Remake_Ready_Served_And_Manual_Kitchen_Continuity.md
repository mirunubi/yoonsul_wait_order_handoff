# 006440_WorkPackage_Store_Runtime_KDS_Kitchen_Ticket_Preparation_Remake_Ready_Served_And_Manual_Kitchen_Continuity

## 1. Purpose

This WorkPackage defines the KDS and kitchen execution runtime boundary inside the Store Runtime lane.

The purpose is to ensure that order acceptance, kitchen ticket creation, preparation state, delay handling, remake, ready state, served state, manual kitchen note, and KDS degradation are governed by the same operational truth layer as customer session, kiosk, POS Gateway, staff tablet, and manager control flows.

Kitchen execution must not become a separate island.  
A store may accept payment and order state correctly, but still fail operationally if the kitchen does not receive, understand, execute, update, or recover the ticket safely.

This WorkPackage defines how kitchen runtime state must be created, controlled, corrected, and evidenced.

## 2. Scope

This WorkPackage covers:

- KDS runtime role
- Kitchen ticket lifecycle
- POS-accepted order to kitchen ticket boundary
- Preparation state control
- Ready and served state distinction
- Kitchen delay handling
- Remake handling
- Void/cancel kitchen handling
- Manual kitchen note fallback
- KDS outage and degraded operation
- Staff/kitchen communication boundary
- Evidence requirements for kitchen execution

This WorkPackage does not define full KDS UI design, hardware selection, recipe SOP, production station design, or kitchen labor scheduling.

## 3. Baseline Dependency

This WorkPackage depends on:

`014161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`006410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

`014162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control.md`

`014163_WorkPackage_Store_Runtime_Staff_Tablet_Manager_Console_Override_Manual_Control_And_Evidence_Boundary.md`

06400 defines the store runtime command layer.  
06410 defines customer session and order-state control.  
06420 defines kiosk and mini kiosk participation.  
06430 defines staff and manager authority.  
This document defines kitchen execution and KDS continuity inside that runtime.

## 4. Core Principle

A kitchen ticket is not merely a printed or displayed order.

It is the execution contract between Store Runtime and the kitchen.

The kitchen ticket must answer:

1. What must be prepared
2. For whom or which service context it is prepared
3. When it was accepted
4. Which order/payment/session it belongs to
5. Which station or kitchen role must act
6. Whether the order is normal, delayed, remake, cancelled, or manually handled
7. Whether staff or manager intervention is required
8. Whether the customer may be told the order is ready

No kitchen ticket may be created, duplicated, voided, or marked ready without traceable runtime state.

## 5. KDS Runtime Role

The KDS may support:

- Receiving kitchen-eligible tickets
- Displaying order items and preparation notes
- Grouping tickets by station, priority, or service mode
- Marking preparation started
- Marking delay
- Marking item unavailable
- Requesting staff clarification
- Marking remake required
- Marking ready
- Marking ticket voided where allowed
- Supporting manual continuity during degraded mode
- Preserving kitchen execution evidence

The KDS must not independently define payment truth or customer/session truth.

## 6. Kitchen Ticket Creation Boundary

A kitchen ticket may be created only when Store Runtime determines that the order is kitchen-eligible.

Kitchen eligibility may require:

- Order state is accepted or explicitly allowed for kitchen preview
- Payment state is approved, not required, or allowed by policy
- POS Gateway result is accepted or fallback route is approved
- Menu items are available or exception is handled
- Service mode is known
- Table or pickup context is known when required
- Duplicate ticket prevention has passed
- Cancellation state does not block cooking
- Staff/manual override is recorded if required

Kitchen ticket creation must not be triggered only by customer UI submission.

## 7. Kitchen Ticket Identity

A kitchen ticket must preserve separate references.

Required references include:

- Kitchen ticket ID
- Store ID
- Business date
- Order ID
- Customer or guest session reference, where applicable
- Waiting or table session reference, where applicable
- POS Gateway reference, where applicable
- Payment reference, where applicable
- KDS device or station reference
- Staff actor reference, where manually created or corrected
- Correlation ID

The kitchen ticket must not replace the order ID or payment ID.

## 8. Kitchen Ticket Lifecycle

A kitchen ticket may move through the following states:

| State | Meaning |
|---|---|
| Pending Creation | Runtime has determined possible kitchen eligibility |
| Created | Ticket exists but kitchen has not accepted or started |
| Kitchen Accepted | Kitchen has acknowledged ticket |
| Preparing | Preparation has started |
| Delayed | Kitchen has indicated delay |
| Clarification Required | Kitchen or staff needs additional information |
| Item Unavailable | Item cannot be prepared as ordered |
| Remake Required | Existing prepared item/order must be remade |
| Ready | Kitchen has completed preparation |
| Served Or Picked Up | Staff has delivered or customer has received |
| Void Requested | Ticket void has been requested |
| Voided | Ticket is no longer executable |
| Manual Kitchen Note | Ticket is being handled outside normal KDS flow |
| Recovery Required | Ticket state is ambiguous or inconsistent |

KDS state must remain connected to Store Runtime state.

## 9. Ready And Served Distinction

Ready and served must be separate states.

Ready means:

- Kitchen has completed preparation
- Order is physically or operationally ready for staff/customer handoff
- Staff may need to deliver, call, or stage the order

Served or picked up means:

- Customer has actually received the order
- Staff has completed the service handoff
- The order may be eligible for final closeout state

The kitchen must not mark an order as served merely because it is ready.  
Staff must not mark served unless the customer handoff occurred or a controlled exception is recorded.

## 10. Preparation State Control

Preparation state must be controlled by kitchen execution reality.

The system must support:

- Start preparation
- Pause or delay preparation
- Request clarification
- Mark partial readiness where allowed
- Mark complete readiness
- Flag remake
- Flag unavailable item
- Flag wrong ticket/table/order context
- Attach kitchen note

Preparation state changes must record actor, timestamp, station/device, and affected ticket.

## 11. Kitchen Delay Handling

Kitchen delay must be visible to staff and, where appropriate, customer-facing status.

Delay reasons may include:

- Item prep time exceeded
- Ingredient shortage
- Station overload
- Equipment issue
- Order clarification needed
- Payment/order state uncertainty
- Table/service context conflict
- Remake required
- Manual fallback mode

Delay must not silently accumulate without staff visibility.

Staff-facing delay information may be more detailed than customer-facing wording.

## 12. Item Unavailable Handling

Item unavailable after order submission is a high-risk operational condition.

The system must support:

- Kitchen marks item unavailable
- Staff receives action requirement
- Customer substitution or cancellation path is triggered
- Payment adjustment need is identified
- Manager approval is requested where required
- POS Gateway cancel/refund route is invoked where applicable
- Evidence is preserved

The kitchen must not independently replace, cancel, or refund an item without Store Runtime and staff/manager flow.

## 13. Remake Handling

Remake may be required when:

- Food quality issue occurs
- Wrong item was prepared
- Wrong option was applied
- Wrong table/order context was used
- Customer complaint is accepted
- Kitchen error is confirmed
- Staff delivery error occurred
- Temperature/hold-time standard failed

Remake handling must record:

- Original ticket reference
- Remake ticket reference
- Reason
- Actor
- Approval requirement
- Whether customer was affected
- Whether payment or refund impact exists
- Whether waste/loss should be recorded

Remake must not create duplicate payment or duplicate final served state.

## 14. Void And Cancel Kitchen Boundary

Order cancellation and kitchen void are related but not identical.

A kitchen ticket may need to be voided when:

- Order was cancelled before preparation
- POS/order state was rejected after ticket creation
- Duplicate ticket was created
- Wrong table/order context was assigned
- Manager approves exception
- Manual fallback route replaces KDS ticket

Voiding a kitchen ticket must not automatically refund payment.  
Refund and cancellation must follow POS Gateway and payment uncertainty rules.

## 15. Manual Kitchen Note Fallback

Manual kitchen note fallback may be used when:

- KDS is unavailable
- KDS ticket failed to create
- Printer/display path is degraded
- Staff must verbally or manually hand off order
- Kitchen requires clarification outside normal flow
- Network outage prevents normal ticket update
- Emergency peak operation requires controlled manual continuity

Manual kitchen notes must record:

- Who created the note
- Why manual note was required
- Which order/session/table it belongs to
- Which items and options were included
- Whether payment/order state was verified
- Whether later reconciliation is required
- Whether KDS recovery should create or suppress a duplicate ticket

Manual kitchen note fallback must not become invisible kitchen operation.

## 16. KDS Outage And Degraded Operation

KDS outage must trigger degraded operation rules.

KDS degradation may include:

- KDS unavailable
- KDS slow or unstable
- Station display unavailable
- Kitchen cannot update state
- Ticket creation fails
- Duplicate tickets appear
- Ticket state diverges from Store Runtime
- Manual notes replace KDS temporarily

During KDS degradation:

1. Store Runtime must mark KDS degraded
2. Staff must use manual kitchen continuity SOP
3. Kitchen execution evidence must be captured manually where possible
4. POS/order/payment truth must remain separate from kitchen display state
5. Recovery must prevent duplicate cooking
6. Manager review may be required before daily closeout

## 17. Staff And Kitchen Communication Boundary

Staff and kitchen communication must support structured operational flow.

Communication types include:

- Clarification request
- Delay notice
- Item unavailable notice
- Remake request
- Ready confirmation
- Wrong table/order warning
- Manual kitchen note
- Void request
- Customer complaint note

Free-text notes may be allowed, but sensitive operational actions must use structured state transitions.

## 18. Customer-Facing Kitchen Status Boundary

Customer-facing kitchen status must be conservative.

| Kitchen/Internal State | Customer-Facing Boundary |
|---|---|
| Created | Order received by kitchen |
| Preparing | Preparing your order |
| Delayed | Preparation is taking longer than expected |
| Clarification Required | Staff is checking your order |
| Item Unavailable | Staff will assist with your order |
| Ready | Your order is ready |
| Served Or Picked Up | Completed, if appropriate |
| Remake Required | Staff is handling your order |
| Recovery Required | Staff is checking your order |

Customer-facing status must not expose internal blame, sensitive staff notes, or uncertain financial state.

## 19. Evidence Requirements

The system must preserve evidence for:

- Kitchen ticket creation
- Kitchen ticket acceptance
- Preparation start
- Delay
- Clarification request
- Item unavailable
- Remake required
- Ready state
- Served or picked up state
- Void request
- Voided ticket
- Manual kitchen note
- KDS outage
- Degraded kitchen operation
- KDS recovery
- Duplicate ticket prevention
- Staff/kitchen communication
- Manager approval where required

Evidence must include:

- Ticket ID
- Order ID
- Store ID
- Business date
- Station/device ID
- Actor ID where applicable
- Timestamp
- Before state
- After state
- Reason
- Related incident ID where applicable

## 20. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- KDS runtime role is defined
- Kitchen ticket creation boundary is defined
- Kitchen ticket lifecycle is documented
- Ready and served states are separated
- Delay handling is defined
- Item unavailable handling is defined
- Remake handling is defined
- Void/cancel kitchen boundary is defined
- Manual kitchen note fallback is defined
- KDS outage and degraded operation rules are defined
- Evidence fields are defined

## 21. Acceptance Criteria

This WorkPackage is accepted when:

- Kitchen ticket identity is separated from order/payment identity
- Kitchen eligibility rules are documented
- KDS state transitions are traceable
- Ready and served are not collapsed
- Manual kitchen fallback is auditable
- KDS outage does not erase kitchen evidence
- Remake and item unavailable flows are controlled
- Kitchen void does not automatically imply refund
- Customer-facing kitchen status is conservative
- Open risks are routed to backlog, waiver, or blocker register

## 22. Out of Scope

This WorkPackage does not include:

- Full KDS UI design
- Kitchen station layout design
- Recipe SOP details
- Food safety HACCP documents
- Ingredient inventory decrement logic
- Labor scheduling
- Full customer compensation policy
- Full accounting settlement implementation
- Final hardware procurement

Those must be handled in their own lanes.

## 23. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- Staff Tablet and Manager Console WorkPackage
- POS Gateway readiness lane
- Manual fallback SOP
- Kitchen continuity policy
- Payment uncertainty policy
- Runtime evidence policy
- Incident register template
- Daily closeout checklist

## 24. Final Rule

The kitchen is where digital order truth becomes physical service reality.

The Store Runtime must ensure that every kitchen ticket, delay, remake, ready state, served state, manual note, and KDS failure remains visible, traceable, recoverable, and safe.

This WorkPackage defines the kitchen execution boundary before deeper daily closeout, inventory, and store pilot operations are expanded.