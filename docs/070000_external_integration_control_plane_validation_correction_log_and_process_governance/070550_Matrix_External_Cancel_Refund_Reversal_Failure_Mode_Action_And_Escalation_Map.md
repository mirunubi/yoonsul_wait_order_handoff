# 070550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_Action_And_Escalation_Map.md

## 1. Purpose

This matrix defines the required action, escalation, evidence, and state transition rules for failures that occur during external cancel, refund, reversal, net cancel, and compensation flows.

This document belongs to the `70500` External Cancel / Refund / Reversal / Compensation Control lane and must be used with:

- `70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md`
- `70510_Policy_External_Cancel_Refund_State_Authority_And_Request_Eligibility_Control.md`
- `70520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md`
- `70530_Policy_External_Refund_Method_Limit_Partial_Cancel_And_Customer_Return_Control.md`
- `70540_Runbook_External_Cancel_Refund_Reversal_Failure_Recovery_And_Manager_Action.md`

## 2. Core Principle

Cancel, refund, reversal, and compensation failures must never be treated as ordinary API errors.

Every failed external money-return action must be classified into one of the following control states:

- `CANCEL_FAILED_UNKNOWN`
- `CANCEL_RETRY_PENDING`
- `CANCEL_INQUIRY_PENDING`
- `REVERSAL_PENDING`
- `REFUND_METHOD_BLOCKED`
- `MANUAL_REFUND_REQUIRED`
- `MANAGER_REVIEW_REQUIRED`
- `VENDOR_ESCALATION_REQUIRED`
- `RECONCILIATION_EXCEPTION`
- `CUSTOMER_RETURN_HOLD`

No customer-facing refund completion message may be issued until the state is released by the payment state authority.

## 3. Failure Mode Matrix

| Failure Mode | Initial State | Required Evidence | Allowed Action | Prohibited Action | Escalation Owner | Release Condition |
|---|---|---|---|---|---|---|
| Cancel API timeout | `CANCEL_FAILED_UNKNOWN` | cancel request id, idempotency key, raw timeout log, original approval evidence | Run cancel inquiry before retry | Mark refund complete | Payment Ops | Provider confirms cancel success or safe retry window opens |
| Cancel API returned provider error | `CANCEL_RETRY_PENDING` or `MANAGER_REVIEW_REQUIRED` | raw response, provider code, canonical error code | Map error, retry only if retryable | Blind repeated cancel | Payment Ops | Canonical retry policy passes |
| Cancel inquiry unavailable | `VENDOR_ESCALATION_REQUIRED` | inquiry attempt log, provider response, support ticket id | Escalate to provider and hold customer return state | Force internal cancel | Vendor Manager | Provider supplies official transaction status |
| Cancel succeeded externally but internal state update failed | `RECONCILIATION_EXCEPTION` | external cancel response, internal DB error, outbox/event log | Repair internal ledger through approved recovery job | Manually edit ledger row | Finance Ops + Engineering | Internal cancel ledger and external cancel evidence match |
| Internal cancel succeeded but external cancel failed | `REVERSAL_PENDING` | internal cancellation event, failed external response | Restore internal state or issue external reversal retry | Tell customer refund is complete | Payment Ops | External cancel/refund confirmed or customer return alternative approved |
| Duplicate cancel request detected | `CANCEL_RETRY_PENDING` | idempotency key, duplicate request hash, prior response | Return prior result if confirmed | Submit new cancel with new key | Payment System | Prior result validated |
| Refund method does not allow partial cancel | `REFUND_METHOD_BLOCKED` | payment method type, provider policy code, order split data | Block partial cancel and offer full cancel or manual refund route | Partial cancel by internal adjustment only | Store Manager + Payment Ops | Valid alternative refund method approved |
| Mobile carrier payment cancellation period expired | `MANUAL_REFUND_REQUIRED` | payment date, carrier rule, provider rejection code | Collect approved customer return account via secure process | Retry carrier cancel indefinitely | Customer Support + Finance Ops | Manual refund executed and ledger matched |
| Virtual account not paid yet but partial cancel requested | `REFUND_METHOD_BLOCKED` | virtual account status, deposit status, order delta | Cancel original virtual account and reissue if allowed | Change expected deposit amount silently | Payment Ops | New valid payment instruction issued |
| Virtual account paid and refund account missing | `CUSTOMER_RETURN_HOLD` | deposit confirmation, missing refund account evidence | Request secure refund account collection | Store refund account in unsafe note field | Customer Support | Refund account verified and approved |
| Reversal request returned transaction not found | `REVERSAL_PENDING` | original timeout, reversal payload, provider not-found response | Delay and retry after inquiry window | Close as failed with no follow-up | Payment Ops | Provider confirms no approval or reversal succeeds |
| Reversal succeeded but receipt evidence missing | `MANAGER_REVIEW_REQUIRED` | reversal response, missing slip/receipt data | Request receipt evidence from provider | Treat as fully reconciled | Payment Ops | Receipt or official provider evidence captured |
| Refund amount mismatch | `MANAGER_REVIEW_REQUIRED` | expected refund amount, provider refund amount, order delta | Hold and investigate | Auto-correct financial ledger | Finance Ops | Amount mismatch resolved and approved |
| Refund target mismatch | `MANAGER_REVIEW_REQUIRED` | original payer token, refund target, provider trace | Quarantine and escalate | Pay alternative target without approval | Finance Ops + Compliance | Target verified and legally approved |
| Customer claims refund not received | `CUSTOMER_RETURN_HOLD` or `RECONCILIATION_EXCEPTION` | customer claim, provider refund evidence, bank/settlement evidence | Run inquiry and attach evidence packet | Promise immediate duplicate refund | Customer Support + Finance Ops | Provider/settlement confirmation or approved duplicate prevention review |
| Provider settlement file contradicts refund API | `RECONCILIATION_EXCEPTION` | API response, settlement file, deposit report | Open reconciliation exception | Prefer API blindly | Finance Ops | Settlement and ledger correction approved |
| Store manager manually refunded cash/card outside system | `MANAGER_REVIEW_REQUIRED` | manager approval, customer receipt, CCTV/receipt if required | Register manual refund evidence and ledger adjustment request | Delete original payment or mark automatic refund | Store Manager + Finance Ops | Manual refund ledger approved |
| Provider outage during mass cancellation | `VENDOR_ESCALATION_REQUIRED` | outage notice, retry queue, affected transaction list | Freeze retry storm and batch recover | Unlimited synchronous retry | Incident Commander | Provider recovery notice and staged retry complete |

