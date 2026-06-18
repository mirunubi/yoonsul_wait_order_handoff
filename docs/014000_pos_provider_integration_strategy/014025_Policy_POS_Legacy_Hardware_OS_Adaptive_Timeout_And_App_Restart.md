# 014025_Policy_POS_Legacy_Hardware_OS_Adaptive_Timeout_And_App_Restart

## 1. Purpose

This policy defines how the POS Gateway must handle legacy POS hardware, low-spec POS PCs, outdated operating systems, POS application freeze, forced POS application restart, CPU saturation, socket exhaustion, local middleware delay, and adaptive timeout behavior.

The purpose is to prevent store-side device weakness from being misclassified as ordinary provider API failure, platform order failure, or customer error.

In real stores, POS-connected order flow may depend on old Windows-based POS PCs, low-end CPUs, unstable local applications, printer drivers, vendor middleware, and operator restarts. The POS Gateway must detect, classify, tolerate, and audit these conditions without losing orders, duplicating submissions, or blocking the entire platform.

## 2. Scope

This policy applies to:

* Low-spec POS PC
* Legacy Windows environment
* POS application freeze
* POS application forced shutdown
* POS application restart
* Local middleware slowdown
* CPU saturation
* Memory exhaustion
* Thread exhaustion
* Socket timeout
* Connection pool exhaustion
* Local bridge delay
* Provider server alive but store POS app dead
* Adaptive timeout
* Dynamic retry timing
* Store-side health check
* Operator restart recovery
* Audit evidence for local app and hardware instability

This policy applies to all provider integration modes that depend on local POS applications, local middleware, local bridge software, printer drivers, or store-side PC resources.

## 3. Core Principle

A provider may be healthy while the store POS application is dead.

A store POS PC may be alive while the POS application is frozen.

A local agent may be alive while it cannot safely communicate with the POS application.

The POS Gateway must distinguish:

* Provider cloud outage
* Local POS app freeze
* Local POS app restart
* POS PC hardware saturation
* Local agent delay
* Socket timeout
* Connection pool pressure
* Printer driver lock
* Store network instability
* Operator forced restart
* Unknown local execution gap

The system must not collapse these into one vague “POS timeout” state.

## 4. Legacy Hardware Boundary

The local execution path may contain several weak points.

```
[Cloud Gateway]
      |
      v
[Provider Cloud Or Gateway Bridge]
      |
      v
[Local Agent / Middleware]
      |
      v
[Legacy POS PC]
      |
  -------------------------
  |                       |
  v                       v
[POS Application]      [Printer Driver]
      |
      v
[POS Local Database / Runtime]
```

Any component in this path may delay, drop, freeze, restart, or misreport state.

## 5. Non-Negotiable Rules

### 5.1 Local App Health Is Separate From Provider Health Rule

Provider API health must not be treated as proof that the store POS application is processing orders.

The Gateway must maintain separate health indicators for:

* Provider cloud
* Local agent
* POS PC
* POS application
* Printer driver
* Local queue

### 5.2 Timeout Must Be Context-Aware Rule

Timeout values must not be hardcoded blindly across all stores, providers, operations, and hardware classes.

The Gateway must support adaptive or profile-based timeout behavior based on:

* Provider
* Store
* Integration mode
* Operation risk
* Historical latency
* Peak-time profile
* Local device health
* Queue depth
* Payment state

### 5.3 Restart Gap Must Be Visible Rule

If the POS application is stopped or restarted during business hours, the Gateway must mark a restart gap or local execution unavailable state.

Orders submitted during this gap must be queued, blocked, degraded, or manually reviewed according to risk.

### 5.4 No Unlimited Connection Waiting Rule

Long timeouts must not exhaust Gateway worker threads, sockets, or connection pools.

The Gateway must use bounded timeouts, cancellation, circuit breaker, and queueing rather than holding connections indefinitely.

### 5.5 Operator Restart Must Be Audited Rule

If staff restarts the POS app, local agent, printer service, or POS PC, the event must be recorded when detectable or operator-confirmed.

Restart is not merely a technical event. It may affect order submission, payment, kitchen printing, and reconciliation.

## 6. Hardware And OS Classification

Each store-side POS environment should be classified.

