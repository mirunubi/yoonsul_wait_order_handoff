# 014004_Policy_POS_Gateway_Interface_Abstraction_Adapter_Boundary

## 1. Purpose

This policy defines the interface abstraction and adapter boundary for the POS Gateway.

The purpose is to ensure that the core order, payment, settlement, and audit domains do not directly depend on any external POS provider’s API format, menu model, table model, payment structure, printer behavior, error code, or operational timing.

A new POS provider must be added through a provider adapter and capability profile without modifying the core business logic.

## 2. Scope

This policy applies to:

* Virtual POS interface design
* POS provider adapter boundary
* Provider capability profile
* Provider-specific request and response mapping
* Provider error normalization
* Unsupported feature handling
* Adapter versioning
* Core-to-Gateway contract separation
* Gateway-to-provider contract isolation
* Provider onboarding readiness checks

This policy applies to all POS providers, including but not limited to:

* Modern cloud POS providers
* Legacy desktop POS providers
* Local middleware-based POS providers
* API-limited POS providers
* Printer-only or semi-manual POS paths
* Future unknown POS providers

## 3. Core Principle

The core system must speak only to the Virtual POS interface.

The core system must never speak directly to a POS provider.

Provider-specific differences must be absorbed by:

* Provider adapter
* Provider capability profile
* Transformer
* Validator
* Error normalizer
* Retry and queue policy
* Audit event mapper

The POS Gateway exists to protect the core from POS provider disorder.

## 4. Architectural Boundary

```
[Core Order / Payment / Settlement / Audit Domain]
                     |
                     v
        [Virtual POS Interface Contract]
                     |
                     v
        [POS Gateway Orchestration Layer]
                     |
     -------------------------------------
     |                 |                 |
     v                 v                 v
[Adapter: Toss]   [Adapter: OKPOS]   [Adapter: Future POS]
```

The core domain must only depend on the Virtual POS interface contract.

Each adapter may depend on a provider-specific API, SDK, local agent, file protocol, printer protocol, or network protocol.

The dependency direction must never be reversed.

## 5. Non-Negotiable Rules

### 5.1 No Core Modification For New POS Provider Rule

Adding a new POS provider must not require modification of:

* Core order creation logic
* Core payment approval logic
* Core settlement logic
* Core customer state logic
* Core menu domain model
* Core audit domain model

A new provider may require additions or extensions to:

* Provider adapter
* Provider capability profile
* Menu transformer
* Table transformer
* Payment mapping rule
* Error mapping rule
* Test fixture
* Provider-specific readiness evidence

### 5.2 Adapter Isolation Rule

Provider-specific code must remain inside the provider adapter boundary.

The following must not leak into the core:

* Provider-specific field names
* Provider-specific enum values
* Provider-specific menu code assumptions
* Provider-specific table ID formats
* Provider-specific payment rounding rules
* Provider-specific printer behavior
* Provider-specific retry assumptions
* Provider-specific error codes

### 5.3 Capability Profile First Rule

Before a POS provider is integrated, the provider must have a capability profile.

The capability profile must declare what the provider supports, does not support, or supports only through degraded operation.

The Gateway must not assume that all POS providers support the same features.

### 5.4 Explicit Degradation Rule

When a provider does not support a required feature, the Gateway must classify the integration path as degraded, blocked, or manual-assisted.

The system must not pretend that unsupported features are supported.

### 5.5 Provider Contract Version Rule

Each POS provider adapter must be tied to a known contract version.

If the provider changes its API, schema, or operational behavior, the adapter version and evidence must be updated.

## 6. Virtual POS Interface Responsibilities

The Virtual POS interface must expose provider-neutral operations.

Examples include:

```
validateOrder()
submitOrder()
cancelOrder()
voidPayment()
syncMenuMaster()
syncSoldOutState()
syncTableState()
getBusinessDayState()
submitKitchenPrintRequest()
checkProviderHealth()
```

The interface must describe what the platform needs, not what a specific provider happens to expose.

## 7. Provider Adapter Responsibilities

Each provider adapter is responsible for translating the Virtual POS interface into provider-specific behavior.

The adapter must handle:

* Request transformation
* Response transformation
* Error normalization
* Provider authentication
* Provider timeout policy
* Provider retry eligibility
* Provider-specific idempotency key placement
* Provider-specific menu code mapping
* Provider-specific table mapping
* Provider-specific payment mapping
* Provider-specific audit event generation
* Provider capability enforcement

The adapter must not own core business decisions.

## 8. Provider Capability Profile

Each POS provider must have a capability profile.

The profile should include:

```
provider_id
provider_name
contract_version
integration_mode
supports_cloud_api
supports_local_agent
supports_order_submit
supports_order_cancel
supports_payment_submit
supports_payment_void
supports_menu_sync
supports_price_validation
supports_sold_out_sync
supports_table_sync
supports_business_day_sync
supports_kitchen_print_delegation
supports_direct_print
supports_webhook
supports_idempotency_key
supports_async_status_query
supports_partial_payment
supports_discount_mapping
supports_tax_breakdown
rate_limit_policy_known
timeout_policy_known
manual_recovery_required
degraded_operation_allowed
```

The capability profile is required evidence for onboarding.

## 9. Integration Mode Classification

Every provider must be classified into one integration mode.

### 9.1 Full API Mode

The provider supports:

* Order submission
* Payment mapping
* Menu validation
* Sold-out validation
* Status query
* Error response
* Basic audit trace

This is the preferred integration path.

### 9.2 Cloud API With Limited Validation Mode

The provider supports order submission but has limited validation capability.

Example limitations:

* No real-time sold-out query
* No exact menu option validation
* No detailed payment breakdown
* No business day status

This mode requires additional Gateway-side validation and operator warning.

### 9.3 Local Agent Mode

The provider requires communication with a store-side POS PC or local middleware.

This mode requires:

* Local agent heartbeat
* Network reachability checks
* Store-side installation evidence
* Local failure recovery path
* Offline and reconnect handling

### 9.4 Printer Delegation Mode

The provider accepts orders and delegates kitchen printing internally.

This mode requires clear audit separation between:

* POS order ACK
* Kitchen print responsibility
* Store-side print failure handling

### 9.5 Printer-Only Or Manual-Assisted Mode

The provider cannot accept structured order data but can support printing or manual input flow.

This mode is degraded by default.

It requires:

* Manual confirmation
* Operator recovery workflow
* Clear customer-facing state
* Strong audit evidence

### 9.6 Unsupported Mode

If a provider cannot safely support the minimum required order, payment, and audit boundary, it must be classified as unsupported.

Unsupported providers must not be connected to production order flow.

## 10. Core Request Contract

The core must send provider-neutral requests to the POS Gateway.

A core order submission request should include:

```
platform_order_id
store_id
business_context_id
customer_context_id
order_lines
option_lines
discount_context
payment_context
table_context
fulfillment_context
idempotency_key
requested_at
trace_id
```

The core must not include provider-specific implementation assumptions.

## 11. Gateway Normalized Response Contract

The Gateway must return normalized responses to the core.

Examples:

```
ACCEPTED
REJECTED_BY_PROVIDER
VALIDATION_FAILED
PROVIDER_TIMEOUT
PROVIDER_RATE_LIMITED
QUEUED_FOR_RETRY
DUPLICATE_DETECTED
MANUAL_REVIEW_REQUIRED
UNSUPPORTED_PROVIDER_FEATURE
SCHEMA_DRIFT_DETECTED
```

The core must act on normalized states, not provider-native error codes.

## 12. Provider Error Normalization

Provider-specific errors must be mapped into Gateway-level categories.

Examples:

```
Provider error: 429
Normalized: PROVIDER_RATE_LIMITED

Provider error: socket timeout
Normalized: PROVIDER_TIMEOUT

Provider error: item not found
Normalized: VALIDATION_FAILED

Provider error: invalid option code
Normalized: VALIDATION_FAILED

Provider error: unknown field response
Normalized: SCHEMA_DRIFT_DETECTED

Provider error: duplicate receipt number
Normalized: DUPLICATE_DETECTED
```

The original provider error must still be preserved in immutable audit evidence.

## 13. Unsupported Feature Handling

When a provider does not support a required feature, the Gateway must choose one of the following outcomes:

```
BLOCKED
DEGRADED_WITH_WARNING
MANUAL_ASSISTED
QUEUE_AND_RETRY
OPERATOR_CONFIRMATION_REQUIRED
PROVIDER_NOT_SUPPORTED
```

The decision must be visible in:

* Audit log
* Provider capability profile
* Store onboarding checklist
* Operator console
* Implementation readiness evidence

## 14. Adapter Versioning

Each adapter must be versioned.

The adapter version must record:

```
adapter_id
provider_id
provider_contract_version
adapter_version
supported_gateway_contract_version
released_at
change_summary
breaking_change_flag
test_fixture_version
schema_snapshot_reference
```

A provider API change must not be silently absorbed without adapter evidence.

## 15. Raw Packet Preservation

The adapter must preserve provider request and response evidence.

At minimum, the Gateway must record:

* Normalized request
* Provider outbound request
* Provider inbound response
* Provider error payload
* Provider status query payload
* Provider webhook payload, if applicable
* Schema validation result
* Trace ID
* Idempotency key
* Timestamp
* Adapter version

Sensitive values must be redacted, tokenized, or encrypted according to the security runtime policy.

## 16. Adapter Test Requirements

Each provider adapter must have tests for:

* Successful order submission
* Validation failure
* Provider timeout
* Provider rate limit
* Duplicate idempotency key
* Invalid menu code
* Invalid option code
* Payment amount mismatch
* Unsupported feature
* Schema drift
* Retry-eligible error
* Retry-ineligible error
* Raw packet audit preservation

A provider adapter without tests must not be treated as production-ready.

## 17. Provider Onboarding Checklist

Before a provider can be attached to a production store, the following evidence must exist:

```
Provider capability profile
Adapter contract
Adapter version
Schema snapshot
Menu mapping rule
Table mapping rule
Payment mapping rule
Tax and rounding rule
Discount handling rule
Sold-out validation rule
Order submit test
Order cancel test
Timeout test
Rate limit test
Idempotency test
Schema drift rejection test
Operator recovery path
Audit evidence sample
```

## 18. Anti-Patterns

The following are prohibited:

* Calling provider APIs directly from core order logic
* Embedding provider menu codes in the core menu model
* Embedding provider table IDs in customer-facing order state
* Treating POS ACK as final fulfillment success
* Treating all provider errors as generic failure
* Silently retrying non-idempotent requests
* Silently accepting provider schema changes
* Hardcoding provider-specific VAT or rounding rules into core payment logic
* Adding provider-specific branches inside core business logic
* Allowing adapter code to mutate core state directly

## 19. Relationship With Other Documents

This policy is the foundation for the remaining 05300 policies.

It directly supports:

```
05320 POS Menu Hierarchy Option Transformer Policy
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

## 20. Final Rule

The POS Gateway must be designed so that the platform can integrate a new POS provider by adding an adapter, not by rewriting the core.

If a POS provider forces core order, payment, settlement, or audit logic to change, the abstraction boundary has failed.
