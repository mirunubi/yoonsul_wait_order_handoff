# 070100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md

## 1. Purpose

This document opens the 70100 external payment integration governance lane for `yoonsul_wait_order_handoff`.

The purpose of this lane is to define how the system controls, validates, corrects, logs, reconciles, and recovers all payment-related external integrations, including POS, VAN, PG, easy payment providers, cross-border payment providers, card/acquirer networks, settlement files, and future delivery app or external membership payment flows.

This document treats external payment systems as external financial event sources. The system must not assume that a successful RPC call, callback, webhook, POS response, or vendor status message is sufficient to finalize internal order, payment, refund, settlement, or accounting state.

## 2. Scope

This lane covers external payment integration governance for:

- POS terminals and POS software vendors
- VAN providers and VAN daemons
- PG providers and payment aggregators
- domestic easy payment providers
- Alipay, WeChat Pay, and other cross-border payment providers
- card companies and acquiring networks
- payment approval, cancel, refund, reversal, and inquiry flows
- settlement, deposit, fee, and chargeback data
- payment webhooks, callbacks, polling results, and batch files
- external order app payment handoff where payment state affects internal order state
- future delivery app, membership, coupon, loyalty, tax, and accounting integration where money state must be reconciled

Out of scope:

- internal menu/order UI design
- pure customer UX policy unless it affects payment integrity
- internal-only order lifecycle rules not dependent on external payment state
- POS sandbox infection-control details, except where they intersect with financial data validation

## 3. Governance Position

The 70100 lane sits under:

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`

It is related to, but separate from:

- POS gateway implementation work packages in the 06000 range
- store runtime operation policies in the 04000 range
- security and runtime test catalog policies in the 04900 range
- customer handoff and implementation readiness policies in the 05000 range
- audit ledger and financial-grade evidence lanes in the 50000+ system SOP and governance lanes

The distinction is mandatory:

- POS sandboxing protects the core system from external software contamination.
- External payment integration governance protects money, order state, settlement, evidence, and customer claims from external data ambiguity.

## 4. Core Principle

The system must apply the following principle to every external payment integration:

> External payment data is never final until it is validated against internal intent, external response evidence, inquiry state, and reconciliation results.

Therefore:

- A sent request is not a confirmed payment.
- A transport success is not a financial success.
- A POS success flag is not sufficient without approval evidence.
- A timeout is not a failure; it is an unknown state.
- A cancel request is not a cancellation until cancellation evidence is verified.
- A settlement file is not automatically correct; it must be reconciled.
- A vendor dashboard value is not authoritative unless mapped to internal ledger evidence.

## 5. External Payment Control Model

Every external payment event must pass through the following control model.

```text
Payment Intent Created
  -> External Request Sent
  -> External Response / Callback / Webhook / Inquiry / Batch Received
  -> Raw Payload Captured
  -> Field Normalization
  -> Validation Gate
  -> State Decision
  -> Correction / Compensation / Manual Review if required
  -> Reconciliation
  -> Audit Evidence Closure
