# 070270_Runbook_External_RPC_API_Webhook_Late_Event_Conflict_Quarantine_And_Replay_Action.md

## 1. Purpose

This runbook defines the operational recovery procedure for late-arriving, conflicting, quarantined, or replay-required external RPC/API/Webhook events in the yoonsul_wait_order_handoff External Integration Control Plane.

External events may originate from POS, VAN, PG, simple payment providers, card acquirers, delivery apps, external order apps, kiosk vendors, KDS vendors, membership providers, coupon providers, settlement systems, tax/accounting systems, or other third-party systems. These events must never mutate internal state directly without reception logging, validation, sequencing, quarantine review, and controlled replay.

## 2. Scope

This runbook applies to:

- External Webhook events delivered after the expected processing window.
- RPC/API responses that conflict with already confirmed internal state.
- Duplicate or replayed callbacks.
- Events with valid signatures but invalid business sequence.
- Events with invalid signatures or expired timestamps.
- Events quarantined by validation policy.
- Manual replay or operator-driven recovery of external events.
- Late settlement, refund, cancellation, membership, coupon, and delivery-order events.

This runbook does not allow direct database modification, direct order-state mutation, or manual override without an evidence packet.

## 3. Parent And Related Documents

- Parent index: `70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md`
- Previous: `70260_Policy_External_RPC_API_Webhook_Event_Order_State_Machine_And_Late_Arrival_Control.md`
- Next: `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md`
- Related root: `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- Generation rule: `70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md`
- Payment integrity root: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Operating Principle

A late or conflicting external event is not automatically wrong, and it is not automatically authoritative.

The system must treat the event as evidence, not as final state. The event must be:

1. Preserved as raw input.
2. Normalized into the canonical event envelope.
3. Signature, timestamp, and replay checked.
4. Compared against current internal state.
5. Routed to accept, ignore, quarantine, compensate, or replay.
6. Audited with operator identity and evidence.

## 5. Event Classification

| Class | Description | Default Action |
|---|---|---|
| LATE_VALID | Event is authentic but arrived after the normal processing window | Compare with state machine and process only if forward-safe |
| LATE_STALE | Event is older than the current confirmed state | Preserve and ignore for mutation |
| CONFLICTING | Event contradicts current internal state | Quarantine and create review task |
| DUPLICATE | Event was already processed under same provider_event_id or idempotency key | Return cached result or ignore mutation |
| REPLAY_SUSPECT | Event resembles previous event but lacks trusted replay marker | Quarantine |
| SIGNATURE_INVALID | Signature verification failed | Reject or quarantine according to provider contract |
| TIMESTAMP_EXPIRED | Event timestamp exceeds acceptance window | Quarantine unless provider-specific exception applies |
| BUSINESS_INVALID | Technically valid but impossible in current business state | Quarantine and block state mutation |
| COMPENSATION_REQUIRED | Event proves external money/order state diverged from internal state | Route to compensation workflow |

## 6. Mandatory Operator Checks

Before replaying or resolving an event, the operator must verify:

- Provider name and integration type.
- Store, terminal, channel, or vendor identity.
- Provider event id.
- Internal canonical event id.
- Internal order id, payment id, membership id, coupon id, or delivery order id.
- Current internal state.
- Event claimed state.
- Event timestamp and received timestamp.
- Signature verification result.
- Idempotency key and replay marker.
- Raw payload hash.
- Related previous events.
- Existing exception or incident ticket.

If any of these are missing, the operator must not manually confirm the event.

## 7. Prohibited Actions

Operators and automated agents must not:

- Directly update order, payment, coupon, membership, delivery, settlement, or ledger tables.
- Mark an external payment as confirmed based only on a screenshot or customer statement.
- Replay a quarantined event without preserving the original raw payload.
- Modify raw payload before replay.
- Force a backward state transition without compensation workflow approval.
- Delete duplicate events.
- Suppress provider retry without recording ACK/NACK rationale.
- Resolve money-impacting conflicts without reconciliation evidence.
- Reuse another event's idempotency key.
- Treat late arrival as provider fault without audit evidence.

## 8. Standard Recovery Flow

### 8.1 Late Valid Event

1. Confirm signature and timestamp policy result.
2. Compare event version, provider timestamp, and current canonical state.
3. If the event represents a forward-safe transition, enqueue controlled processing.
4. If the event is stale, preserve and mark as `IGNORED_STALE_EVENT`.
5. Link the event to the current state record and audit packet.

### 8.2 Conflicting Event

1. Move event to quarantine.
2. Block automatic state mutation.
3. Generate `EXTERNAL_EVENT_CONFLICT` exception.
4. Attach raw payload, canonical envelope, signature result, previous event chain, and current state snapshot.
5. Run provider inquiry if available.
6. Route to manager or financial operations review if money-impacting.
7. Resolve through confirm, ignore, compensate, or provider dispute path.

### 8.3 Duplicate Event

1. Locate prior processed event using provider event id, canonical event id, idempotency key, trace id, and payload hash.
2. If identical, return cached ACK behavior and prevent mutation.
3. If similar but not identical, quarantine as replay suspect.
4. Preserve both payloads for audit.

### 8.4 Quarantined Event Replay

1. Confirm replay authorization.
2. Confirm original event is immutable and hash-verified.
3. Create replay request with operator identity, reason, target processor, and replay mode.
4. Replay through the same validation and state machine path used for fresh events.
5. Record replay result as separate audit event.
6. Never overwrite original raw event.

### 8.5 Compensation-Required Event

1. Freeze user-visible finalization if still possible.
2. Run provider inquiry or settlement cross-check.
3. Create compensation task.
4. Route to payment reversal, refund, order recovery, coupon restoration, membership point correction, delivery cancellation, or manual claim workflow.
5. Attach all evidence to the compensation record.

## 9. Replay Modes

| Replay Mode | Use Case | Restrictions |
|---|---|---|
| VALIDATION_ONLY | Re-run validation without state mutation | Safe for diagnostics |
| STATE_MACHINE_DRY_RUN | Check proposed state transition | No mutation allowed |
| CONTROLLED_REPLAY | Reprocess event through canonical pipeline | Requires approval and evidence |
| COMPENSATION_REPLAY | Trigger compensation workflow | Requires money-impacting review |
| PROVIDER_DISPUTE_PACKET | Package evidence for external vendor | No internal mutation |

## 10. Evidence Requirements

Every late, conflicting, quarantined, or replayed event must retain:

- Original raw payload.
- Canonical envelope.
- Provider headers.
- Signature verification result.
- Timestamp validation result.
- Payload hash.
- Previous and next state snapshots.
- Operator or automation identity.
- Replay reason.
- Replay result.
- Linked incident, reconciliation exception, or claim id.

## 11. State Resolution Outcomes

| Outcome | Meaning |
|---|---|
| ACCEPTED_FORWARD | Event was late but valid and advanced state safely |
| IGNORED_STALE_EVENT | Event was valid but older than confirmed state |
| DUPLICATE_SUPPRESSED | Event was duplicate and no mutation occurred |
| QUARANTINED_FOR_REVIEW | Event requires human or higher-level automated review |
| COMPENSATION_OPENED | Event revealed divergence requiring compensation |
| PROVIDER_INQUIRY_REQUIRED | Provider-side confirmation is required |
| DISPUTE_PACKET_CREATED | Evidence packet prepared for vendor/customer dispute |
| REPLAY_COMPLETED | Controlled replay completed successfully |
| REPLAY_REJECTED | Replay attempt failed validation or authorization |

## 12. Store And Manager Communication Rule

For customer-facing or store-facing incidents, the system must not display low-level provider details. The manager console must show operationally safe language:

- `결제/주문 상태 확인 중입니다.`
- `중복 처리 방지를 위해 재시도 전 확인이 필요합니다.`
- `외부 결제사 응답 지연으로 관리자 확인이 필요합니다.`
- `확정 전 취소/환불/재결제 안내를 금지합니다.`

Money-impacting guidance must be governed by payment integrity runbooks under the 75000 band.

## 13. Handoff

This runbook hands off to:

- `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md` for evidence and tamper-check rules.
- `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md` for payment-specific unknown-state recovery.
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` for money-impacting compensation, idempotency, Saga, outbox, and ledger controls.
