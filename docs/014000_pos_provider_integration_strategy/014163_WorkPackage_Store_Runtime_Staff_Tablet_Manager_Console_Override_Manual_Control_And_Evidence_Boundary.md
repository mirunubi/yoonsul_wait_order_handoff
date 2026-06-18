# 014163_WorkPackage_Store_Runtime_Staff_Tablet_Manager_Console_Override_Manual_Control_And_Evidence_Boundary

## 1. Purpose

This WorkPackage defines the Staff Tablet and Store Manager Console runtime boundary inside the Store Runtime lane.

The purpose is to ensure that staff and manager actions do not become informal, invisible, or disconnected from customer session, order state, payment state, POS Gateway state, KDS state, and store closeout evidence.

The Staff Tablet is the primary store operation control device.  
The Manager Console is the controlled authority surface for sensitive override, incident resolution, refund/cancel exception, payment uncertainty, degraded operation approval, and daily closeout.

This WorkPackage defines how staff and manager control actions must be structured, authorized, recorded, and reconciled.

## 2. Scope

This WorkPackage covers:

- Staff Tablet runtime role
- Store Manager Console runtime role
- Staff action authority
- Manager override authority
- Manual correction and fallback control
- Payment uncertainty handling
- Order/session/table correction
- KDS and kitchen exception control
- Incident escalation and closure
- Daily closeout control
- Audit and evidence requirements

This WorkPackage does not define full UI design, HR permission schema implementation, POS provider adapter implementation, or complete accounting settlement logic.

## 3. Baseline Dependency

This WorkPackage depends on:

`014161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`006410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

`014162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control.md`

06400 defines the store runtime command layer.  
06410 defines customer session and order-state control.  
06420 defines kiosk and mini kiosk runtime participation.  
This document defines the staff and manager authority surface over those flows.

## 4. Core Principle

Staff and manager actions must be treated as first-class runtime commands.

A store cannot safely operate if manual correction, override, fallback, refund, cancel, payment confirmation, or kitchen exception handling happens outside the system.

The Store Runtime must record:

1. Who acted
2. What they changed
3. Why they acted
4. Which customer, session, order, payment, table, device, or kitchen ticket was affected
5. Whether approval was required
6. Whether reconciliation is pending
7. Whether the action created customer, financial, operational, or compliance risk

No staff or manager action may silently rewrite operational truth.

## 5. Staff Tablet Runtime Role

The Staff Tablet is the main operational control device for store staff.

The Staff Tablet may support:

- Waiting queue review
- Customer arrival confirmation
- Table assignment
- Order review
- Kiosk assist
- Manual order correction
- POS handoff status review
- KDS ticket status review
- Kitchen delay/remake note
- Staff fallback activation
- Customer dispute intake
- Incident escalation
- Manager approval request
- Daily operational checklist support

The Staff Tablet must be treated as a high-authority device because it can affect live store operation.

## 6. Manager Console Runtime Role

The Manager Console is the authority surface for sensitive control.

The Manager Console may support:

- Payment uncertainty review
- Refund/cancel exception approval
- Manual POS entry approval
- No-show reversal approval
- Table reassignment approval
- Duplicate order/payment review
- Incident severity confirmation
- Degraded operation continuation approval
- Rollback or pause decision
- Daily closeout approval
- Evidence packet review
- Waiver or carry-forward approval

Manager actions must create audit events and must not be hidden inside normal staff action logs.

## 7. Role And Authority Classes

Staff and manager runtime authority must be separated by action class.

| Authority Class | Meaning | Example |
|---|---|---|
| View | Can inspect runtime state | Staff views waiting queue |
| Assist | Can help customer complete flow | Staff helps kiosk order |
| Correct | Can modify low-risk operational data | Staff corrects party size |
| Execute | Can perform normal store action | Staff marks order served |
| Fallback | Can perform degraded/manual operation | Staff manually enters POS order |
| Approve | Can authorize sensitive action | Manager approves refund |
| Resolve | Can close incident or uncertainty | Manager resolves payment uncertainty |
| Closeout | Can approve end-of-day state | Manager approves daily runtime closeout |

Authority must be explicit and scoped.

