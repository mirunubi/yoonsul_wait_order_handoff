# 014152_Implementation_POS_Gateway_Global_Scale_Final_Boss_Risk_Absorption_Architecture_Invariant_Guardrail

## 1. Purpose

This document absorbs the final-boss scale risks that appear only after the POS Gateway grows beyond early pilot, single-store, or ordinary franchise operation.

The previous governance lane is closed at `06250`.

This document does not reopen the closed governance lane.

Instead, it places non-negotiable architecture invariants at the beginning of the implementation lane so that later implementation does not hard-code assumptions that would break during:

- national-scale traffic;
- hundreds or thousands of stores;
- multiple POS providers;
- multiple VAN/PG/payment routes;
- headquarters-driven forced menu/price replacement;
- global timezone expansion;
- multi-tax and tip-based payment regions;
- provider lock-in pressure;
- audit immutability vs privacy deletion conflict;
- platform-level POS hot-swap strategy.

This document exists to ensure that implementation work packages from `06310` onward do not accidentally build a domestic single-provider, single-tax, single-timezone, single-store architecture that must later be ripped apart.

---

## 2. Scope

This guardrail applies to all later POS Gateway implementation work, especially:

- registry schema;
- order schema;
- payment schema;
- refund/cancellation schema;
- audit/event schema;
- provider adapter interface;
- queue/retry/worker logic;
- circuit breaker policy;
- POS/KDS/payment route design;
- menu master sync;
- price/tax/discount calculation;
- settlement and accounting export;
- privacy and redaction pipeline;
- provider hot-swap abstraction;
- global expansion readiness;
- scale traffic control;
- Admin Console and operator controls.

This document should be referenced by every later implementation work package in the `06310~06399` band.

---

## 3. Core Principle

Implementation must not optimize for the first provider, first country, first store, or first payment model.

The POS Gateway must be built as a survivable transaction engine.

The core architecture must answer `Yes` to these questions:

```text
Can time be reconstructed globally?
Can money support multiple tax lines, tips, fees, discounts, and provider adjustments?
Can external provider traffic be isolated, throttled, delayed, and circuit-broken?
Can audit evidence remain immutable while personal data is redacted or destroyed?
Can a POS provider be replaced without rewriting the transaction core?
Can headquarters mass-update master data without blocking order traffic?
Can retry traffic avoid stampeding a recovering provider?
Can settlement remain correct across multiple VAN/PG/card-company paths?
```

If the answer is `No`, the implementation is not future-proof.

---

## 4. Architecture Invariant Summary

The following invariants must be treated as permanent architecture constraints.

| Invariant | Requirement |
|---|---|
| Time invariant | Store all authoritative timestamps in UTC and preserve local business timezone context |
| Money invariant | Use extensible amount components, not fixed single-tax totals |
| Provider invariant | External POS/payment/KDS calls must pass through adapter, circuit breaker, rate limiter, and retry policy |
| Queue invariant | Retry must use exponential backoff, jitter, and provider-scoped pressure control |
| Master data invariant | Menu/price/provider sync must be isolated from order transaction traffic |
| Settlement invariant | Payment/VAN/PG/card-company route metadata must be preserved |
| Privacy invariant | Immutable transaction proof must be separable from personal data payload |
| Hot-swap invariant | Provider replacement must not change transaction core state model |
| Global invariant | Country, currency, timezone, tax, tip, and local business day must be first-class fields |

These are not optional enhancements.

They are implementation guardrails.

---

## 5. National-Scale Traffic Risk

At national franchise scale, provider failure can become a traffic amplifier.

Danger pattern:

```text
provider outage
gateway retry queue grows
provider partially recovers
all clients retry simultaneously
provider collapses again
gateway retries again
cycle repeats
```

This is a retry storm.

The POS Gateway must prevent retry storms through:

- exponential backoff;
- jitter;
- provider-scoped rate limits;
- store-scoped throttling;
- queue segmentation;
- retry budget;
- circuit breaker open/half-open/closed states;
- dead-letter transition;
- recovery dampening;
- priority queueing;
- manual fallback activation.

No provider call should be retried by naive fixed interval logic.

---

## 6. Exponential Backoff and Jitter Requirement

All external provider retry logic must use exponential backoff and jitter.

Required retry fields:

```text
provider_code
operation_type
attempt_count
base_delay_ms
max_delay_ms
jitter_strategy
retry_budget
last_attempt_at_utc
next_attempt_at_utc
circuit_breaker_state
```

Retry must be controlled by provider and operation type.

Examples:

- POS order write retry;
- POS order lookup retry;
- payment status lookup retry;
- cancellation status lookup retry;
- refund status lookup retry;
- KDS ticket retry;
- receipt lookup retry;
- settlement report retry.

Retry must not happen simultaneously across all stores.

---

## 7. Circuit Breaker Requirement

Every external POS/payment/KDS/provider integration must support circuit breaker behavior.

Circuit breaker states:

```text
closed
open
half_open
forced_open
forced_closed
maintenance
degraded
```

Circuit breaker must be scoped by:

- provider;
- operation;
- tenant;
- store;
- channel;
- payment method where applicable.

When circuit breaker is open, the gateway must stop sending unsafe mutation traffic and switch to a controlled fallback mode.

---

## 8. Virtual Waiting Room and Fallback UI Requirement

When provider failure is prolonged, the gateway must not continue accepting unlimited transaction work.

Required fallback modes:

| Mode | Meaning |
|---|---|
| `normal` | Provider operation healthy |
| `degraded` | Limited operation with warnings |
| `manual_confirm` | Staff confirmation required |
| `order_waiting_room` | Order intake paused or queued with explicit customer notice |
| `counter_payment_only` | Customer directed to on-site payment |
| `offline_store_mode` | Store operates manually and syncs later |
| `provider_frozen` | Provider mutation blocked |
| `channel_paused` | Specific channel disabled |
| `store_paused` | Store ordering temporarily paused |

The fallback UI must be driven by gateway health and circuit breaker state, not by random front-end logic.

---

## 9. Queue Isolation Requirement

Provider sync and transaction mutation must not share the same uncontrolled queue.

Recommended queue segmentation:

```text
order_write_queue
payment_status_queue
cancel_refund_queue
kds_ticket_queue
receipt_lookup_queue
provider_health_queue
master_data_sync_queue
menu_transformation_queue
settlement_import_queue
notification_queue
audit_archive_queue
privacy_redaction_queue
```

Master data synchronization must not starve order traffic.

Settlement import must not block refund verification.

Privacy redaction must not block POS writes.

---

## 10. Headquarters Mass Menu Replacement Risk

At large franchise scale, headquarters may force menu, price, option, or modifier changes across hundreds of stores.

This can create:

- CPU spike from transformation;
- cache stampede;
- POS provider rate limit exhaustion;
- inconsistent store activation;
- wrong price during transition;
- stale menu display;
- reconciliation mismatch.

Mass menu replacement must be handled as an asynchronous controlled rollout, not synchronous request fan-out.

---

## 11. Master Data Sync Isolation Requirement

Master data sync must use:

- batch job;
- transformation cache;
- versioned activation;
- store wave rollout;
- precomputed provider payload;
- validation before activation;
- rollback version;
- background queue;
- cache warmup;
- provider rate limit control.

Order traffic must read already-validated active versions.

Order traffic must not perform heavy menu transformation in the hot path.

---

## 12. Cache and Precomputation Requirement

Gateway must prepare master data before activation.

Required precomputed artifacts:

```text
menu_mapping_payload
option_modifier_payload
price_rule_payload
tax_rule_payload
discount_coupon_payload
provider_specific_transform_payload
kds_routing_payload
customer_display_payload
receipt_display_payload
```

Hot order path should reference activated version IDs, not recompute full structures.

---

## 13. Multi-VAN and Card-Company Routing Risk

Large franchise operators may use multiple VAN/PG routes or direct card-company merchant configurations.

The gateway must not assume one store equals one payment route.

Payment route may vary by:

- card company;
- issuer/acquirer;
- VAN provider;
- PG provider;
- terminal;
- merchant ID;
- store;
- channel;
- payment method;
- country;
- currency;
- contract.

If payment route metadata is missing, settlement reconciliation can break.

---

## 14. Payment Route Metadata Requirement

Payment records must preserve route metadata.

Recommended fields:

```text
payment_route_id
van_provider_code
pg_provider_code
card_company_code
issuer_code
acquirer_code
merchant_id
terminal_id
approval_number
payment_method
currency_code
country_code
store_id
business_date_local
created_at_utc
```

Not all fields are required in every country, but the schema must allow them.

The system must not hard-code a single VAN assumption.

---

## 15. Settlement Route Compatibility Requirement

Settlement and accounting export must be able to group by:

- tenant;
- store;
- business date;
- local timezone;
- VAN provider;
- PG provider;
- card company;
- merchant ID;
- terminal ID;
- payment method;
- currency;
- tax jurisdiction.

This is required before top-tier franchise or global settlement.

---

## 16. Global Timezone Requirement

All authoritative timestamps must use UTC.

