# 14104_Policy_POS_Gateway_Callback_Webhook_Provider_Lookup_And_Async_State_Reconciliation

## 1. Purpose

This document defines the POS Gateway policy for callback, webhook, provider lookup, delayed provider response, asynchronous state reconciliation, and late-arriving external evidence.

The POS Gateway must not assume that provider responses arrive in the same order as internal requests.

Payment providers, POS providers, VAN/PG routes, kiosk routes, mini-kiosk routes, bridge servers, receipt providers, and settlement sources may send callbacks late, duplicate callbacks, conflicting callbacks, missing callbacks, malformed callbacks, or provider lookup responses that contradict prior gateway assumptions.

The purpose of this policy is to ensure that asynchronous external evidence is accepted, validated, deduplicated, reconciled, and applied only through the internal event ledger and state machine.

## 2. Scope

This policy applies to all asynchronous provider and route evidence, including:

* payment provider callback
* payment approval webhook
* payment failure webhook
* payment cancellation callback
* refund callback
* partial refund callback
* POS order acceptance callback
* POS rejection callback
* POS cancellation callback
* VAN/PG callback
* provider bridge callback
* kiosk payment callback
* mini-kiosk payment callback
* provider lookup response
* delayed provider response
* duplicate callback
* conflicting callback
* missing callback
* malformed callback
* callback retry
* settlement file arrival
* receipt evidence arrival
* reconciliation-triggered provider lookup
* support-triggered provider lookup
* dispute-triggered provider lookup

This policy applies before callback processing, webhook receiver, provider lookup worker, asynchronous reconciliation worker, refund automation, cancellation automation, or production provider route release is implemented.

## 3. Relationship_To_Previous_Documents

This document follows:

* `14100_Policy_POS_Gateway_Adapter_Interface_Request_Response_Callback_And_Error_Mapping.md`
* `14102_Policy_POS_Gateway_Idempotency_Retry_Duplicate_Prevention_And_Safe_Replay_Implementation.md`

It also depends on:

* `14096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry.md`
* `14098_Policy_POS_Gateway_State_Machine_Payment_POS_Cancellation_Refund_And_Customer_Status.md`
* `14071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md`
* `14073_Policy_POS_Gateway_Offline_Degraded_Mode_Local_Ledger_Replay_And_Reconciliation.md`

The rule is:

> Asynchronous evidence may inform internal state, but it must not bypass event, validation, idempotency, and reconciliation controls.

## 4. Core_Principle

The POS Gateway must treat every callback, webhook, lookup response, delayed response, and settlement evidence as external evidence, not as direct state authority.

Asynchronous evidence must be:

* authenticated where possible
* validated
* deduplicated
* correlated
* mapped
* event-recorded
* state-machine-checked
* conflict-checked
* reconciliation-linked
* dispute-linked where needed
* projection-applied only after allowed transition

The system must never allow an external asynchronous message to directly overwrite current payment, POS, cancellation, refund, customer, staff, reconciliation, or dispute state.

## 5. Async_Evidence_Types

The POS Gateway must classify asynchronous evidence into standardized types.

Required types include:

* `PAYMENT_APPROVAL_CALLBACK`
* `PAYMENT_FAILURE_CALLBACK`
* `PAYMENT_UNKNOWN_CALLBACK`
* `PAYMENT_CANCELLATION_CALLBACK`
* `REFUND_CALLBACK`
* `PARTIAL_REFUND_CALLBACK`
* `POS_ACCEPTANCE_CALLBACK`
* `POS_REJECTION_CALLBACK`
* `POS_CANCELLATION_CALLBACK`
* `PROVIDER_LOOKUP_RESULT`
* `PROVIDER_DELAYED_RESPONSE`
* `DUPLICATE_CALLBACK`
* `CONFLICTING_CALLBACK`
* `MALFORMED_CALLBACK`
* `UNAUTHENTICATED_CALLBACK`
* `SETTLEMENT_FILE_EVIDENCE`
* `RECEIPT_EVIDENCE`
* `SUPPORT_MANUAL_LOOKUP_EVIDENCE`
* `DISPUTE_PROVIDER_EVIDENCE`

Each type must define:

* validation requirement
* idempotency requirement
* correlation requirement
* allowed state impact
* blocked state impact
* reconciliation requirement
* dispute requirement
* evidence retention rule

