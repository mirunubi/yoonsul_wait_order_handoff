# 14127_Policy_POS_Gateway_Multi_Provider_Routing_Fallback_Provider_Priority_And_Store_Specific_Adapter_Selection

## 1. Purpose

This document defines the multi-provider routing, fallback, provider priority, and store-specific adapter selection policy for the POS Gateway.

After provider onboarding and certification, the POS Gateway may support multiple POS providers, payment providers, KDS providers, receipt providers, or settlement export providers.

However, multi-provider support must not become uncontrolled dynamic routing.  
A transaction-critical gateway must know exactly which provider is responsible for each store, transaction type, payment method, terminal, table, and operational mode.

This policy exists to ensure that:

- provider routing is explicit and auditable;
- fallback does not create duplicate orders, payments, cancellations, or refunds;
- store-specific provider selection is controlled;
- provider priority does not override certification restrictions;
- routing changes are logged and reversible;
- fallback behavior preserves transaction evidence;
- multi-provider expansion does not weaken financial integrity or customer protection.

---

## 2. Scope

This policy applies to all POS Gateway routing decisions involving multiple providers, including:

- store-specific POS provider selection;
- store-specific payment provider selection;
- KDS provider selection;
- receipt provider selection;
- settlement/export provider selection;
- fallback from primary provider to manual mode;
- fallback from primary provider to secondary provider where allowed;
- fallback from API write mode to provider portal/manual mode;
- provider priority rules;
- adapter version selection;
- transaction-type routing;
- payment-method routing;
- terminal or table based routing;
- emergency routing override;
- provider degradation routing;
- provider migration routing.

This policy does not assume that provider-to-provider fallback is always safe.  
In financial and POS write paths, fallback is often manual rather than automatic.

---

## 3. Core Principle

Multi-provider routing must be deterministic, scoped, and evidence-preserving.

The POS Gateway must not dynamically choose a provider for transaction-critical writes based only on availability or latency.

For POS order writes, payment execution, cancellation, refund, and settlement linkage, provider routing must be:

```text
explicitly configured
certification-aware
store-scoped
transaction-type-scoped
idempotency-protected
audited
reversible at routing level
non-destructive at evidence level
```

Fallback must protect the transaction more than it protects automation continuity.

---

## 4. Provider Routing Model

The gateway must maintain a provider routing model.

Required routing dimensions:

```text
tenant_id
store_id
provider_type
provider_code
adapter_version
transaction_type
payment_method
terminal_id
table_zone_id
business_day_scope
routing_mode
priority_rank
certification_scope
restriction_list
fallback_policy
effective_from
effective_until
status
```

The routing model must support explicit selection rather than implicit discovery.

---

## 5. Provider Types

The routing policy may apply to different provider types.

Recommended provider types:

| Provider Type | Description |
|---|---|
| `pos_provider` | Primary POS system provider |
| `payment_provider` | PG/VAN/simple payment provider |
| `kds_provider` | Kitchen display or kitchen ticket provider |
| `receipt_provider` | Receipt or proof-of-transaction provider |
| `settlement_provider` | Settlement or accounting export provider |
| `delivery_order_provider` | Delivery order aggregator provider |
| `kiosk_provider` | Hardware or software kiosk provider |
| `table_order_provider` | Table order or QR ordering provider |
| `manual_provider` | Manual staff-operated fallback path |

Provider type must be part of routing identity.

---

## 6. Routing Modes

The gateway must classify routing modes.

Recommended routing modes:

| Routing Mode | Meaning |
|---|---|
| `disabled` | Provider route is unavailable |
| `read_only` | Provider may be queried but not mutated |
| `shadow` | Provider route is evaluated without active business effect |
| `manual_only` | Staff or operator must perform action manually |
| `primary_active` | Provider is the active route |
| `secondary_standby` | Provider is configured but not used unless approved |
| `limited_active` | Provider is active only for restricted scope |
| `fallback_manual` | Automation disabled, manual route active |
| `fallback_secondary` | Secondary provider route active under controlled policy |
| `rollback_mode` | Routing reverted after cutover or incident |
| `migration_mode` | Routing under provider migration controls |

The routing mode must be visible to operations.

---

## 7. Primary Provider Selection

Each production store must have a primary provider selection for active transaction paths.

Primary provider selection must be based on:

- provider certification status;
- store contract or operational setup;
- store POS installation;
- provider capability;
- transaction type;
- payment method;
- terminal/table requirements;
- settlement linkage;
- cancellation/refund support;
- monitoring support;
- incident escalation support;
- known restrictions.

Primary provider must not be selected solely because it is technically reachable.

---

## 8. Store-Specific Adapter Selection

Adapter selection must be scoped to the store.

Required adapter selection fields:

```text
adapter_selection_id
tenant_id
store_id
provider_code
provider_type
adapter_version
selected_capabilities
routing_mode
selection_reason
selected_by
approved_by
effective_from
status
```

