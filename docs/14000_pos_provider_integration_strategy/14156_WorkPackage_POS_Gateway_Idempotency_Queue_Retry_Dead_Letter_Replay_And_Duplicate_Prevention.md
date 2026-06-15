# 14156_WorkPackage_POS_Gateway_Idempotency_Queue_Retry_Dead_Letter_Replay_And_Duplicate_Prevention

## 1. Purpose

This document defines the implementation work package for POS Gateway idempotency, queue control, retry policy, dead-letter handling, replay safety, and duplicate prevention.

After the core registry, menu/price/availability validation, and transaction state machine exist, the gateway must safely execute external mutations against POS, payment, refund, cancellation, KDS, receipt, and provider systems.

The POS Gateway must assume that external calls can fail in dangerous ways:

- request timeout after provider mutation;
- network failure after POS order write;
- payment response lost after approval;
- duplicate retry due to client refresh;
- worker crash after sending request;
- webhook delay or duplication;
- provider returns ambiguous error;
- store tablet submits twice;
- customer taps payment twice;
- queue backlog replays old jobs;
- provider recovers and receives retry storm;
- dead-letter replay creates duplicate POS/payment/refund action.

This work package creates the safety spine that prevents repeated requests from becoming repeated real-world actions.

---

## 2. Scope

This work package covers implementation of:

- idempotency key model;
- idempotency request hash;
- idempotency result cache;
- duplicate request detection;
- duplicate POS order prevention;
- duplicate payment prevention;
- duplicate cancellation prevention;
- duplicate refund prevention;
- provider-scoped queue segmentation;
- worker execution locking;
- retry classification;
- exponential backoff;
- jitter;
- retry budget;
- circuit breaker integration point;
- rate limiter integration point;
- timeout-after-mutation handling;
- dead-letter transition;
- dead-letter review;
- safe replay;
- replay guard;
- manual recovery handoff;
- queue monitoring;
- audit events;
- test requirements.

This document does not implement provider-specific adapter request/response schemas.  
Provider adapter details are handled in `06350`.

---

## 3. Core Principle

A retry is not harmless.

Every retry against POS, payment, KDS, cancellation, refund, or receipt provider can create duplicate operational or financial side effects.

The gateway must enforce:

```text
idempotency before retry
state check before mutation
provider lookup before duplicate action
retry budget before retry storm
dead-letter before infinite retry
manual review before unsafe replay
```

If the system cannot prove that a retry is safe, it must stop automation and require review.

---

## 4. Implementation Position

This work package follows:

```text
14153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md
14154_WorkPackage_POS_Gateway_Menu_Mapping_Price_Availability_And_Calculation_Snapshot_Implementation.md
14155_WorkPackage_POS_Gateway_Order_Payment_Cancel_Refund_State_Machine_And_Transaction_Timeline_Implementation.md
```

This work package precedes:

```text
06350_WorkPackage_POS_Gateway_POS_KDS_Adapter_Interface_Routing_Error_Normalization_And_Provider_Contract_Implementation.md
14157_WorkPackage_POS_Gateway_Table_QR_NFC_Kiosk_Device_Receipt_Proof_And_Customer_Status_Implementation.md
14158_WorkPackage_POS_Gateway_Manual_Fallback_Manager_Approval_Staff_Action_And_Override_Implementation.md
14159_WorkPackage_POS_Gateway_Reconciliation_Audit_Evidence_Settlement_And_Accounting_Guard_Implementation.md
```

Provider adapter execution must not proceed without idempotency and retry safety.

---

## 5. Required Implementation Domains

The implementation must define these domains:

```text
idempotency_key
idempotency_request
idempotency_result
mutation_guard
duplicate_detection
queue_job
queue_segment
worker_execution_lock
retry_policy
retry_attempt
retry_budget
backoff_schedule
circuit_breaker_reference
rate_limit_reference
dead_letter_record
dead_letter_review
replay_request
replay_guard
manual_recovery_handoff
```

These domains may be separate tables or strongly separated logical models.

