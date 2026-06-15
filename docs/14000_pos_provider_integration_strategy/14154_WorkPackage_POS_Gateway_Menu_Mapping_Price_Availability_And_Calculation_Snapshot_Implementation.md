# 14154_WorkPackage_POS_Gateway_Menu_Mapping_Price_Availability_And_Calculation_Snapshot_Implementation

## 1. Purpose

This document defines the implementation work package for POS Gateway menu mapping, price versioning, availability control, and calculation snapshot.

After the core registry is established, the gateway must know what can be sold, how it maps to the external POS/KDS provider, whether it is available, and how the final payable amount is calculated.

The POS Gateway must not send an order to POS when:

- menu item mapping is missing;
- option or modifier mapping is invalid;
- provider-specific POS code is unknown;
- price version is inactive;
- availability state is stale;
- sold-out state conflicts with order;
- tax, fee, discount, coupon, service charge, or tip structure cannot be snapshotted;
- calculation total cannot be reconstructed later.

This work package creates the sellable item and calculation foundation required before order mutation.

---

## 2. Scope

This work package covers implementation of:

- menu item registry for gateway use;
- option and modifier mapping;
- POS provider code mapping;
- KDS routing references;
- menu versioning;
- mapping activation;
- unmapped item fail-closed behavior;
- price versioning;
- calculation component model;
- tax list support;
- fee list support;
- discount/coupon component support;
- service charge support;
- tip field readiness;
- provider adjustment field readiness;
- currency and minor-unit support;
- availability status;
- sold-out state;
- stale availability blocking;
- calculation snapshot;
- mapping and calculation audit events;
- required tests before transaction layer.

This document does not implement final order/payment state machine.  
It prepares the validated input and immutable calculation data that later order records must reference.

---

## 3. Core Principle

The POS Gateway must not treat menu, price, and availability as display data.

They are transaction controls.

Every order must be based on:

```text
active menu version
valid provider mapping
valid option/modifier mapping
active price version
current availability decision
calculation snapshot
currency and tax context
```

If any of these are missing or invalid, order creation must fail closed or require staff/manual review.

---

## 4. Implementation Position

This work package follows:

```text
14153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md
```

This work package precedes:

```text
14155_WorkPackage_POS_Gateway_Order_Payment_Cancel_Refund_State_Machine_And_Transaction_Timeline_Implementation.md
06340_POS_Gateway_Idempotency_Queue_Retry_Dead_Letter_Replay_And_Duplicate_Prevention_Implementation_Work_Package.md
06350_POS_Gateway_POS_KDS_Adapter_Interface_Routing_Error_Normalization_And_Provider_Contract_Implementation_Work_Package.md
```

Order state machine must not be built on unversioned menu or price data.

---

## 5. Required Implementation Domains

The implementation must define these domains:

```text
menu_catalog
menu_item
menu_option_group
menu_option
modifier
provider_menu_mapping
provider_option_mapping
provider_modifier_mapping
menu_version
mapping_version
price_version
availability_status
sold_out_state
calculation_rule
calculation_snapshot
tax_line
fee_line
discount_line
coupon_line
service_charge_line
tip_component
provider_adjustment_line
```

The exact table structure may vary, but these concepts must remain distinct and auditable.

---

## 6. Menu Catalog Model

Menu catalog represents the tenant/store menu structure used by the gateway.

Required fields:

```text
menu_catalog_id
tenant_id
store_id
catalog_code
catalog_name
country_code
currency_code
status
created_at_utc
updated_at_utc
```

Recommended statuses:

```text
draft
active
paused
archived
```

Menu catalog must be scoped by tenant and store, even when inherited from tenant-level template.

---

## 7. Menu Item Model

Menu item represents a sellable item before provider-specific mapping.

Required fields:

```text
menu_item_id
tenant_id
store_id
menu_catalog_id
item_code
item_name
item_type
base_category
sellable_flag
requires_option_flag
tax_category_code
kds_category_code
status
created_at_utc
updated_at_utc
```

Recommended item types:

```text
single
set
combo
bundle
service_item
fee_item
discount_item
```

A menu item may be visible but not sellable.

Sellability must be validated separately from display.

---

## 8. Option Group Model

Option group represents a selection rule.

Required fields:

```text
option_group_id
tenant_id
store_id
menu_item_id
group_code
group_name
min_select_count
max_select_count
required_flag
selection_type
status
created_at_utc
updated_at_utc
```

