# 070260_Policy_External_RPC_API_Webhook_Event_Order_State_Machine_And_Late_Arrival_Control.md

## Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff |
| Band | 70000 External Integration Control Plane |
| Sub-band | 70200 External RPC API Webhook Response Contract And Event Control |
| Document Type | Policy |
| Status | Draft |
| Owner | External Integration / Payment Integrity / Runtime Governance |
| Parent Index | [70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md](./070200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md) |
| Previous | [70250_Policy_External_RPC_API_Webhook_Deduplication_Idempotency_And_Event_Order_Control.md](./070250_Policy_External_RPC_API_Webhook_Deduplication_Idempotency_And_Event_Order_Control.md) |
| Next | 70270_Runbook_External_RPC_API_Webhook_Late_Event_Conflict_Quarantine_And_Replay_Action.md |
| Related | [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](./070000_Readme_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md), [70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md](./070005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md), [70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md](./070120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md), [70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md](./070230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md), [70250_Policy_External_RPC_API_Webhook_Deduplication_Idempotency_And_Event_Order_Control.md](./070250_Policy_External_RPC_API_Webhook_Deduplication_Idempotency_And_Event_Order_Control.md) |

---

## 1. Purpose

This policy defines how yoonsul_wait_order_handoff controls external RPC/API/Webhook event ordering, canonical state-machine transitions, late-arriving events, delayed provider callbacks, and state regression risk.

The purpose is to prevent external event timing from corrupting internal payment, order, membership, delivery, settlement, or reconciliation state.

External events may arrive late, duplicate, out of order, partially missing, retried by provider, replayed by attacker, or delivered after a newer internal state has already been confirmed. Therefore, event arrival time SHALL NOT be treated as state authority.

---

## 2. Core Principle

External event arrival order is not trusted.

The system SHALL determine state transition authority using:

1. canonical entity identity,
2. provider event identity,
3. provider event occurred time,
4. received time,
5. current internal canonical state,
6. allowed state transition matrix,
7. version or sequence marker where available,
8. ledger reconciliation status,
9. business finality rule,
10. quarantine and review result.

A late event MAY be logged and preserved, but it SHALL NOT automatically reverse, downgrade, overwrite, or reopen an already finalized internal state.

---

## 3. Scope

This policy applies to inbound and outbound event flows involving:

- POS provider callbacks,
- VAN/POS payment result events,
- PG webhooks,
- simple payment callbacks,
- Alipay / WeChatPay cross-border callbacks,
- card acquirer result files,
- settlement file imports,
- delivery app order status webhooks,
- external order app callbacks,
- external membership / point / coupon events,
- external kiosk vendor events,
- external KDS device events,
- tax / accounting / ERP integration events,
- future external integration providers.

---

## 4. Definitions

| Term | Definition |
|---|---|
| Event Occurred Time | Time reported by the provider as the time the external event happened. |
| Event Received Time | Time the Yoonsul gateway received the event. |
| Canonical State | Internal normalized state managed by Yoonsul. |
| Late Event | An event received after a newer or more final state already exists internally. |
| State Regression | A transition that moves an entity from a more final state back to an earlier or weaker state. |
| Final State | A state that cannot be overwritten by later external events without inquiry, reconciliation, or manager approval. |
| Quarantine | Controlled holding area for events that are validly received but unsafe to apply. |
| State Authority | The component allowed to decide whether an event changes canonical internal state. |

---

## 5. Mandatory Event Time Model

Every external event SHALL be stored with at least the following time attributes:

```text
provider_event_occurred_at
provider_event_sent_at
received_at
normalized_at
validated_at
applied_at
quarantined_at
replayed_at
```

If a provider does not supply `provider_event_occurred_at`, the event SHALL be marked as `PROVIDER_TIME_MISSING` and SHALL NOT be allowed to override an already finalized state without additional validation.

---

## 6. Canonical State Transition Authority

External RPC/API/Webhook receivers SHALL NOT directly mutate business state.

The required pipeline is:

```text
receive event
→ persist raw payload
→ create canonical envelope
→ verify signature / replay / timestamp
→ deduplicate
→ map to canonical event type
→ evaluate state transition matrix
→ apply allowed transition or quarantine
→ emit audit event
→ reconcile if required
```

State transition decisions SHALL be made by an internal state authority component, not by:

- provider success flag,
- provider event name alone,
- HTTP status code alone,
- arrival order alone,
- user interface event alone,
- external callback order alone.

