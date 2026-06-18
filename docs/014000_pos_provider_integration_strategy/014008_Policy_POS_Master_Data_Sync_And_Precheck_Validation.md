# 014008_Policy_POS_Master_Data_Sync_And_Precheck_Validation

## 1. Purpose

This policy defines how the POS Gateway must handle master data synchronization and precheck validation for POS-connected order flow.

The purpose is to prevent orders, payments, menu items, prices, sold-out states, and option selections from entering an unsafe state due to stale, delayed, incomplete, or provider-specific POS master data.

The POS Gateway must validate critical order facts before payment approval or final order submission whenever the provider integration path allows it.

## 2. Scope

This policy applies to:

* POS menu master synchronization
* POS price synchronization
* POS option synchronization
* POS sold-out state synchronization
* POS table state synchronization, where applicable
* Cached POS master data
* Provider webhook handling
* Scheduled synchronization
* On-demand validation
* Pre-payment validation
* Pre-order submission validation
* Validation failure handling
* Stale data handling
* Audit evidence for validation decisions

This policy applies to all POS provider integration modes, including full API, limited API, local agent, manual-assisted, and degraded provider paths.

## 3. Core Principle

During early POS integration phases, the POS provider should be treated as the final operational execution system for store-side order acceptance.

The platform may own the customer-facing order experience, menu display, payment flow, and audit trail, but the Gateway must not ignore provider-side menu, price, sold-out, or operational constraints.

Before payment approval or order finalization, the Gateway must perform the strongest available validation that the provider integration path can safely support.

## 4. Master Data Boundary

Master data exists in multiple systems.

```
[Core Menu / Store Configuration]
              |
              v
[Platform Master Data Cache]
              |
              v
[POS Gateway Validation Layer]
              |
   ------------------------------
   |                            |
   v                            v
[POS Provider Master]     [Local Agent / Store POS]
```

The platform must distinguish between:

* Platform-owned menu intent
* Cached provider master data
* Live provider validation response
* Store-side manual override
* Provider unavailable or unknown state

These must not be collapsed into one ambiguous state.

## 5. Non-Negotiable Rules

### 5.1 Precheck Before Payment Rule

If the provider supports price, menu, option, or sold-out validation, the Gateway must perform a precheck before final payment approval.

The precheck must cover at minimum:

* Menu item exists
* Option exists
* Price is valid
* Sold-out state is valid
* Store is open for order intake
* Provider can accept the order path

If precheck fails, payment approval must be blocked, delayed, or moved to a controlled exception flow.

### 5.2 POS-As-Operational-Truth Phase Rule

In early provider integration phases, the POS must be treated as the operational truth for whether a store can accept a specific order.

This does not mean the POS owns the platform menu model.

It means the POS may block execution because its operational state differs from the platform’s cached state.

### 5.3 Cache Is Not Truth Rule

Cached POS master data must not be treated as live truth when live validation is required and available.

A cache is a performance optimization and fallback support mechanism, not a substitute for final validation when risk is high.

### 5.4 Stale Data Visibility Rule

If the Gateway uses stale or cached provider data, the decision must be visible in audit and operator evidence.

The system must record:

* Data source used
* Last sync time
* Staleness age
* Validation mode
* Risk classification
* Customer-facing status, if affected

### 5.5 Silent Mismatch Prohibition Rule

If platform data and provider data disagree on price, sold-out state, option validity, or menu availability, the Gateway must not silently choose one without policy.

The mismatch must be classified, logged, and resolved through a controlled rule.

## 6. Master Data Types

The POS Gateway may synchronize or validate the following master data types:

* Menu item
* Menu category
* Variant
* Option group
* Option item
* Menu price
* Option price
* Tax category
* Discount eligibility
* Sold-out state
* Store operating state
* Business day state
* Table layout
* Table availability
* Printer routing, where available
* Provider feature capability
* Provider error code catalog

Not every provider supports every master data type.

Provider capability must be declared in the provider capability profile.

## 7. Synchronization Modes

Each provider must declare its synchronization mode.

### 7.1 Webhook Synchronization

The provider sends changes to the platform through webhook events.

Webhook synchronization may include:

* Menu update
* Price update
* Sold-out update
* Store open or close update
* Table update
* Order status update

Webhook events must be schema-validated before they update any platform cache.

Webhook delay, duplication, missing sequence, and replay must be handled.

### 7.2 Scheduled Synchronization

The Gateway periodically pulls provider master data.

Scheduled synchronization may occur:

* At store opening
* Every fixed interval
* During off-peak hours
* Before service start
* On operator request

Scheduled synchronization must record sync start, sync end, result, provider version, and failure reason.

### 7.3 On-Demand Validation

The Gateway calls the provider at the moment of order or payment decision.

On-demand validation is preferred for high-risk facts such as:

* Final price
* Sold-out state
* Required option validity
* Store order acceptance state

