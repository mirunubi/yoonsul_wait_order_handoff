# 14002_Readme_POS_Gateway_Resilience_Field_Exception_Catalog

## 1. Purpose

This catalog defines the resilience, exception handling, field operation, and full F&B journey integrity boundary for the POS Gateway and Virtual POS abstraction layer.

The purpose of this band is to ensure that external POS systems, kitchen printers, local network devices, store-side manual operations, payment mismatches, API failures, waiting and entry state drift, inventory race conditions, legacy hardware instability, VAN/PG settlement differences, and provider-specific data irregularities do not contaminate the core order, payment, settlement, kitchen execution, customer journey, and audit state of the platform.

The POS Gateway must act as an orchestration, validation, isolation, and recovery layer between the Catch Menu / Yoonsul core system and external POS environments.

## 2. Scope

This catalog covers:

* POS provider adapter boundary
* Virtual POS interface abstraction
* POS menu hierarchy and option transformation
* Master data synchronization and pre-check validation
* Payment, tax, discount, refund, and reconciliation mismatch handling
* Kitchen printer delegation and direct-print boundary
* Local agent, hardware heartbeat, and network disappearance handling
* POS API rate limit, timeout, circuit breaker, throttling, and queue protection
* Idempotency and duplicate order prevention
* Manual POS reentry defense
* Business day close, table move, table merge, and table split synchronization
* Raw packet schema validation and provider spec drift defense
* Waiting, entry, no-show, manual entry, and table assignment synchronization
* Prepaid waiting cancellation, POS cancellation, kitchen cancellation, and refund coordination
* Legacy POS hardware, operating system, POS app restart, local execution gap, and adaptive timeout handling
* Inventory race condition, last-item conflict, stock hold, and stock release handling
* VAN, PG, POS, sales channel, tax, unpaid order, service order, and house account reconciliation
* Immutable audit evidence for all POS Gateway transitions

## 3. Core Principle

The POS Gateway must protect the core system from external POS disorder and real store field disorder.

External POS systems must be treated as unstable, provider-specific, operationally inconsistent, and subject to change.

Store environments must also be treated as unreliable unless verified. POS PCs may sleep, local agents may disappear, printers may fail, routers may reboot, staff may manually reenter orders, tables may move, business days may close late, inventory may sell out between sync events, and payment records may split across PG, VAN, POS, cash, coupon, point, and house account channels.

The core system must not directly depend on any single POS provider’s menu structure, table structure, printer behavior, payment rounding rule, API response format, business day model, sales channel model, or operational timing.

All provider-specific and field-specific behavior must be absorbed by the POS Gateway, adapter, transformer, validation, queue, circuit breaker, idempotency, local health, inventory hold, settlement reconciliation, and audit layers.

## 4. Architectural Position

The POS Gateway sits between the core order/payment domain and external POS, local store, kitchen, payment, and settlement systems.

```
[Core Order / Payment / Settlement / Kitchen / Audit Domain]
                          |
                          v
    [POS Gateway And Virtual POS Abstraction Layer]
                          |
      -------------------------------------------------
      |                    |                          |
      v                    v                          v
[Modern POS Provider]  [Legacy POS Provider]  [Local Store Devices]
                                               |
                                        ----------------
                                        |              |
                                        v              v
                                  [Kitchen Printer] [POS PC / Agent]
```

The Gateway is not a simple pass-through interface.

It is responsible for:

* Contract validation
* Provider adaptation
* Order transformation
* Menu and table mapping
* Payment pre-check
* Master data validation
* Duplicate prevention
* Retry and queue control
* Circuit breaker protection
* Kitchen print boundary separation
* Local device health detection
* Waiting and entry state synchronization
* Inventory hold and stock race defense
* VAN/PG/POS reconciliation
* Raw packet evidence preservation
* Field exception classification
* Operator recovery visibility

## 5. Non-Negotiable Rules

### 5.1 Core Immutability Rule

The core order, payment, settlement, kitchen, customer journey, and audit logic must not be modified when a new POS provider is added.

New POS providers must be integrated by adding or extending:

* Provider adapter
* Provider capability profile
* Menu transformer
* Table transformer
* Payment mapping rule
* Validation rule
* Printer boundary rule
* Local agent rule, if applicable
* Inventory hold rule, if applicable
* Sales channel mapping rule
* Provider-specific test catalog