---

## 7. State Finality Rules

The system SHALL classify states into finality levels.

| Finality Level | Meaning | Example |
|---|---|---|
| L0 Volatile | Temporary state, freely updatable by validated events | webhook received, validation pending |
| L1 Provisional | Business-visible but not financially final | order pending, payment pending |
| L2 Confirmed | Internally confirmed by validation gate | payment confirmed, order accepted |
| L3 Reconciled | Confirmed by external settlement or inquiry | reconciled payment, matched settlement |
| L4 Final | Closed by retention, accounting, refund, settlement, or legal hold rule | final ledger closeout |

A lower-finality event SHALL NOT overwrite a higher-finality internal state.

Example:

```text
Current state: PAYMENT_CONFIRMED
Late event: PAYMENT_PENDING
Action: reject state mutation, preserve event, mark LATE_WEAKER_EVENT
```

---

## 8. Late Event Handling Policy

Late events SHALL be classified before action.

| Classification | Condition | Default Action |
|---|---|---|
| LATE_DUPLICATE | Same event already applied | Preserve and ignore mutation |
| LATE_WEAKER_EVENT | Event represents earlier/weaker state | Quarantine or no-op |
| LATE_COMPATIBLE_EVENT | Event confirms current state with additional evidence | Attach evidence only |
| LATE_CONFLICTING_EVENT | Event contradicts current state | Quarantine and raise exception |
| LATE_FINALITY_EVENT | Event affects settlement/refund/accounting finality | Route to reconciliation authority |
| LATE_SECURITY_RISK | Event is old, unsigned, replayed, or suspicious | Quarantine and security alert |

A late event SHALL NOT be deleted solely because it is late. It must be retained as evidence.

---

## 9. Forbidden State Mutations

The following mutations are forbidden without inquiry, reconciliation, or approved compensation workflow:

```text
CONFIRMED → PENDING
CONFIRMED → REQUESTED
PAID → PAYMENT_PENDING
PAID → PAYMENT_FAILED
CANCELLED → PAID
REFUNDED → PAID
RECONCILED → UNRECONCILED
SETTLED → UNSETTLED
DELIVERED → PREPARING
ORDER_CANCELLED → ORDER_ACCEPTED
COUPON_REDEEMED → COUPON_AVAILABLE
POINT_USED → POINT_AVAILABLE
```

If such an event is received, the event SHALL be preserved and routed to conflict handling.

---

## 10. External Payment Event Order Control

For payment-related events, the following ordering rule applies:

```text
PAYMENT_REQUESTED
→ PAYMENT_SENT_TO_PROVIDER
→ PAYMENT_RESPONSE_RECEIVED
→ PAYMENT_VALIDATION_PENDING
→ PAYMENT_CONFIRMED / PAYMENT_DECLINED / PAYMENT_UNKNOWN
→ PAYMENT_INQUIRY_PENDING / REVERSAL_PENDING / MANUAL_REVIEW
→ PAYMENT_RECONCILED
→ PAYMENT_CLOSED
```

A provider event such as `payment_failed` received after `PAYMENT_CONFIRMED` SHALL NOT automatically fail the payment. It SHALL trigger conflict classification.

A provider event such as `payment_confirmed` received after `PAYMENT_CANCELLED` SHALL NOT automatically reopen payment. It SHALL trigger inquiry and possible reversal review.

---

## 11. External Order And Delivery Event Order Control

For delivery and external order apps, status events may arrive late due to provider retry, mobile network delay, rider app delay, or order channel sync delay.

Default order flow:

```text
EXTERNAL_ORDER_CREATED
→ EXTERNAL_ORDER_ACCEPTED
→ STORE_CONFIRMED
→ PREPARING
→ READY
→ PICKED_UP / SERVED / COMPLETED
→ CANCELLED / REFUNDED / DISPUTED
```

Late `order_created`, `accepted`, or `preparing` events SHALL NOT override `completed`, `cancelled`, or `refunded` states.

---

## 12. Membership, Coupon, And Point Event Order Control

Membership and coupon events SHALL be treated as financial-adjacent events because they can affect customer balance, discount amount, taxable amount, and settlement value.

A late coupon availability event SHALL NOT re-enable a coupon already marked as used.

A late point balance callback SHALL NOT overwrite internal point ledger unless it is produced by an approved reconciliation process.

---

## 13. Settlement And Accounting Event Order Control

Settlement file imports and accounting callbacks may arrive days after original transactions. They are late by nature but may have higher finality.

