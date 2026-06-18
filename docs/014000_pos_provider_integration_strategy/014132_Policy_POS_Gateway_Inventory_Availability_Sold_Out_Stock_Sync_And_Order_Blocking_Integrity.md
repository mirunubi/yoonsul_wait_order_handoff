# 014132_Policy_POS_Gateway_Inventory_Availability_Sold_Out_Stock_Sync_And_Order_Blocking_Integrity

## 1. Purpose

This document defines the inventory, availability, sold-out, stock synchronization, and order blocking integrity policy for the POS Gateway.

The POS Gateway must not accept or route orders for items that cannot be prepared, cannot be sold, or cannot be represented correctly in POS/KDS.

In food store operations, item availability may change due to:

- ingredient depletion;
- sold-out menu item;
- time-limited menu;
- seasonal menu;
- store-specific preparation capacity;
- KDS station overload;
- POS-side item disablement;
- staff manual stop-sale action;
- delivery/channel restriction;
- safety or quality issue;
- provider synchronization delay.

If the gateway accepts an unavailable item, the result may be customer dissatisfaction, refund friction, kitchen confusion, staff intervention, settlement mismatch, and loss of trust.

This policy exists to ensure that:

- item availability is represented explicitly;
- sold-out state is synchronized safely;
- POS, KDS, kiosk, table ordering, and gateway availability do not diverge silently;
- unavailable items fail closed before payment whenever possible;
- staff can quickly stop selling items;
- stale availability data is detected;
- orders are blocked, refreshed, or routed to manual review when availability becomes uncertain;
- inventory and availability state is preserved as evidence for disputes and incidents.

---

## 2. Scope

This policy applies to all POS Gateway availability and stock-related behavior, including:

- menu item availability;
- option and modifier availability;
- set/combo component availability;
- ingredient-driven sold-out state;
- store-specific stock state;
- time-based menu availability;
- channel-specific availability;
- dine-in/takeout availability;
- kiosk/table ordering availability;
- KDS capacity-based availability;
- POS-side item disabled state;
- manual staff sold-out action;
- inventory synchronization;
- availability cache;
- cart validation;
- pre-payment order validation;
- post-payment availability conflict handling;
- cancellation/refund due to sold-out;
- customer-facing sold-out messaging.

This document governs availability integrity before order acceptance, POS write, KDS routing, payment execution, cancellation, refund, and customer communication.

---

## 3. Core Principle

The POS Gateway must not sell what the store cannot fulfill.

For every orderable item, the gateway must know:

```text
whether the item is active
whether the store can sell it
whether required modifiers are available
whether set/combo components are available
whether the selected channel is allowed
whether the selected time is allowed
whether the item is blocked by POS, KDS, or staff
whether the availability state is fresh enough
whether the customer cart must be refreshed
```

If availability cannot be proven, the gateway must block automated order acceptance or require staff confirmation.

---

## 4. Availability Authority Model

The system must define the authority source for availability.

Possible authority models:

| Model | Description |
|---|---|
| `pos_authoritative` | POS item status determines availability |
| `gateway_authoritative` | Gateway availability state controls orderability |
| `inventory_authoritative` | Inventory/stock system controls availability |
| `kds_capacity_authoritative` | Kitchen capacity or station state controls availability |
| `staff_authoritative` | Staff manual stop-sale action controls availability |
| `hybrid_authoritative` | Multiple authorities combine through deterministic precedence |
| `unknown_authority` | No reliable authority exists |

`unknown_authority` must not allow production automation.

Availability authority must be scoped by store, provider, channel, and item type.

---

## 5. Availability Scope

Availability rules must be scoped.

Required scope dimensions:

```text
tenant_id
store_id
provider_code
adapter_version
menu_item_id
option_id
modifier_id
combo_component_id
order_channel
terminal_id
table_zone_id
business_day
effective_from
effective_until
availability_source
availability_version_id
status
```

Availability for one store must not automatically apply to another store unless explicitly inherited and verified.

---

## 6. Availability Status Model