```

The system must not bypass this model for pilot stores, manually configured providers, partner-provided SDKs, or vendor-managed POS environments.

## 6. Required Ledger Separation

External payment integration must use separated ledgers.

### 6.1 Payment Intent Ledger

Records the system's expected financial action before external communication.

Minimum fields:

- payment_intent_id
- order_id
- store_id
- table_id or channel_id
- terminal_id or provider_channel_id
- provider_type
- provider_name
- expected_amount
- tax_amount
- discount_amount
- service_charge_amount
- currency
- idempotency_key
- request_hash
- created_by_system_component
- created_at
- status

### 6.2 External Request Ledger

Records every outbound request.

Minimum fields:

- external_request_id
- payment_intent_id
- request_type
- provider_endpoint_or_adapter
- request_payload_hash
- idempotency_key
- retry_count
- sent_at
- transport_result
- timeout_flag
- adapter_version

### 6.3 External Response Ledger

Records every inbound response, callback, webhook, inquiry result, or settlement response.

Minimum fields:

- external_response_id
- payment_intent_id
- external_request_id if available
- raw_payload
- raw_payload_hash
- provider_transaction_id
- approval_no
- cancel_no
- response_code
- response_message
- approved_amount
- cancelled_amount
- provider_trace_id
- acquirer
- card_company
- merchant_id
- terminal_id
- received_at
- parsed_at
- parser_version

### 6.4 Payment Decision Ledger

Records the internal decision made after validation.

Minimum fields:

- payment_decision_id
- payment_intent_id
- decision_status
- decision_reason_code
- validation_result_id
- decided_by
- decided_at
- override_flag
- manual_review_ticket_id
- linked_compensation_id

### 6.5 Reconciliation Ledger

Records daily, batch, settlement, deposit, and accounting reconciliation results.

Minimum fields:

- reconciliation_id
- store_id
- provider_name
- business_date
- internal_amount
- external_approved_amount
- external_cancelled_amount
- settlement_amount
- fee_amount
- deposit_amount
- mismatch_amount
- mismatch_reason
- evidence_packet_id
- closed_at

## 7. Validation Gate Requirements

Every external payment response must be validated before it changes internal order or financial state.

Minimum validation checks:

| Validation Area | Required Check |
|---|---|
| Identity | provider transaction ID, approval number, merchant ID, terminal ID, store ID, order ID, and payment intent ID must map correctly. |
| Amount | expected amount, approved amount, tax, discount, service charge, currency, and partial cancel amount must match allowed rules. |
| Time | request time, approval time, received time, timeout window, and business date must be within defined tolerance. |
| Duplicate | duplicate approval, duplicate cancel, replayed webhook, retried callback, and double confirm must be detected. |
| State | external state transition must be allowed from the current internal state. |
| Provider code | provider response codes must be mapped through the provider response code registry. |
| Evidence | approval or cancel success must contain required evidence fields. |
| Integrity | raw payload hash, parser version, normalized field values, and decision result must be preserved. |
| Security | suspicious terminal, unknown merchant, altered amount, or unknown provider route must generate a security/audit event. |

If a validation check fails, the system must not directly finalize the payment. It must move the transaction to a controlled state such as `AMBIGUOUS`, `MISMATCHED`, `INQUIRY_REQUIRED`, `COMPENSATION_REQUIRED`, or `MANUAL_REVIEW`.

## 8. Mandatory Payment States

The external payment governance lane requires at least the following state vocabulary.

```text
INTENT_CREATED
REQUEST_READY
REQUEST_SENT
RESPONSE_RECEIVED
VALIDATION_PENDING
CONFIRMED
DECLINED
TIMEOUT_UNKNOWN
INQUIRY_REQUIRED
AMBIGUOUS
MISMATCHED
CANCEL_REQUESTED
CANCEL_CONFIRMED
CANCEL_UNKNOWN
REVERSAL_PENDING
REFUND_PENDING
REFUND_CONFIRMED
COMPENSATION_REQUIRED
MANUAL_REVIEW
RECONCILIATION_PENDING
RECONCILIATION_EXCEPTION
RECONCILED
AUDIT_CLOSED
```

The system must never collapse `TIMEOUT_UNKNOWN`, `AMBIGUOUS`, or `CANCEL_UNKNOWN` into generic failure.

## 9. Inquiry Requirement

External payment providers must be evaluated for inquiry capability before production approval.

Required inquiry capabilities:

- approval inquiry by provider transaction ID
- approval inquiry by order/payment intent ID where supported
- approval inquiry by approval number
- cancel/refund inquiry
- last transaction inquiry for POS terminal cases
- business-date transaction list export
- settlement batch export
- receipt/slip reprint or receipt metadata fetch
- webhook replay or event resend where supported

If a provider cannot support inquiry or equivalent reconciliation evidence, it must be treated as high-risk and restricted from automated payment finalization.

## 10. Failure Mode Families

The 70100 lane must produce detailed recovery rules for the following failure families.

| Failure Family | Required Control |
|---|---|
| Request timeout | Mark as `TIMEOUT_UNKNOWN`; trigger inquiry before retrying payment. |
| Response lost | Use inquiry or batch reconciliation before customer re-payment. |
| Duplicate approval | Keep one valid approval; cancel or reverse duplicates. |
| Duplicate cancel | Detect idempotently and prevent over-refund. |
| Amount mismatch | Stop order finalization and create review event. |
| Store/terminal mismatch | Block finalization and create security/audit event. |
| Success without approval number | Mark as ambiguous and require inquiry. |
| Cancel timeout | Do not assume cancellation; move to `CANCEL_UNKNOWN`. |
| Order success/payment failure | Hold or void order depending on kitchen and fulfillment status. |
| Payment success/order failure | Recreate order or compensate with cancel/reversal. |
| Settlement mismatch | Hold accounting closure and create reconciliation exception. |
| Fee mismatch | Route to settlement/finance review. |
| Chargeback/dispute | Attach original evidence and freeze automatic closure. |

## 11. Correction and Compensation Governance

Correction must be explicit, logged, and auditable.

Allowed correction types:

- field normalization correction
- provider response code mapping correction
- state transition correction
- duplicate event suppression
- delayed response attachment
- settlement file mapping correction
- manual evidence attachment

Allowed compensation types:

- approval cancel
- refund
- reversal
- order regeneration
- order hold
- kitchen ticket void
- customer claim ticket creation
- manager override
- finance reconciliation adjustment

Prohibited behavior:

- silently rewriting approved amount
- deleting raw external payload
- marking timeout as failed without inquiry
- marking cancel as complete without cancel evidence
- merging two approvals into one without trace evidence
- using vendor dashboard screenshot as sole evidence when machine-readable evidence is available

## 12. Logging and Evidence Requirements

Every external payment integration must produce machine-readable and human-reviewable evidence.

Required evidence:

- request raw payload or canonical request snapshot
- response raw payload
- normalized response fields
- validation result
- state transition history
- inquiry result if used
- compensation action if used
- operator action if used
- reconciliation record
- provider adapter version
- clock/timezone metadata
- hash of evidence packet

Evidence retention must align with financial audit, legal hold, customer dispute, tax, and settlement retention policies.

## 13. Provider Onboarding Requirements

A payment provider must not be enabled for production until the following are complete.

- provider identity and registration review
- contract and liability boundary review
- sandbox certification
- approval/cancel/refund test cases
- timeout and retry test cases
- duplicate webhook/callback test cases
- inquiry test cases
- settlement file import test cases
- receipt evidence test cases
- reconciliation exception test cases
- manual recovery runbook review
- store operator training impact review
- audit evidence export review

## 14. Relationship to Future External Channels

The same control model must be reused for future integrations such as:

- delivery apps
- external order apps
- external membership providers
- coupon and voucher providers
- gift card providers
- loyalty point systems
- tax invoice providers
- accounting systems
- ERP systems
- franchise settlement systems

The financial control model must remain the same even when the external channel is not a traditional POS/VAN/PG provider.

If the external channel can change order value, discount, customer entitlement, payable amount, receivable amount, settlement amount, refund amount, or accounting state, it must pass through this external integration control plane.

## 15. Document Map

This lane will expand into the following candidate documents.

| No. | Document | Purpose |
|---:|---|---|
| 70110 | Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model | Provider trust boundary and liability model |
| 70120 | Policy_External_Payment_Request_Response_Separation_And_State_Authority | Separation of internal intent and external response authority |
| 70130 | Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata | Provider response field registry |
| 70140 | Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation | Amount and order validation |
| 70150 | Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control | Unknown state and inquiry control |
| 70160 | Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action | Communication error and recovery runbook |
| 70170 | Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check | Raw payload evidence and tamper check |
| 70180 | Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action | Failure mode and recovery action matrix |
| 70190 | Index_POS_VAN_PG_External_Payment_Integration_Closeout_And_Handoff | Lane closeout and handoff |

## 16. Acceptance Criteria

This lane is acceptable only when:

- every external payment state has a defined internal state mapping
- timeout and ambiguous states are explicitly handled
- inquiry is required before retrying risky payment flows
- raw external payload is preserved
- validation failure never silently finalizes an order
- cancel/refund/reversal flows have independent evidence
- settlement and deposit reconciliation are connected
- store operator recovery actions are defined
- customer claim evidence can be reconstructed
- provider onboarding includes failure-mode certification

## 17. Handoff

This document hands off to:

- `70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md`

The next document must define the external provider trust boundary, responsibility split, liability model, and contractual readiness requirements for POS, VAN, PG, and related payment providers.
