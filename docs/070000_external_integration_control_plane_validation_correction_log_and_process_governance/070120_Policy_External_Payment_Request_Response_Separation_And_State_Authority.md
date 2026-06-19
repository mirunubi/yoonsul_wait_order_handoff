# 070120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md

## 1. Purpose

This policy defines the mandatory separation between external payment requests, external payment responses, and internal payment state authority for the yoonsul_wait_order_handoff external integration control plane.

The purpose is to prevent POS, VAN, PG, card acquirer, simple-payment provider, cross-border payment gateway, kiosk vendor, delivery-app provider, membership provider, or accounting integration response data from directly mutating the internal order, payment, settlement, or customer claim state without validation.

This document establishes the rule that external payment responses are evidence inputs, not final state authority.

## 2. Scope

This policy applies to all external payment and money-related integrations, including but not limited to:

- POS payment request and approval response
- VAN approval, cancel, inquiry, and settlement response
- PG authorization, confirm, cancel, refund, and webhook response
- Simple-payment provider response, including KakaoPay, NaverPay, TossPay, and similar providers
- Alipay, WeChat Pay, GLN, and other cross-border payment response flows
- Card issuer, acquirer, merchant service, and settlement files
- Kiosk vendor payment modules
- External order-app payment handoff
- Delivery-app settlement, cancel, and dispute records
- External membership, coupon, point, and promotion redemption events
- Tax, accounting, receipt, and revenue recognition integration events

## 3. Governing Principle

External systems may originate payment events, but they must not directly own the final internal state.

The internal system must treat every external response as one of the following:

1. a raw evidence payload;
2. a candidate state transition;
3. a validation target;
4. a reconciliation input;
5. a dispute and audit artifact.

No external response may directly close an order, confirm a payment, release a table, issue a refund, recognize revenue, mark settlement complete, or resolve a customer claim without passing the internal validation and state authority gate.

## 4. State Authority Model

### 4.1 Request Authority

The internal system owns the payment request authority.

Before any request is sent to POS, VAN, PG, kiosk vendor, delivery-app provider, membership provider, or accounting integration, the internal system must create a request-side ledger entry.

Minimum request authority fields:

| Field | Requirement |
|---|---|
| request_id | Mandatory internal unique request identifier |
| payment_intent_id | Mandatory payment intent linkage |
| order_id | Mandatory order linkage if applicable |
| store_id | Mandatory store scope |
| terminal_id | Required when a terminal is involved |
| provider_id | External provider identifier |
| provider_type | POS, VAN, PG, delivery, membership, accounting, or other external type |
| expected_amount | Mandatory for money movement |
| tax_amount | Required where taxable amount exists |
| discount_amount | Required where discount exists |
| service_charge_amount | Required where service charge exists |
| currency | Mandatory for cross-border and multi-currency flows |
| idempotency_key | Mandatory for retryable external calls |
| request_hash | Mandatory hash of normalized request body |
| requested_at | Mandatory timestamp |
| request_status | REQUEST_CREATED, SENT, FAILED_TO_SEND, RETRY_PENDING, or EXPIRED |

### 4.2 Response Authority

The external provider owns only the response event emission, not the final internal state.

Every received response must be stored as a response-side ledger entry before interpretation.

Minimum response authority fields:

| Field | Requirement |
|---|---|
| response_id | Mandatory internal unique response identifier |
| request_id | Required when matched to a known request |
| payment_intent_id | Required when matchable |
| provider_id | Mandatory provider identifier |
| provider_trace_id | Required when provided by external system |
| approval_no | Required for approved payment responses |
| cancel_no | Required for confirmed cancel responses where applicable |
| response_code | Mandatory when provided |
| response_message | Required when provided |
| approved_amount | Required for approval responses |
| cancelled_amount | Required for cancel/refund responses |
| raw_payload | Mandatory original payload preservation |
| raw_payload_hash | Mandatory tamper-evidence hash |
| received_at | Mandatory timestamp |
| parse_status | PARSED, PARTIAL, UNPARSEABLE, or UNSUPPORTED_SCHEMA |
| response_status | RECEIVED, VALIDATION_PENDING, VALIDATED, REJECTED, AMBIGUOUS, or MANUAL_REVIEW |

### 4.3 Internal State Authority

The internal payment state authority belongs only to the internal validation gate and ledger controller.

The validation gate must decide whether an external response can produce one of the following internal state transitions:

| Candidate Event | Allowed Internal Result |
|---|---|
| Approval success response | CONFIRMED only after validation |
| Approval failure response | DECLINED only after correlation validation |
| Timeout or missing response | TIMEOUT_UNKNOWN, not FAILED |
| Duplicate success response | DUPLICATE_RESPONSE or DUPLICATE_APPROVAL_REVIEW |
| Amount mismatch | MISMATCHED_AMOUNT_REVIEW |
| Store or terminal mismatch | SECURITY_REVIEW |
| Cancel success response | CANCELLED only after cancel validation |
| Refund success response | REFUNDED only after refund validation |
| Settlement match | RECONCILED only after settlement reconciliation |
| Settlement mismatch | RECONCILIATION_EXCEPTION |