Possible hardware classes include:

```
MODERN_POS_PC
STANDARD_POS_PC
LOW_SPEC_POS_PC
LEGACY_POS_PC
UNKNOWN_POS_PC
PROVIDER_MANAGED_TERMINAL
TABLET_POS
CLOUD_ONLY_NO_LOCAL_PC
```

Possible OS classes include:

```
WINDOWS_11
WINDOWS_10
WINDOWS_7_OR_OLDER
WINDOWS_SERVER_VARIANT
ANDROID_POS
LINUX_POS
PROVIDER_APPLIANCE_OS
UNKNOWN_OS
```

Legacy or unknown environments must receive stricter readiness checks.

## 7. Local Runtime Health Signals

The Gateway or local agent should collect local runtime health signals where permitted.

Signals may include:

```
cpu_usage_percent
memory_usage_percent
disk_free_space
process_running_flag
pos_app_responsive_flag
local_agent_responsive_flag
printer_driver_responsive_flag
socket_error_count
connection_timeout_count
request_queue_depth
average_local_response_time
p95_local_response_time
last_pos_app_seen_at
last_successful_order_submit_at
last_successful_print_at
restart_detected_at
os_version
agent_version
```

Collection must respect security, privacy, and provider contract boundaries.

## 8. POS Application Health States

The Gateway must normalize POS application health.

Allowed states include:

```
POS_APP_HEALTHY
POS_APP_SLOW
POS_APP_UNRESPONSIVE
POS_APP_RESTARTING
POS_APP_STOPPED
POS_APP_FORCE_CLOSED
POS_APP_STARTUP_PENDING
POS_APP_READY_UNKNOWN
POS_APP_VERSION_CHANGED
POS_APP_LOCAL_DB_LOCKED
POS_APP_PROVIDER_BRIDGE_UNAVAILABLE
POS_APP_HEALTH_UNSUPPORTED
POS_APP_UNKNOWN_FAILURE
```

These states must be distinct from provider cloud health.

## 9. Adaptive Timeout Policy

Timeout policy must be adaptive or profile-based.

The policy may consider:

* Operation type
* Risk class
* Provider
* Store hardware class
* Current local health
* Historical latency
* Peak-time window
* Queue depth
* Payment status
* Idempotency support
* Circuit breaker state

Example operation classes:

```
HEALTH_CHECK
MENU_SYNC
PRICE_VALIDATION
ORDER_SUBMISSION
PAYMENT_SYNC
CANCELLATION
REFUND_SYNC
KITCHEN_PRINT
STATUS_QUERY
```

Each class may have different timeout and retry behavior.

## 10. Timeout Result Classification

The Gateway must classify timeout outcomes.

Allowed categories include:

```
PROVIDER_CLOUD_TIMEOUT
LOCAL_AGENT_TIMEOUT
POS_APP_TIMEOUT
PRINTER_DRIVER_TIMEOUT
SOCKET_CONNECT_TIMEOUT
SOCKET_READ_TIMEOUT
CONNECTION_POOL_TIMEOUT
CPU_SATURATION_TIMEOUT
LOCAL_QUEUE_TIMEOUT
UNKNOWN_TIMEOUT
```

Timeout classification must influence retry, queue, circuit, and operator decisions.

## 11. Tight Timeout Risk

Timeouts that are too tight may cause false failure.

False failure may occur when:

* Low-spec POS PC is slow but still processing
* POS app is busy during lunch peak
* Local agent is waiting for POS DB lock
* Printer driver blocks the POS thread
* Provider bridge is slow but not dead
* Windows update or antivirus slows the machine

False failure may create duplicate retry risk.

The Gateway must not assume timeout means provider did not process the request.

## 12. Loose Timeout Risk

Timeouts that are too loose may cause resource exhaustion.

Loose timeout may create:

* Gateway worker starvation
* Socket pool exhaustion
* Customer waiting screen freeze
* Queue buildup
* Payment uncertainty
* Duplicate customer retry
* Retry storm after backlog clears

The Gateway must use bounded waiting and controlled pending state.

## 13. Adaptive Timeout Decision Outcomes

When timeout risk changes, the Gateway may choose:

```
USE_NORMAL_TIMEOUT
USE_EXTENDED_TIMEOUT
USE_SHORT_TIMEOUT_AND_QUEUE
BLOCK_HIGH_RISK_OPERATION
SWITCH_TO_PENDING_CONFIRMATION
REQUIRE_OPERATOR_CONFIRMATION
OPEN_LOCAL_CIRCUIT
MARK_STORE_DEGRADED
DISABLE_LOCAL_PATH
ESCALATE_SUPPORT
```

The chosen outcome must be auditable.

## 14. POS App Restart Detection

Restart may be detected through:

* Process heartbeat loss
* Local agent report
* Provider bridge disconnect
* Socket reset
* Local port unavailable
* POS app version or start time change
* Operator confirmation
* Sudden queue failure followed by recovery
* Printer service restart correlation

Detected restart must create a restart gap event.

## 15. Restart Gap Handling

A restart gap is the period when the POS app is unavailable or not safely processing orders.

During a restart gap, the Gateway must evaluate:

* Orders already submitted before restart
* Orders in-flight during restart
* Orders queued during restart
* Payments approved during restart
* Kitchen tickets not printed
* Cancellations not synced
* Refunds not synced
* Manual POS entries performed by staff

Each affected operation must be reconciled after the POS app returns.

## 16. In-Flight Operation During Restart

If the POS app restarts while an operation is in-flight, the outcome may be ambiguous.

Examples:

* Order submitted but ACK lost
* POS created receipt before crash
* POS did not commit order
* Local DB locked during write
* Print command buffered but not printed
* Cancellation request lost
* Status query unavailable

The Gateway must attempt reconciliation before replay.

Blind replay is prohibited for high-risk operations.

## 17. Local Circuit Breaker

A local circuit breaker may be opened separately from provider circuit.

Local circuit open triggers may include:

* Missing local agent heartbeat
* POS app unresponsive
* POS app restart detected
* CPU saturation above threshold
* Local queue depth too high
* Repeated socket timeout
* Printer driver lock affecting order path
* Operator marks POS unstable

Local circuit state must not automatically imply provider cloud outage.

## 18. CPU And Resource Saturation Handling

When CPU, memory, disk, or thread saturation is detected, the Gateway may:

* Mark local health degraded
* Increase timeout for low-risk operations
* Reduce concurrency
* Throttle outbound local requests
* Pause non-critical sync
* Queue lower-priority jobs
* Block payment-sensitive operations
* Notify operator
* Escalate support

Resource saturation must be preserved in health audit.

## 19. Connection Pool Protection

The Gateway must protect its own connection pools.

Rules should include:

* Maximum concurrent calls per provider
* Maximum concurrent calls per store
* Maximum local agent sessions
* Maximum pending socket count
* Request cancellation
* Backpressure
* Queue handoff
* Circuit breaker integration

The platform must not let one weak POS PC consume shared Gateway capacity.

## 20. Store-Specific Timeout Profile

A store may have a timeout profile.

The profile should include:

```
store_id
provider_id
hardware_class
os_class
integration_mode
normal_timeout_ms
peak_timeout_ms
local_agent_timeout_ms
pos_app_timeout_ms
printer_timeout_ms
max_concurrent_local_requests
queue_threshold
degraded_mode_threshold
last_calibrated_at
approved_by
```

Store-specific tuning must not bypass payment and idempotency safety rules.

## 21. Peak-Time Profile

The Gateway may apply peak-time profiles.

Peak windows may include:

* Lunch peak
* Dinner peak
* Weekend peak
* Store-specific rush
* Event traffic
* Franchise promotion traffic

Peak profile may adjust:

* Timeout
* Concurrency
* Throttling
* Queue eligibility
* Operator alerts
* Customer pending copy
* Circuit thresholds

Peak tuning must not hide actual failures.

## 22. Operator Console Requirements

The operator console must show:

* Store hardware class
* OS class, if known
* POS app health
* Local agent health
* Current timeout profile
* Local circuit state
* CPU or resource warning, if available
* Restart gap events
* In-flight affected operations
* Queue depth
* Last successful POS app interaction
* Required recovery action

Allowed operator actions may include:

```
MARK_POS_APP_RESTARTED
CONFIRM_POS_APP_READY
OPEN_LOCAL_CIRCUIT
CLOSE_LOCAL_CIRCUIT_AFTER_CHECK
PAUSE_LOCAL_SUBMISSION
RESUME_LOCAL_SUBMISSION
RECALIBRATE_TIMEOUT_PROFILE
CANCEL_STALE_IN_FLIGHT_OPERATION
RECONCILE_AFTER_RESTART
ESCALATE_HARDWARE_SUPPORT
```

All operator actions must be audited.

## 23. Customer-Facing Messaging

Customer-facing messaging must remain non-technical.

Examples:

```
The store is taking longer than usual to confirm this order.
The store is reconnecting its order system.
Your order is still being confirmed.
This store is temporarily unable to accept online orders.
No payment was completed for this order.
```

Customer-facing messages must not expose POS PC specifications, OS version, CPU usage, local IP, process names, or internal timeout policies.

## 24. Audit Requirements

Every legacy hardware, timeout, restart, and local app health event must preserve:

* Store ID
* Provider ID
* Local agent ID, if applicable
* Device ID, if applicable
* Hardware class
* OS class
* POS app health state
* Previous health state
* Timeout category
* Timeout profile
* Operation type
* Operation risk class
* Related order ID, if applicable
* Related payment ID, if applicable
* Related print ticket ID, if applicable
* Local circuit state
* Queue job ID, if applicable
* Restart gap ID, if applicable
* Resource signal snapshot, if available
* Decision outcome
* Operator action, if any
* Trace ID
* Idempotency key
* Gateway version
* Local agent version
* Adapter version
* Timestamp

Sensitive infrastructure data must be redacted, tokenized, or access-restricted according to the security runtime policy.

## 25. Test Requirements

Each local POS integration must test:

* Normal local POS app response
* Slow POS app response
* POS app timeout
* POS app forced shutdown
* POS app restart recovery
* Local agent alive but POS app dead
* Provider cloud alive but local POS app dead
* CPU saturation simulation
* Socket read timeout
* Connection pool pressure
* Adaptive timeout adjustment
* Local circuit open
* Local circuit half-open recovery
* Queue during restart gap
* Reconciliation after restart
* Ambiguous in-flight operation
* Payment blocked during unsafe local gap
* Audit preservation for local health and timeout states

A local POS integration cannot be production-ready without legacy hardware and app restart test evidence.

## 26. Store Onboarding Requirements

For local POS or legacy hardware environments, store onboarding must verify:

* POS PC hardware class
* OS class
* Power and sleep settings
* POS app startup behavior
* Local agent installation
* Local agent auto-start
* Local agent permissions
* Firewall configuration
* Printer driver behavior
* Provider bridge behavior
* Basic load test
* Restart recovery test
* Timeout profile
* Operator restart instruction
* Support escalation path

Legacy stores without onboarding evidence must be marked readiness-incomplete.

## 27. Anti-Patterns

The following are prohibited:

* Treating provider cloud health as proof of local POS app health
* Using one hardcoded timeout for all providers and stores
* Holding Gateway connections indefinitely while local POS app freezes
* Retrying ambiguous in-flight operations after restart without reconciliation
* Allowing a weak store device to exhaust shared Gateway resources
* Hiding POS app restart gaps from operators
* Treating CPU saturation as a customer error
* Ignoring low-spec POS PC constraints during onboarding
* Allowing outdated local agents to continue without version control
* Exposing hardware or OS details to customers
* Marking order confirmed while POS app processing is unknown

## 28. Relationship With Other Documents

This policy depends on and supports:

```
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
05410 POS Waiting Entry NoShow And Prepaid Cancel Sync Policy
```

Legacy hardware and adaptive timeout handling protects the Gateway from mistaking slow local execution for safe failure or safe success.

## 29. Final Rule

The POS Gateway must always be able to explain whether a delay came from the provider cloud, local agent, POS PC hardware, POS application freeze, app restart, printer driver, socket timeout, connection pool pressure, or unknown local execution gap.

If the system cannot distinguish slow local POS execution from provider failure, or if timeout tuning causes lost orders, duplicate submissions, or Gateway resource exhaustion, the legacy hardware and adaptive timeout boundary has failed.
