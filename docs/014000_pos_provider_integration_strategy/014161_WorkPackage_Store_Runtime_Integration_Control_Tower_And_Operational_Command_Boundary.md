# 014161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary

## 1. Purpose

This WorkPackage defines the Store Runtime Integration Control Tower boundary for 윤슬 Wait-Order Handoff and Store Operation lanes.

The purpose of this document is to ensure that POS Gateway, Kiosk, Mini Kiosk, KDS, Staff Tablet, Store Manager flow, and customer-facing order state are not developed as isolated modules.

A store does not operate by API success alone. It operates through a synchronized runtime command structure where each device, staff role, order state, payment state, fallback action, and incident decision has a clear owner and boundary.

This WorkPackage establishes the first store-level runtime control layer after POS Gateway pilot readiness.

## 2. Scope

This WorkPackage covers:

- Store runtime command boundary
- Device-role coordination
- POS Gateway to store operation integration
- Kiosk and Mini Kiosk runtime relationship
- Staff tablet and manager control path
- KDS and kitchen execution handoff
- Customer order state visibility
- Manual fallback command route
- Incident command escalation
- Store-level runtime evidence
- Operational readiness for integrated pilot

This document does not implement each device UI or provider adapter. It defines the control tower boundary that governs how those components operate together.

## 3. Baseline Dependency

This WorkPackage assumes the previous POS Gateway readiness lane has reached closeout baseline.

The immediate prior completed document is:

`014160_WorkPackage_POS_Gateway_Monitoring_Incident_Disaster_Recovery_Pilot_Readiness_And_Closeout.md`

The Store Runtime lane must not proceed as if POS Gateway is a completed black box. It must consume POS Gateway status, incidents, fallback states, and reconciliation boundaries as live operational inputs.

## 4. Core Principle

The store runtime must have one operational truth layer.

The following systems may each hold partial state:

- Customer web app
- Entrance waiting flow
- Mini Kiosk
- Main Kiosk
- Staff tablet
- POS
- POS Gateway
- KDS
- Kitchen board
- Manager dashboard
- Audit log
- Reconciliation ledger

However, store operation cannot allow each device to independently decide what is true.

The Store Runtime Control Tower must define:

1. Which state is authoritative
2. Which state is display-only
3. Which state may be manually overridden
4. Which state requires manager approval
5. Which state requires reconciliation before final confirmation
6. Which state must be preserved as evidence

## 5. Runtime Components

The Store Runtime Control Tower coordinates the following components.

| Component | Runtime Role |
|---|---|
| Customer Web App | Customer-facing waiting, cart, preorder, table/order state display |
| Entrance Waiting Flow | Queue, party identity, pre-entry state |
| Mini Kiosk | Lightweight customer order/payment assist path |
| Main Kiosk | In-store customer ordering/payment device |
| Staff Tablet | Primary store operation control device |
| Manager Console | Approval, override, incident, fallback, closeout authority |
| POS Gateway | Provider-facing order/payment/cancel/refund integration boundary |
| POS Terminal | Legal/financial transaction endpoint where required |
| KDS | Kitchen execution and ticket state surface |
| Kitchen Staff View | Actual preparation and fulfillment state |
| Audit/Event Ledger | Evidence and traceability layer |
| Reconciliation Layer | Financial correctness verification layer |

No component may be treated as operationally complete until its relationship to the control tower is defined.

## 6. Store Runtime State Families

Store runtime state must be grouped into clear families.

### 6.1 Customer State

Customer state includes:

- Waiting session
- Party information
- Cart state
- Preorder state
- Order confirmation state
- Payment attempt state
- Table matching state
- Pickup or dine-in state
- Customer notification state

Customer state must be customer-readable only when it is safe, understandable, and not misleading.

### 6.2 Order State

Order state includes:

- Draft order
- Submitted order
- POS handoff pending
- POS accepted
- Kitchen ticket created
- Kitchen preparing
- Ready
- Served
- Cancel requested
- Cancel confirmed
- Failed
- Manual review required