## 5. Mandatory Separation Rule

The system must maintain separate ledgers for at least the following layers:

```text
External Request Ledger
External Response Ledger
Internal Payment State Ledger
Reconciliation Ledger
Audit Evidence Ledger
Operator Recovery Ledger
```

These ledgers may be implemented in related database tables, but they must remain logically separated.

The system must not overwrite the request record with the response result as the only source of truth.

The system must not use a provider response as the sole final payment record.

The system must not collapse payment request, payment response, internal confirmation, settlement match, and accounting recognition into one mutable row without append-only audit history.

## 6. Validation Gate Requirements

Before an external response is allowed to change an internal payment state, the validation gate must check the following minimum controls.

| Control | Required Check |
|---|---|
| Correlation check | Response must match known request, payment intent, or allowed inquiry recovery pattern |
| Amount check | External amount must match expected amount, tax, discount, service charge, and currency rules |
| Store check | Response store/merchant identity must match the internal store scope |
| Terminal check | Terminal ID must match registered terminal or accepted provider mapping |
| Provider check | Provider must be active, certified, and allowed for the store |
| Idempotency check | Duplicate request or response must not create duplicate approval or cancel |
| Approval number check | Success response must include required approval or transaction reference |
| Response-code check | Provider-specific response code must map to approved registry semantics |
| Time-window check | Response must fall within allowed request/response validity window unless recovered by inquiry |
| Signature/hash check | Webhook or callback response must pass authenticity checks where available |
| Raw evidence check | Original payload must be preserved before state mutation |

## 7. State Transition Policy

### 7.1 Approved Response

An approval response may move to `PAYMENT_CONFIRMED` only when all mandatory validations pass.

If the approval response contains missing approval number, mismatched amount, mismatched terminal, unsupported response code, unrecognized provider trace, or duplicate approval risk, the payment must move to a review or ambiguous state.

### 7.2 Failed Response

A failed response may move to `PAYMENT_DECLINED` only when the response is correlated to the correct request and there is no evidence that the transaction might have been approved externally.

A communication error, timeout, broken socket, missing callback, or user-screen interruption must not be treated as definitive payment failure.

### 7.3 Timeout Response

A timeout must be recorded as `TIMEOUT_UNKNOWN`.

The system must trigger inquiry, reconciliation, or operator review depending on provider capability and risk severity.

### 7.4 Ambiguous Response

The system must use an ambiguous state when an external event cannot be safely classified.

Examples:

- POS call timed out after card insertion;
- VAN approval may have succeeded but response was lost;
- PG webhook arrived before confirm result;
- cancel request timed out;
- same order received two approval references;
- provider returned success code without approval number;
- amount differs by tax, discount, coupon, or rounding;
- external membership redemption succeeded but payment failed;
- delivery-app cancel succeeded but internal order state already advanced.

### 7.5 Cancel and Refund Response

Cancel or refund responses must pass the same separation and validation rules as approval responses.

A cancel request timeout must be classified as `CANCEL_UNKNOWN`, not `CANCEL_FAILED`, until inquiry or reconciliation confirms the external state.

## 8. Inquiry Requirement

For any provider that handles money movement or monetary benefit, integration onboarding must verify whether the provider supports inquiry or equivalent recovery mechanisms.

Required inquiry capabilities should include:

| Inquiry Type | Requirement |
|---|---|
| Approval inquiry | Required for POS/VAN/PG approval recovery |
| Cancel inquiry | Required for cancel timeout recovery |
| Refund inquiry | Required for refund recovery |
| Last transaction inquiry | Required for terminal-based ambiguous recovery where available |
| Settlement inquiry/export | Required for daily reconciliation |
| Receipt/slip re-fetch | Required for customer dispute and evidence recovery |
| Provider trace lookup | Required for incident and audit investigation |

A provider that cannot support inquiry must be marked high-risk and may require additional manual closeout controls before production approval.

## 9. Correction and Compensation Policy

When validation detects a mismatch or ambiguous result, the system must not silently correct the state.

Allowed correction methods:

1. inquiry-based confirmation;
2. provider settlement-file confirmation;
3. manager-approved manual correction with evidence;
4. compensating cancel or refund transaction;
5. internal order reconstruction after confirmed payment;
6. customer claim resolution with evidence packet;
7. accounting adjustment after reconciliation approval.

Forbidden correction methods:

- overwriting confirmed payment without audit trail;
- deleting raw external payload;
- manually changing amount without evidence;
- treating timeout as failure without inquiry;
- treating UI screen result as financial truth;
- closing reconciliation exception without responsible owner.

