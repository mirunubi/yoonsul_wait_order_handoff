# 06470_WorkPackage_Store_Runtime_Inventory_Soldout_Menu_Availability_Kitchen_Production_Signal_And_Exception_Control

## 1. Purpose

This WorkPackage defines the Store Runtime inventory, sold-out, menu availability, and kitchen production signal boundary.

The purpose is to ensure that menu availability is not treated as a static menu display problem.

In live store operation, menu availability is affected by ingredient stock, preparation capacity, kitchen station status, order volume, time window, sold-out decisions, staff override, KDS delay, and customer-facing communication.

This WorkPackage defines how Store Runtime must control menu availability signals before they reach customer web app, kiosk, mini kiosk, staff tablet, POS Gateway, KDS, and daily closeout.

## 2. Scope

This WorkPackage covers:

- Menu availability runtime boundary
- Sold-out state control
- Ingredient and prep stock signal boundary
- Kitchen capacity signal boundary
- Customer-facing availability display
- Staff and manager sold-out authority
- Kiosk and customer app availability control
- POS Gateway order eligibility impact
- KDS and kitchen production signal impact
- Availability exception evidence
- Daily closeout handoff for sold-out and production exceptions

This WorkPackage does not define full inventory accounting, recipe costing, supplier ordering, warehouse management, or full ingredient procurement policy.

## 3. Baseline Dependency

This WorkPackage depends on:

`14161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`06410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

`14162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control.md`

`14163_WorkPackage_Store_Runtime_Staff_Tablet_Manager_Console_Override_Manual_Control_And_Evidence_Boundary.md`

`06440_WorkPackage_Store_Runtime_KDS_Kitchen_Ticket_Preparation_Remake_Ready_Served_And_Manual_Kitchen_Continuity.md`

`14164_WorkPackage_Store_Runtime_Daily_Closeout_End_Of_Day_Evidence_Exception_Carry_Forward_And_Manager_Approval.md`

`14165_WorkPackage_Store_Runtime_Finance_Reconciliation_Accounting_Settlement_Handoff_And_Exception_Control.md`

06460 defines finance and settlement handoff.  
This document defines the store runtime availability and production signal layer that affects order eligibility before financial handoff occurs.

## 4. Core Principle

Menu availability must be controlled by Store Runtime, not by disconnected screens.

A menu item may appear available, unavailable, limited, delayed, hidden, or manager-only depending on live store conditions.

The system must distinguish:

1. Menu item exists in master menu
2. Menu item is enabled for the store
3. Menu item is available today
4. Menu item is available now
5. Menu item is available for this service mode
6. Menu item is available in this language/customer channel
7. Menu item is available with current ingredient/prep stock
8. Menu item is available with current kitchen capacity
9. Menu item may be sold only with staff or manager confirmation
10. Menu item must be blocked from customer order submission

A menu item visible to the customer must not automatically mean it is orderable.

## 5. Availability State Families

Menu availability must be grouped into state families.

| State Family | Meaning |
|---|---|
| Master Menu State | Whether item exists as a defined menu entity |
| Store Enablement State | Whether item is enabled for this store |
| Business Date State | Whether item is available for today’s operation |
| Time Window State | Whether item is available during the current time range |
| Ingredient State | Whether required ingredients or prep stock are available |
| Kitchen Capacity State | Whether kitchen can prepare the item safely now |
| Channel State | Whether item is available for app, kiosk, mini kiosk, staff, or POS path |
| Service Mode State | Whether item is available for dine-in, pickup, preorder, or waiting flow |
| Override State | Whether staff/manager changed availability |
| Exception State | Whether availability requires review or evidence |

No single sold-out flag is sufficient for store runtime control.

## 6. Availability Runtime States

A menu item may have the following runtime states:

| State | Meaning |
|---|---|
| Available | Item may be shown and ordered normally |
| Limited | Item may be ordered but quantity or timing is constrained |
| Delayed | Item may be ordered but preparation will take longer |
| Staff Confirm Required | Staff must confirm before order acceptance |
| Manager Confirm Required | Manager must approve sale or exception |
| Hidden | Item should not be shown to customer channel |
| Sold Out | Item cannot be ordered for current scope |
| Temporarily Paused | Item is paused due to operational condition |
| Prep Pending | Item is not yet ready for sale but may become available |
| Channel Blocked | Item is unavailable only in specific channel |
| Service Mode Blocked | Item is unavailable only for dine-in, pickup, preorder, or other service mode |
| Manual Review Required | Availability state is ambiguous or conflicting |

Availability state must be scope-aware.

## 7. Sold-Out Boundary