Therefore, settlement events SHALL be routed to reconciliation authority, not normal webhook state mutation.

Settlement events may:

- confirm an internal state,
- raise mismatch exception,
- attach deposit evidence,
- create fee adjustment record,
- create receivable/payable correction,
- trigger manual review.

Settlement events SHALL NOT directly rewrite original payment response payloads.

---

## 14. Quarantine Triggers

An event SHALL be quarantined when:

- event sequence is older than current canonical state,
- event finality is weaker than current state,
- event contradicts amount, tax, discount, or order identity,
- provider timestamp is missing or outside allowed window,
- event signature is invalid,
- replay risk is detected,
- duplicate event contains different payload,
- provider event id is reused with different content,
- state transition matrix does not allow the requested transition,
- event attempts to reopen closed financial state,
- event affects refund, reversal, settlement, or accounting finality.

---

## 15. Conflict Resolution Actions

| Conflict Type | Required Action |
|---|---|
| Late duplicate | No-op mutation, attach duplicate evidence |
| Late weaker state | No-op mutation, retain raw event |
| Late conflicting state | Quarantine, create reconciliation exception |
| Late payment success after cancellation | Inquiry and reversal review |
| Late failure after payment confirmation | Inquiry and evidence attach |
| Late refund after settlement | Ledger adjustment review |
| Late delivery cancellation after completion | Store claim review |
| Late membership correction | Membership ledger reconciliation |

---

## 16. Audit And Evidence Requirements

Every late or out-of-order event SHALL produce an audit record containing:

```text
event_id
provider_event_id
canonical_entity_id
current_state
requested_transition
transition_decision
late_event_classification
reason_code
raw_payload_hash
signature_result
provider_event_occurred_at
received_at
applied_or_rejected_at
operator_id_if_manual
reconciliation_case_id_if_any
```

Audit records SHALL be append-only.

---

## 17. Required State Transition Matrix

Every external integration provider family SHALL maintain a state transition matrix before production activation.

Minimum matrix dimensions:

| Dimension | Required |
|---|---|
| Provider event type | Yes |
| Canonical event type | Yes |
| Current internal state | Yes |
| Requested target state | Yes |
| Allowed / denied / quarantine | Yes |
| Finality level | Yes |
| Inquiry requirement | Yes |
| Compensation requirement | Yes |
| Operator action | Yes |
| Audit evidence | Yes |

If a provider lacks a transition matrix, production activation is prohibited.

---

## 18. Implementation Requirements

The implementation SHALL include:

- immutable raw event store,
- canonical envelope table,
- event deduplication table,
- entity state version table,
- state transition matrix,
- late event classifier,
- quarantine queue,
- replay worker,
- reconciliation exception register,
- audit ledger emission,
- admin review screen for quarantined events.

---

## 19. Admin Console Requirements

The admin console SHALL allow authorized users to view:

- current canonical state,
- incoming late event,
- provider timestamp vs received timestamp,
- raw payload hash,
- validation result,
- transition decision,
- allowed recovery actions,
- related payment/order/settlement evidence,
- previous state history,
- next required action.

The admin console SHALL NOT allow arbitrary state editing. Manual actions must create compensating events or approved correction records.

---

## 20. Store Operator Boundary

Store operators SHALL NOT be asked to decide technical event order.

Store-facing guidance must simplify late event outcomes into operational states such as:

```text
결제 확인 중
승인 확인 필요
취소 확인 필요
정산 확인 필요
관리자 검토 중
고객 안내 후 대기
```

Technical conflict resolution remains with the integration control plane and authorized manager workflow.

---

## 21. Acceptance Criteria

This policy is satisfied when:

- external event arrival order is never used alone as state authority,
- late events are classified before mutation,
- state regression is blocked by transition matrix,
- final states cannot be overwritten by weaker late events,
- all late/conflicting events are preserved as evidence,
- quarantine and reconciliation workflows exist,
- payment/order/membership/delivery/settlement events have separate finality rules,
- admin manual override is controlled through correction events, not direct row edits.

---

## 22. Handoff

This policy hands off to:

- `70270_Runbook_External_RPC_API_Webhook_Late_Event_Conflict_Quarantine_And_Replay_Action.md`
- `70280_Audit_External_RPC_API_Webhook_Event_Timeline_Evidence_And_State_Decision_Log.md`
- `70290_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control_Closeout_And_Handoff.md`
- `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md`