Recommended selection types:

```text
single_select
multi_select
quantity_select
nested_select
```

Option group validation must happen before calculation.

---

## 9. Option and Modifier Model

Option and modifier records must represent item-level customizations.

Required fields:

```text
option_id
tenant_id
store_id
option_group_id
option_code
option_name
price_delta_rule
availability_status
status
created_at_utc
updated_at_utc
```

Modifier fields:

```text
modifier_id
tenant_id
store_id
modifier_code
modifier_name
modifier_type
price_delta_rule
status
created_at_utc
updated_at_utc
```

Options and modifiers may affect:

- price;
- tax category;
- KDS route;
- provider mapping;
- availability;
- preparation instruction.

---

## 10. Provider Menu Mapping

Provider menu mapping connects internal menu items to POS provider codes.

Required fields:

```text
provider_menu_mapping_id
tenant_id
store_id
provider_id
provider_environment_id
menu_item_id
provider_item_code
provider_item_name
mapping_status
mapping_version_id
effective_from_utc
effective_until_utc
created_at_utc
updated_at_utc
```

Recommended mapping statuses:

```text
draft
pending_validation
valid
invalid
active
paused
archived
```

Active provider mapping is required before POS write.

---

## 11. Provider Option and Modifier Mapping

Option and modifier mapping must be provider-specific.

Required option mapping fields:

```text
provider_option_mapping_id
tenant_id
store_id
provider_id
option_id
provider_option_code
mapping_status
mapping_version_id
effective_from_utc
effective_until_utc
```

Required modifier mapping fields:

```text
provider_modifier_mapping_id
tenant_id
store_id
provider_id
modifier_id
provider_modifier_code
mapping_status
mapping_version_id
effective_from_utc
effective_until_utc
```

Nested or provider-specific option structures must be validated before activation.

---

## 12. Mapping Version

Mapping version groups menu, option, modifier, and provider-code mapping into an activation unit.

Required fields:

```text
mapping_version_id
tenant_id
store_id
provider_id
version_code
source_template_id
activation_status
validated_at_utc
activated_at_utc
activated_by
rollback_mapping_version_id
status
```

Recommended activation statuses:

```text
draft
validating
validated
scheduled
active
rollback_ready
retired
failed
```

Every order must reference the mapping version used at creation time.

---

## 13. Mapping Activation Policy

Mapping activation must be controlled.

Activation requires:

- item mapping valid;
- required option mapping valid;
- modifier mapping valid;
- provider capability supports required structure;
- price version compatible;
- availability status initialized;
- rollback version exists where applicable;
- validation result stored.

Activation must create audit event.

Unvalidated mapping must not become active.

---

## 14. Unmapped Item Fail-Closed Rule

If an item, option, or modifier is unmapped for the target provider, the gateway must fail closed.

Allowed outcomes:

```text
reject_order_creation
hide_item_from_channel
require_staff_manual_review
route_to_manual_pos_entry
```

The system must not guess provider codes.

Unmapped item rejection must be traceable to a denial reason.

---

## 15. Price Version Model

Price version represents the effective price rules used for calculation.

Required fields:

```text
price_version_id
tenant_id
store_id
menu_item_id
currency_code
base_price_minor
price_includes_tax_flag
effective_from_utc
effective_until_utc
activation_status
approved_by
created_at_utc
updated_at_utc
```

Price version must be immutable after activation.

Corrections require a new version.

---

## 16. Option Price Delta

Options and modifiers may add or subtract price.

Required fields:

```text
price_delta_id
tenant_id
store_id
option_id
modifier_id
currency_code
delta_amount_minor
effective_from_utc
effective_until_utc
status
```

Price deltas must be included in calculation snapshot.

---

## 17. Currency and Minor Unit Requirement

All money values must store currency context.

Required fields:

```text
currency_code
amount_minor
currency_exponent
```

The system must not assume KRW-only or zero-decimal behavior.

Even if the domestic MVP starts with KRW, schema must allow currencies with decimal minor units.

---

## 18. Calculation Component Model

The calculation engine must produce component lines, not only one final total.

Recommended components:

```text
subtotal
option_delta
modifier_delta
discount
coupon
membership_benefit
service_charge
fee
tax
tip
rounding
provider_adjustment
grand_total
```

Each component must be reconstructable.

The final amount must be derived from component lines and stored as a snapshot.

---

## 19. Tax Line Model

Tax must support multiple tax lines.

