# 014041_Policy_POS_Provider_Test_Fixture_And_Simulation_Scenario

## 1. Purpose

This policy defines how POS provider integrations must be tested through repeatable fixtures, simulations, failure scenarios, replay cases, reconciliation cases, and production-readiness evidence.

The purpose is to ensure that provider readiness is proven through controlled tests, not assumptions.

A POS provider integration must be able to demonstrate correct behavior under happy path, failure path, timeout, duplicate, payment mismatch, kitchen print, inventory race, local agent, schema drift, waiting journey, table sync, and settlement reconciliation scenarios before it is approved for pilot or production.

## 2. Scope

This policy applies to:

* POS provider test fixtures
* Provider sandbox tests
* Local agent simulation
* Legacy hardware simulation
* Provider API failure simulation
* Payment and refund simulation
* In-doubt transaction simulation
* Kitchen printer simulation
* Menu transformer test fixtures
* Table sync test fixtures
* Waiting journey simulation
* Stock race simulation
* VAN/PG/POS reconciliation simulation
* Schema drift simulation
* Queue replay simulation
* Idempotency and duplicate prevention simulation
* Operator recovery simulation
* Test evidence capture
* Production readiness test approval

This policy applies to all POS provider integrations, whether full API, limited API, local agent, direct print, printer-only, degraded, manual-assisted, or multi-endpoint.

## 3. Core Principle

Every critical POS Gateway behavior must be testable before production.

The platform must not wait for a real store incident to discover that a provider cannot handle timeout, refund, duplicate order, receipt lookup, stock conflict, or table move.

Provider integration tests must include:

* Normal success
* Expected business rejection
* Technical failure
* Ambiguous outcome
* Retry and replay
* Manual recovery
* Audit preservation
* Customer-facing state
* Operator-facing state
* Finance reconciliation state

## 4. Test Fixture Boundary

Provider tests must cover the full Gateway boundary.

```
[Test Scenario]
      |
      v
[Gateway Normalized Contract]
      |
      v
[Provider Adapter / Local Agent / Printer Adapter]
      |
      v
[Provider Stub / Sandbox / Simulator / Pilot Store]
      |
      v
[Evidence Capture]
```

The test must prove both behavior and evidence.

A test that passes functionally but does not produce audit evidence is incomplete.

## 5. Non-Negotiable Rules

### 5.1 Repeatable Fixture Required Rule

Every provider integration must have repeatable test fixtures for critical paths.

Manual one-time tests are not enough.

### 5.2 Failure Path Required Rule

A provider cannot be approved with only happy-path order submission evidence.

Failure, timeout, rejection, refund, duplicate, schema drift, and recovery paths must be tested.

### 5.3 Audit Evidence Required Rule

Each test must verify that required audit events, raw packet references, trace IDs, idempotency keys, state transitions, and decision outcomes are preserved.

### 5.4 Risk-Based Test Depth Rule

Higher-risk providers require deeper tests.

Risk factors include:

* Payment integration
* Prepaid waiting flow
* Local agent dependency
* Direct print responsibility
* Legacy hardware
* Unknown rate limit
* Weak idempotency
* Weak schema contract
* Weak refund support
* Table/dine-in support
* Multi-endpoint routing

### 5.5 Production Approval Requires Test Evidence Rule

No provider path may be marked production-ready without test evidence linked to its readiness profile.

## 6. Test Environment Types

Provider tests may run in several environments.

### 6.1 Unit Fixture

Tests pure transformation or mapping logic.

Examples:

* Menu transformer
* Table transformer
* Payment mapper
* Error normalizer
* Schema validator
* Idempotency decision

### 6.2 Provider Stub

A controlled fake provider returns defined responses.

Used for:

* Timeout
* 429
* 5xx
* Malformed payload
* Unknown enum
* Missing field
* Delayed ACK
* Duplicate webhook

### 6.3 Provider Sandbox

Uses official provider sandbox.

Used for:

* Real API contract
* Auth
* Order submission
* Cancel
* Refund
* Status query
* Receipt lookup

### 6.4 Local Agent Simulator

Simulates store-side local agent, POS app, printer, local queue, heartbeat, and reconnect.

### 6.5 Printer Simulator

Simulates kitchen printer response, timeout, busy state, encoding error, duplicate print, and unknown print status.

### 6.6 Pilot Store Test

