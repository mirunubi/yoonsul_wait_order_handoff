# 070560_Audit_External_Cancel_Refund_Reversal_Evidence_Manager_Approval_And_Customer_Notice_Log.md

## 1. Purpose

This audit document defines the evidence, approval, customer notice, and accounting trace requirements for external cancel, refund, reversal, net cancel, and compensation events in the External Integration Control Plane.

The purpose is to ensure that every money-returning or money-reversing action is reproducible, explainable, tamper-evident, and reconcilable against internal ledgers, external provider responses, customer notices, and settlement records.

## 2. Scope

This document applies to all external cancellation and recovery flows involving:

- POS cancel responses
- VAN cancel and reversal responses
- PG refund and cancel APIs
- Simple payment refund responses
- Cross-border refund and reversal responses
- Net cancel recovery actions
- Compensation transactions
- Manual refund alternatives
- Manager-approved exception handling
- Customer notice logs
- Accounting hold and release logs

## 3. Parent And Related Documents

- Parent Index: `70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md`
- Previous: `70550_Matrix_External_Cancel_Refund_Reversal_Failure_Mode_Action_And_Escalation_Map.md`
- Next: `70570_Register_External_Cancel_Refund_Reversal_Exception_Gap_And_Open_Issue.md`
- Related: `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`
- Related: `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md`
- Related: `70370_Audit_External_Payment_Inquiry_Recovery_Evidence_And_Manager_Decision_Log.md`
- Related: `70470_Audit_External_Response_Correction_Evidence_Manager_Approval_And_Replay_Log.md`
- Related: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

A cancel, refund, reversal, or compensation event must not be treated as complete merely because an external provider returned a success response.

Completion requires:

1. Original payment evidence exists.
2. Cancel/refund/reversal request evidence exists.
3. External response raw payload is preserved.
4. Internal state transition is validated.
5. Customer notice is recorded where required.
6. Manager approval exists where required.
7. Accounting hold/release state is traceable.
8. Settlement reconciliation confirms final money movement or exception status.

## 5. Evidence Categories

| Evidence Category | Required Contents | Purpose |
|---|---|---|
| Original Payment Evidence | payment_intent_id, approval_no, provider_transaction_id, amount, timestamp | Prove the transaction being reversed |
| Cancel/Refund Request Evidence | request payload, idempotency key, requester, reason code | Prove what was requested |
| External Response Evidence | raw response payload, response code, message, provider trace id | Prove what provider returned |
| Inquiry Evidence | inquiry request/response, retrieved status, timestamp | Prove status confirmation |
| Manager Approval Evidence | approver, approval reason, timestamp, scope | Prove human authorization |
| Customer Notice Evidence | notice channel, message key, timestamp, recipient | Prove customer communication |
| Accounting Evidence | hold id, release id, ledger journal id, reconciliation id | Prove financial treatment |
| Tamper Evidence | raw hash, normalized hash, hash chain pointer | Prove immutability |

## 6. Mandatory Audit Fields

Every cancel/refund/reversal audit record must contain:

```text
cancel_refund_audit_id
payment_intent_id
order_id
store_id
provider_id
provider_type
original_payment_reference
cancel_refund_request_id
reversal_request_id
compensation_id
idempotency_key
request_type
request_reason_code
request_amount
request_currency
requester_actor_type
requester_actor_id
manager_approval_id
external_raw_request_hash
external_raw_response_hash
external_response_code
external_response_message
provider_trace_id
inquiry_reference_id
customer_notice_id
accounting_hold_id
ledger_journal_id
reconciliation_status
audit_status
created_at
updated_at
```

## 7. Manager Approval Requirements

Manager approval is mandatory when any of the following conditions apply:

- refund method differs from original payment method
- manual customer return is required
- refund amount differs from original approved amount
- partial cancel is requested after settlement
- reversal is triggered by unknown or ambiguous payment state
- duplicate approval is being corrected
- customer claim exists
- provider response is incomplete
- accounting hold must be released manually
- legal or dispute packet must be prepared

Manager approval must include:

```text
manager_approval_id
approval_type
approved_action
approval_reason
risk_acknowledgement
approved_by
approved_at
linked_evidence_ids
```

## 8. Customer Notice Log

Customer-facing notices must be logged using message keys, not hardcoded free text.

Required fields:

```text
customer_notice_id
order_id
payment_intent_id
notice_type
notice_channel
message_key
localized_language
recipient_masked
sent_at
delivery_status
operator_id
```

Customer notices must not claim final refund completion unless the refund or reversal state has passed the relevant validation and evidence gates.

Allowed notice states:

- refund request received
- refund processing
- refund completed
- refund delayed pending provider confirmation
- manual refund required
- manager review in progress
- settlement reconciliation pending

## 9. Accounting Hold And Release Evidence

When external cancellation or refund status is not fully confirmed, the affected order/payment must be placed under accounting hold.

Required hold fields:

```text
accounting_hold_id
payment_intent_id
hold_reason
hold_amount
hold_currency
hold_started_at
hold_released_at
release_reason
linked_reconciliation_id
linked_manager_approval_id
```

Accounting hold must not be released solely by operator judgment. Release requires either:

1. validated external provider confirmation,
2. reconciliation confirmation,
3. approved manual compensation evidence, or
4. finance manager override with evidence packet.

## 10. Tamper Check Requirements

The following payloads must be hashed and retained:

- original payment raw response
- cancel/refund/reversal raw request
- cancel/refund/reversal raw response
- inquiry response
- customer notice payload
- manager approval record
- accounting hold/release record

Hash records must include:

```text
hash_algorithm
payload_hash
hash_created_at
previous_hash_pointer
storage_location
retention_class
```

## 11. Audit Status Model

| Status | Meaning |
|---|---|
| AUDIT_PENDING | Evidence capture started but incomplete |
| AUDIT_COMPLETE | Required evidence exists and links are valid |
| AUDIT_HOLD | Evidence incomplete or contradiction exists |
| AUDIT_REVIEW_REQUIRED | Manager or finance review required |
| AUDIT_RECONCILIATION_PENDING | Waiting for settlement or provider reconciliation |
| AUDIT_EXCEPTION | Evidence conflict or missing provider confirmation |
| AUDIT_CLOSED | Fully reconciled and closed |

## 12. Prohibited Actions

The system and operators must not:

- delete raw refund or reversal responses
- overwrite original provider response payloads
- mark refund complete without external or accounting confirmation
- release accounting hold without evidence
- manually edit provider response code
- use free-text customer notice without message key
- process a second refund without idempotency and duplicate checks
- close a customer claim without linked refund evidence

## 13. Closeout Criteria

This audit control is considered satisfied only when:

1. All cancel/refund/reversal events have raw request and response hashes.
2. Manager approvals are linked where required.
3. Customer notices are logged with message keys.
4. Accounting hold/release records are traceable.
5. Provider response, inquiry result, and internal ledger state are aligned.
6. Exceptions are registered in the relevant open issue register.
7. Final reconciliation status is recorded.

## 14. Handoff

This document hands off to:

`70570_Register_External_Cancel_Refund_Reversal_Exception_Gap_And_Open_Issue.md`

The next document must maintain unresolved provider limitations, refund method gaps, manual compensation risks, and settlement confirmation gaps as a controlled register.
