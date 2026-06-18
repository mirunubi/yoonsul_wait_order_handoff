# 014126_Policy_POS_Gateway_Provider_Onboarding_Certification_Capability_Verification_And_Expansion_Control

## 1. Purpose

This document defines the provider onboarding, certification, capability verification, and expansion control policy for the POS Gateway after the implementation lane.

The POS Gateway must not treat a new POS provider, payment provider, KDS provider, or ordering provider as a simple adapter addition.  
Each provider introduces different transaction semantics, cancellation behavior, refund behavior, receipt identity, settlement timing, API reliability, operational limitations, and support constraints.

This policy exists to ensure that:

- new providers are onboarded through a controlled verification process;
- provider capability is proven before production use;
- unsupported or partially supported features are explicitly restricted;
- certification evidence is retained;
- provider behavior is not assumed from another provider;
- rollout expansion is gated by provider-specific operational evidence;
- provider limitations are visible to store onboarding, kiosk reuse, reconciliation, and incident response teams.

---

## 2. Scope

This policy applies to all external providers connected through or adjacent to the POS Gateway, including:

- POS providers;
- payment providers;
- VAN/PG providers;
- KDS providers;
- kiosk providers;
- table ordering providers;
- receipt providers;
- settlement/export providers;
- delivery/order aggregation providers where connected to POS state;
- provider-side admin portals used for operational verification.

This policy applies whenever the system:

- adds a new provider;
- adds a new adapter for an existing provider;
- enables a new provider capability;
- changes provider API version;
- changes provider credential model;
- changes provider settlement export behavior;
- changes provider cancellation/refund behavior;
- expands provider use to additional stores;
- expands provider use to kiosk or SaaS tenant flows.

---

## 3. Core Principle

Provider onboarding must be evidence-based and provider-specific.

The gateway must not assume that:

- one POS provider behaves like another;
- sandbox behavior matches production behavior;
- order write success means refund support exists;
- cancellation support means payment cancellation is safe;
- receipt number availability means settlement linkage is available;
- provider documentation is complete;
- provider dashboard state is enough for audit evidence;
- a successful test in one store approves all stores.

Every provider must earn production trust through scoped verification.

---

## 4. Provider Onboarding Status Model

Each provider onboarding effort must have an explicit status.

Recommended statuses:

| Status | Meaning |
|---|---|
| `candidate` | Provider is being considered |
| `discovery_in_progress` | Capability and access investigation underway |
| `documentation_reviewed` | Provider documentation reviewed |
| `credential_pending` | Access or credential not yet available |
| `sandbox_ready` | Sandbox or test environment available |
| `sandbox_verified` | Basic tests passed in sandbox |
| `production_access_pending` | Production credential or approval pending |
| `production_probe_ready` | Controlled production validation can begin |
| `limited_certified` | Provider approved only for restricted scope |
| `production_certified` | Provider approved for defined production scope |
| `restricted` | Provider has known limitations |
| `blocked` | Provider cannot be used safely |
| `deprecated` | Provider should not be used for new rollout |
| `retired` | Provider removed from active use |

Provider status must be visible to implementation and operations teams.

---

## 5. Provider Identity Registry

Every provider must be registered with stable identity.

Required provider registry fields:

```text
provider_id
provider_code
provider_display_name
provider_type
provider_region
provider_contact_channel
provider_support_hours
provider_documentation_reference
provider_contract_reference
api_version
certification_status
supported_environment_list
production_access_status
settlement_support_status
incident_escalation_status
created_at
updated_at
```

Provider codes must be stable.  
Changing display name must not change provider identity.

---

## 6. Capability Matrix

Each provider must have a capability matrix.

Required capability dimensions:

| Capability Area | Required Verification |
|---|---|
| Order Create | Can gateway create POS order? |
| Order Lookup | Can gateway confirm order state after write? |
| Order Cancel | Can gateway cancel or void POS order? |
| Payment Reference | Can gateway attach payment approval reference? |
| Payment Execution | Can gateway initiate or confirm payment? |
| Payment Cancel | Can gateway cancel payment safely? |
| Refund | Can gateway execute or verify refund? |
| Receipt Identity | Can gateway obtain receipt/bill number? |
| Table Mapping | Can gateway map table/order location? |
| Terminal Mapping | Can gateway map POS terminal? |
| Menu Mapping | Can gateway map item/option/modifier? |
| Discount Mapping | Can gateway represent discounts? |
| Tax Mapping | Can gateway preserve tax amount? |
| KDS Routing | Can gateway route kitchen ticket? |
| Settlement Export | Can gateway reconcile settlement data? |
| Webhook/Event | Can provider push status updates? |
| Idempotency | Does provider support idempotency or duplicate prevention? |
| Rate Limit | Are rate limits known and manageable? |
| Maintenance Notice | Can provider maintenance be detected? |

Capabilities must be marked with explicit states, not vague notes.

Recommended capability states:

```text
supported_verified
supported_unverified
partially_supported
manual_only
provider_portal_only
not_supported
unknown
blocked
```

`unknown` must not be treated as supported.

---

## 7. Provider Discovery Requirements

Provider discovery must collect:

- provider API documentation;
- authentication method;
- environment separation model;
- sandbox availability;
- production approval process;
- credential issuance process;
- API rate limit;
- timeout behavior;
- idempotency behavior;
- duplicate request behavior;
- order state model;
- cancellation state model;
- refund state model;
- receipt identity model;
- settlement export format;
- maintenance notification process;
- support escalation path;
- data retention and audit availability;
- known restrictions.

Discovery must produce a provider discovery report.

---

## 8. Documentation Review Policy

Provider documentation must be reviewed before adapter implementation.

Review must identify:

- required endpoints;
- optional endpoints;
- undocumented behavior;
- ambiguous fields;
- provider-side enum values;
- error code list;
- retry guidance;
- rate limit policy;
- cancellation/refund restrictions;
- settlement timing;
- webhook reliability;
- receipt generation behavior;
- production certification requirements.

Questions or ambiguities must be recorded in a provider clarification log.

Adapter implementation must not silently guess financial behavior where documentation is ambiguous.

---

## 9. Credential and Environment Verification

Provider onboarding must verify environment and credentials.

Required checks:

- sandbox credential exists where available;
- production credential exists only after approval;
- sandbox and production endpoints are distinct;
- credential scope is known;
- credential permissions match intended capability;
- credential storage policy is satisfied;
- credential rotation path exists;
- credential revoke path exists;
- credential health check works;
- credential failure is detectable;
- sandbox credential cannot route production transactions;
- production credential cannot be accidentally used in sandbox test.

Any environment ambiguity must block production certification.

---

## 10. Adapter Certification Stages

Provider adapter certification must progress through stages.

Recommended stages:

```text
static_contract_review
sandbox_connectivity_test
sandbox_mapping_test
sandbox_order_test
sandbox_cancel_test
sandbox_refund_test
sandbox_failure_test
sandbox_reconciliation_test
production_credential_test
controlled_production_probe
limited_store_rollout
stabilization_review
production_certification
```

Stages may be skipped only with documented justification and restriction.

---

## 11. Sandbox Verification

Sandbox verification may confirm technical compatibility, but it is not enough for full production certification.

Sandbox verification should cover:

- authentication;
- connectivity;
- request/response schema;
- order creation;
- order lookup;
- cancellation if supported;
- refund if supported;
- receipt field availability;
- error response handling;
- timeout handling;
- retry behavior;
- idempotency behavior;
- mapping behavior.

Sandbox verification must record which behaviors are sandbox-only and require production confirmation.

---

## 12. Controlled Production Probe

A provider must pass controlled production probe before production certification.

Controlled production probe must verify:

- production credential works;
- production endpoint is correct;
- order write behavior matches expectation;
- receipt identity is available or limitation is recorded;
- payment reference behavior works if in scope;
- cancellation/refund behavior is safe if in scope;
- provider response timing is acceptable;
- gateway audit event chain is complete;
- reconciliation can identify the transaction;
- store operator can recognize the transaction in POS.

