# 014027_Policy_POS_Inventory_Race_Condition_And_Stock_Hold_Buffer

## 1. Purpose

This policy defines how the POS Gateway must handle inventory race conditions, sold-out timing gaps, stock hold buffers, last-item conflicts, POS-side manual sales, platform-side preorder, and provider stock validation uncertainty.

The purpose is to prevent two or more order channels from selling the same limited item when the POS provider, platform cache, store staff, and kitchen stock state are not perfectly synchronized.

In F&B operations, inventory is often operational, approximate, and manually adjusted. The Gateway must protect customer experience, store execution, payment integrity, and audit evidence when stock state changes faster than synchronization can propagate.

## 2. Scope

This policy applies to:

* Sold-out race condition
* Last-item conflict
* POS-side manual order competing with platform order
* Platform preorder competing with in-store order
* Stock hold before payment
* Stock hold after payment
* Stock release after cancellation
* Stock release after payment failure
* Stock release after no-show
* Stock release after queue expiration
* POS stock validation
* Platform stock buffer
* Provider sold-out sync delay
* Store manual sold-out
* Kitchen actual stock shortage
* Audit evidence for inventory and stock hold decisions

This policy applies to all order channels where limited menu availability, ingredient stock, item-level count, option-level count, or kitchen capacity may affect whether an order can be accepted.

## 3. Core Principle

Sold-out state is a fast-moving operational truth, not merely a menu display flag.

The platform must not assume that cached availability is always current.

The POS Gateway must defend against race conditions between:

* Platform customer order
* POS manual order
* Kitchen actual stock
* POS sold-out state
* Platform cache
* Store operator update
* Provider webhook delay
* Local agent delay
* Payment approval timing

When stock is limited, the Gateway must use controlled hold, validation, release, rejection, refund, or manual confirmation.

## 4. Inventory Race Boundary

Inventory decisions may cross multiple systems.

```
[Customer Cart / Preorder]
          |
          v
[Gateway Stock Hold Buffer]
          |
  ----------------------------
  |                          |
  v                          v
[Platform Availability]   [POS / Store Availability]
          |
          v
    [Kitchen Actual Stock]
```

The Gateway must distinguish customer-visible availability, platform-held stock, POS-validated availability, and kitchen-confirmed availability.

## 5. Non-Negotiable Rules

### 5.1 Last-Item Must Be Protected Rule

If an item is near depletion or stock count is limited, the Gateway must not rely only on stale cache.

The Gateway must validate, hold, or require confirmation before payment approval or POS submission.

### 5.2 Hold Must Expire Rule

A stock hold must always have expiration.

The system must not allow abandoned carts, failed payments, no-shows, or stuck queue jobs to hold stock forever.

### 5.3 Payment Must Not Confirm Unavailable Stock Rule

If stock cannot be validated or held for a limited item, payment must be blocked, delayed, or moved to controlled confirmation.

The platform must not approve payment while knowingly uncertain that the item can be fulfilled.

### 5.4 POS Manual Sale Conflict Must Be Recognized Rule

A POS-side manual order may consume the last available stock before the platform order is submitted.

The Gateway must classify this as stock race condition, not as generic order failure.

### 5.5 Stock Decision Must Be Auditable Rule

Every stock hold, release, validation, rejection, override, and refund decision must preserve evidence.

## 6. Inventory State Types

The system must distinguish the following states.

### 6.1 Display Availability

The item is shown as available to customers.

This may be based on platform cache and may not be final truth.

### 6.2 Cart Availability

The item appeared available when added to cart.

Cart availability must be revalidated before payment.

### 6.3 Held Availability

The Gateway temporarily reserves quantity for a customer intent.

This state must have expiration and release rules.

### 6.4 POS Validated Availability

The provider or POS confirms the item is available at validation time.

This may still be subject to race if the provider does not lock stock.

### 6.5 Kitchen Confirmed Availability

Store staff or kitchen confirms actual fulfillment ability.

