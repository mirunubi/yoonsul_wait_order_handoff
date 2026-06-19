# 070330_Runbook_External_Payment_Inquiry_Request_Retry_Escalation_And_Manager_Action.md

## 1. Purpose

This runbook defines the controlled operational procedure for requesting external payment inquiry, retrying unresolved inquiry attempts, escalating provider-side uncertainty, and guiding manager action when payment state is UNKNOWN, AMBIGUOUS, INQUIRY_PENDING, CANCEL_PENDING, REVERSAL_PENDING, or RECONCILIATION_EXCEPTION.

This document belongs to the 70300 External Payment Inquiry, Unknown State, and Recovery Governance lane and must be read together with:

- [70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md](./70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md)
- [70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md](./70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md)
- [70320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md](./70320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md)
- [70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md](./70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md)
- [70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md](./70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md)
- [70270_Runbook_External_RPC_API_Webhook_Late_Event_Conflict_Quarantine_And_Replay_Action.md](./70270_Runbook_External_RPC_API_Webhook_Late_Event_Conflict_Quarantine_And_Replay_Action.md)
- [75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md](./75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md)

## 2. Scope

This runbook applies to external payment inquiry and recovery involving:

- POS approval inquiry
- POS cancel inquiry
- VAN transaction inquiry
- PG payment inquiry
- PG cancel/refund inquiry
- last transaction inquiry
- receipt/slip lookup
- terminal-based inquiry
- approval-number-based inquiry
- provider dashboard/manual verification
- settlement-file-based confirmation
- manager-level customer claim handling

This runbook does not define the internal accounting ledger model. Ledger posting and double-entry settlement controls are handled by the 75000 Payment Integrity Architecture lane.

## 3. Core Principle

External inquiry is not a convenience feature. It is a required recovery control.

When payment state is unknown, the system must not decide the final payment result from timeout, UI state, operator assumption, customer screen capture, or POS screen message alone.

Final state may be changed only after inquiry evidence passes validation and is recorded in the payment evidence ledger.

## 4. Trigger Conditions

The inquiry runbook must start when any of the following occurs:

| Trigger | Required Initial State |
|---|---|
| POS/VAN/PG request timeout | TIMEOUT_UNKNOWN |
| response body missing after request sent | RESPONSE_LOST |
| approval response has missing approval number | AMBIGUOUS |
| cancel request timed out | CANCEL_UNKNOWN |
| provider webhook conflicts with synchronous response | EVENT_CONFLICT |
| order succeeded but payment confirmation is missing | PAYMENT_UNKNOWN_ORDER_HOLD |
| payment succeeded but order creation failed | PAYMENT_CONFIRMED_ORDER_FAILED |
| duplicate approval suspected | DUPLICATE_REVIEW |
| customer claims payment was charged but internal ledger shows unpaid | CUSTOMER_CLAIM_REVIEW |
| daily closing finds unmatched external transaction | RECONCILIATION_EXCEPTION |

## 5. Prohibited Actions

During UNKNOWN or AMBIGUOUS state, operators and automated workers must not:

1. mark the order as fully paid without validated inquiry evidence;
2. ask the customer to pay again without checking duplicate approval risk;
3. manually delete the payment intent;
4. manually overwrite approval number or amount;
5. issue refund/cancel from an unverified approval record;
6. change order status to completed based only on a customer screenshot;
7. close the incident without inquiry attempt evidence;
8. suppress provider error logs;
9. replay the original payment request without idempotency guard;
10. treat timeout as payment failure.

## 6. Inquiry Evidence Inputs

The inquiry operator or automated inquiry worker must collect the best available identifiers in this priority order:

| Priority | Identifier |
|---:|---|
| 1 | payment_intent_id |
| 2 | idempotency_key |
| 3 | provider_transaction_id / paymentKey / pg_tid |
| 4 | VAN approval number |
| 5 | terminal_id / TID |
| 6 | merchant_id |
| 7 | order_id |
| 8 | amount |
| 9 | approved_at or request time window |
| 10 | card masked number or issuer/acquirer metadata where legally allowed |

Sensitive card data must never be collected beyond allowed masked/tokenized fields.

## 7. Standard Inquiry Flow

### 7.1 Automated First Inquiry

When UNKNOWN is detected, the system must:

1. freeze customer-facing final state;
2. mark payment intent as `INQUIRY_PENDING`;
3. record the unknown trigger and raw error;
4. create an inquiry job with idempotency key;
5. call the provider inquiry endpoint or provider adapter;
6. store raw inquiry response;
7. map provider response to canonical inquiry result;
8. validate amount, merchant, terminal, order, and timestamp;
9. transition state according to the result matrix.

### 7.2 Inquiry Result Matrix

| Inquiry Result | State Transition | Required Action |
|---|---|---|
| approval confirmed and data matches | CONFIRMED | finalize payment and release order flow |
| approval confirmed but order failed | PAYMENT_CONFIRMED_ORDER_FAILED | start compensation or order regeneration flow |
| approval not found but within provider creation delay window | INQUIRY_PENDING | retry after delay |
| approval not found after delay threshold | DECLINED_OR_NOT_APPROVED_REVIEW | manager review before failure confirmation |
| cancel confirmed | CANCELLED | update cancellation ledger |
| cancel not found but original approval exists | REVERSAL_PENDING | retry cancel/reversal flow |
| duplicate approvals found | DUPLICATE_REVIEW | hold order and escalate |
| amount mismatch | PAYMENT_MISMATCHED | quarantine and escalate |
| merchant/terminal mismatch | SECURITY_REVIEW | quarantine and escalate |
| provider unavailable | INQUIRY_RETRY_WAIT | retry with backoff |
| provider manual confirmation required | PROVIDER_ESCALATION_PENDING | open vendor case |

