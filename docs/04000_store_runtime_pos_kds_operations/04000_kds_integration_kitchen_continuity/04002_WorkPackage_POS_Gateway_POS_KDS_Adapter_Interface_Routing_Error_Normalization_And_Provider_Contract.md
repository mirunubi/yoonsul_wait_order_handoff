# 04002_WorkPackage_POS_Gateway_POS_KDS_Adapter_Interface_Routing_Error_Normalization_And_Provider_Contract

## 1. Purpose

This document defines the implementation work package for POS Gateway POS/KDS adapter interface, routing, error normalization, and provider contract implementation.

After registry, menu mapping, transaction state machine, and idempotency/queue safety exist, the gateway must communicate with external POS and KDS providers through a controlled adapter boundary.

The POS Gateway must not let provider-specific behavior leak into the transaction core.

Every provider differs in:

- order write API;
- order lookup API;
- cancellation support;
- receipt lookup;
- table mapping;
- menu code structure;
- KDS ticket routing;
- idempotency support;
- timeout behavior;
- error codes;
- webhook behavior;
- settlement reference;
- rate limit;
- sandbox/production behavior;
- retry safety.

This work package creates the adapter interface and provider contract boundary so that the gateway can support multiple providers, swap providers, normalize errors, and preserve transaction truth without rewriting the core transaction model.

---

## 2. Scope

This work package covers implementation of:

- generic POS adapter interface;
- generic KDS adapter interface;
- provider contract registry binding;
- provider operation capability validation;
- provider request envelope;
- provider response envelope;
- provider error normalization;
- provider timeout classification;
- provider unknown-result handling;
- POS order write contract;
- POS order lookup contract;
- POS cancellation lookup contract;
- POS receipt lookup contract;
- KDS ticket create contract;
- KDS ticket lookup contract;
- KDS duplicate prevention hook;
- provider route selection integration;
- provider contract tests;
- provider adapter version compatibility;
- sandbox/production parity checks;
- adapter audit events;
- provider hot-swap readiness.

This document does not define full provider-specific technical specs.  
Provider-specific specs should move to the `06700` band.

---

## 3. Core Principle

Provider-specific implementation must be behind an adapter boundary.

The POS Gateway core must speak in normalized operations:

```text
create_pos_order
lookup_pos_order
cancel_pos_order
lookup_receipt
create_kds_ticket
lookup_kds_ticket
```

External providers may have different APIs, payloads, response formats, and failure modes.

The gateway core must not depend on those differences.

Adapters translate provider-specific behavior into normalized gateway results.

---

## 4. Implementation Position

This work package follows:

```text
14153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md
14154_WorkPackage_POS_Gateway_Menu_Mapping_Price_Availability_And_Calculation_Snapshot_Implementation.md
14155_WorkPackage_POS_Gateway_Order_Payment_Cancel_Refund_State_Machine_And_Transaction_Timeline_Implementation.md
14156_WorkPackage_POS_Gateway_Idempotency_Queue_Retry_Dead_Letter_Replay_And_Duplicate_Prevention_Implementation.md
```

This work package precedes:

```text
14157_WorkPackage_POS_Gateway_Table_QR_NFC_Kiosk_Device_Receipt_Proof_And_Customer_Status_Implementation.md
14158_WorkPackage_POS_Gateway_Manual_Fallback_Manager_Approval_Staff_Action_And_Override_Implementation.md
14159_WorkPackage_POS_Gateway_Reconciliation_Audit_Evidence_Settlement_And_Accounting_Guard_Implementation.md
06390_WorkPackage_POS_Gateway_Monitoring_Incident_Disaster_Recovery_Pilot_Readiness_And_Implementation_Closeout.md
```

Adapter execution must use registry, state machine, idempotency, and queue controls.

---

## 5. Required Implementation Domains

The implementation must define these domains:

```text
adapter_contract
adapter_operation
adapter_request_envelope
adapter_response_envelope
provider_payload_transform
provider_error_mapping
provider_timeout_classification
provider_operation_result
provider_external_reference_binding
provider_route_resolution
pos_order_write_contract
pos_order_lookup_contract
pos_cancel_contract
pos_receipt_contract
kds_ticket_create_contract
kds_ticket_lookup_contract
provider_contract_test
sandbox_production_parity_check
adapter_hot_swap_record
```

The exact table/class structure may vary, but these concepts must remain explicit.

---

## 6. Adapter Contract Model

Adapter contract defines the common interface each provider adapter must implement.

Required fields:

```text
adapter_contract_id
provider_id
adapter_code
adapter_version
contract_version
supported_operation_types
required_capabilities
known_limitations
release_status
effective_from_utc
effective_until_utc
status
```

Supported operation types:

```text
create_pos_order
lookup_pos_order
cancel_pos_order
lookup_pos_cancellation
lookup_receipt
create_kds_ticket
lookup_kds_ticket
sync_menu
sync_sold_out
import_settlement
```

Adapter contract must link to provider capability and limitation registry.

---

## 7. Adapter Operation Interface

Every adapter operation must implement the same normalized execution shape.

Recommended interface:

```text
prepareRequest(context, normalizedCommand)
execute(requestEnvelope)
normalizeResponse(rawProviderResponse)
classifyResult(normalizedResponse)
bindExternalReferences(result)
emitAdapterAudit(result)
```

Adapter must not directly mutate final transaction state without going through state transition service.

The adapter returns normalized result.  
The transaction layer applies state transition.

---

## 8. Provider Request Envelope

Provider request envelope wraps outbound provider call.

Required fields:

```text
request_envelope_id
transaction_id
queue_job_id
idempotency_key_id
provider_id
provider_environment_id
adapter_version_id
operation_type
normalized_command_ref
provider_payload_ref
request_hash
timeout_ms
created_at_utc
correlation_id
```

The envelope must not expose raw secrets.

Credentials must be resolved at execution time through approved secret reference.

---

## 9. Provider Response Envelope

Provider response envelope wraps inbound provider response.

Required fields:

```text
response_envelope_id
request_envelope_id
transaction_id
provider_id
operation_type
provider_status_code
provider_error_code
raw_response_ref
normalized_result_status
normalized_error_code
external_reference_id
received_at_utc
duration_ms
correlation_id
```

Raw response should be stored only according to sensitive payload policy.

Normalized response must be sufficient for state transition and reconciliation.

---

## 10. Normalized Result Status

Adapter must convert provider response to normalized result statuses.

Required statuses:

```text
confirmed_success
confirmed_failure
pending
unknown
retryable_failure
non_retryable_failure
duplicate_detected
manual_lookup_required
manual_review_required
provider_not_supported
provider_rate_limited
provider_auth_failed
provider_maintenance
schema_mismatch
```

The adapter must never return ambiguous provider result as confirmed success.

---

## 11. Error Normalization

Provider-specific error codes must map to normalized gateway error codes.

Required mapping fields:

```text
provider_error_mapping_id
provider_id
operation_type
provider_error_code
provider_error_message_pattern
normalized_error_code
retry_classification
severity
manual_review_required_flag
reconciliation_required_flag
status
```

Example normalized error codes:

```text
provider_timeout
provider_connection_failed
provider_rate_limited
provider_auth_failed
provider_validation_failed
provider_duplicate_reference
provider_unknown_result
provider_operation_not_supported
provider_schema_changed
provider_maintenance
provider_internal_error
```

Unknown provider errors must default to safe classification.

---

## 12. Timeout Classification

Timeouts must be classified according to operation risk.

Timeout after mutation request may mean the provider actually processed the action.

Timeout classification must include:

```text
operation_type
request_sent_flag
provider_received_unknown_flag
mutation_risk_flag
lookup_supported_flag
retry_safe_flag
next_action
```

Recommended next actions:

```text
perform_lookup
mark_unknown
schedule_lookup_retry
manual_lookup_required
manual_review_required
dead_letter_required
```

Timeout must not automatically retry mutation unless provider idempotency is verified.

---

## 13. Provider Route Resolution

