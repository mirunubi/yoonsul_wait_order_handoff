# 070230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md

## 1. Purpose

This specification defines the canonical event envelope, normalized field registry, signature verification metadata, and trace requirements for all external RPC, API, and Webhook events entering the yoonsul_wait_order_handoff External Integration Control Plane.

External providers may send different payload formats, response codes, callback signatures, timestamps, and retry identifiers. This document prevents provider-specific payloads from directly mutating internal order, payment, settlement, membership, coupon, delivery, kiosk, KDS, tax, or accounting state.

All inbound external events must be wrapped into a canonical envelope before validation, routing, correction, reconciliation, compensation, or operator action.

## 2. Scope

This document applies to inbound and callback events from:

- POS providers
- VAN providers
- PG providers
- simplified payment providers
- Alipay, WeChat Pay, and cross-border payment providers
- card acquirers and issuing-network intermediaries
- settlement file providers
- external order apps
- delivery apps
- kiosk vendors
- KDS vendors
- external membership, coupon, point, and voucher providers
- tax, accounting, ERP, and bank-deposit integrations
- webhook-based operational platforms

This document does not define final business state transition rules. Final state authority is governed by:

- `70210_Governance_External_RPC_API_Webhook_Trust_Boundary_And_State_Authority.md`
- `70220_Policy_External_RPC_API_Webhook_Inbound_Event_Reception_Raw_Log_And_Acknowledgement.md`
- `70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md`
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 3. Core Principle

External payloads are evidence, not authority.

The system must not write external provider fields directly into core domain state. Every inbound external event must pass through the following sequence:

1. raw reception
2. raw payload preservation
3. canonical envelope creation
4. signature and timestamp verification
5. provider field normalization
6. duplicate and replay detection
7. validation queue routing
8. domain-specific validation
9. internal state decision by the authorized state gate

## 4. Canonical Envelope Required Fields

Every external event must be transformed into the following canonical envelope.

| Field | Required | Description |
|---|---:|---|
| `external_event_id` | Yes | Internal immutable event identifier generated at reception. |
| `provider_event_id` | Conditional | Provider-supplied event id, webhook id, transaction id, callback id, or message id. |
| `provider_type` | Yes | POS, VAN, PG, DELIVERY_APP, MEMBERSHIP, KIOSK_VENDOR, KDS_VENDOR, ACCOUNTING, TAX, BANK, OTHER. |
| `provider_name` | Yes | Provider name or configured integration alias. |
| `integration_contract_id` | Yes | Internal contract/config version used to parse this event. |
| `event_family` | Yes | PAYMENT, ORDER, CANCEL, REFUND, SETTLEMENT, MEMBERSHIP, COUPON, DELIVERY, DEVICE, ACCOUNTING, TAX, OPERATIONAL. |
| `event_type` | Yes | Canonical event type after provider mapping. |
| `event_version` | Yes | Canonical schema version. |
| `raw_payload_hash` | Yes | Hash of the original payload bytes. |
| `raw_payload_ref` | Yes | Storage reference to the preserved raw payload. |
| `received_at` | Yes | Server-side receipt timestamp. |
| `provider_created_at` | Conditional | Provider-side event creation timestamp when available. |
| `provider_sent_at` | Conditional | Provider-side send timestamp when available. |
| `signature_status` | Yes | VERIFIED, FAILED, MISSING, NOT_SUPPORTED, SKIPPED_BY_POLICY. |
| `timestamp_status` | Yes | VALID, SKEWED, MISSING, EXPIRED, FUTURE_DATED. |
| `replay_status` | Yes | UNIQUE, DUPLICATE, REPLAY_SUSPECTED, UNKNOWN. |
| `idempotency_key` | Conditional | Idempotency key, request id, operation id, or generated fallback key. |
| `correlation_id` | Conditional | Correlation id joining request, response, webhook, inquiry, settlement, and compensation. |
| `trace_id` | Conditional | Provider or internal distributed trace identifier. |
| `canonical_mapping_status` | Yes | MAPPED, PARTIAL, UNKNOWN_EVENT, UNSUPPORTED_VERSION, PARSE_FAILED. |
| `validation_status` | Yes | PENDING, PASSED, FAILED, MANUAL_REVIEW, QUARANTINED. |
| `state_authority_status` | Yes | NO_AUTHORITY, PENDING_STATE_GATE, APPROVED_BY_STATE_GATE, REJECTED_BY_STATE_GATE. |

