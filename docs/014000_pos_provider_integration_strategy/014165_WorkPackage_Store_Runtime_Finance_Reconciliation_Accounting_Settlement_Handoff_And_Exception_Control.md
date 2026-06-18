# 014165_WorkPackage_Store_Runtime_Finance_Reconciliation_Accounting_Settlement_Handoff_And_Exception_Control

## 1. Purpose

This WorkPackage defines the Store Runtime finance, reconciliation, accounting, and settlement handoff boundary.

The purpose is to ensure that daily store operation results are not handed to finance only as POS sales totals.

Store Runtime must provide finance and reconciliation lanes with a complete, traceable, exception-aware handoff package containing order state, payment state, POS Gateway result, refund/cancel cases, manual fallback actions, manager overrides, unresolved incidents, and evidence links.

This WorkPackage connects Store Runtime daily closeout to financial correctness review.

## 2. Scope

This WorkPackage covers:

- Store Runtime to finance handoff boundary
- Order-to-payment reconciliation handoff
- POS Gateway settlement reference handoff
- Refund and cancel exception handoff
- Manual POS entry handoff
- Payment uncertainty handoff
- Daily closeout evidence package routing
- Accounting review marker
- Settlement mismatch escalation
- Finance exception owner assignment
- Store-level financial evidence preservation

This WorkPackage does not define full accounting ledger design, tax reporting, payroll, inventory costing, or final financial statement generation.

## 3. Baseline Dependency

This WorkPackage depends on:

`014161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`006410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

`014162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control.md`

`014163_WorkPackage_Store_Runtime_Staff_Tablet_Manager_Console_Override_Manual_Control_And_Evidence_Boundary.md`

`006440_WorkPackage_Store_Runtime_KDS_Kitchen_Ticket_Preparation_Remake_Ready_Served_And_Manual_Kitchen_Continuity.md`

`014164_WorkPackage_Store_Runtime_Daily_Closeout_End_Of_Day_Evidence_Exception_Carry_Forward_And_Manager_Approval.md`

06450 produces the daily closeout truth package.  
This document defines how that package is passed into finance, reconciliation, accounting, and settlement review.

## 4. Core Principle

Finance handoff must not be a raw sales export.

A store day may contain:

- Normal orders
- Cancelled orders
- Refunded orders
- Failed orders
- Duplicate attempts
- Payment uncertainty
- Manual POS entries
- Kiosk failures
- POS Gateway retries
- DLQ or replay cases
- KDS exceptions
- Manager overrides
- Customer disputes
- Settlement mismatches

Finance must receive not only totals, but also the evidence needed to explain totals.

## 5. Handoff State Families

The finance handoff must include the following state families.

| State Family | Handoff Requirement |
|---|---|
| Order State | Final, cancelled, failed, carry-forward, or exception |
| Payment State | Approved, failed, refunded, cancelled, uncertain, or held |
| POS Gateway State | Accepted, rejected, retried, DLQ, replayed, or incident-linked |
| Refund/Cancel State | Requested, approved, failed, pending, or exception |
| Manual POS Entry | Actor, reason, order reference, reconciliation status |
| Manager Override | Approval, reason, affected financial state |
| Customer Dispute | Claim, affected order/payment, owner |
| Settlement Reference | Provider reference, expected settlement, mismatch marker |
| Evidence Packet | Trace links for audit and review |

No state family may be omitted merely because the POS total appears balanced.

## 6. Handoff Inputs

The finance handoff consumes:

- Daily closeout record
- POS Gateway transaction records
- Payment approval/failure records
- Refund/cancel records
- Manual POS entry records
- Kiosk payment attempt records
- Staff correction records
- Manager override records
- Incident register entries
- Customer dispute records
- Reconciliation evidence packet
- Settlement provider references

The handoff must preserve both business date and actual timestamp.

## 7. Handoff Outputs

The finance handoff must produce or route:

- Daily financial handoff package
- Order-payment reconciliation candidate set
- Refund/cancel review list
- Payment uncertainty hold list
- Manual POS entry review list
- Settlement mismatch candidate list
- Provider exception list
- Customer dispute financial impact list
- Accounting review marker
- Finance exception backlog
- Audit evidence links

The output must be usable by finance, accounting, audit, support, and operations.