The key requirement is that every external mutation attempt is traceable and duplicate-safe.

---

## 6. Idempotency Key Model

Idempotency key must uniquely identify a mutation intent.

Required fields:

```text
idempotency_key_id
tenant_id
store_id
transaction_id
operation_type
idempotency_key
request_hash
request_source
created_by_actor_id
created_at_utc
expires_at_utc
status
```

Recommended operation types:

```text
create_pos_order
lookup_pos_order
initiate_payment
lookup_payment
cancel_payment
cancel_order
request_refund
lookup_refund
create_kds_ticket
lookup_receipt
send_notification
```

The same idempotency key must return the same result or a safe conflict response.

---

## 7. Request Hash Requirement

The gateway must store a normalized request hash.

Required fields:

```text
request_hash
normalized_payload_version
payload_hash_algorithm
created_at_utc
```

If the same idempotency key is reused with a different request hash, the gateway must reject it as an idempotency conflict.

This prevents accidental reuse of keys for different mutations.

---

## 8. Idempotency Result Model

The result of a completed idempotent operation must be stored.

Required fields:

```text
idempotency_result_id
idempotency_key_id
transaction_id
operation_type
result_status
result_state_domain
result_state
external_reference_id
response_summary_ref
completed_at_utc
status
```

Recommended result statuses:

```text
completed_success
completed_failure
pending
unknown
manual_review_required
reconciliation_required
conflict
expired
```

If the original operation is still pending or unknown, repeated calls must not create a new mutation.

---

## 9. Idempotency Conflict Rule

Idempotency conflict occurs when:

- same key with different payload;
- same mutation intent with different key but same transaction state;
- duplicate payment attempt while payment is pending or unknown;
- duplicate POS write while POS write is pending or unknown;
- duplicate refund request for same refund amount and reason;
- duplicate KDS ticket creation for same order and kitchen route.

Conflict must create:

```text
conflict_record
audit_event
safe_response
manual_review_marker_if_needed
```

Conflict must not execute external mutation.

---

## 10. Mutation Guard

Mutation guard validates whether an external mutation may proceed.

Input:

```text
transaction_id
operation_type
state_domain
current_state
idempotency_key
provider_id
route_eligibility
capability_status
limitation_status
```

Output:

```text
allowed
denial_reason
required_action
manual_review_required
reconciliation_required
```

Mutation guard must check transaction state before any provider call.

---

## 11. Duplicate POS Order Prevention

Before creating POS order, gateway must check:

- transaction has no confirmed POS order;
- POS write state is not pending or unknown without lookup;
- idempotency key not previously completed;
- external POS reference not already bound;
- same transaction not in dead-letter pending review;
- provider route still eligible;
- order state allows POS write.

If POS write result is unknown, the next action should usually be lookup or manual review, not another write.

---

## 12. Duplicate Payment Prevention

Before initiating payment, gateway must check:

- payment not already confirmed;
- payment not pending without safe status lookup;
- payment not unknown without manual/provider verification;
- duplicate risk not active;
- idempotency key not conflicting;
- amount matches calculation snapshot;
- payment route is eligible;
- customer is not being asked to pay again during unknown state.

Duplicate payment prevention is customer protection and financial control.

---

## 13. Duplicate Cancellation Prevention

Before cancellation mutation, gateway must check:

- cancellation not already confirmed;
- cancellation not pending or unknown without lookup;
- order/payment state allows cancellation;
- provider cancellation capability exists;
- idempotency key not conflicting;
- approval exists where required.

Cancellation request submission is not cancellation confirmation.

---

## 14. Duplicate Refund Prevention

Before refund mutation, gateway must check:

- refund not already confirmed for same scope;
- refund not pending or unknown without lookup;
- refundable amount remains;
- partial refund sequence is valid;
- provider refund capability exists;
- approval exists where required;
- idempotency key not conflicting.

Duplicate refund is a critical financial risk.

Refund unknown must route to verification or reconciliation before another refund request.

---

## 15. Queue Segment Model

Queue segmentation prevents unrelated work from blocking or amplifying each other.

