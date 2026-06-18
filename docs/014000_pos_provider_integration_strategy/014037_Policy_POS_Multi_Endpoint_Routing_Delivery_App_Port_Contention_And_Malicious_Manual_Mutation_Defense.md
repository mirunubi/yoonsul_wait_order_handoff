# 014037_Policy_POS_Multi_Endpoint_Routing_Delivery_App_Port_Contention_And_Malicious_Manual_Mutation_Defense

## 1. Purpose

This policy defines how the POS Gateway must handle multi-endpoint POS routing, delivery-app coexistence, local hardware port contention, shared printer resource conflict, multiple business entities inside one store, and malicious or unauthorized manual POS mutation after platform-confirmed order and payment.

The purpose is to prevent real store infrastructure disorder and intentional store-side manipulation from corrupting platform order, payment, kitchen, settlement, tax, and audit integrity.

In commercial F&B stores, the POS PC may run multiple third-party order applications, delivery dispatch programs, printer drivers, vendor bridges, VAN utilities, and manual operator workflows. The POS Gateway must assume that local resources can be contested, POS endpoints may be plural, and store-side manual changes may be accidental or intentional.

## 2. Scope

This policy applies to:

* Multiple POS endpoints in one store
* Multiple business entities in one physical location
* Hall POS and delivery POS separation
* Takeout POS and dine-in POS separation
* Shared kitchen with multiple POS systems
* Shared or cloud kitchen routing
* Delivery platform order programs
* Delivery agency programs
* Printer port contention
* COM port lock
* USB printer lock
* Network printer contention
* Printer driver shared mode
* Local resource ownership
* Platform order routing decision
* POS endpoint selection
* Malicious manual POS cancellation
* Unauthorized POS-side void
* Store-side sales manipulation
* Manual mutation timeline defense
* Legal and provider dispute evidence
* Audit evidence for routing and manual mutation events

This policy applies to all stores where one platform store context may map to more than one POS endpoint, printer route, sales channel, business entity, or local execution path.

## 3. Core Principle

A store is not always one POS endpoint.

A POS PC is not always dedicated to the platform.

A POS-side manual cancellation is not always a platform-authorized cancellation.

The POS Gateway must distinguish:

* Platform store ID
* Physical store
* Legal business entity
* Operating group
* POS endpoint
* Sales channel
* Printer route
* Delivery app route
* Local program resource owner
* Platform-authorized mutation
* POS-local manual mutation
* Malicious or suspicious mutation

The system must not collapse all store-side events into one trusted POS truth.

## 4. Routing And Local Resource Boundary

A single platform store may route to multiple execution endpoints.

```
[Platform Store Context]
          |
          v
[Gateway Routing Virtualization Layer]
          |
  -------------------------------------
  |                 |                 |
  v                 v                 v
[Hall POS]      [Delivery POS]    [Takeout POS]
  |                 |                 |
  v                 v                 v
[Printer A]     [Printer B]      [Shared Printer]
```

The Gateway must choose route based on order type, channel, business entity, table context, payment context, and store configuration.

## 5. Non-Negotiable Rules

### 5.1 Store ID Is Not POS Endpoint Rule

A platform store ID must not be treated as equivalent to one POS endpoint.

The Gateway must support one-to-many mapping between platform store context and POS endpoints.

### 5.2 Routing Decision Must Be Explicit Rule

Every POS submission must record why a specific endpoint, printer, sales channel, and business entity were selected.

The route must not be inferred silently from default store settings when multiple endpoints exist.

### 5.3 Third-Party Local Programs Must Be Treated As Resource Competitors Rule

Delivery apps, dispatch programs, printer utilities, vendor bridges, and POS add-ons may compete for CPU, memory, network, COM ports, USB devices, printer drivers, and local databases.

The Gateway must not assume it controls local resources exclusively.

### 5.4 POS-Local Manual Mutation Is Not Platform Authorization Rule

A POS-side cancellation, void, discount, receipt deletion, or business day adjustment must not be treated as platform-authorized unless it is correlated to a platform-approved action or manual recovery event.

### 5.5 Suspicious Mutation Must Be Preserved Rule

