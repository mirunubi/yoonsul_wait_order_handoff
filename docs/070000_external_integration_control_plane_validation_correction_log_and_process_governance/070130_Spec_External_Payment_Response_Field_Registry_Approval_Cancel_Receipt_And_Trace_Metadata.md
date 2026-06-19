# 070130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md

## 1. Purpose

This specification defines the standard response field registry for external payment integrations connected to the Yoonsul Wait Order Handoff platform.

The scope includes POS, VAN, PG, card acquirer, simple payment provider, cross-border payment provider, kiosk vendor, and external payment relay systems. The purpose of this document is to prevent external response payloads from directly controlling internal order and payment state without validation.

External payment responses are evidence. They are not final state authority by themselves.

The platform must normalize, validate, hash, preserve, reconcile, and audit all external payment response fields before internal payment confirmation, cancellation, refund, settlement, or customer claim handling is finalized.

## 2. Relationship To Parent Documents

This document belongs to the 70000 External Integration Control Plane band.

- Parent index: `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- Payment integration index: `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`
- Provider boundary document: `70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md`
- Request/response authority document: `70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md`
- Next document: `70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md`

## 3. Core Principle

The platform must not treat external payment response fields as trusted internal state.

Every external response must be handled through five layers:

1. Raw payload capture
2. Provider-specific parsing
3. Canonical field normalization
4. Internal validation against payment intent and order ledger
5. Evidence preservation and reconciliation readiness

No order, payment, cancellation, refund, or settlement status may be finalized only because an external provider returned a success-like response.

## 4. Response Field Registry Objectives

The response field registry exists to:

- standardize provider-specific approval and cancellation fields;
- separate raw provider fields from canonical internal fields;
- preserve payment traceability across POS, VAN, PG, card company, acquirer, and internal ledger;
- detect mismatched amount, store, terminal, order, and transaction identity;
- support inquiry, replay, reversal, refund, dispute, and reconciliation;
- support customer claim handling with reliable evidence;
- prevent duplicate approval, duplicate cancellation, and false confirmation;
- preserve raw payloads for audit and tamper-evidence verification.

## 5. Canonical Payment Response Object

Every external payment response must be normalized into a canonical response object.

Required canonical object fields:

| Field | Required | Description |
|---|---:|---|
| `payment_response_id` | Yes | Internal unique response identifier |
| `payment_intent_id` | Yes | Internal payment intent identifier generated before external request |
| `order_id` | Yes | Internal order identifier |
| `store_id` | Yes | Internal store identifier |
| `terminal_id` | Conditional | POS terminal or kiosk terminal identifier |
| `provider_type` | Yes | POS, VAN, PG, SIMPLE_PAY, CROSS_BORDER, CARD_ACQUIRER, KIOSK_VENDOR |
| `provider_id` | Yes | Registered external provider identifier |
| `adapter_id` | Yes | Internal adapter that parsed the response |
| `external_transaction_id` | Conditional | External transaction identifier where provided |
| `provider_trace_id` | Conditional | Provider-side trace, transaction, or sequence identifier |
| `approval_no` | Conditional | Approval number for successful authorization |
| `approval_datetime` | Conditional | External approval datetime |
| `response_code_raw` | Yes | Raw provider response code |
| `response_message_raw` | Conditional | Raw provider response message |
| `canonical_response_code` | Yes | Internal normalized response code |
| `canonical_response_status` | Yes | Internal normalized response status |
| `approved_amount` | Conditional | Amount approved by external provider |
| `currency` | Yes | Currency code such as KRW, USD, CNY |
| `tax_amount` | Conditional | Tax amount returned by provider |
| `service_charge_amount` | Conditional | Service charge returned by provider |
| `discount_amount` | Conditional | Discount amount returned by provider |
| `card_company` | Conditional | Card issuer or brand returned by provider |
| `acquirer` | Conditional | Acquirer or acquiring VAN/PG/card-side entity |
| `merchant_id` | Conditional | External merchant identifier |
| `receipt_no` | Conditional | Receipt or slip number |
| `receipt_url` | Conditional | Provider receipt URL if available |
| `receipt_text` | Conditional | Receipt or slip text if returned |
| `raw_payload_ref` | Yes | Storage reference to raw payload |
| `raw_payload_hash` | Yes | Hash of raw response payload |
| `received_at` | Yes | Internal receive timestamp |
| `validation_status` | Yes | PENDING, PASSED, FAILED, AMBIGUOUS, MANUAL_REVIEW |

## 6. Raw Payload Preservation Rule

The platform must preserve raw external response payloads before parsing or transformation.

Required controls:

- Store raw payload without field deletion.
- Store source channel and adapter version.
- Hash raw payload at receipt time.
- Link raw payload to `payment_intent_id` and `payment_response_id`.
- Preserve provider headers, callback metadata, local socket metadata, and request correlation data where available.
- Never overwrite raw payload after first capture.
- Store later corrections as separate correction events, not mutations of the original payload.

Raw payload is the highest-value dispute evidence for external payment communication.

## 7. Canonical Response Status

Provider-specific response codes must be mapped into canonical internal response status values.

Allowed canonical statuses:

| Canonical Status | Meaning |
|---|---|
| `APPROVED` | Provider indicates successful authorization or approval |
| `DECLINED` | Provider indicates customer/card/payment method rejection |
| `CANCELLED` | Provider indicates cancellation completed |
| `REFUNDED` | Provider indicates refund completed |
| `PENDING` | Provider indicates processing is not final |
| `TIMEOUT_UNKNOWN` | Request timed out and final external state is unknown |
| `AMBIGUOUS` | Response is incomplete, contradictory, late, duplicated, or cannot be trusted |
| `MISMATCHED` | Response conflicts with internal payment intent or order ledger |
| `DUPLICATE` | Duplicate response for an already processed transaction |
| `PROVIDER_ERROR` | Provider system error without reliable financial finality |
| `PARSING_ERROR` | Adapter could not parse response reliably |
| `MANUAL_REVIEW_REQUIRED` | Human review required before financial state finalization |

Provider-specific success codes may only map to `APPROVED` after mandatory field validation passes.

## 8. Approval Response Fields

Approval responses must include enough evidence to prove that the external payment network authorized the transaction.

Minimum approval evidence:

| Field | Rule |
|---|---|
| `approval_no` | Required for final approved card/POS/VAN transaction unless provider contract explicitly excludes it |
| `approved_amount` | Required |
| `approval_datetime` | Required or must be inferable from trusted provider timestamp |
| `provider_trace_id` | Required where provider supports transaction tracing |
| `terminal_id` | Required for physical POS/kiosk transactions |
| `merchant_id` | Required where provided by VAN/PG/acquirer |
| `response_code_raw` | Required |
| `canonical_response_code` | Required |
| `raw_payload_hash` | Required |

If a response claims success but lacks approval evidence, it must be routed to `AMBIGUOUS` or `MANUAL_REVIEW_REQUIRED`.

## 9. Cancellation And Reversal Response Fields

Cancellation, reversal, and void responses must be tracked separately from approval responses.

Required cancellation fields:

| Field | Rule |
|---|---|
| `original_payment_intent_id` | Required |
| `original_approval_no` | Required where applicable |
| `cancel_transaction_id` | Required where provided |
| `cancel_response_code_raw` | Required |
| `canonical_cancel_status` | Required |
| `cancel_amount` | Required |
| `cancel_datetime` | Required or must be inferable from trusted provider timestamp |
| `cancel_reason_code` | Conditional |
| `cancel_raw_payload_ref` | Required |
| `cancel_raw_payload_hash` | Required |

A cancellation response must never delete or overwrite the original approval response. It must create a separate cancellation evidence event linked to the original transaction.

## 10. Receipt And Slip Metadata

Receipt evidence must be captured because customer disputes often depend on receipt-level data.

Receipt metadata fields:

| Field | Description |
|---|---|
| `receipt_no` | Receipt, slip, or transaction slip number |
| `receipt_url` | External provider receipt URL |
| `receipt_text` | Receipt body, slip text, or printable payload |
| `masked_card_no` | Masked card number only, if provided |
| `installment_months` | Installment metadata if applicable |
| `issuer_name` | Card issuer name if provided |
| `acquirer_name` | Acquirer name if provided |
| `approval_no` | Approval number printed on receipt |
| `merchant_display_name` | Provider-side merchant name |
| `merchant_no` | Provider-side merchant number |

The platform must not store raw PAN, full card number, CVV, card password, or sensitive authentication data.

## 11. Trace Metadata

Trace metadata is mandatory for reconstructing payment paths across external systems.

Trace metadata must include, where available:

- internal request id;
- idempotency key;
- payment intent id;
- order id;
- provider request id;
- provider response id;
- VAN trace id;
- PG transaction id;
- acquirer transaction id;
- terminal sequence number;
- local POS sequence number;
- adapter version;
- gateway node id;
- receive timestamp;
- raw payload hash;
- callback signature validation result.

## 12. Provider-Specific Field Mapping Registry

Each provider integration must maintain a field mapping table.

Required mapping table columns:

| Column | Description |
|---|---|
| `provider_id` | Registered provider identifier |
| `provider_version` | Provider API/protocol version |
| `raw_field_name` | Field name used by provider |
| `raw_field_type` | String, number, datetime, enum, nested object, binary |
| `canonical_field_name` | Internal canonical field name |
| `required_for_approval` | Whether required for approval validation |
| `required_for_cancel` | Whether required for cancellation validation |
| `validation_rule` | Format, range, enum, checksum, timestamp, or cross-field rule |
| `masking_rule` | Storage/display masking requirement |
| `retention_class` | Retention and audit class |
| `failure_route` | AMBIGUOUS, MISMATCHED, MANUAL_REVIEW, PROVIDER_ERROR |

Provider mapping changes must be versioned and approved before production activation.

## 13. Response Code Registry

External response codes must be mapped into internal canonical codes.

Response code mapping must include:

| Field | Description |
|---|---|
| `provider_id` | Provider identifier |
| `raw_response_code` | Raw response code |
| `raw_response_message` | Raw response message or description |
| `canonical_response_status` | Internal normalized status |
| `financial_finality` | FINAL, NON_FINAL, UNKNOWN |
| `customer_message_key` | i18n-safe customer-facing message key |
| `operator_message_key` | i18n-safe store operator message key |
| `retry_allowed` | Whether retry is allowed |
| `inquiry_required` | Whether inquiry is mandatory before final state |
| `compensation_required` | Whether reversal/cancel/refund may be required |
| `manual_review_required` | Whether human review is mandatory |

A raw provider code may never be exposed directly to customers without message-key mapping.

## 14. Financial Finality Rule

Each response must be classified by financial finality.

Allowed financial finality values:

| Finality | Meaning |
|---|---|
| `FINAL_SUCCESS` | External payment network confirms successful final result |
| `FINAL_FAILURE` | External payment network confirms no financial movement occurred |
| `NON_FINAL_PENDING` | Processing continues or provider has not finalized |
| `UNKNOWN` | Financial movement may or may not have occurred |
| `CONFLICTED` | External response conflicts with internal ledger or another provider response |

Timeout, socket close, parsing error, callback delay, provider 5xx, and missing approval evidence must not be treated as `FINAL_FAILURE`.

## 15. Duplicate Detection Fields

Duplicate payment responses must be detected before order/payment state mutation.

Duplicate detection keys may include:

- `payment_intent_id`;
- `order_id`;
- `idempotency_key`;
- `approval_no`;
- `provider_trace_id`;
- `terminal_id` plus terminal sequence number;
- `merchant_id` plus approval datetime plus amount;
- `external_transaction_id`;
- raw payload hash.

If a duplicate response is detected, the platform must preserve it as evidence but prevent duplicate financial state transition.

## 16. Amount And Currency Metadata

Payment responses must preserve amount components separately.

Required amount fields where applicable:

- total approved amount;
- product amount;
- tax amount;
- service charge;
- tip;
- discount;
- coupon amount;
- point redemption amount;
- delivery fee;
- cancellation amount;
- refund amount;
- currency;
- exchange rate for cross-border payment;
- foreign currency charged amount;
- KRW settlement amount.

Cross-border payment responses must preserve both customer-charged currency and merchant-settlement currency where provider returns both values.

## 17. Security And Privacy Rules

The response field registry must enforce security and privacy restrictions.

Forbidden storage fields:

- full card number;
- CVV/CVC;
- card password;
- full magnetic track data;
- sensitive authentication data;
- unmasked identity document number;
- raw biometric data;
- unauthorized customer financial credentials.

Allowed storage fields:

- masked card number;
- issuer/acquirer name;
- approval number;
- receipt number;
- provider transaction id;
- masked customer identifier where legally allowed;
- raw payload with sensitive data redacted by approved secure capture mechanism where required.

If provider payload contains prohibited sensitive data, the adapter must route the event to security review and apply approved redaction controls before long-term retention.

## 18. Validation Routing

After canonical normalization, the response must be routed into one of the following validation outcomes:

| Outcome | Meaning | Next Action |
|---|---|---|
| `PASSED` | Field and ledger validation passed | Proceed to state transition candidate |
| `FAILED` | Definitive mismatch or invalid response | Block finalization and create exception |
| `AMBIGUOUS` | Result cannot be trusted | Trigger inquiry or manual review |
| `DUPLICATE` | Already processed or duplicate response | Preserve evidence and block duplicate mutation |
| `SECURITY_REVIEW` | Suspicious or prohibited data detected | Notify security control lane |
| `MANUAL_REVIEW` | Operator/manager/backoffice review required | Open recovery case |

Validation outcome must be stored separately from provider response status.

## 19. Logging Requirements

All response parsing and mapping events must create immutable logs.

Required log events:

- raw response received;
- raw payload hash generated;
- provider parser selected;
- canonical mapping completed;
- response code mapped;
- mandatory field validation completed;
- duplicate check completed;
- amount/order/store/terminal validation completed;
- validation route selected;
- state transition candidate created or blocked;
- inquiry, compensation, or manual review triggered.

Logs must be linked to the payment intent, response id, order id, store id, provider id, and adapter version.

## 20. Audit Evidence Packet

For every payment response that reaches approval, cancellation, refund, ambiguous, or dispute state, the platform must be able to assemble an evidence packet.

Evidence packet contents:

- payment intent record;
- outbound request metadata;
- raw response payload reference;
- raw payload hash;
- canonical response object;
- response code mapping version;
- field registry mapping version;
- validation result;
- state transition decision;
- inquiry result if performed;
- compensation result if performed;
- receipt/slip evidence;
- operator action log if manual action occurred;
- reconciliation result.

## 21. Change Control

Provider field mappings and response code mappings are production-critical artifacts.

Change control requirements:

- No direct production mapping edit without approval.
- Mapping changes must include sample payloads.
- Mapping changes must include regression test cases.
- Mapping changes must include fallback behavior.
- Mapping changes must specify affected providers and stores.
- Mapping changes must be versioned.
- Rollback plan is required for production activation.
- Mapping drift must trigger provider review.

## 22. Provider Certification Requirement

Before a provider is allowed into production, the provider must supply or validate:

- approval success response sample;
- approval decline response sample;
- approval timeout behavior;
- cancellation success response sample;
- cancellation failure response sample;
- duplicate request behavior;
- duplicate response behavior;
- inquiry response sample;
- settlement or batch export sample if applicable;
- receipt/slip sample;
- response code list;
- error code list;
- field length and encoding rules;
- timestamp timezone rules;
- signature or integrity verification method where available.

A provider without field registry and response code registry cannot be treated as production-ready.

## 23. Non-Compliance Handling

If a provider cannot supply sufficient response metadata, the integration must be classified as high-risk.

Possible controls:

- pilot-only activation;
- store-limited activation;
- transaction amount cap;
- manual settlement review;
- mandatory inquiry before confirmation;
- restricted payment methods;
- enhanced receipt capture;
- daily reconciliation gate;
- contract escalation.

## 24. Closeout Criteria

This specification is considered satisfied only when:

- canonical response object is implemented;
- raw payload preservation is enabled;
- provider-specific field mapping registry exists;
- response code registry exists;
- approval/cancel/receipt/trace metadata are captured;
- duplicate response detection is enabled;
- ambiguous response routing is enabled;
- audit packet generation is possible;
- provider certification samples are stored;
- mapping change control is active.

## 25. Handoff

This document hands off to:

- `70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md` for amount and order validation policy;
- `70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md` for timeout and ambiguous state control;
- `70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md` for operational recovery;
- `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md` for audit evidence and tamper checking.
