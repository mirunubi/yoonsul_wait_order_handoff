# 070220_Policy_External_RPC_API_Webhook_Inbound_Event_Reception_Raw_Log_And_Acknowledgement.md

## Document Control

- **Project**: yoonsul_wait_order_handoff
- **Document Type**: Policy
- **Document Number**: 70220
- **Domain**: External Integration Control Plane
- **Status**: Draft
- **Parent Index**: [70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md](./070200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md)
- **Previous**: [70210_Governance_External_RPC_API_Webhook_Trust_Boundary_And_State_Authority.md](./070210_Governance_External_RPC_API_Webhook_Trust_Boundary_And_State_Authority.md)
- **Next**: [70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md](./070230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md)
- **Related**:
  - [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](./070000_Readme_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md)
  - [70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md](./070005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md)
  - [70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md](./070120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md)
  - [70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md](./070170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md)
  - `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` (미작성)

---

## 1. Purpose

This policy defines how yoonsul_wait_order_handoff receives inbound external RPC/API/Webhook events, preserves raw logs, issues acknowledgements, and separates reception from validation and state mutation.

The purpose is to prevent external systems from directly changing internal financial, order, settlement, membership, or operational state merely because an inbound callback, response, or webhook was received.

Inbound reception means:

1. receive the external event,
2. authenticate the source where possible,
3. persist the raw payload and transport metadata,
4. generate a stable internal reception record,
5. acknowledge according to the provider contract,
6. pass the event to validation and state authority layers.

Reception is not final confirmation.

---

## 2. Scope

This policy applies to all external inbound event sources, including but not limited to:

- POS callback events,
- VAN response callbacks,
- PG payment, cancel, refund, and virtual account events,
- simple payment provider events,
- Alipay / WeChatPay / cross-border payment events,
- card acquirer or settlement status events,
- delivery app order, cancel, delay, pickup, and claim events,
- external order app events,
- kiosk vendor events,
- KDS vendor events,
- membership, coupon, point, voucher, and benefit events,
- accounting, tax, ERP, and deposit file events,
- external system health, outage, retry, and dead-letter events.

Out of scope:

- final financial ledger posting rules,
- double-entry accounting rules,
- Saga compensation rules,
- detailed provider-specific API parameter mapping.

Those are handled by 75000-series payment integrity and later provider-specific documents.

---

## 3. Core Policy Statement

External inbound events must be treated as **untrusted evidence** until they pass canonical validation and state authority checks.

The system must not perform the following directly from an inbound event handler:

- mark an order as finally paid,
- mark a refund as finally completed,
- close a customer claim,
- release kitchen or delivery work based only on callback arrival,
- update settlement as final,
- consume or restore membership points as final,
- delete or overwrite prior financial state,
- suppress a reconciliation exception,
- acknowledge customer-facing completion without internal validation.

The inbound handler may only:

- receive,
- normalize transport metadata,
- persist raw payload,
- compute hash,
- assign reception id,
- perform basic source authentication,
- enqueue validation work,
- return a controlled acknowledgement to the external provider.

---

## 4. Reception Pipeline

Every inbound external event must follow this pipeline.

```text
External Provider
  -> Inbound Endpoint
  -> Transport Authentication
  -> Raw Payload Capture
  -> Reception Ledger Insert
  -> Hash / Signature Record
  -> Duplicate Reception Check
  -> ACK / NACK Decision
  -> Validation Queue
  -> Canonical Mapping
  -> State Authority Gate
  -> Domain State Update or Exception Queue
```

The inbound endpoint is not a business transaction processor. It is an intake control point.

---

## 5. Required Reception Ledger Fields

Each inbound event must create an immutable reception ledger record.

Minimum fields:

| Field | Required | Description |
|---|---:|---|
| `inbound_event_id` | Yes | Internal unique event reception id |
| `external_provider_id` | Yes | Provider, vendor, or partner id |
| `external_provider_type` | Yes | POS, VAN, PG, DELIVERY_APP, MEMBERSHIP, ACCOUNTING, etc. |
| `endpoint_id` | Yes | Internal endpoint that received the event |
| `http_method` | Conditional | HTTP method, if HTTP-based |
| `http_status_returned` | Conditional | Status returned to provider |
| `received_at` | Yes | System reception timestamp |
| `received_timezone` | Yes | Timezone used for reception timestamp |
| `provider_event_id` | Conditional | Provider event id if supplied |
| `provider_transaction_id` | Conditional | Provider transaction id if supplied |
| `provider_trace_id` | Conditional | Provider trace, request, or correlation id |
| `idempotency_key` | Conditional | Provider or internal idempotency key |
| `signature_header` | Conditional | Signature header or token metadata |
| `signature_verified` | Yes | True/false/unknown |
| `source_ip` | Conditional | Source IP or gateway forwarding chain |
| `raw_headers` | Yes | Raw request headers, with sensitive masking where required |
| `raw_payload` | Yes | Original payload before business mapping |
| `raw_payload_hash` | Yes | Hash of raw payload |
| `raw_payload_size` | Yes | Payload size |
| `content_type` | Conditional | MIME/content type |
| `schema_version_detected` | Conditional | Provider schema version if known |
| `reception_status` | Yes | RECEIVED, REJECTED, DUPLICATE, QUARANTINED, etc. |
| `validation_status` | Yes | NOT_STARTED, QUEUED, PASSED, FAILED, MANUAL_REVIEW |
| `state_mutation_status` | Yes | NOT_ALLOWED_AT_RECEPTION, QUEUED, APPLIED, BLOCKED |
| `retention_class` | Yes | Audit retention class |

Sensitive values must be masked or encrypted according to applicable privacy, PCI, payment, and internal security policies.

---

## 6. Raw Payload Preservation Policy

Raw payload must be preserved before canonical mapping.

Rules:

1. Raw payload must not be overwritten by normalized payload.
2. Raw payload must be hashable and reproducible for audit.
3. Raw payload must be linked to the validation result.
4. Raw payload must be linked to state mutation decisions.
5. Raw payload must be available for dispute, incident, reconciliation, and legal hold workflows.
6. Raw payload must not expose plaintext card track data, sensitive authentication data, secret keys, or prohibited personal information.
7. If provider payload includes prohibited sensitive data, the event must be quarantined and a provider contract/security exception must be opened.

The canonical event is a derived record. The raw event is the evidence record.

---

## 7. Acknowledgement Policy

Acknowledgement must be based on **safe reception**, not final business success.

An ACK means:

```text
The event was received and recorded by the inbound control plane.
```

An ACK does not mean:

```text
The payment is confirmed.
The order is completed.
The refund is completed.
The settlement is reconciled.
The membership point change is final.
The customer claim is closed.
```

The ACK response must be provider-contract aware.

Typical ACK decisions:

| Condition | ACK Decision | Notes |
|---|---|---|
| Payload received, raw log persisted, validation queued | ACK | Preferred normal path |
| Payload received but duplicate provider event id | ACK | Avoid unnecessary provider retry; mark duplicate |
| Payload received but signature invalid | NACK or ACK-Quarantine | Depends on provider retry semantics and security policy |
| Payload cannot be parsed at transport level | NACK | Provider should retry or investigate |
| Payload too large | NACK | Security and abuse control |
| Endpoint unavailable after partial receipt | No ACK | Provider retry expected |
| Event persisted but validation later fails | ACK already valid | Failure handled internally as exception |

If a provider treats non-2xx as retry trigger, the system must avoid returning non-2xx after raw persistence unless retry is desired.

---

## 8. Duplicate Reception Handling

The system must assume providers may deliver the same event more than once.

Duplicate detection must use layered keys:

1. provider event id,
2. provider transaction id,
3. idempotency key,
4. event type + amount + terminal/store + timestamp window,
5. raw payload hash,
6. correlation id or trace id.

Duplicate event reception must not cause duplicate state mutation.

Duplicate events must be recorded as one of:

```text
FIRST_RECEIVED
DUPLICATE_SAME_PAYLOAD
DUPLICATE_DIFFERENT_PAYLOAD
REPLAY_SUSPECTED
PROVIDER_RETRY
UNKNOWN_DUPLICATE
```

`DUPLICATE_DIFFERENT_PAYLOAD` and `REPLAY_SUSPECTED` must enter security or manual review queue.

---

## 9. Signature And Source Authentication

Inbound events must be authenticated according to provider capability.

Accepted authentication mechanisms may include:

- HMAC signature,
- mutual TLS,
- provider certificate,
- signed JWT,
- static token with rotation,
- IP allowlist plus signature,
- provider gateway identity header,
- VPN/private network source control.

IP allowlist alone is not sufficient for financial state mutation.

Signature verification result must be persisted as audit evidence.

If signature verification is impossible because a provider lacks support, the provider must be marked as higher-risk and compensated by:

- stricter reconciliation,
- reduced automatic state authority,
- additional inquiry requirement,
- limited rollout scope,
- provider contract exception record.

---

## 10. Validation Queue Policy

Inbound event validation must be asynchronous unless provider contract requires immediate validation response.

Validation queue messages must include:

- `inbound_event_id`,
- raw payload hash,
- provider id,
- detected event type,
- priority,
- retry count,
- validation deadline,
- related payment/order/settlement candidate ids if detected.

Validation workers must be idempotent.

If validation worker fails, the event remains in exception or retry state. The raw reception record must not be deleted.

---

## 11. State Mutation Guardrail

Inbound reception handlers must not directly mutate final domain states.

Allowed at reception:

```text
INSERT inbound_event_reception
INSERT inbound_event_raw_log
INSERT inbound_event_hash
INSERT validation_queue_message
UPDATE provider_delivery_attempt_statistics
```

Not allowed at reception:

```text
UPDATE order.status = PAID
UPDATE payment.status = CONFIRMED
UPDATE refund.status = COMPLETED
UPDATE settlement.status = RECONCILED
UPDATE membership_point.balance
DELETE exception records
DELETE raw payloads
```

State mutation must only occur through the state authority layer after validation.

---

## 12. Provider Retry Semantics

Each provider must have a retry semantics profile.

Required provider profile fields:

| Field | Description |
|---|---|
| `retry_on_non_2xx` | Whether provider retries on non-2xx |
| `retry_schedule` | Retry interval and maximum duration |
| `duplicate_event_id_stability` | Whether same event id is reused on retry |
| `signature_stability` | Whether signature changes on retry |
| `delivery_order_guarantee` | Ordered, unordered, best-effort, unknown |
| `at_least_once_delivery` | Whether duplicate delivery is expected |
| `eventual_delivery_window` | How long delayed events may arrive |
| `manual_resend_available` | Whether provider can resend from admin console |
| `dead_letter_available` | Whether provider exposes failed event delivery list |

Unknown retry semantics must be recorded as integration risk.

---

## 13. Event Ordering Policy

The system must not assume external events arrive in business order.

Examples:

- cancellation event arrives before approval event,
- delivery app order cancel arrives before order accepted event,
- settlement adjustment arrives after payout event,
- membership point restore arrives before original consumption event,
- webhook arrives before synchronous API response is processed.

Therefore, validation must use state machine rules, not arrival order alone.

Out-of-order events must be handled through:

- pending correlation queue,
- delayed validation retry,
- inquiry request,
- manual review,
- reconciliation exception.

---

## 14. Quarantine Policy

Inbound events must be quarantined when they are unsafe, malformed, suspicious, or unsupported.

Quarantine triggers:

- invalid signature,
- unknown provider,
- unsupported schema version,
- raw payload contains prohibited sensitive data,
- duplicated event with changed financial fields,
- impossible state transition,
- missing required transaction id,
- mismatched store, terminal, merchant, or amount,
- replay suspected,
- provider event timestamp outside allowed window,
- payload hash conflict.

Quarantined events must not be discarded. They must be retained with restricted access and linked to incident or provider exception workflow.

---

## 15. Customer-Facing Communication Guardrail

The customer-facing layer must not display final financial confirmation based only on inbound reception.

Permitted messages:

```text
결제 상태를 확인 중입니다.
외부 결제망 응답을 확인 중입니다.
주문 상태를 확인 중입니다. 직원에게 문의해 주세요.
```

Prohibited messages before validation:

```text
결제가 완료되었습니다.
환불이 완료되었습니다.
주문이 확정되었습니다.
포인트가 복구되었습니다.
정산이 완료되었습니다.
```

Final customer-facing messaging must follow validated state authority.

---

## 16. Operational Monitoring

The following metrics must be monitored:

- inbound event count by provider,
- duplicate event rate,
- invalid signature rate,
- parse failure rate,
- validation queue delay,
- ACK failure rate,
- provider retry storm detection,
- quarantine count,
- state mutation blocked count,
- out-of-order event count,
- payload size anomaly,
- unknown provider event count.

High-risk thresholds must trigger incident workflow.

---

## 17. Evidence And Audit Requirements

Each inbound event must be traceable through the following chain:

```text
Inbound Event
  -> Raw Payload Hash
  -> Reception Ledger
  -> ACK Decision
  -> Validation Result
  -> Canonical Event
  -> State Authority Decision
  -> Domain State Mutation or Exception
  -> Reconciliation / Incident / Dispute Evidence
```

Audit must be able to answer:

1. What did the external provider send?
2. When did we receive it?
3. Did we verify the source?
4. What ACK did we return?
5. Did we treat it as duplicate?
6. How was it mapped?
7. Why was state changed or not changed?
8. Which downstream process consumed it?
9. Was the event later reconciled or disputed?

---

## 18. Implementation Requirements

Minimum implementation components:

- external inbound gateway,
- raw payload store,
- inbound event reception ledger,
- payload hash generator,
- provider signature verifier,
- duplicate detector,
- ACK decision engine,
- validation queue,
- canonical event mapper,
- state authority gate,
- quarantine store,
- monitoring dashboard,
- incident and reconciliation linkage.

No external provider integration may go live without these minimum controls or a formally approved waiver.

---

## 19. Open Gaps

The following items require provider-specific follow-up documents:

- exact retry semantics per POS/VAN/PG provider,
- webhook signature algorithm registry,
- provider event schema version registry,
- event ordering guarantees by provider,
- provider manual resend process,
- provider DLQ export availability,
- sensitive field masking map,
- retention class per provider event type,
- integration test harness for duplicate and out-of-order delivery.

---

## 20. Handoff

This policy hands off to:

- `70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md` for canonical envelope and signature fields,
- `70240_Policy_External_RPC_API_Webhook_Idempotent_Reception_Duplicate_Detection_And_Replay_Control.md` for duplicate and replay handling,
- `70250_Runbook_External_RPC_API_Webhook_Delivery_Failure_Retry_Dead_Letter_And_Manual_Replay.md` for delivery failure recovery,
- 75000-series documents for payment integrity, delayed cancellation, Saga, Outbox, and ledger governance.

---

## 21. Closeout Criteria

This policy is complete when:

- inbound events are never treated as final business confirmation at reception,
- every external event is raw-logged and hashed,
- ACK semantics are separated from business success,
- duplicate and replay events are controlled,
- validation and state mutation are separated,
- provider retry semantics are registered,
- quarantined events are retained and reviewable,
- audit can reconstruct the full chain from raw event to final state decision.