Required fields:

```text
tax_line_id
calculation_snapshot_id
tax_code
tax_name
tax_type
tax_rate
tax_amount_minor
tax_jurisdiction_code
tax_inclusive_flag
applies_to_component
provider_tax_code
```

Domestic VAT may be one line, but global-ready structure must support many.

---

## 20. Fee and Service Charge Model

Fee and service charge must be separate from tax and item price.

Required fields:

```text
fee_line_id
calculation_snapshot_id
fee_code
fee_name
fee_type
fee_amount_minor
fee_taxable_flag
provider_fee_code
```

Service charge fields:

```text
service_charge_line_id
calculation_snapshot_id
service_charge_code
service_charge_rate
service_charge_amount_minor
service_charge_taxable_flag
```

Do not hide service charge inside item price unless policy explicitly requires it and snapshot records it.

---

## 21. Discount and Coupon Line Model

Discount and coupon must be recorded separately.

Required discount fields:

```text
discount_line_id
calculation_snapshot_id
discount_code
discount_type
discount_amount_minor
discount_rate
applies_to
source_module
```

Required coupon fields:

```text
coupon_line_id
calculation_snapshot_id
coupon_id
coupon_code
coupon_amount_minor
coupon_status_at_use
coupon_reversal_required_flag
```

Coupon consumption must later link to transaction state and refund/cancel reversal.

---

## 22. Tip Component Readiness

Tip must be supported as a first-class component for global readiness.

Required fields:

```text
tip_component_id
calculation_snapshot_id
tip_amount_minor
tip_type
tip_rate
tip_entered_by
tip_settlement_status
```

Domestic MVP may set tip to zero or null, but the schema must not require rewrite for overseas expansion.

---

## 23. Provider Adjustment Component

External POS or payment provider may report adjustment values.

Required fields:

```text
provider_adjustment_id
calculation_snapshot_id
provider_id
adjustment_code
adjustment_amount_minor
adjustment_reason
provider_reference
```

Provider adjustment must be visible in reconciliation.

It must not silently alter the original calculation snapshot.

---

## 24. Calculation Snapshot

Calculation snapshot is the immutable record of amount logic used at order creation.

Required fields:

```text
calculation_snapshot_id
tenant_id
store_id
menu_item_refs
mapping_version_id
price_version_refs
currency_code
subtotal_amount_minor
discount_total_minor
coupon_total_minor
fee_total_minor
service_charge_total_minor
tip_amount_minor
tax_total_minor
rounding_amount_minor
provider_adjustment_total_minor
grand_total_minor
calculation_policy_version
created_at_utc
```

Snapshot must be immutable.

Later refund/cancel/reconciliation logic must reference this snapshot.

---

## 25. Calculation Validation

Before order creation, the system must validate:

- active mapping version;
- active price version;
- option selection rules;
- option price deltas;
- tax rule;
- discount/coupon eligibility;
- currency consistency;
- total arithmetic;
- provider-supported amount structure;
- rounding rule;
- availability.

Validation failure must block transaction or route to manual review.

---

## 26. Availability Status Model

Availability status determines whether an item can be sold.

Required fields:

```text
availability_status_id
tenant_id
store_id
menu_item_id
option_id
modifier_id
channel_scope
availability_state
source_type
source_reference
updated_at_utc
expires_at_utc
status
```

Recommended availability states:

```text
available
limited
sold_out
temporarily_unavailable
unknown
stale
manual_review_required
```

Unknown or stale availability must not default to available for high-risk channels.

---

## 27. Sold-Out State Model

Sold-out state must be explicit and reversible.

Required fields:

```text
sold_out_state_id
tenant_id
store_id
menu_item_id
option_id
channel_scope
sold_out_flag
reason_code
set_by_actor_id
set_at_utc
expected_restore_at_utc
restored_by_actor_id
restored_at_utc
status
```

Sold-out changes must create audit events.

---

## 28. Availability Source Policy

Availability may come from:

```text
manual_staff_action
inventory_system
pos_provider
kds_provider
hq_menu_control
scheduled_rule
incident_fallback
```

Each source must be recorded.

When sources conflict, the safest sellability decision must win.

For example:

```text
sold_out overrides available
stale provider state may require manual review
incident pause overrides normal availability
```

---

## 29. Channel-Specific Availability

Availability may differ by channel.

Channel scopes:

```text
dine_in
takeout
delivery
kiosk
qr_table
waiting_preorder
staff_order
```