Adapter execution must use route resolution from registry and routing policy.

Route resolution input:

```text
tenant_id
store_id
operation_type
channel
provider_type
currency_code
payment_method
business_context
```

Route resolution output:

```text
provider_id
provider_environment_id
adapter_version_id
credential_reference_id
route_eligibility_status
capability_status
limitation_status
circuit_breaker_state
rate_limit_status
```

If route cannot be resolved safely, adapter execution must not start.

---

## 14. POS Order Write Contract

POS order write contract must define normalized input.

Required normalized command fields:

```text
transaction_id
tenant_id
store_id
order_channel
fulfillment_type
business_date_local
created_at_utc
local_timezone_name
mapping_version_id
calculation_snapshot_id
line_items
amount_components
customer_safe_note
table_session_ref
staff_actor_ref
idempotency_key
```

Line item must include:

```text
menu_item_id
provider_item_code
quantity
selected_options
selected_modifiers
line_amount_minor
tax_refs
kds_category_ref
```

Provider payload is generated from normalized command and provider mapping.

---

## 15. POS Order Write Result

POS order write result must return normalized output.

Required fields:

```text
result_status
pos_order_id
provider_order_reference
provider_receipt_reference
provider_created_at
provider_business_day
provider_status
external_reference_refs
raw_response_ref
normalized_error_code
next_action
```

`result_status = confirmed_success` requires sufficient provider evidence that the POS order was created.

---

## 16. POS Order Lookup Contract

POS order lookup contract is mandatory for unknown write recovery where provider supports it.

Lookup input:

```text
transaction_id
provider_order_reference
idempotency_key
store_id
business_date_local
amount_minor
created_at_utc_range
```

Lookup output:

```text
found_flag
pos_order_id
provider_order_status
amount_minor
created_at_provider
receipt_reference
match_confidence
normalized_result_status
```

Lookup must be used before retrying unknown POS write when possible.

---

## 17. POS Cancellation Contract

POS cancellation contract must distinguish cancellation request from confirmed cancellation.

Required input:

```text
transaction_id
pos_order_id
provider_order_reference
cancel_reason_code
requested_by_actor_id
approval_reference
idempotency_key
```

Required output:

```text
result_status
provider_cancel_reference
provider_order_status
cancel_confirmed_flag
normalized_error_code
next_action
```

If provider does not support cancellation, capability registry must block automatic cancellation.

---

## 18. Receipt Lookup Contract

Receipt lookup contract must retrieve provider receipt/proof reference.

Required input:

```text
transaction_id
pos_order_id
provider_order_reference
business_date_local
store_id
```

Required output:

```text
receipt_found_flag
receipt_reference
receipt_number
receipt_amount_minor
receipt_created_at
receipt_payload_ref
normalized_result_status
```

Receipt lookup failure must not erase order/payment state.

It may trigger proof pending or reconciliation marker.

---

## 19. KDS Ticket Create Contract

KDS ticket creation must use normalized kitchen command.

Required input:

```text
transaction_id
store_id
kds_route_id
order_channel
fulfillment_type
line_items
preparation_notes
table_session_ref
priority
idempotency_key
created_at_utc
```

Required output:

```text
result_status
kds_ticket_id
provider_ticket_reference
kds_station_reference
provider_status
normalized_error_code
next_action
```

KDS ticket create must use duplicate prevention.

A duplicate KDS ticket can cause duplicate cooking and food waste.

---

## 20. KDS Ticket Lookup Contract

KDS lookup must support recovery from unknown KDS create result.

Required input:

```text
transaction_id
kds_ticket_id
provider_ticket_reference
store_id
created_at_utc_range
```

Required output:

```text
found_flag
kds_ticket_status
kds_station_reference
match_confidence
normalized_result_status
```

If KDS lookup is unsupported, unknown KDS state must route to manual kitchen verification.

---

## 21. Provider Payload Transform

Provider payload transform must be versioned.

Required fields:

```text
payload_transform_id
provider_id
adapter_version_id
operation_type
mapping_version_id
transform_version
input_schema_version
output_schema_version
created_at_utc
status
```

