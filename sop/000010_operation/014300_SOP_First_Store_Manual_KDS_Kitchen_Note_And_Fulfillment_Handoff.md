# 014300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md

## 1. Purpose

This SOP defines the first-store manual KDS, kitchen note, and fulfillment handoff procedure for Catch & Order.

It is used when KDS integration is unavailable, unverified, disabled, degraded, or intentionally deferred.

The goal is to ensure that orders confirmed by staff are reliably transferred to kitchen execution without depending on automated KDS integration.

## 2. Operating Principle

Kitchen handoff must be explicitly confirmed.

An order is not considered handed off to kitchen until one of the approved kitchen handoff methods is completed and recorded.

Approved methods:

- KDS confirmation
- kitchen printer output
- manual kitchen note
- staff verbal handoff with written confirmation
- shift lead confirmation in degraded operation

## 3. Scope

This SOP covers:

- receiving manually confirmed POS order
- creating kitchen handoff note
- using KDS if available
- using printer if available
- manual kitchen ticket flow
- verbal handoff fallback
- fulfillment status update
- correction/remake/delay handling
- evidence capture

This SOP does not define cooking recipes, station mise-en-place, inventory policy, or automated KDS integration.

## 4. Roles

| Role | Responsibility |
|---|---|
| POS Operator | Confirms POS entry and sends kitchen handoff |
| Kitchen Receiver | Accepts ticket/note and starts fulfillment |
| Expeditor / Shift Lead | Resolves mismatch, remake, delay, priority issue |
| Fulfillment Staff | Updates ready/served/picked-up status |
| Store Manager | Reviews daily kitchen mismatch and delay records |
| Support Owner | Handles customer-facing delay or mismatch escalation |

## 5. Kitchen Handoff Triggers

Kitchen handoff occurs after:

1. order is manually entered into POS, or
2. order is confirmed as valid in Catch & Order, or
3. order is approved by shift lead for manual kitchen processing.

Do not send kitchen handoff for:

- duplicate suspected order
- cancelled order
- unpaid order when prepayment is required
- unavailable menu item not yet resolved
- unclear option/modifier
- unconfirmed customer/table/waiting session

## 6. Approved Handoff Methods

| Method | Use When | Required Evidence |
|---|---|---|
| KDS | KDS is available and staff can see the order | KDS sent/accepted marker |
| Kitchen Printer | Printer is available | printed ticket or print timestamp |
| Manual Kitchen Note | KDS/printer unavailable or deferred | handwritten/manual note reference |
| Verbal + Written Confirmation | Emergency or peak congestion | shift lead confirmation |
| Degraded Shift Lead Queue | System degraded | degraded operation note |

## 7. Manual Kitchen Note Format

Every manual kitchen note must include:

| Field | Required |
|---|---|
| Catch & Order order id | Yes |
| POS receipt/order number | If available |
| order time | Yes |
| customer/table/waiting context | Yes |
| menu items | Yes |
| options/modifiers | Yes |
| quantity | Yes |
| allergy/special note | If provided |
| priority / pickup time | If applicable |
| staff name/id | Yes |
| handoff time | Yes |
| correction marker | If corrected |
| cancellation/remake marker | If applicable |

## 8. Standard Kitchen Handoff Flow

1. POS Operator confirms POS entry.
2. POS Operator creates kitchen handoff using KDS, printer, or manual note.
3. Kitchen Receiver acknowledges the handoff.
4. POS Operator records handoff method and time.
5. Kitchen begins preparation.
6. Fulfillment status is updated when ready.
7. Pickup/serve completion is recorded.
8. Any delay, remake, correction, or cancellation is recorded.

## 9. KDS Available Flow

When KDS is available:

1. Send order to KDS.
2. Verify order appears on kitchen screen.
3. Kitchen Receiver confirms visibility.
4. Record KDS handoff confirmation.
5. If KDS does not show the order within expected time, use printer/manual note fallback.
6. Record KDS mismatch if fallback is used.

## 10. Printer Available Flow

When printer is available:

1. Print kitchen ticket.
2. Confirm ticket is physically printed.
3. Place ticket in kitchen queue.
4. Kitchen Receiver acknowledges ticket.
5. Record print/handoff confirmation.
6. If print fails, use manual kitchen note.
7. Record printer failure.

## 11. Manual Note Flow

When KDS/printer are unavailable:

1. Write or generate manual kitchen note.
2. Staff checks note against POS/Catch & Order order summary.
3. Kitchen Receiver reads back key item/option/quantity.
4. Staff records handoff time.
5. Kitchen starts preparation.
6. Fulfillment Staff updates ready/served status manually.

## 12. Verbal Emergency Flow

