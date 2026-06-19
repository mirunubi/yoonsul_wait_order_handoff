# 070370_Audit_External_Payment_Inquiry_Recovery_Evidence_And_Manager_Decision_Log.md

## 1. Purpose

This document defines the audit evidence and manager decision logging requirements for external payment inquiry, unknown-state recovery, manual review, hold release, reversal escalation, and customer-facing recovery decisions.

The goal is to ensure that every recovery decision made after an external payment enters `UNKNOWN`, `AMBIGUOUS`, `INQUIRY_PENDING`, `MANUAL_REVIEW`, or `HOLD` can be reconstructed later from immutable evidence.

This document belongs to the `70300` External Payment Inquiry, Unknown State, and Recovery Governance lane.

## 2. Scope

This audit applies to payment recovery involving:

- POS payment inquiry
- VAN payment inquiry
- PG payment inquiry
- simple payment provider inquiry
- approval status inquiry
- cancel status inquiry
- last transaction inquiry
- settlement file verification
- delayed confirmation
- delayed cancellation
- duplicate approval review
- payment success but order failure
- order success but payment unknown
- customer claim recovery
- manager override decisions

## 3. Parent And Related Documents

- Parent index: `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md`
- Detection policy: `70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md`
- Inquiry requirement: `70320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md`
- Inquiry runbook: `70330_Runbook_External_Payment_Inquiry_Request_Retry_Escalation_And_Manager_Action.md`
- Inquiry result validation: `70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md`
- Recovery decision policy: `70350_Policy_External_Payment_Recovery_Decision_Auto_Release_Manual_Review_And_Hold_Control.md`
- Recovery decision matrix: `70360_Matrix_External_Payment_Recovery_Decision_State_Evidence_And_Action_Map.md`
- External event audit: `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md`
- Payment response audit: `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`
- Payment integrity root: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Audit Principle

No payment recovery action may be treated as complete unless the following can be proven:

1. why the payment entered an abnormal or unknown state,
2. which inquiry channels were used,
3. what raw external evidence was received,
4. how the evidence was validated,
5. who or what decided the recovery outcome,
6. whether customer-facing communication was issued,
7. whether settlement or ledger reconciliation later confirmed the decision.

If any of these elements is missing, the recovery record remains audit-incomplete.

## 5. Required Audit Log Entities

### 5.1 Inquiry Case Log

Each unknown payment must create or attach to an inquiry case.

Required fields:

- `inquiry_case_id`
- `payment_intent_id`
- `order_id`
- `store_id`
- `terminal_id`
- `provider_type`
- `provider_name`
- `unknown_state_code`
- `unknown_detected_at`
- `detected_by`
- `trigger_event_id`
- `current_payment_state`
- `current_order_state`
- `customer_claim_id`, if applicable
- `case_opened_at`
- `case_closed_at`, if applicable
- `case_close_reason`

### 5.2 Inquiry Request Log

Every inquiry request must be stored separately from the inquiry case.

Required fields:

- `inquiry_request_id`
- `inquiry_case_id`
- `inquiry_type`
- `request_channel`
- `request_payload_raw`
- `request_payload_hash`
- `requested_by`
- `request_idempotency_key`
- `provider_reference_id`
- `sent_at`
- `timeout_at`
- `retry_sequence`
- `transport_result`
- `acknowledgement_result`

### 5.3 Inquiry Response Log

Every inquiry response must be stored as raw evidence before interpretation.

Required fields:

- `inquiry_response_id`
- `inquiry_request_id`
- `inquiry_case_id`
- `response_payload_raw`
- `response_payload_hash`
- `provider_response_code`
- `provider_response_message`
- `canonical_response_code`
- `approval_number`
- `cancel_number`
- `transaction_id`
- `van_trace_id`
- `pg_transaction_id`
- `approved_amount`
- `cancelled_amount`
- `approved_at`
- `cancelled_at`
- `received_at`
- `signature_validation_result`
- `timestamp_validation_result`
- `replay_validation_result`

### 5.4 Recovery Decision Log

Every recovery decision must be stored as a separate decision record.

Required fields:

- `recovery_decision_id`
- `inquiry_case_id`
- `decision_type`
- `previous_payment_state`
- `next_payment_state`
- `previous_order_state`
- `next_order_state`
- `decision_basis`
- `evidence_reference_list`
- `auto_decision_rule_id`, if automated
- `manager_user_id`, if manual
- `approval_role`
- `decision_at`
- `customer_impact_level`
- `financial_impact_level`
- `requires_reconciliation_followup`
- `requires_vendor_escalation`

### 5.5 Manager Decision Log

Manual recovery must capture manager intent, authority, and reason.

Required fields:

- `manager_decision_id`
- `recovery_decision_id`
- `manager_user_id`
- `manager_role`
- `store_id`
- `decision_action`
- `decision_reason_code`
- `decision_reason_text`
- `evidence_reviewed`
- `customer_present_flag`
- `customer_claim_flag`
- `override_flag`
- `override_reason`
- `second_approval_required_flag`
- `second_approver_user_id`
- `decision_timestamp`

