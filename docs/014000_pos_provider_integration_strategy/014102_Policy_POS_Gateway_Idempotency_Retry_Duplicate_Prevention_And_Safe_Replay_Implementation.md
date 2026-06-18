# 014102_Policy_POS_Gateway_Idempotency_Retry_Duplicate_Prevention_And_Safe_Replay_Implementation

## 1. Purpose

This document defines the POS Gateway implementation policy for idempotency, retry classification, duplicate prevention, duplicate payment detection, callback deduplication, replay safety, and provider-safe recovery.

The POS Gateway must prevent repeated requests, delayed callbacks, provider timeouts, local replay, manual retry, staff action, or queue reprocessing from creating duplicate payment, duplicate POS order, duplicate cancellation, duplicate refund, duplicate kitchen ticket, duplicate customer notification, or duplicate dispute case.

The purpose of this policy is to ensure that every retry and replay path is governed by explicit idempotency and safety rules before any provider-specific route is implemented or released.

## 2. Scope

This policy applies to all POS Gateway operations that can be retried, replayed, duplicated, delayed, or repeated, including:

* payment authorization
* payment cancellation
* refund
* partial refund
* POS order submission
* POS cancellation
* provider lookup
* provider callback
* duplicate callback
* delayed callback
* customer notification
* staff notification
* kitchen ticket creation
* wait-order handoff
* table-order handoff
* kiosk submission
* mini-kiosk submission
* local ledger replay
* degraded-mode recovery
* manual POS entry
* manual recovery
* reconciliation case creation
* dispute case creation
* evidence packet generation
* route rollback recovery

This policy applies before first provider adapter implementation, retry worker implementation, queue implementation, local replay implementation, refund/cancellation automation, or production route release.

## 3. Relationship_To_Previous_Documents

This document follows:

* `014096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry.md`
* `014098_Policy_POS_Gateway_State_Machine_Payment_POS_Cancellation_Refund_And_Customer_Status.md`
* `014100_Policy_POS_Gateway_Adapter_Interface_Request_Response_Callback_And_Error_Mapping.md`

It implements the retry and duplicate-prevention controls required by:

* `014071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md`
* `014073_Policy_POS_Gateway_Offline_Degraded_Mode_Local_Ledger_Replay_And_Reconciliation.md`
* `014077_Policy_POS_Gateway_Observability_SLO_Incident_Command_And_Provider_Escalation.md`
* `014081_Policy_POS_Gateway_Controlled_Production_Release_Rollback_And_Provider_Route_Change_Governance.md`
* `014094_Policy_POS_Gateway_Implementation_Backlog_Provider_Route_Build_Order_And_Phase_Cutline.md`

The rule is:

> Retry is not a loop.
> Retry is a governed financial decision.

## 4. Core_Principle

The POS Gateway must assume that every external operation can be repeated, delayed, duplicated, or partially completed.

The system must therefore make all financially or operationally significant actions:

* idempotent
* traceable
* replay-safe
* duplicate-aware
* provider-aware
* state-machine-controlled
* evidence-backed
* reconciliation-ready
* customer-protective
* staff-action-safe

The system must never treat a timeout as permission to repeat a financial action without first determining whether the original action may have succeeded.

## 5. Idempotency_Target_Operations

The following operations must require idempotency:

* payment authorization request
* payment cancellation request
* refund request
* partial refund request
* POS order submission
* POS cancellation
* kitchen ticket creation
* customer notification
* staff notification
* provider callback processing
* provider lookup result application
* local ledger replay
* manual POS entry registration
* manual recovery execution
* dispute case creation
* reconciliation case creation
* evidence packet generation
* release rollback execution
* route kill switch activation

A financial operation without idempotency must be blocked.

## 6. Idempotency_Key_Policy

### 6.1 Key_Purpose

An idempotency key must identify a logical operation, not merely an HTTP request.

The same logical operation retried due to timeout, queue restart, network issue, browser retry, callback delay, or local replay must reuse the same governed idempotency identity.

### 6.2 Required_Key_Components

An idempotency key should be derived from or linked to:

* tenant_id
* store_id
* provider_route_id
* operation_type
* internal_entity_type
* internal_entity_id
* amount where financially relevant
* currency where financially relevant
* action_sequence where repeated actions are valid
* correlation_id
* request_intent_version

### 6.3 Key_Separation

The implementation must not reuse the same idempotency key across different logical operations.

Separate keys are required for:

* payment authorization
* payment cancellation
* refund
* partial refund
* POS order submission
* POS cancellation
* customer notification
* kitchen ticket creation
* local replay action
* manual recovery action

### 6.4 Key_ReUse_Rule

The same key may be reused only when the system is repeating the same logical operation with the same request intent.

If the request body, amount, operation type, provider route, or target entity differs, the duplicate key must create `IDEMPOTENCY_CONFLICT`.

## 7. Idempotency_Record_Lifecycle

The idempotency record must support the following states:

* `IDEMPOTENCY_RESERVED`
* `IDEMPOTENCY_IN_PROGRESS`
* `IDEMPOTENCY_COMPLETED`
* `IDEMPOTENCY_CONFLICT`
* `IDEMPOTENCY_UNKNOWN_RESULT`
* `IDEMPOTENCY_LOOKUP_REQUIRED`
* `IDEMPOTENCY_RECONCILIATION_REQUIRED`
* `IDEMPOTENCY_BLOCKED`
* `IDEMPOTENCY_EXPIRED`

### 7.1 RESERVED

Created before the external operation begins.

Required evidence:

* operation type
* target entity
* request hash
* actor/source
* correlation id
* provider route
* created timestamp

### 7.2 IN_PROGRESS

Set when the operation is actively being executed.

The system must prevent a second worker from executing the same operation concurrently.

### 7.3 COMPLETED

Set only when the operation result is known and state machine transition has been accepted.

### 7.4 UNKNOWN_RESULT

Set when the request may have reached the provider but the result is not known.

This state must block unsafe repeat execution.

### 7.5 LOOKUP_REQUIRED

Set when provider lookup is required before retry or closure.

### 7.6 RECONCILIATION_REQUIRED

Set when provider lookup cannot resolve final truth.

### 7.7 BLOCKED

Set when the operation cannot safely proceed due to duplicate risk, kill switch, route block, provider limitation, state conflict, or expired waiver.

## 8. Request_Hash_Policy

Every idempotent operation must store a request hash.

Request hash should include:

* operation type
* target entity id
* amount
* currency
* provider route
* action type
* request body normalized form
* request intent version

If an idempotency key is reused with a different request hash:

* the operation must be blocked
* conflict event must be written
* staff/customer status must remain conservative
* review case may be created
* metric must be emitted

## 9. Retry_Classification

All retry attempts must be classified before execution.

Required retry classes include:

* `RETRY_SAFE`
* `RETRY_SAFE_AFTER_LOOKUP`
* `RETRY_SAFE_AFTER_IDEMPOTENCY_CONFIRMATION`
* `RETRY_UNSAFE`
* `RETRY_BLOCKED_DUPLICATE_RISK`
* `RETRY_BLOCKED_STATE_CONFLICT`
* `RETRY_BLOCKED_PROVIDER_LIMITATION`
* `RETRY_BLOCKED_KILL_SWITCH`
* `RETRY_BLOCKED_MANUAL_REVIEW`
* `RETRY_RECONCILIATION_REQUIRED`

### 9.1 RETRY_SAFE

Allowed only when repeating the operation cannot create duplicate external side effects.

Examples may include:

* idempotent read-only provider lookup
* duplicate callback processing
* notification status query
* internal projection rebuild

### 9.2 RETRY_SAFE_AFTER_LOOKUP

Allowed only after provider lookup confirms that the prior operation did not complete or can be safely retried.

### 9.3 RETRY_UNSAFE

Used when repeating the operation may create duplicate payment, duplicate refund, duplicate cancellation, duplicate POS order, or duplicate fulfillment.

Unsafe retry must be blocked unless an authorized provider-specific rule allows it.

### 9.4 RETRY_RECONCILIATION_REQUIRED

Used when the system cannot determine whether retry is safe.

The operation must enter reconciliation or manual review.

