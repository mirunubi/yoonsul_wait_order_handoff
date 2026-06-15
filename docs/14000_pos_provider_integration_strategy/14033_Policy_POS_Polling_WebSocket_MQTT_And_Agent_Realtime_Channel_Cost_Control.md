# 14033_Policy_POS_Polling_WebSocket_MQTT_And_Agent_Realtime_Channel_Cost_Control

## 1. Purpose

This policy defines how the POS Gateway must control polling traffic, real-time agent communication, WebSocket or MQTT channel design, long polling fallback, connection fan-out, idle traffic cost, and store-agent communication cost.

The purpose is to prevent store-side agents, legacy POS polling, printer status checks, order status checks, and heartbeat traffic from creating unsustainable infrastructure cost, unnecessary server load, or Gateway saturation as the number of connected stores grows.

Legacy POS providers may not support reliable webhooks. In those cases, the platform may need store-side agents or local bridges to maintain operational state. This must be done through a controlled real-time channel strategy, not uncontrolled short-interval polling.

## 2. Scope

This policy applies to:

* Store-side agent polling
* Gateway polling endpoints
* POS status polling
* Order status polling
* Printer status polling
* Menu sync polling
* Sold-out polling
* Heartbeat polling
* Long polling
* WebSocket channel
* MQTT channel
* Server-sent event channel, if used
* Agent reconnect
* Agent channel authentication
* Agent channel backoff
* Idle connection cost
* Per-store traffic budget
* Per-provider traffic budget
* Polling interval control
* Push and pull hybrid communication
* Audit evidence for agent communication decisions

This policy applies to all local agent, local middleware, legacy POS, direct printer, and real-time store communication flows.

## 3. Core Principle

Polling must be treated as a cost and capacity risk.

A polling design that works for ten stores may collapse at one thousand stores.

The POS Gateway must not allow every store agent to call every few seconds without traffic budgeting, adaptive interval control, connection reuse, push channel optimization, jitter, backoff, and observability.

The system must prefer event-driven or persistent lightweight channels where they reduce cost and improve reliability, but those channels must also be authenticated, bounded, monitored, and recoverable.

## 4. Agent Communication Boundary

Store communication may use multiple channel modes.

```
[Store POS / Printer / Local Agent]
                |
                v
    [Agent Realtime Channel Layer]
                |
   --------------------------------
   |              |               |
   v              v               v
[WebSocket]    [MQTT]        [Polling / Fallback]
                |
                v
          [POS Gateway]
```

The Gateway must choose channel mode by provider, store capability, network environment, risk, and cost.

## 5. Non-Negotiable Rules

### 5.1 No Fixed Aggressive Polling Rule

A fixed one-second or three-second polling interval across all stores is prohibited unless specifically justified, capped, and monitored.

Polling intervals must be adaptive or profile-based.

### 5.2 Polling Must Have Budget Rule

Each store, provider, tenant, and endpoint must have a traffic budget.

The Gateway must know the expected request rate and cost impact of polling behavior.

### 5.3 Jitter Required Rule

Polling schedules must include jitter to avoid synchronized request spikes.

All agents must not wake up and hit the Gateway at the same second.

### 5.4 Backoff Required Rule

When the Gateway, provider, or store channel is unhealthy, agents must back off rather than retry aggressively.

Backoff must apply to reconnect, polling, sync, and status query behavior.

### 5.5 Persistent Channel Must Be Authenticated Rule

WebSocket, MQTT, or any persistent channel must authenticate store, device, agent, tenant, and permission context.

A connected agent must not be allowed to submit or receive events for another store.

### 5.6 Fallback Must Not Become Permanent Hidden Polling Rule

Polling fallback may be used when persistent channels fail, but it must be visible, rate-limited, and auditable.

Fallback mode must not silently become permanent high-cost operation.

## 6. Channel Modes

### 6.1 Short Polling

The agent periodically sends HTTP requests to check for state changes.

Short polling is simple but expensive.

It should be limited to:

* Low store count
* Temporary fallback
* Low-frequency health checks
* Provider environments where persistent connection is impossible

Short polling requires strict interval and jitter control.

### 6.2 Long Polling

The agent holds a request open until an event is available or timeout occurs.

Long polling may reduce request count but still consumes server resources.

It requires:

* Timeout budget
* Connection limit
* Reconnect backoff
* Proxy compatibility check
* Load balancing support
* Graceful drain behavior

