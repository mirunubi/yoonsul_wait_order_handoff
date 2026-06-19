# 070540_Runbook_External_Cancel_Refund_Reversal_Failure_Recovery_And_Manager_Action.md

## 1. Purpose

This runbook defines the operational recovery procedure for external cancel, refund, reversal, net cancel, and compensation failures in the yoonsul_wait_order_handoff External Integration Control Plane.

The goal is to prevent money-state accidents when a cancel/refund/reversal request is partially processed, times out, is rejected by a provider, or cannot be confirmed due to missing evidence.

## 2. Scope

This runbook applies to external payment channels including POS, VAN, PG, simple payment providers, cross-border payment providers, card acquirers, settlement intermediaries, and any provider that can accept or reject a cancel, refund, reversal, or compensation request.

This runbook covers:

- customer-requested cancel
- customer-requested refund
- system recovery reversal
- delayed net cancel
- compensation transaction
- provider timeout during cancel/refund
- provider rejection during cancel/refund
- partial cancel limitation
- unavailable refund method
- manual customer return flow
- manager approval and evidence logging

## 3. Parent And Related Documents

- Parent index: `70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md`
- Previous document: `70530_Policy_External_Refund_Method_Limit_Partial_Cancel_And_Customer_Return_Control.md`
- Next document: `70550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_Action_And_Escalation_Map.md`
- Related: `70320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md`
- Related: `70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md`
- Related: `70520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md`
- Related: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Rule

A failed cancel/refund/reversal request must never be treated as completed unless provider evidence confirms completion.

A timeout during cancel/refund/reversal is not success and not final failure. It must be classified as `CANCEL_REFUND_UNKNOWN` or `REVERSAL_UNKNOWN` and routed to inquiry and reconciliation.

## 5. State Categories

| State | Meaning | Operator Action |
|---|---|---|
| `CANCEL_REQUESTED` | Cancel request was created internally | Wait for provider response or inquiry |
| `CANCEL_SENT` | Request was sent to external provider | Do not duplicate without idempotency key |
| `CANCEL_CONFIRMED` | Provider confirmed cancel | Release customer/order state only after validation |
| `CANCEL_DECLINED` | Provider rejected cancel | Check reason and route to manual/refund alternative |
| `CANCEL_UNKNOWN` | Timeout or no reliable confirmation | Run inquiry before customer confirmation |
| `REFUND_REQUESTED` | Refund flow initiated | Validate method eligibility |
| `REFUND_CONFIRMED` | Provider confirmed refund | Record evidence and update ledger |
| `REFUND_REJECTED` | Refund impossible through original method | Use customer return flow if allowed |
| `REVERSAL_PENDING` | System recovery reversal is required | Manager and system recovery queue required |
| `COMPENSATION_PENDING` | Logical compensation transaction is required | Saga/ledger evidence required |
| `MANUAL_RETURN_PENDING` | Manual bank/cash return is required | Manager approval and customer evidence required |
| `RECONCILIATION_EXCEPTION` | Provider and internal ledger disagree | Hold settlement/release until resolved |

## 6. Prohibited Operator Actions

Operators must not:

- tell the customer that a refund is complete without provider confirmation
- retry cancel/refund repeatedly without an idempotency key
- manually mark an order as refunded based only on customer SMS/app screenshot
- delete or overwrite failed provider responses
- bypass inquiry when the state is unknown
- process manual return without manager approval
- close a reconciliation exception without evidence
- treat provider timeout as final success
- treat provider timeout as final failure
- compensate by creating an unlinked cash movement outside the ledger

## 7. Standard Recovery Procedure

### 7.1 Step 1 — Freeze State

When a cancel/refund/reversal error occurs, the system must freeze the related order/payment state.

Required actions:

1. prevent duplicate customer-visible completion messages
2. block automatic kitchen/order release if payment state is unresolved
3. mark the transaction as `CANCEL_UNKNOWN`, `REFUND_REJECTED`, `REVERSAL_PENDING`, or `RECONCILIATION_EXCEPTION`
4. create an incident or recovery ticket
5. attach raw request and raw response payloads

### 7.2 Step 2 — Preserve Evidence

The operator or system must preserve:

- internal payment intent id
- original approval number
- provider transaction id
- VAN/PG trace id
- cancel/refund request id
- idempotency key
- request timestamp
- response timestamp
- raw provider payload
- error code and message
- receipt/slip evidence if available
- customer-facing message log
- manager action log

### 7.3 Step 3 — Run Inquiry

