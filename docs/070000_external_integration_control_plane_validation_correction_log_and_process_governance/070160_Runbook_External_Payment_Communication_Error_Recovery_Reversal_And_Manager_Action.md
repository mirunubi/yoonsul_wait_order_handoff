# 070160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md

## 1. Purpose

This runbook defines the operational recovery procedure for external payment communication errors, uncertain payment results, reversal/cancel ambiguity, and store manager action in the External Integration Control Plane.

The purpose of this document is to prevent money accidents when POS, VAN, PG, simple payment providers, card acquirers, or other external payment providers return delayed, missing, conflicting, or incomplete payment responses.

This document belongs to the 70000 External Integration Control Plane lane and is controlled by:

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`
- `70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md`
- `70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md`
- `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`
- `70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md`
- `70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md`

## 2. Core Principle

External payment communication errors must never be treated as simple payment failure.

A timeout, missing response, broken socket, interrupted POS daemon, delayed callback, duplicate callback, or ambiguous VAN/PG result must be placed into a controlled recovery state until inquiry, reversal, reconciliation, or manager verification resolves the case.

The system must not expose a final customer-facing result until the payment state is safe enough to display.

## 3. Scope

This runbook applies to communication and recovery events involving:

- POS payment adapters
- VAN approval and cancel networks
- PG confirm and cancel APIs
- simple payment providers
- Alipay / WeChat Pay cross-border payment routes
- card acquirer and issuer responses
- external kiosk vendors
- external order app payment flows
- delivery app payment handoff flows
- external membership and coupon payment adjustment flows
- settlement file and end-of-day payment reconciliation feeds

## 4. Non-Scope

This runbook does not define:

- provider onboarding contract requirements
- low-level device driver protocols
- full settlement accounting logic
- tax reporting rules
- customer refund policy terms
- legal dispute settlement procedures

Those are controlled by separate governance, audit, settlement, legal, and accounting documents.

## 5. Mandatory Recovery States

The following states must be available before production payment integration is allowed.

| State | Meaning | Final State Allowed |
|---|---|---|
| `PAYMENT_REQUESTED` | Internal payment intent created | No |
| `SENT_TO_EXTERNAL_PROVIDER` | Request sent to POS/VAN/PG/provider | No |
| `RESPONSE_NOT_RECEIVED` | No response received within normal wait window | No |
| `TIMEOUT_UNKNOWN` | Communication timed out, external result unknown | No |
| `RESPONSE_RECEIVED` | External response was received and stored | No |
| `VALIDATION_PENDING` | Response awaits internal validation | No |
| `CONFIRMED` | Payment validated and internally confirmed | Yes |
| `DECLINED` | External provider returned confirmed decline | Yes |
| `AMBIGUOUS` | Conflicting or incomplete result | No |
| `MISMATCHED` | Amount/order/provider/terminal mismatch detected | No |
| `INQUIRY_PENDING` | Inquiry is required or in progress | No |
| `REVERSAL_PENDING` | Cancel/reversal is required or in progress | No |
| `REVERSAL_CONFIRMED` | Reversal/cancel was confirmed | Yes |
| `MANAGER_REVIEW_REQUIRED` | Store manager or HQ review required | No |
| `RECONCILIATION_EXCEPTION` | End-of-day or settlement mismatch detected | No |
| `RECONCILED` | Case resolved through reconciliation | Yes |

## 6. Communication Error Classification

All communication errors must be classified before recovery action.

| Error Type | Example | Required First Action |
|---|---|---|
| Request send failure | POS daemon unreachable before request transmission | Mark as `RESPONSE_NOT_RECEIVED`; do not charge again without new intent |
| Request sent but response lost | Socket closed after sending payment request | Mark as `TIMEOUT_UNKNOWN`; run inquiry |
| Response received but invalid | Missing approval number or malformed payload | Store raw payload; mark as `AMBIGUOUS` |
| External success but internal mismatch | Amount or order ID mismatch | Mark as `MISMATCHED`; block order completion |
| External success but order failure | Payment approved but order creation failed | Run order repair or reversal path |
| External cancel timeout | Cancel requested but cancel response missing | Mark as `REVERSAL_PENDING`; run cancel inquiry |
| Duplicate response | Same trace ID or approval number repeated | De-duplicate; do not create second payment |
| Late response | Response arrives after UI already timed out | Attach to original intent; do not create new state without validation |
| Provider callback conflict | API response says fail but webhook says success | Mark as `AMBIGUOUS`; run provider inquiry |

## 7. General Recovery Pipeline

Every payment communication error must follow this pipeline.

```text
1. Freeze customer-facing finalization.
2. Persist the payment intent and request metadata.
3. Persist any raw response or raw error payload.
4. Assign a recovery state.
5. Run inquiry when provider supports it.
6. Validate inquiry result against internal intent.
7. Decide one of: confirm, decline, reverse, repair order, escalate.
8. Write recovery event log.
9. Notify store manager only when human action is required.
10. Include the case in end-of-day reconciliation.
```

## 8. Scenario A — Request Not Sent

### 8.1 Condition

The system failed before the payment request was successfully transmitted to the external provider.

Examples:

- POS daemon process is down
- local socket unavailable
- terminal adapter unavailable
- provider credential missing
- network path blocked before request transmission

### 8.2 System Action

1. Keep the payment intent in `PAYMENT_REQUESTED` or move to `RESPONSE_NOT_RECEIVED`.
2. Mark the request as `NOT_SENT_CONFIRMED` only when the adapter can prove the request was not transmitted.
3. Do not create an approval record.
4. Allow retry only with the same idempotency key or a controlled new payment intent.
5. Show customer and operator a safe retry message.

### 8.3 Manager Action

The manager may retry payment only if the system shows `NOT_SENT_CONFIRMED` or `SAFE_TO_RETRY`.

The manager must not ask the customer to pay again if the system shows `TIMEOUT_UNKNOWN`, `INQUIRY_PENDING`, `AMBIGUOUS`, or `REVERSAL_PENDING`.

## 9. Scenario B — Request Sent, Response Lost

### 9.1 Condition

The payment request may have reached the external provider, but the response was not received.

Examples:

- socket timeout after request send
- POS daemon crash after VAN request
- mobile payment provider delayed response
- network interruption after card approval

### 9.2 System Action

1. Move the payment intent to `TIMEOUT_UNKNOWN`.
2. Block automatic retry with a new payment intent.
3. Trigger inquiry using provider transaction key, terminal ID, order ID, amount, and time window.
4. If inquiry returns approved, validate and move to `CONFIRMED`.
5. If inquiry returns no transaction and provider guarantees no approval, move to `DECLINED` or `SAFE_TO_RETRY`.
6. If inquiry is unavailable, move to `MANAGER_REVIEW_REQUIRED` and include in reconciliation.

### 9.3 Manager Action

The manager must check the payment status screen before taking customer payment again.

Allowed manager actions:

- wait for inquiry result
- print or request last transaction slip from POS terminal
- check customer card/app approval notification only as supporting evidence
- escalate to HQ support when system remains unknown

Prohibited manager actions:

- force order completion without payment evidence
- ask for duplicate payment while state is `TIMEOUT_UNKNOWN`
- manually delete payment intent
- manually mark payment as failed without inquiry or evidence

## 10. Scenario C — External Success, Internal Order Failure

### 10.1 Condition

The external provider approved payment, but the internal order, table, KDS, or receipt workflow failed.

Examples:

- order DB write failed after payment success
- KDS ticket creation failed
- table mapping failed
- customer order screen crashed after approval

### 10.2 System Action

1. Store approval response and raw payload.
2. Move payment to `CONFIRMED_ORDER_REPAIR_PENDING` or `MANAGER_REVIEW_REQUIRED`.
3. Attempt order repair from payment intent snapshot.
4. If order repair succeeds, mark the case `CONFIRMED` and continue fulfillment.
5. If order repair fails, trigger reversal/cancel workflow if business policy requires automatic reversal.
6. Keep all approval, repair, and reversal events in audit log.

### 10.3 Manager Action

The manager must not tell the customer that payment failed when approval evidence exists.

The manager must either:

- allow the system to recreate the order from the payment intent, or
- contact HQ support for reversal if the order cannot be fulfilled.

## 11. Scenario D — Internal Order Success, External Payment Failure

### 11.1 Condition

The internal order was created or sent to kitchen, but the external payment result is confirmed failed or declined.

### 11.2 System Action

1. Move order to `PAYMENT_REQUIRED` or `PAYMENT_FAILED_ORDER_HOLD`.
2. Prevent KDS fulfillment when unpaid orders are not allowed by store policy.
3. If kitchen ticket already printed, show store manager alert.
4. Record payment failure response.
5. Allow controlled retry using a new payment intent linked to the same order.

### 11.3 Manager Action

The manager must confirm whether the order should be:

- re-paid by customer
- cancelled before preparation
- fulfilled as manager override
- transferred to postpaid/manual settlement mode

Manager override must require reason code.

## 12. Scenario E — Cancel/Reversal Timeout

### 12.1 Condition

The system requested cancel, void, reversal, or refund, but the cancel response is missing or unclear.

### 12.2 System Action

1. Move the payment to `REVERSAL_PENDING`.
2. Do not mark the customer as refunded.
3. Trigger cancel inquiry.
4. If cancel inquiry confirms reversal, move to `REVERSAL_CONFIRMED`.
5. If original approval remains active, retry reversal according to provider retry policy.
6. If provider blocks repeated reversal, escalate to manual review.
7. Include the case in end-of-day reconciliation.

### 12.3 Manager Action

The manager must not promise final refund completion until the system shows `REVERSAL_CONFIRMED` or HQ confirms external cancellation evidence.

Customer-facing message must distinguish:

- cancel request received
- cancel processing
- cancel confirmed
- refund settlement pending

## 13. Scenario F — Duplicate Approval or Duplicate Callback

### 13.1 Condition

The system receives more than one successful approval or callback for the same payment intent or order.

### 13.2 System Action

1. Compare idempotency key, approval number, provider trace ID, terminal ID, amount, and timestamp.
2. If duplicate of the same transaction, suppress duplicate state transition.
3. If separate approvals are detected, move to `DUPLICATE_APPROVAL_REVIEW`.
4. Keep the earliest valid approval as candidate confirmation.
5. Trigger reversal for extra approvals only after validation.
6. Notify manager and HQ support.

### 13.3 Manager Action

The manager must not refund or cancel manually from the terminal unless instructed by the system or HQ support.

## 14. Scenario G — Amount or Order Mismatch

### 14.1 Condition

External approval exists, but the amount, tax, discount, service charge, order ID, store ID, terminal ID, provider ID, or currency does not match the internal payment intent.

### 14.2 System Action

1. Move the payment to `MISMATCHED`.
2. Block order finalization.
3. Preserve raw request and response.
4. Run inquiry if supported.
5. Escalate to HQ support.
6. Decide repair, reversal, or manual accounting correction.

### 14.3 Manager Action

The manager must collect:

- customer receipt or app approval evidence if available
- terminal slip
- order number
- table number
- approximate time
- amount displayed to customer

The manager must not edit payment amount manually.

## 15. Scenario H — Provider Callback Conflict

### 15.1 Condition

External provider API response, webhook, POS callback, settlement file, or inquiry result conflicts.

Examples:

- API response timeout, webhook success
- POS response success, settlement file missing
- cancel API success, cancel inquiry failure
- app payment success notification, provider inquiry not found

### 15.2 System Action

1. Store all conflicting events as separate evidence records.
2. Assign precedence according to provider-specific authority matrix.
3. If no authority matrix resolves the conflict, move to `AMBIGUOUS`.
4. Escalate to HQ support or provider support.
5. Mark the case for reconciliation review.

## 16. Inquiry Requirement

A provider integration must not be production-approved unless at least one recovery inquiry path is available.

Minimum acceptable inquiry keys:

- internal payment intent ID
- provider transaction ID
- approval number
- terminal ID
- store ID / merchant ID
- amount
- transaction time window
- VAN trace ID / PG transaction ID when available

When a provider has no inquiry API, the integration must be marked as high-risk and require enhanced manual recovery SOP.

## 17. Manager Console Requirements

The manager console must show payment recovery cases in a way that prevents accidental money accidents.

Required display fields:

| Field | Required |
|---|---|
| Current recovery state | Yes |
| Safe customer message | Yes |
| Payment amount | Yes |
| Order number | Yes |
| Table or device source | Yes |
| External provider | Yes |
| Terminal ID | Yes |
| Approval number if known | Yes |
| Last inquiry result | Yes |
| Allowed manager actions | Yes |
| Prohibited actions | Yes |
| Escalation button | Yes |

The console must not expose dangerous buttons such as manual confirm, manual refund, or force failure without permission checks and reason capture.

## 18. Customer-Facing Message Control

Customer-facing messages must avoid unsafe conclusions.

| Internal State | Safe Customer Message |
|---|---|
| `TIMEOUT_UNKNOWN` | Payment result is being checked. Please do not pay again yet. |
| `INQUIRY_PENDING` | We are confirming the payment result with the payment provider. |
| `CONFIRMED` | Payment has been confirmed. |
| `DECLINED` | Payment was not approved. Please try another method. |
| `REVERSAL_PENDING` | Cancellation is being processed. |
| `REVERSAL_CONFIRMED` | Cancellation has been confirmed. |
| `AMBIGUOUS` | Staff is checking the payment result. |
| `MISMATCHED` | Staff assistance is required for this payment. |

## 19. Logging Requirements

Every recovery case must produce an immutable recovery log.

Minimum log fields:

```text
recovery_event_id
payment_intent_id
order_id
store_id
terminal_id
provider_type
provider_name
previous_state
next_state
error_type
raw_error_payload_hash
raw_response_payload_hash
inquiry_attempt_count
reversal_attempt_count
manager_id
manager_action_code
hq_support_case_id
reason_code
created_at
```

Raw payloads must be stored separately and linked by hash.

## 20. Reason Codes

Manager or HQ manual actions must require reason codes.

Required reason code categories:

- `CUSTOMER_SHOWED_APPROVAL_NOTICE`
- `TERMINAL_SLIP_CONFIRMED`
- `PROVIDER_INQUIRY_CONFIRMED`
- `DUPLICATE_PAYMENT_SUSPECTED`
- `ORDER_REPAIR_REQUIRED`
- `REVERSAL_REQUESTED`
- `PROVIDER_SUPPORT_ESCALATED`
- `SETTLEMENT_EXCEPTION`
- `MANUAL_ACCOUNTING_ADJUSTMENT_REQUIRED`
- `OTHER_WITH_DESCRIPTION`

## 21. Escalation Rules

Immediate HQ escalation is required when:

- payment amount mismatch occurs
- duplicate approval is detected
- provider inquiry conflicts with raw response
- cancel/reversal remains pending beyond allowed window
- terminal ID or merchant ID mismatch occurs
- settlement file does not include confirmed approval
- customer claims payment was charged but system has no approval
- staff attempts manual override on ambiguous payment

## 22. Store Staff Prohibited Actions

Store staff must not:

- delete a payment record
- modify approval amount
- manually invent an approval number
- mark a timeout as failed without inquiry
- ask the customer to pay again while state is unknown
- promise refund completion before reversal confirmation
- complete an unpaid order unless manager override policy allows it
- directly call external provider support without recording case ID

## 23. HQ Support Responsibilities

HQ support must:

1. Review raw request, raw response, inquiry, and reversal logs.
2. Compare internal ledger against provider evidence.
3. Contact provider support when required.
4. Decide final state transition.
5. Record reason code and evidence reference.
6. Mark case for reconciliation when money movement is not fully resolved.

## 24. Recovery SLA

| Severity | Condition | Initial Action Target | Final Resolution Target |
|---|---|---:|---:|
| P0 | Duplicate charge or high-value mismatch | Immediate | Same business day |
| P1 | Timeout unknown with customer waiting | Immediate | Within store operation window |
| P2 | Reversal pending | Same business day | According to provider settlement window |
| P3 | Settlement-only mismatch | Next reconciliation cycle | Before accounting close |
| P4 | Non-money metadata mismatch | Next business day | Before monthly close |

## 25. Audit Evidence

Each recovery case must preserve:

- payment intent snapshot
- external request payload hash
- external response payload hash
- inquiry request and response
- reversal request and response
- manager action log
- customer-facing message log
- order state transition log
- reconciliation result
- final closeout decision

## 26. Completion Criteria

A payment recovery case may be closed only when one of the following is true:

1. payment is confirmed and matched to order
2. payment is confirmed and order repair is completed
3. payment is reversed and reversal evidence is stored
4. provider confirms no payment occurred and retry is safe
5. reconciliation resolves the discrepancy
6. HQ closes the case with documented provider evidence and accounting treatment

## 27. Handoff

This runbook hands off to:

- `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`
- `70180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md`
- `70190_Index_POS_VAN_PG_External_Payment_Integration_Closeout_And_Handoff.md`

## 28. Governance Note

This runbook must be reviewed whenever a new external payment provider, POS vendor, VAN provider, PG provider, simple payment provider, delivery app payment channel, or membership/coupon payment adjustment integration is added.

No provider integration may bypass this recovery runbook.