## 10. Retry_By_Operation_Type

### 10.1 Payment_Authorization_Retry

Payment authorization retry is unsafe by default.

It may be retried only when:

* provider supports idempotent authorization
* same idempotency key is accepted by provider or safely simulated internally
* provider lookup confirms no approval exists
* duplicate payment risk is absent
* state machine allows retry
* route policy allows retry

If the result is unknown, payment retry must be blocked until lookup or review.

### 10.2 Payment_Cancellation_Retry

Payment cancellation retry may be safe only when:

* provider cancellation is idempotent
* provider returns stable cancellation reference
* original payment exists
* cancellation is not already completed
* cancellation amount matches
* state machine allows retry

If provider cancellation state is unknown, lookup or reconciliation is required.

### 10.3 Refund_Retry

Refund retry is unsafe by default.

Refund retry may proceed only when:

* provider supports idempotent refund
* refund amount matches original request
* refund was not already completed
* partial refund limit is not exceeded
* idempotency record confirms same request intent
* provider lookup does not show completed refund
* state machine allows retry

### 10.4 POS_Order_Submission_Retry

POS submission retry is unsafe by default when provider may create duplicate POS orders.

It may proceed only when:

* provider supports idempotent order submission
* provider lookup confirms order was not created
* same internal order id maps safely to same POS order
* prior submission did not succeed
* state machine allows replay or retry

If POS result is unknown, retry must prefer lookup or manual review.

### 10.5 Customer_Notification_Retry

Customer notification retry may be allowed when:

* notification template and version are unchanged
* message is still accurate
* duplicate notification is acceptable or suppressed
* delivery status is unknown or failed
* idempotency prevents duplicate misleading message

Customer notification retry must not send outdated success/failure claims after state changes.

## 11. Duplicate_Prevention_Policy

### 11.1 Duplicate_Risk_Targets

The system must prevent duplicates for:

* payment approvals
* refunds
* cancellations
* POS orders
* kitchen tickets
* customer notifications
* staff notifications
* dispute cases
* reconciliation cases
* evidence packets
* manual recovery actions
* local replay actions

### 11.2 Duplicate_Risk_Signals

Duplicate risk may be detected from:

* repeated idempotency key
* same customer and amount within configured window
* same order and multiple payment attempts
* same POS order reference
* same provider transaction reference
* duplicate provider callback
* retry after timeout
* queue worker restart
* browser resubmission
* kiosk session resubmission
* mini-kiosk session resubmission
* local ledger replay
* staff manual action after automated action
* reconciliation mismatch
* customer claim

### 11.3 Duplicate_Risk_Response

When duplicate risk is detected, the system must:

* block unsafe operation
* write duplicate risk event
* set customer status conservatively
* set staff status to review or hold
* create or update duplicate review case where required
* trigger provider lookup where supported
* trigger reconciliation where needed
* prevent staff from asking customer to pay again unless approved
* prevent automatic refund unless safe
* emit observability metric

## 12. Duplicate_Payment_Detection

### 12.1 Detection_Rules

Duplicate payment detection must consider:

* same order_id with multiple approved payment attempts
* same customer_reference and amount within configured time window
* same device/session and amount within configured time window
* same provider reference appearing more than once
* same idempotency key with conflicting request
* provider duplicate approval callback
* POS order linked to multiple payment approvals
* payment retry after unknown result
* customer dispute claim
* reconciliation provider-only duplicate

### 12.2 Detection_Output

Duplicate payment detection must produce:

* duplicate_case_id or reference
* primary payment attempt
* suspected duplicate payment attempt
* detection rule
* confidence level
* affected amount
* affected customer reference
* fulfillment hold recommendation
* refund review recommendation
* reconciliation requirement
* customer status recommendation
* staff status recommendation

### 12.3 Fulfillment_Hold_Rule

If duplicate payment may create duplicate order fulfillment, the staff status must show hold or review where appropriate.

The system must distinguish:

* duplicate payment for same order
* duplicate order with duplicate payment
* duplicate payment but single order
* duplicate callback only
* duplicate provider reference only

## 13. Callback_Deduplication

### 13.1 Callback_Deduplication_Key