### 6.3 WebSocket

WebSocket provides persistent bidirectional communication.

It may be used for:

* Agent heartbeat
* Order dispatch
* Print job dispatch
* Status event receive
* Store command receive
* Operator command propagation

WebSocket requires:

* Authentication
* Reconnect strategy
* Message acknowledgment
* Backpressure
* Channel-level idempotency
* Connection lifecycle monitoring

### 6.4 MQTT

MQTT may be used for lightweight device-style messaging.

It may be useful for:

* Many store agents
* Low-bandwidth status updates
* Topic-based routing
* Retained state, if safely configured
* QoS-based delivery, if understood and tested

MQTT requires:

* Topic isolation
* Store binding
* QoS policy
* Retained message policy
* Broker scaling
* Authentication
* Authorization
* Replay handling

### 6.5 Hybrid Mode

A store may use persistent channel for commands and polling for provider state that cannot be pushed.

Hybrid mode must be explicit.

Example:

* WebSocket for Gateway-to-agent order dispatch
* Agent local polling to POS app
* Agent sends only changed state to Gateway

Hybrid mode is often required for legacy POS environments.

## 7. Agent Traffic Types

The Gateway must classify agent traffic.

Allowed traffic types include:

```
HEARTBEAT
ORDER_DISPATCH
ORDER_STATUS_UPDATE
PRINT_JOB_DISPATCH
PRINT_STATUS_UPDATE
MENU_SYNC
SOLD_OUT_SYNC
TABLE_SYNC
BUSINESS_DAY_SYNC
LOCAL_HEALTH_REPORT
LOCAL_QUEUE_REPORT
PROVIDER_BRIDGE_STATUS
COMMAND_ACK
ERROR_REPORT
LOG_SUMMARY
CONFIG_UPDATE
UNKNOWN_AGENT_TRAFFIC
```

Each traffic type must have frequency, priority, and payload-size policy.

## 8. Traffic Priority

Agent traffic must be prioritized.

### 8.1 Critical Priority

Examples:

* Payment-related order state
* POS order acceptance
* POS order rejection
* Refund or void state
* Cancel signal
* Kitchen stop signal

Critical traffic requires fast delivery and strong audit.

### 8.2 High Priority

Examples:

* New order dispatch
* Print job dispatch
* Table assignment conflict
* Stock sold-out update
* Local agent offline transition

High-priority traffic should not be blocked by low-priority sync.

### 8.3 Medium Priority

Examples:

* Menu sync
* Table sync
* Business day sync
* Local queue report

Medium traffic may be delayed under pressure.

### 8.4 Low Priority

Examples:

* Routine health detail
* Non-critical log summary
* Diagnostic metrics
* Full menu refresh
* Printer capability scan

Low-priority traffic may be throttled or paused during peak.

## 9. Polling Budget Model

Each polling path must define budget.

A polling budget should include:

```
store_id
provider_id
agent_id
endpoint
traffic_type
normal_interval_seconds
peak_interval_seconds
degraded_interval_seconds
minimum_interval_seconds
maximum_interval_seconds
jitter_range_seconds
max_requests_per_minute
max_payload_bytes
backoff_policy
fallback_allowed
last_calibrated_at
```

Budget must be reviewed as store count grows.

## 10. Adaptive Polling

Polling interval may change based on context.

The system may shorten interval when:

* Store is open
* Order is in progress
* Payment is pending
* Kitchen cancel is pending
* Local queue has jobs
* Operator is actively troubleshooting

The system may lengthen interval when:

* Store is closed
* No active orders
* No pending jobs
* Provider circuit is open
* Agent is in degraded mode
* Gateway is under pressure
* Low-priority sync is scheduled off-peak

Adaptive polling decisions must be auditable when they affect order flow.

## 11. Jitter And Herd Prevention

Agents must avoid synchronized behavior.

Herd risk occurs when:

* All agents start at the same time
* All agents reconnect after deploy
* All agents poll at exact interval
* All agents retry after provider outage
* All agents perform menu sync at opening time

The Gateway must use:

* Randomized jitter
* Staggered schedule
* Per-store offset
* Exponential backoff
* Retry-after control
* Fleet-wide rate limiting
* Gradual rollout

## 12. Reconnect Storm Handling

Persistent channels may experience reconnect storm.

Reconnect storm may occur after:

* Gateway deploy
* Network outage
* Broker restart
* Certificate rotation
* Agent update
* Provider incident
* Store internet outage recovery

Reconnect must use:

* Random backoff
* Maximum retry interval
* Authentication throttling
* Connection admission control
* Status page or config broadcast, if available
* Operator incident visibility

The Gateway must not allow reconnect storm to starve order processing.

## 13. Message Acknowledgment

Persistent channel messages must have acknowledgment where operationally required.

Message acknowledgment should include:

```
message_id
agent_id
store_id
message_type
sent_at
received_at
acknowledged_at
processing_result
idempotency_key
retry_count
```

Not every diagnostic message needs strong acknowledgment, but order, payment, print, cancel, and refund messages do.

## 14. Delivery Semantics

Each message type must declare delivery semantics.

Allowed semantics include:

```
AT_MOST_ONCE
AT_LEAST_ONCE
EXACTLY_ONCE_BY_IDEMPOTENCY
BEST_EFFORT
OPERATOR_CONFIRMED
```

For most practical systems, “exactly once” must be achieved through idempotency and state checks, not by assuming the network guarantees it.

## 15. Topic And Route Isolation

For MQTT or topic-based systems, topics must be isolated.

Topic design must prevent cross-store leakage.

Example topic dimensions:

```
tenant_id
store_id
agent_id
provider_id
traffic_type
command_or_event
```

A store agent must not subscribe to another store’s command topic.

Wildcard subscriptions must be restricted.

## 16. Payload Size Control

Agent messages must have payload size limits.

Large payloads may include:

* Full menu sync
* Full table map
* Diagnostic logs
* Raw provider payloads
* Printer capability scan
* Local queue dump

Large payloads should use controlled upload, compression, chunking, or scheduled off-peak sync where appropriate.

Large payloads must not block critical order or payment messages.

## 17. Offline And Store-And-Forward

Agents may operate during temporary disconnection.

Store-and-forward requires:

* Local queue identity
* Message ID
* Idempotency key
* Expiration
* Replay eligibility
* Ordering policy
* Conflict policy
* Gateway acknowledgment
* Audit preservation

Offline stored messages must not replay after they are stale, canceled, refunded, superseded, or unsafe.

## 18. Agent Configuration Distribution

The Gateway may send configuration to agents.

Config may include:

* Polling intervals
* Feature flags
* Provider endpoint settings
* Printer profile
* Timeout profile
* Store open schedule
* Debug mode
* Traffic throttle
* Channel mode
* Backoff policy

Agent config must be versioned and store-bound.

Misconfigured agent traffic can create fleet-wide cost or reliability issues.

## 19. Security Requirements

Persistent and polling channels must enforce:

* Agent authentication
* Store binding
* Tenant binding
* Device identity
* Token rotation
* Message integrity
* Replay protection
* Least privilege
* Command authorization
* Rate limiting
* Audit of privileged commands

Agent channels must not become an unprotected backdoor into store operations.

## 20. Cost Monitoring

The Gateway must monitor communication cost drivers.

Metrics should include:

* Requests per store per minute
* Requests per provider per minute
* Polling hit rate
* Empty polling response rate
* WebSocket connection count
* MQTT connection count
* Reconnect rate
* Message count by type
* Payload bytes by type
* Egress bytes
* Broker cost
* Idle connection cost
* Retry traffic
* Off-peak sync traffic
* Cost per store
* Cost per successful order

Cost monitoring must influence channel design.

## 21. Empty Polling Response Control

Empty polling responses are a major waste source.

The Gateway must track:

* Empty response ratio
* Polling interval
* Store open state
* Agent active state
* Pending job state
* Last meaningful event time

If empty response ratio is high, the system should lengthen interval, switch to persistent channel, or disable unnecessary polling.

## 22. Gateway Protection

Agent traffic must not starve core customer traffic.

Gateway protection may include:

* Separate ingress path for agents
* Separate rate limit for agents
* Separate worker pool for agent traffic
* Separate queue for low-priority sync
* Priority routing for customer order traffic
* Payload size limit
* Connection admission control
* Circuit breaker for agent channel
* Regional or provider partitioning

Agent fleet traffic must be isolated from customer-facing order flow.

## 23. Deployment And Rolling Update Behavior

Agent updates and Gateway deploys must avoid fleet-wide storms.

Deployment strategy should include:

* Staggered rollout
* Randomized reconnect
* Version compatibility window
* Graceful connection drain
* Backward-compatible message schema
* Rollback plan
* Agent update health monitoring
* Forced downgrade policy, if needed

A deploy must not make thousands of agents reconnect simultaneously without control.

## 24. Operator Console Requirements

The operator console must show:

* Store agent channel mode
* Agent connection state
* Last heartbeat
* Polling interval
* Empty polling ratio
* Message backlog
* Reconnect count
* Current backoff state
* Traffic budget status
* Cost warning
* Channel degradation
* Agent config version
* Pending commands
* Last command acknowledgment

Allowed operator actions may include:

```
SWITCH_TO_FALLBACK_POLLING
SWITCH_TO_WEBSOCKET
SWITCH_TO_MQTT
INCREASE_POLL_INTERVAL
DECREASE_POLL_INTERVAL_WITH_REASON
PAUSE_LOW_PRIORITY_SYNC
FORCE_AGENT_RECONNECT_WITH_JITTER
SEND_CONFIG_UPDATE
DISABLE_AGENT_CHANNEL
ESCALATE_CHANNEL_INCIDENT
```

All operator actions must be audited.

## 25. Customer-Facing Messaging

Customer-facing messaging must not expose channel internals.

Allowed messages may include:

```
The store is confirming your order.
The store is reconnecting its order system.
This store is temporarily unable to accept online orders.
Your order is taking longer than usual to confirm.
```

Customer-facing messages must not mention polling, WebSocket, MQTT, broker, agent connection, reconnect storm, or infrastructure cost.

## 26. Audit Requirements

Every agent channel and polling policy decision must preserve:

* Store ID
* Provider ID
* Agent ID
* Device ID, if applicable
* Channel mode
* Previous channel mode
* Traffic type
* Polling interval
* Jitter policy
* Backoff policy
* Message ID, if applicable
* Message type, if applicable
* Delivery semantics
* Acknowledgment state
* Connection state
* Reconnect count
* Queue depth
* Empty response ratio, if applicable
* Cost warning state, if applicable
* Decision outcome
* Operator action, if any
* Trace ID
* Correlation ID
* Idempotency key, if applicable
* Gateway version
* Agent version
* Timestamp

Sensitive device and network data must be redacted, tokenized, encrypted, or access-restricted according to the security runtime policy.

## 27. Test Requirements

Each agent communication integration must test:

* Normal polling
* Adaptive polling interval
* Jitter distribution
* Empty polling control
* Polling backoff
* Long polling timeout
* WebSocket connect
* WebSocket reconnect
* MQTT connect
* MQTT topic authorization
* Message acknowledgment
* Duplicate message handling
* Offline store-and-forward
* Replay after reconnect
* Stale message rejection
* Reconnect storm
* Gateway deploy with connection drain
* Agent update rollout
* Large payload handling
* Low-priority sync throttling
* Critical message priority
* Agent traffic does not starve customer traffic
* Audit preservation for channel state

A store-agent communication path cannot be production-ready without polling and real-time channel cost control test evidence.

## 28. Anti-Patterns

The following are prohibited:

* Fixed one-second polling across all stores
* Polling every store during closed hours without reason
* No jitter on polling intervals
* No backoff during Gateway or provider incident
* Treating WebSocket as automatically reliable
* Treating MQTT QoS as substitute for idempotency
* Allowing agents to subscribe to other stores’ topics
* Letting low-priority menu sync block order dispatch
* Allowing reconnect storms during deploy
* Storing offline agent jobs without expiration
* Accepting unlimited diagnostic payloads
* Hiding high empty-polling cost from operators
* Letting agent traffic starve customer-facing order flow

## 29. Relationship With Other Documents

This policy depends on and supports:

```
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05420 POS Legacy Hardware OS Adaptive Timeout And App Restart Policy
05450 POS External API Isolation NonBlocking IO And Connection Pool Protection Policy
05480 POS Multi Endpoint Routing Delivery App Port Contention And Malicious Manual Mutation Defense Policy
```

Agent channel cost control is the fleet-scale communication boundary of the POS Gateway.

## 30. Final Rule

The POS Gateway must always be able to control how often store agents communicate, which channel they use, what priority their messages have, how reconnection behaves, and how much traffic cost they generate.

If the platform requires thousands of agents to perform aggressive polling without budget, jitter, backoff, persistent channel strategy, priority control, and audit visibility, the agent communication cost boundary has failed.