If a store-side manual mutation appears to reduce sales, avoid fees, alter settlement, or contradict platform payment evidence, the Gateway must preserve immutable evidence and classify the mutation for review.

## 6. POS Endpoint Types

A store may have multiple POS endpoint types.

Allowed endpoint categories include:

```
HALL_POS
TABLE_ORDER_POS
TAKEOUT_POS
DELIVERY_POS
KIOSK_POS
WAITING_HANDOFF_POS
PREORDER_POS
FRANCHISE_PROMOTION_POS
SHARED_KITCHEN_POS
CLOUD_KITCHEN_POS
MANUAL_FALLBACK_POS
PRINTER_ONLY_ENDPOINT
UNKNOWN_POS_ENDPOINT
```

Each endpoint must have a capability profile and routing rule.

## 7. Endpoint Registry

The POS endpoint registry should include:

```
pos_endpoint_id
platform_store_id
tenant_id
legal_entity_id
operating_group_id
business_entity_code
provider_id
endpoint_type
endpoint_name
integration_mode
sales_channel
payment_collector
printer_route_id
table_scope
menu_scope
order_type_scope
active_flag
priority
fallback_endpoint_id
effective_from
effective_until
approved_by
approved_at
```

Endpoint registry must be versioned.

Historical orders must reference the endpoint version used at submission time.

## 8. Routing Decision Inputs

Routing decisions may use:

* Store ID
* Order channel
* Order type
* Dine-in or takeout
* Waiting session
* Table context
* Delivery context
* Pickup context
* Payment collector
* Sales channel
* Legal entity
* Business entity
* Menu category
* Kitchen station
* Provider capability
* Endpoint health
* Endpoint business day state
* Printer availability
* Operator override
* Fallback mode

Routing decisions must be deterministic and auditable.

## 9. Routing Decision Outcomes

Allowed routing outcomes include:

```
ROUTE_TO_PRIMARY_ENDPOINT
ROUTE_TO_CHANNEL_ENDPOINT
ROUTE_TO_LEGAL_ENTITY_ENDPOINT
ROUTE_TO_DELIVERY_ENDPOINT
ROUTE_TO_TAKEOUT_ENDPOINT
ROUTE_TO_HALL_ENDPOINT
ROUTE_TO_PRINTER_ONLY
ROUTE_TO_MANUAL_FALLBACK
ROUTE_TO_FALLBACK_ENDPOINT
HOLD_FOR_OPERATOR_ROUTING
BLOCK_UNROUTABLE_ORDER
ROUTING_CONFLICT_DETECTED
```

Each outcome must preserve route evidence.

## 10. Multi-Business-Entity Store

Some physical stores or shared kitchens may operate multiple business entities.

Examples:

* Hall business entity uses POS A
* Delivery business entity uses POS B
* Takeout brand uses POS C
* Shared kitchen has multiple tenants
* Franchise and owner-operated channels are separated
* Alcohol or taxable category uses separate business entity

The Gateway must preserve which legal entity, operating group, business entity, and sales channel owns the order and payment.

Routing must not send an order to the wrong entity’s POS.

## 11. Delivery App Coexistence

Store POS PCs may run multiple third-party programs.

Examples:

* Baemin order receiver
* Yogiyo order receiver
* Coupang Eats order receiver
* Delivery agency dispatch program
* Rider dispatch utility
* VAN utility
* Printer utility
* POS vendor updater
* Remote support tool

These programs may consume CPU, memory, network, local database locks, printer ports, or printer queues.

The platform local agent must observe resource contention where possible and must avoid assuming exclusive access.

## 12. Port And Printer Contention

Local hardware contention may occur when:

* Third-party app holds COM port
* Printer driver is locked
* USB printer is busy
* Network printer queue is blocked
* Windows spooler is stuck
* Multiple programs send ESC/POS commands concurrently
* Delivery app prints long receipt during platform print
* POS app uses exclusive printer mode
* Local agent lacks driver permission
* Printer buffer contains stale commands

The Gateway must classify printer or port contention separately from generic print failure.

## 13. Printer Resource Ownership

Each printer path should declare resource ownership mode.

Allowed modes include:

```
POS_EXCLUSIVE
PLATFORM_EXCLUSIVE
SHARED_DRIVER_MODE
SHARED_NETWORK_MODE
DELIVERY_APP_SHARED
WINDOWS_SPOOLER_SHARED
LOCAL_AGENT_MEDIATED
PROVIDER_MEDIATED
UNKNOWN_OWNERSHIP
```

Unknown or exclusive ownership requires stricter readiness testing.

## 14. Shared Mode Requirements

If shared printing is allowed, the system must define:

* Queue ownership
* Print job identity
* Printer lock timeout
* Retry policy
* Duplicate print defense
* Job ordering
* Error classification
* Printer busy handling
* Third-party contention detection
* Operator recovery
* Audit evidence

Shared mode must not allow uncontrolled interleaving of kitchen tickets.

## 15. Local Resource Health Signals

Where permitted, the local agent may collect:

```
cpu_usage_percent
memory_usage_percent
printer_queue_depth
printer_busy_flag
port_lock_detected_flag
windows_spooler_status
pos_app_process_status
delivery_app_process_count
local_socket_error_count
printer_driver_error_count
last_successful_print_at
last_port_contention_at
```

Collection must respect security, provider contract, and privacy boundaries.

## 16. Port Contention State Classification

Allowed contention states include:

```
NO_CONTENTION
PRINTER_BUSY
COM_PORT_LOCKED
USB_DEVICE_BUSY
NETWORK_PRINTER_BUSY
WINDOWS_SPOOLER_STUCK
THIRD_PARTY_APP_LOCK
POS_APP_LOCK
DELIVERY_APP_LOCK
UNKNOWN_PORT_CONTENTION
RESOURCE_CONTENTION_RECOVERED
```

Contention state must be visible in operator console and audit when it affects order execution.

## 17. Route Health And Fallback

Each POS endpoint and printer route must have health state.

Allowed route health states include:

```
ROUTE_HEALTHY
ROUTE_DEGRADED
ROUTE_UNREACHABLE
ROUTE_PRINTER_BLOCKED
ROUTE_BUSINESS_DAY_CLOSED
ROUTE_PAYMENT_UNAVAILABLE
ROUTE_MENU_MAPPING_INVALID
ROUTE_MANUAL_ONLY
ROUTE_DISABLED
ROUTE_UNKNOWN
```

When primary route is unhealthy, the Gateway may use fallback only if the fallback route preserves legal entity, payment, tax, kitchen, and audit integrity.

## 18. Fallback Routing Rules

Fallback routing may be allowed when:

* Primary endpoint is down
* Printer route is blocked
* Delivery endpoint unavailable
* Hall endpoint unavailable
* Provider circuit is open
* Operator approves manual fallback
* Customer-facing state supports delay

Fallback routing must not:

* Send order to wrong legal entity
* Misclassify sales channel
* Lose payment collector identity
* Break table context
* Duplicate kitchen ticket
* Bypass tax mapping
* Hide provider outage

Fallback routing must be audited.

## 19. POS-Local Manual Mutation Categories

Manual POS mutation may be accidental or intentional.

Allowed categories include:

```
MANUAL_POS_CANCEL
MANUAL_POS_VOID
MANUAL_POS_REFUND
MANUAL_POS_DISCOUNT
MANUAL_POS_RECEIPT_DELETE
MANUAL_POS_PAYMENT_METHOD_CHANGE
MANUAL_POS_SALES_CHANNEL_CHANGE
MANUAL_POS_BUSINESS_DAY_CHANGE
MANUAL_POS_TABLE_CHANGE
MANUAL_POS_REPRINT
MANUAL_POS_PRICE_OVERRIDE
MANUAL_POS_UNPAID_CONVERSION
UNKNOWN_MANUAL_MUTATION
```

Each mutation must be correlated to platform action if possible.

## 20. Authorized Vs Unauthorized Mutation

A POS-local mutation may be classified as:

```
PLATFORM_AUTHORIZED
OPERATOR_AUTHORIZED_RECOVERY
STORE_AUTHORIZED_WITH_REASON
POS_NATIVE_OPERATION
UNKNOWN_AUTHORITY
SUSPICIOUS_MUTATION
PROHIBITED_MUTATION
MALICIOUS_MANIPULATION_SUSPECTED
```

