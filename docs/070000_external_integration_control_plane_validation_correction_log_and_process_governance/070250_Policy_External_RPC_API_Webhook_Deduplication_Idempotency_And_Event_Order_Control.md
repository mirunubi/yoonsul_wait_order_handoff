# 070250_Policy_External_RPC_API_Webhook_Deduplication_Idempotency_And_Event_Order_Control.md

## 1. Purpose

This policy defines how the yoonsul_wait_order_handoff platform controls duplicate, repeated, delayed, reordered, and conflicting inbound events received through external RPC, API, and Webhook integrations.

The purpose of this document is to ensure that external events from POS, VAN, PG, payment providers, delivery apps, external order channels, membership providers, coupon systems, kiosk vendors, KDS vendors, tax/accounting systems, and settlement providers cannot create duplicate internal state transitions or financial inconsistencies.

External providers may retry, replay, reorder, delay, batch, or resend events. The platform must accept this as normal external behavior and protect internal order, payment, settlement, inventory, customer claim, and audit ledgers through deduplication, idempotency, and event ordering controls.

## 2. Scope

This policy applies to all external inbound event paths under the External Integration Control Plane, including:

- RPC response callbacks.
- REST API asynchronous responses.
- Payment gateway Webhooks.
- POS and VAN payment status callbacks.
- Cancel, refund, reversal, and net cancel callbacks.
- Delivery app order status events.
- External order app reservation, waitlist, and order state events.
- Membership, point, coupon, voucher, and benefit events.
- Kiosk and KDS device status events.
- External accounting, tax, settlement, and deposit status events.
- Provider retry and reconciliation feed events.

This document does not define provider-specific business meaning. Provider-specific event mapping must be defined in the relevant field registry, canonical mapping, or integration specification documents.

## 3. Parent And Related Documents