Payload transform must be deterministic.

The same normalized command and same transform version should produce the same provider payload.

---

## 22. Raw Provider Payload Policy

Raw provider payloads must be handled as sensitive evidence.

Rules:

- store raw request/response only when needed;
- store by reference;
- encrypt where appropriate;
- redact secrets;
- classify personal/payment data;
- set retention category;
- make normalized result independent from raw payload;
- audit access.

Raw payload must not be required for ordinary customer support display.

---

## 23. External Reference Binding

Adapter results must bind external references.

Reference types:

```text
pos_order_id
provider_order_reference
provider_receipt_reference
kds_ticket_id
provider_ticket_reference
cancel_reference
refund_reference
settlement_reference
```

Binding must include:

```text
transaction_id
provider_id
reference_type
reference_value
confidence_level
source_operation
created_at_utc
```

External references must be unique where provider guarantees uniqueness.

---

## 24. Provider Idempotency Support

Adapter must declare whether provider supports idempotency.

Provider idempotency modes:

```text
native_idempotency_key
provider_reference_deduplication
lookup_based_recovery
no_idempotency_support
unknown
```

If provider has no idempotency support, mutation retry policy must be stricter.

No-idempotency provider may require manual lookup after timeout.

---

## 25. Provider Webhook Compatibility

Provider adapters may receive webhook events.

Webhook compatibility must define:

```text
webhook_event_type
provider_event_id
deduplication_key
signature_validation_required
event_ordering_guarantee
state_update_domain
normalized_event_type
```

Webhook processing must be idempotent.

Webhook must not blindly override newer gateway state.

---

## 26. Provider Schema Drift Detection

Provider schema may change unexpectedly.

Schema drift signals:

- missing expected field;
- new error code;
- changed status value;
- amount field format change;
- receipt format change;
- webhook signature change;
- endpoint response shape change.

Schema drift must trigger:

```text
adapter_warning
provider_incident_if_critical
route_restriction_if_needed
contract_test_update
manual_review_for_affected_transactions
```

Adapter must fail safely on unknown schema.

---

## 27. Sandbox / Production Parity Check

Provider sandbox may not behave like production.

Parity check must track:

```text
provider_id
operation_type
sandbox_behavior
production_behavior
difference_description
risk_level
compensating_control
last_verified_at_utc
```

Known sandbox/production difference must be documented in limitation registry.

Provider certification must not assume parity.

---

## 28. Adapter Version Compatibility

Adapter version must be compatible with:

- provider environment;
- provider capability;
- mapping version;
- calculation snapshot version;
- state machine contract version;
- idempotency contract version;
- queue execution contract version.

Compatibility record must include:

```text
adapter_version_id
contract_version
compatible_from
compatible_until
breaking_change_flag
migration_required_flag
status
```

Incompatible adapter must not execute production mutation.

---

## 29. Provider Hot-Swap Readiness

Adapter boundary must support provider hot-swap.

Hot-swap requires:

- provider-independent transaction state;
- normalized operation contract;
- external reference abstraction;
- route eligibility switch;
- mapping version per provider;
- settlement route metadata per provider;
- rollback route;
- provider retirement plan.

Provider-specific code must not be embedded in core transaction logic.

---

## 30. Adapter Execution Flow

Recommended execution flow:

```text
resolve gateway context
resolve route eligibility
validate provider capability
validate idempotency and mutation guard
create request envelope
transform normalized command to provider payload
check circuit breaker
check rate limit
execute provider request
capture response envelope
normalize response
classify result
bind external reference
record idempotency result
request state transition
emit audit event
```

Every step must be observable.

---

## 31. Adapter Failure Flow

Recommended failure flow:

```text
capture failure
normalize error
classify retry safety
update queue retry or dead-letter
mark state unknown if mutation result uncertain
create manual review marker if needed
create reconciliation marker if financial risk exists
emit audit event
alert if threshold exceeded
```

Failure handling must not skip state machine.

---

## 32. Provider Contract Test