Order state must not be advanced merely because a UI action succeeded.

### 6.3 Payment State

Payment state includes:

- Not required
- Payment pending
- Payment approved
- Payment failed
- Payment uncertain
- Cancel pending
- Cancel approved
- Refund pending
- Refund approved
- Settlement review required

Payment state must follow POS Gateway and reconciliation guard rules.

### 6.4 Kitchen State

Kitchen state includes:

- Ticket pending
- Ticket accepted
- Preparation started
- Delayed
- Remake required
- Ready
- Served
- Voided
- Manual kitchen note required

Kitchen state must remain usable even when POS/KDS automation is degraded.

### 6.5 Staff Operation State

Staff operation state includes:

- Normal operation
- Assisted order
- Staff correction
- Manager approval required
- Manual POS entry
- Manual kitchen handoff
- Customer dispute handling
- Incident mode
- Store closeout mode

Staff operation state must be visible to the role responsible for action.

## 7. Authority Boundary

The Store Runtime Control Tower must define authority by action.

| Action | Default Authority |
|---|---|
| View customer waiting state | Store staff |
| Modify waiting party | Staff or manager depending on impact |
| Confirm table matching | Staff |
| Submit order to POS Gateway | Runtime system |
| Retry POS handoff | Runtime owner or controlled automation |
| Manually enter POS order | Staff under fallback SOP |
| Override payment uncertainty | Manager only, with evidence |
| Cancel order before payment | Staff or manager by policy |
| Cancel after payment approval | Manager or payment owner |
| Trigger refund | Manager/payment owner |
| Mark kitchen ready | Kitchen or staff role |
| Close incident | Assigned incident owner |
| Close pilot/store runtime day | Manager with evidence |

No sensitive state transition may depend only on convenience.

## 8. Device Role Boundary

Each device must have a defined role.

### 8.1 Customer Web App

The Customer Web App may:

- Start or continue waiting session
- Hold cart/preorder state
- Show customer-facing status
- Receive notification
- Support handoff into store order flow

It must not independently finalize POS/payment truth.

### 8.2 Mini Kiosk

The Mini Kiosk may:

- Assist foreign or non-app customers
- Support lightweight order entry
- Bridge waiting and order state
- Show guided order flow

It must not bypass Store Runtime authority.

### 8.3 Main Kiosk

The Main Kiosk may:

- Accept in-store order
- Accept customer payment where configured
- Send order/payment request into POS Gateway
- Display confirmation after authoritative state returns

It must not mark order complete without POS/payment/kitchen state agreement.

### 8.4 Staff Tablet

The Staff Tablet is the main operational control device.

It may:

- View store-wide runtime state
- Correct order/customer/table context
- Activate fallback
- Confirm manual actions
- Record staff notes
- Escalate incidents
- Support manager handoff

The Staff Tablet must be treated as a high-authority store device.

### 8.5 Manager Console

The Manager Console may:

- Approve sensitive overrides
- Resolve payment uncertainty
- Confirm refund/cancel exception
- Close incidents
- Approve daily runtime closeout
- Authorize degraded operation continuation
- Trigger rollback or pause

Manager actions must create audit events.

### 8.6 KDS

The KDS may:

- Display kitchen ticket
- Update preparation state
- Signal delay/remake/ready
- Preserve kitchen execution evidence

The KDS must not be the sole source of financial/order truth.

## 9. Runtime Command Model

The Store Runtime Control Tower must support the following command model:

1. Customer or staff creates intent
2. Runtime validates context
3. POS Gateway receives eligible order/payment command
4. POS/POS provider returns authoritative response
5. Runtime updates order/payment state
6. KDS receives kitchen-eligible ticket
7. Staff and customer views update from runtime state
8. Exceptions route to fallback or incident mode
9. Evidence is written for sensitive transitions

Every command must be traceable through correlation ID, store context, device context, actor context, and timestamp.