At the same time, the system must preserve local business context.

Required time fields for transaction-critical records:

```text
created_at_utc
updated_at_utc
business_date_local
local_timezone_name
local_timezone_offset_minutes
store_local_time
provider_business_day
```

UTC is for global ordering and audit.

Local business date is for store close, settlement, payroll, reporting, and franchise operation.

Both are required.

---

## 17. Business Day Boundary Requirement

Business date must not be inferred only from server date.

Business date may depend on:

- store timezone;
- store closing time;
- POS provider close time;
- overnight operation;
- delivery cutoff;
- settlement day;
- local legal/reporting day.

The gateway must store explicit `business_date_local`.

This prevents overseas stores from corrupting Korean-server-day reporting.

---

## 18. Global Money Object Requirement

The gateway must not use a domestic-only fixed VAT total model.

Money object must support:

- subtotal;
- tax list;
- fee list;
- discount list;
- coupon list;
- service charge;
- tip;
- rounding;
- provider adjustment;
- currency;
- exchange reference where needed;
- jurisdiction;
- inclusive/exclusive tax mode.

Recommended structure:

```text
amount_components: {
  subtotal_amount,
  discount_total,
  coupon_total,
  fee_total,
  service_charge_total,
  tip_amount,
  tax_total,
  rounding_amount,
  provider_adjustment_amount,
  grand_total,
  currency_code,
  tax_list: [],
  fee_list: [],
  discount_list: []
}
```

A single fixed `vat_10_percent` assumption is prohibited.

---

## 19. Multi-Tax Requirement

Tax must support multiple tax lines.

Example tax fields:

```text
tax_id
tax_name
tax_type
tax_rate
tax_amount
tax_jurisdiction
tax_inclusive_flag
applies_to
provider_tax_code
```

Tax may differ by:

- country;
- state;
- city;
- item type;
- alcohol;
- dine-in/takeout;
- delivery;
- service charge;
- tip treatment.

Tax logic must be versioned and snapshotted per transaction.

---

## 20. Tip Requirement

Tip must be first-class where applicable.

Tip fields should include:

```text
tip_amount
tip_type
tip_rate
tip_entered_by
tip_adjusted_after_payment
tip_provider_reference
tip_settlement_status
```

Tip may be:

- pre-payment;
- post-authorization;
- table-service based;
- staff-distributed;
- excluded from tax;
- included in certain settlement flows.

The schema must not assume tips do not exist.

---

## 21. Provider Hot-Swap Requirement

The POS Gateway must be able to replace a provider without rewriting transaction core logic.

Hot-swap requires:

- provider-independent state machine;
- adapter contract;
- capability registry;
- limitation registry;
- provider route table;
- feature flags;
- settlement route abstraction;
- receipt/proof abstraction;
- provider-specific payload archive;
- provider retirement process.

Provider-specific logic must live behind adapter boundaries.

---

## 22. Provider Lock-In Hedging Requirement

Large POS providers may change pricing, API terms, data access, or technical behavior.

The gateway must preserve negotiation leverage by supporting:

- multiple providers;
- route restriction;
- route migration;
- provider retirement;
- own virtual POS module;
- data export;
- adapter replacement;
- historical evidence continuity.

The platform must not become hostage to one provider’s schema.

---

## 23. Virtual POS Layer Requirement

The gateway should maintain its own virtual POS state even when external POS is the downstream operational system.

Virtual POS state should include:

- normalized order;
- normalized payment reference;
- normalized cancel/refund state;
- normalized receipt/proof state;
- normalized KDS route;
- normalized settlement reference;
- normalized customer-safe status;
- provider-specific external references.

The gateway must not rely exclusively on external POS as the only source of operational truth.

---

## 24. Audit Immutability Requirement

Audit events must be append-only.

Audit must preserve:

- event type;
- actor;
- timestamp UTC;
- local context;
- transaction reference;
- before/after references where allowed;
- provider reference;
- approval reference;
- correlation ID;
- evidence pointer.

Audit event history must not be edited to make a later result look clean.

Corrections must be additive.

---

## 25. Privacy Separation Requirement

Immutable audit and privacy deletion requirements conflict unless data is separated.

Therefore, transaction proof must be separated from personal data payload.

Recommended separation:

```text
transaction_event_core
transaction_financial_core
customer_personal_payload
staff_personal_payload
provider_raw_payload
redaction_token_map
privacy_deletion_record
```

The core transaction evidence must remain.

Personal data must be encrypted, redacted, anonymized, or deleted according to policy.

---

## 26. Selective Redaction Pipeline Requirement