Callback deduplication must use available fields such as:

* provider_id
* provider_route_id
* provider_event_id
* provider_transaction_id
* provider_reference
* event_type
* event_timestamp
* payload_hash
* correlation field

If provider has no stable callback id, the limitation must be recorded.

### 13.2 Duplicate_Callback_Rule

Duplicate callback must not:

* duplicate financial event result
* repeat customer notification
* repeat refund/cancellation state change
* repeat POS acceptance
* close dispute twice
* override newer state

Duplicate callback may:

* increment duplicate metric
* attach additional evidence
* confirm already known state
* trigger provider limitation warning if excessive

### 13.3 Conflicting_Callback_Rule

If callbacks conflict, the system must:

* preserve both callback records
* block automatic final state if conflict affects financial truth
* create reconciliation case
* create dispute case if customer-impacting
* update provider risk register if repeated

## 14. Queue_And_Worker_Safety

Queue workers must be idempotent.

A queue retry must not execute an external financial action unless:

* idempotency record permits it
* state machine permits it
* route policy permits it
* duplicate risk is absent
* kill switch is not active
* provider route is in allowed state

Worker restart must not cause duplicate execution.

Concurrent workers must not execute the same idempotency key.

## 15. Local_Ledger_Replay_Safety

Local replay must be governed by both local ledger record and central idempotency record.

Replay may proceed only when:

* local ledger record is valid
* local record hash or sequence is valid where supported
* central idempotency record permits action
* provider route is enabled
* state machine permits replay
* provider lookup confirms safety where required
* no dispute or legal hold blocks replay
* no manual review block exists
* duplicate risk is absent

Replay must be blocked when:

* payment authorization result is unknown
* provider may have already executed action
* refund may already be completed
* cancellation may already be completed
* POS order may already exist
* local record appears tampered
* idempotency key conflicts
* route kill switch is active

## 16. Safe_Replay_Result_Classes

Replay result must be classified as:

* `REPLAY_SUCCESS`
* `REPLAY_SKIPPED_ALREADY_APPLIED`
* `REPLAY_SKIPPED_DUPLICATE_CALLBACK`
* `REPLAY_SKIPPED_PROVIDER_ALREADY_CONFIRMED`
* `REPLAY_BLOCKED_UNSAFE_PAYMENT`
* `REPLAY_BLOCKED_DUPLICATE_RISK`
* `REPLAY_BLOCKED_STATE_CONFLICT`
* `REPLAY_BLOCKED_IDEMPOTENCY_CONFLICT`
* `REPLAY_BLOCKED_PROVIDER_LIMITATION`
* `REPLAY_BLOCKED_KILL_SWITCH`
* `REPLAY_BLOCKED_LEGAL_HOLD`
* `REPLAY_RECONCILIATION_REQUIRED`
* `REPLAY_MANUAL_REVIEW_REQUIRED`
* `REPLAY_FAILED_RETRYABLE`
* `REPLAY_FAILED_FINAL`

Replay result must be recorded as evidence.

## 17. Manual_Retry_And_Staff_Action_Safety

Staff and store managers must not be able to bypass retry safety.

The system must block staff from:

* retrying payment when payment unknown exists
* asking customer to pay again when duplicate risk exists
* marking payment complete without provider evidence
* retrying refund without idempotency check
* retrying cancellation without idempotency check
* manually re-submitting POS order when POS unknown exists unless authorized
* clearing duplicate warning
* clearing replay conflict
* closing reconciliation requirement

Manual recovery must create an auditable action and must not delete the original ambiguity.

## 18. Customer_Status_During_Retry_And_Replay

Customer status must remain conservative during retry and replay.

Allowed statuses include:

* payment confirmation pending
* order confirmation pending
* cancellation confirmation pending
* refund confirmation pending
* duplicate payment under review
* support review required
* route temporarily unavailable

Forbidden statuses include:

* payment completed without evidence
* payment failed when unknown
* refund completed without evidence
* cancellation completed without evidence
* duplicate resolved without reconciliation or authorized resolution
* order confirmed without route-specific acceptance evidence

## 19. Staff_Status_During_Retry_And_Replay