Production probe must be scoped, low-risk, and linked to evidence packet.

---

## 13. Certification Scope

Provider certification must be scoped.

Required scope dimensions:

```text
provider_code
provider_type
adapter_version
tenant_scope
store_scope
environment
transaction_types
payment_methods
terminal_scope
table_scope
menu_scope
kds_scope
settlement_scope
certification_level
restriction_list
valid_from
valid_until
reassessment_condition
```

Certification for one capability must not approve another capability automatically.

Example:

- order write certified;
- cancellation manual-only;
- refund not certified;
- KDS not supported;
- settlement export provider-portal-only;
- payment reference supported but payment execution blocked.

---

## 14. Certification Levels

Recommended provider certification levels:

| Level | Meaning |
|---|---|
| `L0_discovered` | Provider information collected but not verified |
| `L1_sandbox_verified` | Sandbox tests passed |
| `L2_production_probe_verified` | Controlled production probe passed |
| `L3_limited_production_certified` | Limited store/capability production allowed |
| `L4_full_scope_certified` | Defined full production scope approved |
| `L5_operationally_stable` | Stable after real operating period and reconciliation |
| `restricted_certified` | Approved only with explicit restrictions |
| `not_certified` | Not safe for production use |

Certification level must be visible before store onboarding begins.

---

## 15. Restriction Policy

Provider restrictions must be explicit.

Restriction examples:

```text
order_lookup_unavailable
refund_manual_only
partial_refund_not_supported
cancel_after_payment_not_supported
receipt_number_delayed
settlement_export_delayed
webhook_unreliable
provider_portal_lookup_required
rate_limit_low
no_idempotency_support
no_kds_cancel_sync
terminal_mapping_required
table_mapping_unreliable
```

Each restriction must include:

```text
restriction_id
provider_code
capability_area
affected_scope
risk_description
manual_workaround
customer_impact
financial_impact
owner
review_date
status
```

Restrictions must be carried into readiness, cutover, monitoring, and incident response.

---

## 16. Provider Limitation Register

A provider limitation register must be maintained.

The register must include:

- unsupported capabilities;
- partial support;
- operational workarounds;
- provider-side known issues;
- API quirks;
- error code interpretation;
- settlement delays;
- receipt identity limitations;
- cancellation/refund limitations;
- provider support limitations;
- required manual verification steps.

Provider limitations must not be buried inside adapter code.

---

## 17. Error Code Mapping

Each provider must have an error code mapping.

Required mapping fields:

```text
provider_code
provider_error_code
provider_error_message_sample
gateway_error_class
retryable
idempotency_safe
customer_impact_possible
manual_review_required
provider_escalation_required
recommended_action
```

Unknown provider error codes must fail safe.

Retry behavior must not be enabled for unknown financial mutation results unless idempotency safety is proven.

---

## 18. Idempotency and Duplicate Behavior Verification

Provider onboarding must verify duplicate behavior.

Required checks:

- provider supports idempotency key or equivalent;
- duplicate order request behavior is known;
- duplicate cancellation behavior is known;
- duplicate refund behavior is known;
- timeout-after-mutation behavior is known;
- lookup-after-timeout is available or unavailable;
- provider duplicate prevention limitation is documented.

If provider does not support idempotency, gateway-side duplicate prevention and manual review controls must be stronger.

---

## 19. Cancellation and Refund Verification

Cancellation and refund capability must be verified separately from order creation.

Required verification:

- original transaction reference required;
- cancellation window known;
- refund window known;
- full refund support known;
- partial refund support known;
- payment method restrictions known;
- provider response evidence captured;
- duplicate cancel/refund prevention known;
- settlement impact known;
- manual exception path defined.

Refund automation must remain disabled until verification passes.

---

## 20. Receipt and Settlement Verification