Authority classification must influence settlement, provider dispute, and legal evidence handling.

## 21. Malicious Manual Mutation Defense

Malicious or suspicious mutation may include:

* Canceling platform-paid POS orders near closing
* Voiding receipts without platform refund
* Applying unauthorized discount after settlement
* Converting paid order to unpaid
* Deleting receipt after platform fee calculation
* Changing sales channel to avoid fee
* Moving order to another business entity
* Reprinting or recreating receipt with different amount
* Closing business day to hide transaction timing

The Gateway must preserve original platform evidence and later POS mutation evidence separately.

The POS mutation must not rewrite history.

## 22. Manual Mutation Timeline

For every POS-local mutation after platform acceptance, the Gateway must reconstruct:

* Original platform order creation
* Payment approval
* POS submission
* POS ACK
* POS receipt creation
* Kitchen print or execution
* Later POS-local mutation
* Actor, if available
* Time gap
* Provider event source
* Settlement impact
* Customer impact
* Platform authorization status

This timeline is the dispute defense record.

## 23. Suspicious Mutation Triggers

A suspicious mutation flag may be raised when:

* POS order canceled after platform payment but no platform refund exists
* POS void occurs without matching platform cancel
* POS receipt amount changes after platform settlement
* POS channel changes after order completion
* Repeated end-of-day POS cancellations occur
* Manual unpaid conversion occurs after PG payment
* Store mutation pattern differs from normal behavior
* Mutation occurs after business day close
* Mutation removes platform fee basis
* Mutation conflicts with immutable platform audit

Suspicion must not automatically accuse the store, but it must preserve evidence and require review.

## 24. Settlement Impact Handling

Manual mutation may affect:

* Store sales total
* Platform commission
* Franchise fee
* VAT classification
* PG settlement
* VAN settlement
* Refund liability
* Customer receipt
* Tax reporting
* Inventory consumption
* Kitchen production evidence

The Gateway must classify settlement impact and route cases to finance review when needed.

## 25. Mutation Reconciliation Outcomes

Allowed outcomes include:

```
ACCEPT_MUTATION_WITH_EVIDENCE
REJECT_MUTATION_FOR_PLATFORM_SETTLEMENT
REQUIRE_STORE_REASON
REQUIRE_MANAGER_APPROVAL
REQUIRE_FINANCE_REVIEW
REQUIRE_PROVIDER_DISPUTE
LINK_TO_PLATFORM_CANCEL
LINK_TO_PLATFORM_REFUND
MARK_SUSPICIOUS_PATTERN
MARK_MALICIOUS_SUSPECTED
PRESERVE_FOR_LEGAL_REVIEW
```

Outcome must not delete original evidence.

## 26. Legal And Dispute Evidence Requirements

For dispute defense, the Gateway must preserve:

* Original customer intent
* Platform order approval
* Payment approval
* POS submission evidence
* POS ACK evidence
* POS receipt evidence
* Kitchen evidence, if applicable
* Later POS mutation evidence
* Provider raw packet reference
* Operator action
* Customer notification
* Settlement calculation before mutation
* Settlement calculation after mutation
* Authority classification
* Review outcome

Evidence must be immutable, access-controlled, and retention-managed.

## 27. Operator And Finance Console Requirements

The console must show:

* Endpoint routing decision
* POS endpoint selected
* Fallback endpoint used
* Business entity selected
* Sales channel selected
* Printer route selected
* Port contention state
* Third-party resource contention warning
* POS-local manual mutations
* Unauthorized mutation warnings
* Suspicious mutation timeline
* Settlement impact
* Required review owner
* Evidence status

Allowed actions may include:

```
APPROVE_FALLBACK_ROUTE
BLOCK_ENDPOINT
SWITCH_ENDPOINT
MARK_PORT_CONTENTION
CONFIRM_SHARED_PRINTER_RECOVERY
LINK_MUTATION_TO_PLATFORM_CANCEL
LINK_MUTATION_TO_PLATFORM_REFUND
REQUEST_STORE_REASON
REQUIRE_MANAGER_APPROVAL
ESCALATE_FINANCE_REVIEW
ESCALATE_PROVIDER_DISPUTE
MARK_SUSPICIOUS_MUTATION_RESOLVED
PRESERVE_LEGAL_EVIDENCE
```