Runs controlled production-like tests in a real store.

Pilot store tests must be narrow, observable, reversible, and evidence-rich.

## 7. Test Scenario Record

Every scenario must have a record.

The scenario record should include:

```
scenario_id
scenario_name
provider_id
integration_mode
test_environment
policy_reference
risk_category
preconditions
input_payload_reference
expected_gateway_state
expected_provider_state
expected_payment_state
expected_kitchen_state
expected_audit_events
expected_customer_message
expected_operator_action
pass_fail_status
evidence_reference
executed_by
executed_at
```

Scenario records must be linked to provider readiness evidence.

## 8. Fixture Data Requirements

Test fixture data must include realistic F&B structures.

Required fixture domains include:

* Store
* Tenant
* POS provider
* POS endpoint
* Menu item
* Variant
* Option group
* Option item
* Table
* Waiting session
* Customer session
* Payment intent
* Payment component
* Kitchen ticket
* Stock item
* Business day
* Provider raw packet
* Operator action

Fixtures must include edge cases, not only clean data.

## 9. Menu And Option Test Scenarios

Each provider must test:

* Direct menu mapping
* Variant mapping
* Option group mapping
* Flattened option mapping
* Combination code mapping
* Missing menu mapping
* Missing option mapping
* Inactive menu mapping
* Store-specific provider menu code
* Required option missing
* Unsupported optional option
* Unsupported required option
* Price mismatch after option transform
* Long kitchen name
* Multilingual display name
* Text truncation
* Legacy flat payload
* Modern tree payload

## 10. Master Data And Validation Test Scenarios

Each provider must test:

* Menu exists
* Menu missing
* Option exists
* Option missing
* Price exact match
* Price mismatch
* Sold-out valid
* Sold-out rejection
* Store open
* Store closed
* Provider validation timeout
* Provider validation rate limit
* Stale cache
* Webhook delayed
* Scheduled sync failure
* Retry replay requiring revalidation
* Unknown provider state

## 11. Payment And Reconciliation Test Scenarios

Each provider must test:

* Platform amount equals POS amount
* POS amount differs from platform amount
* VAT rounding tolerance
* VAT blocking mismatch
* Platform coupon
* Platform point
* POS-side discount
* Split payment
* Prepaid plus on-site payment
* PG approval success
* PG approval unknown
* PG refund
* PG refund unknown
* POS void
* POS void mismatch
* Day-end reconciliation
* Business day mismatch
* Manual finance review

## 12. In-Doubt Transaction Test Scenarios

Each provider must test:

* PG approved and POS accepted
* PG approved and POS submission failed
* PG approved and POS ACK unknown
* PG approval timeout
* Network cancel success
* Network cancel timeout
* Network cancel failed
* PG status query resolves unknown
* POS receipt lookup resolves unknown
* Receipt number collision
* Approval number mapping failure
* Duplicate refund prevention
* In-doubt record created
* Nightly reconciliation closes with evidence
* Finance review required

## 13. Kitchen Printer Test Scenarios

Each provider or printer path must test:

* POS delegated print
* Direct print success
* Print timeout
* Print status unknown
* Printer offline
* Printer busy
* Printer IP changed
* Printer encoding failure
* Korean long menu name
* Reprint with label
* Duplicate print blocked
* Cancel ticket
* Remake ticket
* Kitchen station routing
* Local agent print replay
* Manual kitchen recovery

## 14. Local Agent And Hardware Test Scenarios

Each local path must test:

* Agent heartbeat healthy
* Heartbeat delayed
* Heartbeat missing
* Agent offline
* Agent reconnect
* POS PC unreachable
* POS app frozen
* POS app restarted
* Provider cloud healthy but POS app dead
* CPU saturation
* Socket timeout
* Connection pool pressure
* Local queue growth
* Local queue replay
* Stale local job rejected
* Agent version mismatch
* Unknown device rejected
* IP changed

## 15. Circuit Breaker And Queue Test Scenarios

Each provider must test:

* Normal provider response
* Provider timeout
* Provider latency spike
* Provider 429
* Provider 5xx
* Circuit closed
* Circuit open
* Circuit half-open
* Circuit forced-open
* Queue enqueue
* Queue replay success
* Queue replay blocked
* Queue expiration
* Retry backoff
* Retry storm prevention
* Backpressure
* Provider A failure isolated from Provider B