### 5.2 Reject Before Core Rule

Malformed, unexpected, incomplete, unauthorized, or schema-drifted external POS packets must be rejected or quarantined before entering the core domain.

The core system must never normalize corrupted external packets by assumption.

### 5.3 POS ACK Is Not Kitchen Print Success

A POS order acceptance response does not prove that a kitchen printer successfully printed the order ticket.

The Gateway must record separate evidence for:

* Order submission attempt
* POS ACK response
* POS rejection response
* Printer delegation boundary
* Direct print attempt, if applicable
* Printer status, if known
* Store-side recovery event

### 5.4 POS Provider Failure Must Not Kill The Gateway

When a POS provider API slows down, times out, rate-limits, or fails, the Gateway must isolate the failure.

The Gateway must support:

* Timeout classification
* Circuit breaker state
* Queueing
* Retry backoff
* Throttling
* Customer-facing pending status
* Operator-visible recovery state
* Audit-visible order preservation

### 5.5 Payment Mismatch Must Stop Before Approval

If the amount calculated by the core system and the amount validated through the POS layer do not match beyond the permitted tolerance, payment approval must be blocked or placed into a controlled exception state.

The Gateway must not silently approve mismatched payment requests.

### 5.6 Waiting State Must Not Drift From Table State

Waiting, entry, no-show, table assignment, POS table occupancy, prepaid order, kitchen execution, and refund state must remain correlated.

The system must not call the next waiting team into an occupied table or refund a prepaid waiting order without checking POS and kitchen execution state.

### 5.7 Local Store Health Is Separate From Provider Health

A POS provider cloud API may be healthy while the store POS app is frozen, restarted, overloaded, or unreachable.

The Gateway must distinguish provider failure from local POS PC, local agent, printer, router, socket, CPU, and application restart failure.

### 5.8 Last-Item Stock Must Be Protected

When inventory is limited, stale sold-out cache is not enough.

The Gateway must use validation, hold, expiration, release, manual confirmation, or refund flow to prevent two channels from selling the same last item.

### 5.9 Sales Channel And Payment Collector Must Be Explicit

Platform PG payment, store VAN payment, POS receipt, cash, coupon, point, service order, unpaid order, and house account must not be collapsed into one ambiguous payment state.

The system must preserve who collected the money, which system recorded the sale, and which channel should be reconciled.

## 6. Field Exception Categories

The 05300 band recognizes the following field exception categories.

### 6.1 Menu And Option Exceptions

Examples:

* Legacy POS requires flattened menu codes
* Option combinations exist as separate product codes
* Modern POS supports option group trees
* POS menu code does not match core menu item
* POS option price differs from core option price
* POS does not support required option structure
* Store-specific menu codes differ for the same platform menu item

### 6.2 Master Data Exceptions

Examples:

* Price changed in POS but not yet synchronized
* Sold-out state changed in POS before platform cache refresh
* POS master sync is available only after store opening
* Webhook is delayed or missing
* POS provider cannot expose real-time stock state
* Platform cache is stale during payment attempt

### 6.3 Payment And Reconciliation Exceptions

Examples:

* Split payment between prepaid and on-site POS payment
* POS-side discount applied after order submission
* Promotion mismatch
* VAT rounding mismatch
* Service charge mismatch
* PG amount and POS sales amount mismatch
* Daily settlement mismatch
* POS void not reflected in PG
* PG refund not reflected in POS

### 6.4 Kitchen Printer Exceptions

Examples:

* POS accepted order but did not print kitchen ticket
* POS application is frozen or backgrounded
* Printer is offline
* Printer IP changed
* ESC/POS command is unsupported
* Printed ticket is garbled
* Duplicate ticket printed after retry
* Cancel ticket did not reach kitchen

### 6.5 Hardware And Local Network Exceptions

Examples:

* POS PC sleep mode
* Local middleware stopped
* Store router rebooted
* POS internal IP changed
* Network printer disappeared
* Gateway cannot reach local agent
* Heartbeat missing
* POS app forced restart
* CPU saturation on legacy POS PC
* Local socket timeout or connection pool pressure