## 6. Recovery Decision Types

Allowed decision types:

| Decision Type | Meaning | Audit Requirement |
|---|---|---|
| `AUTO_RELEASE_CONFIRMED` | Inquiry proves successful payment and internal validation passes | inquiry response + validation result |
| `AUTO_RELEASE_DECLINED` | Inquiry proves external payment did not succeed | inquiry response + no approval evidence |
| `MANUAL_RELEASE_CONFIRMED` | Manager confirms successful payment based on evidence | manager decision + evidence list |
| `MANUAL_HOLD_CONTINUE` | Evidence insufficient; hold remains | reason code + next review time |
| `REVERSAL_REQUIRED` | External success but internal process failed | reversal case link |
| `CANCEL_CONFIRMED` | External cancellation verified | cancel evidence |
| `REFUND_REQUIRED` | API cancel not possible; refund workflow required | refund reason + customer refund method control |
| `VENDOR_ESCALATION_REQUIRED` | Provider evidence is missing or contradictory | vendor ticket reference |
| `RECONCILIATION_EXCEPTION` | Must be resolved by settlement or ledger reconciliation | reconciliation case link |
| `FRAUD_OR_TAMPER_REVIEW` | Suspicious payload, signature, or trace inconsistency | security incident link |

## 7. Evidence Chain Requirements

The evidence chain must include:

1. original payment request evidence,
2. original external response evidence,
3. unknown detection evidence,
4. inquiry request evidence,
5. inquiry response evidence,
6. validation result evidence,
7. recovery decision evidence,
8. manager approval evidence if manual,
9. customer communication evidence if issued,
10. reconciliation confirmation evidence if available.

Each item must be linked through immutable identifiers and raw payload hashes.

## 8. Customer Communication Log

If a customer is informed about the status of an unknown or recovered payment, the communication must be logged.

Required fields:

- `customer_communication_id`
- `inquiry_case_id`
- `customer_id`, if known
- `communication_channel`
- `message_template_id`
- `message_language`
- `message_sent_at`
- `message_body_hash`
- `operator_user_id`
- `communication_reason`
- `customer_acknowledgement_result`

Customer-facing messages must not claim final success, failure, cancellation, or refund until the relevant state has been released by policy.

## 9. Prohibited Audit Practices

The following practices are prohibited:

- closing an inquiry case without raw external evidence,
- overwriting raw inquiry responses,
- storing only interpreted status without provider payload,
- using screenshots as the only payment evidence,
- approving manager override without reason code,
- editing prior manager decision logs,
- deleting failed inquiry attempts,
- treating vendor verbal confirmation as final proof,
- releasing unknown state based only on customer bank app screen,
- removing disputed payment records after refund.

## 10. Tamper Check Requirements

All inquiry and recovery audit records must support tamper detection.

Minimum controls:

- raw payload hash,
- canonical payload hash,
- decision record hash,
- append-only update history,
- actor identity,
- timestamp source,
- related event id,
- evidence packet id,
- immutable storage or WORM-compatible archive for high-risk cases.

## 11. Reconciliation Follow-Up

Some inquiry recovery decisions are temporary until reconciliation confirms them.

Reconciliation follow-up is required when:

- provider inquiry and internal ledger disagree,
- inquiry response is incomplete,
- approval exists without matching order,
- cancellation exists without matching approval,
- manager override was used,
- customer claim was involved,
- refund was processed outside normal API cancellation,
- settlement file has not yet arrived.

The case may be operationally closed but must remain financially pending until reconciliation closes the evidence chain.

## 12. Reporting Requirements

Daily inquiry recovery audit reports must include:

- number of unknown cases opened,
- number of cases auto-released,
- number of manual review cases,
- number of reversal cases,
- number of refund-required cases,
- number of vendor escalation cases,
- number of reconciliation exception cases,
- average time to inquiry response,
- average time to recovery decision,
- unresolved high-risk cases,
- repeated provider failure patterns.

## 13. Closeout Criteria

An inquiry recovery audit case may be closed only when:

1. all required raw evidence is preserved,
2. all inquiry attempts are logged,
3. final recovery decision is recorded,
4. manager decision is recorded if manual,
5. customer communication is recorded if issued,
6. reconciliation follow-up is either closed or explicitly linked,
7. tamper check metadata exists,
8. no unresolved financial mismatch remains unassigned.

## 14. Handoff

This document hands off to:

- `70380_Register_External_Payment_Inquiry_Recovery_Exception_Gap_And_Open_Issue.md`
- `70390_Index_External_Payment_Inquiry_Unknown_State_Recovery_Closeout_And_Handoff.md`
- `70500_Index_External_Cancel_Refund_Reversal_And_Compensation_Control.md`
- `70600_Index_External_Settlement_Reconciliation_Deposit_Fee_And_Ledger_Audit.md`
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`
