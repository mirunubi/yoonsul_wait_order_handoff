# 014360_Runbook_First_Store_Day_Zero_Activation_And_Manual_Fallback_Operation.md

## 1. Purpose

This runbook defines the Day-Zero activation procedure for Catch & Order at the first store.

It is used on the first controlled operating day when Catch & Order is activated with manual POS entry, manual or semi-manual KDS/kitchen handoff, payment/order separation, daily reconciliation, and fallback controls.

The goal is to activate safely, monitor closely, and preserve the ability to stop or downgrade operation immediately.

## 2. Day-Zero Principle

Day-Zero is not a normal operating day.

It is a controlled activation day.

The store must prioritize:

- safe customer-facing wording
- staff confirmation
- duplicate prevention
- manual POS entry accuracy
- kitchen handoff confirmation
- payment evidence separation
- incident capture
- daily reconciliation
- rollback readiness

## 3. Activation Scope

Default Day-Zero scope:

| Area | Default |
|---|---|
| POS integration | Disabled or manual-only |
| KDS integration | Manual/KDS-if-available |
| Payment execution | POS/payment terminal only |
| Payment observation | Manual evidence only |
| Provider adapter | Disabled unless gate-approved |
| Customer-facing status | Conservative wording |
| Daily reconciliation | Required |
| Support escalation | Required |

## 4. Pre-Opening Checklist

Complete before the store opens.

| Check | Required | Done | Owner |
|---|---|---|---|
| Opening readiness gate passed | Yes |  |  |
| Store shift lead present | Yes |  |  |
| POS operator assigned | Yes |  |  |
| Kitchen receiver assigned | Yes |  |  |
| Reconciliation owner assigned | Yes |  |  |
| Support escalation owner assigned | Yes |  |  |
| Manual POS entry SOP visible | Yes |  |  |
| Manual kitchen note format visible | Yes |  |  |
| Daily reconciliation template ready | Yes |  |  |
| Fallback materials ready | Yes |  |  |
| Customer-safe wording visible | Yes |  |  |
| Activation scope confirmed | Yes |  |  |
| Stop/rollback authority confirmed | Yes |  |  |

## 5. Staff Briefing Script

Before activation, shift lead briefs staff:

1. Today is controlled activation.
2. Do not assume payment completion from order creation.
3. Do not assume POS entry from Catch & Order order intent.
4. Do not send to kitchen without confirmation.
5. Check duplicate risk before POS entry.
6. Use manual kitchen note if KDS/printer is unclear.
7. Record every correction, cancellation, refund, and mismatch.
8. Escalate unclear states. Do not guess.
9. Safe customer wording must be used.
10. If operation becomes unsafe, we pause or downgrade.

## 6. Activation Steps

1. Confirm readiness gate status.
2. Confirm allowed service modes.
3. Confirm provider adapter remains disabled unless approved.
4. Confirm manual POS entry path.
5. Confirm manual kitchen handoff path.
6. Confirm payment/order separation rule.
7. Confirm support escalation route.
8. Start internal test order.
9. Manually enter test order into POS.
10. Create kitchen handoff.
11. Record evidence.
12. Reconcile test order.
13. Activate limited customer-facing order intake.
14. Monitor first real orders one by one.

## 7. First Real Order Procedure

For the first real order:

1. Staff receives Catch & Order order summary.
2. Shift lead observes duplicate check.
3. POS operator manually enters POS order.
4. POS operator records POS entry confirmation.
5. Kitchen receiver confirms handoff.
6. Payment state remains separate.
7. Support owner checks customer-facing wording.
8. Reconciliation owner marks first order for day-close verification.
9. Shift lead approves continuing.

## 8. First 10 Orders Monitoring

The first 10 orders must be monitored more closely.

| Order No. | Check Required |
|---:|---|
| 1 | shift lead observes full flow |
| 2 | duplicate check confirmed |
| 3 | POS entry reference captured |
| 4 | kitchen handoff confirmed |
| 5 | payment wording checked |
| 6 | correction path checked if needed |
| 7 | support wording checked |
| 8 | reconciliation marker checked |
| 9 | staff handoff independence checked |
| 10 | decision to continue/hold/downgrade |

## 9. Live Monitoring Metrics

Track during Day-Zero:

| Metric | Alert If |
|---|---|
| manual POS entry delay | repeated delay affects customer |
| duplicate risk checks | staff skips check |
| kitchen handoff pending | unresolved pending orders |
| payment unknown | staff/customer confusion |
| manual corrections | repeated correction type |
| sold-out mismatches | menu availability issue |
| cancellation/refund confusion | evidence unclear |
| customer complaints | repeated wording/status issue |
| staff escalation | too many unclear decisions |
| reconciliation gaps | evidence missing |

## 10. Hold Conditions

Pause new Catch & Order intake if:

- duplicate order risk cannot be resolved
- POS entry queue is backing up
- kitchen handoff is not being confirmed
- payment state wording confuses staff/customers
- cancellation/refund process is unclear
- staff are bypassing evidence capture
- support escalation cannot respond
- shift lead cannot supervise active risk

## 11. Downgrade Conditions

Downgrade to internal/manual-only mode if:

- customer-facing status becomes unsafe
- staff cannot keep up with manual POS entry
- kitchen handoff errors repeat
- payment/order mismatch occurs
- refund/cancel mismatch occurs
- daily reconciliation evidence cannot be captured
- provider/POS/KDS issue creates confusion

## 12. Rollback Procedure

If operation becomes unsafe:

1. Stop new Catch & Order intake.
2. Mark current active orders for manual handling.
3. Complete POS and kitchen handoff for already accepted orders.
4. Notify shift lead, manager, support owner.
5. Use customer-safe wording.
6. Record rollback time and reason.
7. Preserve all evidence.
8. Complete reconciliation for affected orders.
9. Create mismatch/escalation record.
10. Decide whether to resume, hold, or close activation.

## 13. Customer-Safe Wording During Day-Zero

Use:

- 매장에서 주문을 확인 중입니다.
- 주문을 매장 시스템에 입력 중입니다.
- 주방 전달을 확인 중입니다.
- 결제 상태를 확인 중입니다.
- 조리 상황을 확인 중입니다.
- 확인 후 안내드리겠습니다.

Avoid:

- 결제 완료
- 환불 완료
- POS 접수 완료
- 주방 접수 완료
- 조리 완료
- 확정 완료

unless evidence exists.

## 14. Incident Handling

Create incident or issue if:

- order is duplicated
- POS entry missing
- kitchen handoff missing
- payment/order mismatch exists
- refund/cancel unclear
- customer-facing state wrong
- staff correction lacks evidence
- order delayed due to process failure
- manual note lost
- support escalation failed

## 15. Day-Zero Close Procedure

At close:

1. Export or collect Catch & Order order list.
2. Collect POS records.
3. Collect payment terminal/VAN/PG records.
4. Collect kitchen handoff notes.
5. Review manual correction log.
6. Review cancellation/refund cases.
7. Review customer/support issues.
8. Complete daily reconciliation template.
9. List unresolved mismatches.
10. Decide next-day scope.

## 16. Day-Zero Outcome

| Outcome | Meaning |
|---|---|
| Continue Same Scope | Day-Zero stable enough to continue |
| Continue With Conditions | Continue but restrict specific flow |
| Dry Run Only | Customer-facing use should stop |
| Staff Retraining Required | Training gap found |
| Support Wording Revision Required | Customer/status wording unsafe |
| Reconciliation Fix Required | Evidence or close process insufficient |
| Hold Activation | Do not operate until issue resolved |
| Rollback | Disable Catch & Order customer-facing intake |

## 17. Next-Day Scope Decision

| Field | Value |
|---|---|
| next_day_scope |  |
| restricted_modes |  |
| training_required |  |
| SOP_update_required |  |
| support_update_required |  |
| reconciliation_issue_open |  |
| decision_owner |  |
| decision_time |  |

## 18. Non-Goals

This runbook does not define:

- provider API integration
- payment execution
- franchise rollout
- automated KDS implementation
- full operating manual for all stores

It only defines first-store Day-Zero controlled activation.

## 19. Related Documents

- 14350_Checklist_First_Store_Catch_Order_Opening_Readiness_Gate.md
- 14340_Index_First_Store_Manual_Fallback_Readiness_Closeout_And_Handoff.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
- 14320_Checklist_First_Store_POS_KDS_Staff_Training_And_Fallback_Readiness.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md
- 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md