A provider adapter certified for one store must not automatically apply to another store unless the certification scope explicitly allows it.

Store-specific adapter selection must be reviewed when:

- POS terminal changes;
- table layout changes;
- menu mapping changes;
- payment method changes;
- store operating mode changes;
- provider credential changes;
- adapter version changes;
- store joins kiosk or table ordering flow.

---

## 9. Provider Priority Policy

Provider priority may be used only within safe boundaries.

Allowed priority use:

- selecting read provider when multiple read sources exist;
- selecting settlement export source where multiple evidence sources exist;
- selecting KDS display route where duplication risk is controlled;
- selecting provider for non-financial status lookup;
- selecting manual fallback instruction priority.

Restricted priority use:

- POS order write;
- payment execution;
- cancellation;
- refund;
- receipt issuance;
- settlement finalization.

For restricted paths, priority must not automatically switch provider without explicit approval or pre-certified fallback rule.

---

## 10. Fallback Types

The gateway must classify fallback types.

| Fallback Type | Description |
|---|---|
| `no_fallback` | Failure stops automated path and requires review |
| `manual_fallback` | Staff performs action manually |
| `read_lookup_fallback` | Alternate provider/source used only for lookup |
| `provider_portal_fallback` | Staff verifies or acts through provider portal |
| `secondary_provider_fallback` | Secondary provider executes action under strict rule |
| `delayed_retry_fallback` | Gateway retries later after safe classification |
| `rollback_fallback` | Route reverts to prior operational mode |
| `customer_service_fallback` | Customer support/manual dispute process used |

The fallback type must be declared before production activation.

---

## 11. Automatic Fallback Restriction

Automatic fallback is prohibited for high-risk financial mutation unless explicitly certified.

Automatic fallback must not be used for:

- payment execution;
- refund execution;
- cancellation execution;
- POS order write after unknown mutation result;
- settlement finalization;
- receipt reissue with uncertain source state.

Automatic fallback may be used only when:

- idempotency safety is proven;
- provider state lookup is available;
- duplicate risk is controlled;
- certification explicitly permits it;
- monitoring and audit evidence are active;
- rollback rule exists.

If these conditions are not met, fallback must become manual review.

---

## 12. Manual Fallback Policy

Manual fallback is the default safe fallback for uncertain transaction-critical states.

Manual fallback may include:

- staff manually entering order into POS;
- manager verifying payment provider dashboard;
- staff confirming receipt in POS;
- provider portal cancellation;
- payment provider portal refund;
- manual reconciliation annotation;
- customer support follow-up;
- store operator approval before completion.

Manual fallback must produce an audit record.

Required manual fallback record:

```text
manual_fallback_id
tenant_id
store_id
transaction_id
provider_code
failed_route
fallback_reason
manual_action_type
performed_by
approved_by
evidence_reference
customer_impact
created_at
status
```

---

## 13. Secondary Provider Fallback Policy

Secondary provider fallback is allowed only in limited cases.

It may be considered for:

- KDS routing where duplicate ticket prevention exists;
- read-only status lookup;
- settlement evidence supplement;
- non-financial notification routing;
- order routing only when provider identity and store workflow support it.

It is generally unsafe for:

- payment execution;
- refund execution;
- cancellation execution;
- POS order write after unknown primary result.

Secondary provider fallback requires:

- certification for fallback use;
- explicit routing rule;
- idempotency boundary;
- duplicate prevention;
- operational approval;
- monitoring;
- reconciliation;
- evidence packet.

---

## 14. Provider Degradation Routing

When a provider becomes degraded, the gateway must classify routing response.

Degradation responses:

| Provider State | Required Routing Response |
|---|---|
| `latency_degraded` | Continue with warning or restrict expansion |
| `write_degraded` | Pause write expansion and monitor |
| `write_unknown` | Stop automated write and require review |
| `auth_failed` | Disable affected route |
| `rate_limited` | Throttle or pause route |
| `maintenance` | Switch to approved fallback or manual mode |
| `partial_outage` | Disable affected transaction types |
| `financial_uncertainty` | Freeze mutation path and reconcile |
| `provider_down` | Activate manual fallback or rollback |

Provider degradation must not be hidden from store-facing status when it affects operation.

---

## 15. Transaction-Type Routing

Routing may differ by transaction type.

Recommended transaction types:

```text
order_create
order_lookup
order_cancel
payment_reference_attach
payment_execute
payment_cancel
refund_execute
receipt_lookup
receipt_reissue
kds_ticket_create
kds_ticket_cancel
settlement_lookup
closing_report_fetch
status_lookup
```

Each transaction type must have its own routing rule.

A provider approved for `order_lookup` is not automatically approved for `order_create`.  
A provider approved for `payment_reference_attach` is not automatically approved for `payment_execute`.