## 5. Canonical Event Families

| Event Family | Description | Examples |
|---|---|---|
| `PAYMENT` | Approval, capture, authorization, confirmation, timeout, payment status update. | PG confirm result, VAN approval response, POS payment callback. |
| `CANCEL` | Payment cancel, net cancel, void, reversal. | payment void result, timeout reversal event. |
| `REFUND` | Full or partial refund, manual refund, delayed refund. | refund success, refund rejected, bank refund pending. |
| `ORDER` | External order intake or order status callback. | delivery app order accepted, order cancelled, external table order update. |
| `SETTLEMENT` | Settlement, deposit, fee, deduction, set-off, settlement file event. | D+2 deposit file, fee deduction, chargeback adjustment. |
| `MEMBERSHIP` | Member lookup, point use, point earn, membership validation. | external point deduction, loyalty grade response. |
| `COUPON` | Coupon validation, redemption, rollback, voucher status. | coupon used, coupon rollback failed. |
| `DELIVERY` | Delivery app order, rider status, pickup, cancel, fee update. | delivery order received, rider assigned. |
| `DEVICE` | Kiosk, CAT, POS agent, KDS, printer, scanner, or terminal status. | CAT disconnected, KDS ack timeout. |
| `ACCOUNTING` | Accounting, ERP, tax, invoice, revenue ledger event. | tax invoice issued, accounting journal accepted. |
| `OPERATIONAL` | Provider health, SLA, credential, maintenance, throttling, outage. | provider outage notice, rate limit event. |

## 6. Signature Registry

Each provider integration must declare its signature model in the provider registry.

| Signature Model | Required Controls |
|---|---|
| HMAC header signature | Verify algorithm, key id, payload bytes, timestamp, and replay window. |
| asymmetric signature | Verify public key version, certificate chain if applicable, payload bytes, and timestamp. |
| mTLS-only | Verify client certificate identity and integration contract binding. |
| bearer token only | Treat as weak authentication; require IP allowlist, replay controls, and elevated monitoring. |
| no signature supported | Must be classified as high-risk and routed through stricter validation and reconciliation. |

Signature failure must not be silently ignored. The event must be preserved as raw evidence and then routed to `QUARANTINED` or `MANUAL_REVIEW` according to provider risk class.

## 7. Timestamp And Replay Control

Inbound events must be checked for replay risk.

Minimum controls:

- server-side `received_at` must always be recorded
- provider timestamp must be checked when available
- allowed clock skew must be configured per provider
- duplicate `provider_event_id` must be detected
- duplicate raw payload hash within the replay window must be detected
- old but newly delivered events must not directly alter state
- future-dated events must be quarantined unless provider-specific policy allows them

Default replay decision:

| Condition | Result |
|---|---|
| Same `provider_event_id`, same payload hash | DUPLICATE; return previous processing result when safe. |
| Same `provider_event_id`, different payload hash | REPLAY_SUSPECTED; quarantine and alert. |
| Missing provider id, same raw hash | DUPLICATE_CANDIDATE; route to idempotency check. |
| Timestamp beyond allowed window | EXPIRED or FUTURE_DATED; no direct state authority. |

## 8. Canonical Field Mapping Rules

Provider fields must be mapped into canonical fields using an explicit versioned mapping table.

Rules:

1. provider-specific fields must not become internal domain fields without mapping
2. unknown fields must be preserved in raw payload but not trusted
3. required canonical fields missing from the provider payload must be marked as `PARTIAL`
4. provider response codes must be mapped to canonical response codes
5. provider status strings must be mapped to canonical states only by approved mapping rules
6. lossy transformation must be flagged
7. schema version changes must require registry update

## 9. Payment Canonical Field Examples

| Canonical Field | Examples From Providers | Required Use |
|---|---|---|
| `approval_no` | approval number, auth number, 승인번호 | Evidence and reconciliation. |
| `transaction_id` | paymentKey, tid, vanTraceNo, pgTxId | Request-response matching. |
| `merchant_id` | MID, 가맹점번호, store merchant id | Merchant boundary validation. |
| `terminal_id` | TID, CAT id, terminalNo | Device and store validation. |
| `approved_amount` | amount, totalAmount, approvalAmount | Amount validation. |
| `response_code` | resultCode, vanCode, pgStatusCode | Canonical response mapping. |
| `response_message` | message, resultMessage | Human-readable evidence only. |
| `receipt_no` | receiptNo, slipNo | Receipt evidence. |
| `acquirer` | card acquirer, 매입사 | Settlement and dispute evidence. |
| `card_masked_no` | maskedCardNumber | Display/evidence only; never full PAN. |