## 4. Severity Map

| Severity | Criteria | Required Response |
|---|---|---|
| S0 Financial Loss Risk | Duplicate refund, missing refund, unauthorized refund target, settlement contradiction | Immediate hold, incident record, finance escalation |
| S1 Customer Harm Risk | Customer paid but refund/cancel status unknown | Customer support hold script, inquiry, manager review |
| S2 Operational Recovery | Retryable provider timeout or transient API failure | Controlled retry with idempotency and evidence |
| S3 Mapping / Evidence Gap | Missing receipt, missing provider code mapping, incomplete payload | Register gap and block auto-release |

## 5. Required Evidence by Action Type

| Action Type | Required Evidence |
|---|---|
| Retry cancel | Original request, idempotency key, previous failure response, retry eligibility result |
| Run inquiry | Original approval id, cancel/refund request id, provider transaction id, time window |
| Reversal / net cancel | Original approval evidence, timeout/unknown evidence, delayed reversal schedule, provider response |
| Manual refund | Manager approval, customer refund target verification, finance ledger entry, customer notice log |
| Vendor escalation | Provider ticket id, raw payload, canonical mapping result, affected transaction list |
| Reconciliation exception | Internal ledger, provider API evidence, settlement file, deposit report, correction approval |

## 6. State Transition Guardrails

The following transitions are allowed only through the payment state authority:

```text
CANCEL_FAILED_UNKNOWN -> CANCEL_INQUIRY_PENDING
CANCEL_INQUIRY_PENDING -> CANCEL_RETRY_PENDING
CANCEL_INQUIRY_PENDING -> CANCEL_CONFIRMED
CANCEL_INQUIRY_PENDING -> MANAGER_REVIEW_REQUIRED
REVERSAL_PENDING -> REVERSAL_CONFIRMED
REVERSAL_PENDING -> VENDOR_ESCALATION_REQUIRED
REFUND_METHOD_BLOCKED -> MANUAL_REFUND_REQUIRED
MANUAL_REFUND_REQUIRED -> MANUAL_REFUND_CONFIRMED
RECONCILIATION_EXCEPTION -> RECONCILED
```

The following transitions are prohibited:

```text
CANCEL_FAILED_UNKNOWN -> REFUND_COMPLETE
REVERSAL_PENDING -> ORDER_CANCELLED_FINAL
REFUND_METHOD_BLOCKED -> REFUND_COMPLETE
MANAGER_REVIEW_REQUIRED -> AUTO_RELEASED
RECONCILIATION_EXCEPTION -> CLOSED_WITHOUT_EVIDENCE
```

## 7. Customer Communication Rule

Customer-facing communication must match the verified state.

| Internal State | Allowed Customer Message |
|---|---|
| `CANCEL_FAILED_UNKNOWN` | Cancellation is being checked. Do not confirm completion. |
| `CANCEL_INQUIRY_PENDING` | Payment provider status is under verification. |
| `REFUND_METHOD_BLOCKED` | This payment method requires a different refund route. |
| `MANUAL_REFUND_REQUIRED` | A manual return process is required and will be handled through an approved channel. |
| `REFUND_CONFIRMED` | Refund/cancel has been confirmed. |

Staff must not say “refund completed” until the confirmed state exists in the internal ledger and provider evidence is attached.

## 8. Linkage to 75000 Payment Integrity Architecture

This matrix hands off the following concerns to the `75000` Payment Integrity Architecture lane:

- Idempotency key generation and duplicate refund prevention
- Delayed net cancel queue design
- Saga compensation sequence for order, inventory, point, coupon, and payment rollback
- Transactional outbox event delivery for refund/cancel events
- Double-entry ledger treatment for refund, reversal, manual return, and settlement offset
- Reconciliation exception closure logic

## 9. Completion Criteria

This matrix is complete only when:

- All known cancel/refund/reversal failure modes are mapped.
- Every failure mode has a state, evidence requirement, allowed action, prohibited action, and release condition.
- No refund completion can occur without provider or approved manual evidence.
- All manual refund and manager override actions produce audit evidence.
- Reconciliation exceptions are connected to finance and settlement controls.

## 10. Next Document

Next:

`70560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Customer_Notice_Log.md`