Staff status must show:

* retry in progress
* lookup required
* duplicate risk
* unsafe retry blocked
* provider delayed
* POS unknown
* refund pending
* cancellation pending
* local replay pending
* replay conflict
* reconciliation required
* manual review required

Staff status must bind to allowed and blocked action sets.

## 20. Idempotency_And_Retry_Data_Model_Requirements

The implementation must support the following logical records.

### 20.1 Idempotency_Record

Required fields:

* idempotency_record_id
* idempotency_key
* tenant_id
* store_id
* provider_route_id
* operation_type
* target_entity_type
* target_entity_id
* request_hash
* request_intent_version
* first_seen_at
* last_seen_at
* request_count
* result_reference
* idempotency_state
* conflict_reason
* expires_at
* created_at
* updated_at

### 20.2 Retry_Attempt_Record

Required fields:

* retry_attempt_id
* idempotency_record_id
* provider_route_id
* operation_type
* target_entity_type
* target_entity_id
* retry_class
* retry_reason
* attempted_by
* attempted_at
* attempt_number
* result_class
* blocked_reason
* evidence_reference
* next_action

### 20.3 Duplicate_Risk_Record

Required fields:

* duplicate_risk_id
* tenant_id
* store_id
* provider_route_id
* duplicate_risk_type
* primary_entity_type
* primary_entity_id
* suspected_duplicate_entity_type
* suspected_duplicate_entity_id
* detection_rule
* confidence_level
* affected_amount
* customer_reference
* staff_status
* customer_status
* reconciliation_required
* dispute_required
* status
* created_at
* resolved_at

### 20.4 Callback_Deduplication_Record

Required fields:

* callback_deduplication_id
* provider_id
* provider_route_id
* callback_key
* provider_event_id
* provider_reference
* event_type
* payload_hash
* first_seen_at
* last_seen_at
* seen_count
* duplicate_status
* conflict_status
* evidence_reference

### 20.5 Replay_Safety_Record

Required fields:

* replay_safety_id
* local_ledger_id
* idempotency_record_id
* provider_route_id
* operation_type
* eligibility_status
* eligibility_checked_at
* checked_by
* block_reason
* provider_lookup_reference
* reconciliation_case_id
* dispute_case_id
* replay_result_class
* evidence_reference
* status

## 21. Observability_Requirements

The system must monitor:

* idempotency key creation count
* idempotency conflict count
* unknown result count
* retry attempt count
* unsafe retry block count
* duplicate payment suspicion count
* duplicate POS submission block count
* duplicate refund block count
* duplicate cancellation block count
* duplicate callback count
* conflicting callback count
* replay pending count
* replay blocked count
* replay conflict count
* provider lookup required count
* reconciliation required after retry count
* staff prohibited retry attempt count

Metrics must be tagged by:

* provider_id
* provider_route_id
* tenant_id
* store_id
* channel_id
* operation_type
* environment

## 22. Access_Control

Idempotency and duplicate-prevention records must be access-controlled.

### 22.1 Store_Staff

Store staff may view:

* operational duplicate warning
* retry blocked message
* allowed action
* blocked action
* runbook reference

Store staff must not modify idempotency records.

### 22.2 Store_Manager

Store manager may view:

* store-scoped duplicate risk
* manual recovery guidance
* POS unknown cases
* payment unknown cases
* escalation path

Store manager must not clear duplicate risk without authorized workflow.

### 22.3 HQ_Support

HQ support may view:

* duplicate risk details
* retry attempts
* callback deduplication summary
* provider lookup requirement
* reconciliation linkage

### 22.4 HQ_Compliance_And_Finance

HQ compliance and finance may view:

* financial idempotency records
* duplicate payment cases
* refund retry records
* cancellation retry records
* reconciliation linkage
* dispute linkage

### 22.5 Developer

Developer production access must be masked and controlled.

No raw secrets or sensitive customer data should be exposed through retry diagnostics.

## 23. Test_Requirements

The implementation must support tests for:

* missing idempotency key blocks financial operation
* same idempotency key and same request hash returns same result or safe status
* same idempotency key and different request hash creates conflict
* payment timeout does not trigger unsafe retry
* payment unknown blocks customer pay-again flow where duplicate risk exists
* duplicate payment suspicion creates duplicate risk record
* duplicate provider callback is idempotent
* conflicting provider callback creates reconciliation case
* refund retry is blocked when prior refund unknown
* cancellation retry is blocked when prior cancellation unknown
* POS retry is blocked when POS may already exist
* queue worker restart does not duplicate operation
* concurrent workers do not execute same idempotency key
* local replay blocks unsafe payment authorization
* local replay creates reconciliation case on conflict
* staff cannot clear duplicate risk
* customer status remains conservative during retry
* staff status shows blocked action during duplicate risk

## 24. Readiness_Checklist

Before retry worker, callback processor, refund automation, cancellation automation, local replay, or provider production route can be implemented, the following checklist must pass.

### 24.1 Idempotency

* [ ] Financial operations require idempotency key.
* [ ] Idempotency record lifecycle is defined.
* [ ] Request hash is stored.
* [ ] Key reuse rule is defined.
* [ ] Key conflict rule is defined.
* [ ] Concurrent execution is blocked.
* [ ] Idempotency expiration does not delete audit evidence.

### 24.2 Retry

* [ ] Retry classes are defined.
* [ ] Payment retry is unsafe by default.
* [ ] Refund retry is unsafe by default.
* [ ] Cancellation retry checks provider/POS state.
* [ ] POS retry checks duplicate POS risk.
* [ ] Customer notification retry checks message validity.
* [ ] Unknown result triggers lookup or reconciliation.

### 24.3 Duplicate_Prevention

* [ ] Duplicate risk targets are defined.
* [ ] Duplicate risk signals are defined.
* [ ] Duplicate payment detection rules exist.
* [ ] Duplicate callback handling exists.
* [ ] Duplicate POS submission block exists.
* [ ] Duplicate refund block exists.
* [ ] Duplicate cancellation block exists.
* [ ] Staff prohibited actions are blocked.

### 24.4 Replay

* [ ] Replay eligibility is defined.
* [ ] Replay blocked conditions are defined.
* [ ] Replay result classes are defined.
* [ ] Local ledger replay requires central idempotency.
* [ ] Replay conflict creates reconciliation or dispute case.
* [ ] Unsafe financial replay is blocked.

### 24.5 Observability_And_Access

* [ ] Idempotency metrics exist.
* [ ] Duplicate risk metrics exist.
* [ ] Retry block metrics exist.
* [ ] Replay conflict metrics exist.
* [ ] Staff prohibited retry metrics exist.
* [ ] Access control is defined.
* [ ] Tests cover duplicate, retry, callback, and replay paths.

## 25. Non_Goals

This policy does not define:

* final queue implementation
* final worker technology
* final database lock strategy
* final distributed lock provider
* final provider-specific idempotency header
* final customer UI copy
* final staff UI implementation
* final reconciliation algorithm
* final dispute packet implementation

Those must be handled by implementation, provider-specific, infrastructure, UI, reconciliation, and dispute documents.

This policy defines the logical and operational safety boundary for idempotency, retry, duplicate prevention, and safe replay.

## 26. Acceptance_Criteria

This policy is accepted when:

* idempotency is required for all financial operations
* idempotency key reuse rules are defined
* request hash conflict blocks execution
* retry classification is defined
* payment authorization retry is unsafe by default
* refund retry is unsafe by default
* POS submission retry is unsafe when duplicate POS order may occur
* duplicate payment detection rules exist
* duplicate callback handling is idempotent
* conflicting callback creates review path
* local replay requires central idempotency
* unsafe replay is blocked
* staff cannot bypass retry safety
* customer status remains conservative during retry and replay
* retry and duplicate-prevention records are auditable
* retry and duplicate metrics are observable
* provider-specific routes cannot implement retry outside this policy

## 27. Final_Rule

The POS Gateway must never retry blindly.

Every retry must answer one question first:

> Can this action be repeated without creating a second financial or operational truth?

If the answer is unknown, the retry must stop, preserve evidence, protect the customer, and enter lookup, reconciliation, or manual review.