### 6.6 Peak Traffic And Provider API Exceptions

Examples:

* Provider API returns 429 Too Many Requests
* Provider API response exceeds timeout threshold
* Provider API returns intermittent 5xx errors
* Lunch peak creates request burst
* Queue grows beyond safe threshold
* Retry storm risk
* Provider status query becomes unreliable

### 6.7 Human Operation Exceptions

Examples:

* Store staff manually reentered a delayed order
* Store staff canceled or modified an order directly in POS
* Store staff changed sold-out state manually
* Business day was closed late
* Table was moved or merged directly in POS
* Store operator reprinted or voided order without Gateway awareness
* Staff verbally admitted a waiting customer without platform confirmation

### 6.8 Provider Contract Drift Exceptions

Examples:

* API field renamed
* Required field removed
* New enum value added
* Response format changed
* Discount field semantics changed
* Provider sends undocumented error code
* Amount field appears with changed meaning

### 6.9 Waiting And Entry Journey Exceptions

Examples:

* Customer was called but not confirmed as entered
* No-show customer was manually admitted
* POS table state says occupied while platform says available
* Platform calls next waiting team too early
* Prepaid waiting order is canceled after kitchen ticket was printed
* Waiting session, table, order, payment, and kitchen state lose correlation

### 6.10 Inventory Race Exceptions

Examples:

* Last item is sold through POS and platform at nearly the same time
* Sold-out webhook is delayed
* Stock hold expires but order continues
* Kitchen discovers shortage after payment
* Ingredient shared by multiple menu items runs out
* Queue replay submits an order after stock is gone

### 6.11 VAN / PG / Tax / Sales Channel Exceptions

Examples:

* Platform PG sale is also counted as store VAN card sale
* POS receipt lacks smart-order channel mapping
* Store VAN payment exists without platform payment
* Platform PG payment exists without POS receipt
* Unpaid order is treated as error
* Service order is treated as canceled
* House account is lost because no immediate payment exists
* Duplicate taxation risk appears during day-end reconciliation

## 7. Relationship With Other Catalogs

This catalog depends on and complements the following documentation areas.

### 7.1 04900 Security Runtime Test Catalog

The 04900 band defines runtime security, audit, and controlled verification principles.

The 05300 band applies those principles specifically to POS Gateway field resilience, POS provider exception handling, local infrastructure disorder, customer journey disorder, and settlement integrity.

### 7.2 05100 Implementation Readiness And Evidence Handoff

The 05100 band defines readiness, ownership, implementation entry, and evidence handoff policies.

The 05300 band provides the field exception scenarios that must be covered before POS Gateway implementation can be considered production-ready.

### 7.3 POS / KDS / Payment Provider Integration Bands

The 05300 band does not replace provider-specific integration documents.

Instead, it defines the common resilience and exception handling rules that all provider-specific integration documents must follow.

### 7.4 Waiting / Handoff / Table Journey Documents

The 05300 band provides the POS Gateway-facing exception layer for waiting, entry, prepaid cancellation, table assignment, table move, and handoff flows.

It does not replace the customer journey product policy, but it defines how the journey must remain consistent with POS, payment, kitchen, and audit state.

### 7.5 Finance / Settlement / Tax Documents

The 05300 band provides the POS Gateway-facing evidence layer for PG, VAN, POS, unpaid, service, house account, sales channel, and tax reconciliation.

It does not replace final accounting policy, but it ensures that finance has complete evidence to reconcile and classify transactions.

## 8. Required Evidence

Every POS Gateway integration must produce evidence for:

* Provider capability profile
* Adapter contract
* Adapter version
* Provider contract snapshot
* Menu transformation rule
* Table transformation rule
* Master data validation rule
* Price and sold-out validation rule
* Payment mismatch handling
* VAT, discount, coupon, point, and service charge handling
* Split payment handling
* Sales channel mapping
* Payment collector mapping
* Unpaid and service order classification
* Kitchen print boundary
* POS ACK capture
* Direct print rule, if applicable
* Local agent heartbeat rule
* Legacy hardware profile, if applicable
* Adaptive timeout profile
* Timeout and retry behavior
* Circuit breaker behavior
* Queue preservation and replay behavior
* Idempotency and duplicate order defense
* Manual POS reentry defense
* Business day and table state sync rule
* Waiting and entry sync rule
* Prepaid cancellation and kitchen cancellation rule
* Inventory hold and release rule
* Stock race condition handling
* Raw packet schema validation
* Provider spec drift rejection
* Operator recovery path
* Customer-facing pending and failure message
* Audit event mapping
* Test fixtures for all production-critical exception paths