This may be required for degraded or manual-assisted flows.

### 6.6 Sold-Out

The item is no longer available.

Sold-out may be platform-side, POS-side, kitchen-side, or manual operator-side.

### 6.7 Unknown Availability

The system cannot safely determine current stock state.

Unknown availability must not be treated as available for high-risk items.

## 7. Stock State Classification

Allowed stock states include:

```
AVAILABLE
LOW_STOCK
HOLD_PENDING
HELD
HOLD_EXPIRED
HOLD_RELEASED
POS_VALIDATION_PENDING
POS_VALIDATED_AVAILABLE
POS_VALIDATED_UNAVAILABLE
KITCHEN_CONFIRMATION_REQUIRED
SOLD_OUT_PLATFORM
SOLD_OUT_POS
SOLD_OUT_KITCHEN
SOLD_OUT_MANUAL
STOCK_RACE_CONFLICT
STOCK_STATE_UNKNOWN
STOCK_SYNC_STALE
STOCK_OVERRIDE_APPLIED
```

These states must be distinct from order and payment states.

## 8. Stock Hold Identity

A stock hold must have a stable identity.

A stock hold record should include:

```
stock_hold_id
store_id
platform_order_id
cart_id
waiting_session_id
menu_item_id
option_item_id
ingredient_group_id
quantity
hold_reason
hold_status
hold_started_at
hold_expires_at
released_at
release_reason
provider_validation_reference
operator_confirmation_reference
idempotency_key
trace_id
```

Stock hold identity must be linked to the customer intent and order lifecycle.

## 9. Hold Reasons

Allowed hold reasons include:

```
CART_CHECKOUT
PAYMENT_IN_PROGRESS
PREORDER_PENDING
WAITING_ORDER_PENDING
QUEUE_REPLAY_PENDING
OPERATOR_CONFIRMATION_PENDING
PROVIDER_VALIDATION_PENDING
KITCHEN_CONFIRMATION_PENDING
TABLE_ASSIGNMENT_PENDING
```

Hold reason must influence expiration and release behavior.

## 10. Hold Expiration

Each hold must expire according to policy.

Expiration may vary by:

* Menu item
* Ingredient
* Order channel
* Payment state
* Waiting state
* Store peak period
* Preparation lead time
* Provider validation mode
* Kitchen capacity

When a hold expires, the Gateway must release the quantity or require operator decision.

Expired hold must not silently remain active.

## 11. Hold Release Reasons

Allowed release reasons include:

```
PAYMENT_FAILED
PAYMENT_CANCELED
CUSTOMER_CANCELED
WAITING_CANCELED
NO_SHOW_RELEASE
ORDER_REJECTED
POS_REJECTED
KITCHEN_REJECTED
QUEUE_EXPIRED
OPERATOR_RELEASED
HOLD_REPLACED
ORDER_CONFIRMED_CONSUMED
REFUND_COMPLETED
MANUAL_RECOVERY
```

Release reason must be auditable.

## 12. Last-Item Race Scenario

A typical last-item race may occur as follows:

```
Item has one unit left.
Customer A adds item through platform.
Customer B orders the same item directly at POS.
POS accepts Customer B order first.
Platform cache still shows available.
Customer A proceeds to payment.
```

The Gateway must prevent or resolve this by:

* Revalidating before payment
* Holding stock before payment when supported
* Blocking payment if validation fails
* Releasing hold if POS rejects
* Notifying customer
* Updating availability cache
* Preserving race evidence

## 13. Pessimistic Hold Buffer

For limited stock items, the Gateway may use a pessimistic hold buffer.

This means the platform temporarily reduces available quantity before payment completes.

Pessimistic hold is useful when:

* Item stock is countable
* Item is low stock
* Payment flow is short
* Customer intent is strong
* Provider validation is slow
* Race risk is high

Pessimistic hold requires:

* Short expiration
* Idempotency key
* Release rule
* Operator visibility
* Audit evidence
* Abuse protection