Each adapter must pass provider contract tests.

Required tests:

```text
create_pos_order_success
create_pos_order_validation_failure
create_pos_order_timeout_after_send
lookup_pos_order_found
lookup_pos_order_not_found
cancel_pos_order_success_or_not_supported
receipt_lookup_success_or_not_supported
create_kds_ticket_success
create_kds_ticket_duplicate_prevention
provider_error_normalization
schema_mismatch_safe_failure
idempotency_support_behavior
rate_limit_behavior
sandbox_production_difference_recorded
```

Contract tests must run before provider activation.

---

## 33. Adapter Certification Status

Adapter certification must track readiness.

Recommended statuses:

```text
not_started
development
internal_test_passed
contract_test_passed
sandbox_certified
production_shadow_ready
pilot_ready
production_ready
deprecated
retired
```

Only `pilot_ready` or `production_ready` adapters may execute scoped production traffic.

---

## 34. Data Model Draft

Recommended table group:

```text
pos_gateway_adapter_contracts
pos_gateway_adapter_operations
pos_gateway_adapter_versions
pos_gateway_adapter_compatibility_records
pos_gateway_provider_request_envelopes
pos_gateway_provider_response_envelopes
pos_gateway_provider_payload_transforms
pos_gateway_provider_error_mappings
pos_gateway_provider_timeout_classifications
pos_gateway_provider_operation_results
pos_gateway_provider_external_references
pos_gateway_provider_webhook_events
pos_gateway_provider_schema_drift_cases
pos_gateway_sandbox_production_parity_checks
pos_gateway_provider_contract_tests
pos_gateway_adapter_certification_statuses
pos_gateway_adapter_hot_swap_records
```

The implementation may store raw payload externally, but references and normalized results must remain queryable.

---

## 35. API Requirements

Recommended internal APIs or service methods:

```text
registerAdapterContract()
registerAdapterVersion()
validateAdapterCompatibility()
createProviderRequestEnvelope()
transformProviderPayload()
executeAdapterOperation()
normalizeProviderResponse()
normalizeProviderError()
classifyProviderTimeout()
bindProviderExternalReference()
processProviderWebhook()
detectProviderSchemaDrift()
runProviderContractTest()
updateAdapterCertificationStatus()
resolveProviderHotSwapReadiness()
```

Adapters must use common service boundaries for audit and state transition.

---

## 36. Denial Reason Codes

Recommended denial reason codes:

```text
adapter_contract_missing
adapter_version_incompatible
provider_capability_missing
provider_limitation_blocking
provider_route_not_eligible
provider_environment_disabled
provider_credential_missing
provider_operation_not_supported
provider_schema_mismatch
provider_timeout_unknown_result
provider_auth_failed
provider_rate_limited
provider_circuit_open
provider_lookup_required
adapter_contract_test_not_passed
adapter_not_certified
```

Denial reason must be recorded internally and mapped to safe operator/customer messages later.

---

## 37. Audit Event Requirements

Required audit events:

```text
pos_gateway.adapter.contract_registered
pos_gateway.adapter.version_registered
pos_gateway.adapter.compatibility_checked
pos_gateway.adapter.request_envelope_created
pos_gateway.adapter.response_envelope_received
pos_gateway.adapter.response_normalized
pos_gateway.adapter.error_normalized
pos_gateway.adapter.external_reference_bound
pos_gateway.adapter.timeout_classified
pos_gateway.adapter.schema_drift_detected
pos_gateway.adapter.contract_test_completed
pos_gateway.adapter.certification_status_changed
pos_gateway.adapter.hot_swap_readiness_checked
```

Audit must include:

```text
tenant_id
store_id
transaction_id
provider_id
adapter_version_id
operation_type
created_at_utc
correlation_id
```

Raw secrets must not be included.

---

## 38. Monitoring Requirements

Monitoring must detect:

- adapter operation success rate;
- adapter operation timeout rate;
- normalized unknown result rate;
- provider error code spike;
- schema drift cases;
- contract test failures;
- webhook duplicate rate;
- webhook delay;
- receipt lookup failure rate;
- POS write lookup failure rate;
- KDS ticket create failure rate;
- adapter version mismatch;
- production traffic on uncertified adapter;
- provider route using deprecated adapter.

Monitoring must be scoped by tenant, store, provider, adapter version, operation type, and channel.

---

## 39. Alert Requirements

Critical alerts:

```text
adapter_unknown_result_rate_high
provider_schema_drift_detected
production_adapter_not_certified
pos_order_write_failure_spike
pos_order_lookup_unavailable_after_unknown
kds_ticket_duplicate_risk
receipt_lookup_failure_spike
provider_error_unmapped_spike
webhook_signature_validation_failed
adapter_version_incompatible_in_production
```

Alerts must link to provider runbook and dead-letter/manual review process.

---

## 40. Test Requirements

Required tests:

```text
adapter_contract_required_test
adapter_version_compatibility_test
provider_route_resolution_test
request_envelope_no_secret_test
payload_transform_determinism_test
response_normalization_success_test
error_normalization_test
timeout_after_mutation_unknown_test
POS_order_write_result_classification_test
POS_order_lookup_recovery_test
KDS_ticket_create_result_classification_test
receipt_lookup_result_classification_test
external_reference_binding_test
webhook_deduplication_test
schema_drift_safe_failure_test
sandbox_production_parity_record_test
hot_swap_contract_independence_test
```

Adapter tests must be part of provider onboarding and release governance.

---

## 41. Acceptance Criteria

This work package is acceptable only when:

- generic POS adapter interface exists;
- generic KDS adapter interface exists;
- adapter contract model exists;
- adapter operation interface exists;
- request and response envelopes exist;
- normalized result status exists;
- provider error normalization exists;
- timeout classification exists;
- provider route resolution integration exists;
- POS order write and lookup contracts exist;
- POS cancellation and receipt lookup contracts exist;
- KDS ticket create and lookup contracts exist;
- provider payload transform exists;
- raw provider payload policy exists;
- external reference binding exists;
- provider idempotency support model exists;
- webhook compatibility exists;
- schema drift detection exists;
- sandbox/production parity check exists;
- adapter version compatibility exists;
- provider hot-swap readiness exists;
- adapter execution and failure flows exist;
- provider contract tests and adapter certification status exist;
- data model, APIs, denial codes, audit, monitoring, alerts, and tests exist.

---

## 42. Relationship To Adjacent Documents

This document is related to:

- 06340 WorkPackage POS Gateway idempotency, queue, retry, dead-letter, replay, and duplicate prevention implementation;
- 06330 WorkPackage POS Gateway order, payment, cancel, refund state machine, and transaction timeline implementation;
- 06320 WorkPackage POS Gateway menu mapping, price, availability, and calculation snapshot implementation;
- 06310 WorkPackage POS Gateway core registry, tenant, store, provider capability, and environment binding implementation;
- 06305 Governance POS Gateway global scale final boss risk absorption architecture invariant implementation;
- 06190 Policy POS Gateway vendor, provider, SLA, contract limitation, liability, escalation, and service governance;
- 06020 Policy POS Gateway multi-provider routing, fallback, provider priority, and store-specific adapter selection;
- 06010 Policy POS Gateway provider onboarding, certification, capability verification, and expansion control.

Where conflict exists, this document governs implementation of POS/KDS adapter interface, routing, provider contract, error normalization, and hot-swap-ready provider boundary behavior.

---

## 43. Summary

The adapter layer is the wall between the POS Gateway core and provider chaos.

External providers may be inconsistent, incomplete, slow, undocumented, or unstable.

The gateway core must remain stable.

The correct implementation standard is:

- normalized operation contracts;
- provider-specific payload transformation behind adapters;
- response and error normalization;
- timeout classification;
- lookup before unsafe retry;
- external reference binding;
- schema drift detection;
- contract tests;
- adapter certification;
- hot-swap readiness.

A provider can fail.  
A provider can change.  
A provider can be replaced.

The gateway core must survive all three.