All actions must be audited.

## 28. Customer-Facing Messaging

Customer-facing messaging must remain simple and not expose dispute logic.

Examples:

```
The store is confirming your order.
The store is updating this order.
Your order has been canceled by the store.
A refund is being processed.
The store is reviewing this order.
```

Customer-facing messages must not expose fraud suspicion, malicious mutation classification, printer port contention, third-party app conflicts, or legal review state.

## 29. Audit Requirements

Every routing, resource contention, and manual mutation event must preserve:

* Platform order ID
* Store ID
* Tenant ID
* Legal entity ID, if applicable
* Operating group ID, if applicable
* POS endpoint ID
* Provider ID
* Sales channel
* Payment collector
* Printer route ID
* Route decision
* Route decision inputs
* Fallback route, if used
* Resource contention state
* Third-party contention indicator, if available
* Manual mutation category
* Authority classification
* Suspicion state
* Settlement impact
* Original POS receipt reference
* Mutated POS receipt reference
* Payment reference
* Refund reference, if applicable
* Customer notification reference, if applicable
* Operator action, if any
* Finance review reference, if any
* Legal evidence reference, if applicable
* Raw packet ID, if applicable
* Trace ID
* Correlation ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive store, customer, payment, device, and legal evidence must be redacted, tokenized, encrypted, or access-restricted according to the security runtime policy.

## 30. Test Requirements

Each multi-endpoint or local resource integration must test:

* Single endpoint normal route
* Multi-endpoint route by order type
* Route by sales channel
* Route by legal entity
* Route by table context
* Route by delivery or takeout context
* Primary endpoint down
* Fallback endpoint allowed
* Fallback endpoint blocked by legal entity mismatch
* Printer shared mode
* Printer exclusive mode
* COM port locked
* Windows spooler stuck
* Delivery app print contention
* POS app print contention
* Third-party program resource pressure
* Manual POS cancel after platform acceptance
* Manual POS void after PG payment
* Manual POS discount after settlement
* Manual unpaid conversion
* Suspicious end-of-day cancellation
* Mutation linked to platform refund
* Mutation not linked to platform action
* Finance review escalation
* Audit preservation for routing and mutation evidence

A store cannot be production-ready for multi-endpoint or shared local resource mode without routing, contention, and manual mutation defense test evidence.

## 31. Anti-Patterns

The following are prohibited:

* Assuming one platform store equals one POS endpoint
* Routing orders by store ID alone when multiple endpoints exist
* Sending fallback order to wrong legal entity
* Ignoring sales channel during route selection
* Treating all POS-local cancellations as platform-approved
* Letting later POS mutation overwrite original platform evidence
* Ignoring printer port contention caused by third-party apps
* Assuming the platform owns the printer exclusively
* Hiding suspicious manual mutation from finance review
* Accusing a store without preserving evidence and review process
* Deleting original receipt evidence after mutation
* Exposing malicious mutation suspicion to customers

## 32. Relationship With Other Documents

This policy depends on and supports:

```
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
05440 POS VAN PG Tax Sales Channel And Unpaid Order Reconciliation Policy
05450 POS External API Isolation NonBlocking IO And Connection Pool Protection Policy
05460 POS Polling WebSocket MQTT And Agent Realtime Channel Cost Control Policy
05470 POS InDoubt Transaction Network Cancel Receipt Number And Financial Reconciliation Policy
```

Multi-endpoint routing and malicious mutation defense is the legal, operational, and settlement shield of the POS Gateway.

## 33. Final Rule

The POS Gateway must always be able to explain which POS endpoint, business entity, sales channel, printer route, and payment collector were selected, why they were selected, what local resources were contested, and whether any later POS-local mutation was authorized, suspicious, or settlement-impacting.

If a physical store’s multiple POS endpoints, delivery applications, shared printer ports, and manual POS mutations can alter execution or settlement without routing evidence, resource contention evidence, and immutable mutation timeline, the multi-endpoint and manual mutation defense boundary has failed.
