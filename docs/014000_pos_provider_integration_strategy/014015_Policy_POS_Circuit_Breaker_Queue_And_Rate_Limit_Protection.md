# 014015_Policy_POS_Circuit_Breaker_Queue_And_Rate_Limit_Protection

## 1. Purpose

This policy defines how the POS Gateway must protect the platform from POS provider timeout, rate limit, latency spike, partial outage, retry storm, and provider-side instability.

The purpose is to prevent external POS provider failure from causing platform-wide order failure, duplicate submission, payment inconsistency, lost order, or uncontrolled retry behavior.

The POS Gateway must isolate unstable provider behavior through circuit breaker, queueing, throttling, retry, replay validation, customer-facing pending state, operator visibility, and immutable audit evidence.

## 2. Scope

This policy applies to:

* POS provider API timeout
* POS provider rate limit
* POS provider 429 response
* POS provider 5xx response
* Provider latency spike
* Provider partial outage
* Local agent timeout
* Local queue growth
* Gateway retry control
* Provider-specific throttling
* Circuit breaker state
* Queue preservation
* Queue replay
* Retry backoff
* Customer pending state
* Operator recovery state
* Audit evidence for all queue and circuit transitions

This policy applies to all POS provider integration modes where orders, payments, validations, cancellations, refunds, prints, or status queries may depend on external provider response.

## 3. Core Principle

The platform must not die with the POS provider.

When a POS provider becomes slow, unavailable, rate-limited, or unstable, the POS Gateway must isolate that failure and protect the core system.

The Gateway must never allow uncontrolled retries, duplicate orders, duplicate payments, queue corruption, or silent order loss.

Provider instability must become a controlled Gateway state, not a platform collapse.

## 4. Resilience Boundary

The circuit breaker and queue layer sits between the Gateway orchestration layer and provider adapters.

```
[Core Order / Payment / Audit Domain]
                 |
                 v
    [POS Gateway Orchestration Layer]
                 |
                 v
    [Circuit Breaker And Queue Layer]
                 |
      ---------------------------
      |                         |
      v                         v
[Provider Adapter]        [Local Agent Path]
      |                         |
      v                         v
[External POS API]        [Store Local System]
```

The core must receive normalized, controlled states instead of raw provider instability.

## 5. Non-Negotiable Rules

### 5.1 Provider Failure Isolation Rule

Provider failure must be isolated inside the Gateway.

A provider timeout, rate limit, or outage must not cause uncontrolled failure in core order, payment, settlement, or audit domains.

### 5.2 No Blind Retry Rule

The Gateway must not retry provider requests blindly.

Retry must be based on:

* Operation type
* Idempotency support
* Current order state
* Current payment state
* Provider error type
* Retry eligibility
* Circuit breaker state
* Queue freshness
* Duplicate risk

### 5.3 Queue Must Be Auditable Rule

Any queued order, validation, cancellation, print, refund, or status query must be traceable.

The system must know:

* Why it was queued
* When it was queued
* What state it had at queue time
* Whether it is still valid
* When it was replayed
* What result occurred
* Whether manual intervention was required

### 5.4 Circuit State Must Be Visible Rule

Circuit breaker state must be visible to Gateway logic, operators, readiness checks, and audit logs.

The system must not hide an open provider circuit behind generic error messages.

### 5.5 Payment Risk Priority Rule

Payment-related operations must be treated with higher risk than read-only or validation operations.

The Gateway must not queue or replay payment-sensitive operations unless idempotency, state, and provider behavior are safe.

## 6. Circuit Breaker States

The Gateway must support circuit breaker states.

### 6.1 Closed

Provider is considered healthy.

Requests may flow normally, subject to rate limit and timeout policies.

### 6.2 Open

Provider is considered unhealthy.

Direct requests are temporarily blocked or limited.

New requests may be:

* Rejected
* Queued
* Moved to pending
* Routed to manual-assisted flow
* Blocked before payment
* Held for operator review

### 6.3 Half-Open

Provider is being tested for recovery.

Only limited probe requests are allowed.

If probes succeed, the circuit may close.

If probes fail, the circuit returns to open.

### 6.4 Forced-Open

Operator or automated safety rule has forced the provider path open.

