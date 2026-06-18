# 014073_Policy_POS_Gateway_Offline_Degraded_Mode_Local_Ledger_Replay_And_Reconciliation

## 1. Purpose

This document defines the offline, degraded-mode, local ledger, replay, and reconciliation policy for the POS Gateway Resilience lane.

The POS Gateway must not assume that store network, POS provider API, payment provider route, VAN/PG route, kiosk channel, mini-kiosk channel, staff device, or internal cloud service will always be online.

When connectivity or provider availability is degraded, the system must preserve operational continuity without creating unverifiable financial, order, cancellation, refund, or settlement state.

The purpose of this policy is to ensure that degraded operation remains:

* evidence-preserving
* customer-protective
* replay-safe
* idempotent
* reconciliation-ready
* financially auditable
* provider-aware
* store-operable
* legally defensible

## 2. Scope

This policy applies to all POS Gateway flows that may enter offline or degraded mode, including:

* POS API unavailable
* payment provider unavailable
* VAN/PG route unavailable
* store network unstable
* kiosk network unstable
* mini-kiosk web session unstable
* table order session disconnected
* wait-order handoff delayed
* staff device unavailable
* internal API timeout
* provider callback delayed
* provider lookup unavailable
* order accepted but POS confirmation missing
* payment approved but order confirmation missing
* cancellation requested but provider/POS response missing
* refund requested but provider response missing
* local queue backlog
* replay after recovery
* reconciliation after offline period
* manual staff recovery during degraded mode

This policy applies to official POS API integrations, unofficial bridge integrations, provider export/import integrations, printer fallback, kitchen-ticket fallback, and manual POS entry fallback.

## 3. Relationship_To_Previous_Documents

This document follows:

* `05640_POS_Gateway_Compliance_Financial_Audit_Regulatory_And_Consumer_Protection_Readiness_Policy.md`
* `014071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md`

The previous documents define compliance evidence and dispute packet readiness.

This document defines how the POS Gateway must behave when the system cannot immediately complete provider calls, POS calls, payment confirmation, cancellation confirmation, refund confirmation, or settlement confirmation.

The rule is:

> Offline operation is allowed only when the system can preserve local evidence and safely reconcile later.

## 4. Core_Principle

The POS Gateway must treat offline and degraded operation as a controlled financial state, not as a simple retry queue.

The system must not:

* silently accept orders without evidence
* silently mark payment as complete without provider evidence
* silently mark cancellation as complete without POS/provider evidence
* silently mark refund as complete without provider evidence
* replay the same financial action twice
* lose local evidence during device restart
* overwrite cloud truth with stale local truth
* overwrite provider truth with staff assumption
* hide ambiguity from customer or store
* clear degraded-mode records before reconciliation

Every degraded operation must preserve a local ledger entry and later reconcile against cloud, POS, provider, and settlement evidence.

## 5. Degraded_Mode_Categories

The POS Gateway must classify degraded mode into standardized categories.

Required categories include:

* `STORE_NETWORK_DEGRADED`
* `STORE_NETWORK_OFFLINE`
* `POS_PROVIDER_API_DEGRADED`
* `POS_PROVIDER_API_OFFLINE`
* `PAYMENT_PROVIDER_DEGRADED`
* `PAYMENT_PROVIDER_OFFLINE`
* `VAN_PG_ROUTE_DEGRADED`
* `VAN_PG_ROUTE_OFFLINE`
* `KIOSK_CHANNEL_DEGRADED`
* `MINI_KIOSK_CHANNEL_DEGRADED`
* `STAFF_DEVICE_DEGRADED`
* `INTERNAL_GATEWAY_DEGRADED`
* `INTERNAL_EVENT_LEDGER_DEGRADED`
* `PROVIDER_CALLBACK_DELAYED`
* `PROVIDER_LOOKUP_UNAVAILABLE`
* `POS_LOOKUP_UNAVAILABLE`
* `RECONCILIATION_DELAYED`
* `MANUAL_RECOVERY_REQUIRED`
* `REPLAY_REQUIRED`
* `REPLAY_BLOCKED`
* `REPLAY_CONFLICT_DETECTED`

Each category must have:

* detection rule
* allowed actions
* blocked actions
* customer-facing status
* staff-facing status
* evidence requirement
* replay rule
* reconciliation rule
* escalation owner

## 6. Offline_And_Degraded_Mode_State_Model

The POS Gateway must support explicit degraded-mode states.

Required states include:

* `ONLINE_NORMAL`
* `ONLINE_PROVIDER_DELAYED`
* `ONLINE_POS_DELAYED`
* `ONLINE_INTERNAL_DELAYED`
* `DEGRADED_ACCEPTING_LIMITED`
* `DEGRADED_READ_ONLY`
* `DEGRADED_MANUAL_RECOVERY`
* `OFFLINE_LOCAL_CAPTURE_ONLY`
* `OFFLINE_ORDER_HOLD_ONLY`
* `OFFLINE_PAYMENT_BLOCKED`
* `OFFLINE_POS_BLOCKED`
* `REPLAY_PENDING`
* `REPLAY_IN_PROGRESS`
* `REPLAY_PARTIAL_SUCCESS`
* `REPLAY_CONFLICT`
* `RECONCILIATION_PENDING`
* `RECONCILIATION_REQUIRED`
* `RECOVERED_NORMAL`

The system must not compress these states into vague labels such as `offline`, `pending`, or `done`.

## 7. Local_Ledger_Requirement

### 7.1 Local_Ledger_Purpose

When cloud, POS, payment provider, or network connectivity is degraded, the system must preserve a local ledger before allowing any operational continuation that may affect customer, order, payment, cancellation, refund, or fulfillment state.

The local ledger is not the final financial truth.

It is a protected evidence buffer used to:

* preserve customer action
* preserve staff action
* preserve order intent
* preserve payment attempt reference
* preserve cancellation/refund request
* preserve device/channel context
* preserve timestamps
* preserve retry/replay relationship
* enable later reconciliation
* prevent duplicate financial actions
* explain degraded-mode behavior during disputes

### 7.2 Local_Ledger_Record_Families

The local ledger must support at minimum:

* local order intent record
* local payment intent record
* local POS submission intent record
* local cancellation intent record
* local refund intent record
* local customer notification record
* local staff action record
* local device state record
* local degraded-mode transition record
* local replay attempt record
* local reconciliation marker
* local conflict marker

### 7.3 Local_Ledger_Record_Fields

Required fields include:

* local_ledger_id
* local_sequence_number
* tenant_id
* store_id
* device_id
* channel_id
* session_id
* order_id
* payment_attempt_id
* cancellation_action_id
* refund_action_id
* event_type
* event_version
* local_status
* intended_remote_action
* actor_type
* actor_id
* amount
* currency
* idempotency_key
* correlation_id
* causation_id
* trace_id
* created_at_local
* device_clock_offset_if_known
* persisted_at_local
* first_replay_at
* last_replay_at
* replay_attempt_count
* replay_status
* reconciliation_status
* conflict_status
* payload_hash
* previous_record_hash
* local_chain_hash

### 7.4 Local_Ledger_Durability

The local ledger must be durable enough to survive:

* browser refresh
* app restart
* device sleep
* temporary network loss
* kiosk reload
* staff tablet reboot where technically feasible
* queue processor crash
* internal service retry
* local cache eviction attempt

If the implementation environment cannot guarantee durable local storage, the affected flow must be downgraded to a safer mode, such as:

* order hold only
* payment blocked
* staff confirmation required
* read-only status
* manual note capture only

## 8. Offline_Action_Classification

All actions during degraded mode must be classified.

### 8.1 Allowed_In_Local_Capture_Mode

The following may be allowed when configured and evidence can be locally preserved:

* customer order intent capture
* wait-order session preservation
* cart preservation
* table matching intent capture
* staff operational note
* customer notification attempt record
* store review case creation
* manual kitchen note creation
* deferred POS submission intent
* deferred reconciliation marker

### 8.2 Conditionally_Allowed

The following may be allowed only under provider-specific and tenant-approved rules:

* order acceptance without POS confirmation
* kitchen preparation start without POS confirmation
* cancellation request capture
* refund request capture
* manual receipt evidence attachment
* staff-confirmed external payment note
* local fulfillment hold release
* delayed customer notification
* provider lookup retry
* POS lookup retry