Provider onboarding must verify receipt and settlement behavior.

Required checks:

- POS receipt number availability;
- bill number availability;
- approval number availability;
- cancellation receipt availability;
- refund receipt availability;
- settlement batch reference availability;
- settlement export timing;
- fee data availability where applicable;
- closing report availability;
- transaction-level settlement matching possibility.

If settlement matching is not possible, the provider must be restricted for financial reporting automation.

---

## 21. Webhook and Event Verification

If provider supports webhook or event callbacks, the following must be verified:

- event delivery reliability;
- event ordering;
- duplicate event behavior;
- retry behavior;
- signature verification;
- event timestamp semantics;
- missing event detection;
- webhook secret rotation;
- fallback polling path.

Webhook support must not be trusted without replay and missing-event handling.

---

## 22. Provider Support and Escalation Verification

Provider onboarding must verify support process.

Required support information:

- support contact;
- emergency contact;
- support hours;
- escalation SLA where available;
- required evidence format;
- provider incident ticket process;
- production credential support process;
- settlement inquiry process;
- refund/cancellation inquiry process;
- maintenance notification channel.

Provider escalation path must be known before critical production certification.

---

## 23. Store Rollout Eligibility

A provider may be used for store rollout only when:

- provider certification scope includes the target store/capability;
- restrictions are visible;
- store onboarding checklist includes provider-specific requirements;
- smoke tests are updated for provider behavior;
- monitoring rules include provider error codes;
- incident runbook includes provider escalation path;
- reconciliation rules include provider settlement behavior;
- rollback path exists.

Provider certification does not eliminate store-level readiness.

---

## 24. Expansion Control

Provider expansion must be controlled.

Expansion types:

- additional store;
- additional tenant;
- additional payment method;
- cancellation automation;
- refund automation;
- KDS routing;
- kiosk reuse;
- delivery order integration;
- settlement automation;
- multi-provider routing.

Expansion requires:

- stable certification status;
- error budget availability;
- no unresolved critical incidents;
- reconciliation stability;
- provider limitation review;
- updated runbook;
- updated monitoring;
- updated restrictions.

Expansion must stop when repeated provider-specific incidents occur.

---

## 25. Reassessment Triggers

Provider certification must be reassessed when:

- provider API version changes;
- credential model changes;
- provider settlement export changes;
- cancellation/refund behavior changes;
- provider outage pattern changes;
- rate limit changes;
- support channel changes;
- adapter version changes;
- major incident occurs;
- reconciliation variance repeats;
- new store operating mode differs materially;
- provider documentation is revised;
- provider is acquired, rebranded, or platform-migrated.

Certification must not be treated as permanent.

---

## 26. Provider Deprecation and Retirement

A provider may be deprecated when:

- capability is no longer sufficient;
- support is unreliable;
- financial evidence is inadequate;
- cancellation/refund risk is unacceptable;
- settlement reconciliation is consistently weak;
- provider API is unstable;
- security posture is inadequate;
- better provider path exists.

Deprecation means:

- no new rollout;
- existing stores may remain under restriction;
- migration plan required;
- known risk register updated.

Retirement means:

- active routing removed;
- credentials revoked;
- evidence retained;
- migration/backfill preserved;
- documentation updated.

---

## 27. Provider Evidence Packet

Each provider certification must create an evidence packet.

Required sections:

```text
provider_summary
capability_matrix
documentation_review
credential_verification
sandbox_test_result
production_probe_result
error_code_mapping
idempotency_behavior_result
cancel_refund_verification
receipt_settlement_verification
webhook_event_verification
support_escalation_verification
restriction_list
known_limitation_register
certification_decision
reassessment_condition
```

Evidence packet must be retained and linked to provider registry.

---

## 28. Dashboard Requirements

The operations dashboard must show provider onboarding and certification state.

Required fields:

- provider code;
- provider type;
- certification status;
- certification level;
- certified scope;
- active restrictions;
- known limitations;
- active stores;
- adapter version;
- credential status;
- provider health status;
- last smoke test result;
- last production probe result;
- last incident;
- last reassessment date;
- next review date.