## 6. Callback_Receiver_Boundary

### 6.1 Receiver_Purpose

The callback receiver is responsible for accepting external messages, validating them, and converting them into adapter callback records.

The receiver must not directly update business state.

### 6.2 Receiver_Allowed_Actions

The receiver may:

* receive callback payload
* identify provider route
* validate environment
* validate signature or authentication where supported
* validate schema
* compute payload hash
* create callback record
* deduplicate callback
* reject invalid callback
* enqueue normalized processing
* emit observability metric

### 6.3 Receiver_Blocked_Actions

The receiver must not:

* mark payment approved directly
* mark refund completed directly
* mark cancellation completed directly
* mark POS accepted directly
* notify customer directly as final state
* close dispute case directly
* close reconciliation case directly
* delete prior callback evidence
* overwrite prior provider reference silently

## 7. Callback_Validation_Requirements

Callback validation must include where available:

* provider route identification
* environment match
* endpoint path validation
* HTTP method validation
* authentication token validation
* signature validation
* timestamp freshness
* replay window validation
* payload schema validation
* required field validation
* provider reference validation
* operation type validation
* amount validation where relevant
* currency validation where relevant
* tenant/store/channel correlation where available
* provider event identifier validation where available

If the provider does not support strong callback validation, the limitation must be recorded in the provider risk register.

## 8. Callback_Rejection_Rules

A callback must be rejected or quarantined when:

* provider route cannot be identified
* environment is wrong
* signature validation fails
* authentication fails
* payload is malformed
* required provider reference is missing
* payload schema version is unsupported
* event type is unsupported
* amount conflicts with known financial state
* callback appears replayed outside allowed window
* provider route is blocked for callback processing
* callback would require prohibited state transition

Rejected callback must still be recorded as evidence when security and storage policy allow.

## 9. Callback_Deduplication_Rules

### 9.1 Deduplication_Key

Callback deduplication must use the strongest available combination of:

* provider_id
* provider_route_id
* provider_event_id
* provider_transaction_id
* provider_reference
* event_type
* event_timestamp
* payload_hash
* correlation field
* operation type

### 9.2 Duplicate_Callback_Behavior

Duplicate callback must:

* not duplicate state transition
* not duplicate customer notification
* not duplicate refund/cancellation application
* not duplicate dispute case
* not duplicate reconciliation case
* increase duplicate callback counter
* attach duplicate evidence where useful
* remain visible for provider reliability review

### 9.3 Duplicate_Callback_Limitation

If the provider does not provide stable callback identifiers, the route must be marked with a known limitation and may require stricter reconciliation.

## 10. Callback_Ordering_Rules

The POS Gateway must not assume provider callbacks arrive in order.

Late or out-of-order callback must be checked against:

* current internal state
* source event sequence
* provider reference map
* idempotency record
* state machine allowed transitions
* reconciliation status
* dispute status
* refund/cancellation state
* rollback or kill switch state

An older callback must not overwrite a newer confirmed state unless a governed correction event is created.

## 11. Delayed_Callback_Handling

Delayed callback may resolve unknown state only when:

* callback is valid
* provider reference matches
* operation type matches
* amount matches where relevant
* state machine permits transition
* no conflict exists with later evidence
* no dispute or legal hold requires manual review
* reconciliation case permits automated resolution

If delayed callback conflicts with current state, the system must create or update reconciliation case.

## 12. Conflicting_Callback_Handling

A callback is conflicting when it contradicts:

* prior provider evidence
* internal financial event ledger
* POS evidence
* refund/cancellation evidence
* settlement evidence
* manual recovery evidence
* reconciliation result
* dispute resolution
* amount or currency expectation
* provider reference mapping

Conflicting callback must:

* be preserved
* create conflict event
* block automatic final state where financial truth is affected
* create or update reconciliation case
* create or update dispute case if customer-impacting
* notify operations where severity threshold is met
* update provider risk register if repeated

## 13. Provider_Lookup_Trigger_Policy

Provider lookup must be triggered when asynchronous evidence is missing, delayed, unknown, or conflicting.

Required lookup triggers include:

* payment timeout
* payment unknown
* POS unknown
* cancellation unknown
* refund unknown
* callback missing beyond threshold
* callback malformed
* callback conflict
* duplicate payment suspicion
* duplicate callback conflict
* customer dispute
* chargeback notice
* reconciliation mismatch
* settlement provider-only record
* POS-only record
* internal-only record
* manual recovery review
* provider incident review

