# 070520_Policy_External_Reversal_Net_Cancel_And_Compensation_Request_Control.md

## Document Control

- Document Number: 70520
- Document Type: Policy
- Domain: External Integration Control Plane / Cancel Refund Reversal And Compensation Control
- Parent Index: 70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md
- Previous: 70510_Policy_External_Cancel_Refund_State_Authority_And_Request_Eligibility_Control.md
- Next: 70530_Policy_External_Refund_Method_Limit_Partial_Cancel_And_Customer_Return_Control.md
- Related: 70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md
- Related: 70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md
- Related: 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md

## 1. Purpose

This policy defines how external reversal, net cancel, and compensation requests are controlled when payment, order, settlement, or provider state becomes inconsistent.

The purpose is to prevent money-state corruption by ensuring that system-healing transactions are never treated as ordinary customer refunds, never executed without evidence, and never repeated without idempotency control.

## 2. Scope

This policy applies to external payment-related recovery actions involving:

- POS approval reversal
- VAN net cancel
- PG cancel after uncertain approval
- delayed cancel after timeout
- compensation transaction after partial failure
- refund fallback after provider cancel is unavailable
- duplicated approval correction
- order failure after payment success
- payment success after internal timeout
- cancel timeout or cancel unknown state

## 3. Core Principle

A reversal or net cancel is not a customer-service refund.

It is a system recovery action used to restore financial integrity after an incomplete, ambiguous, duplicated, or conflicting transaction.

Therefore:

- it must be linked to an original payment intent
- it must be linked to an observed inconsistency
- it must use a dedicated recovery idempotency key
- it must preserve provider request and response payloads
- it must not erase the original approval event
- it must produce an auditable compensation record

## 4. Classification

| Type | Meaning | Trigger | Owner |
|---|---|---|---|
| Customer Cancel | customer or store cancels a valid order/payment | normal business request | Store / Customer Support |
| Refund | money return after confirmed payment | return, complaint, policy exception | Store / Finance |
| Reversal | technical cancel of an approval before final settlement | partial failure or invalid approval | Payment Integrity Plane |
| Net Cancel | network/system cancel used after timeout or incomplete transaction | timeout unknown, lost response | Payment Integrity Plane |
| Compensation | opposite transaction that offsets a completed local step | Saga or distributed partial failure | Orchestrator / Recovery Worker |
| Manual Return | provider cancel unavailable, money returned outside provider flow | legal/policy/provider limit | Finance / Manager |

## 5. Eligibility Requirements

A reversal, net cancel, or compensation request may only be created when all required evidence exists:

1. Original payment intent exists.
2. Original external request payload exists or request hash exists.
3. The transaction is not already settled as final successful and fulfilled unless policy allows reversal.
4. Inquiry was attempted when external state is unknown.
5. The current state is one of the approved recovery states.
6. No active recovery request with the same recovery key is already in progress.
7. The request is linked to a failure mode, incident, or reconciliation exception.

## 6. Approved Source States

| Source State | Allowed Recovery Action | Notes |
|---|---|---|
| TIMEOUT_UNKNOWN | delayed inquiry, then net cancel if external approval is confirmed but internal completion failed | never mark failed immediately |
| AMBIGUOUS | inquiry and manual review before action | no blind cancel |
| PAYMENT_CONFIRMED_ORDER_FAILED | order replay or reversal depending on fulfillment possibility | manager rule required |
| PAYMENT_DUPLICATED | retain one valid payment, reverse duplicates | must compare approval numbers |
| CANCEL_TIMEOUT_UNKNOWN | cancel inquiry before retry | avoid double cancel |
| PROVIDER_RESPONSE_MISMATCHED | quarantine, inquiry, escalation | no automatic state release |
| RECONCILIATION_EXCEPTION | finance review and provider evidence check | settlement impact exists |

## 7. Prohibited Actions

The system and operators must not:

- issue immediate net cancel solely because a request timed out
- issue repeated cancel requests without idempotency key control
- mark customer-facing payment as failed while external state is unknown
- delete original approval records after reversal
- overwrite approval payload with cancel payload
- treat provider Not Found response as proof of no payment without inquiry policy
- reverse a payment that has already been compensated by another recovery action
- manually return money without finance evidence and manager approval

## 8. Delayed Net Cancel Control

When timeout occurs, the recovery process must avoid immediate blind net cancel.

Required sequence:

1. Record timeout event.
2. Set payment state to TIMEOUT_UNKNOWN.
3. Place recovery candidate into delayed recovery queue.
4. Wait configured provider-specific delay window.
5. Execute inquiry if supported.
6. If external approval is confirmed and internal completion failed, issue net cancel or compensation.
7. If external approval is not found, keep the record in inquiry retry or reconciliation watch until release criteria are met.

## 9. Recovery Idempotency Key

Every recovery request must have a deterministic recovery idempotency key.

Recommended pattern:

```text
recovery:{provider}:{store_id}:{payment_intent_id}:{original_request_id}:{recovery_type}:{attempt_group}
```

The key must be used for:

- external provider request header or payload if supported
- internal recovery ledger deduplication
- replay protection
- audit linkage
- manager review evidence

## 10. Compensation Ledger

A compensation action must create a separate ledger entry.

It must never mutate the original payment as though it never occurred.

Minimum fields:

```text
compensation_id
original_payment_intent_id
original_approval_id
recovery_type
reason_code
source_failure_mode
requested_amount
approved_amount
provider_cancel_id
provider_response_code
idempotency_key
manager_approval_id
status
created_at
completed_at
raw_request_hash
raw_response_hash
```

## 11. Request State Machine

| State | Meaning |
|---|---|
| RECOVERY_CANDIDATE | failure detected, not yet eligible |
| INQUIRY_REQUIRED | external state must be checked |
| DELAY_WAITING | waiting for provider-side record stabilization |
| REVERSAL_REQUESTED | reversal/net cancel sent |
| REVERSAL_CONFIRMED | provider confirmed reversal |
| REVERSAL_UNKNOWN | reversal request result unknown |
| COMPENSATION_REQUIRED | technical reversal unavailable, compensation needed |
| MANUAL_RETURN_REQUIRED | provider flow cannot return money |
| CLOSED_RECONCILED | recovery verified by reconciliation |

## 12. Evidence Requirements

Each recovery action must preserve:

- original payment intent
- original external request payload or hash
- original external response payload or timeout evidence
- inquiry request and response
- recovery request and response
- provider trace id
- approval number or cancel number if present
- manager approval when manual action is used
- customer-facing communication log when customer impact exists
- reconciliation follow-up result

## 13. Escalation

Escalation is required when:

- provider response is inconsistent across inquiry and cancel results
- recovery amount differs from original amount
- partial cancel is not supported but partial fulfillment occurred
- customer claims card was charged but provider inquiry returns not found
- duplicate approval cannot be safely paired
- settlement file later contradicts recovery result
- provider cancel deadline has passed

## 14. Relationship To 75000 Payment Integrity Architecture

This policy defines the operational control of recovery requests.

The 75000 Payment Integrity Architecture lane defines the deeper mechanisms that support this policy, including:

- idempotency persistence
- delayed recovery queues
- net cancel workers
- Saga compensation
- transactional outbox
- recovery event replay
- double-entry ledger impact
- reconciliation proof

## 15. Closeout Criteria

This policy is complete when:

- reversal, net cancel, and compensation are separated from normal refunds
- recovery eligibility states are defined
- delayed net cancel control is mandatory
- recovery idempotency keys are mandatory
- original approval events are preserved
- compensation ledger entries are required
- prohibited actions are explicit
- escalation triggers are defined
