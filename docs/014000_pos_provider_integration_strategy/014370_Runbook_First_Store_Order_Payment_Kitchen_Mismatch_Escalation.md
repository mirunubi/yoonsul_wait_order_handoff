# 014370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md

## 1. Purpose

This runbook defines how the first store escalates and resolves mismatches between Catch & Order, POS, payment evidence, kitchen handoff, and fulfillment state.

It is used during Day-Zero activation and early controlled operations.

The goal is to prevent staff from guessing when states do not match.

## 2. Core Rule

When order, POS, payment, or kitchen state is unclear, stop assumption and escalate.

Do not mark an order as paid, entered, handed to kitchen, cancelled, refunded, ready, or served unless supporting evidence exists.

## 3. Mismatch Domains

| Domain | Example |
|---|---|
| Order | Catch & Order has order, POS does not |
| POS | POS has order, Catch & Order does not |
| Payment | payment exists but matching order unclear |
| Kitchen | kitchen received order but POS/payment unclear |
| Fulfillment | food ready but order/payment state unclear |
| Cancellation | cancellation exists in one system only |
| Refund | refund requested but not confirmed |
| Customer Status | customer-facing status differs from store reality |

## 4. Severity Levels

| Severity | Meaning | Required Response |
|---|---|---|
| M0 | Customer/payment harm risk | Stop affected flow and escalate immediately |
| M1 | Financial/order mismatch | Shift lead + manager review before close |
| M2 | Operational mismatch | Correct and log |
| M3 | Training/process issue | Record and retrain |
| M4 | Informational | Keep evidence |

## 5. Escalation Owners

| Issue | Primary Owner | Secondary Owner |
|---|---|---|
| duplicate order | shift lead | manager |
| POS entry mismatch | POS operator | shift lead |
| kitchen handoff mismatch | kitchen receiver | shift lead |
| payment mismatch | manager | finance/support owner |
| cancellation/refund mismatch | manager | support/payment owner |
| customer-facing wording issue | support owner | shift lead |
| evidence missing | reconciliation owner | manager |
| repeated staff error | store manager | training owner |

## 6. Immediate Stop Conditions

Pause affected order flow if:

- duplicate order is suspected
- customer paid but order is not matched
- order exists but payment requirement is unclear
- kitchen started an order with unclear POS state
- cancellation/refund state is ambiguous
- customer-facing status is wrong
- staff cannot identify the current state
- evidence cannot be captured

## 7. Mismatch Intake Steps

1. Identify mismatch type.
2. Stop further state change for affected order if needed.
3. Assign severity.
4. Notify escalation owner.
5. Gather evidence from all sources.
6. Determine current safe state.
7. Apply correction, cancellation, refund, remake, or fallback.
8. Record decision and evidence.
9. Update daily reconciliation log.
10. Decide whether training or SOP update is required.

## 8. Evidence Collection Checklist

| Evidence | Required When |
|---|---|
| Catch & Order order id | Always |
| POS receipt/order reference | POS-related issue |
| payment reference | payment/refund/cancel issue |
| kitchen note/KDS/print reference | kitchen-related issue |
| staff confirmation | manual action |
| customer support note | customer-facing issue |
| manager approval | M0/M1 or refund/cancel |
| timestamp | Always |
| correction reason | correction |
| final reconciliation status | Always |

## 9. Order Without POS

Use when Catch & Order has an order but POS does not.

Steps:

1. Confirm order id and time.
2. Check whether order was already cancelled.
3. Check duplicate handling.
4. If valid, manually enter into POS.
5. Record POS reference.
6. Send kitchen handoff only after POS entry or shift lead approval.
7. Record correction as ORDER_WITHOUT_POS if delayed.
8. Include in daily reconciliation.

## 10. POS Without Order

Use when POS has an order but Catch & Order does not.

Steps:

1. Check whether order was manually created outside Catch & Order.
2. Check staff notes.
3. Check if customer/order session exists but was not linked.
4. Do not create fake customer state.
5. Mark POS-only order for reconciliation.
6. If customer support is involved, use safe wording.
7. Manager decides whether to close as external POS order or manual correction.

## 11. Payment Without Order

Use when payment evidence exists but matching order is unclear.

Steps:

1. Stop customer-facing completion claim.
2. Gather payment reference.
3. Search POS record.
4. Search Catch & Order order/session.
5. Escalate to manager/payment owner.
6. Do not issue refund unless store payment policy confirms.
7. Record as M0 or M1 depending customer impact.
8. Resolve before day close if possible.

## 12. Order Without Payment

Use when order exists but payment evidence is missing.

Steps:

1. Check whether payment was required at that step.
2. Check POS/payment terminal.
3. Ask POS operator or shift lead.
4. Do not mark paid.
5. Use "payment checking" customer-safe wording.
6. If food is not yet prepared, hold if policy requires payment first.
7. Record mismatch if unresolved.
8. Reconcile at day close.

## 13. Kitchen Without POS

Use when kitchen received or started order before POS entry confirmation.

Steps:

1. Stop further preparation if safe.
2. Compare kitchen note with Catch & Order order summary.
3. Check POS entry.
4. If POS missing and order valid, enter POS or manager approves exception.
5. Record kitchen handoff correction.
6. If food already prepared, manager decides handling.
7. Reconcile POS/kitchen/order state.

## 14. POS Without Kitchen

Use when POS entry exists but kitchen did not receive handoff.

Steps:

1. Confirm POS order.
2. Check KDS/printer/manual note.
3. If missing, create kitchen handoff immediately.
4. Notify kitchen of delay.
5. Update customer-safe status if needed.
6. Record delay and evidence.
7. Review staff training if repeated.

## 15. Cancellation Mismatch

Use when cancellation exists in one source only.

Steps:

1. Identify cancellation stage: before POS, after POS, after kitchen, after payment.
2. Gather cancellation request.
3. Gather POS cancellation evidence if applicable.
4. Gather kitchen stop/prepare state.
5. Gather payment/refund evidence if applicable.
6. Manager decides final state.
7. Update all records.
8. Record cancellation mismatch.

## 16. Refund Mismatch

Use when refund is requested or claimed but not confirmed.

Steps:

1. Do not mark refund complete.
2. Gather payment reference.
3. Confirm store refund procedure.
4. Record refund request time.
5. Confirm refund evidence from POS/payment terminal.
6. Update Catch & Order only after evidence.
7. Escalate unresolved refund to manager/payment owner.
8. Include in daily reconciliation.

## 17. Customer-Facing Status Mismatch

Use when customer sees or hears a state that does not match store evidence.

Steps:

1. Stop repeating unsafe wording.
2. Check actual order/POS/payment/kitchen state.
3. Use conservative wording.
4. Notify support owner if customer impact exists.
5. Correct visible state if possible.
6. Record support note.
7. Review wording rule after close.

## 18. Resolution Outcomes

| Outcome | Meaning |
|---|---|
| Corrected | State corrected with evidence |
| Cancelled | Cancellation completed with evidence |
| Refunded | Refund completed with evidence |
| Manually Closed | Manager closed with note |
| Pending Evidence | Evidence still missing |
| Escalated | Requires owner review |
| Training Gap | Staff retraining required |
| SOP Update Required | Document flow must be updated |

## 19. Post-Incident Review

For M0/M1 issues, complete review:

| Item | Required |
|---|---|
| root cause | Yes |
| customer impact | Yes |
| financial impact | Yes |
| staff action | Yes |
| system/state issue | Yes |
| evidence completeness | Yes |
| prevention action | Yes |
| owner | Yes |
| due date | Yes |

## 20. Daily Close Link

All unresolved mismatches must be transferred to:

- 14330 daily reconciliation and manual correction log
- support issue log if customer-facing
- payment/finance review if payment-related
- training gap list if staff-related
- provider incident register if provider integration is active

## 21. Non-Goals

This runbook does not define:

- full customer service policy
- legal refund obligations
- payment gateway implementation
- provider API reconciliation
- accounting close

It defines first-store mismatch escalation in manual/semi-manual operation.

## 22. Related Documents

- 14360_Runbook_First_Store_Day_Zero_Activation_And_Manual_Fallback_Operation.md
- 14350_Checklist_First_Store_Catch_Order_Opening_Readiness_Gate.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md
- 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md
- 14160_Register_POS_Provider_Incident_Reconciliation_And_Mismatch_Tracking.md