### 8.3 Blocked_By_Default

The following must be blocked by default during offline or degraded mode unless an explicitly approved provider/tenant policy allows it:

* new payment authorization without provider route
* final payment success marking without provider evidence
* final cancellation completion without provider/POS evidence
* final refund completion without provider evidence
* settlement finalization
* duplicate replay of payment authorization
* duplicate replay of refund
* duplicate replay of cancellation
* silent POS order injection after timeout
* clearing unresolved local ledger records
* deleting degraded-mode evidence
* closing dispute cases without reconciliation

## 9. Payment_During_Degraded_Mode

### 9.1 Payment_Authorization_Rule

If the payment provider or VAN/PG route is unavailable, the POS Gateway must not create an appearance of completed payment.

Allowed customer-facing statuses include:

* payment unavailable
* payment confirmation pending
* payment provider delayed
* store review required
* support review required

Forbidden customer-facing statuses include:

* payment completed
* payment failed
* refund completed
* order fully confirmed

unless supporting evidence exists.

### 9.2 Payment_Attempt_Local_Record

If a payment attempt is initiated and provider response becomes unknown, the system must record:

* payment_attempt_id
* request timestamp
* provider route
* request payload hash
* idempotency key
* timeout or failure reason
* customer-visible status
* staff-visible status
* retry eligibility
* provider lookup requirement
* duplicate risk marker
* dispute case marker if required

### 9.3 Unknown_Payment_Result

When payment result is unknown, the system must:

* prevent unsafe duplicate payment attempts
* attempt provider lookup if supported
* preserve idempotency key
* mark customer state conservatively
* create or update dispute case if aging threshold is exceeded
* block fulfillment where required
* allow staff to capture external receipt evidence
* attach the case to reconciliation

## 10. Order_And_POS_Submission_During_Degraded_Mode

### 10.1 POS_Submission_Rule

If POS submission fails, times out, or becomes unknown, the POS Gateway must not silently assume POS acceptance.

The order must enter one of the following states:

* `POS_SUBMISSION_PENDING`
* `POS_SUBMISSION_UNKNOWN`
* `POS_SUBMISSION_FAILED`
* `POS_SUBMISSION_MANUAL_REQUIRED`
* `POS_SUBMISSION_REPLAY_PENDING`
* `POS_SUBMISSION_RECONCILIATION_REQUIRED`

### 10.2 Kitchen_Execution_Risk

If kitchen execution begins before POS confirmation, the system must record:

* who allowed execution
* why execution was allowed
* customer payment state
* POS submission state
* kitchen ticket state
* expected reconciliation path
* risk owner
* manual recovery reason
* customer protection marker

### 10.3 Manual_POS_Entry

If staff manually enters an order into POS during degraded mode, the system must record:

* staff actor
* manager approval if required
* original internal order id
* manual POS order id if known
* amount
* menu item mapping
* timestamp
* reason code
* evidence attachment if available
* reconciliation requirement
* duplicate POS risk marker

Manual POS entry must not replace the internal order ledger.
It must be linked as recovery evidence.

## 11. Cancellation_During_Degraded_Mode

### 11.1 Cancellation_Request_Capture

Cancellation request may be locally captured during degraded mode, but must not be marked final unless POS/payment provider evidence exists.

Required local record fields:

* cancellation_action_id
* original_order_id
* original_payment_attempt_id
* customer request timestamp if applicable
* staff request timestamp if applicable
* preparation state
* POS state
* provider state
* requested amount if applicable
* reason code
* customer-facing pending status
* replay requirement
* reconciliation requirement

### 11.2 Cancellation_Replay

Cancellation replay must be idempotent.

Before replaying cancellation, the system must check:

* whether POS already cancelled
* whether provider already cancelled
* whether refund already issued
* whether order already fulfilled
* whether manual staff action changed state
* whether customer was already notified
* whether another replay attempt is in progress

### 11.3 Cancellation_Conflict

If cancellation replay conflicts with POS, payment, or fulfillment state, the system must create or update a dispute case.

Required conflict classes include:

* `CANCEL_REPLAY_POS_ALREADY_ACCEPTED`
* `CANCEL_REPLAY_PROVIDER_ALREADY_CANCELLED`
* `CANCEL_REPLAY_PROVIDER_NOT_FOUND`
* `CANCEL_REPLAY_ORDER_ALREADY_FULFILLED`
* `CANCEL_REPLAY_REFUND_REQUIRED`
* `CANCEL_REPLAY_DUPLICATE_RISK`
* `CANCEL_REPLAY_MANUAL_REVIEW_REQUIRED`

## 12. Refund_During_Degraded_Mode

### 12.1 Refund_Request_Capture

Refund request may be captured during degraded mode, but final refund completion must require provider evidence or authorized compliance resolution.

Required local record fields:

* refund_action_id
* original_payment_attempt_id
* original_order_id
* refund amount
* full or partial marker
* reason code
* requested by
* requested at
* provider availability state
* idempotency key
* replay eligibility
* customer-facing pending status
* dispute case id if applicable

### 12.2 Refund_Replay

Refund replay must be strictly controlled.

Before replaying refund, the system must verify:

* original payment exists
* original payment is not already cancelled
* refund was not already completed
* partial refund limit is not exceeded
* provider supports the requested refund type
* idempotency key is valid
* customer notification does not overstate completion
* reconciliation has not already resolved the case

### 12.3 Refund_Conflict

Refund conflict must create or update a dispute case.

Required conflict classes include:

* `REFUND_REPLAY_PROVIDER_NOT_FOUND`
* `REFUND_REPLAY_ALREADY_COMPLETED`
* `REFUND_REPLAY_AMOUNT_EXCEEDS_PAYMENT`
* `REFUND_REPLAY_PARTIAL_NOT_SUPPORTED`
* `REFUND_REPLAY_PAYMENT_NOT_SETTLED`
* `REFUND_REPLAY_DUPLICATE_RISK`
* `REFUND_REPLAY_MANUAL_REVIEW_REQUIRED`

## 13. Replay_Policy

### 13.1 Replay_Eligibility

A local ledger record may be replayed only when:

* the source record is complete
* the local hash chain is valid
* idempotency key exists
* provider route is available
* POS route is available if required
* no conflicting remote state is detected
* no active manual review block exists
* no legal hold block exists
* no duplicate replay is in progress

### 13.2 Replay_Order

Replay must follow safe ordering.

Recommended order:

1. restore degraded-mode transition records
2. sync local order intent records
3. sync customer notification evidence
4. sync staff action evidence
5. check provider payment state
6. check POS order state
7. replay safe POS submissions
8. replay safe cancellation requests
9. replay safe refund requests
10. create reconciliation cases for conflicts
11. update customer-facing projections
12. close replay batch only after reconciliation markers are created

Payment authorization replay must be prohibited unless provider-specific safe retry rules explicitly allow it.

### 13.3 Replay_Idempotency

Every replay action must use idempotency protection.

Replay must prevent:

* duplicate POS order creation
* duplicate kitchen ticket creation
* duplicate cancellation
* duplicate refund
* duplicate customer notification
* duplicate dispute case creation
* duplicate reconciliation case creation

### 13.4 Replay_Result_Classes

Required replay result classes include:

* `REPLAY_SUCCESS`
* `REPLAY_SKIPPED_ALREADY_REMOTE`
* `REPLAY_SKIPPED_UNSAFE`
* `REPLAY_PROVIDER_LOOKUP_REQUIRED`
* `REPLAY_POS_LOOKUP_REQUIRED`
* `REPLAY_CONFLICT_DETECTED`
* `REPLAY_MANUAL_REVIEW_REQUIRED`
* `REPLAY_FAILED_RETRYABLE`
* `REPLAY_FAILED_FINAL`
* `REPLAY_BLOCKED_BY_LEGAL_HOLD`
* `REPLAY_BLOCKED_BY_DISPUTE_CASE`

## 14. Reconciliation_After_Degraded_Mode

### 14.1 Reconciliation_Requirement

Every degraded-mode session must create a reconciliation requirement unless no financially or operationally relevant local action occurred.

Reconciliation must compare:

* local ledger records
* cloud event ledger
* POS records
* payment provider records
* cancellation records
* refund records
* customer notification records
* staff manual actions
* settlement records where available

### 14.2 Reconciliation_Result_Classes

Required result classes include:

* `LOCAL_MATCHED_REMOTE`
* `LOCAL_ONLY`
* `REMOTE_ONLY`
* `POS_ONLY`
* `PROVIDER_ONLY`
* `LOCAL_REMOTE_AMOUNT_MISMATCH`
* `LOCAL_POS_STATUS_MISMATCH`
* `LOCAL_PROVIDER_STATUS_MISMATCH`
* `PAYMENT_UNKNOWN_AFTER_RECOVERY`
* `CANCEL_UNKNOWN_AFTER_RECOVERY`
* `REFUND_UNKNOWN_AFTER_RECOVERY`
* `MANUAL_ACTION_REVIEW_REQUIRED`
* `CUSTOMER_NOTIFICATION_REVIEW_REQUIRED`
* `DISPUTE_CASE_REQUIRED`
* `LEGAL_HOLD_REQUIRED`

### 14.3 Reconciliation_Closure

A degraded-mode reconciliation case may be closed only when:

* all local ledger records are accounted for
* all replayable records are replayed or blocked with reason
* all unsafe records are marked for manual review
* all financial mismatches are classified
* all customer-facing statuses are corrected
* all required dispute cases are opened
* all provider evidence gaps are marked
* all POS evidence gaps are marked
* closure reason is recorded
* owner approval is recorded

## 15. Customer_Facing_Status_During_Degraded_Mode

Customer-facing status must remain conservative.

Allowed statuses include:

* order received
* payment confirmation pending
* store confirmation pending
* cancellation request received
* cancellation confirmation pending
* refund request received
* refund confirmation pending
* provider delayed
* store review required
* support review required
* duplicate payment review required
* order cannot be completed online

Forbidden statuses during unresolved degraded state include:

* payment completed
* order fully confirmed
* cancellation completed
* refund completed
* duplicate resolved
* settlement completed

unless supporting evidence exists.

## 16. Staff_Facing_Status_During_Degraded_Mode

Staff-facing status must distinguish operational facts from financial facts.

Staff views must show:

* customer says paid
* provider payment confirmed
* provider payment unknown
* POS accepted
* POS unknown
* internal order captured
* local ledger pending
* replay pending
* manual review required
* fulfillment hold recommended
* cancellation pending
* refund pending
* duplicate risk
* reconciliation required

Staff must not be asked to infer payment truth from order truth or POS truth.

## 17. Device_And_Channel_Requirements

### 17.1 Staff_Device

Staff device degraded-mode behavior must support:

* local note capture
* local action record
* masked customer reference
* order hold view
* replay pending marker
* manual recovery reason code
* device clock warning
* sync status indicator

### 17.2 Kiosk

Kiosk degraded-mode behavior must support:

* order intent preservation where safe
* payment blocked when provider route unavailable
* customer-safe message
* session recovery reference
* local ledger record where technically feasible
* staff handoff when online completion is unavailable

### 17.3 Mini_Kiosk

Mini-kiosk degraded-mode behavior must support:

* web session preservation
* customer-safe failure message
* payment state ambiguity handling
* wait-order session linkage
* recovery reference
* customer notification fallback where available

### 17.4 Table_Order_Channel

Table order degraded-mode behavior must support:

* table/session linkage preservation
* order hold state
* staff review marker
* local action record
* recovery after reconnect
* duplicate submission prevention

## 18. Security_And_Tamper_Protection

The local ledger must be protected against tampering.

Required controls include:

* append-only local sequence
* payload hash
* previous record hash
* local chain hash
* device identifier
* actor attribution
* local storage encryption where feasible
* replay signature where feasible
* server-side validation after sync
* tamper detection marker
* tamper incident creation

If tampering is suspected, the system must:

* block automatic replay
* create compliance case
* preserve local records
* require manual review
* mark customer-facing state conservatively
* prevent evidence deletion

## 19. Monitoring_And_Alerts

The POS Gateway must monitor:

* degraded-mode entry count
* degraded-mode duration
* local ledger backlog size
* local ledger write failure
* replay pending count
* replay conflict count
* replay failure count
* reconciliation pending count
* reconciliation aging
* payment unknown after recovery count
* cancellation unknown after recovery count
* refund unknown after recovery count
* duplicate replay prevention count
* local ledger tamper marker count
* device clock drift count
* customer notification pending count
* manual recovery count

Critical alerts must be raised when:

* local ledger write fails
* financial action is attempted without ledger write
* replay creates conflict
* duplicate payment risk is detected
* refund replay conflict occurs
* cancellation replay conflict occurs
* reconciliation aging exceeds threshold
* tamper marker is detected
* degraded mode exceeds configured duration

## 20. Readiness_Checklist

Before a route may support offline or degraded-mode operation, the following checklist must pass.

### 20.1 Local_Ledger

* [ ] Local ledger record model exists.
* [ ] Local ledger survives expected restart scenarios.
* [ ] Local ledger uses local sequence numbers.
* [ ] Local ledger records idempotency keys.
* [ ] Local ledger records correlation identifiers.
* [ ] Local ledger records actor attribution.
* [ ] Local ledger records payload hash.
* [ ] Local ledger blocks unsafe final state claims.

### 20.2 Replay

* [ ] Replay eligibility rules exist.
* [ ] Replay ordering is defined.
* [ ] Replay idempotency is enforced.
* [ ] Payment authorization replay is blocked by default.
* [ ] Cancellation replay is idempotent.
* [ ] Refund replay is idempotent.
* [ ] Replay conflict creates case.
* [ ] Replay result classes are recorded.

### 20.3 Reconciliation

* [ ] Degraded session creates reconciliation requirement.
* [ ] Local ledger is compared with cloud ledger.
* [ ] Local ledger is compared with POS records where available.
* [ ] Local ledger is compared with provider records where available.
* [ ] Mismatch classes are defined.
* [ ] Closure requires owner approval.
* [ ] Customer-facing state is corrected after reconciliation.
* [ ] Missing evidence is flagged.

### 20.4 Customer_And_Staff_Status

* [ ] Customer status remains conservative.
* [ ] Staff status separates operational and financial facts.
* [ ] Payment unknown is not shown as failed or completed.
* [ ] Refund pending is not shown as completed.
* [ ] Cancellation pending is not shown as completed.
* [ ] Duplicate risk is visible to staff.
* [ ] Manual recovery reason code is required.

### 20.5 Security

* [ ] Local ledger tamper detection exists.
* [ ] Local records cannot be silently deleted.
* [ ] Replay can be blocked by tamper marker.
* [ ] Developer access to local evidence is restricted.
* [ ] Sensitive fields are masked where required.
* [ ] Sync/export access is logged.

## 21. Non_Goals

This policy does not define:

* final offline payment authorization scheme
* card-present terminal offline approval certification
* provider-specific VAN/PG offline transaction rules
* complete kiosk offline UX
* complete mobile local database implementation
* final device encryption implementation
* legal treatment of all offline payments
* provider contract negotiation for offline mode

Those must be handled by provider-specific, security, legal, kiosk, and implementation documents.

This policy defines the POS Gateway minimum control boundary for degraded operation.

## 22. Acceptance_Criteria

This policy is accepted when:

* offline/degraded states are explicitly modeled
* local ledger exists for degraded operations
* local ledger records are durable within implementation constraints
* local ledger records are tamper-evident where feasible
* unsafe financial actions are blocked by default
* payment unknown does not become payment success
* cancellation pending does not become cancellation complete
* refund pending does not become refund complete
* replay eligibility is enforced
* replay is idempotent
* replay conflicts create cases
* degraded sessions require reconciliation
* customer-facing status remains conservative
* staff-facing status separates operational and financial truth
* local evidence cannot be cleared before reconciliation
* provider/POS evidence gaps remain visible

## 23. Final_Rule

Offline operation is not a shortcut around financial truth.

The POS Gateway may capture intent, preserve evidence, defer submission, replay safe actions, and reconcile after recovery.

It must not invent success.

If the system cannot prove payment, POS acceptance, cancellation, refund, or fulfillment state during degraded mode, it must preserve the ambiguity, protect the customer, block unsafe replay, and reconcile before closure.