## 10. Event Quarantine Conditions

An inbound event must be quarantined when any of the following occurs:

- signature verification failed
- payload hash cannot be generated
- provider identity cannot be resolved
- payload cannot be parsed
- required integration contract is missing
- provider event id collides with different payload
- event timestamp is outside the allowed policy window
- provider status cannot be mapped to canonical status
- event attempts to mutate unauthorized domain state
- payment event lacks minimum financial evidence fields
- duplicate event conflicts with a previously confirmed result

Quarantined events must remain queryable for audit and incident response.

## 11. Acknowledgement Relationship

ACK to an external provider means only:

- the event was received
- the raw payload was preserved or safely rejected according to reception policy
- the event was accepted into the internal validation pipeline if eligible

ACK does not mean:

- internal business state was changed
- payment was confirmed
- order was completed
- refund was finalized
- settlement was reconciled
- accounting was posted

This distinction must be reflected in operational logs, support UI, and provider-facing contract wording.

## 12. Storage And Retention

The following must be retained according to audit and legal hold policy:

- original raw payload bytes
- raw payload hash
- headers used for signature verification
- signature verification result
- provider timestamp and server receipt timestamp
- canonical envelope
- mapping version
- validation result
- state gate decision
- operator override if any
- correction, replay, inquiry, compensation, and reconciliation references

Sensitive values must be masked, tokenized, or encrypted according to data classification policy.

## 13. Observability Requirements

Each canonical envelope must produce metrics and logs for:

- inbound event count by provider
- parse failures
- signature failures
- replay suspicions
- duplicate events
- mapping failures
- validation failures
- quarantined events
- delayed events
- state gate rejects
- provider retry storms
- ACK/NACK ratio

Alerts must be configured for provider-specific anomaly thresholds.

## 14. Implementation Notes

Recommended table groups:

- `external_event_raw_log`
- `external_event_envelope`
- `external_event_signature_check`
- `external_event_mapping_result`
- `external_event_replay_index`
- `external_event_validation_queue`
- `external_event_quarantine`
- `external_event_state_gate_decision`

Recommended immutable identifiers:

- `external_event_id`
- `integration_contract_id`
- `mapping_version`
- `raw_payload_hash`
- `correlation_id`
- `idempotency_key`

## 15. Gap Register

| Gap | Required Follow-up |
|---|---|
| Provider-specific signature algorithms not yet registered | Create provider-level registry documents under 70240~70280. |
| Provider retry and ACK policy differences | Define provider-specific ACK contracts. |
| Payment-specific canonical status mapping | Link to 70130 and future 70400 mapping documents. |
| Delivery app and membership event schemas | Expand under 71000 and 71200 bands. |
| Settlement file canonical envelope | Expand under 70600 and 71600 bands. |
| Outbox/CDC bridge with inbound external event envelope | Cross-link with 75000 payment integrity architecture. |

## 16. Control Checklist

- [ ] Raw payload is stored before parsing.
- [ ] Payload hash is generated from original bytes.
- [ ] Provider identity is resolved.
- [ ] Integration contract version is resolved.
- [ ] Signature status is recorded.
- [ ] Timestamp status is recorded.
- [ ] Replay status is recorded.
- [ ] Canonical envelope is generated.
- [ ] Provider fields are mapped using a versioned registry.
- [ ] Unknown fields are preserved but not trusted.
- [ ] Event is routed to validation queue or quarantine.
- [ ] ACK does not imply business state confirmation.
- [ ] State authority remains with the internal state gate.

## 17. Related Documents

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md`
- `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`
- `70190_Index_POS_VAN_PG_External_Payment_Integration_Closeout_And_Handoff.md`
- `70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md`
- `70210_Governance_External_RPC_API_Webhook_Trust_Boundary_And_State_Authority.md`
- `70220_Policy_External_RPC_API_Webhook_Inbound_Event_Reception_Raw_Log_And_Acknowledgement.md`
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 18. Closeout

This document establishes the canonical envelope and signature registry baseline for all external inbound events. Follow-up documents must define provider-specific validation rules, retry behavior, event quarantine handling, canonical response-code mapping, and replay/idempotency handling.
