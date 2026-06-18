# 014130_Policy_POS_Gateway_Menu_Item_Option_Modifier_Mapping_Template_Versioning_And_Price_Integrity

## 1. Purpose

This document defines the menu item, option, modifier, mapping template, versioning, and price integrity policy for the POS Gateway.

The POS Gateway cannot safely write orders into POS unless menu identity and price meaning are controlled.

Menu mapping is not a cosmetic configuration task.  
It directly affects order correctness, kitchen preparation, tax amount, discount behavior, receipt evidence, settlement totals, customer disputes, and store trust.

This policy exists to ensure that:

- gateway menu items map safely to POS menu items;
- options and modifiers preserve kitchen and price meaning;
- menu mapping templates are versioned and verified;
- price differences are detected before production write;
- unmapped or ambiguous items fail closed;
- menu updates do not corrupt active orders;
- kiosk, table ordering, and SaaS ordering flows inherit the same menu mapping boundary.

---

## 2. Scope

This policy applies to all menu-related mapping used by the POS Gateway, including:

- menu item mapping;
- option mapping;
- modifier mapping;
- set/combo mapping;
- size mapping;
- temperature mapping;
- spicy level mapping;
- add-on mapping;
- removal/substitution mapping;
- discountable item mapping;
- tax category mapping;
- KDS display name mapping;
- receipt display name mapping;
- price synchronization;
- menu versioning;
- mapping templates;
- provider-specific menu codes;
- tenant/store-specific menu differences;
- kiosk/table ordering menu reuse.

This document governs how the gateway preserves menu identity and price integrity when routing orders to POS and related systems.

---

## 3. Core Principle

The POS Gateway must never guess menu identity or price.

If a customer orders an item through the gateway, the system must know exactly:

```text
which gateway item was ordered
which POS item it maps to
which options/modifiers were selected
which kitchen instruction should be produced
which price should be charged
which tax/discount rules apply
which receipt identity should be shown
which menu version was active at order time
```

If this cannot be proven, the order must not be automatically written into POS.

---

## 4. Menu Mapping Status Model

Each mapping record must have an explicit status.

Recommended statuses:

| Status | Meaning |
|---|---|
| `draft` | Mapping is being prepared |
| `imported_unverified` | Mapping imported but not reviewed |
| `template_applied` | Mapping created from template but not verified |
| `verified` | Mapping verified for store/provider scope |
| `active` | Mapping can be used for production order write |
| `restricted` | Mapping active only under stated limits |
| `deprecated` | Mapping should not be used for new orders |
| `blocked` | Mapping is unsafe or invalid |
| `archived` | Mapping retained for historical evidence |

Only `active` or approved `restricted` mappings may be used for production order writes.

---

## 5. Menu Identity Model

The gateway must preserve multiple menu identities.

Required identity fields:

```text
gateway_menu_item_id
tenant_menu_item_id
store_menu_item_id
provider_menu_item_id
pos_menu_item_code
pos_menu_item_name
kds_display_name
receipt_display_name
menu_version_id
mapping_version_id
effective_from
effective_until
status
```

The gateway must not replace POS menu identity with a gateway-only name.  
Provider identifiers must be retained for transaction evidence and reconciliation.

---

## 6. Option and Modifier Identity Model

Options and modifiers must have stable mapping.

Required fields:

```text
gateway_option_id
gateway_modifier_id
provider_option_code
provider_modifier_code
pos_option_name
pos_modifier_name
modifier_group
modifier_type
price_delta
kitchen_display_behavior
receipt_display_behavior
required_flag
max_selection_count
mapping_version_id
status
```

Modifiers must not be collapsed into free-text instructions when the POS or KDS requires structured option codes.

Free-text instructions may be allowed only where provider capability and kitchen workflow support them.

---

## 7. Mapping Scope

Menu mapping must be scoped.

Required scope dimensions:

```text
tenant_id
store_id
provider_code
adapter_version
menu_source
menu_version_id
mapping_version_id
order_channel
payment_method_scope
kds_scope
effective_from
effective_until
```

A mapping verified for one store must not automatically apply to another store unless the template and provider configuration explicitly support inheritance.

---

## 8. Mapping Template Policy

Mapping templates may be used to accelerate setup.

Template types:

- standard store menu template;
- provider-specific menu template;
- brand-wide menu template;
- seasonal menu template;
- promotion menu template;
- kiosk/table ordering menu template;
- KDS display template;
- receipt display template;
- tax/discount mapping template.

Templates must not be treated as verified production mapping.

Each template-applied mapping must be verified at store/provider scope before active use.

---

## 9. Mapping Template Versioning

Mapping templates must be versioned.

Required template metadata:

```text
template_id
template_name
template_type
template_version
tenant_id
provider_code
supported_store_type
supported_menu_category
created_by
approved_by
effective_from
status
```

When a template changes, existing active mappings must not silently change.

A template update may create a new candidate mapping version, but production activation requires verification.

---

## 10. Mapping Version Policy

Each production menu mapping must belong to a mapping version.

Required mapping version fields:

```text
mapping_version_id
tenant_id
store_id
provider_code
source_menu_version_id
mapping_source
created_by
verified_by
approved_by
effective_from
effective_until
activation_reason
status
```

Mapping versions must be immutable after activation.  
Corrections must create a new mapping version.

Orders must retain the mapping version used at order creation time.

---

## 11. Menu Version Snapshot

The gateway must preserve the menu version used for each order.

Required order-level references:

```text
order_id
menu_version_id
mapping_version_id
price_version_id
tax_rule_version_id
discount_rule_version_id
created_at
```

Historical order reconstruction must be possible even after menu price or mapping changes.

---

## 12. Price Integrity Policy

Price integrity must be verified before order write.

Required price checks:

- gateway item price matches POS item price or approved override exists;
- option/modifier price delta matches POS price or approved override exists;
- combo/set price logic is consistent;
- tax-included/tax-excluded behavior is known;
- discount application order is known;
- rounding behavior is known;
- payment total equals order total;
- receipt total can be reconciled;
- price version is recorded.

If price mismatch is detected, the system must fail closed or route to manual review unless an approved price override policy applies.

---

## 13. Price Mismatch Classification

Price mismatches must be classified.

| Classification | Meaning | Required Response |
|---|---|---|
| `minor_rounding_difference` | Small rounding difference within approved rule | Allow if policy permits |
| `template_price_stale` | Template price differs from current POS price | Block or reverify |
| `pos_price_changed` | POS price changed after mapping activation | Block affected item |
| `gateway_price_changed` | Gateway price changed without POS sync | Block affected item |
| `modifier_price_mismatch` | Option/modifier price mismatch | Block affected modifier |
| `tax_rule_mismatch` | Tax treatment differs | Block order write |
| `discount_rule_mismatch` | Discount behavior differs | Block or manual review |
| `unknown_price_source` | Price cannot be verified | Block production write |

Price mismatch must be visible in readiness, smoke test, and operations dashboards.

---

## 14. Tax and Discount Mapping

Menu mapping must include tax and discount behavior where applicable.

Required tax fields:

```text
tax_category_code
tax_included_flag
tax_rate
tax_rule_version_id
provider_tax_code
```

Required discount fields:

```text
discount_code
discount_type
discount_scope
discount_provider_code
discount_stackability
discount_rule_version_id
```

Tax and discount mismatch can affect settlement and customer receipt evidence.  
Therefore, these mappings must be treated as transaction-critical.

---

## 15. Set, Combo, and Bundle Mapping

Set/combo mapping must preserve both customer-facing and POS-facing meaning.

Required checks:

- set item identity;
- component item identity;
- required choices;
- optional choices;
- included price logic;
- additional price logic;
- kitchen preparation behavior;
- receipt display behavior;
- inventory implication where applicable;
- cancellation/refund behavior.

A combo must not be flattened into a single item if POS/KDS requires component-level representation.

A combo must not be exploded into components if receipt/settlement requires single item representation unless approved.

---

## 16. Substitution and Removal Mapping

Substitutions and removals must be controlled.

Examples:

- no onion;
- sauce on side;
- extra rice;
- less spicy;
- replace protein;
- remove ingredient;
- add topping;
- gluten-free request;
- allergy-related request.

The gateway must distinguish:

```text
structured_modifier
free_text_kitchen_note
allergy_or_safety_note
unsupported_request
manual_review_required
```

Unsupported substitutions must not be silently dropped.

Allergy or safety-related notes must follow separate food safety and customer communication policy where applicable.

---

## 17. KDS Display Mapping

KDS display may differ from receipt display.

KDS mapping must define:

- kitchen item name;
- station/lane;
- prep grouping;
- option display order;
- modifier emphasis;
- cancellation/void behavior;
- remake indicator;
- delay/hold instruction;
- language display where applicable.

KDS mapping must not omit modifiers required for preparation.

---

## 18. Receipt Display Mapping

Receipt mapping must define:

- receipt item name;
- option/modifier display;
- price breakdown;
- discount display;
- tax display;
- cancellation/refund display;
- customer proof wording;
- provider receipt identity.

Receipt display must preserve enough detail to support customer dispute and accounting review.

---

## 19. Mapping Import Policy

Menu mappings may be imported from:

- POS export;
- provider API;
- spreadsheet;
- tenant master menu;
- store-specific menu file;
- prior verified template;
- migration batch.

Imported mappings must be marked `imported_unverified` until validation passes.

Import must record:

```text
import_batch_id
source_type
source_reference
source_checksum
imported_by
imported_at
record_count
accepted_count
rejected_count
duplicate_count
status
```

---

## 20. Mapping Validation

Mapping validation must check:

- duplicate POS item codes;
- duplicate gateway item references;
- missing provider item codes;
- inactive POS items;
- price mismatch;
- modifier mismatch;
- unsupported required options;
- missing tax category;
- missing KDS routing;
- unavailable receipt display;
- invalid effective dates;
- stale template version;
- provider capability mismatch.

Validation failure must block production activation for affected item or scope.

---

## 21. Unmapped Item Policy

Unmapped items must fail closed.

When an unmapped item is ordered:

- gateway must not write a guessed POS item;
- order must be blocked before payment where possible;
- if already paid, transaction must become staff/manual review;
- customer-facing status must avoid false completion;
- staff must see missing mapping reason;
- incident or configuration task must be created.

Unmapped item events must be tracked as readiness and rollout quality signals.

---

## 22. Mapping Change Control

Production mapping changes require control.

Changes requiring approval:

- item-to-POS code change;
- option/modifier code change;
- price rule change;
- tax rule change;
- discount rule change;
- KDS routing change;
- receipt display change;
- combo component change;
- effective date change;
- template version promotion.

Mapping changes must create:

- change request;
- diff summary;
- validation result;
- approval record;
- effective time;
- rollback plan;
- affected active order assessment.

---

## 23. Active Order Protection

Mapping changes must not corrupt active orders.

When mapping changes:

- new orders may use new mapping version after effective time;
- existing carts may require reprice or refresh;
- paid orders must retain original mapping;
- POS write retries must use original mapping version unless manual correction is approved;
- cancellation/refund must reference original transaction mapping where required.

Active order protection must be considered before activation.

---

## 24. Price Change Policy

Price changes must be versioned and controlled.

Price change must record:

```text
price_version_id
item_id
old_price
new_price
change_reason
effective_from
approved_by
source_system
sync_status
```

Customer-visible price and POS price must be consistent before payment.

