# 14013_Policy_POS_Hardware_Heartbeat_Local_Agent_And_Network_Disappearance

## 1. Purpose

This policy defines how the POS Gateway must detect, classify, and recover from store-side hardware, local agent, POS PC, printer, and network disappearance events.

The purpose is to prevent physical infrastructure failures from being misclassified as generic POS API errors or platform order failures.

In real stores, POS-connected order flow depends not only on provider APIs but also on local PCs, routers, printers, local middleware, and store staff behavior. The POS Gateway must treat these as explicit operational dependencies with heartbeat, reachability, recovery, and audit evidence.

## 2. Scope

This policy applies to:

* POS PC availability
* Local middleware or local agent availability
* Store router and LAN reachability
* Network printer reachability
* POS internal IP changes
* Printer internal IP changes
* POS PC sleep mode
* Local agent crash or stop
* Local agent version drift
* Store device identity
* Heartbeat and ping checks
* Offline and reconnect behavior
* Local queue replay
* Store-side recovery
* Operator visibility
* Audit evidence for hardware and network events

This policy applies to all provider integration modes that depend on store-side devices, local agents, network printers, or on-premise POS applications.

## 3. Core Principle

Store-side infrastructure must be treated as unreliable unless continuously verified.

A store device may disappear without the cloud provider being down.

The POS Gateway must distinguish:

* Provider cloud failure
* Local agent failure
* POS PC failure
* Printer failure
* Store router failure
* Store network failure
* Device IP change
* Store operator manual shutdown
* Unknown reachability loss

The system must not collapse these into one vague “POS error” state.

## 4. Local Infrastructure Boundary

The store-side dependency chain may include multiple physical and software components.

```
[Platform Cloud Gateway]
          |
          v
[Provider API Or Local Agent Bridge]
          |
          v
[Store Router / LAN]
          |
   -------------------
   |                 |
   v                 v
[POS PC]        [Network Printer]
   |
   v
[POS Application]
```

Each component has a different failure mode and recovery path.

The Gateway must preserve which component was unreachable or unhealthy.

## 5. Non-Negotiable Rules

### 5.1 Heartbeat Required Rule

Any local agent, local middleware, or platform-controlled store device must send or expose heartbeat evidence.

A store-side integration path without heartbeat must be classified as degraded.

### 5.2 Device Disappearance Must Be Explicit Rule

When a device becomes unreachable, the Gateway must mark a device disappearance state.

The system must not treat disappearance as ordinary provider rejection.

### 5.3 No Blind Local Replay Rule

When a local agent reconnects, it must not blindly replay old jobs without idempotency, freshness, and order-state checks.

Reconnect replay must be controlled.

### 5.4 Device Identity Rule

A local agent or printer must be bound to a known store and device identity.

The Gateway must not trust an unidentified local process or printer endpoint.

### 5.5 Operator Recovery Visibility Rule

Store operators and support operators must be able to see whether the issue is provider-side, local-agent-side, POS-PC-side, printer-side, or network-side.

The system must avoid vague operational messages such as “integration failed” when a narrower diagnosis exists.

## 6. Device Categories

The policy recognizes the following device categories.

### 6.1 POS PC

The POS PC may run:

* POS application
* Local middleware
* Printer driver
* Store database
* Vendor sync client
* Local API bridge

Failure examples:

* Sleep mode
* Application frozen
* Windows update restart
* User shutdown
* Network adapter reset
* Firewall change
* POS vendor update
* Local database lock

### 6.2 Local Agent

The local agent may be platform-owned or provider-owned.

It may handle:

* Order submission
* Printer routing
* Local queue
* Heartbeat
* Device discovery
* POS application bridge
* Status reporting

Failure examples:

* Agent process stopped
* Agent outdated
* Agent token expired
* Agent cannot reach Gateway
* Agent cannot reach POS
* Agent cannot reach printer
* Agent local queue corrupted
* Agent store binding mismatch

### 6.3 Store Router And LAN

The store network may fail even when internet service is partially available.

Failure examples:

* Router reboot
* DHCP address reassignment
* LAN cable unplugged
* Wi-Fi instability
* IP conflict
* NAT or firewall change
* ISP outage
* Captive portal or router reset

### 6.4 Network Printer

The kitchen printer or receipt printer may fail independently.

Failure examples:

* Printer offline
* Paper out
* Cover open
* Internal IP changed
* Printer buffer stuck
* Printer firmware issue
* ESC/POS unsupported command
* Encoding failure
* Network timeout

### 6.5 Provider Local Bridge

Some POS providers use their own local bridge software.

Failure examples:

* Vendor bridge stopped
* Vendor bridge cannot authenticate
* Vendor bridge sync delayed
* Vendor bridge version mismatch
* Vendor bridge cannot reach provider cloud
* Vendor bridge accepts request but POS application does not process it