Each item, option, modifier, or component must have an explicit availability status.

Recommended statuses:

| Status | Meaning |
|---|---|
| `available` | Can be sold normally |
| `limited` | Can be sold under quantity or channel restriction |
| `sold_out` | Cannot be sold due to stock depletion |
| `temporarily_unavailable` | Temporarily blocked by staff or operation |
| `time_restricted` | Available only during configured time window |
| `channel_restricted` | Not available for selected order channel |
| `kds_restricted` | Kitchen capacity or station state blocks item |
| `provider_disabled` | POS/provider marks item unavailable |
| `mapping_blocked` | Item cannot be sold due to mapping issue |
| `price_blocked` | Item cannot be sold due to price mismatch |
| `safety_blocked` | Item blocked due to food safety or quality issue |
| `unknown` | Availability cannot be determined |

`unknown` must not be treated as available for automated ordering.

---

## 7. Sold-Out Policy

Sold-out state must be controlled and visible.

Sold-out may be triggered by:

- staff manual action;
- inventory threshold;
- POS item disablement;
- KDS capacity decision;
- provider event;
- quality/safety issue;
- repeated preparation failure;
- supplier shortage;
- business rule.

Sold-out record must include:

```text
sold_out_id
tenant_id
store_id
menu_item_id
option_id
modifier_id
reason
source
set_by
approved_by
effective_from
effective_until
customer_visible_flag
order_blocking_flag
created_at
status
```

Sold-out state must propagate to all order channels within the approved scope.

---

## 8. Manual Sold-Out Action

Staff must be able to mark items sold out quickly.

Manual sold-out action must support:

- item-level stop sale;
- option/modifier-level stop sale;
- combo component stop sale;
- channel-specific stop sale;
- time-bounded stop sale;
- immediate customer-facing update;
- reason capture;
- manager approval where required;
- audit logging.

Manual sold-out must not require developer intervention.

Sensitive or high-impact sold-out actions may require manager approval depending on store policy.

---

## 9. Sold-Out Propagation

Sold-out state must propagate to:

- gateway menu;
- customer ordering screen;
- kiosk/table ordering;
- staff tablet;
- POS write validation;
- KDS routing validation;
- cart validation;
- payment validation;
- customer support view;
- operations dashboard.

Propagation must be monitored.

If propagation fails, affected channels must fail closed or display restricted status.

---

## 10. Availability Synchronization

Availability synchronization may use:

- POS API;
- inventory system;
- staff device;
- KDS station state;
- provider webhook;
- scheduled polling;
- manual admin update;
- migration/import batch;
- store operation dashboard.

Synchronization must record:

```text
sync_id
tenant_id
store_id
source_system
sync_type
started_at
completed_at
record_count
changed_count
failed_count
stale_count
status
```

Availability sync failure must be visible in monitoring.

---

## 11. Availability Freshness Policy

Availability data must have freshness rules.

Required freshness fields:

```text
availability_record_id
last_confirmed_at
source_system
freshness_ttl_seconds
stale_after
stale_behavior
```

Possible stale behaviors:

| Behavior | Meaning |
|---|---|
| `allow_with_warning` | Allow order but mark risk |
| `require_refresh` | Refresh before order acceptance |
| `block_order` | Block automated order |
| `staff_confirmation_required` | Route to staff review |
| `channel_disable` | Disable affected channel temporarily |

For transaction-critical ordering, stale availability should fail closed unless the store explicitly accepts the risk.

---

## 12. Cart Availability Validation

Customer carts must be validated against current availability.

Validation must occur:

- when item is added to cart;
- when option/modifier is selected;
- when cart is opened after delay;
- before payment;
- before POS write;
- before KDS routing;
- after availability sync event affects cart items.

If an item becomes unavailable while in cart, the system must:

- notify customer;
- remove or disable affected item;
- recalculate total;
- require confirmation before payment;
- preserve evidence of availability change.

The system must not silently charge for an unavailable item.

---

## 13. Pre-Payment Blocking

Unavailable items should be blocked before payment whenever possible.