Example:

- item available for dine-in but not delivery;
- hot item unavailable for scheduled pickup;
- kiosk channel paused during provider outage;
- table ordering blocked when table identity unknown.

Availability must be evaluated at channel scope.

---

## 30. Stale Availability Blocking

Availability must have freshness rules.

Required fields:

```text
updated_at_utc
expires_at_utc
freshness_policy_code
```

If availability is stale:

Allowed outcomes:

```text
block_order
require_staff_confirmation
refresh_availability
hide_item
allow_with_warning
```

High-risk automation should block or require confirmation.

---

## 31. Pre-Payment Availability Validation

Before payment is initiated or before POS order is written, availability must be revalidated.

Validation must check:

- item still sellable;
- required options available;
- channel still enabled;
- store not paused;
- provider route eligible;
- availability not stale;
- sold-out not active.

If item becomes unavailable after cart creation, customer must receive safe status message.

---

## 32. Post-Payment Availability Conflict

If payment succeeds but item becomes unavailable before POS/KDS fulfillment, the system must create a conflict case.

Required conflict data:

```text
transaction_id
calculation_snapshot_id
availability_status_at_order
availability_status_at_conflict
payment_status
customer_message_status
refund_or_substitution_required_flag
manual_review_case_id
created_at_utc
```

This case must link to refund/cancel or substitution policy later.

---

## 33. Master Data Sync Readiness

This work package must prepare for master data sync but does not fully implement large-scale sync.

Required readiness fields:

```text
source_master_version_id
sync_batch_id
transformation_status
cache_ready_flag
activation_scheduled_at_utc
activation_status
```

Mass menu or price updates must later use async batch and cache isolation.

Do not design hot order path to perform heavy transformation.

---

## 34. Transformation Cache Readiness

Provider-specific transformation results should be precomputed.

Potential cached artifacts:

```text
provider_menu_payload
provider_option_payload
provider_modifier_payload
provider_price_payload
provider_tax_payload
provider_kds_payload
customer_display_payload
```

Order creation should reference active validated payloads or version IDs.

---

## 35. Audit Event Requirements

Required audit events:

```text
pos_gateway.menu.item_created
pos_gateway.menu.item_status_changed
pos_gateway.menu.option_created
pos_gateway.menu.mapping_created
pos_gateway.menu.mapping_validated
pos_gateway.menu.mapping_activated
pos_gateway.menu.mapping_rejected
pos_gateway.price.version_created
pos_gateway.price.version_activated
pos_gateway.calculation.snapshot_created
pos_gateway.availability.status_changed
pos_gateway.availability.stale_detected
pos_gateway.sold_out.set
pos_gateway.sold_out.restored
pos_gateway.master_data.sync_scheduled
pos_gateway.master_data.transformation_completed
```

Audit must include actor, tenant, store, version, before/after reference, and created_at_utc.

---

## 36. API Requirements

Recommended internal APIs or service methods:

```text
createMenuItem()
createOptionGroup()
createOption()
createModifier()
createProviderMenuMapping()
validateMappingVersion()
activateMappingVersion()
createPriceVersion()
activatePriceVersion()
evaluateAvailability()
setSoldOut()
restoreSoldOut()
calculateOrderSnapshot()
validateCalculationSnapshot()
resolveSellableItemContext()
```

`resolveSellableItemContext()` should return whether the item can be sold in the requested channel and provider route.

---

## 37. Sellable Item Context Resolver

Input:

```text
tenant_id
store_id
menu_item_id
selected_options
selected_modifiers
channel
provider_id
currency_code
requested_at_utc
```

Output:

```text
sellable
denial_reason
active_mapping_version
active_price_version
availability_state
sold_out_state
calculation_snapshot_preview
provider_mapping_status
option_validation_status
tax_rule_status
currency_status
```

Later order creation must call this resolver before creating transaction state.

---

## 38. Denial Reason Codes

Recommended denial reason codes:

```text
item_inactive
item_not_sellable
mapping_missing
mapping_invalid
mapping_not_active
option_required_missing
option_selection_invalid
option_mapping_missing
modifier_mapping_missing
price_missing
price_inactive
currency_mismatch
tax_rule_missing
calculation_invalid
availability_unknown
availability_stale
item_sold_out
channel_unavailable
provider_not_supported
store_paused
manual_review_required
```

Internal denial reason must be mapped to customer-safe messages later.

---