## 16. Idempotency And Duplicate Test Scenarios

Each provider must test:

* Customer double-submit
* Client retry
* Gateway retry
* Queue replay duplicate risk
* Provider timeout ambiguous outcome
* Status reconciliation before replay
* Duplicate webhook
* Out-of-order webhook
* Local agent replay
* Manual POS reentry suspected
* Manual POS reentry confirmed
* Duplicate payment blocked
* Duplicate refund blocked
* Duplicate print blocked
* Legitimate second identical order allowed

## 17. Waiting, Entry, And Table Journey Test Scenarios

Each waiting or table provider path must test:

* Waiting registered
* Waiting called
* Entry confirmed
* No-show
* Manual entry
* Manual entry after no-show
* Table assignment success
* POS table occupied conflict
* Table move
* Table merge
* Table split
* Waiting session assigned to different table
* Prepaid waiting order
* Customer cancels before POS submission
* Customer cancels after POS submission
* Customer cancels after kitchen print
* Kitchen cancel signal
* Refund after waiting cancel
* Overbooking prevention

## 18. Inventory Race Test Scenarios

Each stock-sensitive flow must test:

* Item available
* Item low stock
* Last-item platform order
* Last-item POS manual order wins
* Platform hold wins
* Hold expiration
* Hold release after payment failure
* Hold release after customer cancel
* Hold release after no-show
* Provider sold-out webhook delay
* Option-level stock sold out
* Shared ingredient stock conflict
* Kitchen shortage after payment
* Queue replay after stock sold out
* Manual sold-out override

## 19. Sales Channel And Settlement Test Scenarios

Each financial integration must test:

* Platform PG mapped to smart-order POS channel
* Store VAN payment linked to platform order
* Mixed PG and VAN payment
* Platform coupon plus POS payment
* Platform point plus POS payment
* POS receipt without PG payment
* PG payment without POS receipt
* Duplicate sales risk
* Duplicate tax risk
* Unpaid order
* House account
* Service order
* Staff meal
* Owner comp
* Business day mismatch
* Manual finance classification

## 20. Schema Drift Test Scenarios

Each provider must test:

* Valid response
* Valid webhook
* Invalid signature
* Missing required field
* Invalid type
* Unknown low-risk field
* Unknown high-risk field
* Unknown enum value
* Amount field missing
* Status field changed
* Store binding mismatch
* Duplicate webhook
* Replay webhook
* Payload too large
* Quarantine path
* Adapter stale path
* Raw packet redaction

## 21. External API Isolation And Agent Channel Test Scenarios

Each production-scale provider path must test:

* Slow provider latency
* External connection pool saturation
* Worker pool saturation
* Non-blocking handoff
* Async queue admission
* Queue rejection
* Backpressure
* Polling interval control
* Polling jitter
* Polling backoff
* Empty polling response control
* WebSocket reconnect
* MQTT topic authorization
* Reconnect storm
* Low-priority sync throttling
* Agent traffic isolation from customer traffic

## 22. Multi-Endpoint And Manual Mutation Test Scenarios

Each multi-endpoint store path must test:

* Route by order type
* Route by sales channel
* Route by legal entity
* Route by delivery channel
* Primary endpoint down
* Fallback endpoint allowed
* Fallback endpoint blocked
* Printer shared mode
* COM port locked
* Delivery app print contention
* Manual POS cancel after platform acceptance
* Manual POS void after PG payment
* Manual POS discount after settlement
* Manual unpaid conversion
* Suspicious end-of-day cancellation
* Finance review escalation

## 23. Evidence Capture Requirements

Every test execution must capture:

* Test scenario ID
* Provider ID
* Store ID, if applicable
* Input payload
* Normalized Gateway request
* Provider outbound request
* Provider response or simulated response
* Raw packet reference
* Expected state
* Actual state
* Audit events
* Trace ID
* Correlation ID
* Idempotency key
* Adapter version
* Gateway version
* Test environment
* Pass or fail result
* Failure explanation
* Evidence file or record reference
* Timestamp

Sensitive data must be masked or synthesized in test evidence.

## 24. Pass Criteria

A test passes only when:

* Expected Gateway state is reached
* Provider or simulator state matches expectation
* Core state is not corrupted
* Payment state is safe
* Duplicate risk is controlled
* Customer-facing state is correct
* Operator-facing state is correct
* Audit evidence is complete
* Retry or recovery behavior matches policy
* No prohibited anti-pattern occurs