Sold-out is a runtime decision that must define scope.

Sold-out scope may be:

- Store-level
- Business-date-level
- Time-window-level
- Channel-level
- Service-mode-level
- Item-level
- Option-level
- Ingredient-level
- Prep-batch-level
- Kitchen-station-level

Examples:

- A menu item may be sold out for kiosk but still staff-confirmable.
- A topping may be sold out while the base item remains available.
- A prep batch may be sold out until the next batch is ready.
- A hot kitchen item may be paused during equipment issue.
- A pickup item may be unavailable while dine-in remains possible.

Sold-out must not be treated as a permanent menu deletion.

## 8. Ingredient And Prep Stock Signal

Store Runtime may consume ingredient and prep stock signals.

Signals may include:

- Ingredient stock available
- Ingredient stock low
- Ingredient stock exhausted
- Prep batch available
- Prep batch low
- Prep batch exhausted
- Prep batch pending
- Prep batch expired
- Prep batch quality hold
- Substitute ingredient allowed
- Substitute ingredient blocked

This WorkPackage does not require full inventory accounting.  
It requires operational availability signals sufficient to prevent unsafe or misleading order acceptance.

## 9. Kitchen Production Signal

Kitchen production signal may include:

- Station available
- Station overloaded
- Station paused
- Equipment degraded
- Prep worker unavailable
- Production delay expected
- Remake load high
- Large order load active
- Ingredient prep pending
- Manual kitchen continuity active

Kitchen production signal may affect whether an item is:

- Available normally
- Delayed
- Staff-confirm required
- Temporarily paused
- Sold out
- Hidden from customer channel

Kitchen production signal must be visible to staff where it affects customer promise.

## 10. Customer-Facing Availability Boundary

Customer-facing availability must be safe and understandable.

| Runtime State | Customer-Facing Boundary |
|---|---|
| Available | Show normally |
| Limited | Show limited quantity or caution where appropriate |
| Delayed | Show longer preparation notice |
| Staff Confirm Required | Show staff assistance required or hide from self-order channel |
| Manager Confirm Required | Hide or route to staff |
| Hidden | Do not show |
| Sold Out | Show sold out or remove depending on channel policy |
| Temporarily Paused | Show temporarily unavailable or hide |
| Prep Pending | Show available later only if reliable |
| Manual Review Required | Do not allow self-order |

Customer-facing text must not promise availability when Store Runtime requires staff review.

## 11. Channel Availability Rules

Availability may differ by channel.

| Channel | Availability Control Requirement |
|---|---|
| Customer Web App | Must not allow unavailable preorder/order submission |
| Main Kiosk | Must block unavailable self-order items |
| Mini Kiosk | May show assist-only items if staff review is required |
| Staff Tablet | May show hidden/paused items with authority marker |
| Manager Console | May approve or override restricted availability |
| POS Gateway | Must receive only eligible order lines unless fallback is approved |
| KDS | Must receive clear item availability and exception context |

Channel differences must be intentional, not accidental.

## 12. Service Mode Availability Rules

Availability may differ by service mode.

Service modes include:

- Dine-in
- Pickup
- Waiting preorder
- Table order
- Kiosk order
- Staff-assisted order
- Batch/prep reservation
- Event or group order, if later supported

Example rules:

- Some items may be dine-in only.
- Some items may be pickup-safe but not dine-in priority.
- Some items may require staff confirmation for preorder.
- Some items may be blocked during peak kitchen overload.
- Some items may be available only after prep batch completion.

Service mode availability must be evaluated before POS Gateway handoff.

## 13. Staff Availability Control

Staff may control availability within assigned authority.

Staff actions may include:

- Mark item low
- Mark item sold out
- Mark option sold out
- Mark prep batch pending
- Mark item delayed
- Request manager pause
- Restore item after confirmation
- Add kitchen note
- Escalate ambiguous availability

Staff availability changes must record:

- Actor
- Timestamp
- Item or option
- Scope
- Before state
- After state
- Reason
- Expected restore condition, if any

## 14. Manager Availability Override

Manager override may be required when:

- Restoring sold-out item
- Selling restricted item
- Continuing sale despite low stock
- Pausing high-impact menu item
- Changing channel-level visibility
- Overriding kitchen capacity warning
- Approving substitution
- Approving customer exception
- Closing day with unresolved availability discrepancy

Manager override must create audit evidence.

## 15. POS Gateway Impact

POS Gateway handoff must respect availability state.

The Store Runtime must prevent POS Gateway submission when:

- Item is sold out
- Required option is sold out
- Item requires staff confirmation and confirmation is missing
- Item requires manager approval and approval is missing
- Service mode is blocked
- Channel is blocked
- Prep state is invalid
- Availability state is ambiguous
- Item was changed after customer confirmation without review