Pre-payment blocking must occur when:

- item is sold out;
- required modifier is unavailable;
- combo component unavailable;
- price/mapping blocked;
- channel restriction applies;
- time window closed;
- POS provider disabled item;
- safety block exists;
- availability state is unknown and policy requires block.

Blocking must show a clear customer-facing reason without exposing internal provider details.

---

## 14. Post-Payment Availability Conflict

If availability conflict is detected after payment, the transaction becomes customer-impacting.

Required handling:

- prevent false order completion;
- notify staff immediately;
- classify affected item;
- offer replacement, cancellation, refund, or manual handling according to store policy;
- preserve payment evidence;
- preserve availability conflict evidence;
- avoid duplicate refund;
- create incident or customer-impact case where required.

Post-payment availability conflicts must be measured as rollout and operations quality issues.

---

## 15. POS Write Availability Validation

Before writing to POS, the gateway must validate availability.

Required checks:

- item active in gateway;
- item active in POS if POS availability is authoritative;
- provider item code valid;
- modifiers available;
- selected channel allowed;
- price and mapping active;
- sold-out state not active;
- availability data fresh enough.

If POS rejects order due to unavailable item, the gateway must classify the failure and avoid retrying blindly.

---

## 16. KDS Availability and Capacity

KDS or kitchen state may affect availability.

KDS-driven restrictions may include:

- station closed;
- prep capacity exceeded;
- ingredient station unavailable;
- item temporarily stopped;
- delayed preparation window;
- equipment failure;
- staff shortage.

KDS capacity restriction must be visible to front staff and customer ordering channels where applicable.

KDS restriction must not silently drop tickets.

---

## 17. Inventory Quantity Policy

If quantity tracking is available, the gateway must handle limited stock.

Required quantity fields:

```text
stock_record_id
tenant_id
store_id
item_id
available_quantity
reserved_quantity
sold_quantity
unit
source_system
last_updated_at
status
```

Quantity-based ordering must support reservation or final check before payment.

If quantity cannot be reserved, the system must account for race conditions.

Limited quantity items must not oversell without store-approved policy.

---

## 18. Stock Reservation Policy

Stock reservation may be required for scarce items.

Reservation must define:

- reservation point;
- reservation duration;
- release condition;
- payment failure release;
- order cancellation release;
- POS write failure release;
- manual override;
- customer timeout behavior.

Reservation record must include:

```text
reservation_id
order_id
item_id
quantity
reserved_at
expires_at
release_reason
status
```

Reservation must not permanently reduce stock if order fails.

---

## 19. Race Condition Handling

Availability race conditions occur when multiple customers attempt to buy limited stock simultaneously.

Required controls:

- atomic availability check where possible;
- reservation or lock where applicable;
- final validation before payment;
- final validation before POS write;
- clear customer message when item becomes unavailable;
- refund/cancel path if payment already occurred;
- incident threshold for repeated oversell.

Race condition handling must prioritize customer protection.

---

## 20. Channel-Specific Availability

Availability may differ by channel.

Channels may include:

- dine-in;
- takeout;
- kiosk;
- QR/table ordering;
- delivery;
- staff order;
- phone order;
- admin/manual order;
- promotion-only channel.

Channel-specific availability must define:

```text
channel_code
availability_scope
allowed_items
blocked_items
time_window
restriction_reason
status
```

An item available for staff order is not automatically available for customer self-ordering.

---

## 21. Time-Based Availability

Time-based availability must be explicit.

Examples:

- breakfast menu;
- lunch menu;
- dinner menu;
- late-night menu;
- seasonal menu;
- weekday-only menu;
- promotion window;
- prep cutoff time;
- last order time.

Time-based rules must use store timezone and business day boundary.

A customer cart crossing an availability boundary must be refreshed before payment.

---

## 22. Safety and Quality Blocking

Food safety or quality concerns must override sales availability.

Safety block may apply to:

- ingredient recall;
- allergen concern;
- spoiled ingredient;
- equipment failure;
- preparation quality issue;
- temperature control issue;
- contamination risk;
- internal quality hold.

