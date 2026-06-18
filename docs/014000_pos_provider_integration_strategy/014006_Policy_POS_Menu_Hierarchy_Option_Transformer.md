# 014006_Policy_POS_Menu_Hierarchy_Option_Transformer

## 1. Purpose

This policy defines how the POS Gateway must transform menu, option, modifier, and product hierarchy data between the core menu model and provider-specific POS menu structures.

The purpose is to ensure that the platform can maintain a rich, flexible, and provider-neutral menu model while still submitting orders to legacy, modern, and future POS providers in a format each provider can understand.

The core menu model must not be weakened to match the limitations of any single POS provider.

Provider-specific menu limitations must be absorbed by the POS Gateway transformer layer.

## 2. Scope

This policy applies to:

* Core menu model to POS menu mapping
* POS menu code registry
* Legacy POS flattened product structures
* Modern POS option group and option item structures
* Option combination mapping
* Menu alias mapping
* Required and optional option handling
* Menu price and option price transformation
* POS-specific order line generation
* Unsupported option behavior
* Menu synchronization evidence
* Menu mapping test fixtures

This policy applies to all order channels that submit structured menu data through the POS Gateway.

## 3. Core Principle

The core menu model must remain richer than the most limited POS provider model.

The POS Gateway must transform the core menu structure into a provider-compatible representation at the edge.

The core must not store provider-specific menu assumptions as its primary truth.

Provider-specific menu structures must be treated as external projection formats, not as the core menu design.

## 4. Menu Model Boundary

The core menu model should represent menu intent.

The POS provider menu model represents provider execution format.

The Gateway transformer sits between them.

```
[Core Menu Model]
      |
      v
[Menu Mapping Registry]
      |
      v
[Provider Menu Transformer]
      |
  ------------------------
  |                      |
  v                      v
[Modern POS Tree]     [Legacy POS Flat Codes]
```

The transformation direction must be explicit, testable, and auditable.

## 5. Non-Negotiable Rules

### 5.1 Core Menu Richness Rule

The core menu model must support:

* Product
* Variant
* Option group
* Option item
* Required option
* Optional option
* Multi-select option
* Quantity-based option
* Price-adjusting option
* Kitchen instruction
* Channel-specific availability
* Store-specific availability
* Promotion context
* Tax context
* Display metadata

The core model must not be reduced to a flat POS product code list.

### 5.2 Provider Projection Rule

Each POS provider must receive only the structure it can understand.

The transformer may:

* Flatten a menu tree
* Expand options into sub-product lines
* Convert option combinations into provider product codes
* Remove unsupported metadata
* Convert option prices into line adjustments
* Map display names to provider names
* Map kitchen names to provider kitchen labels

The transformer must not silently change the customer-facing order intent.

### 5.3 Mapping Registry Required Rule

Every POS-facing menu item must be mapped through a controlled registry.

The Gateway must not rely on free-text matching between core menu names and POS menu names.

### 5.4 No Assumed Option Compatibility Rule

The Gateway must not assume that a POS provider supports option groups, nested options, multi-select options, or dynamic modifiers.

Support must be declared in the provider capability profile.

### 5.5 Transformation Evidence Rule

Every transformed order must preserve evidence of:

* Original core menu line
* Original core option line
* Provider target menu code
* Provider target option code
* Transformation rule version
* Price before transformation
* Price after transformation
* Unsupported feature handling decision

## 6. Core Menu Structure

The core menu structure may contain:

```
menu_item_id
menu_item_name
menu_category_id
variant_id
variant_name
option_group_id
option_group_name
option_item_id
option_item_name
option_quantity
option_price_delta
required_option_flag
multi_select_flag
kitchen_label
customer_display_label
channel_availability
store_availability
tax_category
promotion_context
sales_price
base_price
effective_price
menu_version
```

This structure is platform-owned and provider-neutral.

## 7. POS Mapping Registry

The POS mapping registry must connect core menu concepts to provider-specific codes.

The registry should include:

```
mapping_id
provider_id
store_id
core_menu_item_id
core_variant_id
core_option_group_id
core_option_item_id
provider_menu_code
provider_sub_menu_code
provider_option_code
provider_modifier_code
provider_combo_code
provider_display_name
provider_kitchen_name
mapping_mode
effective_from
effective_until
active_flag
mapping_version
created_by
approved_by
approved_at
```

