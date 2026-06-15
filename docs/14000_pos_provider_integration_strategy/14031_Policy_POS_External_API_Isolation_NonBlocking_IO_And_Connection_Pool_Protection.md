# 14031_Policy_POS_External_API_Isolation_NonBlocking_IO_And_Connection_Pool_Protection

## 1. Purpose

This policy defines how the POS Gateway must isolate external POS provider API latency, outage, blocking calls, connection pool exhaustion, worker starvation, and cascading failure from the core platform.

The purpose is to prevent external provider bottlenecks from causing platform-wide failure.

When thousands of stores generate peak-time order, payment, validation, cancellation, refund, and status requests, the Gateway must protect itself even if a POS provider becomes slow, unstable, or unresponsive.

The Gateway must treat external API calls as failure-prone, latency-prone, and resource-consuming operations that require isolation, non-blocking execution, bounded concurrency, timeout control, backpressure, queue handoff, and audit visibility.

## 2. Scope

This policy applies to:

* External POS API calls
* Provider validation calls
* Provider order submission
* Provider cancellation
* Provider refund or void sync
* Provider status query
* Provider menu sync
* Provider sold-out sync
* Provider table sync
* Provider business day sync
* Local agent bridge calls
* Non-blocking I/O
* Connection pool protection
* Worker pool isolation
* Provider-specific concurrency limits
* Bulkhead isolation
* Backpressure
* Async job handoff
* Request cancellation
* Provider latency spike
* Provider bottleneck
* Cascading failure prevention
* Audit evidence for external call isolation

This policy applies to all POS-connected production flows where the platform depends on external provider response or local bridge response.

## 3. Core Principle

An external POS provider must never be allowed to exhaust shared Gateway resources.

The Gateway must not let one slow provider, one degraded endpoint, one weak store device, or one overloaded local bridge consume the threads, sockets, connection pools, queues, or memory required by the rest of the platform.

External dependency failure must be isolated before it becomes internal platform failure.

## 4. Failure Isolation Boundary

The Gateway must isolate external calls behind a controlled resource boundary.

```
[Core Request Intake]
          |
          v
[Gateway Orchestration Layer]
          |
          v
[External Call Isolation Layer]
          |
  -------------------------------
  |              |              |
  v              v              v
[Provider A]  [Provider B]  [Local Agent Path]
```

The isolation layer must enforce:

* Timeout
* Concurrency limit
* Connection pool limit
* Queue handoff
* Circuit breaker
* Backpressure
* Retry eligibility
* Resource budget
* Provider-specific degradation

The core request intake must not directly wait on unbounded external calls.

## 5. Non-Negotiable Rules

### 5.1 No Unbounded Blocking Rule

The Gateway must not hold request threads, event-loop capacity, worker pools, or database transactions open while waiting indefinitely for external POS providers.

Every external operation must have bounded timeout, cancellation behavior, and resource budget.

### 5.2 Provider Bulkhead Rule

Each provider and high-risk endpoint must be isolated by bulkhead.

A failure in one provider must not exhaust resources for another provider.

A failure in one store’s local path must not exhaust resources for all stores.

### 5.3 Connection Pool Protection Rule

Connection pools must be bounded, monitored, and provider-scoped where appropriate.

The Gateway must not allow a slow provider to occupy all shared outbound connections.

### 5.4 Non-Blocking Preferred Rule

High-volume provider communication should use non-blocking I/O, async worker handoff, event-driven status update, or queue-based execution where possible.

Synchronous blocking calls are allowed only when bounded and low-risk.

### 5.5 Backpressure Required Rule

When provider latency or queue pressure rises, the Gateway must apply backpressure instead of accepting unlimited work.

Backpressure may block, defer, queue, throttle, degrade, or reject new work depending on operation risk.

### 5.6 Payment-Sensitive Isolation Rule

Payment-sensitive operations must not be mixed with low-risk sync operations in the same uncontrolled resource pool.