## 9. Active File List

This catalog contains the following active documents.

05300_POS_Gateway_Resilience_And_Field_Exception_Catalog_Readme.md

05310_POS_Gateway_Interface_Abstraction_And_Adapter_Boundary_Policy.md

05320_POS_Menu_Hierarchy_Option_Transformer_Policy.md

14008_Policy_POS_Master_Data_Sync_And_Precheck_Validation.md

14010_Policy_POS_Payment_Tax_Discount_And_Reconciliation_Mismatch.md

05350_Policy_POS_Kitchen_Printer_Delegation_And_Direct_Printing_Boundary.md

14013_Policy_POS_Hardware_Heartbeat_Local_Agent_And_Network_Disappearance.md

14015_Policy_POS_Circuit_Breaker_Queue_And_Rate_Limit_Protection.md

14017_Policy_POS_Idempotency_Duplicate_Order_And_Manual_Reentry_Defense.md

14019_Policy_POS_Business_Day_Close_Table_Move_And_Field_Operation_Sync.md

14022_Policy_POS_Schema_Validation_Raw_Packet_Audit_And_Spec_Drift_Defense.md

05410_Policy_POS_Waiting_Entry_NoShow_And_Prepaid_Cancel_Sync.md

14025_Policy_POS_Legacy_Hardware_OS_Adaptive_Timeout_And_App_Restart.md

14027_Policy_POS_Inventory_Race_Condition_And_Stock_Hold_Buffer.md

14029_Policy_POS_VAN_PG_Tax_Sales_Channel_And_Unpaid_Order_Reconciliation.md

## 10. File Purpose Summary

### 10.1 05310 POS Gateway Interface Abstraction And Adapter Boundary Policy

Defines the Virtual POS interface, provider adapter boundary, provider capability profile, adapter isolation, provider error normalization, unsupported feature handling, and provider onboarding checklist.

Core question:

Can a new POS provider be integrated by adding an adapter without rewriting core order, payment, settlement, or audit logic?

### 10.2 05320 POS Menu Hierarchy Option Transformer Policy

Defines how the Gateway transforms the platform’s rich menu, variant, option group, option item, and price model into provider-specific POS menu structures.

Core question:

Can legacy flat-code POS and modern option-tree POS both be supported without weakening the core menu model?

### 10.3 05330 POS Master Data Sync And Precheck Validation Policy

Defines menu, price, option, sold-out, table, and store acceptance validation before risky order or payment transitions.

Core question:

Can the Gateway prevent payment or order submission when POS master data, price, sold-out, or table state is stale or contradictory?

### 10.4 05340 POS Payment Tax Discount And Reconciliation Mismatch Policy

Defines handling for payment amount mismatch, tax/VAT rounding, discount conflict, coupon, point, split payment, refund, void, and day-end reconciliation.

Core question:

Can the Gateway explain and control every monetary difference between platform, POS, and PG records?

### 10.5 05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy

Defines POS-delegated kitchen printing, direct ESC/POS printing, print uncertainty, print retry, duplicate ticket prevention, and kitchen recovery.

Core question:

Can the Gateway distinguish POS order acceptance from actual kitchen ticket delivery?

### 10.6 05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy

Defines local agent heartbeat, POS PC reachability, printer reachability, IP change, network disappearance, local queue, reconnect, and device binding.

Core question:

Can the Gateway tell whether failure came from provider cloud, local agent, POS PC, printer, router, or unknown store network failure?

### 10.7 05370 POS Circuit Breaker Queue And Rate Limit Protection Policy

Defines circuit breaker, queueing, retry, throttling, provider 429, provider timeout, provider outage, retry storm prevention, and customer pending state.

Core question:

Can the Gateway survive POS provider instability without losing orders, duplicating operations, or collapsing with the provider?

