# 14133_Policy_POS_Gateway_Order_Channel_Separation_Dine_In_Takeout_Delivery_Kiosk_Table_QR_And_Staff_Order_Routing

## 1. Purpose

This document defines the order channel separation, dine-in, takeout, delivery, kiosk, table QR, and staff order routing policy for the POS Gateway.

The POS Gateway must not treat all orders as the same simply because they eventually reach POS.

In real store operation, order channel affects:

- customer identity;
- table/session identity;
- payment timing;
- receipt handling;
- KDS routing;
- packaging requirement;
- service charge;
- discount eligibility;
- menu availability;
- cancellation/refund authority;
- staff responsibility;
- settlement source;
- customer communication;
- dispute investigation.

This policy exists to ensure that:

- each order channel is explicitly classified;
- routing behavior differs safely by channel;
- dine-in, takeout, delivery, kiosk, QR/table, and staff orders do not corrupt each other’s state;
- table/session handoff is preserved;
- channel-specific pricing, availability, tax, fee, discount, KDS, and receipt behavior is controlled;
- channel migration or fallback does not create duplicate orders or payments;
- customer and staff responsibilities remain clear.

---

## 2. Scope

This policy applies to all POS Gateway order channels, including:

- dine-in staff order;
- dine-in table QR order;
- dine-in kiosk-assisted order;
- takeout order;
- pickup reservation order;
- kiosk order;
- QR order;
- table ordering;
- staff tablet order;
- phone/manual order;
- delivery platform order;
- delivery aggregator order;
- external ordering provider order;
- waiting/preorder handoff order;
- customer web/app order;
- admin/manual correction order.

This document governs how order channel affects POS write, payment, KDS routing, receipt, cancellation, refund, reconciliation, and incident investigation.

---

## 3. Core Principle

Order channel is transaction context.

The POS Gateway must preserve where an order came from, who initiated it, how it should be fulfilled, how it should be paid, where it should be prepared, and how it should be reconciled.

The gateway must not flatten all orders into a generic POS order without channel context.

Each order must preserve:

```text
order_channel
order_origin
fulfillment_type
customer_presence_type
table_context
payment_timing
staff_involvement
kds_route
receipt_behavior
settlement_source
support_boundary
```

If channel context is unknown, the order must be restricted or routed to manual review.

---

## 4. Order Channel Model

The gateway must define order channel explicitly.

Recommended order channels:

| Channel | Description |
|---|---|
| `staff_pos` | Staff enters order directly or through staff device |
| `staff_tablet` | Staff uses tablet or internal ordering interface |
| `customer_table_qr` | Customer orders from table QR/NFC context |
| `customer_kiosk` | Customer orders from kiosk or mini-order station |
| `customer_mobile_web` | Customer orders through mobile web/app |
| `waiting_preorder` | Customer orders before seat/table assignment |
| `takeout_pickup` | Customer orders for pickup/takeout |
| `scheduled_pickup` | Customer orders for future pickup time |
| `delivery_platform` | External delivery platform order |
| `delivery_aggregator` | Aggregated delivery order routed through provider |
| `phone_manual` | Staff enters phone order manually |
| `admin_adjustment` | Administrative correction or adjustment order |
| `test_probe` | Controlled probe or test transaction |

Order channel must be stored per order and included in audit evidence.

---

## 5. Fulfillment Type Model

Order channel must be separated from fulfillment type.

Recommended fulfillment types:

| Fulfillment Type | Meaning |
|---|---|
| `dine_in` | Customer consumes in store |
| `takeout` | Customer picks up packaged order |
| `delivery` | Order delivered through platform or store |
| `scheduled_pickup` | Pickup at future time |
| `preorder_hold` | Preorder awaiting fulfillment trigger |
| `staff_manual` | Staff-managed fulfillment |
| `test_or_probe` | Controlled test or probe flow |

Example:

- table QR normally maps to `dine_in`;
- mobile web may map to `takeout`, `scheduled_pickup`, or waiting preorder;
- staff tablet may map to `dine_in` or `takeout`.