If customer-visible price differs from POS chargeable price, production order flow must be blocked or corrected before payment.

---

## 25. Menu Availability Policy

Menu availability must be mapped separately from menu identity.

Availability dimensions:

- date;
- time;
- weekday;
- store;
- stock status;
- seasonal status;
- channel availability;
- dine-in/takeout availability;
- delivery availability;
- kiosk/table ordering availability;
- staff-only status.

Unavailable items must not be sent to POS through automated order write.

---

## 26. Provider-Specific Menu Behavior

Provider-specific behavior must be documented.

Provider differences may include:

- POS uses numeric item code;
- POS uses name matching;
- POS does not expose modifiers;
- POS requires terminal-specific menu;
- POS uses different price for channel;
- POS cannot accept free-text note;
- POS does not support combo decomposition;
- POS rounds tax differently;
- POS updates menu asynchronously.

Provider-specific behavior must be reflected in the mapping validation rules.

---

## 27. Store-Specific Override Policy

Store-specific menu overrides must be controlled.

Allowed override examples:

- store-specific price;
- store-specific item availability;
- store-specific terminal menu;
- store-specific KDS lane;
- store-specific receipt name;
- temporary sold-out status.

Overrides must include:

```text
override_id
tenant_id
store_id
item_id
override_type
old_value
new_value
reason
effective_from
effective_until
approved_by
status
```

Overrides must not break tenant-level menu integrity without visibility.

---

## 28. Kiosk and Table Ordering Reuse

Kiosk and table ordering flows must use verified POS Gateway mapping.

They must not maintain an independent menu mapping that can diverge from POS Gateway mapping unless a formal synchronization and reconciliation boundary exists.

Kiosk/table ordering must inherit:

- active menu version;
- active mapping version;
- price version;
- option/modifier mapping;
- tax/discount rules;
- availability rules;
- restrictions;
- unsupported item behavior.

---

## 29. Smoke Test Requirements

Menu mapping smoke tests must include:

- representative item order;
- option/modifier item order;
- combo/set order;
- discount item order where applicable;
- tax category variation where applicable;
- sold-out/unavailable item;
- unmapped item failure;
- price mismatch failure;
- KDS display verification;
- receipt display verification;
- cancellation/refund linkage for mapped item.

Smoke test results must link to readiness and rollout evidence.

---

## 30. Monitoring Requirements

Menu mapping health must be monitored.

Required metrics:

- unmapped item count;
- price mismatch count;
- modifier mismatch count;
- KDS mapping failure count;
- receipt mapping failure count;
- template stale count;
- mapping validation failure count;
- override count;
- active mapping version count;
- failed order due to mapping;
- manual review due to menu mapping.

Mapping failures that affect customer payment or kitchen preparation must alert operations.

---

## 31. Incident Requirements

Menu mapping incidents may include:

- wrong item sent to POS;
- wrong option sent to kitchen;
- price mismatch charged;
- discount missing;
- tax mismatch;
- receipt mismatch;
- unavailable item accepted;
- combo represented incorrectly;
- customer allergen/safety note dropped;
- cancellation/refund failed due to item reference mismatch.

Menu mapping incidents must classify customer, kitchen, payment, and settlement impact.

---

## 32. Dashboard Requirements

Operations dashboard must show:

- active menu version;
- active mapping version;
- template version;
- mapping validation status;
- price integrity status;
- unmapped item count;
- price mismatch count;
- active overrides;
- pending mapping changes;
- blocked items;
- restricted items;
- last successful validation;
- next required review.

Dashboard must not show menu mapping as ready when price or required modifier validation is failing.

---

## 33. Prohibited Practices

The following practices are prohibited:

- guessing POS item code by item name similarity;
- sending free-text substitute when structured modifier is required;
- silently dropping modifiers;
- silently accepting price mismatch;
- treating template mapping as verified mapping;
- changing active mapping without versioning;
- applying new mapping to old paid orders;
- using kiosk menu mapping that bypasses POS Gateway mapping;
- using default tax rule when tax category is unknown;
- hiding unmapped item failures from operations;
- marking order complete when required menu mapping failed.