Payment, refund, void, and order submission paths require stricter isolation.

## 6. External Call Risk Classes

Every external call must be classified by risk.

### 6.1 Low-Risk Read

Examples:

* Provider health check
* Capability query
* Non-critical menu sync
* Status query without state mutation

These may use more flexible retry and timeout policy.

### 6.2 Medium-Risk Validation

Examples:

* Price validation
* Sold-out validation
* Table validation
* Store acceptance validation

These affect payment and order decisions.

They must have bounded latency and clear fallback.

### 6.3 High-Risk Order Mutation

Examples:

* Submit order
* Cancel order
* Modify order
* Confirm POS acceptance

These must be idempotent and isolated.

### 6.4 Critical Financial Mutation

Examples:

* Payment sync
* Void sync
* Refund sync
* Settlement update
* Receipt linkage

These require strict idempotency, audit, and reconciliation.

### 6.5 Operational Print Or Local Mutation

Examples:

* Kitchen print
* Reprint
* Local agent job
* Printer status update

These require duplicate prevention and local resource isolation.

## 7. Resource Isolation Types

The Gateway may use multiple isolation techniques.

### 7.1 Provider-Level Bulkhead

Limits resources per provider.

Example:

```
Provider A cannot consume Provider B’s connection pool.
```

### 7.2 Store-Level Bulkhead

Limits resources per store.

Example:

```
One store with a frozen POS PC cannot consume shared local agent workers.
```

### 7.3 Endpoint-Level Bulkhead

Limits resources per endpoint.

Example:

```
Slow menu sync cannot block order submission.
```

### 7.4 Operation-Risk Bulkhead

Limits resources by operation risk.

Example:

```
Refund sync and health checks must not share the same unconstrained worker pool.
```

### 7.5 Tenant-Level Bulkhead

Limits resource usage per tenant or franchise.

Example:

```
One large tenant’s peak traffic cannot starve smaller tenants.
```

## 8. Connection Pool Requirements

Connection pool configuration must support:

```
provider_id
endpoint_group
max_connections
max_idle_connections
connection_timeout_ms
read_timeout_ms
write_timeout_ms
idle_timeout_ms
max_pending_acquire
pending_acquire_timeout_ms
circuit_breaker_binding
metrics_enabled
last_calibrated_at
```

Connection pool limits must be reviewed under load testing.

Default shared connection pools are prohibited for production-critical provider integration unless safely partitioned.

## 9. Worker Pool Requirements

Blocking or CPU-heavy work must not run on shared event-loop threads.

Worker pool configuration should include:

```
worker_pool_id
provider_id
operation_risk_class
max_workers
queue_capacity
task_timeout_ms
cancellation_policy
overload_policy
priority_policy
circuit_binding
monitoring_enabled
```

A slow provider must not starve core request processing.

## 10. Non-Blocking I/O Policy

Where high concurrency is expected, external provider calls should use non-blocking I/O or async execution.

Non-blocking I/O must still enforce:

* Timeout
* Cancellation
* Circuit breaker
* Backpressure
* Response size limit
* Schema validation
* Audit event emission
* Idempotency
* Retry eligibility

Non-blocking does not mean uncontrolled.

## 11. Async Handoff Policy

High-risk or slow provider operations may be handed off to asynchronous queues.

Async handoff must preserve:

* Operation identity
* Order state snapshot
* Payment state snapshot
* Idempotency key
* Trace ID
* Correlation ID
* Queue job ID
* Retry policy
* Expiration
* Customer-facing pending state
* Operator-visible status

Async handoff must not create hidden order loss.

## 12. Backpressure Policy

When Gateway or provider capacity is under pressure, the system must apply backpressure.

Backpressure signals may include:

* Provider latency above threshold
* Connection pool saturation
* Worker pool saturation
* Queue depth above threshold
* Pending acquire timeout
* Circuit breaker open
* Database write pressure
* Local agent backlog
* Payment-risk backlog
* Memory pressure

