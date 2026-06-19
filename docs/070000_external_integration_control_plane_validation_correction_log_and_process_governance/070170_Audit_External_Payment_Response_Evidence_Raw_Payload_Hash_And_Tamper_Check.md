# 070170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md

## 1. Purpose

This document defines the audit evidence, raw payload preservation, hash control, tamper check, and dispute trace requirements for external payment responses received from POS, VAN, PG, card acquirer, simple payment provider, cross-border payment gateway, or related external payment infrastructure.

The purpose of this audit control is to ensure that external payment responses are not treated as disposable runtime messages. Every response that can affect money movement, order confirmation, cancellation, refund, settlement, customer claim, or accounting must be preserved as verifiable evidence.

This document belongs to the External Integration Control Plane 70000 lane and supports the POS/VAN/PG external payment governance set opened by 70100.

## 2. Scope

This audit applies to all external payment-related inbound data, including but not limited to:

- POS payment approval response
- POS payment decline response
- VAN approval response
- VAN cancel response
- PG confirm response
- PG webhook or callback
- simple payment response such as KakaoPay, NaverPay, TossPay, Samsung Pay routed response
- Alipay / WeChat Pay cross-border approval response
- card acquirer approval, cancel, purchase, or settlement response
- receipt, slip, approval number, transaction id, trace id, and terminal evidence
- payment inquiry response
- cancel inquiry response
- last transaction inquiry response
- settlement batch file response
- fee, deposit, and reconciliation file response

This document does not define external provider onboarding, request routing, or recovery playbooks. Those are handled by related documents.

## 3. Related Documents

- 70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md
- 70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md
- 70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md
- 70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md
- 70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md
- 70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md
- 70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md
- 70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md

## 4. Core Principle

External payment data must be treated as evidence, not as a final authority.

A POS, VAN, PG, or payment provider response may trigger internal validation, but it must not by itself finalize the internal order, payment, cancellation, refund, settlement, or accounting state unless all required validation and audit evidence capture rules have passed.

The system must preserve enough evidence to answer the following questions later:

1. What did we request?
2. What did the external provider return?
3. When did we receive it?
4. Who or what processed it?
5. Was the payload altered after receipt?
6. Did the response match the expected order, amount, terminal, provider, and transaction identity?
7. Was the final internal state derived from evidence or from manual override?
8. Can we prove the decision during customer dispute, provider dispute, audit, settlement review, or legal hold?

## 5. Evidence Classes

### 5.1 Request Evidence

Every outbound payment-affecting request must produce request evidence before transmission.

Required request evidence:

- payment_intent_id
- order_id
- store_id
- terminal_id
- provider_id
- adapter_id
- idempotency_key
- expected_amount
- expected_tax_amount
- expected_discount_amount
- expected_service_charge_amount
- currency
- request_type
- request_timestamp
- request_payload_hash
- request_correlation_id
- outbound_transport_channel
- request_operator_or_system_actor

### 5.2 Response Evidence

Every inbound external response must be captured before interpretation.

Required response evidence:

- payment_response_id
- payment_intent_id when available
- provider_transaction_id
- approval_no when available
- response_code
- provider_response_message
- canonical_response_code
- raw_response_payload
- raw_response_payload_hash
- received_at
- receiver_component
- transport_channel
- terminal_id from response
- store_id from response when available
- merchant_id from response when available
- approved_amount or cancelled_amount
- approved_at or cancelled_at when available
- receipt_no
- receipt_text or receipt_url when available
- van_trace_id or pg_trace_id
- acquirer_id or card_company when available
- inquiry_required_flag
- validation_status
- evidence_retention_class

### 5.3 Validation Evidence

Every response validation decision must be recorded separately from the raw response.

Required validation evidence:

- validation_id
- payment_response_id
- validation_rule_version
- validation_started_at
- validation_completed_at
- validation_result
- failed_rule_codes
- amount_match_result
- order_match_result
- terminal_match_result
- provider_match_result
- duplicate_check_result
- time_window_check_result
- response_code_mapping_result
- inquiry_required_result
- final_state_recommendation
- validator_component

### 5.4 Decision Evidence

The final internal state decision must be auditable.

Required decision evidence:

- decision_id
- payment_intent_id
- payment_response_id or inquiry_response_id
- previous_internal_state
- new_internal_state
- decision_source
- decision_reason_code
- decision_actor
- decision_timestamp
- manual_override_flag
- manager_approval_id when applicable
- compensation_action_id when applicable
- reconciliation_exception_id when applicable

## 6. Raw Payload Preservation Rule

The raw external response payload must be preserved before any transformation, normalization, filtering, masking, enrichment, or canonical mapping.

The raw payload must be stored in a write-once or append-only evidence store when the storage layer supports it. If native WORM storage is not available, the system must simulate tamper resistance through append-only writes, immutable versioning, cryptographic hashes, and audit trail chaining.

The following are prohibited:

- overwriting the raw payload
- storing only parsed fields without raw response
- storing only success/failure flags
- deleting raw payload after validation
- allowing operator edit of raw payload
- masking before original capture
- changing provider response code after receipt
- replacing a failed response with a later successful response

Corrections must be stored as separate correction records, never as mutation of original evidence.

## 7. Hash And Tamper Check Policy

### 7.1 Payload Hash

Each raw payload must be hashed immediately after receipt.

Minimum hash fields:

- hash_algorithm
- raw_payload_hash
- hash_created_at
- hash_created_by_component
- canonicalization_method when applicable

The default algorithm should be SHA-256 or stronger unless project-wide cryptographic policy defines a stronger standard.

### 7.2 Evidence Chain Hash

Payment evidence should form a chain where practical.

Recommended chain input:

- previous_evidence_hash
- current_raw_payload_hash
- payment_intent_id
- provider_transaction_id
- received_at
- evidence_sequence_no

The chain hash allows detection of missing, reordered, replaced, or edited evidence.

### 7.3 Tamper Check Events

Tamper checks must be executed at minimum during:

- real-time validation
- manual review opening
- cancellation or refund execution
- daily close
- reconciliation batch
- dispute packet generation
- legal hold export
- archive retention verification

A tamper check failure must immediately create a security-grade audit incident and prevent automatic settlement finalization until reviewed.

## 8. Evidence Storage Model

The evidence store must separate operational state from evidence state.

Recommended logical stores:

```text
payment_intent_ledger
payment_request_evidence
payment_response_evidence
payment_validation_evidence
payment_decision_evidence
payment_inquiry_evidence
payment_compensation_evidence
payment_reconciliation_evidence
payment_dispute_packet
payment_evidence_tamper_check
```

Operational order/payment state may reference evidence records, but evidence records must not be rewritten to fit operational state.

## 9. Receipt And Slip Evidence

Receipt and slip evidence must be captured when returned by POS, VAN, PG, or provider adapter.

Required receipt evidence when available:

- receipt_no
- approval_no
- merchant_no
- terminal_id
- provider_id
- acquirer
- card_company
- masked_card_no
- installment_months
- approved_amount
- tax_amount
- service_charge_amount
- approved_at
- cancellation_flag
- receipt_text
- receipt_url
- print_status
- reprint_count

Receipt evidence must not be treated as the only proof of payment. It must be linked to request evidence, raw response evidence, and validation evidence.

## 10. Inquiry Evidence

When payment state is timeout, unknown, ambiguous, mismatched, or reversal pending, inquiry evidence is mandatory.

Inquiry evidence must include:

- inquiry_id
- original_payment_intent_id
- inquiry_type
- inquiry_request_payload
- inquiry_request_hash
- inquiry_response_payload
- inquiry_response_hash
- provider_transaction_id
- inquiry_result_code
- canonical_inquiry_result
- inquiry_started_at
- inquiry_received_at
- inquiry_attempt_no
- inquiry_finality_level

Inquiry evidence must not overwrite the original response. It must be linked as later evidence that clarifies, confirms, or disputes the original state.

## 11. Correction Record Rule

When a wrong internal interpretation occurs, the system must create a correction record.

Correction records must include:

- correction_id
- affected_payment_intent_id
- affected_response_id
- incorrect_state
- corrected_state
- correction_reason_code
- correction_source
- correction_actor
- correction_timestamp
- supporting_evidence_ids
- customer_impact_flag
- accounting_impact_flag
- settlement_impact_flag
- manager_approval_id when applicable

Corrections are allowed. Silent mutation is prohibited.

## 12. Audit Event Types

The following audit event types must be supported:

```text
PAYMENT_REQUEST_EVIDENCE_CREATED
PAYMENT_RESPONSE_RAW_PAYLOAD_CAPTURED
PAYMENT_RESPONSE_HASH_CREATED
PAYMENT_RESPONSE_CANONICALIZED
PAYMENT_RESPONSE_VALIDATION_STARTED
PAYMENT_RESPONSE_VALIDATION_FAILED
PAYMENT_RESPONSE_VALIDATION_PASSED
PAYMENT_STATE_DECISION_CREATED
PAYMENT_INQUIRY_REQUESTED
PAYMENT_INQUIRY_RESPONSE_CAPTURED
PAYMENT_COMPENSATION_REQUESTED
PAYMENT_REVERSAL_PENDING
PAYMENT_CANCEL_CONFIRMED
PAYMENT_MANUAL_REVIEW_OPENED
PAYMENT_MANAGER_OVERRIDE_REQUESTED
PAYMENT_MANAGER_OVERRIDE_APPROVED
PAYMENT_RECONCILIATION_EXCEPTION_OPENED
PAYMENT_TAMPER_CHECK_PASSED
PAYMENT_TAMPER_CHECK_FAILED
PAYMENT_DISPUTE_PACKET_EXPORTED
PAYMENT_LEGAL_HOLD_APPLIED
```

## 13. Dispute Packet Requirement

When a customer, store, provider, card acquirer, tax/accounting party, or internal operator disputes a payment state, the system must generate a dispute packet.

Minimum dispute packet contents:

- order summary
- payment intent summary
- request evidence
- response evidence
- raw payload hash
- validation evidence
- decision evidence
- inquiry evidence when applicable
- cancellation/refund evidence when applicable
- receipt/slip evidence
- reconciliation evidence when applicable
- operator actions
- manager overrides
- customer-facing messages
- final recommended resolution

The dispute packet must be exportable without modifying original evidence.

## 14. Retention And Legal Hold

External payment evidence must follow financial-grade retention and legal hold rules.

Retention classes:

| Evidence Type | Minimum Retention Class |
| --- | --- |
| payment request evidence | financial transaction evidence |
| payment response raw payload | financial transaction evidence |
| approval/cancel receipt evidence | financial transaction evidence |
| validation and decision evidence | audit decision evidence |
| inquiry and compensation evidence | recovery evidence |
| reconciliation exception evidence | accounting audit evidence |
| dispute packet | dispute/legal evidence |
| tamper check record | security audit evidence |

If a legal hold, dispute, tax inquiry, regulator inquiry, or provider dispute is active, deletion, compaction, or anonymization must be suspended for affected records until release.

## 15. Access Control

Only authorized system components may write payment evidence. Human users must not directly edit evidence records.

Access principles:

- operators may view limited payment status and customer-safe receipt information
- managers may view dispute and recovery context
- finance/audit roles may view reconciliation and settlement evidence
- security roles may view tamper check and payload integrity metadata
- raw payload access must be restricted and logged
- exports must create export audit events

Sensitive customer data must be masked in user-facing views, but original evidence capture must remain preserved according to compliance rules.

## 16. Failure Handling

If evidence capture fails, the payment must not be silently finalized.

Failure states:

```text
EVIDENCE_CAPTURE_FAILED
PAYLOAD_HASH_FAILED
VALIDATION_EVIDENCE_FAILED
DECISION_EVIDENCE_FAILED
TAMPER_CHECK_FAILED
DISPUTE_PACKET_EXPORT_FAILED
```

If raw response cannot be preserved, the system must classify the payment as audit-incomplete and route it to manual review or reconciliation exception handling.

## 17. Closeout Criteria

This audit control is considered ready only when:

- every external payment response is captured as raw payload
- every raw payload has a hash
- every internal state decision references evidence
- successful, failed, timeout, unknown, cancellation, refund, and inquiry flows all produce audit events
- tamper check can detect payload mutation
- dispute packet export works without modifying source evidence
- daily reconciliation can reference evidence ids
- manual override cannot bypass evidence logging
- legal hold can suspend deletion and archive modification

## 18. Handoff

This document hands off to the failure mode and state transition matrix, where each response, timeout, mismatch, inquiry, reversal, cancellation, refund, and reconciliation exception must be mapped to a specific recovery action and operator/manager responsibility.

Next document:

70180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md