- Parent Index: `70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md`
- Previous: `70240_Policy_External_RPC_API_Webhook_Signature_Timestamp_Replay_And_Quarantine_Control.md`
- Next: `70260_Policy_External_RPC_API_Webhook_Event_Order_State_Machine_And_Late_Arrival_Control.md`
- Root Index: `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- Generation Rules: `70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md`
- Related Payment Integrity Root: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

An external event is not allowed to mutate internal state merely because it was received.

Every external event must pass the following control chain:

```text
receive
→ preserve raw payload
→ verify signature and timestamp
→ identify provider and subject
→ compute deduplication key
→ check idempotency ledger
→ evaluate event order
→ evaluate allowed state transition
→ apply state mutation once
→ record outcome and evidence
```

Duplicate delivery is expected. Reordered delivery is expected. Delayed delivery is expected. Provider retries are expected. Internal state must remain deterministic despite these conditions.

## 5. Definitions

| Term | Definition |
|---|---|
| Duplicate Event | Same provider event delivered more than once. |
| Retry Event | Event resent by provider due to missing ACK, timeout, or provider retry policy. |
| Replay Event | Previously valid event resent outside allowed time or sequence context. |
| Late Arrival | Event that arrives after a newer internal or external state has already been accepted. |
| Out-of-Order Event | Event whose sequence, version, timestamp, or state transition is older than the current accepted state. |
| Idempotency | Guarantee that repeated processing of the same logical event produces the same internal result without duplicate side effects. |
| Deduplication Key | Deterministic key used to detect whether the same logical event has already been received or processed. |
| State Authority | Internal component authorized to apply canonical state transitions after validation. |

## 6. Required Deduplication Key Strategy

Each inbound event must be assigned a canonical deduplication key before processing.

The preferred key hierarchy is:

```text
1. provider_event_id
2. provider_transaction_id + event_type + event_version
3. provider_transaction_id + status + event_timestamp
4. internal_subject_id + external_subject_id + event_type + amount + occurred_at
5. raw_payload_hash + provider_id + received_route
```

When a provider supplies a stable event ID, that ID must be used as the primary deduplication key. When a provider does not supply a reliable event ID, the platform must construct a deterministic composite key from canonical fields.

If no safe deduplication key can be derived, the event must not be processed automatically. It must be placed into `DEDUP_KEY_UNRESOLVED` quarantine.

## 7. Idempotency Ledger

All externally received events must be recorded in an idempotency ledger before state mutation.

Minimum required fields:

```text
event_id
provider_id
provider_event_id
canonical_event_type
subject_type
subject_id
external_subject_id
deduplication_key
raw_payload_hash
signature_status
timestamp_status
first_received_at
last_received_at
received_count
processing_status
processing_result
state_transition_result
side_effect_reference_id
quarantine_reason
```

The idempotency ledger must support the following statuses:

```text
RECEIVED
DUPLICATE_RECEIVED
PROCESSING
PROCESSED_SUCCESS
PROCESSED_NOOP
PROCESSED_REJECTED
ORDER_BLOCKED
STATE_TRANSITION_BLOCKED
QUARANTINED
MANUAL_REVIEW_REQUIRED
```

## 8. Duplicate Event Handling

If the same deduplication key has already been successfully processed, the platform must not execute side effects again.

Examples of forbidden duplicate side effects:

- Marking the same payment as confirmed twice.
- Issuing duplicate kitchen tickets.
- Applying the same coupon redemption twice.
- Deducting the same point balance twice.
- Creating duplicate refunds.
- Reopening a closed claim based on duplicate provider callback.
- Creating duplicate settlement adjustment rows.

Duplicate events must be logged as duplicates and linked to the first accepted event.

Allowed duplicate response behavior:

```text
- return provider-compatible ACK if required
- preserve duplicate raw payload
- increment received_count
- return the original processing result internally
- produce no new business side effect
```

## 9. Event Order Control

External event ordering must be evaluated independently from provider delivery order.

The platform must determine order using the best available authority:

```text
1. provider sequence number
2. provider event version
3. provider occurred_at timestamp
4. provider status transition graph
5. internal subject state version
6. internal received_at timestamp as last resort only
```

`received_at` must not be treated as business event order unless no better ordering information exists.

## 10. Late Arrival Policy

A late-arriving event must not overwrite a newer confirmed internal state.

Examples:

| Current Internal State | Late Event | Required Result |
|---|---|---|
| PAYMENT_CONFIRMED | PAYMENT_PENDING | No-op, log late event. |
| PAYMENT_CANCELLED | PAYMENT_APPROVED | Quarantine or reconciliation review. |
| ORDER_COMPLETED | ORDER_ACCEPTED | No-op, preserve raw payload. |
| REFUND_COMPLETED | CANCEL_REQUESTED | No-op or review depending on provider semantics. |
| SETTLEMENT_RECONCILED | SETTLEMENT_PENDING | Block state regression. |

Late events that reveal a possible external/internal mismatch must be routed to reconciliation or manual review instead of being silently discarded.

## 11. State Regression Prohibition

External events may not regress internal state without an explicit compensation or correction workflow.

Forbidden examples:

```text
CONFIRMED → PENDING
COMPLETED → ACCEPTED
CANCELLED → APPROVED
REFUNDED → CANCEL_REQUESTED
RECONCILED → UNRECONCILED
```

If a regression appears necessary due to provider correction, the platform must create a separate correction event, not overwrite historical state.

## 12. Concurrency Control

The system must prevent two workers from processing the same logical event or subject simultaneously in a way that creates duplicate side effects.

Required controls:

- Unique constraint on deduplication key.
- Atomic insert-or-read behavior for idempotency ledger.
- Subject-level lock or state version check for critical payment/order/membership/settlement transitions.
- Optimistic concurrency control using state version where possible.
- Deadlock-safe retry with bounded retry count.
- No blind update based only on external payload.

## 13. Provider Retry Compatibility

Some providers retry Webhooks until they receive a successful ACK. The platform must separate ACK behavior from business acceptance.

A received event may be ACKed to stop provider retry while still being internally quarantined, provided that:

- Raw payload is preserved.
- Signature and source are recorded.
- Quarantine reason is recorded.
- The event is visible to monitoring and review workflows.
- No unauthorized state mutation occurs.

Events that fail authentication or signature validation must follow the security/quarantine policy defined in `70240`.

## 14. Event Processing Outcomes

Every inbound event must end with exactly one processing outcome.

| Outcome | Meaning |
|---|---|
| ACCEPTED_AND_APPLIED | Event validated and state transition applied. |
| ACCEPTED_NOOP_DUPLICATE | Duplicate event accepted but no side effect executed. |
| ACCEPTED_NOOP_LATE | Late event preserved but did not change state. |
| ACCEPTED_RECONCILIATION_REQUIRED | Event preserved; mismatch requires reconciliation. |
| REJECTED_INVALID_SIGNATURE | Event rejected by signature policy. |
| REJECTED_INVALID_ENVELOPE | Required canonical envelope fields missing. |
| QUARANTINED_UNSAFE_ORDER | Event order is unsafe or contradictory. |
| QUARANTINED_DEDUP_UNRESOLVED | Deduplication key cannot be safely derived. |
| MANUAL_REVIEW_REQUIRED | Automation cannot safely decide. |

## 15. Observability And Logging Requirements

The platform must log the following for every event:

```text
provider_id
route_id
event_type
deduplication_key
raw_payload_hash
signature_result
timestamp_result
replay_result
idempotency_result
ordering_result
state_transition_result
ack_result
quarantine_result
operator_review_reference
```

Monitoring must expose:

- Duplicate event rate by provider.
- Late event rate by provider.
- Out-of-order event rate by provider.
- Deduplication unresolved count.
- State transition blocked count.
- Quarantine backlog.
- Manual review backlog.
- Provider retry storm indicators.

## 16. Prohibited Practices

The following practices are prohibited:

- Applying internal state changes directly inside the Webhook controller without idempotency ledger check.
- Treating `received_at` as authoritative event order when provider sequence/version exists.
- Deleting duplicate events without raw payload preservation.
- Retrying unsafe state mutation blindly after duplicate key conflict.
- Overwriting confirmed internal state with older external state.
- Reusing one idempotency key across different business actions.
- Using only amount and timestamp as deduplication key for payment events when stronger identifiers exist.
- Returning failure to provider solely because internal business processing is delayed, when safe ACK and async validation are possible.

## 17. Minimum Acceptance Criteria

A route may be production-enabled only if all of the following are satisfied:

- Deduplication key strategy is documented.
- Idempotency ledger write occurs before state mutation.
- Duplicate event replay test passes.
- Out-of-order event test passes.
- Late event state regression test passes.
- Provider retry test passes.
- Raw payload preservation test passes.
- Manual review routing exists for unresolved cases.
- Monitoring dashboard includes duplicate, late, out-of-order, and quarantine metrics.

## 18. Handoff

This policy hands off to:

- `70260_Policy_External_RPC_API_Webhook_Event_Order_State_Machine_And_Late_Arrival_Control.md` for deeper state machine and late arrival control.
- `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md` for payment-specific inquiry and unknown state recovery.
- `70700_Index_External_Webhook_Callback_Idempotency_And_Event_Delivery_Control.md` for broader callback delivery and retry governance.
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` for payment integrity architecture dependencies.

## 19. Closeout

External event duplication and reordering are normal conditions, not exceptional conditions. The platform must assume that external providers will resend, delay, reorder, and correct events. Internal state must therefore be protected by deterministic deduplication, idempotency, event ordering, state transition validation, and auditable no-op handling.