On-demand validation must have timeout and circuit breaker protection.

### 7.4 Local Agent Synchronization

The Gateway communicates with store-side middleware or POS PC.

Local agent synchronization requires:

* Agent heartbeat
* Local network reachability
* Agent version
* Store device identity
* Last successful sync timestamp
* Recovery path when agent disappears

### 7.5 Manual-Assisted Synchronization

If a provider cannot expose reliable master data, the store operator may manually confirm or maintain mappings.

This mode is degraded.

It requires:

* Operator responsibility assignment
* Manual update evidence
* Store checklist
* Visible warning
* Exception handling policy

## 8. Precheck Validation Types

The Gateway must classify validation into specific types.

### 8.1 Menu Existence Validation

Confirms that the requested provider menu code exists and is active.

Failure examples:

* Provider menu code missing
* Menu item deleted in POS
* Store-specific provider code inactive
* Mapping points to old provider code

### 8.2 Option Validity Validation

Confirms that selected options are supported and active.

Failure examples:

* Option group missing
* Option item inactive
* Option combination unsupported
* Required option missing
* Multi-select not supported by provider

### 8.3 Price Validation

Confirms that core calculated price and provider-recognized price match within allowed tolerance.

Failure examples:

* POS price changed
* Option price changed
* Promotion not recognized
* VAT rounding difference
* Provider total differs from platform total

### 8.4 Sold-Out Validation

Confirms that requested menu items and options are not sold out.

Failure examples:

* POS marked item sold out
* Provider returned stock unavailable
* Store manually blocked menu item
* Sold-out webhook delayed
* Cache stale during order attempt

### 8.5 Store Acceptance Validation

Confirms that the store and provider path can accept orders.

Failure examples:

* Store closed
* POS business day closed
* Provider maintenance
* Local agent offline
* Manual confirmation required

### 8.6 Table State Validation

For dine-in or handoff flows, confirms table state where applicable.

Failure examples:

* Table not found
* Table merged
* Table moved
* Table closed
* Table occupied by another session
* Provider table ID mismatch

## 9. Validation Timing

Validation may occur at multiple points.

### 9.1 Menu Display Time

The platform may use cached data to decide what to show to the customer.

This reduces customer frustration but must not replace final validation.

### 9.2 Cart Confirmation Time

The Gateway may validate before the customer proceeds to payment.

This helps detect stale menu and sold-out issues earlier.

### 9.3 Payment Approval Time

This is the critical validation point.

Before payment approval, the Gateway must confirm that the order can be safely accepted according to the strongest available provider validation path.

### 9.4 POS Submission Time

After payment or order confirmation, the Gateway may validate again before provider submission if delay or queueing occurred.

### 9.5 Retry Replay Time

Queued orders must be revalidated before replay if the original validation is stale or provider state may have changed.

## 10. Validation Result Contract

The Gateway must normalize validation results.

Allowed validation results include:

```
VALID
INVALID_MENU
INVALID_OPTION
PRICE_MISMATCH
SOLD_OUT
STORE_CLOSED
TABLE_INVALID
PROVIDER_UNAVAILABLE
VALIDATION_TIMEOUT
VALIDATION_DEGRADED
MANUAL_CONFIRMATION_REQUIRED
SCHEMA_DRIFT_DETECTED
UNKNOWN_PROVIDER_STATE
```

Each result must map to a controlled order decision.

## 11. Validation Decision Outcomes

The Gateway may choose one of the following outcomes:

```
ALLOW_PAYMENT
BLOCK_PAYMENT
HOLD_FOR_RECHECK
QUEUE_FOR_RETRY
REQUIRE_CUSTOMER_CONFIRMATION
REQUIRE_OPERATOR_CONFIRMATION
CANCEL_AND_REFUND
MARK_PROVIDER_UNSUPPORTED
FALLBACK_TO_MANUAL_FLOW
```

The decision must be recorded in audit.

## 12. Price Mismatch Handling

Price mismatch must be handled conservatively.

If platform amount and provider amount differ, the Gateway must classify the difference.

Categories include:

* Exact match
* Allowed rounding tolerance
* Minor provider rounding mismatch
* Promotion mismatch
* Option price mismatch
* Tax calculation mismatch
* Store-side manual price change
* Unknown mismatch

If the difference exceeds permitted tolerance, the Gateway must block payment approval or require controlled confirmation.

The Gateway must not silently approve a different amount.

## 13. Sold-Out Race Condition Handling

Sold-out race conditions are expected in real store operation.

Example sequence:

```
Customer confirms cart
Store marks item sold out in POS
Platform cache has not yet updated
Customer attempts payment
Provider validation rejects item
```

In this case, the Gateway must:

* Block or reverse the payment flow
* Mark the order as not accepted
* Notify the customer
* Notify the operator, if needed
* Preserve validation evidence
* Update local cache when safe
* Prevent repeated attempts for the same stale item