## 10. Manual Fallback Integration

Manual fallback must be integrated into the runtime, not treated as an undocumented side operation.

Fallback paths include:

- Manual POS entry
- Manual kitchen note
- Manual payment verification
- Manual table matching
- Manual order correction
- Manual refund/cancel handling
- Manual customer explanation
- Manual closeout note

Each fallback action must record:

- Who performed it
- Why it was required
- Which system failed or degraded
- Which customer/order/payment it affected
- Whether manager approval was required
- Whether reconciliation is pending

## 11. Incident Mode

The Store Runtime Control Tower must enter incident mode when:

- POS Gateway reports payment uncertainty
- Kiosk cannot confirm order result
- Staff tablet and POS state diverge
- KDS ticket is missing or duplicated
- Customer was charged but order is unclear
- Order exists without kitchen execution state
- Refund or cancel is unresolved
- Manual fallback is activated repeatedly
- Device role becomes unavailable
- Store cannot complete daily closeout

Incident mode must make ambiguity visible. It must not hide uncertainty behind a normal-looking UI.

## 12. Store Runtime Evidence

The control tower must preserve evidence for:

- Customer session creation
- Cart to order transition
- Order submission
- POS Gateway handoff
- Payment approval/failure/uncertainty
- KDS ticket creation
- Kitchen state transition
- Staff correction
- Manager approval
- Manual fallback
- Incident escalation
- Refund/cancel
- Daily closeout

Evidence must be queryable by store, business date, order ID, payment reference, device ID, actor ID, and incident ID where applicable.

## 13. Daily Closeout Boundary

Store Runtime must support daily closeout.

Daily closeout must verify:

- All orders have final or accepted pending state
- All payment uncertainty cases are resolved or explicitly held
- All manual POS entries are recorded
- All KDS exceptions are reviewed
- All refund/cancel cases are matched to evidence
- All incidents are closed, waived, or carried forward
- Reconciliation handoff is ready
- Manager approval is recorded

Store closeout must not depend only on POS sales totals.

## 14. Integration Readiness Checklist

The Store Runtime Control Tower may enter integrated pilot only when:

- Device-role map is complete
- Runtime state families are defined
- POS Gateway status is consumable
- KDS handoff path is defined
- Staff tablet control actions are defined
- Manager approval actions are defined
- Manual fallback actions are auditable
- Incident mode is visible
- Daily closeout path is defined
- Evidence packet fields are defined
- Rollback and pause authority is assigned

## 15. Acceptance Criteria

This WorkPackage is accepted when:

- Store runtime state families are documented
- Device authority boundaries are documented
- Runtime command model is approved
- Manual fallback is integrated into runtime evidence
- Incident mode entry conditions are defined
- Daily closeout boundary is defined
- Store-level evidence requirements are defined
- Integrated pilot readiness checklist is approved
- Open risks are routed to backlog, waiver, or blocker register

## 16. Out of Scope

This WorkPackage does not include:

- Full UI design for each device
- Full KDS implementation
- Full kiosk payment implementation
- POS provider-specific adapter implementation
- Franchise HQ analytics dashboard
- Customer loyalty/membership benefit policy
- Full accounting settlement implementation
- Enterprise-wide DR beyond store runtime scope

Those must be handled in their own WorkPackages or policy lanes.

## 17. Related Documents

Related document families include:

- POS Gateway WorkPackage lane
- Kiosk runtime policy
- Mini Kiosk customer assist policy
- KDS kitchen continuity policy
- Store staff tablet operation policy
- Manager override governance
- Manual fallback SOP
- Payment uncertainty policy
- Reconciliation audit evidence policy
- Incident register template
- Daily closeout checklist

## 18. Final Rule

The store runtime is not a collection of devices.

It is the controlled operating layer that decides what the store believes, what staff should do next, what customers may safely see, and what evidence must survive after the day ends.

This WorkPackage opens the Store Runtime Control Tower lane after POS Gateway readiness.