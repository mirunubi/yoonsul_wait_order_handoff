# 014290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md

## 1. Purpose

This SOP defines the first-store manual POS entry and order confirmation procedure for Catch & Order.

It is used when POS provider integration is not yet available, not approved, degraded, disabled, or intentionally limited to manual fallback.

The goal is to ensure that the first store can operate safely without deep POS API integration.

## 2. Operating Principle

Manual POS entry is not a temporary weakness.

It is the baseline safe mode for MVP operation until official POS provider integration is verified, tested, and approved.

Catch & Order may hold order intent and customer/session state, but the store POS remains the operational sales source until official integration is approved.

## 3. Scope

This SOP covers:

- staff receiving Catch & Order order summary
- staff manually entering the order into POS
- staff confirming POS entry
- handling unavailable menu items
- correcting mistaken entry
- cancellation and refund handoff
- evidence capture
- daily reconciliation input

This SOP does not define payment execution or provider API integration.

## 4. Roles

| Role | Responsibility |
|---|---|
| Order Receiver | Reviews incoming Catch & Order order summary |
| POS Operator | Enters order into POS manually |
| Kitchen Handoff Staff | Sends order to kitchen/KDS/manual ticket |
| Shift Lead | Resolves mismatch, unavailable items, cancellation, correction |
| Store Owner / Manager | Reviews daily reconciliation |
| Support Owner | Handles customer-facing escalation |

## 5. Manual POS Entry Trigger

Use this SOP when:

- POS API integration does not exist
- provider route is unverified
- provider sandbox is unavailable
- adapter is disabled
- kill switch is active
- provider outage occurs
- payment scope is unknown
- staff must manually enter pre-order/wait-order into POS
- pilot decision gate limits provider to manual fallback

## 6. Manual POS Entry Flow

1. Staff receives new Catch & Order order summary.
2. Staff checks customer/session/table/waiting context.
3. Staff checks menu availability and sold-out state.
4. Staff enters the order into store POS manually.
5. Staff verifies item names, options, quantities, discounts, and notes.
6. Staff confirms POS entry in Catch & Order.
7. Catch & Order records confirmation evidence.
8. Staff sends kitchen handoff via KDS, printer, or manual kitchen note.
9. Staff handles payment through store POS/payment terminal.
10. Staff updates order status only within approved manual workflow.
11. Daily reconciliation compares Catch & Order, POS, payment, and manual corrections.

## 7. Required Staff Checks Before POS Entry

| Check | Required |
|---|---|
| Correct customer/session selected | Yes |
| Order is not duplicated | Yes |
| Store/menu availability checked | Yes |
| Options and modifiers checked | Yes |
| Quantity checked | Yes |
| Special notes reviewed | Yes |
| Customer pickup/dine-in/table context checked | Yes |
| Payment state not assumed | Yes |
| POS entry confirmation ready | Yes |

## 8. Duplicate Prevention

Before entering an order into POS, staff must check:

- order id
- customer name or masked identifier
- order time
- order summary
- table/waiting session
- whether the order was already marked POS-entered
- whether another staff member is handling the same order

If duplicate is suspected:

1. Do not enter the order.
2. Mark as duplicate check required.
3. Notify shift lead.
4. Resolve before kitchen handoff.
5. Record evidence.

## 9. POS Entry Confirmation

After manual POS entry, staff must record:

| Field | Required |
|---|---|
| Catch & Order order id | Yes |
| POS receipt/order number | If available |
| staff id | Yes |
| POS entry time | Yes |
| entered items | Yes |
| changed items | If any |
| sold-out substitutions | If any |
| payment status source | If known |
| kitchen handoff status | Yes |
| correction note | If any |

## 10. Menu Unavailable / Sold-Out Handling

If an item is unavailable:

1. Do not silently change the order.
2. Mark item unavailable.
3. Notify customer or support flow according to store policy.
4. Offer allowed replacement or cancellation path.
5. Update Catch & Order order note.
6. Enter only confirmed items into POS.
7. Record manual correction evidence.

## 11. Staff Correction Flow

Use correction flow when:

- wrong menu item was entered
- option was missed
- quantity was wrong
- discount/coupon was entered incorrectly
- sold-out replacement was selected
- customer changed request
- POS entry and Catch & Order order differ

Correction steps:

1. Stop kitchen handoff if possible.
2. Notify shift lead.
3. Correct POS entry according to store POS procedure.
4. Update Catch & Order manual correction record.
5. Record reason and staff id.
6. Reconcile at day close.

## 12. Cancellation Flow

If customer cancels before POS entry:

1. Mark Catch & Order order as cancelled before POS entry.
2. Do not enter into POS.
3. Record cancellation reason.
4. Notify kitchen if already informed manually.

If customer cancels after POS entry:

1. Follow store POS cancellation procedure.
2. Record POS cancellation reference if available.
3. Record Catch & Order cancellation note.
4. Notify kitchen.
5. Reconcile cancellation at daily close.

## 13. Refund Flow

If payment has occurred through POS/payment terminal:

1. Refund must follow POS/payment terminal procedure.
2. Catch & Order must not mark refund complete unless staff confirms evidence.
3. Record refund reference if available.
4. Record staff id and reason.
5. Reconcile refund at daily close.

## 14. Customer-Facing State Rule

Do not show or say:

- "paid" unless payment evidence exists
- "sent to POS" unless POS entry is confirmed
- "kitchen received" unless KDS/print/manual handoff is confirmed
- "cancelled/refunded" unless cancellation/refund evidence exists

Use safe wording:

- "order received"
- "staff is confirming"
- "being entered at store"
- "kitchen handoff pending"
- "manual confirmation required"

## 15. Evidence Requirements

Every manually entered order must have:

- Catch & Order order id
- staff confirmation
- POS entry timestamp
- POS reference if available
- kitchen handoff marker
- correction/cancel/refund notes if applicable
- reconciliation status

## 16. Exception Handling

| Exception | Action |
|---|---|
| POS unavailable | Use manual sales backup and notify manager |
| POS slow/frozen | Pause new manual entry and notify shift lead |
| Duplicate order suspected | Do not enter; investigate |
| Customer changed order | Record correction before POS entry |
| Item unavailable | Use sold-out handling |
| Payment mismatch | Escalate to shift lead and finance/support |
| Kitchen already started wrong item | Record correction and manager decision |
| Staff cannot determine state | Escalate; do not guess |

## 17. Daily Close Requirement

At day close, compare:

- Catch & Order manually confirmed orders
- POS receipts/orders
- payment terminal records
- cancellations/refunds
- manual corrections
- kitchen handoff notes

Unresolved mismatch must become an incident or reconciliation issue.

## 18. Training Requirement

Staff must be trained before using this SOP.

Training must cover:

- order summary reading
- duplicate check
- POS manual entry
- confirmation recording
- sold-out handling
- correction/cancellation/refund evidence
- safe customer wording
- daily reconciliation support

## 19. Non-Goals

This SOP does not define:

- POS API integration
- automated KDS handoff
- payment execution
- settlement accounting
- franchise rollout
- provider certification

It only defines first-store manual POS entry and confirmation.

## 20. Related Documents

- 14280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md
- 14300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14320_Checklist_First_Store_POS_KDS_Staff_Training_And_Fallback_Readiness.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
- 14160_Register_POS_Provider_Incident_Reconciliation_And_Mismatch_Tracking.md
- 14150_Runbook_POS_Provider_First_Pilot_Activation_Monitoring_And_Rollback.md