## 8. Order-To-Payment Matching

Store Runtime must provide enough information to match order and payment state.

Required matching references include:

- Store ID
- Business date
- Order ID
- Customer or guest session reference, where available
- POS Gateway reference
- POS provider transaction reference
- Payment attempt ID
- Payment approval reference
- Refund/cancel reference
- Kiosk or device session ID
- Manual POS entry reference, if applicable
- Correlation ID

Order and payment matching must not depend on customer name, table number, or staff memory.

## 9. Payment State Handoff

Payment states must be handed off with clear classification.

| Payment State | Finance Handoff Rule |
|---|---|
| Approved | Include in normal reconciliation candidate set |
| Failed | Exclude from revenue but preserve attempt evidence |
| Cancelled | Link to cancel evidence |
| Refunded | Link to refund evidence |
| Pending | Hold from final reconciliation until resolved |
| Uncertain | Escalate to payment uncertainty owner |
| Duplicate Suspected | Escalate to reconciliation review |
| Manual Verified | Require manual evidence and manager approval reference |
| Settlement Mismatch | Escalate to settlement exception review |

Payment uncertainty must never be silently converted into approved or failed status.

## 10. Refund And Cancel Handoff

Refund and cancel cases must include:

- Original order reference
- Original payment reference
- Refund/cancel request timestamp
- Refund/cancel approval timestamp
- Actor
- Manager approval reference, where required
- Provider response
- POS Gateway response
- Customer-facing status
- Settlement impact
- Evidence link

Refund and cancel must be distinguishable.

A cancelled order does not always mean refunded payment.  
A refunded payment does not always mean the order was operationally cancelled before kitchen execution.

## 11. Manual POS Entry Handoff

Manual POS entry must be separately visible.

Manual POS entry may occur when:

- POS Gateway is degraded
- Kiosk flow failed
- Staff must recover customer order
- Network outage occurred
- Payment/order state is ambiguous
- Manager approves fallback operation
- Provider integration cannot complete safely

Manual POS entry handoff must include:

- Staff actor
- Manager approval, if required
- Reason
- Affected order/session/payment
- Manual receipt or POS reference
- Whether duplicate prevention was checked
- Whether reconciliation is pending
- Evidence link

Manual POS entry must not be blended into normal automated flow without marker.

## 12. Settlement Reference Boundary

Settlement handoff must preserve provider references.

Settlement-related data may include:

- POS provider ID
- Payment provider ID
- Approval number
- Transaction ID
- Merchant ID or terminal reference, where applicable
- Settlement date
- Business date
- Gross amount
- Discount amount
- Refund amount
- Cancel amount
- Fee estimate, if available
- Expected settlement amount
- Settlement mismatch marker

The system must not assume settlement date equals store business date.

## 13. Accounting Marker Boundary

Store Runtime does not perform full accounting, but it must provide accounting markers.

Accounting markers may include:

- Sales candidate
- Refund candidate
- Cancel candidate
- Deposit/settlement candidate
- Payment uncertainty hold
- Customer dispute hold
- Manual review required
- Settlement mismatch candidate
- Non-revenue event
- Waived or compensated event
- Evidence incomplete marker

Accounting markers must be generated conservatively.

## 14. Exception Classification

Finance handoff exceptions must be classified.

| Exception Type | Meaning |
|---|---|
| Payment Uncertainty | Payment result is not safely known |
| Order-Payment Mismatch | Order state and payment state do not align |
| Refund/Cancel Mismatch | Refund/cancel state is incomplete or contradictory |
| Settlement Mismatch | Expected and provider settlement data do not match |
| Manual Entry Review | Manual POS entry needs confirmation |
| Duplicate Suspected | Duplicate order/payment/ticket possibility exists |
| Customer Dispute | Customer claim may affect financial truth |
| Evidence Missing | Required trace or approval evidence is missing |
| Provider Exception | POS/payment provider behavior requires review |
| Accounting Hold | Finance should not finalize until resolved |

Every exception must have owner, severity, and next action.

## 15. Finance Exception Owner Assignment

Each finance exception must be assigned.

Possible owners include:

- Store Manager
- Payment/Reconciliation Owner
- Finance Owner
- Accounting Owner
- POS Gateway Runtime Owner
- Customer Support Owner
- Compliance/Audit Owner
- Provider Contact Owner

Owner assignment must be explicit before finance handoff is marked complete.

## 16. Handoff Approval Model

Finance handoff may produce the following approval states.

| Approval State | Meaning |
|---|---|
| Clean Handoff | No known financial exceptions |
| Exception Handoff | Exceptions exist but are owned and evidenced |
| Financial Hold | One or more cases must not be finalized |
| Reconciliation Required | Matching or settlement review required |
| Evidence Incomplete | Handoff cannot be fully trusted |
| Blocked Handoff | Finance handoff cannot proceed safely |

A Clean Handoff must not be used when unresolved payment uncertainty exists.

## 17. Evidence Requirements

The finance handoff must preserve evidence for:

- Daily closeout approval
- Order final state
- Payment final or uncertain state
- Refund/cancel action
- POS Gateway response
- Manual POS entry
- Manager override
- Staff correction affecting financial state
- Customer dispute
- Settlement reference
- Reconciliation mismatch
- Finance exception owner assignment
- Accounting marker generation

Evidence must be retrievable by:

- Store ID
- Business date
- Order ID
- Payment reference
- POS provider reference
- Refund/cancel reference
- Incident ID
- Manager approval reference
- Settlement date

## 18. Reconciliation Review Rules

Reconciliation review is required when:

- Payment uncertainty exists
- Order accepted but payment missing
- Payment approved but order failed
- Refund/cancel response is unclear
- Manual POS entry exists
- Duplicate attempt is suspected
- Provider timeout occurred
- POS Gateway replay occurred
- DLQ case affected financial state
- Settlement amount differs from expected amount
- Evidence packet is incomplete

Reconciliation review must not rely on staff memory.

## 19. Customer Dispute Financial Boundary

Customer disputes that may affect finance include:

- Customer claims payment succeeded but order failed
- Customer claims duplicate charge
- Customer claims refund not received
- Customer claims cancelled order was charged
- Customer claims order was not served
- Customer claims wrong amount
- Customer claims staff promised compensation

Dispute-related financial cases must link support, finance, store runtime, and evidence.

## 20. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- Finance handoff input set is defined
- Finance handoff output set is defined
- Order-payment matching references are defined
- Payment state handoff rules are documented
- Refund/cancel handoff rules are documented
- Manual POS entry handoff is separately visible
- Settlement reference boundary is documented
- Accounting markers are defined
- Exception classification is defined
- Owner assignment is required
- Evidence requirements are defined

## 21. Acceptance Criteria

This WorkPackage is accepted when:

- Store Runtime finance handoff is not reduced to POS totals
- Order, payment, refund, cancel, manual entry, and settlement states are included
- Payment uncertainty is visible and owner-assigned
- Manual POS entry is separately reviewable
- Refund and cancel are not collapsed
- Settlement date and business date are distinguished
- Accounting markers are conservative
- Finance exceptions require owner and next action
- Evidence requirements are traceable
- Open risks are routed to backlog, waiver, or blocker register

## 22. Out of Scope

This WorkPackage does not include:

- Full accounting ledger implementation
- Final chart of accounts
- Corporate tax reporting
- Payroll accounting
- Inventory cost accounting
- Vendor invoice reconciliation
- Bank deposit reconciliation
- Full financial statement generation
- Final payment provider settlement certification

Those must be handled in finance, accounting, tax, inventory, or provider certification lanes.

## 23. Related Documents

Related document families include:

- Store Runtime Daily Closeout WorkPackage
- POS Gateway reconciliation and accounting guard WorkPackage
- Payment uncertainty policy
- Refund and cancel policy
- Manual fallback SOP
- Manager override governance
- Runtime evidence policy
- Incident register template
- Finance reconciliation policy
- Settlement review checklist
- Accounting export policy
- Audit and compliance governance

## 24. Final Rule

Finance cannot safely trust a store day unless Store Runtime hands over more than sales totals.

It must hand over the operational truth behind the numbers: orders, payments, cancellations, refunds, manual actions, exceptions, owners, and evidence.

This WorkPackage defines that handoff boundary before deeper finance, inventory, compliance, and rollout expansion lanes consume store runtime data.