## 14. Provider_Lookup_Request_Policy

Provider lookup request must include:

* provider_id
* provider_route_id
* lookup_type
* lookup_reason
* related_internal_entity_type
* related_internal_entity_id
* provider_reference if available
* idempotency_key
* correlation_id
* amount
* currency
* timestamp window
* expected operation type
* evidence reference
* requester_type
* requested_at

Lookup must be read-only unless provider-specific policy explicitly defines safe lookup-side action.

## 15. Provider_Lookup_Response_Policy

Provider lookup response must be normalized through the adapter layer.

Required normalized fields include:

* lookup_result_id
* provider_status_raw
* provider_status_normalized
* provider_reference
* confidence_level
* amount
* currency
* provider_timestamp
* lookup_evidence_reference
* state_recommendation
* reconciliation_requirement
* dispute_requirement
* unresolved_gap
* next_action

Lookup response must not directly mutate projection.

## 16. Lookup_Result_Classes

Required lookup result classes include:

* `LOOKUP_CONFIRMED_SUCCESS`
* `LOOKUP_CONFIRMED_FAILURE`
* `LOOKUP_CONFIRMED_PENDING`
* `LOOKUP_NOT_FOUND`
* `LOOKUP_INCONCLUSIVE`
* `LOOKUP_CONFLICTED`
* `LOOKUP_UNSUPPORTED`
* `LOOKUP_PROVIDER_UNAVAILABLE`
* `LOOKUP_AUTHORIZATION_FAILED`
* `LOOKUP_RATE_LIMITED`
* `LOOKUP_MALFORMED_RESPONSE`
* `LOOKUP_MANUAL_REVIEW_REQUIRED`

`LOOKUP_NOT_FOUND` must not automatically mean failure unless provider policy explicitly supports that interpretation.

## 17. Async_State_Reconciliation

### 17.1 Purpose

Async state reconciliation determines whether late external evidence can update internal state, create reconciliation case, or require manual review.

### 17.2 Reconciliation_Checks

Async reconciliation must check:

* provider route
* operation type
* internal entity
* provider reference
* idempotency key
* correlation id
* amount
* currency
* timestamp
* current internal state
* current customer status
* current staff status
* existing dispute case
* existing reconciliation case
* manual override history
* rollback history
* legal hold status

### 17.3 Reconciliation_Outcomes

Required async reconciliation outcomes include:

* `ASYNC_APPLIED`
* `ASYNC_DUPLICATE_IGNORED`
* `ASYNC_ATTACHED_AS_EVIDENCE`
* `ASYNC_STATE_ALREADY_CONFIRMED`
* `ASYNC_STATE_RESOLVED_FROM_UNKNOWN`
* `ASYNC_CONFLICT_CREATED`
* `ASYNC_RECONCILIATION_REQUIRED`
* `ASYNC_DISPUTE_REQUIRED`
* `ASYNC_MANUAL_REVIEW_REQUIRED`
* `ASYNC_REJECTED_INVALID`
* `ASYNC_REJECTED_UNSUPPORTED`

## 18. State_Application_Rule

Asynchronous evidence may update projection only when:

* callback or lookup evidence is valid
* event ledger entry is written
* idempotency/deduplication check passes
* state machine allows transition
* confidence level is sufficient
* no newer conflicting state exists
* route is allowed to process the async evidence
* legal hold or dispute does not block automation
* reconciliation outcome allows application

All projection updates must reference source event and evidence.

## 19. Missing_Callback_Policy

If a provider callback is expected but missing beyond threshold, the system must:

* create missing callback event
* trigger provider lookup if supported
* set customer status conservatively
* set staff status to pending/review where needed
* create reconciliation case if financial state is affected
* create provider risk marker if repeated
* alert operations if threshold is exceeded

Missing callback must not be silently ignored for financial operations.

## 20. Settlement_File_Async_Intake

Settlement files are asynchronous evidence.

Settlement file intake must:

* validate file source
* validate file format
* map provider references
* compare internal records
* create reconciliation events
* classify mismatch
* preserve file evidence
* prevent silent overwrite of payment state
* prevent silent closure of refund/cancellation ambiguity

Settlement evidence may confirm financial settlement, but must not erase prior dispute, refund, cancellation, or customer-impact evidence.