## 8. Staff Action Categories

Staff actions must be classified into categories.

### 8.1 Normal Staff Actions

Normal staff actions include:

- Confirm customer arrival
- Assign table
- Mark customer as seated
- Help customer continue kiosk session
- Confirm pickup
- Mark served
- Add staff note
- Notify kitchen delay to customer
- Escalate issue to manager

These actions require actor logging but may not require manager approval.

### 8.2 Corrective Staff Actions

Corrective staff actions include:

- Correct party size
- Correct customer label
- Correct pickup/dine-in mode
- Correct table assignment before service conflict
- Correct order memo before POS acceptance
- Attach guest session to known customer
- Recover abandoned session
- Request order review

These actions must preserve before/after state.

### 8.3 Fallback Staff Actions

Fallback staff actions include:

- Manual POS entry
- Manual kitchen note
- Manual receipt confirmation
- Manual customer call
- Manual table assignment during device failure
- Manual order status update during outage
- Manual customer explanation record

Fallback actions must identify the degraded system or reason.

### 8.4 Restricted Staff Actions

Restricted staff actions require manager approval or escalation.

Examples include:

- Payment uncertainty resolution
- Refund confirmation
- Cancel after payment approval
- Duplicate payment handling
- No-show reversal after expiration
- Forced order state change after POS acceptance
- Forced KDS ticket void
- Daily closeout exception

Restricted actions must not be available as ordinary staff shortcuts.

## 9. Manager Override Categories

Manager override must be divided by risk.

| Override Type | Risk | Required Evidence |
|---|---|---|
| Operational Override | Store flow correction | Before/after state, reason |
| Customer-Service Override | Customer-facing exception | Customer/session/order reference |
| Payment Override | Financial correctness risk | Payment reference and reconciliation status |
| Kitchen Override | Cooking or fulfillment risk | KDS ticket and order reference |
| Incident Override | Risk classification change | Incident record and owner |
| Closeout Override | End-of-day correctness risk | Closeout checklist and approval |

Manager override must be rare, traceable, and reviewable.

## 10. Manual Control Boundary

Manual control must not mean uncontrolled operation.

Manual control may be allowed when:

- POS Gateway is degraded
- Kiosk is unavailable
- KDS is unavailable
- Network is unstable
- Customer/order/payment state is ambiguous
- Staff must prevent customer flow blockage
- Manager approves degraded operation
- Store must continue safely during incident

Manual control must always record:

- Trigger condition
- Actor
- Manager approval, if required
- Affected customer/session/order/payment/table
- Manual action performed
- Whether later reconciliation is required
- Whether customer was informed
- Whether incident record was created

## 11. Payment Uncertainty Handling

Payment uncertainty is a restricted state.

Payment uncertainty may occur when:

- Customer was charged but order confirmation failed
- POS approved payment but kiosk/session failed
- Payment terminal result is delayed
- Provider timeout occurred after payment attempt
- Staff cannot determine whether payment succeeded
- Refund/cancel result is unclear
- Settlement evidence does not match runtime state

Staff may intake and escalate payment uncertainty.  
Manager or payment/reconciliation owner must resolve it.

The system must not allow ordinary staff to silently mark payment uncertain cases as paid, failed, cancelled, or refunded without evidence.

## 12. Order And Session Correction

Staff and manager correction must preserve state history.

Correctable fields may include:

- Customer label
- Guest/customer attachment
- Party size
- Waiting status
- Table assignment
- Service mode
- Order memo
- Item availability note
- Customer contact reference
- Staff assistance note

High-risk corrections include:

- Accepted order item change
- Payment-linked order change
- Refund/cancel status change
- POS accepted state change
- Kitchen ticket void
- Served state reversal
- No-show reversal after expiration

High-risk corrections require manager approval or controlled incident workflow.

## 13. KDS And Kitchen Exception Control

Staff Tablet and Manager Console must support kitchen exception visibility.

Kitchen exceptions include:

- Ticket not created
- Duplicate ticket
- Ticket delayed
- Item unavailable after order acceptance
- Remake required
- Wrong table or customer context
- Kitchen marks ready but staff cannot serve
- Staff marks served but kitchen state disagrees
- Manual kitchen note required