---

## 34. Minimum Acceptance Criteria

Menu mapping is acceptable only when:

- menu identity model exists;
- option/modifier identity model exists;
- mapping scope is explicit;
- templates are versioned;
- mapping versions are immutable after activation;
- menu version is recorded per order;
- price integrity checks exist;
- tax and discount mapping exist where applicable;
- combo/set mapping is controlled;
- substitutions and removals are classified;
- KDS and receipt display mapping exist;
- import and validation process exists;
- unmapped items fail closed;
- production mapping changes require approval;
- active orders are protected;
- kiosk/table ordering inherits verified mapping;
- monitoring and incident handling exist.

---

## 35. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_menu_items
pos_gateway_menu_versions
pos_gateway_mapping_versions
pos_gateway_item_mappings
pos_gateway_option_mappings
pos_gateway_modifier_mappings
pos_gateway_combo_mappings
pos_gateway_price_versions
pos_gateway_tax_mappings
pos_gateway_discount_mappings
pos_gateway_menu_templates
pos_gateway_mapping_import_batches
pos_gateway_mapping_validation_results
pos_gateway_store_menu_overrides
pos_gateway_mapping_change_requests
pos_gateway_menu_mapping_incidents
```

Recommended services:

```text
MenuMappingService
MenuTemplateService
MappingVersionService
PriceIntegrityService
TaxDiscountMappingService
ComboMappingService
ModifierMappingService
MappingImportService
MappingValidationService
UnmappedItemGuard
MappingChangeControlService
ActiveOrderMappingProtectionService
StoreMenuOverrideService
KdsDisplayMappingService
ReceiptDisplayMappingService
MenuMappingMonitoringService
```

Recommended event types:

```text
pos_gateway.menu.template_created
pos_gateway.menu.mapping_imported
pos_gateway.menu.mapping_validated
pos_gateway.menu.mapping_validation_failed
pos_gateway.menu.mapping_activated
pos_gateway.menu.mapping_deprecated
pos_gateway.menu.price_mismatch_detected
pos_gateway.menu.unmapped_item_detected
pos_gateway.menu.override_created
pos_gateway.menu.change_requested
pos_gateway.menu.change_approved
pos_gateway.menu.mapping_incident_detected
```

---

## 36. Relationship To Adjacent Documents

This document is related to:

- 06040 POS Gateway tenant, store, SaaS onboarding package, template provisioning, and operational enablement policy;
- 06030 POS Gateway store rollout, wave control, pilot expansion, field feedback, and stabilization policy;
- 06020 POS Gateway multi-provider routing, fallback, provider priority, and store-specific adapter selection policy;
- POS Gateway production readiness checklist, smoke test, and operational acceptance policy;
- POS Gateway KDS kitchen ticket routing policy;
- POS Gateway reconciliation and settlement linkage policy;
- POS Gateway cancellation and refund exception policy;
- kiosk and table ordering menu reuse policies.

Where conflict exists, this document governs menu item, option, modifier, mapping template, versioning, and price integrity behavior for POS Gateway order routing.

---

## 37. Summary

Menu mapping is transaction infrastructure.

If menu identity is wrong, the order is wrong.  
If option mapping is wrong, the kitchen output is wrong.  
If price mapping is wrong, the customer, receipt, settlement, and accounting evidence are wrong.

Therefore, the POS Gateway must treat menu mapping as a controlled, versioned, verified, evidence-producing boundary.

The correct standard is:

- no guessing;
- no silent defaults;
- no unverified template activation;
- no price mismatch tolerance without policy;
- no mapping change without versioning;
- no kiosk/table ordering bypass.

A safely mapped menu is the foundation for safe POS integration.