Safety-blocked items must not be sold through any automated channel.

Safety block removal may require manager or authorized role approval.

---

## 23. Availability Change Audit

Every material availability change must be audited.

Required audit fields:

```text
availability_change_id
tenant_id
store_id
item_id
previous_status
new_status
reason
source
actor_id
approval_id
effective_from
effective_until
affected_channels
created_at
```

Audit records must support incident investigation and customer dispute review.

---

## 24. Customer-Facing Availability Messaging

Customer-facing messages must be clear and conservative.

Allowed messages:

```text
현재 선택하신 메뉴는 주문할 수 없습니다.
방금 품절되어 장바구니에서 제외되었습니다.
선택하신 옵션이 현재 제공되지 않습니다.
해당 메뉴는 지금 시간대에 주문할 수 없습니다.
직원이 확인 후 주문 가능 여부를 안내드리겠습니다.
```

Prohibited behavior:

- accepting unavailable item silently;
- showing item available when gateway knows it is blocked;
- charging first and explaining later when pre-payment block was possible;
- exposing internal provider errors directly to customer.

---

## 25. Staff-Facing Availability Messaging

Staff-facing messages must include operational cause.

Examples:

```text
POS에서 품절 처리된 메뉴입니다.
가격/매핑 오류로 자동 주문이 차단되었습니다.
KDS 스테이션 제한으로 주문이 보류되었습니다.
재고 수량 부족으로 직원 확인이 필요합니다.
고객 결제 후 품절 충돌이 발생했습니다.
```

Staff messages must indicate required action.

---

## 26. Reconciliation Impact

Availability issues may affect reconciliation.

Examples:

- paid order cancelled due to sold-out;
- item substituted manually;
- partial refund due to unavailable item;
- POS manual correction;
- KDS remake or omission;
- coupon restored due to cancellation;
- inventory quantity adjusted.

Availability-related adjustments must link to:

- original order;
- payment;
- POS record;
- refund/cancellation;
- manual correction;
- reconciliation case.

---

## 27. Incident Requirements

Availability incidents may include:

- sold-out item accepted;
- unavailable modifier accepted;
- stale availability caused payment conflict;
- POS rejected item after payment;
- KDS did not receive item due to availability mismatch;
- stock oversell;
- safety-blocked item sold;
- channel restriction ignored;
- time-based menu incorrectly accepted.

Incident classification must consider:

- customer impact;
- payment impact;
- kitchen impact;
- refund/cancellation impact;
- food safety impact;
- reconciliation impact.

---

## 28. Monitoring Requirements

Availability health must be monitored.

Required metrics:

- sold-out item order attempt count;
- unavailable modifier attempt count;
- stale availability count;
- availability sync failure count;
- POS availability mismatch count;
- KDS availability restriction count;
- post-payment availability conflict count;
- stock oversell count;
- manual sold-out action count;
- safety block count;
- channel restriction violation count;
- time-window violation count.

Critical availability failures must alert operations.

---

## 29. Dashboard Requirements

Operations dashboard must show:

- active sold-out items;
- temporarily unavailable items;
- safety-blocked items;
- stale availability records;
- availability sync status;
- active channel restrictions;
- active time-based restrictions;
- stock-limited items;
- post-payment availability conflicts;
- availability-related incidents;
- manual sold-out actions;
- pending availability approvals.

Dashboard must not show menu as orderable when availability state is unknown or stale beyond policy.

---

## 30. Kiosk and Table Ordering Reuse

Kiosk and table ordering must inherit POS Gateway availability rules.

They must use:

- active availability status;
- sold-out state;
- modifier availability;
- combo component availability;
- channel restrictions;
- time restrictions;
- stock reservation policy;
- stale data behavior;
- safety blocks;
- customer-facing availability messages.

Kiosk/table ordering must not maintain a separate availability truth that can diverge from POS Gateway rules unless formally synchronized and reconciled.

---

## 31. Prohibited Practices

The following practices are prohibited:

- treating unknown availability as available;
- accepting payment before availability validation when validation is possible;
- silently dropping unavailable modifiers;
- routing sold-out items to POS;
- ignoring POS item disabled state;
- ignoring staff manual sold-out action;
- using stale availability data without policy;
- overselling limited stock without approved handling;
- allowing kiosk/table ordering to bypass sold-out state;
- removing safety block without authorization;
- hiding post-payment sold-out conflicts from incident tracking.

---

## 32. Minimum Acceptance Criteria

Inventory and availability integrity is acceptable only when:

- availability authority model is defined;
- availability scope is explicit;
- availability status model exists;
- sold-out policy exists;
- manual sold-out action is auditable;
- sold-out propagation is defined;
- availability synchronization exists;
- freshness policy exists;
- cart validation exists;
- pre-payment blocking exists;
- post-payment conflict handling exists;
- POS write availability validation exists;
- KDS capacity restrictions are supported where applicable;
- stock reservation is defined where quantity tracking exists;
- channel and time-based availability rules exist;
- safety block overrides sales;
- monitoring and incident handling exist;
- kiosk/table ordering inherits the same availability boundary.

---

## 33. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_availability_records
pos_gateway_availability_versions
pos_gateway_sold_out_records
pos_gateway_availability_sync_runs
pos_gateway_availability_change_audits
pos_gateway_stock_records
pos_gateway_stock_reservations
pos_gateway_channel_availability_rules
pos_gateway_time_availability_rules
pos_gateway_safety_blocks
pos_gateway_availability_conflicts
pos_gateway_availability_incidents
```

Recommended services:

```text
AvailabilityAuthorityService
AvailabilityStatusService
SoldOutService
ManualSoldOutService
AvailabilityPropagationService
AvailabilitySyncService
AvailabilityFreshnessService
CartAvailabilityValidationService
PrePaymentOrderBlockService
PostPaymentAvailabilityConflictService
PosWriteAvailabilityGuard
KdsAvailabilityService
StockReservationService
ChannelAvailabilityService
TimeAvailabilityService
SafetyBlockService
AvailabilityMonitoringService
```

Recommended event types:

```text
pos_gateway.availability.status_changed
pos_gateway.availability.sold_out_set
pos_gateway.availability.sold_out_removed
pos_gateway.availability.sync_started
pos_gateway.availability.sync_failed
pos_gateway.availability.stale_detected
pos_gateway.availability.cart_blocked
pos_gateway.availability.pre_payment_blocked
pos_gateway.availability.post_payment_conflict_detected
pos_gateway.availability.stock_reserved
pos_gateway.availability.stock_released
pos_gateway.availability.safety_block_set
pos_gateway.availability.incident_detected
```

---

## 34. Relationship To Adjacent Documents

This document is related to:

- 06050 POS Gateway menu item, option, modifier, mapping template, versioning, and price integrity policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy;
- 06040 POS Gateway tenant, store, SaaS onboarding package, template provisioning, and operational enablement policy;
- POS Gateway KDS kitchen ticket routing policy;
- POS Gateway cancellation, refund, exception, manual override, and customer protection policy;
- POS Gateway production readiness checklist and smoke test policy;
- POS Gateway incident response and dispute investigation policy;
- inventory, procurement, kitchen prep, and store operation policies;
- kiosk and table ordering availability policies.

Where conflict exists, this document governs inventory, availability, sold-out, stock synchronization, and order blocking integrity for POS Gateway order acceptance and routing.

---

## 35. Summary

Availability is a customer trust boundary.

The POS Gateway must not sell unavailable food, unavailable options, blocked menu items, or stale inventory assumptions.

The correct standard is:

- know the authority source;
- synchronize availability;
- fail closed on unknown state;
- block before payment when possible;
- preserve evidence when conflict occurs;
- allow staff to stop sales quickly;
- propagate restrictions to every ordering channel;
- protect customers when availability changes mid-flow.

A store can recover from a blocked order.  
It may not recover customer trust from repeated paid-but-unavailable orders.