## 8. Retry Policy

Inquiry retry must be bounded, observable, and evidence-backed.

| Retry Window | Retry Behavior |
|---|---|
| 0~1 minute | short delayed retry for provider processing lag |
| 1~5 minutes | exponential backoff inquiry retry |
| 5~30 minutes | provider inquiry + manager dashboard watch |
| 30~120 minutes | provider escalation case required |
| after daily close | reconciliation exception required |

Retry must stop when:

- confirmed result is validated;
- cancel/reversal is confirmed;
- provider returns final decline/not-approved with sufficient evidence;
- duplicate/mismatch/security condition is detected;
- manual provider case is opened and the incident is transferred to vendor escalation workflow.

## 9. Manager Action Flow

When the automated path cannot resolve the case, the store manager must follow this procedure:

1. open the payment recovery screen;
2. search by order number, table number, payment time, and amount;
3. check internal payment intent status;
4. check external inquiry result if available;
5. check POS/VAN/PG dashboard or terminal last transaction where authorized;
6. do not request additional payment until duplicate charge risk is ruled out;
7. issue customer-facing temporary explanation using approved wording;
8. escalate to provider support if inquiry remains unresolved;
9. attach all evidence to the incident packet;
10. close only after final state is reconciled.

## 10. Customer Communication Boundary

Permitted customer communication:

- “결제 상태를 확인 중입니다.”
- “중복 결제 방지를 위해 결제망 조회를 먼저 진행하겠습니다.”
- “확인 전에는 재결제를 요청드리지 않겠습니다.”
- “승인 여부 확인 후 주문 진행 또는 취소 처리를 안내드리겠습니다.”

Prohibited customer communication:

- “결제 실패입니다” when timeout occurred;
- “다시 결제하세요” before inquiry;
- “돈은 안 빠졌을 겁니다” without provider evidence;
- “취소됐습니다” before cancel inquiry confirms cancellation;
- “카드사 문제입니다” without provider escalation evidence.

## 11. Provider Escalation Procedure

Provider escalation is required when:

- inquiry endpoint is unavailable beyond retry threshold;
- provider response is internally contradictory;
- approval exists externally but cannot be mapped internally;
- cancellation status cannot be confirmed;
- duplicate approval is suspected;
- settlement file later conflicts with real-time inquiry result;
- customer claim includes card issuer evidence not visible internally.

The escalation packet must include:

```text
incident_id
payment_intent_id
order_id
store_id
terminal_id
merchant_id
provider_name
request_timestamp
raw_request_hash
raw_response_hash
inquiry_attempts
last_inquiry_result
expected_amount
external_amount
approval_number_if_any
provider_transaction_id_if_any
customer_claim_reference_if_any
operator_id
manager_id
```

## 12. Manual Override Control

Manual override is allowed only when all conditions are met:

1. automated inquiry has failed or is unavailable;
2. provider dashboard or provider support gives verifiable evidence;
3. manager approval is recorded;
4. audit evidence packet is attached;
5. finance/reconciliation owner is notified if money movement is affected;
6. the override reason is selected from an approved reason code registry;
7. the override is marked for end-of-day reconciliation review.

Manual override must never delete raw evidence, inquiry attempts, or original payment intent.

## 13. State Closure Rules

An incident may be closed only when one of the following final conditions is reached:

| Final Condition | Required Evidence |
|---|---|
| payment confirmed | approval inquiry + validation pass |
| payment declined/not approved | provider not-approved evidence + no settlement match |
| payment cancelled | cancel inquiry confirmation |
| payment refunded manually | refund evidence + customer account/payment record + manager approval |
| duplicate resolved | retained approval + cancelled duplicate evidence |
| reconciliation corrected | settlement match + adjustment ledger entry |

## 14. Audit Requirements

Every inquiry action must produce an audit trail containing:

- who or what initiated inquiry;
- why inquiry was initiated;
- inquiry channel used;
- request payload hash;
- raw response payload hash;
- canonical result;
- previous state;
- next state;
- retry count;
- escalation target;
- manager action if any;
- customer communication if any;
- final closure reason.

## 15. Relationship To 75000 Payment Integrity Architecture

This runbook executes the operational recovery side of payment integrity.

The following topics are handed off to the 75000 lane:

- idempotency key storage and replay protection;
- delayed net cancel architecture;
- Saga compensation sequencing;
- transactional outbox event durability;
- double-entry ledger posting;
- daily settlement reconciliation;
- provider settlement mismatch correction;
- self-healing payment recovery workers.

## 16. Completion Criteria

This runbook is complete when:

- UNKNOWN state has a mandatory inquiry path;
- retries are bounded and logged;
- manager action is controlled;
- customer communication is constrained;
- provider escalation packet is defined;
- manual override is audit-bound;
- closure requires evidence;
- handoff to reconciliation and 75000 architecture is explicit.

## 17. Next Document

Next:

- [70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md](./70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md)