## 14. Optimistic Validation

For items with abundant stock or low race risk, the Gateway may use optimistic validation.

This means the platform validates availability near payment or submission time without pre-holding stock.

Optimistic validation is acceptable when:

* Stock is not count-limited
* Provider validation is fast
* Sold-out risk is low
* Item can be substituted or delayed
* Store allows manual recovery

Optimistic validation must still handle failure gracefully.

## 15. Provider Stock Lock Support

Each provider capability profile must declare whether the provider supports:

* Stock query
* Sold-out query
* Stock lock
* Stock decrement
* Stock release
* Stock reservation
* Item-level stock
* Option-level stock
* Ingredient-level stock
* Webhook sold-out update
* Manual sold-out event
* Atomic order acceptance

If provider stock lock is unsupported, the Gateway must compensate with platform hold, stricter validation, or manual confirmation.

## 16. POS Atomicity Assumption

The Gateway must not assume that a POS provider atomically validates and decrements stock unless this is confirmed.

If provider atomicity is unknown, the integration must mark stock race risk.

Provider order acceptance may not guarantee stock decrement correctness.

## 17. Ingredient-Level Stock

Some items share ingredients.

Examples:

* Last chicken thigh portion used by multiple menu variants
* Last donkatsu available for bowl, kimbap, or set
* Shared soup stock
* Shared side dish
* Shared sauce or topping

The stock hold model should support ingredient or stock group reservation, not only menu item reservation.

A single ingredient shortage may require multiple menu items to be marked unavailable.

## 18. Option-Level Stock

Options may also sell out.

Examples:

* Extra egg
* Extra chicken
* Seasonal topping
* Limited sauce
* Side upgrade
* Drink option

Option stock must be validated when it affects fulfillment.

The system must not accept an order with an unavailable required or paid option.

## 19. Kitchen Capacity As Stock-Like Constraint

Kitchen capacity may behave like stock during peak.

Examples:

* Limited grill capacity
* Limited fryer capacity
* Limited rice batch
* Limited pickup slot
* Limited staff capacity
* Limited prep queue length

The Gateway may treat certain capacity limits as stock-like constraints.

Capacity hold must have expiration and release rules.

## 20. Stock Conflict Decision Outcomes

When stock conflict occurs, the Gateway may choose:

```
ALLOW_ORDER
BLOCK_PAYMENT
HOLD_FOR_RECHECK
REQUIRE_CUSTOMER_SELECTION_CHANGE
REQUIRE_OPERATOR_CONFIRMATION
CANCEL_AND_REFUND
PARTIAL_CANCEL_AND_PARTIAL_REFUND
SUBSTITUTE_WITH_CUSTOMER_CONFIRMATION
MARK_SOLD_OUT
RELEASE_HOLD
ESCALATE_KITCHEN_CONFIRMATION
MARK_STOCK_RACE_CONFLICT
```

The decision must be linked to payment, kitchen, and customer notification state.

## 21. Customer-Facing Messaging

Customer-facing messages must be clear and non-technical.

Examples:

```
This item just sold out.
This option is no longer available.
The store is confirming availability.
Please choose another item.
Your payment was not completed because the item is unavailable.
A refund is being processed because the store cannot prepare this item.
```

Customer-facing messages must not expose POS locking behavior, stock algorithms, race detection details, or internal provider errors.

## 22. Operator Console Requirements

The operator console must show:

* Low-stock items
* Active stock holds
* Hold expiration
* Sold-out conflicts
* POS validation failures
* Kitchen confirmation required items
* Last-item race conflicts
* Manual stock override
* Stock release actions
* Affected orders
* Affected payments
* Customer notification state

Allowed operator actions may include:

```
CONFIRM_STOCK_AVAILABLE
CONFIRM_SOLD_OUT
RELEASE_HOLD
EXTEND_HOLD_WITH_REASON
REJECT_ORDER_FOR_SOLD_OUT
APPROVE_SUBSTITUTION
TRIGGER_REFUND
MARK_MANUAL_STOCK_OVERRIDE
UPDATE_SOLD_OUT_STATE
ESCALATE_KITCHEN_CONFIRMATION
```

