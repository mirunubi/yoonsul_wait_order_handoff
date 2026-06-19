# 070240_Policy_External_RPC_API_Webhook_Signature_Timestamp_Replay_And_Quarantine_Control.md

## Document Metadata

- Project: yoonsul_wait_order_handoff
- Document Number: 70240
- Document Type: Policy
- Domain: External Integration Control Plane
- Lane: RPC / API / Webhook Response Contract And Event Control
- Status: Draft
- Parent Index: 70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md
- Previous: 70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md
- Next: 70250_Policy_External_RPC_API_Webhook_Deduplication_Idempotency_And_Event_Order_Control.md

---

## 1. Purpose

This policy defines how external RPC, API, and Webhook events must be validated for signature integrity, timestamp freshness, replay risk, and quarantine eligibility before any internal state mutation is allowed.

The purpose is to ensure that external events from POS, VAN, PG, payment providers, delivery apps, membership providers, kiosk vendors, KDS vendors, settlement processors, tax/accounting systems, and future external partners cannot directly alter internal ledgers unless the event passes controlled authenticity and freshness checks.

---

## 2. Core Principle

External events are not trusted facts.

They are inbound claims that must pass:

1. reception logging,
2. canonical envelope normalization,
3. signature validation,
4. timestamp window validation,
5. replay detection,
6. duplicate/idempotency detection,
7. provider contract validation,
8. quarantine routing when validation fails.

Only after these gates may a downstream internal state authority decide whether an internal order, payment, settlement, membership, delivery, or accounting state may be changed.

---

## 3. Scope

This policy applies to all external inbound or returned events including, but not limited to:

- POS RPC responses,
- VAN approval and cancel responses,
- PG confirm, cancel, refund, and webhook events,
- simple pay callbacks,
- Alipay / WeChatPay cross-border callbacks,
- card acquirer / issuer status events,
- settlement file arrival notices,
- delivery app order status callbacks,
- external order app callbacks,
- membership / coupon / point provider callbacks,
- kiosk vendor health or payment events,
- KDS vendor fulfillment events,
- tax/accounting integration acknowledgements,
- provider incident or correction events.

---

## 4. Non-Negotiable Rules

### 4.1 No Direct State Mutation

An inbound event must not directly update internal business state.

Forbidden examples:

- Webhook says `paid`, therefore order becomes paid immediately.
- RPC response says `success`, therefore payment is confirmed immediately.
- Delivery app callback says `cancelled`, therefore internal order is cancelled immediately.
- Membership provider says `point_used`, therefore internal point state is finalized immediately.

All external events must first pass the validation and quarantine policy defined in this document.

### 4.2 Raw Payload Must Be Preserved

The system must store the raw inbound payload before transformation.

Required evidence fields:

- raw_payload,
- raw_header,
- received_at,
- provider_id,
- endpoint_id,
- source_ip or network metadata where available,
- request_id or delivery_id where available,
- computed_payload_hash,
- signature header value,
- timestamp header value,
- validation_result,
- quarantine_status.

### 4.3 Signature Failure Is Not a Business Failure

A signature failure must not be treated as payment failure, order failure, or delivery failure.

It must be treated as an external event authenticity failure and routed to quarantine.

### 4.4 Timestamp Failure Is Not a Business Failure

A timestamp failure must not alter payment, order, delivery, membership, or settlement state.

It must be routed to quarantine unless the provider contract explicitly allows delayed delivery and the event can be validated through inquiry or reconciliation.

### 4.5 Replay Detection Must Precede State Authority

Replay detection must be performed before any internal state authority receives the event for business decisioning.

---

## 5. Signature Validation Model

### 5.1 Provider-Specific Signature Registry

Each external provider must have a signature profile registered before production activation.

Minimum registry fields:

| Field | Required | Description |
|---|---:|---|
| provider_id | Yes | External provider identifier |
| integration_channel | Yes | RPC, REST API, Webhook, file callback, polling callback |
| signature_algorithm | Yes | HMAC-SHA256, RSA, ECDSA, provider-specific scheme, etc. |
| signature_header | Yes | Header or field where signature is located |
| timestamp_header | Conditional | Header or field where provider timestamp is located |
| signing_payload_rule | Yes | Exact canonical string or body used for signing |
| secret_or_key_reference | Yes | Vault reference only; never store secret in document or code |
| key_rotation_policy | Yes | Rotation interval and overlap behavior |
| allowed_clock_skew_seconds | Yes | Acceptable clock skew window |
| replay_window_seconds | Yes | Validity window for replay detection |
| failure_action | Yes | Quarantine, reject, accept-with-inquiry, or manual review |

### 5.2 Canonical Signing Payload

The signing payload must be deterministic.

Allowed signing payload models include:

- raw body bytes,
- timestamp + raw body,
- method + path + timestamp + raw body,
- provider delivery id + timestamp + raw body,
- file hash + manifest timestamp.

The exact rule must be stored in the provider signature registry.

If the canonical signing payload cannot be reproduced reliably, the provider must not be promoted to production without compensating controls.

### 5.3 Secret Handling

Signature secrets and private keys must not be stored in Markdown documents, source code, configuration files, logs, screenshots, or support tickets.

Only vault references are allowed.

Secret rotation must support overlap windows where old and new keys can both validate events during provider cutover.

---

## 6. Timestamp Freshness Control

### 6.1 Required Timestamp Check

When the provider supports a timestamp header or timestamp field, the system must verify:

- timestamp format,
- timestamp parseability,
- timestamp timezone assumption,
- received_at minus provider_timestamp,
- future timestamp tolerance,
- stale timestamp tolerance,
- provider-specific allowed delay.

### 6.2 Default Timestamp Windows

Default windows must be conservative unless provider contract states otherwise.

| Event Class | Default Freshness Window | Default Action on Failure |
|---|---:|---|
| Payment approval/cancel webhook | 5 minutes | Quarantine + inquiry |
| Payment status correction | 30 minutes | Quarantine + provider inquiry |
| Delivery/order status callback | 15 minutes | Quarantine + channel status inquiry |
| Membership/coupon/point event | 10 minutes | Quarantine + ledger inquiry |
| Settlement file notification | 24 hours | Quarantine + file manifest verification |
| Provider incident/correction notice | Contract-defined | Manual review |

### 6.3 Future Timestamp

Events with provider timestamps in the future must be quarantined unless the offset is within the allowed clock skew.

Future timestamp events must not be used to establish payment/order/settlement state.

---

## 7. Replay Detection

### 7.1 Replay Identifier

Replay detection must use one or more of the following:

- provider delivery id,
- webhook event id,
- RPC response id,
- transaction id,
- approval number,
- cancel number,
- payment key,
- provider trace id,
- raw payload hash,
- signature digest,
- canonical envelope hash,
- file manifest hash.

### 7.2 Replay Cache and Ledger

Replay detection must not rely only on short-lived memory cache.

The system must maintain:

1. short-lived replay cache for fast rejection,
2. persistent inbound event ledger for audit and long-term duplicate detection,
3. provider-specific replay window rules.

### 7.3 Replay Classification

Replay-like events must be classified as one of the following:

| Classification | Meaning | Action |
|---|---|---|
| benign_duplicate | Provider retry of already accepted event | Return idempotent acknowledgement |
| stale_duplicate | Old event delivered after business state changed | Quarantine or ignore with evidence |
| malicious_replay_suspected | Signature/timestamp/event id pattern indicates abuse | Quarantine + security alert |
| correction_event | Provider intentionally corrected previous event | Manual or contract-based correction workflow |
| unknown_replay | Cannot determine intent | Quarantine |

---

## 8. Quarantine Policy

### 8.1 Quarantine Triggers

An event must be quarantined when any of the following occurs:

- missing signature when signature is required,
- invalid signature,
- unsupported signature algorithm,
- missing timestamp when required,
- stale timestamp outside allowed window,
- future timestamp outside allowed skew,
- replay detected outside idempotent retry window,
- provider id mismatch,
- endpoint id mismatch,
- event type not registered,
- canonical envelope cannot be parsed,
- required field missing,
- trace id conflicts with existing event,
- transaction id maps to another store/order/payment,
- raw payload hash mismatch,
- provider key is expired or revoked,
- source endpoint is disabled,
- suspected tampering or payload mutation.

### 8.2 Quarantine State

Quarantined events must be stored with explicit state.

Allowed quarantine states:

```text
QUARANTINED_SIGNATURE_FAILED
QUARANTINED_TIMESTAMP_STALE
QUARANTINED_TIMESTAMP_FUTURE
QUARANTINED_REPLAY_SUSPECTED
QUARANTINED_PROVIDER_MISMATCH
QUARANTINED_SCHEMA_INVALID
QUARANTINED_FIELD_MISSING
QUARANTINED_TRACE_CONFLICT
QUARANTINED_KEY_REVOKED
QUARANTINED_MANUAL_REVIEW
QUARANTINED_PENDING_INQUIRY
QUARANTINED_RELEASED_AFTER_REVIEW
QUARANTINED_REJECTED_FINAL
```

### 8.3 Quarantine Must Preserve Evidence

Quarantine must preserve:

- original raw event,
- validation result,
- failed rule id,
- provider profile version,
- signature profile version,
- canonical envelope version,
- reviewer action if manually released,
- inquiry result if later resolved,
- downstream state mutation if eventually allowed.