The system must support background privacy redaction.

Pipeline stages:

```text
identify_expired_personal_payload
verify_retention_and_legal_hold
separate_transaction_core
redact_or_delete_personal_fields
write_redaction_event
preserve irreversible proof hash
update searchable redacted view
report completion
```

Redaction must not destroy financial transaction proof.

---

## 27. WORM and Redaction Coexistence

WORM-style audit must not mean raw personal data is kept forever.

The correct model is:

```text
immutable event envelope
immutable transaction facts
mutable-or-destructible personal payload reference
redaction event record
proof hash continuity
```

The event remains.

The personal payload may be removed or anonymized.

The system must prove both integrity and privacy compliance.

---

## 28. Raw Provider Payload Handling

Raw provider payloads must be treated as sensitive.

Rules:

- store only when necessary;
- encrypt at rest;
- classify sensitivity;
- redact secrets;
- isolate personal/payment data;
- set retention category;
- provide access audit;
- support redaction;
- preserve normalized evidence separately.

Raw payload must not become the only proof of transaction state.

---

## 29. Global Currency Requirement

Currency must be first-class.

Required fields:

```text
currency_code
amount_minor_unit
currency_exponent
exchange_rate_reference
settlement_currency_code
display_currency_code
```

The gateway must not assume KRW or no decimal currency.

All money calculations should use minor units or precise decimal representation.

---

## 30. Country and Jurisdiction Requirement

Global records must support:

```text
country_code
region_code
city_code
tax_jurisdiction_code
legal_entity_id
merchant_country_code
store_country_code
```

This is required for tax, receipt, settlement, reporting, and legal boundary.

---

## 31. Provider Health and Traffic Governance

Provider health must be measurable and actionable.

Health dimensions:

- availability;
- latency;
- timeout;
- error rate;
- mutation unknown rate;
- webhook delay;
- rate limit response;
- settlement delay;
- support escalation status.

Provider health must drive:

- circuit breaker;
- retry budget;
- fallback mode;
- channel pause;
- route restriction;
- incident severity.

---

## 32. Stampede Prevention Checklist

Before enabling provider retry at scale, verify:

```text
exponential_backoff_enabled
jitter_enabled
provider_rate_limit_enabled
store_rate_limit_enabled
retry_budget_enabled
queue_segmentation_enabled
circuit_breaker_enabled
half_open_probe_limited
dead_letter_enabled
manual_fallback_enabled
monitoring_alert_enabled
```

Without this checklist, national-scale retry is unsafe.

---

## 33. Master Data Stampede Prevention Checklist

Before headquarters mass update, verify:

```text
batch_queue_enabled
transformation_cache_ready
version_activation_ready
store_wave_rollout_ready
cache_warmup_ready
rollback_version_ready
provider_rate_limit_ready
order_hot_path_isolated
monitoring_ready
```

Master data sync must never become an order-traffic outage.

---

## 34. Global Readiness Checklist

Before global expansion, verify:

```text
created_at_utc exists
business_date_local exists
local_timezone_name exists
local_timezone_offset_minutes exists
currency_code exists
tax_list exists
tip_amount exists
country_code exists
tax_jurisdiction_code exists
provider_route_metadata exists
privacy_redaction_pipeline exists
multi-language customer messages exist
```

Global expansion must not be attempted with domestic-only assumptions.

---

## 35. Final Architecture Questions

The implementation team must answer `Yes` before core schema freeze:

```text
Can every order be reconstructed in UTC and local business time?
Can every amount be reconstructed from component lines?
Can every provider call be circuit-broken and rate-limited?
Can retry storms be dampened automatically?
Can master data sync be isolated from order traffic?
Can payment settlement be grouped by VAN/PG/card-company route?
Can a provider be replaced behind an adapter?
Can immutable audit coexist with privacy deletion?
Can customer-facing status avoid unsupported certainty?
Can global tax and tip models be added without schema rewrite?
```

If not, the schema is not ready.

---

## 36. Relationship To Adjacent Documents

This document is related to:

- 06300 POS Gateway implementation task breakdown, executable work package index, and build sequence policy;
- 06250 POS Gateway final operational governance index, control map, readiness summary, and phase closeout policy;
- 06240 POS Gateway AI-assisted operation, automation, recommendation, human approval, and controlled decision boundary policy;
- 06220 POS Gateway cross-tenant SaaS standardization, template inheritance, customization, and control boundary policy;
- 06190 POS Gateway vendor, provider, SLA, contract limitation, liability, escalation, and service governance policy;
- 06170 POS Gateway change management, release governance, configuration drift control, and production deployment policy;
- 06160 POS Gateway disaster recovery, business continuity, provider outage, store offline mode, and service resumption policy;
- 06150 POS Gateway performance, load, peak traffic, queue backpressure, and capacity planning policy;
- 06130 POS Gateway data retention, archive, privacy, redaction, and forensic evidence lifecycle policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy.