## 39. Data Model Draft

Recommended table group:

```text
pos_gateway_menu_catalogs
pos_gateway_menu_items
pos_gateway_option_groups
pos_gateway_options
pos_gateway_modifiers
pos_gateway_provider_menu_mappings
pos_gateway_provider_option_mappings
pos_gateway_provider_modifier_mappings
pos_gateway_mapping_versions
pos_gateway_price_versions
pos_gateway_option_price_deltas
pos_gateway_calculation_rules
pos_gateway_calculation_snapshots
pos_gateway_tax_lines
pos_gateway_fee_lines
pos_gateway_service_charge_lines
pos_gateway_discount_lines
pos_gateway_coupon_lines
pos_gateway_tip_components
pos_gateway_provider_adjustments
pos_gateway_availability_statuses
pos_gateway_sold_out_states
pos_gateway_master_data_sync_refs
pos_gateway_transformation_cache_refs
```

The implementation may normalize further, but the concepts must remain reconstructable.

---

## 40. Constraints

Required constraints:

- menu item code unique within store/catalog;
- mapping version immutable after activation;
- active mapping version cannot overlap improperly for same provider/store/channel;
- price version cannot overlap improperly for same item/currency/effective period;
- calculation snapshot immutable;
- tax lines must sum to tax total;
- component lines must sum to grand total;
- active item cannot be sellable without active mapping where provider route requires mapping;
- stale availability must not be treated as fresh;
- sold-out override must block sellability unless explicitly approved.

---

## 41. Monitoring Requirements

Monitoring must detect:

- active item without provider mapping;
- active mapping with missing option mapping;
- price version missing;
- overlapping price versions;
- calculation validation failure;
- high rate of unavailable item requests;
- stale availability count;
- sold-out conflict after payment;
- master data transformation failure;
- mapping activation failure;
- currency mismatch;
- tax rule missing.

Monitoring should create alerts before customer-facing order failures become widespread.

---

## 42. Test Requirements

Required tests:

```text
menu item activation test
provider mapping validation test
unmapped item fail-closed test
required option validation test
modifier mapping validation test
price version activation test
overlapping price version rejection test
calculation component sum test
tax line sum test
currency minor unit test
tip field compatibility test
availability evaluation test
stale availability blocking test
sold-out override test
post-payment sold-out conflict test
mapping rollback test
calculation snapshot immutability test
```

No order state machine implementation should proceed without sellable item resolver tests.

---

## 43. Acceptance Criteria

This work package is acceptable only when:

- menu catalog and item models exist;
- option group, option, and modifier models exist;
- provider item/option/modifier mapping exists;
- mapping version and activation exist;
- unmapped item fail-closed rule exists;
- price version exists;
- calculation component model exists;
- tax list support exists;
- fee, discount, coupon, service charge, tip, and provider adjustment support exists;
- calculation snapshot exists and is immutable;
- availability status exists;
- sold-out state exists;
- stale availability blocking exists;
- pre-payment availability validation exists;
- post-payment availability conflict model exists;
- master data sync and transformation cache readiness exist;
- sellable item context resolver exists;
- audit events, denial reason codes, monitoring, and tests exist.

---

## 44. Relationship To Adjacent Documents

This document is related to:

- 06310 POS Gateway core registry, tenant, store, provider capability, and environment binding implementation work package;
- 06305 POS Gateway global scale final boss risk absorption architecture invariant implementation guardrail;
- 06300 POS Gateway implementation task breakdown, executable work package index, and build sequence policy;
- 06220 POS Gateway cross-tenant SaaS standardization, template inheritance, customization, and control boundary policy;
- 06070 POS Gateway inventory, availability, sold-out, stock sync, and order blocking integrity policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy;
- 06050 POS Gateway menu item, option, modifier, mapping template, versioning, and price integrity policy.

Where conflict exists, this document governs implementation of menu mapping, price versioning, availability control, and calculation snapshot for the POS Gateway.

---

## 45. Summary

Menu, price, and availability are not simple master data.

They are transaction safety controls.

Before the POS Gateway can create an order, it must prove:

- the item is sellable;
- the provider mapping is active;
- required options are valid;
- price version is active;
- availability is fresh;
- sold-out state is clear;
- tax, fee, discount, coupon, service charge, tip, and adjustment components can be snapshotted;
- the final total is reconstructable later.

This work package builds the validated sellable item and calculation spine.

Without it, the order state machine would be built on sand.