Kitchen exceptions must be linked to order, table, staff actor, and KDS ticket where available.

## 14. Incident Escalation Boundary

Staff may escalate an incident when:

- Customer dispute occurs
- Payment status is unclear
- Order and POS state diverge
- Kiosk state and runtime state diverge
- KDS state is missing or duplicated
- Manual fallback is activated
- Store device is unavailable
- Customer cannot be safely told the result
- Closeout cannot be completed

Manager may confirm severity, assign owner, approve continuation, or pause affected flow.

Incident closure must require evidence or explicit carry-forward.

## 15. Daily Closeout Control

Staff Tablet and Manager Console must support daily closeout.

Daily closeout must review:

- Open orders
- Unserved orders
- Unresolved payment uncertainty
- Refund/cancel pending cases
- Manual POS entries
- Manual kitchen notes
- KDS exceptions
- Staff corrections
- Manager overrides
- Open incidents
- Evidence packet completeness
- Reconciliation handoff status

Manager approval is required for final daily closeout when exceptions exist.

## 16. Authentication And Reauthentication

Staff and manager authority must be protected.

The system must support:

- Staff identity confirmation
- Role-based access
- Device-bound session control
- Short timeout for sensitive actions
- Reauthentication for manager override
- Separate approval event for sensitive changes
- Audit trace of actor and device
- Prevention of customer-mode access to staff authority

Shared store devices must not erase individual actor accountability.

## 17. Customer Communication Boundary

Staff may communicate status to customers, but communication must align with runtime truth.

Staff-facing wording should distinguish:

- Confirmed order
- Order being checked
- Payment being checked
- Kitchen delay
- Staff correction required
- Manager review required
- Refund/cancel pending
- Manual confirmation required

Staff must not be encouraged to promise confirmation when the system state is uncertain.

## 18. Evidence Requirements

The system must preserve evidence for:

- Staff login/session
- Staff action
- Staff correction
- Staff assist
- Fallback activation
- Manual POS entry
- Manual kitchen note
- Manager approval
- Manager override
- Payment uncertainty escalation
- Incident creation
- Incident severity change
- Incident resolution
- Daily closeout approval
- Customer communication note where applicable

Evidence must include:

- Actor ID
- Role
- Device ID
- Store ID
- Business date
- Timestamp
- Affected entity references
- Before state
- After state
- Reason
- Approval reference, if applicable

## 19. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- Staff Tablet role is defined
- Manager Console role is defined
- Role authority classes are documented
- Staff action categories are documented
- Manager override categories are documented
- Manual control boundary is documented
- Payment uncertainty handling is restricted
- KDS exception visibility is defined
- Incident escalation path is defined
- Daily closeout control is defined
- Evidence requirements are defined

## 20. Acceptance Criteria

This WorkPackage is accepted when:

- Staff and manager authority boundaries are clear
- Staff Tablet is treated as a high-authority operational device
- Manager override requires evidence
- Manual fallback does not bypass audit
- Payment uncertainty cannot be resolved casually
- Staff correction preserves before/after state
- Incident escalation and closure are traceable
- Daily closeout requires manager approval when exceptions exist
- Authentication and reauthentication requirements are documented
- Open risks are routed to backlog, waiver, or blocker register

## 21. Out of Scope

This WorkPackage does not include:

- Final Staff Tablet UI design
- Final Manager Console UI design
- Full HR permission implementation
- Payroll or attendance authority
- Full accounting reconciliation implementation
- Full customer support compensation policy
- Full enterprise incident management platform
- Final POS provider adapter implementation

Those must be handled in their own lanes.

## 22. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- POS Gateway readiness lane
- KDS kitchen continuity policy
- Manual fallback SOP
- Payment uncertainty policy
- Manager override governance
- Incident register template
- Daily closeout checklist
- Runtime evidence policy
- Audit and compliance governance

## 23. Final Rule

Staff and manager actions are not side notes to automation.

They are operational commands that can change customer experience, financial correctness, kitchen execution, and legal evidence.

This WorkPackage defines the Staff Tablet and Manager Console control boundary so that manual operation remains safe, visible, accountable, and recoverable.