The gateway must not infer fulfillment only from channel name without rule.

---

## 6. Channel Scope

Channel rules must be scoped.

Required scope dimensions:

```text
tenant_id
store_id
provider_code
adapter_version
order_channel
fulfillment_type
payment_method
table_zone_id
terminal_id
menu_version_id
price_version_id
availability_version_id
kds_scope
effective_from
effective_until
status
```

A channel enabled for one store must not automatically apply to another store.

---

## 7. Channel Enablement Policy

Each channel must be explicitly enabled.

Channel enablement requires:

- provider routing rule;
- menu mapping support;
- price calculation support;
- availability support;
- payment timing support;
- KDS routing support where applicable;
- receipt behavior support;
- cancellation/refund behavior support;
- reconciliation support;
- customer/staff messaging support;
- monitoring and incident handling support.

A channel must not be visible to customers until enablement scope passes readiness.

---

## 8. Dine-In Channel Policy

Dine-in orders require table or service context.

Dine-in context may include:

- table ID;
- table zone;
- seat/session ID;
- staff assignment;
- dining party size;
- order round;
- service charge rule;
- kitchen routing;
- bill split behavior;
- post-meal payment behavior;
- table close behavior.

Dine-in orders must preserve table/session context when written to POS.

If table identity is uncertain, order must be held or routed to staff confirmation.

---

## 9. Table QR / NFC Order Policy

Table QR or NFC orders require table object integrity.

Required checks:

- QR/NFC object maps to active store;
- object maps to table or zone;
- table is currently active or allowed for self-order;
- session is valid;
- customer is not attached to wrong store/table;
- table transfer rules are defined;
- payment timing is defined;
- staff can see customer-originated table order;
- KDS receives correct table context.

QR/NFC orders must not be accepted when table object identity is stale, duplicated, or ambiguous.

---

## 10. Kiosk Order Policy

Kiosk orders require device and channel identity.

Required kiosk context:

```text
kiosk_device_id
store_id
terminal_mapping
order_channel
fulfillment_type
payment_method
menu_scope
availability_scope
receipt_behavior
staff_assist_flag
```

Kiosk orders must inherit POS Gateway restrictions for:

- provider routing;
- menu mapping;
- price calculation;
- availability;
- payment;
- cancellation/refund;
- KDS routing;
- incident handling.

Kiosk must not maintain a separate transaction truth outside POS Gateway.

---

## 11. Takeout and Pickup Policy

Takeout orders require packaging and pickup context.

Required takeout fields:

```text
pickup_type
requested_pickup_time
packaging_required_flag
pickup_customer_reference
pickup_number_or_code
payment_timing
receipt_delivery_method
```

Takeout orders must consider:

- packaging fee;
- pickup time capacity;
- item availability for takeout;
- hot/cold holding rule;
- cancellation cutoff;
- refund rule;
- no-show handling;
- customer notification.

A dine-in-only menu item must not be sold as takeout unless explicitly allowed.

---

## 12. Scheduled Pickup Policy

Scheduled pickup orders require future-time validation.

Required checks:

- pickup time window available;
- menu available at pickup time;
- price/promotion rule valid at purchase or pickup time according to policy;
- inventory/reservation rule defined;
- cancellation cutoff defined;
- staff prep schedule visible;
- customer notification path exists.

The gateway must define whether calculation is locked at order time or recalculated at fulfillment time.  
If unclear, scheduled pickup must be restricted.

---

## 13. Delivery Platform Order Policy

Delivery platform orders require external provider boundary.

Required delivery context:

```text
delivery_provider_code
external_order_id
external_payment_status
delivery_fee_owner
platform_discount_owner
settlement_source
customer_support_boundary
cancellation_authority
refund_authority
```

Delivery platform orders must preserve external order identity.

The POS Gateway must not treat external delivery payment as internal payment unless payment ownership is verified.

Delivery orders must not be refunded through the wrong provider path.

---

## 14. Delivery Aggregator Policy

When delivery orders arrive through an aggregator, the gateway must preserve both aggregator and original platform identity where available.

