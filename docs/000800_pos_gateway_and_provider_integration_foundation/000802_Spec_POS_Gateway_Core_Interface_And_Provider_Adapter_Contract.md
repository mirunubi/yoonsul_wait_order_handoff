# 000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md

## 1. Purpose

This document defines the core interface contract between the POS Gateway and provider-specific POS adapters.

This document exists so that each POS provider integration can be implemented as a controlled adapter rather than as uncontrolled provider-specific business logic.

The POS Gateway owns the internal contract.

Provider adapters translate provider-specific behavior into this contract.

No provider adapter may redefine order authority, payment authority, cancellation authority, refund authority, recovery policy, reconciliation policy, evidence policy, or customer-facing finality.

This document is an interface specification only.

It is not implementation code.

## 2. Upstream Boundary

This specification depends on:

```text
000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md
```

The boundary rules in `000801` are authoritative.

This file must not redefine those rules differently.

Core rule:

```text
Provider adapters translate provider-specific behavior.
The POS Gateway normalizes events and evidence.
Our runtime decides state, recovery, reconciliation, evidence, and authority.
Humans approve irreversible or high-risk operational decisions.
```

## 3. Scope

This document defines:

* POS Gateway core interface responsibilities
* provider adapter contract
* common method list
* common identifiers
* input and output expectations
* idempotency requirements
* timeout and retry expectations
* error normalization requirements
* evidence requirements
* manual recovery requirements
* provider capability reporting requirements

## 4. Non-Scope

This document does not define:

* actual adapter source code
* provider-specific API payload implementation
* production credential storage implementation
* payment provider SDK implementation
* Flutter UI implementation
* Supabase schema implementation
* RLS policy implementation
* deployment automation
* production release approval
* vendor contract language

Those belong to separate implementation, security, release, or outsourcing documents.

## 5. Contract Principle

Every provider adapter must implement the POS Gateway contract without leaking provider-specific assumptions into the business runtime.

```text
Provider-specific behavior must be translated.
Provider-specific limitations must be reported.
Provider-specific evidence must be preserved.
Provider-specific uncertainty must not be hidden.
```

The adapter must not collapse complex states into simple success/failure if the provider response is partial, delayed, ambiguous, or inconsistent.

Unknown state must remain unknown until reconciliation or human review resolves it.

## 6. Common Identifiers

The POS Gateway contract must preserve stable identifiers across all provider interactions.

| Identifier               | Purpose                                      |
| ------------------------ | -------------------------------------------- |
| `gateway_event_id`       | Internal POS Gateway event identifier        |
| `tenant_id`              | Tenant boundary identifier                   |
| `store_id`               | Store boundary identifier                    |
| `order_id`               | Internal order identifier                    |
| `order_request_id`       | Customer or runtime order request identifier |
| `payment_id`             | Internal payment identifier                  |
| `payment_transaction_id` | Payment provider transaction identifier      |
| `pos_provider_id`        | POS provider identifier                      |
| `pos_adapter_id`         | Provider adapter identifier                  |
| `pos_adapter_version`    | Provider adapter version                     |
| `pos_order_id`           | Provider-side POS order identifier           |
| `pos_transaction_id`     | Provider-side transaction identifier         |
| `pos_receipt_id`         | Provider-side receipt identifier             |
| `idempotency_key`        | Duplicate prevention key                     |
| `correlation_id`         | Cross-runtime trace identifier               |
| `reconciliation_id`      | Reconciliation attempt identifier            |
| `manual_recovery_id`     | Manual recovery event identifier             |

No adapter may discard identifiers returned by the provider.

If a provider does not support a specific identifier, the adapter must report that limitation.

## 7. Common Result Categories

Every adapter method must normalize provider responses into one of the following result categories.

| Result Category          | Meaning                                                                        |
| ------------------------ | ------------------------------------------------------------------------------ |
| `success`                | Provider confirmed the requested action with sufficient evidence               |
| `failed`                 | Provider rejected or failed the requested action with sufficient evidence      |
| `pending`                | Provider accepted or queued the request but final status is not yet confirmed  |
| `unknown`                | The runtime cannot safely determine whether the provider processed the request |
| `duplicate_detected`     | A duplicate request, order, payment, cancellation, or refund was detected      |
| `manual_review_required` | The state requires human review before final interpretation                    |
| `recovery_required`      | The state requires recovery or reconciliation before final interpretation      |
| `unsupported`            | The provider or adapter does not support the requested operation               |
| `provider_unavailable`   | The provider is unavailable or unreachable                                     |
| `contract_violation`     | The adapter response violates the POS Gateway contract                         |