### 10.8 05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy

Defines idempotency, duplicate order prevention, duplicate payment prevention, duplicate print prevention, queue replay defense, webhook deduplication, and staff manual POS reentry handling.

Core question:

Can the Gateway prevent delayed retries, local replays, customer resubmissions, provider webhooks, and manual reentry from producing duplicate operational execution?

### 10.9 05390 POS Business Day Close Table Move And Field Operation Sync Policy

Defines POS business day, after-midnight order handling, table ID mapping, table move, table merge, table split, manual POS mutation, and field operation sync.

Core question:

Can the Gateway distinguish platform date from POS business date, customer table label from POS table ID, and platform action from store-side manual POS mutation?

### 10.10 05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy

Defines provider packet validation, raw evidence preservation, schema drift detection, unknown field handling, missing field handling, enum drift, amount drift, status drift, and quarantine.

Core question:

Can the Gateway prevent malformed or changed provider packets from corrupting core state?

### 10.11 05410 POS Waiting Entry NoShow And Prepaid Cancel Sync Policy

Defines waiting registration, entry confirmation, no-show, manual entry, table assignment, prepaid waiting order, prepaid cancellation, POS cancellation, kitchen cancellation, and refund coordination.

Core question:

Can the Gateway preserve the full waiting-to-entry-to-order journey without table drift, overbooking, unpaid kitchen execution, or refund ambiguity?

### 10.12 05420 POS Legacy Hardware OS Adaptive Timeout And App Restart Policy

Defines low-spec POS PC handling, legacy Windows environment, POS app freeze, forced restart, CPU saturation, socket timeout, local execution gap, and adaptive timeout profile.

Core question:

Can the Gateway distinguish slow local POS execution from provider failure and tune timeout behavior without losing orders, duplicating submissions, or exhausting Gateway resources?

### 10.13 05430 POS Inventory Race Condition And Stock Hold Buffer Policy

Defines last-item race, POS-side manual stock conflict, platform stock hold, hold expiration, stock release, sold-out timing gap, ingredient-level stock, and kitchen-discovered shortage.

Core question:

Can the Gateway prevent two channels from selling the same limited item without controlled hold, validation, conflict resolution, and audit evidence?

### 10.14 05440 POS VAN PG Tax Sales Channel And Unpaid Order Reconciliation Policy

Defines platform PG, store VAN, POS receipt, sales channel mapping, payment collector identity, VAT, tax, unpaid order, service order, house account, and duplicate taxation prevention.

Core question:

Can the Gateway separate and reconcile platform PG sales, store VAN sales, POS receipts, unpaid orders, service orders, and tax records without duplicate counting?

## 11. Implementation Readiness Rule

No POS provider integration should be treated as implementation-ready unless the provider can be mapped against the 05300 catalog.

At minimum, each provider must have defined answers for:

1. How the provider adapter boundary is isolated from the core
2. How the provider capability profile is declared
3. How menu and option structures are transformed
4. How price and sold-out state are validated before payment
5. How POS ACK is captured
6. How kitchen print responsibility is separated
7. How local device, local agent, POS PC, printer, and router health are tracked
8. How timeout, rate limit, circuit breaker, queue, and retry behavior are handled
9. How duplicate order, duplicate payment, duplicate print, and manual POS reentry are prevented
10. How business day and table state changes are synchronized
11. How provider schema drift is rejected before core contamination
12. How waiting, entry, no-show, manual entry, and table assignment are synchronized
13. How prepaid cancellation propagates to POS cancellation, kitchen stop, refund, and operator recovery
14. How legacy POS hardware and POS app restart gaps are detected and recovered
15. How inventory race, last-item conflict, stock hold, and stock release are handled
16. How platform PG, store VAN, POS receipt, sales channel, unpaid order, service order, and tax records are reconciled
17. How every field exception is preserved as immutable audit evidence

## 12. Production Readiness Questions

No waiting-to-order, table-order, prepaid, or POS-connected flow should be treated as production-ready unless it can answer the following questions.

### 12.1 Adapter And Contract Questions

* Can a new POS provider be added without modifying core business logic?
* Does the provider have a capability profile?
* Does the adapter have a versioned contract snapshot?
* Can malformed provider packets be rejected before core state changes?
* Can unknown fields, missing fields, and enum drift be handled safely?

