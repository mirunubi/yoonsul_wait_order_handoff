# 070280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md

## Document Control

- Document Number: 70280
- Document Type: Audit
- Domain: External Integration Control Plane
- Parent Index: [70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md](./70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md)
- Previous: [70270_Runbook_External_RPC_API_Webhook_Late_Event_Conflict_Quarantine_And_Replay_Action.md](./70270_Runbook_External_RPC_API_Webhook_Late_Event_Conflict_Quarantine_And_Replay_Action.md)
- Next: [70290_Index_External_RPC_API_Webhook_Response_Contract_Closeout_And_Handoff.md](./70290_Index_External_RPC_API_Webhook_Response_Contract_Closeout_And_Handoff.md)
- Related Root: [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](./70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md)
- Related Generation Rule: [70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md](./70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md)

## 1. Purpose

This audit document defines how external RPC, API, and webhook events must be preserved, hashed, replayed, quarantined, released, and inspected for tampering.

The purpose is to ensure that every external event can be explained after the fact:

- what was received,
- when it was received,
- who or what sent it,
- whether the signature and timestamp were valid,
- whether it was accepted, rejected, quarantined, replayed, or ignored,
- what internal state change it caused,
- who approved any manual replay or quarantine release,
- and whether the evidence chain remained intact.

## 2. Scope

This document applies to every inbound external event received from:

- POS provider RPC callbacks,
- VAN or PG webhooks,
- simple payment and wallet providers,
- card acquirer or issuer callback events,
- settlement file arrival callbacks,
- delivery app order callbacks,
- external ordering channel callbacks,
- kiosk vendor device status callbacks,
- KDS vendor callbacks,
- membership, coupon, voucher, and point providers,
- tax, accounting, ERP, and banking integrations,
- future external provider callbacks integrated under the 70000 namespace.

This document does not define provider-specific business logic. Provider-specific field mapping must be defined in dedicated registry and provider onboarding documents.

## 3. Core Principle

External events are not trusted state changes.

Every external event is first treated as evidence. Only after reception, raw logging, canonical envelope mapping, signature validation, deduplication, state-machine validation, and replay control may it be allowed to influence internal state.

```text
External Event
→ Raw Log
→ Hash
→ Signature / Timestamp / Replay Check
→ Canonical Envelope
→ Validation Gate
→ State Machine Gate
→ Accepted / Ignored / Quarantined / Replay Required
→ Audit Evidence Packet
```

## 4. Mandatory Raw Event Evidence

Every inbound external event must create a raw evidence record before parsing or business processing.

Minimum fields:

```text
external_event_audit_id
provider_id
provider_type
integration_channel
received_at
received_from_ip
http_method
request_path
headers_raw
body_raw
query_string_raw
content_type
payload_size_bytes
transport_trace_id
provider_event_id
provider_transaction_id
provider_timestamp
signature_header
signature_algorithm
raw_payload_hash
canonical_payload_hash
reception_status
ack_status
validation_status
quarantine_status
replay_status
state_change_status
created_at
```

If the raw body cannot be stored due to size, file reference, object storage pointer, and hash must be stored instead.

## 5. Hash Requirements

Every event must have at least two hashes.

| Hash | Description |
|---|---|
| Raw Payload Hash | Hash of the exact inbound payload before parsing, normalization, trimming, decoding, or reformatting |
| Canonical Payload Hash | Hash of the normalized canonical envelope after mapping |

Recommended fields:

```text
raw_payload_hash_algorithm = SHA-256
raw_payload_hash_value
canonical_hash_algorithm = SHA-256
canonical_hash_value
hash_generated_at
hash_generator_version
```

A mismatch between stored raw payload and stored raw hash is a tamper event.

## 6. Signature And Timestamp Evidence

For signed external events, the audit record must preserve:

```text
signature_header_name
signature_header_value
signature_algorithm
provider_public_key_id_or_secret_version
calculated_signature
signature_match_result
provider_timestamp
server_received_at
clock_skew_seconds
timestamp_window_result
```

If signature verification fails, the event must not change internal business state.

Allowed outcomes:

```text
SIGNATURE_VALID
SIGNATURE_INVALID_QUARANTINED
SIGNATURE_MISSING_REJECTED
TIMESTAMP_EXPIRED_QUARANTINED
CLOCK_SKEW_REVIEW_REQUIRED
```

## 7. Replay Evidence

Any replayed event must produce a separate replay audit record.

Minimum fields:

```text
replay_id
source_external_event_audit_id
replay_requested_by
replay_request_reason
replay_approval_id
replay_started_at
replay_completed_at
replay_mode
pre_replay_state
post_replay_state
state_change_result
replay_output_hash
replay_error_code
replay_error_message
```

Replay modes:

```text
NO_STATE_CHANGE_DRY_RUN
VALIDATION_ONLY
STATE_MACHINE_REAPPLY
COMPENSATION_TRIGGER
MANUAL_REVIEW_EXPORT
```