## 21. Receipt_Evidence_Async_Intake

Receipt evidence may arrive after the transaction.

Receipt evidence intake must:

* identify source
* link to internal order/payment/POS submission
* store evidence reference
* mark confidence level
* attach to dispute or reconciliation case if relevant
* avoid treating receipt alone as final financial truth unless policy permits

Receipt evidence must not silently replace provider approval evidence.

## 22. Customer_Status_During_Async_Processing

Customer-facing status must remain conservative during asynchronous processing.

Allowed statuses include:

* payment confirmation pending
* order confirmation pending
* cancellation confirmation pending
* refund confirmation pending
* duplicate payment under review
* support review required
* route temporarily unavailable

Customer status may change to completed only when async evidence is validated and state transition is allowed.

## 23. Staff_Status_During_Async_Processing

Staff-facing status must show the operational meaning of async processing.

Required staff signals include:

* callback delayed
* callback received
* callback invalid
* lookup required
* lookup in progress
* lookup inconclusive
* provider confirmed
* provider conflicted
* reconciliation required
* manual review required
* dispute required
* unsafe action blocked

Staff must not infer final financial truth from callback arrival alone.

## 24. Provider_Risk_Register_Linkage

Callback and lookup behavior must update provider risk when repeated issues occur.

Risk register update is required when:

* callback missing rate exceeds threshold
* duplicate callback rate exceeds threshold
* conflicting callback occurs
* callback validation cannot be performed
* provider lookup unsupported
* lookup frequently inconclusive
* provider state mapping is unstable
* settlement file contradicts callbacks
* provider documentation differs from runtime behavior
* callback ordering causes financial ambiguity

## 25. Observability_Requirements

The system must monitor:

* callback received count
* callback validation failure count
* callback authentication failure count
* callback signature failure count
* duplicate callback count
* conflicting callback count
* delayed callback count
* missing callback count
* provider lookup count
* provider lookup success count
* provider lookup inconclusive count
* provider lookup unsupported count
* async applied count
* async conflict count
* async manual review count
* async reconciliation required count
* async dispute required count
* settlement file mismatch count
* receipt evidence attachment count

Metrics must be tagged by:

* provider_id
* provider_route_id
* tenant_id
* store_id
* channel_id
* operation_type
* environment

## 26. Data_Model_Requirements

The implementation must support the following logical records.

### 26.1 Async_Evidence_Record

Required fields:

* async_evidence_id
* provider_id
* provider_route_id
* evidence_type
* source_type
* related_entity_type
* related_entity_id
* provider_reference
* correlation_id
* idempotency_key
* payload_hash
* validation_status
* confidence_level
* received_at
* evidence_reference
* status

### 26.2 Callback_Record

Required fields:

* callback_id
* provider_id
* provider_route_id
* callback_event_type
* provider_event_id
* provider_reference
* environment
* validation_status
* deduplication_status
* ordering_status
* provider_status_raw
* provider_status_normalized
* payload_hash
* received_at
* processed_at
* evidence_reference
* status

### 26.3 Provider_Lookup_Record

Required fields:

* provider_lookup_id
* provider_id
* provider_route_id
* lookup_type
* lookup_reason
* related_entity_type
* related_entity_id
* provider_reference
* requested_by
* requested_at
* completed_at
* lookup_result_class
* provider_status_raw
* provider_status_normalized
* confidence_level
* evidence_reference
* next_action
* status

### 26.4 Async_Reconciliation_Record

Required fields:

* async_reconciliation_id
* async_evidence_id
* related_entity_type
* related_entity_id
* current_state_before
* recommended_state
* reconciliation_outcome
* applied_event_id
* reconciliation_case_id
* dispute_case_id
* manual_review_required
* reason_code
* reviewed_by
* reviewed_at
* status

### 26.5 Missing_Callback_Record

Required fields:

* missing_callback_id
* provider_id
* provider_route_id
* expected_event_type
* related_entity_type
* related_entity_id
* expected_after_at
* detected_at
* lookup_triggered
* reconciliation_case_id
* provider_risk_record_id
* status

## 27. Access_Control

Async evidence records must be access-controlled.

### 27.1 Store_Staff

Store staff may view:

* operational status
* callback delayed indicator
* provider confirmation pending indicator
* allowed actions
* blocked actions
* runbook reference