## 10. Log and Evidence Requirements

All request/response separation events must generate logs and evidence.

Minimum evidence packet:

```text
request_id
payment_intent_id
order_id
store_id
terminal_id
provider_id
idempotency_key
request_hash
raw_request_payload_reference
raw_response_payload_reference
raw_response_payload_hash
provider_trace_id
approval_no / cancel_no / refund_no
validation_result
state_transition_before
state_transition_after
actor_or_system_component
created_at
validated_at
reconciled_at
manual_override_reference, if any
```

Logs must be append-only or tamper-evident where feasible.

## 11. Operator and Manager Boundary

Store operators may observe, escalate, and follow recovery instructions, but they must not directly override financial truth.

Manager override may be allowed only for operational recovery, not for final financial reconciliation.

Examples:

| Action | Store Operator | Store Manager | Finance/Admin |
|---|---:|---:|---:|
| View unknown payment | Allowed | Allowed | Allowed |
| Reprint receipt | Allowed if provider permits | Allowed | Allowed |
| Mark order served after payment evidence | Restricted | Allowed with evidence | Reviewable |
| Force payment confirmed | Not allowed | Restricted | Allowed only through correction workflow |
| Force refund complete | Not allowed | Not allowed | Allowed only after external confirmation |
| Close reconciliation exception | Not allowed | Not allowed | Finance/Admin only |

## 12. Provider Onboarding Requirement

Before production use, each external provider must document:

- request schema;
- response schema;
- response code registry;
- approval/cancel/refund identifiers;
- idempotency support;
- retry behavior;
- timeout behavior;
- inquiry capability;
- webhook/callback authenticity method;
- settlement file format;
- evidence and receipt data availability;
- service-level expectations;
- incident support path;
- legal and liability boundary.

The provider must not be treated as production-ready until the request/response separation model has been tested.

## 13. Failure Classification

All payment-related external failures must be classified before operator or system action.

| Failure Class | Meaning | Default State |
|---|---|---|
| SEND_FAILURE | Request did not leave internal boundary | FAILED_TO_SEND |
| PROVIDER_REJECTED | Provider rejected valid request | DECLINED or REJECTED |
| RESPONSE_TIMEOUT | No definitive response received | TIMEOUT_UNKNOWN |
| RESPONSE_PARSE_FAILURE | Response received but cannot be interpreted | AMBIGUOUS |
| AMOUNT_MISMATCH | External amount differs from expected amount | MISMATCHED_AMOUNT_REVIEW |
| DUPLICATE_RESPONSE | Same response or trace repeated | DUPLICATE_RESPONSE_REVIEW |
| DUPLICATE_APPROVAL | More than one approval risk exists | DUPLICATE_APPROVAL_REVIEW |
| CANCEL_UNKNOWN | Cancel result not confirmed | CANCEL_UNKNOWN |
| SETTLEMENT_MISMATCH | Settlement differs from internal ledger | RECONCILIATION_EXCEPTION |
| PROVIDER_SCHEMA_DRIFT | Provider changed field semantics or format | INTEGRATION_BLOCKED |

## 14. Mandatory Prohibitions

The system must not:

- allow POS success screen alone to complete internal payment;
- allow webhook alone to finalize payment without correlation;
- treat timeout as payment failure;
- treat cancel timeout as cancel failure;
- allow duplicated approval numbers for one internal payment without review;
- allow external membership redemption to be consumed if payment is not confirmed;
- allow delivery-app settlement data to override internal sales ledger without reconciliation;
- accept unregistered terminal or provider identifiers silently;
- discard failed or malformed response payloads;
- mutate financial records without audit trail.

## 15. Relationship to Other Documents

This policy is governed by:

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`
- `70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md`

This policy hands off to:

- `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`
- `70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md`
- `70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md`
- `70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md`
- `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`

## 16. Closeout Criteria

This policy is considered ready for implementation planning only when:

1. request ledger and response ledger are modeled separately;
2. internal state authority gate is defined;
3. provider response-code registry is planned;
4. timeout and ambiguous states are formalized;
5. inquiry requirement is included in provider onboarding;
6. cancel/refund compensation flow is defined;
7. raw payload preservation is mandatory;
8. operator and manager override boundaries are documented;
9. reconciliation and audit handoff are linked;
10. all production providers are subject to this separation policy.

## 17. Summary

External payment requests, external payment responses, and internal payment state authority must remain separated.

The system may send requests to external providers and receive responses from them, but it must not surrender financial truth to any external response without validation.

This policy establishes the foundation for preventing money-state corruption, duplicate approval, missing cancel, settlement mismatch, customer dispute failure, and silent financial data drift across POS, VAN, PG, simple payment, delivery-app, membership, and accounting integrations.