All operator actions must be audited.

## 23. Queue And Replay Interaction

Queued orders must revalidate stock before replay.

Replay must be blocked or reviewed when:

* Hold expired
* Item sold out
* Stock state unknown
* Provider validation stale
* Kitchen capacity changed
* Customer was refunded
* Waiting session canceled
* Manual stock override occurred
* Business day closed

The queue system must not replay old orders into depleted stock.

## 24. Payment Interaction

Payment must be coordinated with stock hold.

Before payment approval, the Gateway must know whether:

* Stock was held
* Stock validation succeeded
* Stock validation is stale
* Stock is unknown
* Stock conflict exists
* Customer confirmation is required

If payment is approved and stock later fails, the Gateway must route the order to cancel, partial cancel, refund, substitution, or manual recovery flow.

## 25. Kitchen Interaction

Kitchen may discover stock shortage after POS and payment success.

In that case, the Gateway must:

* Classify kitchen sold-out
* Stop or adjust kitchen execution
* Notify operator
* Notify customer
* Trigger refund or substitution flow
* Preserve kitchen shortage evidence
* Update availability if appropriate

Kitchen-discovered shortage must not be hidden as generic cancellation.

## 26. Audit Requirements

Every stock hold, validation, conflict, release, and override event must preserve:

* Stock hold ID
* Store ID
* Menu item ID
* Option item ID, if applicable
* Ingredient group ID, if applicable
* Platform order ID, if applicable
* Cart ID, if applicable
* Waiting session ID, if applicable
* Provider ID
* Quantity
* Previous stock state
* New stock state
* Hold status
* Hold reason
* Release reason
* Validation source
* Validation result
* Conflict category
* Decision outcome
* Operator action, if any
* Customer notification reference
* Payment action reference, if applicable
* Kitchen action reference, if applicable
* Trace ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive customer data must be minimized according to the security runtime policy.

## 27. Test Requirements

Each provider or store flow must test:

* Normal available item
* Low stock item
* Last-item platform order
* Last-item POS manual order wins
* Last-item platform hold wins
* Sold-out webhook delay
* Provider validation rejects sold-out item
* Payment blocked before approval
* Payment approved then kitchen shortage
* Hold expiration
* Hold release after payment failure
* Hold release after customer cancel
* Hold release after no-show
* Queue replay after stock sold out
* Option-level stock sold out
* Shared ingredient stock conflict
* Manual operator sold-out override
* Audit preservation for all stock states

A provider or store flow cannot be production-ready without stock race and hold buffer test evidence.

## 28. Anti-Patterns

The following are prohibited:

* Treating menu display availability as final stock truth
* Holding stock without expiration
* Approving payment for limited stock without validation or hold
* Replaying queued orders without stock revalidation
* Ignoring POS-side manual orders that consume stock
* Treating kitchen shortage as generic cancellation
* Allowing stale sold-out cache to keep selling items
* Hiding stock race conflicts from operators
* Using item-level stock only when ingredient-level stock is required
* Silently substituting unavailable items without customer or operator confirmation
* Refunding without linking to stock failure evidence

## 29. Relationship With Other Documents

This policy depends on and supports:

```
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05410 POS Waiting Entry NoShow And Prepaid Cancel Sync Policy
05420 POS Legacy Hardware OS Adaptive Timeout And App Restart Policy
```

Inventory race handling protects the platform from selling operationally unavailable food due to synchronization delay.

## 30. Final Rule

The POS Gateway must always be able to explain whether an item was displayed as available, held, validated, consumed, released, sold out, overridden, rejected, refunded, or manually recovered.

If two channels can sell the last available item without controlled hold, validation, conflict resolution, and audit evidence, the inventory race boundary has failed.