---

## 9. Provider Inquiry and Quarantine Release

A quarantined event may only be released when one of the following is true:

1. provider inquiry confirms the event,
2. settlement/reconciliation confirms the event,
3. manual review confirms the event with required evidence,
4. provider contract defines the event as delayed-but-valid,
5. a known provider migration or key rotation issue is confirmed.

Release must not overwrite the original validation failure.

The final record must show both:

- the original quarantine reason,
- the later release reason.

---

## 10. ACK/NACK Interaction

ACK/NACK behavior must be separated from business acceptance.

A system may return HTTP 200 to prevent provider retry storms after raw logging, while still routing the event to quarantine for validation failure.

However, when provider contracts require NACK for signature failure, the endpoint may return 4xx after raw evidence capture.

ACK must mean one of the following, never more:

```text
ACK_RECEIVED_ONLY
ACK_RECEIVED_AND_QUEUED
ACK_DUPLICATE_ALREADY_PROCESSED
ACK_REJECTED_WITH_EVIDENCE
```

ACK must not mean:

```text
payment confirmed
order completed
settlement accepted
membership point finalized
delivery state finalized
```

---

## 11. Required Logs

Every signature/timestamp/replay decision must create audit log entries.

Minimum log fields:

| Field | Description |
|---|---|
| event_id | Internal inbound event id |
| provider_id | External provider id |
| endpoint_id | Receiving endpoint |
| event_type | Canonical event type |
| received_at | Internal receive timestamp |
| provider_timestamp | Timestamp from provider |
| signature_present | Whether signature was present |
| signature_valid | Whether signature validated |
| timestamp_valid | Whether timestamp window passed |
| replay_detected | Whether replay was detected |
| replay_classification | Duplicate/replay classification |
| quarantine_state | Quarantine state if any |
| validation_profile_version | Rule profile used |
| raw_payload_hash | Hash of original payload |
| canonical_envelope_hash | Hash of normalized envelope |
| decision_actor | System, reviewer, batch, inquiry worker |
| decision_at | Time of decision |

---

## 12. Security Escalation

The following must trigger security escalation:

- repeated invalid signature from same source,
- valid signature but malformed payload pattern,
- repeated replay attempts outside provider retry pattern,
- timestamp manipulation pattern,
- provider id spoofing attempt,
- endpoint disabled but receiving traffic,
- revoked key still being used,
- sudden spike in quarantined events,
- event payload referencing another store or tenant.

Escalation target:

- Security Incident lane,
- External Integration Incident lane,
- Provider Contract Review lane,
- Payment Integrity lane when money state may be affected.

---

## 13. Integration With Payment Integrity Architecture

This policy provides the authenticity and freshness gate for the 75000 Payment Integrity Architecture lane.

The 75000 lane must not consume external events unless this 70240 policy or a stricter provider-specific policy has validated or quarantined the event.

Related future documents:

- 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md
- 75100_Index_Payment_Idempotency_Duplicate_Prevention_And_Request_Correlation_Governance.md
- 75200_Index_Payment_Net_Cancel_Delayed_Reversal_And_Self_Healing_Recovery_Governance.md
- 75300_Index_Payment_Saga_Orchestration_Compensation_And_Distributed_Transaction_Control.md
- 75400_Index_Transactional_Outbox_CDC_Event_Relay_And_Dual_Write_Integrity_Governance.md

---

## 14. Cursor Generation Guardrails

When generating follow-up documents from this policy, automation tools must not invent provider-specific signature rules.

Provider-specific algorithms, keys, timestamps, allowed windows, ACK behavior, and replay behavior must be marked as TODO unless confirmed by official provider documents or contract evidence.

Mandatory generation instruction:

```text
Do not invent external provider security behavior.
If provider-specific signature, timestamp, replay, or ACK policy is unknown, mark it as GAP_PROVIDER_CONFIRMATION_REQUIRED.
```

---

## 15. Closeout Criteria

This policy is considered implemented only when:

- every external endpoint has a registered signature/timestamp/replay profile,
- raw event logging is active before validation,
- invalid events are quarantined before state mutation,
- replay cache and persistent inbound ledger both exist,
- ACK semantics are documented per provider,
- quarantine release requires inquiry, reconciliation, or manual evidence,
- security escalation triggers are wired,
- audit logs are immutable and searchable,
- downstream state authorities reject unvalidated inbound events.

---

## 16. Handoff

This document hands off to:

- 70250_Policy_External_RPC_API_Webhook_Deduplication_Idempotency_And_Event_Order_Control.md

The next document must define how accepted inbound events are deduplicated, correlated with idempotency keys, ordered when providers deliver events out of sequence, and safely forwarded to downstream state authorities.