Verbal-only kitchen handoff is not preferred.

It may be used only when:

- peak congestion requires immediate action
- KDS/printer/manual note is temporarily unavailable
- shift lead approves
- written confirmation is completed as soon as possible

Verbal handoff without written confirmation is an incident risk.

## 13. Handoff Confirmation Rule

Kitchen handoff is confirmed only when:

| Method | Confirmation |
|---|---|
| KDS | order visible and acknowledged |
| Printer | physical ticket printed and received |
| Manual Note | note created and kitchen receiver acknowledges |
| Verbal | shift lead confirms and written note follows |

If no confirmation exists, status must remain "kitchen handoff pending".

## 14. Fulfillment Status

Allowed fulfillment statuses:

| Status | Meaning |
|---|---|
| Kitchen Pending | Order not yet handed to kitchen |
| Kitchen Handoff Confirmed | Kitchen has received order |
| In Preparation | Kitchen started work |
| Delayed | Delay known |
| Ready | Food ready |
| Served / Picked Up | Customer/store completed handoff |
| Cancelled | Order cancelled |
| Remake Required | Remake needed |
| Corrected | Manual correction applied |

## 15. Delay Handling

If kitchen delay occurs:

1. Kitchen Receiver notifies expeditor or shift lead.
2. Delay reason is recorded.
3. Customer-facing wording is updated safely.
4. Staff avoids promising exact completion unless confirmed.
5. If delay affects payment/order status, notify manager/support.
6. Daily review captures delay pattern.

Delay reasons:

- ingredient unavailable
- kitchen overload
- equipment issue
- staff shortage
- order correction
- customer change
- POS/KDS/printer issue
- unknown

## 16. Correction Handling

If kitchen ticket differs from POS/Catch & Order:

1. Stop preparation if possible.
2. Compare Catch & Order order summary, POS entry, and kitchen note.
3. Shift lead decides correct state.
4. Correct kitchen note or POS entry as needed.
5. Record correction evidence.
6. Continue preparation only after confirmation.

## 17. Remake Handling

Remake is required when:

- wrong item prepared
- option/modifier missed
- quantity wrong
- allergy/special note missed
- unacceptable quality issue
- customer/store approved remake

Remake steps:

1. Mark remake required.
2. Record reason.
3. Notify kitchen.
4. Record whether original item is discarded, replaced, or adjusted.
5. Record customer/support impact.
6. Include in daily review.

## 18. Cancellation After Kitchen Handoff

If cancellation occurs after kitchen handoff:

1. Notify kitchen immediately.
2. Check preparation stage.
3. Follow store cancellation/refund policy.
4. Record cancellation timing.
5. Record whether food was already prepared.
6. Reconcile POS/payment/Catch & Order state.
7. Escalate if payment/refund is involved.

## 19. Evidence Requirements

Every kitchen handoff must record:

- Catch & Order order id
- POS reference if available
- kitchen handoff method
- handoff timestamp
- receiving staff or station
- fulfillment status
- delay/correction/remake/cancel notes if applicable
- daily reconciliation status

## 20. Failure Modes

| Failure | Response |
|---|---|
| KDS not showing order | Use printer/manual note fallback |
| Printer failed | Use manual note |
| Manual note lost | Recreate from POS/Catch & Order and mark incident |
| Kitchen receives wrong order | Stop/correct/remake as needed |
| Staff forgets confirmation | Shift lead verifies and records late confirmation |
| Customer asks status but kitchen unknown | Do not guess; check kitchen and update safe wording |
| Kitchen overloaded | Mark delayed and notify front/support |
| Duplicate kitchen ticket | Stop duplicate preparation and reconcile |

## 21. Daily Close Review

At day close, review:

- total kitchen handoffs
- method count by KDS/printer/manual/verbal
- delayed orders
- remakes
- corrections
- cancellations after kitchen handoff
- lost/duplicate kitchen notes
- unresolved mismatches
- staff training gaps

## 22. Training Requirement

Staff must be trained on:

- kitchen handoff methods
- manual note format
- confirmation rule
- safe customer status wording
- delay handling
- correction handling
- remake handling
- cancellation after kitchen handoff
- evidence capture
- daily review support

## 23. Non-Goals

This SOP does not define:

- recipe procedure
- station-level cooking SOP
- inventory/sold-out master policy
- automated KDS integration
- provider adapter code
- final franchise rollout

It only defines first-store kitchen handoff and fulfillment fallback.

## 24. Related Documents

- 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md
- 14280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14320_Checklist_First_Store_POS_KDS_Staff_Training_And_Fallback_Readiness.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
- 14160_Register_POS_Provider_Incident_Reconciliation_And_Mismatch_Tracking.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