---

## 16. Payment-Method Routing

Some providers may support only certain payment methods.

Payment-method routing must consider:

- card;
- cash;
- simple payment;
- local wallet;
- gift certificate;
- coupon;
- membership point;
- split payment;
- partial refund;
- offline payment;
- delivery platform payment.

Payment-method routing must not assume that refund behavior matches payment behavior.

Each payment method must define:

```text
payment_method_code
primary_provider
fallback_policy
refund_support
cancel_support
settlement_support
restriction_list
```

---

## 17. Terminal and Table Routing

Some providers require terminal or table mapping.

Terminal/table routing must consider:

- POS terminal ID;
- payment terminal ID;
- KDS station;
- table number;
- table zone;
- floor;
- order channel;
- staff device;
- kiosk device;
- QR table object.

Routing must fail closed when required terminal or table mapping is missing.

Unknown terminal or table routing must not silently default to a production terminal.

---

## 18. Adapter Version Routing

Multiple adapter versions may exist during rollout.

Adapter version routing must be:

- scoped by store;
- scoped by provider;
- scoped by capability;
- tied to deployment version;
- tied to certification level;
- monitored separately;
- rollback-capable.

Adapter version change must be treated as a material change when it affects transaction semantics.

The gateway must support identifying which adapter version handled each transaction.

---

## 19. Routing Rule Precedence

Routing rule precedence must be deterministic.

Recommended precedence order:

```text
1. Emergency disable / rollback mode
2. Active incident containment rule
3. Store-specific restriction
4. Provider certification restriction
5. Transaction-type routing rule
6. Payment-method routing rule
7. Terminal/table routing rule
8. Adapter version rule
9. Default store provider rule
10. Manual fallback rule
```

No lower-priority rule may override an emergency disable, active restriction, or incident containment rule.

---

## 20. Routing Decision Evidence

Every transaction-critical routing decision must be explainable.

Required routing decision evidence:

```text
routing_decision_id
tenant_id
store_id
transaction_id
transaction_type
payment_method
provider_type
selected_provider_code
selected_adapter_version
routing_mode
fallback_type
rule_id
rule_version
restriction_applied
incident_override_applied
cutover_epoch_id
decision_reason
created_at
```

Routing decision evidence must be linked to audit events and incident investigation.

---

## 21. Routing Change Control

Routing changes must be controlled.

Routing changes requiring approval:

- primary provider change;
- provider fallback change;
- payment method provider change;
- cancellation/refund route change;
- production adapter version change;
- store migration route change;
- emergency manual fallback removal;
- provider restriction removal.

Routing changes must create:

- change request;
- approval record;
- effective time;
- rollback plan;
- monitoring plan;
- evidence packet.

Emergency routing changes may be executed quickly but must be recorded afterward.

---

## 22. Emergency Routing Override

Emergency routing override may be used to protect stores or customers.

Allowed emergency overrides:

- disable active provider write path;
- force manual fallback;
- pause refund automation;
- pause cancellation automation;
- disable KDS route;
- block payment execution;
- block retry worker;
- isolate affected store/provider.

Emergency override must not:

- delete transactions;
- bypass audit;
- mark uncertain transactions successful;
- hide provider failure;
- permanently change provider selection without review.

Emergency override must create incident linkage.

---

## 23. Provider Migration Routing

Provider migration requires special routing protection.

During migration, routing may involve:

- old provider read-only lookup;
- old provider settlement evidence;
- new provider active order write;
- manual fallback for historical transactions;
- split routing by business date;
- split routing by transaction origin;
- restriction on refunds for legacy transactions;
- provider portal verification for old transactions.

Migration routing must preserve original provider identity.

A transaction created under Provider A must not be refunded through Provider B unless explicit financial evidence and provider rules support it.

---

## 24. Kiosk and Table Ordering Reuse

Kiosk, QR, or table ordering flows must inherit provider routing restrictions.

They must not bypass:

- store provider selection;
- payment method routing;
- cancellation/refund restrictions;
- table/terminal mapping rules;
- KDS routing restrictions;
- provider certification scope;
- active incident containment;
- rollback mode.

Kiosk reuse must call the same routing decision boundary or a formally equivalent service.

---

## 25. Monitoring Requirements

Multi-provider routing must be monitored.

Required metrics:

- route selection count by provider;
- fallback count by provider;
- manual fallback count;
- provider degradation count;
- routing error count;
- unknown mapping count;
- restriction hit count;
- emergency override count;
- adapter version transaction count;
- provider-specific failure rate;
- provider-specific reconciliation variance;
- provider-specific incident count.

Dashboard must show active provider per store and capability.

---

## 26. Reconciliation Requirements

Reconciliation must use the actual selected provider.

Required reconciliation linkage:

- selected provider;
- adapter version;
- routing decision ID;
- source transaction ID;
- payment provider reference;
- receipt reference;
- settlement provider reference;
- fallback record if used;
- manual correction record if used.

When fallback occurs, reconciliation must verify both original attempted route and fallback route.

---

## 27. Incident Requirements

Incidents must include routing context.

Incident records must show:

- selected provider;
- expected provider;
- fallback attempted;
- fallback blocked;
- restriction applied;
- emergency override applied;
- adapter version;
- routing rule version;
- manual fallback action.

Provider-specific incident patterns must feed back into provider certification and expansion control.

---

## 28. Dashboard Requirements

The operations dashboard must show:

- active primary provider per store;
- active provider by transaction type;
- active provider by payment method;
- routing mode;
- fallback mode;
- provider certification level;
- active restrictions;
- emergency overrides;
- adapter version;
- provider health;
- fallback frequency;
- routing errors;
- last routing change;
- next reassessment date.

The dashboard must not show generic “POS connected” when only some transaction paths are supported.

---

## 29. Prohibited Practices

The following practices are prohibited:

- automatically switching POS write provider after unknown write result;
- retrying payment/refund through another provider without explicit certification;
- using provider priority to bypass restrictions;
- silently defaulting to a provider when mapping is missing;
- treating provider fallback as equivalent to rollback;
- changing store primary provider without evidence;
- hiding manual fallback from reconciliation;
- routing kiosk transactions outside store provider policy;
- routing refund through provider that did not process original payment without evidence;
- showing provider as active for unsupported capabilities.

---

## 30. Minimum Acceptance Criteria

The multi-provider routing process is acceptable only when:

- provider routing model exists;
- routing modes are defined;
- store-specific adapter selection exists;
- provider priority rules are controlled;
- fallback types are explicit;
- automatic fallback restrictions exist;
- manual fallback is auditable;
- secondary provider fallback is restricted;
- transaction-type routing exists;
- payment-method routing exists;
- terminal/table routing fails closed;
- routing rule precedence is deterministic;
- routing decision evidence is retained;
- routing change control exists;
- emergency override is auditable;
- monitoring and reconciliation include routing context.

---

## 31. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_provider_routes
pos_gateway_store_adapter_selections
pos_gateway_provider_priority_rules
pos_gateway_fallback_policies
pos_gateway_routing_rules
pos_gateway_routing_decisions
pos_gateway_routing_change_requests
pos_gateway_emergency_routing_overrides
pos_gateway_manual_fallback_records
pos_gateway_provider_migration_routes
pos_gateway_routing_dashboard_snapshots
```

Recommended services:

```text
ProviderRoutingService
StoreAdapterSelectionService
ProviderPriorityService
FallbackPolicyService
RoutingRuleEvaluator
RoutingDecisionRecorder
RoutingChangeControlService
EmergencyRoutingOverrideService
ManualFallbackService
ProviderMigrationRoutingService
RoutingMonitoringService
RoutingReconciliationLinkService
```

Recommended event types:

```text
pos_gateway.routing.rule_created
pos_gateway.routing.rule_updated
pos_gateway.routing.provider_selected
pos_gateway.routing.fallback_selected
pos_gateway.routing.manual_fallback_required
pos_gateway.routing.secondary_provider_blocked
pos_gateway.routing.emergency_override_applied
pos_gateway.routing.emergency_override_removed
pos_gateway.routing.primary_provider_changed
pos_gateway.routing.adapter_version_changed
pos_gateway.routing.restriction_applied
pos_gateway.routing.decision_recorded
```

---

## 32. Relationship To Adjacent Documents

This document is related to:

- 06010 POS Gateway provider onboarding, certification, capability verification, and expansion control policy;
- POS Gateway provider adapter implementation contract policy;
- POS Gateway idempotency, retry, timeout, and duplicate prevention policy;
- POS Gateway production readiness and smoke test policy;
- POS Gateway monitoring and alerting policy;
- POS Gateway incident response and provider escalation policy;
- POS Gateway reconciliation and settlement linkage policy;
- POS Gateway cancellation and refund protection policy;
- POS Gateway migration and cutover policy;
- kiosk and table ordering reuse boundary policies.

Where conflict exists, this document governs provider routing, fallback, provider priority, store-specific adapter selection, and routing evidence behavior.

---

## 33. Summary

Multi-provider support is not a shortcut to resilience unless routing is controlled.

The POS Gateway must know:

- which provider is responsible;
- for which store;
- for which transaction type;
- under which certification scope;
- with which fallback rule;
- under which restriction;
- with which evidence.

For financial mutation paths, fallback must be conservative.  
It is better to stop automation and preserve truth than to switch providers and create duplicate or untraceable financial actions.

The correct standard is not “try another provider.”  
The correct standard is “route only where the provider, store, transaction, and evidence boundary are proven safe.”