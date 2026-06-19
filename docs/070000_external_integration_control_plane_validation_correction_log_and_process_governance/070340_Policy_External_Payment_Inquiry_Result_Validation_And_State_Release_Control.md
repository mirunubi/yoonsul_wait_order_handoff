# 070340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md

## Document Control

- Project: yoonsul_wait_order_handoff
- Band: 70000 External Integration Control Plane
- Parent Index: 70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md
- Previous: 70330_Runbook_External_Payment_Inquiry_Request_Retry_Escalation_And_Manager_Action.md
- Next: 70350_Policy_External_Payment_Recovery_Decision_Auto_Release_Manual_Review_And_Hold_Control.md
- Document Type: Policy
- Status: Draft

## 1. Purpose

This policy defines how an external payment inquiry result shall be validated before any UNKNOWN, AMBIGUOUS, INQUIRY_PENDING, REVERSAL_PENDING, or MANUAL_REVIEW payment state is released.

The objective is to prevent a payment from being incorrectly marked as confirmed, failed, cancelled, refunded, or reconciled based only on a single external inquiry response.

## 2. Core Principle

An inquiry response is evidence, not final authority.

External POS, VAN, PG, card acquirer, simplified payment, or cross-border gateway responses shall not directly mutate the internal order, payment, settlement, or customer service state. Every inquiry result must pass through the internal validation gate before state release.

## 3. Scope

This policy applies to inquiry results returned from:

- POS inquiry
- VAN approval inquiry
- VAN cancel inquiry
- PG payment inquiry
- PG refund inquiry
- last transaction inquiry
- settlement file lookup
- receipt or slip reprint lookup
- acquirer transaction lookup
- simplified payment provider inquiry
- cross-border payment inquiry
- manual vendor confirmation

## 4. Protected States

The following states may not be released without inquiry result validation:

| State | Meaning | Release Risk |
|---|---|---|
| TIMEOUT_UNKNOWN | Request timed out and final external result is unknown | Double charge or unpaid order |
| AMBIGUOUS | Conflicting signals exist | Wrong customer/store/order state |
| INQUIRY_PENDING | Inquiry has been requested but not resolved | Premature confirmation or cancellation |
| RESPONSE_PARTIAL | Response lacks required fields | Missing approval/cancel proof |
| REVERSAL_PENDING | Cancel or reversal has not been confirmed | False refund notice |
| RECONCILIATION_EXCEPTION | Internal and external ledgers differ | Accounting mismatch |
| MANUAL_REVIEW | Human review is required | Unauthorized override |

## 5. Inquiry Result Validation Gate

Every inquiry result shall be checked through the following validation gate.

### 5.1 Identity Match

The inquiry result must match the original payment intent using at least the required identity keys available for that provider:

- internal payment_intent_id
- order_id
- store_id
- terminal_id
- merchant_id
- provider_transaction_id
- approval_no
- van_trace_id
- pg_transaction_id
- inquiry_reference_id
- request time window

If the inquiry result cannot be mapped to exactly one internal payment intent, the result shall remain quarantined.

### 5.2 Amount Match

The inquiry result must match the expected financial fields:

- total amount
- taxable amount
- tax amount
- discount amount
- service charge
- tip, if applicable
- currency
- partial cancel amount, if applicable
- remaining authorized amount, if applicable

A mismatch of even one currency unit shall block automatic release unless the mismatch is explicitly covered by an approved rounding, FX, or provider fee rule.

### 5.3 Status Code Mapping

Provider-specific inquiry status codes must be mapped to an internal canonical status before use.

External codes such as SUCCESS, OK, PAID, APPROVED, CANCELLED, VOIDED, REFUNDED, PARTIAL_CANCELLED, FAILED, DECLINED, NOT_FOUND, or PROCESSING shall not be used directly as internal state values.

### 5.4 Approval Evidence Check

A payment may be released to CONFIRMED only if the inquiry result contains sufficient approval evidence.

Required evidence may include:

- approval number
- approval timestamp
- provider transaction id
- approved amount
- merchant id
- terminal id
- card/acquirer response code
- raw inquiry payload hash
- receipt/slip reference, if available

### 5.5 Cancel or Refund Evidence Check

A payment may be released to CANCELLED, REFUNDED, or REVERSAL_CONFIRMED only if the inquiry result contains sufficient reversal evidence.

