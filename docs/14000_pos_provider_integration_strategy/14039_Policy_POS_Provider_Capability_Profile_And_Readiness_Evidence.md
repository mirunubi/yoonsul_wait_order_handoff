# 14039_Policy_POS_Provider_Capability_Profile_And_Readiness_Evidence

## 1. Purpose

This policy defines how each POS provider must be evaluated, profiled, tested, and approved before it can be attached to production order, payment, waiting, table, kitchen, inventory, settlement, or reconciliation flows.

The purpose is to convert the POS Gateway field exception catalog into provider-specific readiness evidence.

A POS provider must not be treated as production-ready merely because its API can accept an order.

A provider is production-ready only when its capabilities, limitations, degraded paths, manual recovery requirements, resilience behavior, financial behavior, local infrastructure behavior, and audit evidence have been documented and verified.

## 2. Scope

This policy applies to:

* POS provider capability profile
* Provider onboarding readiness
* Provider integration mode classification
* Provider API contract evidence
* Provider local agent evidence
* Provider printer evidence
* Provider menu and option support
* Provider master data validation support
* Provider payment and refund support
* Provider table and business day support
* Provider sales channel and tax support
* Provider rate limit and timeout behavior
* Provider idempotency support
* Provider schema validation evidence
* Provider degraded operation classification
* Provider manual recovery requirements
* Provider production readiness approval

This policy applies to all POS providers, including modern cloud POS, legacy POS, local middleware POS, printer-only fallback, manual-assisted POS, delivery-channel POS, and future unknown providers.

## 3. Core Principle

Provider readiness must be evidence-based.

The platform must not integrate a POS provider based on assumptions, sales claims, screenshots, informal documentation, or one happy-path API test.

Every provider must be evaluated against the POS Gateway resilience catalog.

If a provider cannot support a required capability, the limitation must be declared, classified, and mapped to one of:

* Blocked integration
* Degraded integration
* Manual-assisted integration
* Store-limited integration
* Pilot-only integration
* Production-ready integration with known constraints

## 4. Provider Readiness Boundary

Provider readiness sits between policy design and production integration.

```
[05300 POS Gateway Field Exception Catalog]
                     |
                     v
    [Provider Capability Profile And Evidence]
                     |
                     v
    [Provider Test Fixture And Simulation Pack]
                     |
                     v
    [Production Cutover / Pilot / Rollback Decision]
```

No provider should move to implementation or production pilot without a completed readiness profile.

## 5. Non-Negotiable Rules

### 5.1 Capability Profile Required Rule

Every POS provider must have a capability profile before production integration.

The profile must explicitly state what the provider supports, does not support, partially supports, or supports only through manual or degraded operation.

### 5.2 Unknown Means Not Ready Rule

If a provider capability is unknown, it must be treated as not ready for production-critical flow until verified.

Unknown support must not be assumed as supported.

### 5.3 Evidence Required Rule

Each claimed provider capability must have evidence.

Evidence may include:

* Official API documentation
* Contract document
* Sandbox test
* Production pilot test
* Provider confirmation
* Captured request and response
* Webhook sample
* Error sample
* Load or timeout test
* Store-side test evidence
* Audit sample

### 5.4 Degraded Mode Must Be Explicit Rule

If the provider cannot support a required feature, the integration must declare its degraded mode.

The system must not hide degraded operation behind normal production wording.

### 5.5 Provider Limits Must Shape Runtime Policy Rule

Provider rate limit, timeout behavior, idempotency support, sync model, webhook reliability, printer boundary, and financial behavior must directly configure Gateway runtime policy.

Readiness evidence must not remain a static document disconnected from implementation.

## 6. Provider Identity Profile

Each provider profile must include:

```
provider_id
provider_name
provider_type
provider_owner
provider_contact
integration_status
contract_status
documentation_status
sandbox_available
production_api_available
local_agent_required
provider_region
supported_store_types
supported_business_models
created_at
updated_at
approved_by
```

Provider identity must remain stable across adapter versions.

## 7. Integration Mode Classification

Each provider must be classified into one or more integration modes.

Allowed modes include:

```
FULL_CLOUD_API
LIMITED_CLOUD_API
LOCAL_AGENT_REQUIRED
PROVIDER_LOCAL_BRIDGE
PRINTER_DELEGATION_ONLY
DIRECT_PRINT_SUPPORTED
MANUAL_ASSISTED
PRINTER_ONLY_FALLBACK
READ_ONLY_SYNC_ONLY
PAYMENT_ONLY
ORDER_ONLY
UNSUPPORTED
```

Each mode must define production eligibility.

## 8. Core Capability Matrix

Each provider must declare support for:

```
supports_order_submit
supports_order_cancel
supports_order_modify
supports_order_status_query
supports_external_order_id
supports_idempotency_key
supports_payment_mapping
supports_payment_void
supports_payment_refund
supports_partial_refund
supports_split_payment
supports_coupon_mapping
supports_point_mapping
supports_discount_mapping
supports_tax_breakdown
supports_service_charge
supports_tip
supports_menu_sync
supports_price_validation
supports_sold_out_validation
supports_stock_hold
supports_table_sync
supports_table_move
supports_table_merge
supports_business_day_sync
supports_sales_channel_mapping
supports_unpaid_order
supports_service_order
supports_house_account
supports_kitchen_print_delegation
supports_kitchen_print_status
supports_direct_print
supports_webhook
supports_rate_limit_header
supports_retry_after
supports_schema_versioning
supports_local_agent
supports_reconciliation_export
```

Each field must be marked:

```
SUPPORTED
PARTIAL
UNSUPPORTED
UNKNOWN
MANUAL_ONLY
DEGRADED_ONLY
PROVIDER_DEPENDENT
STORE_DEPENDENT
```

## 9. Menu And Option Capability

The provider must declare menu and option support.

Required fields include:

```
menu_model_type
supports_flat_menu_code
supports_variant
supports_option_group
supports_option_item
supports_required_option
supports_optional_option
supports_multi_select_option
supports_quantity_option
supports_nested_option
supports_option_price_delta
supports_combo_code
supports_store_specific_menu_code
supports_menu_version
supports_multilingual_name
supports_kitchen_name
supports_text_truncation_rule
menu_sync_mode
menu_mapping_required
menu_transformer_required
```

Menu limitations must be mapped to transformer rules.

## 10. Master Data And Validation Capability

The provider must declare master data validation support.

Required fields include:

```
supports_live_price_validation
supports_live_sold_out_validation
supports_live_option_validation
supports_store_open_validation
supports_table_validation
supports_business_day_validation
supports_cached_master_export
supports_webhook_master_update
supports_scheduled_master_pull
master_sync_frequency
sold_out_sync_latency
price_sync_latency
validation_timeout_profile
stale_cache_risk_level
```

If live validation is unsupported, the provider must be marked with higher execution risk.

## 11. Payment And Financial Capability

The provider must declare financial capability.

Required fields include:

```
supports_platform_pg_mapping
supports_store_van_mapping
supports_external_payment_reference
supports_pg_approval_number_mapping
supports_van_approval_number_mapping
supports_receipt_number_query
supports_receipt_number_external_reference
receipt_number_ownership_model
supports_network_cancel_correlation
supports_refund_status_query
supports_void_status_query
supports_daily_sales_summary
supports_tax_breakdown
supports_vat_rounding_method
supports_sales_channel
supports_unpaid_receipt
supports_service_receipt
supports_house_account_receipt
supports_reconciliation_file
```

Financial capability must be reviewed more strictly than ordinary order capability.

## 12. Kitchen And Printer Capability

The provider must declare kitchen printing behavior.

Required fields include:

```
print_control_mode
supports_pos_delegated_print
supports_print_status
supports_kitchen_route
supports_station_routing
supports_reprint
supports_cancel_ticket
supports_remake_ticket
supports_direct_print
supports_esc_pos
supports_printer_status_query
supports_printer_ack
printer_status_reliability
direct_print_adapter_required
local_agent_print_required
duplicate_print_risk_level
```

POS ACK must not be treated as print ACK unless provider evidence proves it.

## 13. Local Agent And Hardware Capability

If provider requires local infrastructure, the profile must include:

```
local_agent_required
local_agent_owner
local_agent_version
supported_os
minimum_hardware_requirement
pos_app_health_check_supported
pos_pc_health_check_supported
printer_health_check_supported
local_queue_supported
local_queue_replay_supported
local_agent_heartbeat_supported
ip_change_detection_supported
local_restart_detection_supported
adaptive_timeout_required
local_resource_contention_risk
```

Legacy hardware risk must be classified before store onboarding.

## 14. Resilience Capability

The provider must declare resilience behavior.

Required fields include:

```
documented_rate_limit
observed_rate_limit
supports_retry_after
timeout_policy_known
average_latency_observed
p95_latency_observed
p99_latency_observed
supports_status_reconciliation
supports_safe_retry
supports_external_id_lookup
supports_duplicate_detection
provider_outage_behavior_known
provider_5xx_behavior_known
provider_429_behavior_known
circuit_breaker_profile_required
queue_replay_allowed
queue_replay_limitations
```

Unknown resilience behavior must block high-risk production rollout.

## 15. Schema And Contract Capability

The provider must declare schema and contract evidence.

Required fields include:

```
contract_version
adapter_version
request_schema_available
response_schema_available
webhook_schema_available
error_schema_available
enum_catalog_available
amount_field_policy_known
status_field_policy_known
unknown_field_policy
schema_versioning_supported
breaking_change_notice_policy
schema_drift_detection_required
raw_packet_audit_required
```

A provider without schema evidence must be treated as high risk.

## 16. Waiting, Table, And Journey Capability

For waiting-to-order or table flows, the provider must declare:

```
supports_waiting_entry_sync
supports_table_assignment
supports_table_occupancy_query
supports_table_move
supports_table_merge
supports_table_split
supports_no_show_mapping
supports_prepaid_waiting_order
supports_prepaid_cancel
supports_kitchen_cancel_after_waiting_cancel
supports_manual_entry_detection
supports_overbooking_prevention_signal
table_state_latency
journey_sync_risk_level
```

If provider cannot support journey synchronization, manual operator confirmation must be required.

## 17. Inventory And Stock Capability

The provider must declare inventory and sold-out support.

Required fields include:

```
supports_item_stock_query
supports_option_stock_query
supports_ingredient_stock_query
supports_stock_lock
supports_stock_hold
supports_stock_release
supports_atomic_stock_decrement
supports_sold_out_webhook
supports_manual_sold_out_event
supports_kitchen_shortage_event
stock_sync_latency
stock_race_risk_level
platform_hold_required
```

If stock atomicity is unknown, the provider must be treated as stock race risk.

## 18. Sales Channel And Settlement Capability

The provider must declare sales and settlement capability.

Required fields include:

```
supports_sales_channel_code
supports_smart_order_channel
supports_delivery_channel
supports_takeout_channel
supports_table_order_channel
supports_payment_collector_mapping
supports_pg_van_separation
supports_unpaid_order_code
supports_service_order_code
supports_house_account_code
supports_staff_meal_code
supports_owner_comp_code
supports_tax_export
supports_daily_closing_export
supports_business_day_export
supports_settlement_reconciliation
duplicate_tax_risk_level
```

If sales channel mapping is unsupported, finance readiness must mark risk.

## 19. Multi-Endpoint And Local Contention Capability

For stores with multiple POS endpoints or shared local resources, the provider profile must include:

```
supports_multiple_endpoints
supports_endpoint_routing
supports_legal_entity_routing
supports_channel_routing
supports_printer_route_mapping
supports_shared_printer_mode
supports_port_contention_detection
supports_delivery_app_coexistence
supports_manual_mutation_event
supports_pos_local_cancel_detection
supports_pos_local_void_detection
supports_receipt_delete_detection
malicious_mutation_detection_level
```

Multi-endpoint stores must not go live without routing evidence.

## 20. Readiness Status

Provider readiness must be classified.

Allowed statuses include:

```
NOT_STARTED
INFORMATION_GATHERING
DOCUMENTATION_REVIEW
SANDBOX_TESTING
LOCAL_STORE_TESTING
PILOT_READY
PILOT_IN_PROGRESS
PRODUCTION_READY_WITH_LIMITATIONS
PRODUCTION_READY
DEGRADED_ONLY
MANUAL_ONLY
BLOCKED
UNSUPPORTED
RETIRED
```

Status must be based on evidence, not opinion.

## 21. Readiness Risk Levels

Each provider must receive risk ratings.

Risk dimensions include:

```
menu_mapping_risk
payment_integrity_risk
refund_risk
kitchen_print_risk
local_hardware_risk
provider_latency_risk
schema_drift_risk
stock_race_risk
waiting_journey_risk
table_sync_risk
tax_reconciliation_risk
multi_endpoint_risk
manual_mutation_risk
operator_recovery_risk
```

Allowed ratings:

```
LOW
MEDIUM
HIGH
CRITICAL
UNKNOWN
```

Unknown risk must be treated conservatively.

## 22. Evidence Types

Readiness evidence may include:

```
official_documentation
provider_email_confirmation
api_contract_snapshot
sandbox_request_response
production_request_response
webhook_sample
error_payload_sample
status_query_sample
menu_sync_sample
payment_mapping_sample
refund_sample
receipt_sample
sales_channel_sample
business_day_sample
table_sync_sample
printer_test_sample
local_agent_health_sample
timeout_test_result
rate_limit_test_result
schema_drift_test_result
reconciliation_test_result
operator_recovery_test_result
```

Evidence must be linked to provider profile.

## 23. Minimum Production Evidence

A provider cannot be production-ready without evidence for:

* Order submit success
* Order submit failure
* Payment mapping
* Payment mismatch handling
* Refund or void behavior
* Menu mapping
* Price validation or declared limitation
* Sold-out validation or declared limitation
* POS ACK capture
* Kitchen print responsibility boundary
* Timeout behavior
* Rate limit or unknown-rate-limit risk handling
* Idempotency or duplicate prevention strategy
* Schema validation
* Raw packet audit
* Operator recovery path
* Reconciliation path