Unknown state must never be converted into success for convenience.

## 8. Common Evidence Requirement

Every method must produce or reference an evidence record.

The minimum evidence fields are:

* gateway event ID
* provider name
* adapter ID
* adapter version
* environment
* method name
* order ID where applicable
* payment ID where applicable
* POS order ID where applicable
* POS transaction ID where applicable
* POS receipt ID where applicable
* idempotency key where applicable
* correlation ID
* request timestamp
* response timestamp
* request payload reference
* response payload reference
* normalized result category
* provider raw result category where available
* retry count
* timeout status
* error code where applicable
* recovery requirement
* reconciliation requirement
* manual review requirement

Sensitive payloads must be masked or referenced according to the approved evidence policy.

## 9. Common Error Normalization

Provider-specific errors must be normalized into common error categories.

| Error Category          | Meaning                                            |
| ----------------------- | -------------------------------------------------- |
| `validation_error`      | Input was invalid or rejected before processing    |
| `authentication_error`  | Provider authentication failed                     |
| `authorization_error`   | Provider denied the operation                      |
| `provider_timeout`      | Provider did not respond within the allowed window |
| `network_error`         | Network interruption occurred                      |
| `provider_unavailable`  | Provider service was unavailable                   |
| `unsupported_operation` | Provider does not support the requested operation  |
| `duplicate_request`     | Duplicate request detected                         |
| `duplicate_payment`     | Duplicate payment detected                         |
| `duplicate_order`       | Duplicate order detected                           |
| `state_conflict`        | Provider state conflicts with internal state       |
| `unknown_result`        | Provider result is ambiguous                       |
| `rate_limited`          | Provider rate limit was reached                    |
| `contract_violation`    | Adapter response violated required contract        |

The adapter may preserve provider-specific error codes, but business logic must consume normalized categories.

## 10. Method Contract Summary

The POS Gateway core interface includes the following methods:

```text
healthCheck
createOrder
updateOrder
cancelOrder
authorizePayment
cancelPayment
refundPayment
getOrderStatus
getPaymentStatus
syncMenu
syncAvailability
recoverTransaction
reconcileTransactions
```

Each method must follow:

* input contract
* output contract
* idempotency requirement
* timeout behavior
* retry behavior
* error behavior
* evidence requirement
* manual recovery requirement

## 11. healthCheck

### Purpose

Check whether the provider adapter and provider connection are available.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `pos_provider_id`
* `pos_adapter_id`
* `correlation_id`

Optional:

* provider-specific diagnostic flags
* sandbox or production environment marker

### Output Contract

Must return:

* result category
* provider availability status
* adapter availability status
* response latency
* provider timestamp where available
* known degraded capabilities
* evidence reference

### Idempotency Requirement

No idempotency key is required because this method must not mutate provider state.

### Timeout Behavior

Timeout must return `provider_timeout` or `unknown` depending on whether provider reachability can be determined.

### Retry Behavior

Safe to retry.

### Error Behavior

Authentication, network, provider unavailability, and rate limit errors must be normalized.

### Evidence Requirement

Must record provider availability result, timestamp, latency, and error category where applicable.

### Manual Recovery Requirement

Manual recovery is not normally required, but repeated failure may trigger provider support escalation or degraded mode.

## 12. createOrder

### Purpose

Create or transmit an order to a POS provider.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `order_request_id`
* `pos_provider_id`
* `pos_adapter_id`
* `idempotency_key`
* `correlation_id`
* order line items
* quantities
* item prices
* option selections
* total amount
* order channel
* requested timestamp

Optional:

* customer display name or masked customer reference
* pickup number
* table number
* staff reference
* notes after approved masking
* coupon or discount reference
* payment reference if already authorized

### Output Contract

Must return:

* normalized result category
* provider raw result where available
* `pos_order_id` where available
* `pos_transaction_id` where available
* `pos_receipt_id` where available
* provider timestamp where available
* provider accepted amount where applicable
* provider accepted line items where applicable
* evidence reference
* recovery requirement
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required.

The adapter must use the provided `idempotency_key` where the provider supports idempotency.

If the provider does not support native idempotency, the adapter must report the limitation and rely on POS Gateway duplicate prevention rules.

### Timeout Behavior

A timeout after order submission must return `unknown`, not `failed`, unless provider evidence proves rejection.

### Retry Behavior

