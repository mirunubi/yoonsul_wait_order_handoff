# 014153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation

## 1. Purpose

This document defines the implementation work package for the POS Gateway core registry.

The core registry is the first executable foundation of the POS Gateway implementation lane.

Before the gateway can write orders, call providers, route payments, create KDS tickets, or reconcile transactions, it must know:

- which tenant owns the operation;
- which store is active;
- which country, timezone, currency, and business-day rule applies;
- which POS/payment/KDS providers are connected;
- which provider capabilities are verified;
- which limitations are known;
- which environment is active;
- which credential reference is allowed;
- which adapter version is compatible;
- which store/provider/channel is production-ready.

This work package converts the governance and final-boss architecture guardrails into the first buildable registry spine.

---

## 2. Scope

This work package covers implementation of:

- tenant registry;
- store registry;
- store local time and business-day context;
- country/currency/jurisdiction context;
- provider registry;
- provider type classification;
- provider environment binding;
- credential reference binding;
- provider capability registry;
- provider limitation registry;
- adapter version registry;
- provider route eligibility;
- store onboarding status;
- production readiness status;
- tenant/store/provider access scope;
- audit events for registry changes;
- Admin Console seed requirements for later lanes.

This document does not implement order mutation, payment mutation, KDS ticketing, reconciliation, or UI flows.  
It only creates the registry foundation required by later work packages.

---

## 3. Core Principle

No POS Gateway transaction may occur without a valid registry context.

Every transaction must be able to resolve:

```text
tenant
store
local business context
provider
environment
adapter
capability
limitation
credential reference
route eligibility
readiness status
```

If registry context is missing, invalid, expired, disabled, or incompatible, the gateway must fail closed.

---

## 4. Implementation Position

This work package follows:

```text
014151_Policy_POS_Gateway_Implementation_Task_Breakdown_Executable_Work_Package_Index_And_Build_Sequence.md
014152_Implementation_POS_Gateway_Global_Scale_Final_Boss_Risk_Absorption_Architecture_Invariant_Guardrail.md
```

This work package precedes:

```text
014154_WorkPackage_POS_Gateway_Menu_Mapping_Price_Availability_And_Calculation_Snapshot_Implementation.md
014155_WorkPackage_POS_Gateway_Order_Payment_Cancel_Refund_State_Machine_And_Transaction_Timeline_Implementation.md
06340_POS_Gateway_Idempotency_Queue_Retry_Dead_Letter_Replay_And_Duplicate_Prevention_Implementation_Work_Package.md
06350_POS_Gateway_POS_KDS_Adapter_Interface_Routing_Error_Normalization_And_Provider_Contract_Implementation_Work_Package.md
```

The registry must exist before transaction and provider adapter layers.

---

## 5. Required Registry Domains

The implementation must define these registry domains:

```text
tenant
store
store_business_context
provider
provider_environment
provider_credential_reference
provider_capability
provider_limitation
adapter_version
provider_route_eligibility
store_onboarding_status
production_readiness_status
access_scope
```

These domains may be implemented as separate tables or strongly separated logical models.

The key requirement is that each domain is queryable, auditable, and version-aware where needed.

---

## 6. Tenant Registry

Tenant registry must identify the SaaS customer or operating entity using the gateway.

Required fields:

```text
tenant_id
tenant_code
tenant_name
tenant_type
default_country_code
default_currency_code
status
created_at_utc
updated_at_utc
```

Recommended tenant statuses:

```text
draft
onboarding
active
suspended
offboarding
archived
```

Tenant must be the top-level isolation boundary.

No store, provider, transaction, or evidence record may exist without tenant scope.

---

## 7. Store Registry

Store registry must identify each operating location.

Required fields:

```text
store_id
tenant_id
store_code
store_name
country_code
region_code
city_code
currency_code
timezone_name
timezone_offset_minutes
business_day_cutoff_time_local
status
created_at_utc
updated_at_utc
```

Recommended store statuses:

```text
draft
onboarding
pilot_ready
active
degraded
paused
closed
archived
```

Store must be treated as an operational context, not merely a display name.

---

## 8. Store Business Context

Store business context must support local operating rules.

Required fields:

```text
store_business_context_id
tenant_id
store_id
business_timezone_name
business_day_cutoff_time_local
default_country_code
default_currency_code
default_tax_jurisdiction_code
default_locale
operating_mode
effective_from_utc
effective_until_utc
status
```

This context supports:

- business date calculation;
- local settlement day;
- local reporting;
- local customer messages;
- timezone conversion;
- global expansion readiness.

The gateway must not infer business date only from server time.

---

## 9. Time Context Requirement

All registry records that affect transaction behavior must use UTC timestamps.

At minimum:

```text
created_at_utc
updated_at_utc
effective_from_utc
effective_until_utc
```

Store-specific transaction records later must include:

```text
created_at_utc
business_date_local
local_timezone_name
local_timezone_offset_minutes
```

This work package must ensure store timezone context exists before transaction tables are built.

---

## 10. Country, Currency, and Jurisdiction Context

The registry must prepare for global expansion.

Required fields where applicable:

```text
country_code
region_code
city_code
currency_code
tax_jurisdiction_code
legal_entity_id
merchant_country_code
```

Do not hard-code:

- Korea only;
- KRW only;
- VAT 10% only;
- one timezone only;
- one legal entity only.

Domestic operation may use default values, but schema must remain global-ready.

---

## 11. Provider Registry

Provider registry must identify external systems integrated with POS Gateway.

Required fields:

```text
provider_id
provider_code
provider_name
provider_type
country_scope
supported_currency_codes
status
created_at_utc
updated_at_utc
```

Recommended provider types:

```text
pos_provider
payment_provider
van_provider
pg_provider
kds_provider
delivery_provider
notification_provider
receipt_provider
identity_provider
cloud_provider
hardware_vendor
```

Provider identity must be stable and independent from one store’s configuration.

---

## 12. Provider Environment Binding

Provider environment binding must separate sandbox, staging, and production.

Required fields:

```text
provider_environment_id
provider_id
provider_code
environment_code
base_endpoint_reference
webhook_endpoint_reference
sandbox_parity_level
status
created_at_utc
updated_at_utc
```

Recommended environment codes:

```text
sandbox
staging
production
production_shadow
certification
```

The gateway must not accidentally call production credentials from sandbox or staging.

---

## 13. Credential Reference Binding

Credential values must not be stored directly in registry records.

Registry must store credential references only.

Required fields:

```text
credential_reference_id
tenant_id
store_id
provider_id
provider_environment_id
credential_scope
secret_manager_reference
rotation_status
effective_from_utc
effective_until_utc
status
```

Rules:

- no raw secret in registry;
- no token in audit payload;
- no credential in logs;
- no cross-tenant credential reuse unless explicitly allowed and audited;
- production credential activation requires approval.

Credential reference is metadata.  
Secret value must live in approved secret storage.

---

## 14. Provider Capability Registry

Provider capability registry must define what the provider can do.

Required fields:

```text
provider_capability_id
provider_id
provider_environment_id
capability_code
capability_status
verified_at_utc
verification_method
verified_by
evidence_reference
notes
```

Recommended capability codes:

```text
order_create
order_lookup
order_cancel
payment_authorize
payment_capture
payment_cancel
refund_full
refund_partial
receipt_lookup
settlement_report
webhook_event
idempotency_key
menu_sync
price_sync
sold_out_sync
kds_ticket_create
table_mapping
terminal_mapping
```

Capabilities must be verified, not assumed.

---

## 15. Provider Capability Status

Recommended capability statuses:

```text
unknown
not_supported
claimed_supported
verified_supported
verified_limited
disabled
deprecated
```

The gateway must not route high-risk actions through `unknown` or `claimed_supported` capability.

For production mutation, the capability should be `verified_supported` or `verified_limited` with compensating controls.