Possible backpressure outcomes include:

```
ACCEPT
ACCEPT_ASYNC
ACCEPT_WITH_PENDING_STATE
THROTTLE
QUEUE
BLOCK_PAYMENT
BLOCK_ORDER
REJECT_TEMPORARILY
REQUIRE_OPERATOR_CONFIRMATION
OPEN_CIRCUIT
DISABLE_LOW_PRIORITY_SYNC
```

Backpressure decisions must be auditable when they affect customer or order state.

## 13. Queue Admission Control

The Gateway must not treat queues as infinite buffers.

Queue admission must consider:

* Queue capacity
* Oldest job age
* Operation risk
* Payment state
* Stock validity
* Business day state
* Provider circuit state
* Customer experience
* Replay eligibility
* Expiration
* Duplicate risk

If queue admission is unsafe, the system must reject, block, or require manual handling.

## 14. Timeout Budgeting

Each request path must have an overall timeout budget.

Example:

```
Customer-facing confirmation budget
Gateway orchestration budget
Provider validation budget
Payment approval budget
POS submission budget
Queue handoff budget
Response rendering budget
```

The Gateway must not allow nested external calls to exceed the customer or operation budget uncontrollably.

## 15. Request Cancellation

When a request times out, is superseded, or is canceled, the Gateway must cancel or detach external work safely where possible.

Cancellation must consider:

* Provider may still process request
* Provider may not support cancellation
* Provider may return later
* Queue job may already be leased
* Payment may already be approved
* POS may already have accepted order
* Kitchen print may already have been dispatched

Cancellation must create audit evidence and may require status reconciliation.

## 16. Slow Provider Handling

When provider latency increases, the Gateway may:

* Reduce concurrency
* Increase circuit sensitivity
* Shift to async handoff
* Disable low-priority sync
* Block payment-sensitive flows
* Increase customer pending state visibility
* Open provider circuit
* Raise operator alert
* Activate provider incident mode

Slow provider handling must prevent resource starvation.

## 17. Provider Bottleneck Incident

A provider bottleneck incident may be declared when:

* Latency exceeds threshold
* Timeout rate exceeds threshold
* Connection pool saturation occurs
* Queue backlog grows
* Provider 429 increases
* Provider status checks degrade
* Multiple stores affected
* Payment-sensitive operations delayed

Incident state must be linked to circuit breaker, queue, operator console, and audit.

## 18. Cost And Capacity Awareness

External isolation also protects infrastructure cost.

Unbounded polling, retries, pending connections, and queue growth can create cost explosion.

The Gateway must monitor:

* Outbound call count
* Idle polling call count
* Retry call count
* Connection utilization
* Queue storage growth
* Worker utilization
* Egress cost, where relevant
* Provider error cost amplification
* Per-store traffic profile
* Per-provider traffic profile

Cost metrics must inform throttling and channel design.

## 19. Multi-Provider Fairness

When multiple providers are integrated, the Gateway must avoid unfair resource consumption.

Fairness controls may include:

* Per-provider quotas
* Per-store quotas
* Per-tenant quotas
* Endpoint quotas
* Priority scheduling
* Payment-risk prioritization
* Bulkhead isolation
* Queue partitioning

Provider A’s outage must not degrade Provider B’s healthy stores.

## 20. Database Protection

External call failures must not hold database transactions open.

The Gateway must avoid:

* Starting transaction before slow external call
* Holding row locks during provider wait
* Holding inventory locks longer than policy
* Holding payment state lock while provider is unresponsive
* Blocking audit writes behind provider response

State transitions should use short transactions and durable event records.

## 21. Audit Requirements

Every external API isolation decision must preserve:

* Provider ID
* Store ID
* Endpoint
* Operation type
* Operation risk class
* Request mode
* Blocking or async mode
* Timeout budget
* Actual latency
* Connection pool ID
* Connection pool saturation state
* Worker pool ID
* Worker pool saturation state
* Queue job ID, if applicable
* Circuit state
* Backpressure decision
* Retry eligibility
* Error category
* Related order ID, if applicable
* Related payment ID, if applicable
* Related print ticket ID, if applicable
* Trace ID
* Correlation ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive provider, payment, and infrastructure data must be protected according to the security runtime policy.

## 22. Operator Console Requirements

The operator console must show:

* Provider latency
* Provider timeout rate
* Provider 429 rate
* Provider circuit state
* Connection pool usage
* Worker pool saturation
* Queue depth
* Oldest queue age
* Backpressure state
* Payment-risk backlog
* Affected stores
* Affected providers
* Incident classification
* Current mitigation mode

Allowed operator actions may include:

```
OPEN_PROVIDER_CIRCUIT
FORCE_ASYNC_HANDOFF
PAUSE_LOW_PRIORITY_SYNC
REDUCE_PROVIDER_CONCURRENCY
RESUME_PROVIDER_CONCURRENCY
DRAIN_QUEUE_WITH_LIMIT
BLOCK_PROVIDER_FOR_STORE
ESCALATE_PROVIDER_BOTTLENECK
MARK_INCIDENT_RESOLVED
```

All operator actions must be audited.

## 23. Customer-Facing Messaging

Customer-facing messages must remain simple.

Examples:

```
The store is taking longer than usual to confirm this order.
Your order is being confirmed.
This store is temporarily unable to accept online orders.
No payment was completed.
The store could not confirm this order.
```

Customer-facing messages must not expose connection pool saturation, worker exhaustion, provider bottleneck internals, circuit states, queue internals, or infrastructure cost issues.

## 24. Test Requirements

Each production provider integration must test:

* Normal external API latency
* Slow provider latency
* Provider timeout
* Provider connection pool saturation
* Worker pool saturation
* Endpoint-specific bulkhead
* Provider-specific bulkhead
* Store-specific bulkhead
* Async handoff under load
* Backpressure under load
* Queue admission control
* Queue rejection
* Provider bottleneck incident
* Circuit open from latency
* Circuit open from pool saturation
* Payment-sensitive flow under slow provider
* Low-priority sync disabled during pressure
* Provider A outage does not affect Provider B
* Database transaction not held during provider wait
* Audit preservation for all isolation states

A provider cannot be production-ready without external API isolation and resource protection test evidence.

## 25. Anti-Patterns

The following are prohibited:

* Blocking shared request threads indefinitely on provider API calls
* Using one shared connection pool for all providers without protection
* Letting one provider outage consume all Gateway workers
* Holding database transactions open while waiting for provider response
* Treating queues as infinite buffers
* Retrying provider calls aggressively during latency spike
* Allowing low-priority sync to block payment-sensitive operations
* Hiding connection pool saturation from operators
* Returning confirmed order state while provider acceptance is still unknown
* Allowing one store’s frozen local path to exhaust shared resources
* Treating non-blocking I/O as permission for unlimited outbound calls

## 26. Relationship With Other Documents

This policy depends on and supports:

```
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
05420 POS Legacy Hardware OS Adaptive Timeout And App Restart Policy
05460 POS Polling WebSocket MQTT And Agent Realtime Channel Cost Control Policy
05470 POS InDoubt Transaction Network Cancel Receipt Number And Financial Reconciliation Policy
```

External API isolation is the infrastructure survival boundary of the POS Gateway.

## 27. Final Rule

The POS Gateway must always be able to survive a slow, broken, or overloaded external POS provider without exhausting its own shared resources.

If one external provider bottleneck can consume the Gateway’s connection pools, workers, event-loop capacity, queues, database locks, or payment-sensitive processing capacity, the external API isolation boundary has failed.