A functional API success without audit evidence is not a pass.

## 25. Failure Handling

When a test fails, the provider path must be classified.

Possible classifications include:

```
FIX_REQUIRED
ADAPTER_FIX_REQUIRED
PROVIDER_CLARIFICATION_REQUIRED
PROVIDER_LIMITATION_CONFIRMED
DEGRADED_MODE_REQUIRED
MANUAL_RECOVERY_REQUIRED
PILOT_BLOCKED
PRODUCTION_BLOCKED
POLICY_EXCEPTION_REQUESTED
```

Failure classification must update provider readiness.

## 26. Regression Test Requirements

Provider tests must be rerun when:

* Adapter changes
* Gateway contract changes
* Provider API changes
* Provider schema drift is detected
* Payment logic changes
* Refund logic changes
* Menu transformer changes
* Queue or idempotency logic changes
* Local agent version changes
* Printer adapter changes
* Sales channel mapping changes
* Incident occurs
* Provider readiness is upgraded

Regression evidence must be versioned.

## 27. Load And Peak Simulation

Provider readiness must include load simulation when relevant.

Load scenarios may include:

* Lunch peak
* Dinner peak
* Multi-store burst
* Provider slow response
* Agent reconnect storm
* Empty polling load
* Queue buildup
* Payment-risk backlog
* Printer backlog
* Store opening sync burst

Load tests must verify isolation, backpressure, and cost control.

## 28. Operator Recovery Simulation

Operator recovery must be tested.

Scenarios may include:

* Manual entry confirmation
* Refund approval
* Kitchen stop confirmation
* Queue job cancellation
* Circuit force-open
* Provider incident escalation
* Manual finance classification
* Suspicious mutation review
* In-doubt closure with evidence

Operator tests must verify authority, audit, and allowed action boundaries.

## 29. Test Coverage Matrix

Each provider must maintain a coverage matrix.

Coverage dimensions should include:

```
policy_document
scenario_group
scenario_id
required_for_mode
required_for_payment
required_for_waiting
required_for_table
required_for_direct_print
required_for_local_agent
required_for_multi_endpoint
test_status
last_run_at
evidence_reference
blocking_flag
```

A provider cannot be production-ready if required blocking scenarios are untested or failing.

## 30. Anti-Patterns

The following are prohibited:

* Marking provider ready after one happy-path order test
* Testing only provider API without Gateway state
* Testing only Gateway state without provider payload evidence
* Ignoring audit event verification
* Skipping failure scenarios because sandbox cannot simulate them
* Using production customers as first failure-path test
* Treating manual screenshots as the only evidence
* Not linking tests to provider readiness profile
* Not rerunning tests after adapter changes
* Ignoring load and polling cost tests for store-agent deployments
* Approving payment flow without in-doubt transaction tests

## 31. Relationship With Other Documents

This policy operationalizes:

```
05490 POS Provider Capability Profile And Readiness Evidence Policy
05300 POS Gateway Resilience And Field Exception Catalog Readme
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05320 POS Menu Hierarchy Option Transformer Policy
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
05410 POS Waiting Entry NoShow And Prepaid Cancel Sync Policy
05420 POS Legacy Hardware OS Adaptive Timeout And App Restart Policy
05430 POS Inventory Race Condition And Stock Hold Buffer Policy
05440 POS VAN PG Tax Sales Channel And Unpaid Order Reconciliation Policy
05450 POS External API Isolation NonBlocking IO And Connection Pool Protection Policy
05460 POS Polling WebSocket MQTT And Agent Realtime Channel Cost Control Policy
05470 POS InDoubt Transaction Network Cancel Receipt Number And Financial Reconciliation Policy
05480 POS Multi Endpoint Routing Delivery App Port Contention And Malicious Manual Mutation Defense Policy
```

Test fixtures are the proof layer for provider readiness.

## 32. Final Rule

A POS provider integration is not ready because it works once.

It is ready only when its expected success, expected failure, ambiguous failure, duplicate defense, payment safety, kitchen boundary, local infrastructure behavior, stock conflict, waiting journey, settlement reconciliation, schema drift, and operator recovery paths have been tested and preserved as evidence.

If the Gateway cannot reproduce and prove provider behavior through repeatable fixtures and simulation scenarios, the provider test boundary has failed.