For waiting/table/prepaid flows, additional evidence is required for:

* Waiting entry sync
* Table assignment
* Table occupancy
* Prepaid cancellation
* Kitchen cancellation
* Refund coordination

## 24. Degraded Mode Declaration

If provider support is incomplete, degraded mode must be declared.

A degraded mode declaration must include:

```
degraded_mode_id
provider_id
unsupported_capability
affected_flow
fallback_behavior
manual_operator_action
customer_message
audit_requirement
risk_level
production_allowed_flag
pilot_only_flag
approval_required_by
review_date
```

Degraded mode must be visible to implementation, operations, support, and finance where relevant.

## 25. Manual Recovery Requirement

If manual recovery is required, the profile must define:

* Who performs recovery
* When recovery is required
* Which console action is allowed
* Which evidence must be checked
* Which authority level is required
* Which customer message is allowed
* Which finance or support review is required
* Which audit event is created

Manual recovery must not be vague.

## 26. Provider Approval Gates

Provider approval should pass through gates.

### 26.1 Documentation Gate

Provider documentation and contract snapshot are collected.

### 26.2 Sandbox Gate

Core happy path and failure path are tested in sandbox.

### 26.3 Field Simulation Gate

Timeout, retry, duplicate, print, payment, refund, stock, table, and schema drift simulations are tested.

### 26.4 Pilot Store Gate

Provider is tested in controlled pilot store with operator recovery process.

### 26.5 Finance Reconciliation Gate

Payment, refund, VAN, PG, POS, receipt, business day, and tax reconciliation are verified.

### 26.6 Production Gate

Provider receives explicit production approval with limitations, if any.

## 27. Operator Visibility

The operator console must show provider readiness limitations.

Examples:

* Provider does not support live sold-out validation
* Provider does not support kitchen print status
* Provider does not expose business day close
* Provider has unknown rate limit
* Provider requires local agent
* Provider requires manual refund reconciliation
* Provider is pilot-only
* Provider is degraded-only
* Provider is blocked for prepaid waiting flow

Operators must not be surprised by provider limitations during incidents.

## 28. Audit Requirements

Every provider readiness decision must preserve:

* Provider ID
* Provider profile version
* Capability field
* Capability value
* Evidence reference
* Risk rating
* Degraded mode declaration
* Approval gate
* Approved status
* Approved by
* Approved at
* Review date
* Limitation note
* Related test fixture
* Related pilot store, if applicable
* Trace or evidence reference
* Timestamp

Provider readiness changes must be versioned.

## 29. Review And Revalidation

Provider readiness must be revalidated when:

* Provider changes API
* Provider changes receipt behavior
* Provider changes payment behavior
* Provider changes webhook behavior
* Provider changes menu model
* Provider changes rate limit
* Provider changes local agent
* Provider incident occurs
* Schema drift is detected
* Finance reconciliation mismatch repeats
* Store incident pattern emerges
* New production flow is enabled

Readiness approval must not be permanent.

## 30. Test Requirements

The provider readiness process itself must ensure tests for:

* Capability profile completeness
* Unknown capability blocking
* Unsupported capability degraded mode
* Evidence attachment
* Risk rating assignment
* Approval gate transition
* Production limitation visibility
* Provider revalidation
* Readiness downgrade after incident
* Audit preservation for readiness changes

A provider readiness profile without versioned evidence must not be accepted.

## 31. Anti-Patterns

The following are prohibited:

* Treating provider sales claims as readiness evidence
* Marking provider production-ready after only happy-path order submit
* Assuming unsupported capability can be handled later
* Hiding degraded mode from operators
* Ignoring unknown rate limit
* Ignoring unknown idempotency support
* Ignoring unknown receipt behavior
* Treating sandbox success as production readiness
* Allowing prepaid/payment flow without refund and in-doubt evidence
* Allowing table/waiting flow without table and entry evidence
* Allowing provider schema drift without readiness downgrade
* Keeping provider production-ready after repeated unresolved incidents

## 32. Relationship With Other Documents

This policy depends on and operationalizes:

```
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

Provider readiness is the evidence bridge between POS Gateway architecture and safe production integration.

## 33. Final Rule

A POS provider is not production-ready because it can accept an order.

A POS provider is production-ready only when the platform can prove what the provider supports, what it does not support, how failures behave, how degraded paths operate, how manual recovery works, how money reconciles, and how every critical exception is preserved as evidence.

If provider readiness cannot be proven through versioned capability profile, test evidence, limitation declaration, and approval gate, the provider readiness boundary has failed.