Required fields:

```text
aggregator_provider_code
original_delivery_platform_code
aggregator_order_id
platform_order_id
settlement_owner
cancellation_owner
refund_owner
support_owner
```

If original platform identity is unavailable, refund, cancellation, and settlement automation must be restricted.

---

## 15. Staff Order Policy

Staff orders may bypass some customer self-order restrictions but must remain auditable.

Staff order context must include:

- staff actor;
- role;
- device;
- reason where manual override is used;
- customer/table context where applicable;
- payment handling;
- discount authority;
- cancellation/refund authority.

Staff orders must not be used to hide failed customer-channel orders without linked evidence.

---

## 16. Waiting / Preorder Handoff Policy

Waiting or preorder handoff orders require delayed table/session binding.

Required states:

```text
preorder_created
waiting_session_linked
customer_arrived
table_assigned
order_confirmed
pos_write_ready
pos_write_completed
handoff_failed
manual_review_required
```

The gateway must preserve:

- original customer intent;
- cart state;
- payment timing;
- table assignment timing;
- staff confirmation;
- POS write timing;
- cancellation/refund path.

A waiting preorder must not be written to POS as dine-in table order until table context is valid or policy permits preorder kitchen release.

---

## 17. Channel-Specific Payment Timing

Payment timing may differ by channel.

Recommended payment timing models:

| Model | Description |
|---|---|
| `pay_before_pos_write` | Customer pays before POS order is written |
| `pos_write_before_pay` | POS order is created before payment |
| `pay_at_counter` | Staff collects payment manually |
| `pay_after_meal` | Dine-in post-meal payment |
| `external_paid` | External provider owns payment |
| `mixed_or_split` | Multiple payment paths |
| `manual_confirmation_required` | Staff confirms payment path |

Payment timing must be explicit per channel.

Payment uncertainty must not be hidden by channel conversion.

---

## 18. Channel-Specific Receipt Behavior

Receipt behavior must be defined by channel.

Receipt delivery may include:

- POS printed receipt;
- customer mobile receipt;
- kiosk printed receipt;
- external platform receipt;
- staff-issued receipt;
- email/SMS receipt;
- no immediate receipt with later proof.

Receipt behavior must preserve:

- POS receipt number;
- payment approval number;
- external order ID;
- cancellation/refund receipt;
- customer proof of transaction.

If receipt authority belongs to an external provider, gateway receipt must not falsely represent itself as source of payment proof.

---

## 19. Channel-Specific KDS Routing

KDS routing may differ by channel.

Examples:

- dine-in orders show table number;
- takeout orders show pickup code;
- delivery orders show platform name;
- kiosk orders show kiosk ID or pickup number;
- scheduled pickup orders show pickup time;
- preorder orders may be held before kitchen release.

KDS route must include enough context for kitchen staff to prepare correctly.

KDS must not receive duplicate tickets when channel fallback occurs.

---

## 20. Channel-Specific Menu Availability

Menu availability may differ by channel.

Examples:

- dine-in only;
- takeout only;
- delivery excluded;
- kiosk excluded;
- QR/table only;
- staff-only manual item;
- scheduled pickup unavailable;
- late-night channel restricted.

Channel availability must be evaluated before cart/payment acceptance.

---

## 21. Channel-Specific Pricing and Fees

Pricing may differ by channel only if explicitly configured.

Examples:

- packaging fee for takeout;
- delivery platform price;
- kiosk promotion;
- QR table discount;
- service charge for dine-in;
- platform-funded coupon;
- store-funded coupon;
- staff-only discount.

Channel-specific pricing must be versioned and visible in calculation snapshot.

A channel fee must not appear unexpectedly after payment.

---

## 22. Channel-Specific Cancellation and Refund

Cancellation/refund authority must be defined by channel.

Examples:

- dine-in cancellation by manager;
- kiosk refund through payment provider;
- delivery refund through platform;
- external-paid order refund outside gateway;
- preorder cancellation before table assignment;
- scheduled pickup cancellation cutoff;
- staff manual adjustment.

