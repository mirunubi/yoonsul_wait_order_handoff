# 006530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md

## 1. Purpose

This policy defines the table matching, table session, preorder link, service context, and seating control boundary.

The purpose is to ensure that waiting, preorder, table assignment, dine-in service, staff correction, kitchen execution, and payment/order state remain connected after a customer is seated.

A table is not only a physical seat.  
It is a store runtime service context that may connect customer session, party identity, preorder, order, payment, staff action, KDS ticket, kitchen state, and customer dispute evidence.

This policy defines how table matching and table session control must preserve operational truth.

## 2. Scope

This policy covers:

- Table matching boundary
- Table session creation
- Waiting-to-table transition
- Preorder-to-table linkage
- Table reassignment
- Table merge and split
- Staff and manager correction
- Service context control
- Table-linked order and payment state
- Table-linked KDS and kitchen handoff
- Evidence requirements

This policy does not define full floor-plan optimization, reservation engine, physical table design, QR/NFC hardware placement, or final table-order UI implementation.

## 3. Baseline Dependency

This policy depends on:

`006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

`006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md`

06510 defines the entrance customer link boundary.  
06520 defines waiting queue, call, arrival, no-show, and seating control.  
This document defines the table matching and table service context after seating begins.

## 4. Core Principle

A table assignment must not break the customer runtime thread.

The system must preserve continuity across:

1. Waiting session
2. Customer or guest session
3. Party identity
4. Customer link
5. Preorder or cart
6. Table assignment
7. Order state
8. Payment state
9. KDS/kitchen ticket
10. Staff action
11. Daily closeout evidence

A table number alone is not enough.

The system must know which party, session, order, payment, and service context the table belongs to.

## 5. Table Identity Boundary

The system must distinguish between table-related identities.

| Identity Type | Meaning |
|---|---|
| Physical Table | Actual physical table or seat group in the store |
| Table Label | Customer/staff-visible table name or number |
| Table Session | Runtime service context for a party at a table |
| Waiting Session | Queue context before seating |
| Party Identity | Customer group being served |
| Customer Session | Guest or account-linked customer flow |
| Order Session | Cart, preorder, or accepted order linked to service |
| Payment Reference | Payment attempt or approval linked to order |
| KDS Ticket | Kitchen execution ticket linked to table/order |
| Staff Actor | Staff member assigning, correcting, or serving table |

The table session must not replace customer, order, payment, or waiting identity.

## 6. Table State Lifecycle

A physical table may move through operational states.

| State | Meaning |
|---|---|
| Available | Table may be assigned |
| Candidate | Table is suggested or being considered |
| Held | Table is temporarily held for a party |
| Assigned | Table assigned to waiting/customer session |
| Arrival Confirmed | Party is confirmed for seating |
| Occupied | Party is seated and service context is active |
| Ordering | Table has active order flow |
| Kitchen Active | Kitchen ticket exists for table-linked order |
| Ready Or Serving | Food/service handoff is in progress |
| Closing | Table session is being closed |
| Released | Table returned to available pool |
| Blocked | Table cannot be used |
| Manual Review Required | Staff/manager must resolve ambiguous state |

Table state must be separated from order state and payment state.

## 7. Table Session Lifecycle

A table session may move through:

| State | Meaning |
|---|---|
| Created | Table session created for party/service context |
| Linked To Waiting | Waiting session attached |
| Linked To Preorder | Preorder/cart attached |
| Seating Confirmed | Staff confirmed seating |
| Active Service | Customer is being served |
| Order Active | One or more orders exist |
| Payment Pending | Payment remains pending or uncertain |
| Kitchen Pending | Kitchen state remains open |
| Closeout Pending | Table service closeout is pending |
| Closed | Table session closed |
| Recovery Required | Table/session state is ambiguous |
| Dispute Linked | Customer dispute is linked |

A table session may remain open even after the physical table is released if payment, dispute, or evidence review remains pending.

## 8. Table Matching Rules

Table matching must consider:

- Party size
- Table capacity
- Store layout
- Accessibility needs, if policy allows
- Waiting order
- Service mode
- Preorder or order state
- Staff availability
- Kitchen load
- Table cleaning/readiness
- Manager exception
- Customer preference, where allowed

Table matching may be automatic, staff-assisted, or manager-approved depending on risk.

Automatic matching must not override staff-visible operational constraints.

## 9. Waiting-To-Table Transition

A waiting session may transition to table session only when:

- Waiting session is valid
- Arrival is confirmed or staff-approved
- Physical table is available or held
- Party size is compatible or exception-approved
- Preorder/cart state is reviewed
- Payment/order uncertainty does not block seating
- Staff actor or system trigger is recorded
- Table session is created or linked
- Customer-facing status is updated safely

The transition must preserve the waiting session reference.

## 10. Preorder-To-Table Linkage

A preorder or cart may be linked to a table session when:

- Customer/party identity matches or is staff-confirmed
- Waiting session matches or is staff-confirmed
- Table session is active
- Order has not expired
- Menu availability remains valid or is revalidated
- Payment state allows continuation
- Staff or manager review occurs where required

A preorder linked to the wrong table can create serious kitchen, payment, and customer dispute risk.

Preorder-to-table linkage must be auditable.

## 11. Table-Linked Order Control

Orders linked to table sessions must preserve:

- Table session ID
- Order ID
- Customer/guest reference
- Party reference
- Staff actor, if assisted
- POS Gateway state
- Payment state
- KDS ticket state
- Service mode
- Business date
- Correlation ID

Table-linked order state must not be inferred only from table number.

The same table may have multiple orders during a session.  
The same customer may have multiple order sessions.  
The same order may not be duplicated because table state refreshed or changed.

## 12. Table Reassignment

Table reassignment may be required when:

- Wrong table was assigned
- Party moved tables
- Table became unavailable
- Staff seated wrong party
- Preorder was linked to wrong table
- KDS ticket was routed with wrong table context
- Customer requested movement
- Manager approved exception
- Operational incident required reseating

Table reassignment must record:

- Previous table
- New table
- Table session
- Waiting/customer/order references
- Actor
- Reason
- Timestamp
- Affected KDS tickets
- Affected payment/order state
- Customer-facing impact

Table reassignment must not duplicate kitchen tickets or detach payment/order evidence.

## 13. Table Merge And Split

Table merge may be required when:

- Two parties sit together
- Duplicate table sessions were created
- Staff mistakenly assigned two tables to one party
- Multiple customer links belong to one party
- Preorders from party members must be grouped

Table split may be required when:

- One party separates
- Different customers require separate orders
- Separate payment handling is requested
- Service context splits across physical tables
- Dispute or recovery requires isolating an order/session

Merge and split must preserve original IDs and evidence.

Merge/split must not duplicate orders, payments, KDS tickets, or served state.

## 14. Table Service Context

A table service context may include:

- Party
- Table
- Staff owner or section
- Active orders
- Payment status
- Kitchen status
- Customer request
- Staff note
- Manager note
- Incident or dispute
- Closeout status

The service context must be visible to staff and manager roles.

Customer-facing views may show simplified status only.

## 15. Table-Linked KDS Boundary

KDS tickets linked to table service must include table context where relevant.

KDS table context may include:

- Table label
- Table session ID
- Service mode
- Order grouping
- Staff note
- Timing priority
- Remake or delay flag
- Table reassignment marker

If table assignment changes after KDS ticket creation, the system must decide whether to:

- Update the existing ticket context
- Add correction note
- Create staff/kitchen clarification
- Enter manual review
- Void and recreate only under controlled rule

KDS must not silently prepare for the wrong table.

## 16. Table-Linked Payment Boundary

Payment linked to table service may involve:

- Pay before order
- Pay after order
- Split payment
- Group payment
- Staff-assisted payment
- Kiosk payment
- POS terminal payment
- Payment uncertainty
- Refund/cancel after table service

This policy does not define full payment implementation.  
It requires table sessions to preserve payment references and uncertainty status.

A table must not be closed cleanly while payment uncertainty remains unresolved unless explicitly carried forward.

## 17. Staff Correction Boundary

Staff may correct table-related state when necessary.

Correctable table fields may include:

- Table label
- Party size
- Service mode
- Staff owner
- Table note
- Customer/table association before sensitive downstream impact
- Preorder/table association before POS or KDS impact

Manager approval may be required for:

- Reassignment after KDS ticket creation
- Reassignment after payment approval
- Table merge/split involving payment
- Table closeout with unresolved payment or kitchen state
- No-show reversal after seating conflict
- Customer dispute-linked table correction

All corrections must preserve before/after state.

## 18. Customer-Facing Table Status

Customer-facing table status must be conservative.

| Internal State | Customer-Facing Boundary |
|---|---|
| Candidate | Staff is preparing your seat |
| Held | Your seat is being prepared |
| Assigned | Staff will guide you to your seat |
| Occupied | You are seated |
| Ordering | Your order is being checked |
| Kitchen Active | Preparing your order |
| Ready Or Serving | Your order is ready or being served |
| Closing | Staff is checking your table |
| Released | Service completed, where appropriate |
| Recovery Required | Staff is checking your table/order |
| Dispute Linked | Staff is reviewing your request |

Customer-facing messages must not expose staff notes, internal table conflicts, or uncertain payment conclusions.

## 19. Incident And Dispute Linkage

Table flow must create or link incident/dispute records when:

- Wrong party seated
- Wrong table assigned
- Preorder attached to wrong table
- KDS ticket routed to wrong table
- Customer claims they were skipped or moved unfairly
- Payment/order state is attached to wrong table
- Table split/merge creates confusion
- Table was released while order/payment/kitchen state remained open
- Customer-facing status was incorrect

Table incidents must link to runtime evidence, staff correction, manager approval, and customer dispute where needed.

## 20. Daily Closeout Impact

Daily closeout must review table exceptions.

Closeout should include:

- Open table sessions
- Table sessions closed with exceptions
- Table reassignment cases
- Table merge/split cases
- Table-linked payment uncertainty
- Table-linked KDS exceptions
- Table-linked customer disputes
- Table-linked staff corrections
- Table-linked manager overrides
- Table sessions carried forward

A physical table may be available for next customer while a prior table session remains open for evidence, payment, or dispute review.

## 21. Evidence Requirements

The system must preserve evidence for:

- Table candidate selection
- Table hold
- Table assignment
- Table session creation
- Waiting-to-table transition
- Preorder-to-table linkage
- Table reassignment
- Table merge
- Table split
- Staff correction
- Manager approval
- KDS table context update
- Table-linked payment uncertainty
- Table closeout
- Table release
- Incident/dispute linkage
- Customer-facing status display
- Daily closeout table summary

Evidence must include:

- Store ID
- Business date
- Physical table ID
- Table session ID
- Waiting session ID, where applicable
- Customer or guest reference, where available
- Order ID, where applicable
- Payment reference, where applicable
- KDS ticket reference, where applicable
- Actor ID
- Timestamp
- Before state
- After state
- Reason
- Related incident/dispute/closeout reference

## 22. Acceptance Criteria

This policy is accepted when:

- Table identity is separated from customer, waiting, order, payment, and KDS identity
- Table session lifecycle is documented
- Table matching rules are explicit
- Waiting-to-table transition preserves session continuity
- Preorder-to-table linkage is controlled
- Table reassignment is auditable
- Table merge and split preserve original references
- Table-linked KDS and payment boundaries are documented
- Staff correction and manager approval rules are defined
- Customer-facing table status is conservative
- Daily closeout reviews table exceptions
- Evidence requirements are traceable

## 23. Out of Scope

This policy does not include:

- Full floor-plan optimization
- Full reservation engine
- Physical furniture planning
- QR/NFC hardware procurement
- Final table-order UI
- Full split-payment implementation
- Full staff section assignment algorithm
- Full customer compensation policy

Those must be handled in layout, reservation, hardware, payment, staff operation, support, or UI lanes.

## 24. Related Documents

Related document families include:

- Entrance waiting assist and customer link policy
- Waiting queue, call, arrival, no-show, seating policy
- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- KDS kitchen execution WorkPackage
- Staff Tablet and Manager Console WorkPackage
- Customer dispute and support handoff WorkPackage
- Daily closeout WorkPackage
- Runtime evidence policy
- Table assignment SOP
- Manual fallback SOP

## 25. Final Rule

A table is not just a number on the floor.

It is a live service context that must preserve who is seated, what they ordered, what was paid, what the kitchen received, what staff changed, and what evidence remains after service.

This policy defines table matching and table session control before detailed table-order, split-payment, and service handoff policies expand the flow.