Required evidence may include:

- cancel approval number or cancel transaction id
- cancel timestamp
- cancelled amount
- remaining amount
- original approval reference
- refund method
- raw cancel inquiry payload hash

### 5.6 Time Window Check

The inquiry result must fall within an acceptable transaction time window.

Late, duplicated, or old inquiry results shall not override a more recent internal state without manual review.

### 5.7 Duplicate and Conflict Check

Before state release, the system must check whether:

- another approval exists for the same order
- another cancel exists for the same approval
- the same approval number is mapped to another order
- another terminal submitted a conflicting transaction
- the provider returned different statuses across repeated inquiries

Any conflict shall move the case to MANUAL_REVIEW or RECONCILIATION_EXCEPTION.

## 6. Release Decision Rules

| Inquiry Finding | Allowed Release | Required Action |
|---|---|---|
| Approval confirmed and all fields match | CONFIRMED | Store approval evidence and close UNKNOWN |
| Approval not found, but request may still be processing | INQUIRY_PENDING | Retry inquiry after delay |
| Approval not found after final window | DECLINED or EXPIRED | Release only with policy-defined timeout window |
| Approval confirmed but order missing | CONFIRMED_PAYMENT_ORDER_RECOVERY | Rebuild or manually recover order |
| Order exists but approval absent | PAYMENT_REQUIRED or MANUAL_REVIEW | Do not serve as paid order |
| Cancel confirmed and original approval matches | CANCELLED / REFUNDED | Store cancel evidence |
| Cancel not found after reversal request | REVERSAL_PENDING | Retry or escalate |
| Amount mismatch | MISMATCHED | Block release and escalate |
| Terminal/store mismatch | SECURITY_REVIEW | Quarantine and investigate |
| Conflicting repeated inquiry results | RECONCILIATION_EXCEPTION | Lock state and require audit review |

## 7. Automatic Release Conditions

Automatic state release is allowed only when all of the following are true:

1. The inquiry result maps to exactly one internal payment intent.
2. The canonical provider status is recognized.
3. Amount, order, store, terminal, and provider identifiers match.
4. Required approval or cancel evidence exists.
5. No duplicate approval or conflicting cancel exists.
6. The raw inquiry payload and hash are stored.
7. The release decision is recorded in the audit ledger.

If any condition fails, automatic release is prohibited.

## 8. Manual Review Conditions

Manual review is mandatory when:

- provider inquiry returns inconsistent statuses
- approval exists without a matching order
- order exists without a matching approval
- approval amount differs from expected amount
- cancel result is unclear
- provider reports processing, pending, or unknown beyond the allowed window
- the result was supplied by human vendor confirmation instead of system inquiry
- the raw payload is unavailable
- the transaction affects settlement or customer refund dispute

## 9. Forbidden Actions

The following actions are prohibited:

- Marking a payment as failed only because the first inquiry returned NOT_FOUND
- Marking a payment as confirmed without approval number or equivalent evidence
- Marking a refund as completed without cancel/refund confirmation
- Replaying payment approval requests instead of using inquiry
- Overwriting a newer internal state with an older external inquiry result
- Deleting raw inquiry results after release
- Manually editing payment status without audit reason and manager approval
- Informing a customer that payment failed or refund completed while the case remains UNKNOWN or REVERSAL_PENDING

## 10. Audit Requirements

Every inquiry validation and release decision shall produce an audit record containing:

- payment_intent_id
- inquiry_request_id
- inquiry_result_id
- raw inquiry payload hash
- canonical status mapping result
- validation checks performed
- release decision
- release actor or system component
- release timestamp
- previous state
- new state
- exception reason, if any

## 11. Relationship To Other Documents

This policy depends on:

- 70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md
- 70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md
- 70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md
- 70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md
- 70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md
- 70320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md
- 70330_Runbook_External_Payment_Inquiry_Request_Retry_Escalation_And_Manager_Action.md
- 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md

## 12. Closeout Criteria

This policy is complete when:

- inquiry results cannot directly mutate payment state
- automatic release conditions are explicitly defined
- manual review conditions are explicitly defined
- approval, cancel, refund, and mismatch release paths are separated
- raw inquiry evidence and release decisions are audit logged
- UNKNOWN and AMBIGUOUS states cannot be prematurely closed