Store staff must not access raw callback payload.

### 27.2 Store_Manager

Store manager may view:

* store-scoped async status
* manual review required cases
* provider delay indicators
* escalation path

### 27.3 Tenant_Admin

Tenant admin may view:

* tenant-scoped provider delay summary
* unresolved async reconciliation summary
* callback delay summary
* provider issue summary

### 27.4 HQ_Support

HQ support may view:

* callback status
* lookup records
* async reconciliation outcomes
* missing callback cases
* provider escalation linkage

### 27.5 HQ_Compliance_And_Finance

HQ compliance and finance may view:

* financial async evidence
* lookup evidence
* settlement evidence
* reconciliation linkage
* dispute linkage
* evidence packet linkage

Raw payload access must be restricted and logged.

## 28. Test_Requirements

The implementation must support tests for:

* invalid callback is recorded but cannot update state
* duplicate callback does not duplicate state transition
* delayed callback resolves unknown state only when allowed
* delayed callback conflicting with current state creates reconciliation case
* missing callback triggers lookup
* lookup not found does not automatically mean failure unless provider policy allows
* lookup unsupported creates provider limitation
* malformed lookup response creates manual review
* settlement file mismatch creates reconciliation case
* receipt evidence attaches but does not become financial truth alone
* customer status remains conservative during async processing
* staff status shows lookup/reconciliation requirement
* async projection update references event and evidence
* provider risk register updates after repeated callback problems

## 29. Readiness_Checklist

Before callback receiver, provider lookup worker, settlement intake, or async reconciliation can enter controlled implementation, the following checklist must pass.

### 29.1 Callback

* [ ] Callback receiver boundary is defined.
* [ ] Callback validation is defined.
* [ ] Callback rejection rules are defined.
* [ ] Callback deduplication rules are defined.
* [ ] Callback ordering rules are defined.
* [ ] Delayed callback handling is defined.
* [ ] Conflicting callback handling is defined.

### 29.2 Lookup

* [ ] Provider lookup triggers are defined.
* [ ] Lookup request policy is defined.
* [ ] Lookup response policy is defined.
* [ ] Lookup result classes are defined.
* [ ] Lookup unsupported handling is defined.
* [ ] Lookup does not directly mutate projection.

### 29.3 Async_Reconciliation

* [ ] Async reconciliation checks are defined.
* [ ] Async reconciliation outcomes are defined.
* [ ] State application rule is defined.
* [ ] Missing callback policy is defined.
* [ ] Settlement file async intake is defined.
* [ ] Receipt evidence async intake is defined.

### 29.4 Status_And_Risk

* [ ] Customer status remains conservative.
* [ ] Staff status shows async processing meaning.
* [ ] Provider risk linkage is defined.
* [ ] Observability metrics are defined.
* [ ] Access control is defined.
* [ ] Test cases are defined.

## 30. Non_Goals

This policy does not define:

* final callback endpoint URL
* final provider-specific signature algorithm
* final webhook retry infrastructure
* final queue technology
* final settlement file parser
* final receipt OCR or image parser
* final provider lookup API code
* final reconciliation algorithm
* final UI implementation

Those must be handled by implementation, provider-specific, security, infrastructure, reconciliation, and UI documents.

This policy defines the asynchronous provider evidence boundary required before callback, webhook, lookup, and reconciliation intake are implemented.

## 31. Acceptance_Criteria

This policy is accepted when:

* callback receiver cannot directly update financial state
* callback validation rules are defined
* invalid callback cannot mutate state
* duplicate callback is idempotent
* delayed callback is checked against current state
* conflicting callback creates reconciliation path
* missing callback triggers lookup or review
* provider lookup does not directly mutate projection
* lookup result classes are defined
* lookup not found is not automatically failure
* async state reconciliation outcomes are defined
* settlement evidence cannot silently overwrite payment truth
* receipt evidence cannot silently become final financial truth
* customer status remains conservative during async processing
* staff status exposes lookup, delay, conflict, and review states
* provider callback/lookup problems update provider risk register
* async processing emits observability metrics

## 32. Final_Rule

Asynchronous provider evidence is powerful because it may arrive after the customer, staff, POS, and internal gateway have already moved forward.

Therefore, it must be handled more carefully than synchronous responses.

A late callback may resolve ambiguity, but it must never rewrite history silently.