## 7. Heartbeat Model

Heartbeat may be push-based or pull-based.

### 7.1 Push Heartbeat

A local agent periodically reports its state to the Gateway.

The heartbeat should include:

```
agent_id
store_id
device_id
agent_version
local_ip
public_ip_hash
pos_reachable
printer_reachable
queue_depth
last_successful_pos_call_at
last_successful_print_at
local_time
clock_drift
health_status
heartbeat_sent_at
```

### 7.2 Pull Heartbeat

The Gateway or provider checks whether the local agent or device responds.

The check may include:

* Agent ping
* POS bridge ping
* Printer ping
* Status query
* Version query
* Queue status query

Pull heartbeat requires network access rules and security controls.

### 7.3 Hybrid Heartbeat

A store may use both push and pull heartbeat.

Hybrid mode is preferred for critical production stores when local infrastructure is central to order flow.

## 8. Health Status Classification

The Gateway must normalize local health states.

Allowed states include:

```
HEALTHY
DEGRADED
HEARTBEAT_DELAYED
HEARTBEAT_MISSING
AGENT_OFFLINE
POS_PC_UNREACHABLE
POS_APP_UNRESPONSIVE
PROVIDER_BRIDGE_UNAVAILABLE
PRINTER_UNREACHABLE
PRINTER_STATUS_UNKNOWN
ROUTER_OR_LAN_UNSTABLE
IP_CHANGED
LOCAL_QUEUE_BACKLOG
VERSION_MISMATCH
AUTH_EXPIRED
STORE_RECOVERY_REQUIRED
UNKNOWN_LOCAL_FAILURE
```

These states must be visible in audit and support tooling.

## 9. Heartbeat Thresholds

Each store-side dependency must have thresholds.

Examples:

```
Healthy heartbeat threshold: recent heartbeat within expected interval
Delayed heartbeat threshold: heartbeat late but not yet offline
Missing heartbeat threshold: heartbeat absent beyond safe limit
Critical order flow threshold: local dependency unhealthy during order submission
Printer threshold: printer unreachable during print-required flow
Queue threshold: local queue depth beyond safe limit
```

Thresholds may vary by provider, store, device role, and integration mode.

## 10. POS PC Sleep Mode Handling

POS PC sleep mode is a common real-world failure.

If sleep or inactivity is detected or suspected, the Gateway must:

* Mark local path degraded
* Stop treating local submission as reliable
* Notify operator
* Provide store-side recovery instruction
* Prevent uncontrolled queue growth
* Preserve failure evidence
* Allow controlled retry after heartbeat recovery

Store onboarding must include power and sleep configuration checks when local agent mode is used.

## 11. IP Change Handling

Internal IPs may change after router reboot or DHCP renewal.

If IP change is detected, the system must:

* Compare previous known local IP and current local IP
* Mark affected device as changed
* Revalidate reachability
* Update device registry only through controlled process
* Avoid trusting unknown devices automatically
* Notify operator if manual network configuration is required

Static IP or DHCP reservation should be recommended for production printer and POS device paths.

## 12. Local Agent Version Control

Local agent version must be tracked.

The Gateway must record:

```
agent_id
agent_version
supported_gateway_contract_version
store_id
device_id
installed_at
last_seen_at
update_required_flag
deprecated_flag
blocked_flag
```

If the local agent is too old to safely handle the current contract, the integration path must be degraded or blocked.

## 13. Local Queue Handling

A local agent may maintain a local queue for temporary offline operation.

Local queue handling must define:

* Which jobs may be queued
* Which jobs may not be queued
* Maximum queue depth
* Maximum queue age
* Replay eligibility
* Replay idempotency
* Replay validation
* Replay ordering
* Replay cancellation
* Operator visibility

Old jobs must not replay after they are no longer valid.

## 14. Reconnect Behavior

When a device or local agent reconnects, the Gateway must not assume all pending work should resume automatically.

Reconnect handling must check:

* Current order state
* Current payment state
* Current kitchen state
* Original validation age
* Idempotency key
* Whether the order was manually handled
* Whether customer was refunded or canceled
* Whether POS already received the order
* Whether print already occurred or is uncertain

Reconnect replay must be audited.

## 15. Device Binding And Trust

A local device must be bound to:

* Tenant
* Store
* Device role
* Agent identity
* Device fingerprint, where available
* Installation record
* Authorized network context, where available

The Gateway must reject or quarantine reports from unknown or mismatched devices.

A device from one store must never be allowed to submit events for another store.

## 16. Local Time And Clock Drift

Local devices may have incorrect system time.

Heartbeat must report local time and Gateway-received time.