### 12.2 Menu And Master Data Questions

* Can the Gateway transform rich platform menu data into provider-compatible structures?
* Can legacy flattened menu codes and modern option trees both be supported?
* Can the Gateway validate menu, option, price, sold-out, table, and store acceptance state before payment or order submission?
* Can stale cache be detected and handled?

### 12.3 Payment And Settlement Questions

* Can platform amount, POS amount, PG amount, refund amount, and settlement amount be compared?
* Can split payment be represented without double counting?
* Can POS-side discount and platform-side promotion conflict be reconciled?
* Can VAT and rounding mismatches be explained?
* Can platform PG and store VAN payments be separated?
* Can unpaid, service, house account, and zero-amount orders be classified?

### 12.4 Kitchen And Local Device Questions

* Can POS order acceptance be separated from kitchen print success?
* Can print retry avoid duplicate kitchen tickets?
* Can direct print and POS-delegated print be distinguished?
* Can local agent heartbeat and POS PC health be tracked?
* Can the system distinguish provider cloud failure from local POS app freeze, POS PC overload, app restart, printer driver timeout, and store network failure?

### 12.5 Resilience And Idempotency Questions

* Can provider timeout, rate limit, and outage open a circuit without killing the platform?
* Can orders be queued without losing state?
* Can queued orders be replayed safely only after revalidation?
* Can duplicate customer submissions, duplicate webhooks, local agent replay, and manual POS reentry be blocked or reconciled?
* Can payment operations avoid duplicate approval, duplicate void, and duplicate refund?

### 12.6 Journey And Inventory Questions

* Can waiting, entry, no-show, manual entry, table assignment, order, payment, and kitchen ticket states be correlated through one journey?
* Can prepaid cancellation safely propagate to POS cancellation, kitchen stop, refund, and operator recovery?
* Can the system prevent overbooking when platform table state and POS table state diverge?
* Can the system prevent the last available item from being sold through two channels at the same time?
* Can stock holds expire, release, replay, and reconcile safely?

### 12.7 Audit And Operator Questions

* Can every exception be reconstructed through immutable audit evidence?
* Can operators see the difference between provider error, local hardware error, waiting journey conflict, stock conflict, and finance reconciliation conflict?
* Can customer-facing messages remain clear without exposing internal provider, hardware, tax, or audit details?

## 13. Operator Visibility Requirements

The POS Gateway must provide operator visibility for:

* Provider health
* Adapter version
* Provider capability limitations
* Menu mapping failures
* Master data sync failures
* Price mismatch
* Sold-out conflict
* Payment mismatch
* Refund and void pending state
* Kitchen print uncertainty
* Local agent health
* POS PC health
* Printer health
* Circuit breaker state
* Queue depth
* Duplicate-risk orders
* Manual POS reentry suspected orders
* Business day mismatch
* Table state conflict
* Waiting entry conflict
* No-show and manual entry state
* Prepaid cancellation recovery
* Stock hold and stock race conflict
* VAN/PG/POS reconciliation mismatch
* Duplicate tax risk
* Unpaid and service order classification
* Schema drift and quarantined packets

Operator tools must show allowed actions and required authority.

## 14. Audit Requirements

Every POS Gateway exception must preserve enough evidence to reconstruct:

* What customer or operator intended
* What the platform believed
* What the POS provider received
* What the provider returned
* What the local device reported
* What the printer did or failed to prove
* What payment system approved, voided, or refunded
* What POS receipt recorded
* What VAN or PG channel collected
* What table and business day applied
* What stock state or hold state applied
* What waiting or entry state applied
* What raw packet was validated or rejected
* What schema version and adapter version were used
* What decision was made
* Who made the decision, if manual
* What customer was told
* What recovery happened

At minimum, relevant events should include:

* Store ID
* Provider ID
* Platform order ID
* Waiting session ID, if applicable
* Table ID, if applicable
* Payment ID, if applicable
* Payment group ID, if applicable
* Kitchen ticket ID, if applicable
* Stock hold ID, if applicable
* Queue job ID, if applicable
* Raw packet ID, if applicable
* Trace ID
* Correlation ID
* Idempotency key
* Adapter version
* Gateway version
* Timestamp
* Decision outcome
* Operator action, if applicable