If payment has already been approved, the Gateway must trigger the controlled void, refund, or cancellation path according to payment policy.

## 14. Stale Cache Handling

Each cached master data type must have a freshness threshold.

Examples:

```
Menu catalog: longer threshold allowed
Price: strict threshold required
Sold-out state: very strict threshold required
Store open state: strict threshold required
Table state: strict threshold required during dine-in flow
```

If cache age exceeds the threshold, the Gateway must either revalidate live, degrade the flow, or block risky actions.

## 15. Provider Unavailable Handling

If the provider is unavailable during validation, the Gateway must not pretend validation succeeded.

Allowed outcomes include:

* Queue order before payment only if customer-facing state is clear
* Hold payment authorization, if supported
* Block payment and ask customer to retry
* Switch to manual-assisted store confirmation
* Open circuit breaker
* Mark provider health degraded

The selected outcome must match the provider capability profile and circuit breaker policy.

## 16. Sync Failure Handling

Synchronization failures must be classified.

Examples:

```
SYNC_TIMEOUT
SYNC_AUTH_FAILED
SYNC_SCHEMA_DRIFT
SYNC_PARTIAL_SUCCESS
SYNC_CONFLICT
SYNC_PROVIDER_MAINTENANCE
SYNC_LOCAL_AGENT_OFFLINE
SYNC_UNKNOWN_FAILURE
```

A failed sync must not silently leave the system in a false healthy state.

Operator dashboards and audit records must expose sync health.

## 17. Conflict Resolution

When platform master data and POS master data conflict, the Gateway must apply a documented conflict policy.

Conflict types include:

* Price conflict
* Name conflict
* Option conflict
* Sold-out conflict
* Table conflict
* Store operating state conflict
* Tax category conflict
* Discount eligibility conflict

During early integration, execution-risk conflicts should favor provider validation.

Platform display data may remain platform-owned, but execution must not proceed if provider validation blocks the order.

## 18. Audit Requirements

Every validation decision must preserve:

* Platform order ID or cart ID
* Store ID
* Provider ID
* Validation type
* Validation timing
* Data source used
* Provider request reference
* Provider response reference
* Cache snapshot reference
* Cache age
* Validation result
* Decision outcome
* Price comparison, if applicable
* Sold-out comparison, if applicable
* Table comparison, if applicable
* Trace ID
* Idempotency key
* Gateway version
* Adapter version
* Validation rule version
* Timestamp

Sensitive values must be redacted, tokenized, or encrypted according to the security runtime policy.

## 19. Operator Visibility

The operator console must show validation problems clearly.

It should distinguish:

* Menu mapping issue
* POS price mismatch
* Sold-out conflict
* Provider unavailable
* Local agent offline
* Store closed
* Table state mismatch
* Provider schema drift
* Manual confirmation required

The system must avoid vague errors such as “order failed” when a more specific diagnosis exists.

## 20. Customer-Facing Messaging

Customer-facing messaging must be controlled and non-technical.

Examples:

```
This item is no longer available.
The store is updating its menu. Please try again shortly.
The store could not confirm this order. No payment was completed.
The order is being confirmed by the store.
The selected table is no longer available.
```

Customer-facing messaging must not expose provider internals, API errors, raw payloads, or security-sensitive details.

## 21. Test Requirements

Each provider integration must test:

* Successful live validation
* Successful cached validation
* Missing menu item
* Missing option
* Price mismatch
* Sold-out rejection
* Store closed
* Provider timeout
* Provider rate limit during validation
* Local agent offline during validation
* Webhook delay
* Scheduled sync failure
* Stale cache threshold exceeded
* Retry replay revalidation
* Payment blocked before approval
* Payment approved then provider rejects, if that flow is allowed
* Audit preservation for each validation outcome

A provider cannot be production-ready without validation test evidence.

## 22. Anti-Patterns

The following are prohibited:

* Treating cached POS data as live truth without freshness policy
* Approving payment before required provider validation
* Ignoring sold-out race conditions
* Silently changing platform price to match provider price
* Silently changing provider price to match platform price
* Using provider menu names instead of stable IDs for validation
* Continuing order flow after provider validation timeout as if success occurred
* Hiding sync failures from operators
* Replaying queued orders without checking whether validation is stale
* Collapsing menu sync, price sync, and sold-out sync into one undifferentiated status

## 23. Relationship With Other Documents

This policy depends on and supports:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05320 POS Menu Hierarchy Option Transformer Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Master data validation is the final safety gate before the platform allows risky order and payment transitions.

## 24. Final Rule

The POS Gateway must never approve, submit, or replay an order based on stale, unverifiable, or contradictory master data without a controlled policy decision.

If the platform cannot explain which data source was used, when it was last validated, and why the order was allowed or blocked, the master data validation boundary has failed.