This state may be used during known provider incident, maintenance, repeated duplicate risk, or unsafe behavior.

### 6.5 Disabled

Provider integration path is disabled.

No production order flow may use this provider path until re-enabled through controlled process.

## 7. Circuit Open Triggers

A circuit may open when one or more conditions occur.

Examples:

* Consecutive timeout threshold exceeded
* Consecutive 5xx threshold exceeded
* 429 rate limit threshold exceeded
* Average latency exceeds configured limit
* P95 latency exceeds configured limit
* Provider returns malformed response
* Provider schema drift detected
* Provider duplicate risk detected
* Provider accepts requests but does not return stable status
* Local agent heartbeat missing
* Local queue depth exceeds safe threshold
* Provider maintenance detected
* Operator forces provider degraded state

Thresholds must be provider-specific and documented.

## 8. Circuit Close Conditions

A circuit may close only after recovery evidence.

Recovery evidence may include:

* Successful health check
* Successful validation probe
* Successful status query
* Successful low-risk test request
* Provider incident resolved
* Local agent heartbeat restored
* Queue depth reduced
* Operator confirmation
* Automated stability window completed

A circuit must not close immediately after one lucky response if the provider remains unstable.

## 9. Operation Risk Classification

Every provider operation must have a risk classification.

### 9.1 Read-Only Low Risk

Examples:

* Health check
* Menu query
* Status query
* Capability check

These may be retried more safely.

### 9.2 Validation Medium Risk

Examples:

* Price validation
* Sold-out validation
* Table validation
* Store acceptance validation

These may affect payment approval and must have strict timeout handling.

### 9.3 Order Submission High Risk

Examples:

* Submit order
* Cancel order
* Modify order
* Confirm fulfillment

These require idempotency and duplicate prevention.

### 9.4 Payment Critical Risk

Examples:

* Payment approval
* Payment void
* Refund
* Partial refund
* Split payment update

These must not be blindly queued or replayed.

### 9.5 Print Operational Risk

Examples:

* Kitchen print
* Reprint
* Cancel ticket
* Remake ticket

These require duplicate print protection.

## 10. Queue Types

The Gateway may use separate queues by operation class.

### 10.1 Validation Queue

Used for delayed validation when provider is temporarily unavailable.

Validation queue must not approve payment without valid decision.

### 10.2 Order Submission Queue

Used for order submission when provider is temporarily unavailable and the business flow allows pending state.

This queue must preserve order state and idempotency key.

### 10.3 Cancellation Queue

Used for cancellation or void-related provider synchronization.

This queue must consider whether fulfillment has started.

### 10.4 Refund Queue

Used only when refund replay is safe and payment provider semantics are clear.

Refund queue requires stronger audit and reconciliation evidence.

### 10.5 Print Queue

Used for direct print or local agent print jobs.

Print queue must prevent duplicate tickets.

### 10.6 Status Query Queue

Used for delayed provider status checks.

This queue may help reconcile uncertain states.

## 11. Queue Record Requirements

Each queued job must include:

```
queue_job_id
operation_type
operation_risk_class
platform_order_id
payment_id
kitchen_ticket_id
store_id
provider_id
adapter_version
original_request_reference
normalized_payload_reference
idempotency_key
enqueue_reason
enqueue_state_snapshot
validation_snapshot
payment_state_snapshot
order_state_snapshot
retry_count
max_retry_count
next_retry_at
expires_at
queue_status
last_error_category
last_provider_response_reference
operator_required_flag
created_at
updated_at
```

A queued job without state snapshot and idempotency evidence is unsafe.

## 12. Queue Status Classification

Allowed queue states include:

```
QUEUED
WAITING_FOR_CIRCUIT
WAITING_FOR_RETRY
WAITING_FOR_OPERATOR
REPLAYING
REPLAY_SUCCEEDED
REPLAY_FAILED
EXPIRED
CANCELLED
SUPERSEDED
BLOCKED_DUPLICATE_RISK
BLOCKED_PAYMENT_RISK
MANUAL_RECOVERY_REQUIRED
```

Queue state must be visible in audit and operator console.

## 13. Retry Eligibility

Retry eligibility must be determined before queueing or replay.

Retry may be allowed for:

* Provider timeout before confirmed processing
* Provider 429 with retry-after policy
* Temporary 5xx
* Provider maintenance
* Local agent temporary offline
* Network transient failure
* Read-only query failure

Retry may be blocked for:

* Non-idempotent operation without idempotency key
* Payment operation without safe provider semantics
* Validation result that is stale
* Order already canceled
* Payment already refunded
* Manual POS reentry suspected
* Provider returned business rejection
* Schema drift detected
* Duplicate order risk

## 14. Retry Backoff Policy

Retry must use controlled backoff.

The policy may include:

* Initial retry delay
* Exponential backoff
* Jitter
* Retry-after header respect
* Maximum retry count
* Maximum retry age
* Circuit-aware retry gating
* Queue depth throttling
* Provider-specific rate limit profile

The Gateway must prevent retry storms.

When many orders fail at once, retry must be spread and throttled.

## 15. Rate Limit Protection

The Gateway must track provider rate limit behavior.

Rate limit protection should consider:

* Provider documented limit
* Store-specific limit
* Tenant-level limit
* Endpoint-level limit
* Burst limit
* Sustained limit
* Retry-after header
* Observed 429 response rate
* Lunch or dinner peak profile

The Gateway must not continue sending traffic aggressively after provider rate limit is detected.

## 16. Throttling

The Gateway may throttle outbound provider requests.

Throttling may apply by:

* Provider
* Store
* Tenant
* Endpoint
* Operation type
* Risk class
* Circuit state
* Queue depth
* Peak-time profile

Throttling decisions must be auditable when they affect order flow.

## 17. Customer Pending State

When order flow is delayed due to provider instability, the customer must see a controlled state.

Allowed customer-facing states may include:

```
Order is being confirmed by the store.
The store is taking longer than usual to confirm this order.
Your payment has not been completed yet.
Your order is pending store confirmation.
This store is temporarily unable to accept online orders.
```

The system must not mislead the customer into believing the order is confirmed if provider acceptance is not confirmed.

## 18. Payment And Queue Interaction

Payment-sensitive queueing requires strict rules.

### 18.1 Before Payment Approval

If provider validation is required but unavailable, the Gateway may:

* Block payment
* Hold for recheck
* Ask customer to retry
* Queue validation only
* Move to manual confirmation before payment

The Gateway must not approve payment based on unknown provider state unless a separately approved business policy allows it.

### 18.2 After Payment Approval

If payment was approved but POS submission is delayed or failed, the Gateway must:

* Mark order as payment-approved but POS-unaccepted
* Prevent false fulfillment success
* Queue submission only if idempotency is safe
* Void or refund if provider acceptance cannot be achieved
* Notify operator
* Notify customer according to policy
* Preserve audit evidence

### 18.3 Refund And Void Queue

Refund and void operations must have payment-specific safeguards.

The system must avoid duplicate refunds, missed refunds, and refund replay after manual completion.

## 19. Queue Replay Validation

Before replaying a queued job, the Gateway must re-check:

* Current order state
* Current payment state
* Current provider circuit state
* Current menu and sold-out validity, if relevant
* Current table state, if relevant
* Whether manual recovery already occurred
* Whether customer was notified of cancellation
* Whether refund or void already occurred
* Whether idempotency key is still valid
* Whether queue job expired

Replay must not proceed when the job is stale or superseded.

## 20. Duplicate Risk During Replay

Replay can create duplicate orders if the provider processed the original request but failed to respond.

The Gateway must handle ambiguous outcomes.

Ambiguous outcome examples:

* Timeout after provider received request
* Connection dropped after submission
* Provider ACK lost
* Local agent sent request but crashed before reporting
* Provider status query unavailable

In ambiguous states, the Gateway should attempt status reconciliation before replay.

If reconciliation is impossible, operator confirmation may be required.

## 21. Circuit And Queue Audit Requirements

Every circuit and queue transition must preserve:

* Provider ID
* Store ID
* Operation type
* Risk class
* Circuit state before
* Circuit state after
* Trigger reason
* Queue job ID, if applicable
* Related order ID
* Related payment ID, if applicable
* Related print ticket ID, if applicable
* Error category
* Provider response reference
* Retry count
* Next retry time
* Decision outcome
* Operator action, if any
* Trace ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive provider or payment data must be redacted, tokenized, or encrypted according to the security runtime policy.