Recommended queue segments:

```text
pos_order_write_queue
pos_order_lookup_queue
payment_mutation_queue
payment_lookup_queue
cancel_refund_queue
kds_ticket_queue
receipt_lookup_queue
notification_queue
provider_health_queue
master_data_sync_queue
settlement_import_queue
audit_archive_queue
privacy_redaction_queue
```

Transaction mutation queues must be separated from master data sync and batch jobs.

---

## 16. Queue Job Model

Queue job must contain enough metadata for safe execution.

Required fields:

```text
queue_job_id
tenant_id
store_id
transaction_id
provider_id
queue_segment
operation_type
idempotency_key_id
priority
scheduled_at_utc
available_after_utc
attempt_count
max_attempts
job_status
created_at_utc
updated_at_utc
```

Recommended job statuses:

```text
created
scheduled
leased
running
retry_scheduled
completed
failed
dead_lettered
cancelled
manual_review_required
```

Queue job must not carry raw secrets.

---

## 17. Worker Execution Lock

Worker must acquire execution lock before running mutation.

Required fields:

```text
worker_execution_lock_id
queue_job_id
worker_id
locked_at_utc
lock_expires_at_utc
heartbeat_at_utc
lock_status
```

If worker crashes, lock expiration must allow controlled recovery.

Lock expiration must not create duplicate provider mutation without idempotency check.

---

## 18. Retry Classification

Provider or system failure must be classified before retry.

Recommended retry classifications:

```text
retryable_transient
retryable_after_lookup
retryable_after_backoff
non_retryable_validation
non_retryable_capability
non_retryable_auth
unknown_after_mutation
manual_lookup_required
manual_review_required
dead_letter_required
```

Timeout after mutation should usually be `unknown_after_mutation`, not simple retry.

---

## 19. Retry Policy Model

Retry policy must be explicit per operation and provider.

Required fields:

```text
retry_policy_id
provider_id
operation_type
max_attempts
base_delay_ms
max_delay_ms
backoff_multiplier
jitter_strategy
retry_budget_id
timeout_ms
unknown_result_policy
dead_letter_threshold
status
```

Retry policy must be versioned.

Changing retry policy is a production behavior change.

---

## 20. Exponential Backoff Requirement

Retry delay must grow after each failed attempt.

Example logic:

```text
delay = min(max_delay_ms, base_delay_ms * backoff_multiplier ^ attempt_count)
```

Backoff must prevent immediate repeated hammering of a provider.

Fixed rapid retry is prohibited for external mutation calls.

---

## 21. Jitter Requirement

Jitter must randomize retry timing to prevent synchronized retry storms.

Recommended jitter strategies:

```text
none_for_local_only
full_jitter
equal_jitter
decorrelated_jitter
provider_defined
```

For provider calls at scale, `none` must not be used unless explicitly justified.

Jitter is mandatory for provider-facing retry at franchise scale.

---

## 22. Retry Budget

Retry budget limits total retry pressure.

Required fields:

```text
retry_budget_id
provider_id
operation_type
tenant_id
store_id
window_start_utc
window_end_utc
max_retry_count
used_retry_count
budget_status
```

If retry budget is exhausted:

- stop retry;
- open or evaluate circuit breaker;
- create alert;
- route to manual review or fallback mode.

Retry budget prevents endless retry storms.

---

## 23. Provider Rate Limit Integration

Queue execution must respect provider rate limits.

Rate limit dimensions:

```text
provider_id
operation_type
tenant_id
store_id
channel
payment_method
```

When provider rate limit is reached:

- delay job;
- reschedule with jitter;
- avoid retry storm;
- update provider health;
- alert if sustained.

Rate limiting must happen before provider call, not only after provider rejection.

---

## 24. Circuit Breaker Integration

Queue and retry must consult circuit breaker state.

Circuit breaker states:

```text
closed
open
half_open
forced_open
maintenance
degraded
```

Rules:

- `closed`: allow normal execution;
- `open`: block mutation, schedule fallback or review;
- `half_open`: allow limited probe only;
- `forced_open`: block until operator release;
- `maintenance`: block or defer based on maintenance policy;
- `degraded`: allow only approved operations.