---

## 16. Provider Limitation Registry

Provider limitation registry must document known restrictions.

Required fields:

```text
provider_limitation_id
provider_id
provider_environment_id
limitation_code
description
affected_capability_code
severity
compensating_control
first_detected_at_utc
last_reviewed_at_utc
status
```

Recommended limitation examples:

```text
no_partial_refund
no_idempotency_support
delayed_webhook
manual_cancel_only
receipt_lookup_unavailable
undocumented_rate_limit
sandbox_prod_behavior_difference
settlement_report_delay
table_mapping_not_supported
```

Limitations must directly affect route eligibility, fallback behavior, and operator warnings.

---

## 17. Limitation Severity

Recommended severity values:

```text
info
low
medium
high
critical
blocking
```

A `blocking` limitation must prevent production activation for affected capability.

A `critical` limitation must require explicit approval and compensating control.

---

## 18. Adapter Version Registry

Adapter version registry must track gateway-side adapter implementation.

Required fields:

```text
adapter_version_id
provider_id
adapter_code
adapter_version
contract_version
supported_capabilities
known_limitations
release_status
released_at_utc
deprecated_at_utc
status
```

Recommended release statuses:

```text
draft
internal_test
certification
pilot_ready
production_ready
deprecated
retired
```

Provider adapter version must be checked before route activation.

---

## 19. Provider Route Eligibility

Provider route eligibility determines whether a provider can be used for a store/channel/operation.

Required fields:

```text
provider_route_eligibility_id
tenant_id
store_id
provider_id
provider_environment_id
adapter_version_id
operation_type
channel_scope
payment_method_scope
currency_code
country_code
eligibility_status
reason
approved_by
effective_from_utc
effective_until_utc
status
```

Recommended operation types:

```text
pos_order_write
pos_order_lookup
payment_authorize
payment_cancel
refund
kds_ticket_create
receipt_lookup
settlement_import
menu_sync
sold_out_sync
```

Route eligibility must fail closed if required capability, credential, adapter, or store readiness is missing.

---

## 20. Store Onboarding Status

Store onboarding status must track readiness.

Required fields:

```text
store_onboarding_status_id
tenant_id
store_id
onboarding_phase
provider_setup_status
credential_setup_status
menu_mapping_status
price_rule_status
availability_status
pos_smoke_status
payment_smoke_status
kds_smoke_status
training_status
manual_fallback_status
monitoring_status
readiness_status
updated_at_utc
```

Recommended onboarding phases:

```text
draft
technical_setup
mapping_setup
certification
pilot_preparation
pilot_ready
active
stabilizing
scale_ready
```

A store must not become active only because provider credentials exist.

---

## 21. Production Readiness Status

Production readiness must be explicit.

Required fields:

```text
production_readiness_id
tenant_id
store_id
provider_id
channel_scope
feature_scope
readiness_status
blocking_reason
approved_by
approved_at_utc
review_due_at_utc
status
```

Recommended readiness statuses:

```text
not_ready
restricted_pilot
pilot_ready
production_limited
production_ready
scale_ready
blocked
paused
```

Readiness may differ by channel and feature.

A store may be ready for staff-mediated order write but not ready for kiosk payment or automatic refund.

---

## 22. Access Scope Registry

The core registry must support access boundaries.

Required fields:

```text
access_scope_id
tenant_id
store_id
actor_type
actor_id
scope_type
scope_value
role_code
permission_level
effective_from_utc
effective_until_utc
status
```

Access scope should support:

- tenant admin;
- store manager;
- shift lead;
- support operator;
- reconciliation owner;
- provider operator;
- technical operator.

Access control details may be implemented in another lane, but registry references must exist.

---

## 23. Registry State Transition Rules

Registry records must follow controlled state transitions.

Examples:

```text
draft -> onboarding -> active
active -> suspended
active -> paused
paused -> active
active -> archived
production_ready -> paused
pilot_ready -> active
active -> retired
```