## 22. Operator Console Requirements

The operator console must show:

* Provider health
* Circuit state
* Circuit open reason
* Affected stores
* Affected orders
* Queue depth
* Oldest queued job age
* Retry count distribution
* Payment-risk jobs
* Duplicate-risk jobs
* Manual recovery required jobs
* Current throttling status
* Last successful provider call
* Last provider error category

Allowed operator actions may include:

```
FORCE_OPEN_CIRCUIT
FORCE_HALF_OPEN_CIRCUIT
CLOSE_CIRCUIT_AFTER_CHECK
PAUSE_QUEUE
RESUME_QUEUE
CANCEL_QUEUE_JOB
MARK_MANUAL_RECOVERY
RETRY_SELECTED_JOB
BLOCK_PROVIDER_FOR_STORE
ESCALATE_PROVIDER_INCIDENT
```

All operator actions must be audited.

## 23. Provider Incident Classification

Provider instability must be classified.

Allowed incident categories include:

```
PROVIDER_RATE_LIMIT
PROVIDER_TIMEOUT
PROVIDER_LATENCY_SPIKE
PROVIDER_5XX_OUTAGE
PROVIDER_PARTIAL_OUTAGE
PROVIDER_SCHEMA_DRIFT
PROVIDER_DUPLICATE_RISK
PROVIDER_MAINTENANCE
PROVIDER_STATUS_UNKNOWN
LOCAL_AGENT_BRIDGE_FAILURE
NETWORK_PATH_FAILURE
UNKNOWN_PROVIDER_INCIDENT
```

Incident classification supports later SLA, provider review, and readiness decisions.

## 24. Metrics And Monitoring

The Gateway should track:

* Provider success rate
* Provider timeout rate
* Provider 429 rate
* Provider 5xx rate
* Average latency
* P95 latency
* P99 latency
* Circuit open count
* Circuit open duration
* Queue depth
* Queue age
* Replay success rate
* Replay failure rate
* Duplicate-risk count
* Manual recovery count
* Payment-risk queue count

Metrics must not replace audit evidence, but they help detect operational degradation.

## 25. Store And Provider Readiness Requirements

A provider path cannot be considered production-ready unless it has defined:

* Timeout threshold
* Rate limit behavior
* Circuit breaker threshold
* Retry policy
* Queue eligibility policy
* Idempotency support
* Queue replay validation
* Operator recovery path
* Customer pending state
* Payment-risk handling
* Audit evidence sample
* Load or peak simulation evidence

A provider without rate limit and outage behavior evidence must be treated as readiness-incomplete.

## 26. Test Requirements

Each provider integration must test:

* Normal success
* Provider timeout
* Provider latency spike
* Provider 429 rate limit
* Provider 5xx
* Circuit opens
* Circuit half-open recovery
* Circuit closes after stability
* Queue enqueue
* Queue replay success
* Queue replay failure
* Queue expiration
* Retry backoff
* Retry storm prevention
* Ambiguous timeout outcome
* Duplicate-risk replay blocked
* Payment approved but POS submission delayed
* Payment blocked before provider validation
* Operator force-open circuit
* Audit preservation for all circuit and queue states

A provider cannot be production-ready without circuit breaker and queue test evidence.

## 27. Anti-Patterns

The following are prohibited:

* Sending unlimited retries to an unstable provider
* Treating all timeouts as safe to retry
* Replaying queued payment operations without idempotency
* Hiding circuit open state from operators
* Showing customer confirmed order when provider acceptance is unknown
* Letting queue jobs live forever without expiration
* Replaying stale orders after cancellation or refund
* Closing circuit after one lucky response
* Mixing payment-risk jobs and read-only jobs without risk classification
* Treating provider rate limit as a customer error
* Allowing retry storms during lunch peak

## 28. Relationship With Other Documents

This policy depends on and supports:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Circuit breaker and queue policy is the platform’s survival boundary during POS provider instability.

## 29. Final Rule

The POS Gateway must be able to preserve, classify, delay, retry, reject, or recover provider-dependent operations without losing orders, duplicating payments, or corrupting audit state.

If a POS provider outage causes the platform to lose track of what happened, retry uncontrollably, or falsely confirm orders, the resilience boundary has failed.
