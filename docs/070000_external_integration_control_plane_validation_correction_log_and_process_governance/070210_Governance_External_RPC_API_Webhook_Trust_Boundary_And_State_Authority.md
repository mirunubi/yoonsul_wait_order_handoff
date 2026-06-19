# 070210_Governance_External_RPC_API_Webhook_Trust_Boundary_And_State_Authority.md

## Document Control

- Project: yoonsul_wait_order_handoff
- Document Type: Governance
- Lane: 70000 External Integration Control Plane
- Parent Index: 70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md
- Previous: 70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md
- Next: 70220_Policy_External_RPC_API_Webhook_Inbound_Event_Reception_Raw_Log_And_Acknowledgement.md
- Status: Draft
- Owner: External Integration Control Plane / Payment Integrity Architecture

## 1. Purpose

This document defines the trust boundary, state authority, and control model for external RPC, API, and Webhook interactions in the yoonsul_wait_order_handoff system.

External systems may send payment responses, order status updates, delivery events, membership changes, coupon redemptions, settlement notices, device callbacks, cancellation confirmations, or asynchronous correction messages. These external messages are important evidence, but they are not allowed to directly mutate internal business state.

The purpose of this governance is to ensure that every external message is received as an untrusted event, logged as raw evidence, normalized into a canonical event model, validated against internal ledgers, and then either accepted, corrected, quarantined, or escalated.

## 2. Scope

This governance applies to all inbound and bidirectional external integration channels, including but not limited to:

- POS RPC responses
- VAN approval/cancel responses
- PG API responses
- PG Webhooks
- simple pay callbacks
- Alipay / WeChatPay cross-border callbacks
- card acquirer and issuer response metadata
- settlement file ingestion signals
- delivery app order and status events
- external order app events
- external membership, coupon, voucher, and point events
- kiosk vendor callbacks
- KDS vendor callbacks
- tax/accounting integration callbacks
- provider certification and sandbox callbacks

This document does not define detailed per-provider field mapping. Those mappings must be handled by later field registry and canonical mapping documents.

## 3. Core Governance Principle

External RPC/API/Webhook messages are not commands against the core ledger. They are evidence inputs.

The system must never implement this pattern:

```text
external webhook says paid
→ update order to paid
```

The required pattern is:

```text
external webhook received
→ raw payload stored
→ source authenticated
→ event normalized
→ idempotency checked
→ internal intent/ledger matched
→ validation gate executed
→ state authority decides mutation
→ result logged and reconciled
```

## 4. Trust Boundary Model

### 4.1 External Provider Zone

The external provider zone includes POS, VAN, PG, delivery app, membership provider, coupon provider, accounting provider, kiosk vendor, KDS vendor, and all other third-party integration parties.

The external provider zone is considered partially trusted only for transport delivery and evidence contribution. It is not trusted for internal final state determination.

### 4.2 Integration Reception Zone

The reception zone receives RPC responses, API responses, Webhook events, callback events, file arrival notices, and polling results.

The reception zone is responsible for:

- TLS termination or secure channel verification
- signature verification where supported
- timestamp drift check
- replay window check
- provider identity check
- raw payload preservation
- acknowledgement policy execution
- initial event envelope creation

### 4.3 Canonical Normalization Zone

The normalization zone converts provider-specific payloads into canonical internal event structures.

This zone must not decide final business state. It only translates fields, codes, timestamps, identifiers, and provider metadata into internal canonical vocabulary.

### 4.4 Validation Gate Zone

The validation gate verifies the canonical event against internal ledgers and expected state.

Validation may check:

- order identity
- payment intent identity
- amount
- tax
- discount
- service charge
- currency
- terminal ID
- store ID
- approval number
- cancel number
- provider transaction ID
- duplicate event key
- event time window
- expected state transition
- previous event chain
- settlement/deposit expectation

### 4.5 State Authority Zone

The state authority zone is the only zone allowed to mutate internal order, payment, membership, coupon, delivery, kitchen, settlement, and accounting state.

State authority may accept, reject, quarantine, compensate, reverse, or escalate an external event.

## 5. State Authority Rules

### 5.1 External Success Is Not Internal Success

An external `success`, `approved`, `completed`, or equivalent status does not automatically mean internal confirmation.

Internal confirmation requires:

- valid source
- valid raw evidence
- valid canonical mapping
- valid idempotency check
- valid ledger match
- valid state transition
- valid evidence retention

### 5.2 External Failure Is Not Always Internal Failure

An external timeout, connection error, callback delay, unknown response, or temporary failure does not automatically mean internal failure.

The system must distinguish:

- declined
- failed
- timeout unknown
- provider processing
- duplicate ignored
- inquiry required
- reversal pending
- manual review required

### 5.3 Webhook Is Not Final Truth

Webhook events are asynchronous evidence. They may arrive late, arrive out of order, be duplicated, or represent delayed provider-side correction.

Webhook events must be idempotent and sequence-aware.

### 5.4 RPC Response Is Not Sufficient Alone

Synchronous RPC/API response may be lost, incomplete, stale, or provider-specific. If the synchronous response conflicts with later webhook, inquiry, settlement, or provider export, the conflict must be resolved through reconciliation rules, not blind overwrite.

### 5.5 Settlement Overrides Require Reconciliation

Settlement file or deposit data may reveal final financial truth, but it must not blindly overwrite transaction state. It must create reconciliation exceptions and accounting adjustments where appropriate.