Where conflict exists, this document governs implementation-level global-scale architecture invariants that must not be violated by later POS Gateway work packages.

---

## 37. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_architecture_invariants
pos_gateway_time_context_fields
pos_gateway_money_component_schema
pos_gateway_tax_lines
pos_gateway_tip_records
pos_gateway_provider_circuit_breakers
pos_gateway_retry_policies
pos_gateway_retry_budgets
pos_gateway_provider_rate_limits
pos_gateway_master_data_sync_jobs
pos_gateway_transformation_cache
pos_gateway_payment_route_metadata
pos_gateway_van_pg_route_records
pos_gateway_virtual_pos_state
pos_gateway_provider_hot_swap_routes
pos_gateway_privacy_payload_separation
pos_gateway_redaction_jobs
pos_gateway_worm_audit_envelopes
pos_gateway_provider_health_scores
```

Recommended services:

```text
ArchitectureInvariantGuard
TimeContextService
MoneyComponentService
TaxLineService
TipHandlingService
ProviderCircuitBreakerService
RetryPolicyService
RetryBudgetService
ProviderRateLimitService
MasterDataSyncIsolationService
TransformationCacheService
PaymentRouteMetadataService
VirtualPosStateService
ProviderHotSwapService
PrivacyPayloadSeparationService
SelectiveRedactionPipelineService
WormAuditEnvelopeService
ProviderHealthGovernanceService
```

Recommended event types:

```text
pos_gateway.invariant.violation_detected
pos_gateway.provider.circuit_opened
pos_gateway.provider.circuit_half_opened
pos_gateway.provider.circuit_closed
pos_gateway.retry.budget_exhausted
pos_gateway.retry.jitter_applied
pos_gateway.provider.rate_limited
pos_gateway.master_data.batch_started
pos_gateway.master_data.batch_completed
pos_gateway.master_data.activation_scheduled
pos_gateway.payment.route_resolved
pos_gateway.provider.hot_swap_started
pos_gateway.provider.hot_swap_completed
pos_gateway.privacy.redaction_started
pos_gateway.privacy.redaction_completed
pos_gateway.audit.worm_envelope_created
```

---

## 38. Prohibited Practices

The following practices are prohibited:

- storing only local server time without UTC;
- inferring business date from server date only;
- hard-coding Korean VAT-only amount model;
- storing only one tax field;
- ignoring tip structure;
- retrying provider calls without jitter;
- allowing all stores to retry simultaneously;
- running master data transformation in order hot path;
- assuming one store has one VAN/PG route forever;
- binding transaction state directly to one POS provider schema;
- using raw provider payload as only transaction proof;
- keeping personal data forever because audit must be immutable;
- deleting transaction evidence because personal data must be deleted;
- treating provider hot-swap as a future refactor;
- building global expansion on domestic-only schema.

---

## 39. Minimum Acceptance Criteria

This guardrail is acceptable only when:

- national-scale retry storm risk is addressed;
- circuit breaker and fallback UI requirements are defined;
- queue isolation is defined;
- headquarters mass menu replacement risk is addressed;
- master data sync isolation is defined;
- multi-VAN/payment route metadata is defined;
- UTC and local business time fields are required;
- business day boundary is explicit;
- extensible money object is required;
- tax list and tip fields are required;
- provider hot-swap and lock-in hedging are defined;
- virtual POS layer requirement exists;
- audit immutability and privacy separation are reconciled;
- selective redaction pipeline is defined;
- global currency/country/jurisdiction fields are defined;
- scale/global readiness checklists are defined;
- prohibited domestic-only assumptions are listed.

---

## 40. Summary

This document is the final-boss implementation guardrail.

The POS Gateway must not be built as a domestic, single-provider, single-tax, single-timezone order pipe.

It must be built as a global-scale transaction engine that can survive:

- provider outages;
- retry storms;
- mass menu updates;
- multi-VAN settlement;
- global timezone complexity;
- multi-tax and tip systems;
- provider lock-in attacks;
- immutable audit requirements;
- privacy deletion obligations;
- future POS hot-swap.

The architecture must leave the space now.

If these fields, boundaries, and interceptors are added later, the core will break.

If they are included from the beginning, the system can start small and still grow into national franchise and global SaaS scale without rewriting its bones.