Sensitive data must be redacted, tokenized, encrypted, minimized, or access-restricted according to the security runtime policy.

## 15. Test Evidence Requirements

Each provider or store flow must include test evidence for:

* Adapter contract isolation
* Capability profile enforcement
* Menu mapping success
* Menu mapping failure
* Price validation success
* Price mismatch block
* Sold-out validation
* Sold-out race condition
* Payment exact match
* Payment mismatch
* Split payment
* POS-side discount conflict
* VAT rounding mismatch
* Refund and void
* Kitchen print delegated path
* Direct print path, if supported
* Printer failure
* Local agent heartbeat loss
* POS PC unreachable
* POS app restart
* Adaptive timeout
* Provider timeout
* Provider 429
* Circuit open and half-open recovery
* Queue replay success
* Queue replay blocked
* Duplicate order prevention
* Manual POS reentry
* Business day close
* After-midnight order
* Table move
* Table merge
* Table split
* Waiting entry confirmation
* No-show
* Prepaid cancellation after POS submission
* Kitchen cancellation
* Last-item inventory conflict
* Stock hold expiration
* PG/VAN/POS reconciliation
* Unpaid order
* Service order
* Schema drift
* Raw packet quarantine
* Operator recovery
* Audit preservation

A provider path without test evidence must not be treated as production-ready.

## 16. Anti-Patterns

The following are prohibited:

* Calling provider APIs directly from core order logic
* Embedding provider menu codes as core menu identity
* Treating POS ACK as kitchen print success
* Treating cached POS data as live truth without freshness policy
* Approving payment before required validation
* Treating all provider errors as generic failure
* Retrying non-idempotent requests blindly
* Replaying queued jobs after cancellation, refund, business day close, stock sellout, or manual recovery
* Treating timeout as proof of failure
* Treating timeout as proof of success
* Allowing local agent replay without idempotency
* Hiding POS app restart gaps from operators
* Calling next waiting team when table state is uncertain
* Refunding prepaid waiting orders without POS and kitchen cancellation checks
* Holding stock without expiration
* Selling limited stock through multiple channels without validation or hold
* Treating every unpaid POS order as error
* Treating every zero-amount order as canceled
* Counting PG and VAN payments twice
* Aggregating sales only by calendar date
* Updating core state from quarantined packets
* Ignoring provider schema drift because the order appears to work
* Exposing provider internals, printer details, hardware details, tax internals, or raw payloads to customers

## 17. Customer-Facing Messaging Principles

Customer-facing messaging must be simple, accurate, and non-technical.

Allowed message themes include:

* The store is confirming the order
* The order is taking longer than usual to confirm
* The item is no longer available
* The table is being confirmed
* The payment was not completed
* A refund is being processed
* The store is temporarily unable to accept online orders
* The store is reviewing the order

Customer-facing messages must not expose:

* Provider API errors
* Raw error codes
* Printer IPs
* Local agent state
* POS PC hardware or OS details
* Circuit breaker status
* Queue internals
* Idempotency keys
* Schema validation details
* Tax reconciliation internals
* VAN or PG dispute details
* Raw payloads

## 18. Final Position

The 05300 catalog is the POS Gateway field integrity catalog for the full F&B operating journey.

Its job is not merely to connect to POS providers.

Its job is to absorb disorder across external POS providers, store devices, local agents, kitchen printers, waiting flow, table state, business day state, inventory, payment channels, VAN/PG settlement, tax classification, schema drift, and human field operation while preserving the integrity of the core order, payment, settlement, kitchen execution, customer journey, and audit domains.

The POS Gateway must always be able to answer:

* What did the customer intend?
* What did the platform accept?
* What did the POS provider receive?
* What did the POS provider acknowledge?
* What did the kitchen receive?
* What did the payment system approve?
* What did the store manually change?
* What stock was held, consumed, released, or sold out?
* What table and business day applied?
* What sales channel and payment collector applied?
* What packet was validated, rejected, or quarantined?
* What recovery action happened?
* What evidence proves it?

If the system cannot answer these questions, the POS Gateway field integrity boundary has failed.