Circuit breaker implementation may be shared with provider health services, but queue must obey it.

---

## 25. Timeout-After-Mutation Policy

Timeout after mutation is dangerous.

Examples:

- POS order write request timed out;
- payment authorize request timed out;
- refund request timed out;
- KDS ticket create timed out.

The next action must not automatically resend mutation unless provider supports idempotency and duplicate prevention is verified.

Preferred sequence:

```text
mark state unknown
perform provider lookup if supported
bind external reference if found
route manual review if lookup unavailable
create reconciliation marker if financial risk exists
```

---

## 26. Dead-Letter Transition

A job must move to dead-letter when safe retry is no longer possible.

Dead-letter triggers:

- max attempts exceeded;
- retry budget exhausted;
- circuit breaker open too long;
- unknown mutation cannot be resolved automatically;
- provider capability missing;
- provider auth failure;
- validation failure;
- idempotency conflict;
- repeated worker crash;
- provider response schema unsupported.

Dead-letter is not deletion.

It is a controlled stop point.

---

## 27. Dead-Letter Record

Dead-letter record must include:

```text
dead_letter_id
queue_job_id
transaction_id
tenant_id
store_id
provider_id
operation_type
last_error_code
last_error_summary
last_known_state
idempotency_key_id
created_at_utc
review_status
assigned_role
resolution_reference
```

Dead-letter must link to transaction timeline and manual review.

---

## 28. Dead-Letter Review

Dead-letter review must determine:

- retry safely;
- perform provider lookup;
- manual POS entry;
- manual payment verification;
- manual refund verification;
- cancel job;
- create reconciliation case;
- escalate provider incident;
- mark known provider limitation.

Review must be auditable.

No dead-letter job should be replayed blindly.

---

## 29. Replay Request Model

Replay request must be explicit.

Required fields:

```text
replay_request_id
dead_letter_id
queue_job_id
transaction_id
requested_by_actor_id
replay_reason
replay_scope
pre_replay_state
approved_by
created_at_utc
status
```

Replay requires approval for high-risk operations:

- POS write;
- payment;
- cancellation;
- refund;
- KDS ticket.

---

## 30. Replay Guard

Replay guard must validate:

- transaction state still allows replay;
- idempotency result not completed;
- external reference not already bound;
- provider capability still valid;
- circuit breaker allows probe or execution;
- approval exists where needed;
- retry budget available;
- request hash matches original or approved correction;
- customer impact understood.

Replay must not duplicate completed external mutation.

---

## 31. Manual Recovery Handoff

When automation stops, manual recovery handoff must be created.

Manual recovery handoff fields:

```text
manual_recovery_id
transaction_id
dead_letter_id
operation_type
reason_code
recommended_action
assigned_role
created_at_utc
resolved_at_utc
status
```

Manual recovery later connects to:

```text
14158_WorkPackage_POS_Gateway_Manual_Fallback_Manager_Approval_Staff_Action_And_Override_Implementation.md
```

---

## 32. Queue Priority Policy

Queue priority must protect transaction safety.

Recommended priority order:

1. payment status lookup for unknown payments;
2. refund/cancel status lookup;
3. POS order lookup after unknown write;
4. customer-safe notification for uncertainty;
5. normal POS writes;
6. KDS ticket creation;
7. receipt lookup;
8. master data sync;
9. settlement import;
10. analytics or batch jobs.

Priority must be configurable but audited.

---

## 33. Backpressure Policy

When queue backlog grows, the system must apply backpressure.

Backpressure actions:

```text
slow_new_order_intake
pause_low_priority_channels
force_staff_confirmation
disable_auto_retry
extend_retry_delay
open_provider_circuit
activate_waiting_room_mode
alert_operations
```

Backpressure must be visible in Admin/Store Console later.

The system must degrade before it collapses.

---

## 34. Queue Expiry Policy

Some jobs expire.

Examples:

- customer notification too late;
- menu sync superseded by newer version;
- payment status lookup after reconciliation closure;
- receipt lookup after archive path created.

Expiry must be explicit.

Expired jobs must not execute silently later.

---

## 35. Idempotency Expiry Policy

Idempotency keys may expire, but not before transaction risk is closed.

Idempotency expiry must consider:

- payment dispute window;
- refund/cancel retry window;
- provider duplicate risk window;
- transaction closure;
- reconciliation status;
- legal/audit requirement.

Expired idempotency keys must not delete audit history.

---

## 36. Audit Event Requirements

Required audit events:

```text
pos_gateway.idempotency.key_created
pos_gateway.idempotency.conflict_detected
pos_gateway.idempotency.result_recorded
pos_gateway.queue.job_created
pos_gateway.queue.job_leased
pos_gateway.queue.job_started
pos_gateway.queue.job_retry_scheduled
pos_gateway.queue.job_completed
pos_gateway.queue.job_failed
pos_gateway.queue.job_dead_lettered
pos_gateway.retry.backoff_calculated
pos_gateway.retry.budget_exhausted
pos_gateway.circuit.execution_blocked
pos_gateway.dead_letter.review_started
pos_gateway.dead_letter.replay_requested
pos_gateway.dead_letter.replay_approved
pos_gateway.dead_letter.replay_blocked
pos_gateway.dead_letter.replay_completed
pos_gateway.manual_recovery.created
```

Audit must include:

```text
tenant_id
store_id
transaction_id
provider_id
operation_type
idempotency_key_id
queue_job_id
created_at_utc
correlation_id
```

---

## 37. API Requirements

Recommended internal APIs or service methods:

```text
createIdempotencyKey()
validateIdempotencyKey()
recordIdempotencyResult()
detectMutationConflict()
createQueueJob()
leaseQueueJob()
heartbeatQueueJob()
completeQueueJob()
failQueueJob()
scheduleRetry()
calculateBackoffWithJitter()
consumeRetryBudget()
checkProviderRateLimit()
checkCircuitBreaker()
moveToDeadLetter()
startDeadLetterReview()
requestReplay()
validateReplayGuard()
executeReplay()
createManualRecoveryHandoff()
```

All mutation execution APIs must call idempotency and mutation guard before provider interaction.

---

## 38. Data Model Draft

Recommended table group:

```text
pos_gateway_idempotency_keys
pos_gateway_idempotency_results
pos_gateway_mutation_conflicts
pos_gateway_queue_segments
pos_gateway_queue_jobs
pos_gateway_worker_execution_locks
pos_gateway_retry_policies
pos_gateway_retry_attempts
pos_gateway_retry_budgets
pos_gateway_backoff_schedules
pos_gateway_provider_rate_limit_refs
pos_gateway_circuit_breaker_refs
pos_gateway_dead_letters
pos_gateway_dead_letter_reviews
pos_gateway_replay_requests
pos_gateway_replay_guard_results
pos_gateway_manual_recovery_handoffs
```

The implementation may use an external queue system, but the gateway must retain audit and control records.

---

## 39. Denial Reason Codes

Recommended denial reason codes:

```text
idempotency_conflict
request_hash_mismatch
operation_already_completed
operation_pending
operation_unknown_requires_lookup
duplicate_payment_risk
duplicate_refund_risk
duplicate_pos_order_risk
retry_budget_exhausted
provider_rate_limited
circuit_breaker_open
capability_not_supported
blocking_limitation
max_attempts_exceeded
dead_letter_review_required
replay_not_safe
manual_recovery_required
transaction_state_invalid
```

These reason codes must not be exposed directly to customers without message mapping.

---

## 40. Monitoring Requirements

Monitoring must detect:

- idempotency conflict rate;
- duplicate prevention blocks;
- queue backlog by segment;
- job age by segment;
- retry count by provider;
- retry budget exhaustion;
- circuit breaker block count;
- dead-letter count;
- dead-letter aging;
- replay request count;
- replay blocked count;
- worker crash count;
- lock expiration count;
- payment unknown lookup backlog;
- refund unknown lookup backlog;
- POS write unknown backlog.