Retry may be safe only if idempotency or duplicate detection is available.

Unsafe retry must trigger manual review or reconciliation.

### Error Behavior

Provider validation errors, duplicate errors, unsupported operation, timeout, and unknown results must be normalized.

### Evidence Requirement

Must preserve request and response references, provider identifiers, idempotency key, and normalized result.

### Manual Recovery Requirement

Required when payment succeeded but POS order creation is failed or unknown.

## 13. updateOrder

### Purpose

Update an existing POS order when supported by the provider.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `pos_order_id`
* `pos_provider_id`
* `pos_adapter_id`
* `idempotency_key`
* `correlation_id`
* update reason
* update payload

Optional:

* changed line items
* changed quantity
* changed option
* changed price
* changed note
* staff approval reference

### Output Contract

Must return:

* normalized result category
* provider raw result where available
* updated provider state where available
* evidence reference
* recovery requirement
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required for any state-changing update.

### Timeout Behavior

Timeout must return `unknown` unless provider rejection is confirmed.

### Retry Behavior

Retry eligibility depends on idempotency and provider capability.

### Error Behavior

Unsupported operation must be reported clearly.

### Evidence Requirement

Must record before/after update references where available.

### Manual Recovery Requirement

Required when provider state and internal order state diverge.

## 14. cancelOrder

### Purpose

Request cancellation of a POS order or provider-side order record.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `pos_order_id` where available
* `pos_provider_id`
* `pos_adapter_id`
* `idempotency_key`
* `correlation_id`
* cancellation reason
* requesting actor or system reference

Optional:

* staff approval reference
* payment cancellation reference
* kitchen state reference
* customer-facing cancellation reason code

### Output Contract

Must return:

* normalized result category
* provider cancellation status
* provider timestamp where available
* evidence reference
* refund dependency where applicable
* recovery requirement
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required.

Duplicate cancellation must not create conflicting provider states.

### Timeout Behavior

Cancellation timeout must return `unknown`.

### Retry Behavior

Safe retry depends on provider cancellation idempotency and current state.

### Error Behavior

State conflict, unsupported operation, timeout, and unknown result must be normalized.

### Evidence Requirement

Must preserve cancellation request, provider response, and cancellation actor.

### Manual Recovery Requirement

Required when kitchen, payment, and POS states conflict.

## 15. authorizePayment

### Purpose

Request or confirm payment authorization when the POS provider contract includes payment behavior.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `payment_id`
* `amount`
* `currency`
* `payment_method_type`
* `pos_provider_id`
* `pos_adapter_id`
* `idempotency_key`
* `correlation_id`

Optional:

* external payment transaction reference
* card approval reference
* wallet approval reference
* customer masked reference

### Output Contract

Must return:

* normalized result category
* payment authorization status
* payment transaction ID where available
* provider approval code where available
* provider timestamp where available
* evidence reference
* recovery requirement
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required.

Duplicate payment authorization must be prevented.

### Timeout Behavior

Payment timeout must return `unknown` unless provider evidence proves failure.

### Retry Behavior

Unsafe retry must be blocked unless idempotency is guaranteed.

### Error Behavior

Duplicate payment, authorization failure, timeout, unknown result, and provider unavailability must be normalized.

### Evidence Requirement

Must preserve transaction identifiers and masked payment evidence.

### Manual Recovery Requirement

Required for unknown or duplicate payment risk.

## 16. cancelPayment

### Purpose

Cancel a payment authorization or payment transaction where supported.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `payment_id`
* `payment_transaction_id`
* `amount`
* `pos_provider_id`
* `pos_adapter_id`
* `idempotency_key`
* `correlation_id`
* cancellation reason

Optional:

* staff approval reference
* linked order cancellation reference

### Output Contract

Must return:

* normalized result category
* payment cancellation status
* provider cancellation ID where available
* provider timestamp where available
* evidence reference
* recovery requirement
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required.

Duplicate payment cancellation must not create conflicting state.

### Timeout Behavior

Timeout must return `unknown`.

### Retry Behavior

Retry requires idempotency or provider status verification.

### Error Behavior

Duplicate, already canceled, failed, pending, and unknown states must be normalized.

### Evidence Requirement

Must preserve payment cancellation evidence.

### Manual Recovery Requirement

Required when order cancellation and payment cancellation disagree.

## 17. refundPayment

### Purpose