If the provider response is missing, ambiguous, or timed out, run the appropriate inquiry channel.

Inquiry priority:

1. cancel/refund inquiry by provider transaction id
2. approval inquiry by original approval number
3. last transaction inquiry by terminal id and time window
4. settlement file or batch export check
5. vendor support escalation if automated inquiry is unavailable

### 7.4 Step 4 — Classify Result

After inquiry, classify the result.

| Inquiry Result | Required Classification |
|---|---|
| Provider confirms cancel/refund success | `CANCEL_CONFIRMED` or `REFUND_CONFIRMED` |
| Provider confirms no cancel/refund received | retry if eligible with same idempotency key or new controlled recovery request |
| Provider confirms original payment not approved | release cancel path and update payment state |
| Provider confirms original payment approved but cancel failed | `REVERSAL_PENDING` or `MANUAL_RETURN_PENDING` |
| Provider result conflicts with internal ledger | `RECONCILIATION_EXCEPTION` |
| Provider cannot answer | vendor escalation and evidence hold |

### 7.5 Step 5 — Execute Recovery Action

Recovery action must follow the mapped state.

| State | Recovery Action |
|---|---|
| `CANCEL_UNKNOWN` | inquiry first, then retry or hold |
| `CANCEL_DECLINED` | inspect policy reason and route to refund/manual return |
| `REFUND_REJECTED` | check method limitation and customer return eligibility |
| `REVERSAL_PENDING` | queue delayed net cancel or reversal worker |
| `COMPENSATION_PENDING` | trigger Saga compensation with ledger link |
| `MANUAL_RETURN_PENDING` | manager-approved customer return flow |
| `RECONCILIATION_EXCEPTION` | accounting/reconciliation review before release |

## 8. Customer Communication Rules

Customer messages must use cautious status language.

Allowed examples:

- “결제 취소 상태를 확인 중입니다.”
- “외부 결제망 확인 후 확정 안내드리겠습니다.”
- “카드사/결제사 반영 시간 때문에 즉시 완료로 표시되지 않을 수 있습니다.”

Prohibited examples:

- “취소 완료됐습니다” before provider confirmation
- “실패니까 다시 결제하세요” while state is unknown
- “돈은 안 빠졌을 겁니다” without inquiry evidence
- “문제 없으니 기다리세요” without recovery ticket

## 9. Manager Approval Required Cases

Manager approval is required for:

- manual customer bank transfer return
- cash return
- cancel/refund after provider deadline
- override of provider rejection
- compensation transaction affecting points, coupons, or store revenue
- duplicate approval cleanup
- settlement hold release
- closing reconciliation exception

Approval record must include:

- manager id
- reason code
- evidence links
- customer impact statement
- financial amount
- ledger entry id
- timestamp

## 10. Vendor Escalation Criteria

Escalate to provider/vendor when:

- automated inquiry is unavailable
- inquiry result conflicts with settlement file
- cancel/refund request is accepted but never completed
- provider response code is undocumented
- duplicate approvals are visible in provider records
- provider trace id cannot be resolved
- customer app/card statement shows different result from provider API

Vendor escalation packet must include:

- provider name
- merchant id
- terminal id if applicable
- original approval number
- provider transaction id
- trace id
- amount
- request/response timestamp
- raw payload hash
- internal state
- expected recovery result

## 11. Reconciliation Follow-Up

Every recovery case must be rechecked during daily reconciliation.

Required checks:

- internal ledger vs provider approval record
- cancel/refund ledger vs provider cancel/refund record
- settlement expected amount vs actual deposit
- fee and tax treatment
- manual return ledger posting
- duplicate or missing compensation event

Any unresolved difference must remain open as `RECONCILIATION_EXCEPTION`.

## 12. Evidence Retention

All recovery evidence must be retained according to the financial-grade audit ledger retention policy.

Evidence must not be overwritten. Corrections must be appended as new records with before/after values and approval metadata.

## 13. Closeout Criteria

A cancel/refund/reversal failure recovery case may be closed only when all conditions are met:

1. provider result is confirmed or manual return is completed
2. internal ledger state matches provider evidence
3. customer-facing status is updated
4. manager approval exists when required
5. reconciliation follow-up is completed or scheduled
6. audit packet is sealed
7. no open financial difference remains

## 14. Handoff

This runbook hands off to:

- `70550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_Action_And_Escalation_Map.md`
- `70560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Ledger_Log.md`
- `70600_Index_External_Settlement_Reconciliation_Deposit_Fee_And_Ledger_Audit.md`
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`