Metrics must be scoped by tenant, store, provider, channel, and operation type.

---

## 41. Alert Requirements

Critical alerts:

```text
payment_unknown_backlog_high
refund_unknown_backlog_high
pos_write_unknown_backlog_high
retry_budget_exhausted
provider_retry_storm_detected
dead_letter_financial_operation_created
idempotency_conflict_spike
queue_backlog_peak_threshold
worker_lock_expiration_spike
circuit_breaker_open_for_payment_provider
```

Alerts must link to runbook and manual recovery path.

---

## 42. Test Requirements

Required tests:

```text
same_idempotency_key_same_payload_returns_same_result_test
same_idempotency_key_different_payload_conflict_test
duplicate_pos_order_prevention_test
duplicate_payment_prevention_test
duplicate_cancel_prevention_test
duplicate_refund_prevention_test
queue_job_lease_lock_test
worker_crash_lock_expiry_test
retry_classification_test
exponential_backoff_test
jitter_distribution_test
retry_budget_exhaustion_test
provider_rate_limit_block_test
circuit_breaker_block_test
timeout_after_mutation_marks_unknown_test
dead_letter_transition_test
dead_letter_replay_guard_test
unsafe_replay_block_test
manual_recovery_handoff_test
```

No provider adapter mutation should be enabled without these tests.

---

## 43. Acceptance Criteria

This work package is acceptable only when:

- idempotency key model exists;
- request hash requirement exists;
- idempotency result model exists;
- idempotency conflict rule exists;
- mutation guard exists;
- duplicate POS/payment/cancel/refund prevention exists;
- queue segment model exists;
- queue job model exists;
- worker execution lock exists;
- retry classification exists;
- retry policy exists;
- exponential backoff exists;
- jitter exists;
- retry budget exists;
- provider rate limit and circuit breaker integration exist;
- timeout-after-mutation policy exists;
- dead-letter transition exists;
- dead-letter record and review exist;
- replay request and replay guard exist;
- manual recovery handoff exists;
- queue priority, backpressure, expiry, and idempotency expiry policies exist;
- audit events, APIs, data model, denial codes, monitoring, alerts, and tests exist.

---

## 44. Relationship To Adjacent Documents

This document is related to:

- 06330 WorkPackage POS Gateway order, payment, cancel, refund state machine, and transaction timeline implementation;
- 06320 WorkPackage POS Gateway menu mapping, price, availability, and calculation snapshot implementation;
- 06310 WorkPackage POS Gateway core registry, tenant, store, provider capability, and environment binding implementation;
- 06305 Governance POS Gateway global scale final boss risk absorption architecture invariant implementation;
- 06300 Index POS Gateway implementation task breakdown, executable work package, and build sequence;
- 06170 Policy POS Gateway change management, release governance, configuration drift control, and production deployment;
- 06160 Policy POS Gateway disaster recovery, business continuity, provider outage, store offline mode, and service resumption;
- 06150 Policy POS Gateway performance, load, peak traffic, queue backpressure, and capacity planning;
- 06120 Policy POS Gateway reconciliation case workflow, variance resolution, manual adjustment, and audit closure.

Where conflict exists, this document governs implementation of idempotency, queue, retry, dead-letter, replay, and duplicate prevention behavior for POS Gateway execution.

---

## 45. Summary

The POS Gateway must assume that every external mutation can fail halfway.

A timeout does not mean nothing happened.  
A retry does not mean safe repetition.  
A dead-letter is not garbage.  
A replay is not harmless.

The correct implementation standard is:

- idempotency before retry;
- request hash before duplicate detection;
- state guard before mutation;
- lookup before repeating unknown mutation;
- exponential backoff and jitter before provider retry;
- retry budget before traffic storm;
- dead-letter before infinite loop;
- replay guard before recovery;
- manual review before unsafe automation.

This work package prevents the gateway from turning provider uncertainty into duplicate orders, duplicate payments, duplicate refunds, and national-scale retry storms.