Invalid transition must be rejected.

Critical transitions require audit event and approval reference.

---

## 24. Fail-Closed Rules

The gateway must fail closed when:

- tenant is inactive;
- store is inactive or paused;
- store timezone context missing;
- provider is inactive;
- provider environment disabled;
- credential reference missing or expired;
- adapter version not production-ready;
- required capability unknown or unsupported;
- blocking limitation exists;
- route eligibility disabled;
- readiness status not sufficient;
- access scope invalid.

Fail-closed result must create observable rejection reason.

---

## 25. Audit Event Requirements

Registry changes must create audit events.

Required event types:

```text
pos_gateway.registry.tenant_created
pos_gateway.registry.store_created
pos_gateway.registry.store_context_updated
pos_gateway.registry.provider_registered
pos_gateway.registry.provider_environment_bound
pos_gateway.registry.credential_reference_bound
pos_gateway.registry.capability_recorded
pos_gateway.registry.capability_verified
pos_gateway.registry.limitation_recorded
pos_gateway.registry.adapter_version_registered
pos_gateway.registry.route_eligibility_changed
pos_gateway.registry.store_onboarding_status_changed
pos_gateway.registry.production_readiness_changed
pos_gateway.registry.access_scope_changed
```

Audit event must include:

```text
actor_id
tenant_id
store_id
provider_id
before_reference
after_reference
reason
created_at_utc
correlation_id
```

Do not include raw secrets.

---

## 26. API Requirements

Recommended internal APIs or service methods:

```text
createTenant()
registerStore()
updateStoreBusinessContext()
registerProvider()
bindProviderEnvironment()
bindCredentialReference()
recordProviderCapability()
verifyProviderCapability()
recordProviderLimitation()
registerAdapterVersion()
setProviderRouteEligibility()
updateStoreOnboardingStatus()
setProductionReadiness()
resolveGatewayContext()
validateRouteEligibility()
```

`resolveGatewayContext()` is the most important read function.

It must return whether a transaction path is allowed and why.

---

## 27. Gateway Context Resolver

The implementation must provide a gateway context resolver.

Input:

```text
tenant_id
store_id
operation_type
channel
provider_code
environment_code
payment_method
currency_code
```

Output:

```text
allowed
denial_reason
tenant_status
store_status
store_business_context
provider_status
provider_environment_status
credential_reference_status
adapter_version_status
capability_status
limitation_status
route_eligibility_status
production_readiness_status
```

The transaction layer must call this resolver before provider mutation.

---

## 28. Denial Reason Codes

Recommended denial reason codes:

```text
tenant_inactive
store_inactive
store_paused
business_context_missing
provider_inactive
environment_disabled
credential_missing
credential_expired
adapter_not_ready
capability_unknown
capability_not_supported
blocking_limitation
route_not_eligible
readiness_not_approved
access_denied
currency_not_supported
country_not_supported
operation_not_enabled
```

Denial reason codes must be customer-safe only after mapping through message policy.

Internal denial reason may be more detailed.

---

## 29. Data Model Draft

Recommended table group:

```text
pos_gateway_tenants
pos_gateway_stores
pos_gateway_store_business_contexts
pos_gateway_providers
pos_gateway_provider_environments
pos_gateway_provider_credential_refs
pos_gateway_provider_capabilities
pos_gateway_provider_limitations
pos_gateway_adapter_versions
pos_gateway_provider_route_eligibilities
pos_gateway_store_onboarding_statuses
pos_gateway_production_readiness_statuses
pos_gateway_access_scopes
pos_gateway_registry_audit_events
```

This may later be merged with broader tenant/store/company schemas, but POS Gateway must preserve its own operational registry view.

---

## 30. Migration Notes

Initial migration should seed:

```text
default tenant
default store
default country_code = KR
default currency_code = KRW
timezone_name = Asia/Seoul
timezone_offset_minutes = 540
business_day_cutoff_time_local
provider placeholder records
provider environment placeholders
capability unknown records
onboarding draft statuses
```

