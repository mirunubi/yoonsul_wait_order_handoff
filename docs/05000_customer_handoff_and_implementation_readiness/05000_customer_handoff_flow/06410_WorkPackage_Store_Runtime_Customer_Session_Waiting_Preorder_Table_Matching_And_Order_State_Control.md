# 06410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control

## 1. Purpose

This WorkPackage defines the customer session and order-state control boundary within the Store Runtime lane.

The purpose is to prevent waiting, preorder, table matching, kiosk order, staff-assisted order, and POS-confirmed order states from becoming disconnected or contradictory.

The store must be able to track a customer from the first waiting or preorder intent through table matching, order confirmation, POS handoff, kitchen execution, and final service state.

This WorkPackage establishes the state-control layer that connects customer-facing flows to store-facing operational truth.

## 2. Scope

This WorkPackage covers:

- Customer session lifecycle
- Waiting session state
- Preorder and cart state
- Table matching state
- Entry and seating transition
- Order submission eligibility
- Order state authority
- Staff correction boundary
- Customer-visible status boundary
- Session expiration, abandonment, and recovery
- Evidence requirements for customer/order state transition

This WorkPackage does not define full POS Gateway internals, payment settlement, KDS execution, or loyalty benefit logic. Those are governed by their own WorkPackages and policy lanes.

## 3. Baseline Dependency

This WorkPackage depends on:

`14161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

The Store Runtime Control Tower defines the overall command boundary. This document defines the customer-session and order-state segment inside that boundary.

## 4. Core Principle

A customer session is not just a login, waiting ticket, or cart.

It is the operational thread that connects:

1. Who the customer or party is
2. Why they are interacting with the store
3. Whether they are waiting, ordering, seated, picking up, or leaving
4. Whether the order has been accepted by the store
5. Whether payment is required, pending, approved, failed, or uncertain
6. Whether the kitchen must act
7. Whether staff must intervene
8. Whether the customer can safely be shown a confirmed state

No customer-facing state may advance beyond the operational truth layer.

## 5. Customer Session Families

Customer sessions must be grouped into clear families.

| Session Family | Meaning |
|---|---|
| Waiting Session | Customer or party is waiting for entry, seating, or service opportunity |
| Preorder Session | Customer has created an order intent before final store acceptance |
| Table Session | Customer or party has been matched to a table or in-store service context |
| Kiosk Session | Customer is using a kiosk or mini kiosk to create or complete order intent |
| Staff-Assisted Session | Staff is helping create, correct, or complete the customer flow |
| Recovery Session | Customer/order/payment state requires review, correction, or continuation |

A single customer may move across multiple session families. The system must preserve continuity.

## 6. Session Identity Boundary

The Store Runtime must distinguish between the following identity concepts:

| Identity Type | Description |
|---|---|
| Customer Account | Known customer identity, if logged in or matched |
| Guest Session | Temporary customer identity without full account |
| Party Identity | Group-level waiting or seating identity |
| Device Session | Browser, kiosk, tablet, or app session |
| Order Identity | Specific order intent or accepted order |
| Payment Identity | Specific payment attempt or approval reference |
| Table Identity | Physical or operational table assignment |
| Staff Actor Identity | Staff member assisting or modifying state |

These identities must not be collapsed into one field.

A customer may have multiple orders.  
A party may include multiple customers.  
A device may be used by multiple parties.  
A table may have more than one order during the same business period.  
A staff actor may operate on behalf of a customer but must not become the customer.

## 7. Waiting Session Lifecycle

A waiting session may move through the following states:

| State | Meaning |
|---|---|
| Draft | Waiting intent created but not yet submitted |
| Waiting | Customer/party is actively waiting |
| Called | Store has called or notified customer/party |
| Arrival Pending | Customer/party must confirm or approach |
| Seated | Customer/party has been assigned to table or service context |
| No-Show | Customer/party failed to respond within allowed window |
| Cancelled | Waiting session was cancelled |
| Expired | Session became invalid due to timeout |
| Merged | Session was merged with another party/session |
| Manual Review | Staff must resolve ambiguous state |

Waiting state must not automatically imply order acceptance.

## 8. Preorder Session Lifecycle

A preorder session may move through the following states:

| State | Meaning |
|---|---|
| Cart Draft | Customer is building an order |
| Preorder Draft | Order intent exists but is not ready for submission |
| Preorder Submitted | Customer submitted order intent |
| Store Review Required | Store must check availability, timing, or context |
| Eligible For POS Handoff | Runtime has validated minimum conditions |
| POS Handoff Pending | Order is being sent to POS Gateway |
| POS Accepted | POS/POS Gateway accepted the order |
| POS Rejected | POS/POS Gateway rejected the order |
| Customer Action Required | Customer must revise, confirm, or pay |
| Staff Action Required | Staff must correct or assist |
| Cancelled | Preorder was cancelled before final acceptance |
| Expired | Preorder became invalid due to timeout |
| Converted To Order | Preorder became an accepted store order |

Preorder state must remain separate from final order state until Store Runtime receives authoritative acceptance.

## 9. Table Matching Lifecycle

Table matching may move through the following states:

| State | Meaning |
|---|---|
| Unassigned | No table/service context assigned |
| Candidate Table Suggested | Runtime or staff suggests table |
| Table Reserved Pending Arrival | Table is temporarily held |
| Customer Arrived | Customer/party is physically present or confirmed |
| Table Assigned | Staff or runtime assigns table |
| Table Occupied | Service has begun |
| Table Released | Service context has ended |
| Reassignment Required | Table assignment must change |
| Manual Review | Staff must resolve conflict |

Table matching must not automatically finalize payment or kitchen execution.

## 10. Order State Control

Order state must be controlled separately from waiting, preorder, and table state.

| Order State | Meaning |
|---|---|
| Draft | Order is being composed |
| Submitted | Customer or staff submitted intent |
| Validation Pending | Runtime checks eligibility |
| POS Handoff Pending | Sent or queued for POS Gateway |
| POS Accepted | Authoritative POS acceptance received |
| POS Rejected | POS or provider rejected order |
| Kitchen Pending | Waiting for KDS/kitchen ticket creation |
| Kitchen Accepted | Kitchen accepted ticket |
| Preparing | Kitchen preparation started |
| Ready | Food/order is ready |
| Served or Picked Up | Customer received order |
| Cancel Requested | Cancellation intent exists |
| Cancel Confirmed | Cancellation is completed |
| Failed | Order failed and cannot proceed automatically |
| Manual Review Required | Staff/manager must resolve |

A customer-facing “confirmed” label may only be shown after the appropriate authoritative state is reached.

## 11. State Authority Matrix

The system must define which actor or system may advance each state.

| Transition | Default Authority |
|---|---|
| Draft to Waiting | Customer or staff |
| Waiting to Called | Store runtime or staff |
| Called to Seated | Staff or manager |
| Cart Draft to Preorder Submitted | Customer or staff |
| Preorder Submitted to Eligible For POS Handoff | Store Runtime |
| Eligible For POS Handoff to POS Handoff Pending | Store Runtime |
| POS Handoff Pending to POS Accepted | POS Gateway |
| POS Accepted to Kitchen Pending | Store Runtime |
| Kitchen Pending to Kitchen Accepted | KDS or kitchen staff |
| Preparing to Ready | Kitchen staff or KDS |
| Ready to Served | Staff |
| Any sensitive exception to Manual Review | Store Runtime, staff, or manager |
| Manual Review to Resolved State | Assigned owner, often manager |

Sensitive transitions must create audit events.

## 12. Customer-Visible Status Boundary

Customer-visible status must be simpler than internal state but must not be misleading.

| Internal State | Possible Customer Message |
|---|---|
| Waiting | Waiting in queue |
| Called | Please come to the entrance |
| Arrival Pending | Staff is checking your arrival |
| Preorder Submitted | Order request received |
| Store Review Required | Store is checking your order |
| POS Handoff Pending | Order is being confirmed |
| POS Accepted | Order confirmed |
| Kitchen Preparing | Preparing your order |
| Ready | Ready for pickup or service |
| Payment Uncertain | Staff will confirm payment status |
| Manual Review Required | Staff is checking your request |

The customer must not see “confirmed” when payment or POS state is uncertain.

## 13. Staff Correction Boundary

Staff may correct customer/session/order context when necessary.

Allowed correction types include:

- Customer name or party label correction
- Party size correction
- Waiting order correction
- Table assignment correction
- Cart/order item correction before final acceptance
- Pickup/dine-in correction
- Customer contact correction
- Session merge or split
- No-show reversal with manager approval
- Manual recovery of abandoned session

Corrections must record:

- Actor
- Timestamp
- Before state
- After state
- Reason
- Customer/order/session reference
- Whether manager approval was required

## 14. Session Merge And Split Rules

Session merge and split are high-risk operations.

### 14.1 Merge

A merge may be required when:

- Duplicate waiting sessions were created
- A customer used both app and kiosk
- Staff created a manual session for an existing customer
- A party was split across devices
- A guest session is later matched to a known account

Merge must preserve original session IDs as evidence.

### 14.2 Split

A split may be required when:

- One party separates into two tables
- One cart contains orders for different service contexts
- One customer wants separate payment/order handling
- Staff must isolate a problematic order from the main party

Split must not duplicate payment or kitchen tickets.

## 15. Session Expiration And Abandonment

The system must define expiration behavior for:

- Waiting sessions
- Called but unconfirmed sessions
- Cart drafts
- Preorder drafts
- Payment attempts
- Kiosk sessions
- Table hold sessions
- Recovery sessions

Expiration must not delete evidence.

Expired sessions must retain enough information to support:

- Customer dispute review
- Staff recovery
- Payment reconciliation
- Duplicate prevention
- Audit review

## 16. Recovery Rules

A customer session must enter recovery when:

- Customer returns after no-show
- App and kiosk state conflict
- Table assignment changed after preorder
- Payment status is uncertain
- POS accepted order but customer view failed
- Customer saw failure but POS accepted the order
- KDS ticket was not created after POS acceptance
- Staff manually entered an order for the same customer/session
- Session expired while payment/order processing was incomplete

Recovery must prioritize preventing duplicate charge, duplicate cooking, and customer-facing misinformation.

## 17. Evidence Requirements

The system must preserve evidence for:

- Session creation
- Customer identity or guest identity assignment
- Waiting submission
- Call/arrival/seating transition
- Cart creation and update
- Preorder submission
- Store review
- POS handoff eligibility decision
- POS handoff result
- Table assignment
- Staff correction
- Session merge/split
- Expiration
- Recovery
- Customer notification
- Final order conversion

Evidence must be linked through correlation IDs across session, order, payment, table, staff actor, and device.

## 18. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- Waiting lifecycle is defined
- Preorder lifecycle is defined
- Table matching lifecycle is defined
- Order state lifecycle is defined
- State authority matrix is approved
- Customer-visible status rules are defined
- Staff correction rules are defined
- Merge/split rules are defined
- Expiration rules are defined
- Recovery rules are defined
- Evidence fields are defined

## 19. Acceptance Criteria

This WorkPackage is accepted when:

- Customer session families are documented
- Identity boundaries are separated
- Waiting, preorder, table, and order states are documented
- Authoritative state transitions are defined
- Customer-visible status does not overstate internal certainty
- Staff correction and manager approval rules are defined
- Recovery and expiration rules are defined
- Evidence requirements are traceable
- Open risks are routed to backlog, waiver, or blocker register

## 20. Out of Scope

This WorkPackage does not include:

- Full customer app UI
- Full kiosk UI
- Full staff tablet UI
- Full POS Gateway implementation
- Payment settlement implementation
- Loyalty/membership benefit calculation
- Marketing notification rules
- Full table turnover analytics

Those must be handled in their own lanes.

## 21. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- POS Gateway readiness lane
- Entrance waiting policy
- Preorder and cart policy
- Table matching policy
- Kiosk runtime policy
- Staff tablet operation policy
- KDS handoff policy
- Manual fallback SOP
- Payment uncertainty policy
- Runtime evidence policy

## 22. Final Rule

A customer session is the operational thread of the store.

It must survive device changes, waiting changes, table changes, staff correction, POS handoff, kitchen handoff, and payment uncertainty without losing truth.

This WorkPackage defines that thread before deeper kiosk, KDS, and staff operation flows are expanded.