The Gateway must detect clock drift.

Clock drift may affect:

* Business day boundary
* Print timestamp
* Order timestamp
* Queue replay age
* Audit ordering
* Settlement evidence

Gateway time must remain the authoritative audit receipt time.

## 17. Local Failure Decision Outcomes

When local infrastructure is unhealthy, the Gateway may choose:

```
ALLOW_IF_NOT_DEPENDENT
BLOCK_ORDER
HOLD_FOR_RECHECK
QUEUE_BEFORE_PAYMENT
QUEUE_AFTER_PAYMENT_WITH_REVIEW
SWITCH_TO_MANUAL_FLOW
REQUIRE_OPERATOR_CONFIRMATION
DISABLE_DIRECT_PRINT
MARK_STORE_DEGRADED
ESCALATE_SUPPORT
OPEN_PROVIDER_OR_LOCAL_CIRCUIT
```

The decision must match order risk, payment state, print requirement, and provider capability.

## 18. Store Onboarding Requirements

Stores using local agent or direct print mode must complete onboarding checks.

Required checks include:

* POS PC power setting
* POS PC sleep setting
* Local agent installation
* Local agent version
* Local agent store binding
* Router stability
* Printer static IP or DHCP reservation
* Printer reachability
* Firewall allowance
* POS application reachability
* Test order submission
* Test print
* Recovery instruction
* Operator training evidence

A store cannot be production-ready for local mode without these checks.

## 19. Operator Console Requirements

The operator console must show:

* Store local health
* Agent last heartbeat
* Agent version
* POS reachability
* Printer reachability
* Queue depth
* Last successful POS call
* Last successful print
* IP change warning
* Version mismatch warning
* Recovery actions
* Support escalation status

Allowed operator actions may include:

```
RECHECK_HEARTBEAT
RECHECK_PRINTER
PAUSE_POS_SUBMISSION
RESUME_POS_SUBMISSION
PAUSE_DIRECT_PRINT
RETRY_LOCAL_JOB
CANCEL_STALE_LOCAL_JOB
MARK_MANUAL_RECOVERY
ESCALATE_DEVICE_SUPPORT
```

All operator actions must be audited.

## 20. Customer-Facing Messaging

Customer-facing messages must be non-technical.

Examples:

```
The store is confirming your order.
The store needs a moment to receive this order.
This store is temporarily unable to accept online orders.
Your order could not be confirmed. No payment was completed.
The store is reviewing this order.
```

Customer-facing messages must not expose local IPs, router failures, printer errors, POS PC state, or internal device names.

## 21. Audit Requirements

Every hardware, heartbeat, local agent, or network state transition must preserve:

* Store ID
* Provider ID
* Device ID
* Agent ID, if applicable
* Device role
* Health state
* Previous health state
* Heartbeat timestamp
* Gateway receipt timestamp
* Local IP, redacted or hashed where appropriate
* Agent version
* POS reachability result
* Printer reachability result
* Queue depth
* Failure reason
* Recovery action
* Operator action, if any
* Trace ID
* Related order ID, if applicable
* Related print ticket ID, if applicable
* Gateway version
* Timestamp

Sensitive infrastructure information must be redacted, tokenized, or restricted according to the security runtime policy.

## 22. Test Requirements

Each local infrastructure integration must test:

* Healthy heartbeat
* Delayed heartbeat
* Missing heartbeat
* Agent offline
* Agent reconnect
* POS PC unreachable
* POS application unresponsive
* Printer unreachable
* Printer IP change
* Router restart
* Local queue growth
* Local queue replay
* Stale local job cancellation
* Agent version mismatch
* Unknown device rejection
* Clock drift
* Operator manual recovery
* Audit preservation for all health states

A local agent or direct print path cannot be production-ready without local failure test evidence.

## 23. Anti-Patterns

The following are prohibited:

* Treating local agent failure as generic POS error
* Trusting local device events without device binding
* Blindly replaying local queues after reconnect
* Allowing stale local jobs to submit after cancellation or refund
* Hiding heartbeat loss from operators
* Assuming printer and POS PC share the same health state
* Automatically trusting changed internal IPs without validation
* Allowing outdated local agents to process new contract payloads
* Using local device time as authoritative audit time
* Exposing internal network details to customers

## 24. Relationship With Other Documents

This policy depends on and supports:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05330 POS Master Data Sync And Precheck Validation Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Local infrastructure is a field reliability boundary and must be treated as part of POS Gateway resilience.

## 25. Final Rule

The POS Gateway must always be able to distinguish provider failure from local infrastructure failure.

If the system cannot tell whether an order failed because the provider API was down, the local agent disappeared, the POS PC slept, the printer vanished, or the store network changed, the local resilience boundary has failed.