A provider must not appear as fully available when it is restricted.

---

## 29. Prohibited Practices

The following practices are prohibited:

- treating provider documentation as proof of production behavior;
- copying certification from one provider to another;
- assuming sandbox behavior equals production behavior;
- enabling refund automation because order write works;
- enabling cancellation without original transaction verification;
- enabling production routing with unknown credential scope;
- hiding provider limitations from store onboarding;
- ignoring provider-specific error codes;
- retrying unknown financial mutation results blindly;
- expanding provider rollout during unresolved incident pattern;
- retiring provider without preserving historical evidence.

---

## 30. Minimum Acceptance Criteria

Provider onboarding is acceptable only when:

- provider registry exists;
- capability matrix exists;
- documentation review is recorded;
- credential and environment verification is completed;
- sandbox verification is completed where available;
- controlled production probe is completed where required;
- certification scope is explicit;
- restrictions are documented;
- error code mapping exists;
- idempotency behavior is verified;
- cancellation/refund behavior is separately verified;
- receipt and settlement behavior are verified;
- support escalation path is documented;
- evidence packet is retained;
- reassessment triggers are defined.

---

## 31. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_providers
pos_gateway_provider_capability_matrix
pos_gateway_provider_discovery_reports
pos_gateway_provider_documentation_reviews
pos_gateway_provider_credentials_registry
pos_gateway_provider_certifications
pos_gateway_provider_restrictions
pos_gateway_provider_limitations
pos_gateway_provider_error_code_mappings
pos_gateway_provider_test_results
pos_gateway_provider_evidence_packets
pos_gateway_provider_reassessment_records
```

Recommended services:

```text
ProviderRegistryService
ProviderDiscoveryService
CapabilityMatrixService
ProviderDocumentationReviewService
ProviderCredentialVerificationService
ProviderCertificationService
ProviderRestrictionService
ProviderLimitationRegisterService
ProviderErrorMappingService
ProviderProductionProbeService
ProviderReassessmentService
ProviderDeprecationService
```

Recommended event types:

```text
pos_gateway.provider.registered
pos_gateway.provider.discovery_started
pos_gateway.provider.documentation_reviewed
pos_gateway.provider.credential_verified
pos_gateway.provider.sandbox_verified
pos_gateway.provider.production_probe_started
pos_gateway.provider.production_probe_passed
pos_gateway.provider.certified
pos_gateway.provider.certified_with_restrictions
pos_gateway.provider.restricted
pos_gateway.provider.blocked
pos_gateway.provider.reassessment_required
pos_gateway.provider.deprecated
pos_gateway.provider.retired
```

---

## 32. Relationship To Adjacent Documents

This document is related to:

- 06000 POS Gateway Implementation lane index, readiness check, evidence map, and next-phase handoff policy;
- POS Gateway adapter implementation contract policy;
- POS Gateway runtime configuration and production credential activation policy;
- POS Gateway production readiness and smoke test policy;
- POS Gateway production cutover and rollback policy;
- POS Gateway monitoring and alerting policy;
- POS Gateway incident response and provider escalation policy;
- POS Gateway reconciliation and settlement linkage policy;
- POS Gateway cancellation and refund protection policy;
- POS Gateway store onboarding and production enablement policy.

Where conflict exists, this document governs provider onboarding, provider certification, provider capability verification, and provider expansion control.

---

## 33. Summary

A new provider is not just a new integration.

A provider changes the behavior of orders, payments, cancellations, refunds, receipts, settlement, incidents, support, and store operations.

The POS Gateway must therefore onboard providers through:

- discovery;
- documentation review;
- credential verification;
- capability matrix;
- sandbox testing;
- controlled production probe;
- scoped certification;
- restriction tracking;
- evidence retention;
- reassessment and expansion control.

The correct standard is not “the API works.”  
The correct standard is “we know exactly what this provider can and cannot safely do in production.”