## 6. Required Inbound Event Envelope

Every external RPC/API/Webhook message must be wrapped into an internal event envelope.

Minimum envelope fields:

```text
event_id
provider_type
provider_name
channel_type
source_endpoint
received_at
raw_payload_hash
raw_payload_storage_ref
provider_event_id
provider_transaction_id
provider_trace_id
store_id
terminal_id
order_id
payment_intent_id
canonical_event_type
canonical_event_status
idempotency_key
signature_verification_result
replay_check_result
normalization_status
validation_status
state_authority_result
quarantine_reason
operator_review_required
```

## 7. Acknowledgement Policy

External providers often require fast acknowledgement for Webhook or callback delivery. The system must separate transport acknowledgement from business acceptance.

Allowed acknowledgement model:

```text
Received and stored = ACK to provider
Validated and accepted = internal state transition
```

The system must never treat ACK as acceptance of business truth.

If raw payload cannot be stored, the event must not be acknowledged as received unless the provider contract requires otherwise and a fallback evidence path is available.

## 8. Replay and Duplicate Control

External RPC/API/Webhook channels must expect duplicate delivery.

Duplicate control must use a combination of:

- provider event ID
- provider transaction ID
- internal intent ID
- canonical idempotency key
- raw payload hash
- provider timestamp
- event type
- store ID and terminal ID

Duplicate events must not trigger repeated payment confirmation, repeated cancellation, repeated coupon redemption, repeated point deduction, repeated delivery acceptance, or repeated accounting entry.

## 9. Out-of-Order Event Control

External events may arrive out of order.

Examples:

```text
cancel webhook arrives before approval webhook
settlement correction arrives after refund
order accepted arrives after order cancelled
membership point restore arrives before point deduction event
KDS completion arrives before POS order confirmation
```

The state authority must check whether the transition is valid from the current internal state. Invalid or premature events must be quarantined or parked until prerequisite events are resolved.

## 10. Quarantine Rules

An external event must be quarantined when:

- provider identity cannot be verified
- signature verification fails
- timestamp is outside allowed window
- duplicate key collision is suspicious
- amount does not match internal expectation
- order ID does not exist
- payment intent does not exist
- terminal/store mapping is invalid
- event sequence is impossible
- event conflicts with confirmed ledger state
- raw payload hash cannot be generated
- canonical mapping fails
- provider status code is unknown
- manual legal/compliance review is required

Quarantined events must not mutate core state. They must create review tasks and evidence records.

## 11. Correction and Compensation Relationship

External events may trigger correction or compensation workflows, but they must not execute compensation directly.

Examples:

- approved externally but order creation failed → payment integrity workflow decides restore order or reverse payment
- cancelled externally but refund ledger missing → reconciliation workflow creates correction task
- coupon redeemed externally but order failed → membership compensation workflow evaluates restore coupon
- delivery accepted externally but store order rejected → order integration workflow creates dispute case

## 12. Logging and Evidence Requirements

Every inbound external event must produce the following logs:

- reception log
- raw payload evidence log
- authentication/signature log
- normalization log
- idempotency log
- validation log
- state authority decision log
- quarantine or compensation log where applicable
- operator action log where manual review occurs

Logs must be immutable or tamper-evident where financial, settlement, customer claim, or legal dispute risk exists.

## 13. Prohibited Patterns

The following patterns are prohibited:

```text
Webhook directly updates order status
RPC response directly marks payment confirmed
External success code bypasses amount validation
Provider transaction ID is trusted without internal intent match
Timeout is stored as failure without inquiry path
Duplicate callback causes repeated refund
Settlement file directly overwrites order ledger
Manual manager override without evidence packet
Unknown provider response code treated as success
Raw payload discarded after canonical mapping
```

## 14. Required Related Documents

This governance requires the following follow-up documents:

```text
70220_Policy_External_RPC_API_Webhook_Inbound_Event_Reception_Raw_Log_And_Acknowledgement.md
70230_Spec_External_RPC_API_Webhook_Event_Envelope_Idempotency_Key_And_Replay_Window.md
70240_Policy_External_Webhook_Signature_Timestamp_Source_Verification_And_Trust_Control.md
70250_Spec_External_Event_Canonical_Status_Code_Mapping_And_Provider_Response_Normalization.md
70260_Policy_External_Event_Out_Of_Order_Duplicate_Delayed_And_Conflict_Resolution.md
70270_Runbook_External_RPC_API_Webhook_Failure_Retry_Quarantine_And_Operator_Review.md
70280_Audit_External_RPC_API_Webhook_Raw_Evidence_Decision_Log_And_Tamper_Check.md
70290_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control_Closeout_And_Handoff.md
```

## 15. Acceptance Criteria

This governance is accepted when:

- no external RPC/API/Webhook event directly mutates core business state
- all inbound events are stored as raw evidence before processing
- every external event is wrapped in an internal event envelope
- ACK and business acceptance are separated
- duplicate and replay control is mandatory
- out-of-order event handling is documented
- quarantine is defined for untrusted or mismatched events
- state authority is explicitly internal
- later 70220~70290 documents are generated and linked

## 16. Handoff

This document hands off to:

```text
70220_Policy_External_RPC_API_Webhook_Inbound_Event_Reception_Raw_Log_And_Acknowledgement.md
```

The next document must define the concrete reception process for inbound external messages, including raw log creation, transport acknowledgement, storage failure handling, and provider acknowledgement separation.