Request or confirm refund where the provider supports refund processing.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `payment_id`
* `payment_transaction_id`
* `refund_amount`
* `currency`
* `refund_reason`
* `pos_provider_id`
* `pos_adapter_id`
* `idempotency_key`
* `correlation_id`

Optional:

* staff approval reference
* customer support case reference
* partial refund line item references

### Output Contract

Must return:

* normalized result category
* refund status
* refund transaction ID where available
* provider timestamp where available
* evidence reference
* recovery requirement
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required.

Duplicate refunds must be prevented.

### Timeout Behavior

Refund timeout must return `unknown`.

### Retry Behavior

Retry must be blocked unless provider status verification or idempotency makes it safe.

### Error Behavior

Refund failed, refund pending, refund unknown, duplicate refund, and unsupported refund must be normalized.

### Evidence Requirement

Must preserve refund evidence and approval reference.

### Manual Recovery Requirement

Required for unknown refund or partial refund conflict.

## 18. getOrderStatus

### Purpose

Query provider-side order status.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `pos_order_id` where available
* `pos_provider_id`
* `pos_adapter_id`
* `correlation_id`

Optional:

* provider receipt ID
* provider transaction ID
* polling reason
* reconciliation ID

### Output Contract

Must return:

* normalized result category
* provider order status
* provider timestamp where available
* evidence reference
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

No mutation; idempotency key is not required.

### Timeout Behavior

Timeout must return provider timeout or unknown.

### Retry Behavior

Safe to retry within rate limit and polling policy.

### Error Behavior

Not found, unavailable, timeout, and state conflict must be normalized.

### Evidence Requirement

Must record status response reference.

### Manual Recovery Requirement

Required when provider status conflicts with internal state.

## 19. getPaymentStatus

### Purpose

Query provider-side or linked payment status where supported.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `payment_id`
* `payment_transaction_id` where available
* `pos_provider_id`
* `pos_adapter_id`
* `correlation_id`

Optional:

* reconciliation ID
* polling reason

### Output Contract

Must return:

* normalized result category
* provider payment status
* provider timestamp where available
* evidence reference
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

No mutation; idempotency key is not required.

### Timeout Behavior

Timeout must return provider timeout or unknown.

### Retry Behavior

Safe to retry within rate limit and polling policy.

### Error Behavior

Not found, unavailable, timeout, and state conflict must be normalized.

### Evidence Requirement

Must record payment status response reference.

### Manual Recovery Requirement

Required when payment provider and POS provider disagree.

## 20. syncMenu

### Purpose

Synchronize menu, price, option, and item metadata where supported.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `pos_provider_id`
* `pos_adapter_id`
* `correlation_id`
* sync direction
* sync scope

Optional:

* menu version
* item IDs
* category IDs
* price group IDs
* option group IDs
* scheduled sync timestamp

### Output Contract

Must return:

* normalized result category
* synced item count
* failed item count
* skipped item count
* provider menu version where available
* evidence reference
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required for write-side sync.

Read-only sync does not require mutation idempotency.

### Timeout Behavior

Timeout must return unknown or partial result depending on evidence.

### Retry Behavior

Retry is allowed only if duplicate menu mutation risk is controlled.

### Error Behavior

Partial sync, unsupported fields, validation errors, and provider limitations must be reported.

### Evidence Requirement

Must record sync summary and provider limitation list.

### Manual Recovery Requirement

Required when menu, price, option, or sold-out state mismatch affects customer ordering.

## 21. syncAvailability

### Purpose

Synchronize sold-out, availability, stock-related availability, or service availability where supported.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `pos_provider_id`
* `pos_adapter_id`
* `correlation_id`
* availability scope

Optional:

* item IDs
* option IDs
* sold-out status
* available quantity
* effective start/end time
* manual override reference

### Output Contract

Must return:

* normalized result category
* updated availability count
* failed availability count
* provider timestamp where available
* evidence reference
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required for write-side availability changes.

### Timeout Behavior

Timeout must return unknown or partial result depending on provider evidence.

### Retry Behavior

Retry is allowed only when duplicate or stale availability update risk is controlled.

### Error Behavior

Unsupported availability field, provider conflict, timeout, and partial sync must be normalized.

### Evidence Requirement

Must record before/after availability where available.

### Manual Recovery Requirement

Required when customer ordering may be affected by inaccurate availability.

## 22. recoverTransaction

### Purpose

Attempt recovery of a failed, unknown, partial, duplicated, or conflicting transaction.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* `order_id`
* `pos_provider_id`
* `pos_adapter_id`
* `correlation_id`
* recovery reason
* failure or unknown-state evidence reference