The mapping registry must be versioned.

Historical order reconstruction must use the mapping version active at the time of order submission.

## 8. Mapping Modes

Each mapped item must have a mapping mode.

### 8.1 Direct Item Mapping

A core menu item maps directly to one provider menu code.

Example:

```
Core: Americano
Provider: MENU-1001
```

This is the simplest mapping mode.

### 8.2 Variant Mapping

A core menu item variant maps to different provider menu codes.

Example:

```
Core: Americano / Hot
Provider: MENU-1001

Core: Americano / Ice
Provider: MENU-1002
```

This is common in legacy POS environments.

### 8.3 Option Group Mapping

A provider supports option groups or modifiers.

Example:

```
Core: Americano
Option Group: Temperature
Option Item: Ice

Provider:
Product ID: MENU-1001
Option Group ID: TEMP
Option Item ID: ICE
```

This is common in modern POS environments.

### 8.4 Flattened Option Mapping

A provider does not support option trees.

The transformer must flatten options into additional product or sub-product codes.

Example:

```
Core: Americano + Extra Shot
Provider:
MENU-1001 Americano
SUB-2001 Extra Shot
```

### 8.5 Combination Code Mapping

A provider requires one product code for a specific option combination.

Example:

```
Core: Americano / Ice / Extra Shot
Provider: MENU-3007 Ice Americano Extra Shot
```

This mode is brittle and must be explicitly marked.

### 8.6 Manual-Assisted Mapping

A provider cannot represent the option correctly.

The Gateway may send a simplified provider order plus kitchen note or manual operator instruction.

This mode is degraded and must be visible in audit and readiness evidence.

## 9. Legacy POS Transformation

Legacy POS providers may require:

* Flat product codes
* Separate hot and ice products
* Option items as sub-products
* Option combinations as separate products
* Discount lines as negative products
* Kitchen notes as text-only remarks
* No dynamic option group structure
* Limited text length
* Limited Unicode support
* Store-specific menu code variation

For legacy POS providers, the transformer must generate the exact POS-compatible line structure while preserving the original core order intent in audit.

## 10. Modern POS Transformation

Modern POS providers may support:

* Product ID
* Variant ID
* Option group ID
* Option item ID
* Modifier ID
* Quantity per option
* Nested modifier groups
* JSON payload order lines
* Channel-specific menu visibility
* Webhook-based menu sync
* Real-time sold-out updates

For modern POS providers, the transformer should preserve hierarchy when supported.

However, the Gateway must still validate the provider contract and must not assume future compatibility without schema evidence.

## 11. Unsupported Option Handling

If a provider does not support a requested option structure, the Gateway must choose one of the following outcomes:

```
BLOCK_ORDER
REMOVE_UNSUPPORTED_OPTION_WITH_CUSTOMER_CONFIRMATION
CONVERT_TO_KITCHEN_NOTE
CONVERT_TO_MANUAL_OPERATOR_NOTE
MAP_TO_NEAREST_PROVIDER_CODE
REQUIRE_STORE_MAPPING_UPDATE
MARK_PROVIDER_UNSUPPORTED
```

The chosen outcome must be recorded in audit.

Silent removal of an option is prohibited.

## 12. Price Transformation Rules

The transformer must preserve price integrity.

For every order line, the Gateway must compare:

* Core base price
* Core option price delta
* Core calculated line total
* Provider mapped item price
* Provider option price
* Provider calculated line total

If the provider calculated amount differs from the core calculated amount beyond the permitted tolerance, the order must be blocked, queued for manual review, or redirected to a payment mismatch flow according to the payment reconciliation policy.

The transformer must not hide price mismatch by modifying core order values without evidence.

## 13. Kitchen Name And Print Name Mapping

Customer-facing menu names and kitchen-facing names may differ.

The mapping registry may store:

```
customer_display_name
kitchen_display_name
provider_display_name
provider_kitchen_name
printer_name_override
short_name
language_code
```

The transformer must respect provider text length, printer encoding, and kitchen readability constraints.

If truncation is required, the truncation rule must be documented and tested.

## 14. Multilingual Menu Mapping

When multilingual customer menus are supported, the provider mapping must still resolve to a stable provider menu code.

The Gateway must not map provider menu codes by localized display name.

Allowed structure:

```
customer_language_name -> core_menu_item_id -> provider_menu_code
```

Prohibited structure:

```
customer_language_name -> provider_menu_name_text_match
```

Text matching is not a safe integration strategy.

## 15. Store-Specific Menu Variation

A provider menu code may vary by store even when the core menu item is the same.

The mapping registry must support store-specific mapping.

Examples:

```
Store A:
Core menu: Americano
Provider code: A-1001

Store B:
Core menu: Americano
Provider code: B-9012
```

The Gateway must not assume provider menu codes are globally stable.

## 16. Menu Versioning

Every order must reference a menu version and mapping version.

Required evidence includes:

```
core_menu_version
provider_mapping_version
provider_menu_snapshot_version
transformation_rule_version
submitted_at
store_id
provider_id
```

This allows historical reconstruction when prices, names, options, or mappings change later.

## 17. Menu Sync Relationship

The transformer depends on master data synchronization but must not be confused with it.

Master data sync answers:

```
What menu data does the POS currently have?
```

Menu transformation answers:

```
How do we convert a core order into the POS format?
```

Both are required.

A synced menu without transformation rules is not enough.

A transformation rule without current POS validation may be unsafe.

## 18. Validation Before Transformation

Before transforming an order, the Gateway should validate:

* Core menu item is active
* Core option is active
* Store availability is valid
* Channel availability is valid
* Provider mapping exists
* Provider mapping is active
* Provider supports required option mode
* Provider price validation passes, when available
* Sold-out validation passes, when available

Failure must result in controlled rejection or exception handling.

## 19. Transformation Output Contract

The transformer must produce a provider-neutral transformation result before provider submission.

The result should include:

```
transformation_status
transformed_order_lines
transformed_option_lines
provider_payload_candidate
unsupported_features
warnings
price_check_result
mapping_version
transformer_version
audit_reference_id
```

The adapter may then convert this into the final provider request format.

## 20. Audit Requirements

For every transformed order, the audit log must preserve:

* Platform order ID
* Store ID
* Provider ID
* Core menu item IDs
* Core option IDs
* Provider menu codes
* Provider option codes
* Mapping version
* Transformer version
* Transformation result
* Unsupported feature decision
* Price comparison result
* Validation result
* Raw provider payload candidate
* Final provider outbound payload reference
* Trace ID
* Idempotency key

Sensitive or unnecessary customer data must be excluded, redacted, tokenized, or encrypted according to the security runtime policy.

## 21. Test Requirements

Each provider menu transformer must have tests for:

* Direct item mapping
* Variant mapping
* Option group mapping
* Flattened option mapping
* Combination code mapping
* Missing mapping
* Inactive mapping
* Unsupported required option
* Unsupported optional option
* Price mismatch
* Store-specific menu code
* Menu version change
* Text truncation
* Multilingual display name
* Legacy flat payload generation
* Modern JSON tree payload generation

A transformer without test fixtures must not be treated as production-ready.

## 22. Operator Recovery Requirements

When menu transformation fails, the operator console must show:

* Which order failed
* Which menu line failed
* Which option failed
* Which provider mapping is missing or invalid
* Whether the issue is customer-facing, store-facing, or provider-facing
* Whether the order can be retried
* Whether manual input is allowed
* Whether customer refund or order cancellation is required

The system must avoid vague errors such as “POS error” when a mapping-specific diagnosis is available.

## 23. Anti-Patterns

The following are prohibited:

* Using menu name text matching as the primary mapping method
* Embedding provider menu codes directly into the core menu model as primary identity
* Assuming all providers support option groups
* Silently dropping unsupported options
* Silently changing menu prices during transformation
* Treating store-specific POS codes as global codes
* Reusing stale mappings without version evidence
* Allowing unmapped options to pass into payment approval
* Letting provider menu limitations reshape the core menu model
* Mixing menu synchronization logic and transformation logic without boundary

## 24. Relationship With Other Documents

This policy supports and depends on:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

The menu transformer is one of the most important adapter-side defenses against provider-specific POS disorder.

## 25. Final Rule

The core menu model must remain platform-owned, expressive, and provider-neutral.

The POS Gateway transformer must absorb provider-specific menu limitations at the edge.

If adding a POS provider forces the core menu model to become flatter, weaker, or provider-specific, the menu abstraction boundary has failed.