The gateway must not execute refund through internal provider when the channel payment owner is external.

---

## 23. Channel Conversion Policy

Sometimes an order may change channel or fulfillment type.

Examples:

- dine-in order changed to takeout;
- waiting preorder becomes dine-in table order;
- pickup order consumed in store;
- customer QR order handled by staff manually;
- delivery order cancelled and recreated manually.

Channel conversion must be explicit.

Required conversion record:

```text
channel_conversion_id
order_id
from_channel
to_channel
from_fulfillment_type
to_fulfillment_type
reason
actor_id
approval_id
payment_impact
kds_impact
receipt_impact
reconciliation_impact
created_at
```

Channel conversion must not create duplicate order/payment records.

---

## 24. Channel Fallback Policy

Channel fallback may be required when a channel fails.

Fallback examples:

- QR order to staff tablet;
- kiosk order to counter staff;
- delivery provider to manual POS entry;
- preorder to manual confirmation;
- KDS routing to printed ticket;
- mobile payment to counter payment.

Fallback must preserve:

- original channel;
- fallback channel;
- reason;
- payment state;
- POS state;
- customer communication;
- reconciliation linkage.

Fallback must not erase original channel evidence.

---

## 25. Channel Reconciliation

Reconciliation must include channel context.

Required reconciliation dimensions:

- order channel;
- fulfillment type;
- provider;
- payment owner;
- POS receipt;
- external order ID;
- delivery platform ID;
- table/session ID;
- pickup code;
- discount/coupon owner;
- cancellation/refund owner.

Channel-specific settlement rules must be applied.

Delivery platform orders must not be reconciled as internal card payment unless actually paid through internal provider.

---

## 26. Channel Incident Classification

Channel-related incidents may include:

- order routed to wrong channel;
- dine-in order missing table;
- takeout order sent as dine-in;
- delivery order refunded through wrong provider;
- kiosk order not visible to staff;
- QR table order attached to wrong table;
- preorder written before table assignment;
- channel-specific price mismatch;
- customer communication mismatch;
- KDS ticket missing channel context.

Incidents must classify:

- customer impact;
- staff impact;
- kitchen impact;
- payment impact;
- settlement impact;
- channel identity impact.

---

## 27. Channel Monitoring

The gateway must monitor channel health.

Required metrics:

- order count by channel;
- failure count by channel;
- payment mismatch by channel;
- KDS failure by channel;
- cancellation/refund failure by channel;
- fallback count by channel;
- channel conversion count;
- manual review count by channel;
- reconciliation variance by channel;
- customer dispute count by channel.

Channel-specific failures must not be hidden inside aggregate order success rate.

---

## 28. Dashboard Requirements

Operations dashboard must show:

- active channels per store;
- enabled fulfillment types;
- active channel restrictions;
- payment timing per channel;
- receipt behavior per channel;
- KDS routing status per channel;
- channel-specific incident count;
- channel fallback count;
- channel reconciliation status;
- delivery/external provider boundary;
- table/QR object status;
- kiosk device status.

Dashboard must not show “ordering active” without channel scope.

---

## 29. Kiosk / QR / Table Reuse Boundary

Kiosk, QR, and table ordering must call the same channel routing boundary used by POS Gateway.

They must not bypass:

- provider routing;
- menu mapping;
- price calculation;
- availability;
- payment timing;
- cancellation/refund ownership;
- KDS routing;
- receipt identity;
- channel reconciliation;
- incident evidence.

If kiosk or QR system maintains its own channel logic, it must be reconciled against POS Gateway channel policy.

---

## 30. External Provider Boundary

External delivery or ordering providers may own parts of the transaction.

The gateway must determine:

- who owns customer payment;
- who owns customer support;
- who owns refund;
- who owns cancellation;
- who owns settlement;
- who owns receipt;
- who owns delivery status;
- who owns customer notification.

If ownership is unclear, automation must be restricted.

---

## 31. Prohibited Practices

The following practices are prohibited:

- treating all orders as generic POS orders;
- losing original channel after fallback;
- writing table QR order without valid table/session;
- refunding external-paid delivery order through wrong provider;
- sending delivery order to KDS without channel marker;
- applying dine-in price to delivery channel without rule;
- applying delivery fee to dine-in order;
- converting channel without audit record;
- allowing kiosk to bypass channel restrictions;
- hiding channel-specific reconciliation variance;
- marking channel as enabled when payment or receipt behavior is unknown.

---

## 32. Minimum Acceptance Criteria

Order channel separation is acceptable only when:

- order channel model exists;
- fulfillment type model exists;
- channel scope is explicit;
- channel enablement gate exists;
- dine-in, table QR, kiosk, takeout, scheduled pickup, delivery, staff, and preorder policies exist where applicable;
- payment timing is defined by channel;
- receipt behavior is defined by channel;
- KDS routing is channel-aware;
- menu availability and price rules are channel-aware;
- cancellation/refund authority is channel-aware;
- channel conversion is auditable;
- channel fallback preserves evidence;
- reconciliation includes channel context;
- monitoring and incident classification include channel context.

---

## 33. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_order_channels
pos_gateway_fulfillment_types
pos_gateway_channel_rules
pos_gateway_channel_enablements
pos_gateway_channel_payment_timing_rules
pos_gateway_channel_receipt_rules
pos_gateway_channel_kds_rules
pos_gateway_channel_menu_availability_rules
pos_gateway_channel_pricing_rules
pos_gateway_channel_cancel_refund_rules
pos_gateway_channel_conversions
pos_gateway_channel_fallback_records
pos_gateway_channel_reconciliation_records
pos_gateway_channel_incidents
```

Recommended services:

```text
OrderChannelService
FulfillmentTypeService
ChannelEnablementService
DineInChannelService
TableQrChannelService
KioskChannelService
TakeoutPickupChannelService
ScheduledPickupService
DeliveryChannelService
StaffOrderChannelService
WaitingPreorderHandoffService
ChannelPaymentTimingService
ChannelReceiptService
ChannelKdsRoutingService
ChannelConversionService
ChannelFallbackService
ChannelReconciliationService
ChannelMonitoringService
```

Recommended event types:

```text
pos_gateway.channel.enabled
pos_gateway.channel.disabled
pos_gateway.channel.order_created
pos_gateway.channel.fulfillment_type_assigned
pos_gateway.channel.payment_timing_selected
pos_gateway.channel.receipt_behavior_selected
pos_gateway.channel.kds_route_selected
pos_gateway.channel.conversion_requested
pos_gateway.channel.conversion_completed
pos_gateway.channel.fallback_started
pos_gateway.channel.fallback_completed
pos_gateway.channel.reconciliation_variance_detected
pos_gateway.channel.incident_detected
```

---

## 34. Relationship To Adjacent Documents

This document is related to:

- 06040 POS Gateway tenant, store, SaaS onboarding package, template provisioning, and operational enablement policy;
- 06050 POS Gateway menu item, option, modifier, mapping template, versioning, and price integrity policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy;
- 06070 POS Gateway inventory, availability, sold-out, stock sync, and order blocking integrity policy;
- POS Gateway KDS kitchen ticket routing policy;
- POS Gateway cancellation and refund exception policy;
- POS Gateway reconciliation and settlement linkage policy;
- kiosk, QR, table ordering, waiting/preorder handoff, and delivery integration policies.

Where conflict exists, this document governs order channel separation, fulfillment routing, channel-specific payment/receipt/KDS behavior, and channel evidence preservation.

---

## 35. Summary

An order is not only a list of items.

It also has a channel, fulfillment type, payment timing, table/session context, receipt behavior, KDS route, support boundary, and settlement meaning.

The POS Gateway must preserve that context.

The correct standard is:

- classify every order channel;
- separate fulfillment type from channel;
- validate table/kiosk/delivery identity;
- define payment and receipt behavior by channel;
- preserve fallback and conversion evidence;
- reconcile by channel;
- prevent kiosk, QR, and delivery flows from bypassing POS Gateway controls.

A generic order model may look simple, but it will break in real store operations.