Optional:

* payment ID
* POS order ID
* POS transaction ID
* receipt ID
* reconciliation ID
* manual recovery ID
* human approval reference

### Output Contract

Must return:

* normalized result category
* recovery action performed
* recovery result
* unresolved risk
* evidence reference
* reconciliation requirement
* manual review requirement

### Idempotency Requirement

Required for state-changing recovery.

### Timeout Behavior

Timeout during recovery must return unknown and preserve evidence.

### Retry Behavior

Recovery retry requires human review when duplicate payment, duplicate order, cancellation, or refund risk exists.

### Error Behavior

Recovery failure, partial recovery, unknown recovery, and state conflict must be normalized.

### Evidence Requirement

Must preserve original failure evidence and recovery evidence.

### Manual Recovery Requirement

Human approval is required for high-risk recovery actions.

## 23. reconcileTransactions

### Purpose

Compare internal runtime state with provider, payment, POS, KDS, DID, and evidence records.

### Input Contract

Required:

* `tenant_id`
* `store_id`
* reconciliation scope
* reconciliation time window
* `correlation_id`

Optional:

* order ID
* payment ID
* POS transaction ID
* provider name
* reconciliation reason
* manual review reference

### Output Contract

Must return:

* normalized result category
* matched transaction count
* mismatched transaction count
* unresolved transaction count
* duplicate risk count
* refund risk count
* payment/order split-brain count
* recommended recovery actions
* evidence reference
* manual review requirement

### Idempotency Requirement

No mutation unless reconciliation also performs recovery.

Read-only reconciliation must be safe to repeat.

### Timeout Behavior

Timeout must produce partial or unknown reconciliation result with evidence.

### Retry Behavior

Safe to retry read-only reconciliation.

### Error Behavior

Provider unavailable, partial data, missing evidence, state conflict, and unknown result must be normalized.

### Evidence Requirement

Must preserve reconciliation result summary and unresolved mismatch list.

### Manual Recovery Requirement

Required when reconciliation finds financial or operational mismatch.

## 24. Capability Reporting Requirement

Every provider adapter must report its capabilities.

Minimum capability fields:

* official API availability
* sandbox availability
* order create support
* order update support
* order cancel support
* payment authorization support
* payment cancel support
* refund support
* receipt ID support
* menu sync support
* price sync support
* option sync support
* sold-out sync support
* webhook support
* polling support
* local integration requirement
* cloud integration availability
* authentication method
* rate limit
* retry behavior
* idempotency support
* reconciliation support
* evidence availability
* known limitation
* support status

Capability reporting must feed:

```text
000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md
```

## 25. Unsupported Operation Rule

If a provider does not support an operation, the adapter must return `unsupported`.

The adapter must not simulate official support using:

* scraping
* undocumented bypass
* hidden local automation
* reverse engineering
* manual workaround disguised as API integration
* credential sharing outside approved scope

Unsupported features may be handled by manual operation only if clearly documented and approved.

## 26. Split-Brain Rule

The contract must preserve split-brain cases.

Examples:

```text
Payment succeeded, but POS order failed.
Payment succeeded, but POS order status is unknown.
POS order succeeded, but KDS display failed.
POS order succeeded, but DID callout failed.
Cancel succeeded in POS, but payment cancel failed.
Refund request timed out and provider result is unknown.
Menu sync succeeded, but sold-out sync failed.
```

These must not be hidden as normal success.

They must trigger recovery, reconciliation, manual review, or degraded operation according to downstream rules.

## 27. Security Boundary

The adapter contract must not require vendors or adapters to access:

* production database directly
* Supabase admin key
* production payment credentials outside approved vault
* customer PII outside approved masking boundary
* RLS policy modification
* deployment permission
* unrelated runtime modules

Adapters must operate through approved interfaces and approved credentials only.

## 28. Acceptance Criteria

This specification is acceptable only if it confirms that:

* provider adapters are translators only
* interface methods are clearly defined
* identifiers are preserved
* result categories are normalized
* evidence is mandatory
* payment success and order success remain separate
* unknown state remains explicit
* idempotency is required for state-changing operations
* retry is not allowed when unsafe
* recovery and reconciliation requirements are represented
* unsupported operations are not disguised as support
* no implementation is authorized by this document

## 29. Final Rule

```text
The adapter contract must make provider differences manageable.
It must not allow provider differences to redefine our business authority, state machine, recovery policy, reconciliation policy, or evidence requirements.
```