If an unavailable item reaches POS Gateway, an incident or exception record must be created.

## 16. KDS Impact

KDS must receive availability and exception context when relevant.

Examples:

- Item was staff-confirmed despite low stock
- Item requires substitution
- Item is delayed
- Item was restored after prep batch completion
- Item is part of remake
- Item is manual kitchen note fallback
- Item availability was overridden by manager

Kitchen must not discover critical availability exceptions only after the ticket appears.

## 17. Availability Conflict Handling

Availability conflict occurs when different systems disagree.

Examples:

- Kiosk shows item available but staff tablet shows sold out
- Customer submitted preorder before item was paused
- POS accepted item that kitchen cannot prepare
- KDS reports unavailable after payment approval
- Manager restored item while ingredient stock remains exhausted
- Option is sold out but parent item remains visible
- Translation/menu display hides required option constraint

Conflicts must enter manual review or incident mode depending on severity.

## 18. Recovery Rules

Availability recovery may occur when:

- New prep batch is completed
- Ingredient stock is replenished
- Kitchen station recovers
- Manager restores item
- Erroneous sold-out mark is corrected
- Channel configuration is repaired
- Service mode window changes
- KDS/manual kitchen status is reconciled

Recovery must record before/after state and reason.

Restoring availability after customer-facing sold-out must be controlled to avoid inconsistent customer experience.

## 19. Daily Closeout Handoff

Daily closeout must include availability and sold-out evidence when relevant.

Closeout review should include:

- Items marked sold out
- Items restored
- Items delayed
- Items staff-confirm required
- Items manager-overridden
- Prep batch shortage
- Kitchen capacity pause
- Customer order blocked due to availability
- Orders accepted despite availability warning
- Item unavailable after payment/order acceptance
- Availability-related incidents

These records support inventory planning, menu improvement, staff training, and customer dispute review.

## 20. Evidence Requirements

The system must preserve evidence for:

- Availability state creation
- Sold-out mark
- Sold-out restoration
- Option-level sold-out
- Ingredient/prep stock signal
- Kitchen capacity signal
- Staff availability action
- Manager override
- Customer-facing availability display
- Blocked order attempt
- Availability conflict
- Availability recovery
- POS Gateway block due to availability
- KDS exception due to availability
- Closeout availability summary

Evidence must include:

- Store ID
- Business date
- Menu item ID
- Option ID, where applicable
- Channel
- Service mode
- Actor ID, where applicable
- Timestamp
- Before state
- After state
- Reason
- Related order/session/payment/ticket/incident where applicable

## 21. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- Availability state families are defined
- Runtime availability states are documented
- Sold-out scope rules are defined
- Ingredient/prep signal boundary is defined
- Kitchen production signal boundary is defined
- Customer-facing availability rules are conservative
- Channel and service mode rules are defined
- Staff and manager control authority is defined
- POS Gateway block rules are defined
- KDS exception context is defined
- Daily closeout availability handoff is defined
- Evidence fields are defined

## 22. Acceptance Criteria

This WorkPackage is accepted when:

- Menu availability is not treated as a static display flag
- Sold-out state is scope-aware
- Customer-facing channels cannot submit clearly unavailable items
- Staff availability changes are auditable
- Manager override is required for high-risk availability changes
- POS Gateway handoff respects availability eligibility
- KDS receives relevant availability exception context
- Availability conflict enters review or incident mode
- Closeout includes availability exceptions
- Open risks are routed to backlog, waiver, or blocker register

## 23. Out of Scope

This WorkPackage does not include:

- Full inventory accounting
- Recipe costing
- Supplier ordering
- Warehouse management
- Procurement approval workflow
- Food safety HACCP implementation
- Full menu engineering analytics
- Final customer menu UI design
- Final product image management

Those must be handled in inventory, procurement, food safety, menu, or UI lanes.

## 24. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- Staff Tablet and Manager Console WorkPackage
- KDS kitchen execution WorkPackage
- Daily closeout WorkPackage
- Finance reconciliation handoff WorkPackage
- Menu availability policy
- Sold-out operation SOP
- Manual fallback SOP
- Runtime evidence policy
- Incident register template

## 25. Final Rule

Menu availability is a live operational promise.

If the store shows an item as orderable, the system must be able to explain why it was orderable, who changed it, whether the kitchen could prepare it, whether POS accepted it, and what happened if that promise failed.

This WorkPackage defines the Store Runtime availability control boundary before inventory, procurement, menu engineering, and rollout expansion consume availability data.