Do not seed providers as production-ready unless verified.

---

## 31. Indexing Requirements

Recommended indexes:

```text
tenant_id
store_id
provider_id
provider_code
environment_code
operation_type
channel_scope
currency_code
country_code
status
effective_from_utc
effective_until_utc
```

Route eligibility lookup must be fast because later transaction paths will depend on it.

---

## 32. Constraints

Required constraints:

- tenant code unique;
- store code unique within tenant;
- provider code unique;
- environment code unique per provider;
- active credential reference cannot overlap improperly for same scope;
- route eligibility cannot activate without capability;
- production readiness cannot activate without store onboarding status;
- timezone name required for store;
- currency code required for store;
- country code required for store.

Critical constraints should be enforced in database or service-level validation.

---

## 33. Security Requirements

Security requirements:

- no raw secrets in registry;
- credential references only;
- all changes audited;
- tenant isolation enforced;
- store isolation enforced;
- provider credential access restricted;
- access scope changes privileged;
- production readiness changes privileged;
- route eligibility changes privileged.

Service roles must not bypass audit.

---

## 34. Monitoring Requirements

Registry monitoring must detect:

- expired credential references;
- provider capability unknown in active route;
- active store without business context;
- active provider without environment;
- route eligibility with blocking limitation;
- production-ready store with incomplete onboarding;
- inactive provider still referenced by active route;
- adapter version deprecated but still active;
- store timezone missing;
- currency mismatch.

Monitoring should create operational alerts before transaction failure.

---

## 35. Test Requirements

Required tests:

```text
tenant isolation test
store context resolution test
timezone context required test
provider environment binding test
credential reference no-secret test
capability required test
limitation blocking test
adapter version compatibility test
route eligibility fail-closed test
production readiness fail-closed test
access scope validation test
audit event creation test
denial reason code test
```

No transaction work package may proceed without passing context resolver tests.

---

## 36. Acceptance Criteria

This work package is acceptable only when:

- tenant registry exists;
- store registry exists;
- store business context exists;
- country/currency/timezone fields exist;
- provider registry exists;
- provider environment binding exists;
- credential reference binding exists without raw secrets;
- provider capability registry exists;
- provider limitation registry exists;
- adapter version registry exists;
- provider route eligibility exists;
- store onboarding status exists;
- production readiness status exists;
- access scope reference exists;
- gateway context resolver exists;
- fail-closed rules exist;
- audit event requirements exist;
- denial reason codes exist;
- monitoring and tests exist.

---

## 37. Relationship To Adjacent Documents

This document is related to:

- 06300 POS Gateway implementation task breakdown, executable work package index, and build sequence policy;
- 06305 POS Gateway global scale final boss risk absorption architecture invariant implementation guardrail;
- 06250 POS Gateway final operational governance index, control map, readiness summary, and phase closeout policy;
- 06220 POS Gateway cross-tenant SaaS standardization, template inheritance, customization, and control boundary policy;
- 06190 POS Gateway vendor, provider, SLA, contract limitation, liability, escalation, and service governance policy;
- 06170 POS Gateway change management, release governance, configuration drift control, and production deployment policy;
- 06140 POS Gateway access control, role segregation, tenant isolation, privileged action, and approval audit policy;
- 06010 POS Gateway provider onboarding, certification, capability verification, and expansion control policy.

Where conflict exists, this document governs implementation of the POS Gateway core registry, provider capability, environment binding, and readiness resolver.

---

## 38. Summary

The core registry is the first executable spine of the POS Gateway.

Before the system writes a single POS order, it must know:

- who owns the transaction;
- which store context applies;
- which local time and business day apply;
- which provider is allowed;
- which environment is active;
- which credential reference is valid;
- which capabilities are verified;
- which limitations block action;
- which adapter version is compatible;
- whether the store is ready.

This registry is not administrative decoration.

It is the safety gate before every future transaction