A replay must not create a new external event identity. It must reference the original event.

## 8. Quarantine Evidence

Quarantined events must preserve the reason for quarantine and the release decision.

Quarantine reasons:

```text
INVALID_SIGNATURE
EXPIRED_TIMESTAMP
REPLAY_DETECTED
DUPLICATE_EVENT_ID
LATE_EVENT_STATE_CONFLICT
UNKNOWN_PROVIDER
UNKNOWN_EVENT_TYPE
FIELD_MAPPING_FAILURE
AMOUNT_MISMATCH
TRACE_ID_MISMATCH
STATE_MACHINE_REJECTION
SUSPICIOUS_PAYLOAD
MANUAL_SECURITY_HOLD
```

Quarantine release requires:

```text
quarantine_release_id
released_by
release_reason
release_approval_id
release_time
pre_release_validation_result
allowed_reprocessing_mode
post_release_result
```

No quarantined event may be deleted simply because it was invalid. Invalid events are evidence.

## 9. ACK/NACK Evidence

For webhook channels, the system must record how it responded to the provider.

Mandatory fields:

```text
ack_status
ack_http_status
ack_body_hash
ack_sent_at
ack_latency_ms
nack_reason
provider_retry_expected
provider_retry_count_observed
```

ACK does not mean business acceptance.

ACK means only one of the following:

```text
RECEIVED_AND_LOGGED
RECEIVED_AND_QUEUED
REJECTED_WITH_REASON
TEMPORARY_FAILURE_RETRY_EXPECTED
```

## 10. State Change Evidence

If an external event changes internal state, the system must link the event audit record to state transition records.

Minimum fields:

```text
external_event_audit_id
internal_entity_type
internal_entity_id
pre_state
requested_transition
post_state
state_machine_rule_id
transition_allowed
transition_denied_reason
transition_applied_at
transition_applied_by_service
```

If the event is received but causes no state change, the reason must be recorded.

Examples:

```text
DUPLICATE_ALREADY_APPLIED
LATE_EVENT_OLDER_THAN_CURRENT_STATE
EVENT_TYPE_INFORMATIONAL_ONLY
QUARANTINED_BEFORE_STATE_CHANGE
MAPPING_FAILED
MANUAL_REVIEW_REQUIRED
```

## 11. Tamper Check

Tamper check must be run at minimum:

- on ingestion,
- before replay,
- after replay,
- during daily audit batch,
- during incident investigation,
- before legal evidence export.

Tamper check must verify:

```text
raw payload hash
canonical payload hash
stored header hash
event identity immutability
provider id immutability
received_at immutability
replay chain linkage
quarantine release linkage
state transition linkage
operator approval linkage
```

Any tamper suspicion must create an audit exception.

## 12. Retention And Legal Hold

External event raw logs and replay evidence are financial, operational, and dispute evidence.

Retention class must be assigned by integration type:

| Event Type | Retention Guidance |
|---|---|
| Payment / cancel / refund | Financial-grade retention |
| Settlement / deposit | Accounting and tax retention |
| Delivery app order | Operational and customer dispute retention |
| Membership / coupon / point | Customer claim and liability retention |
| Device status | Incident and operational retention |
| Suspicious / quarantined event | Security and legal hold candidate |

Legal hold must freeze deletion, mutation, and compaction of the relevant evidence chain.

## 13. Prohibited Practices

The following are prohibited:

- overwriting raw payload after parsing,
- storing only parsed business fields without raw body,
- deleting invalid or suspicious events,
- replaying events without an approval record,
- changing internal state from an unverified event,
- treating ACK as final business acceptance,
- manually editing event state without an audit record,
- resolving conflicts by changing provider payload values,
- using provider event time as trusted order time without server receipt time,
- replaying quarantined events directly into production state without validation.

## 14. Audit Queries

The audit system must support the following queries:

```text
Find all events for provider_transaction_id.
Find all events that touched order_id.
Find all duplicate provider_event_id records.
Find all quarantined events by provider and date.
Find all replayed events and their approvers.
Find all events with invalid signature.
Find all events that changed payment state.
Find all late-arrival events rejected by state machine.
Find all ACKed events that never changed business state.
Find all events linked to a customer dispute.
```

## 15. Evidence Packet

A dispute or incident evidence packet must contain:

```text
raw event payload or immutable storage pointer
raw payload hash
canonical envelope
canonical hash
headers
signature verification result
receipt time
provider timestamp
ACK/NACK result
validation result
state transition result
quarantine or replay record
operator approval record
related internal ledger entries
related external provider identifiers
```

## 16. Handoff

This document closes the audit evidence layer for the 70200 external RPC/API/Webhook response contract group.

The next document should close and hand off the 70200 group:

[70290_Index_External_RPC_API_Webhook_Response_Contract_Closeout_And_Handoff.md](./70290_Index_External_RPC_API_Webhook_Response_Contract_Closeout_And_Handoff.md)
