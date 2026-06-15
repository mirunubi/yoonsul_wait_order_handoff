# 14019_Policy_POS_Business_Day_Close_Table_Move_And_Field_Operation_Sync

## 1. Purpose

This policy defines how the POS Gateway must handle business day close, sales date boundaries, table state changes, table merge, table move, and store-side field operation synchronization in POS-connected order flow.

The purpose is to prevent store-side operational actions performed directly in POS from corrupting platform order state, table state, payment state, settlement date, and audit evidence.

The POS Gateway must distinguish platform order time, POS business day, calendar date, table context, and store-side manual operation state.

## 2. Scope

This policy applies to:

* POS business day open and close
* After-midnight order handling
* Store operating date
* POS sales date
* Payment date
* Settlement date
* Table ID mapping
* Table section mapping
* Table merge
* Table split
* Table move
* Seat or party movement
* Store-side POS manual order modification
* Store-side POS cancellation
* Store-side POS table relocation
* Waiting-to-table handoff
* Dine-in order synchronization
* Operator visibility
* Audit evidence for business day and table state transitions

This policy applies to all dine-in, table order, waiting handoff, preorder, and store-side POS-connected flows where business day, table, or field operation state affects execution or settlement.

## 3. Core Principle

Calendar date is not always POS business date.

Table identity is not always stable.

Store-side POS operation may change order execution state without the platform initiating it.

The POS Gateway must not assume that:

* Midnight means business day changed
* Platform order date equals POS sales date
* Table number is globally stable
* Table assignment never changes after order
* POS staff will not manually modify orders
* POS state and platform state remain aligned automatically

Field operation changes must be synchronized, classified, and audited.

## 4. Business Day And Field Operation Boundary

The POS Gateway sits between platform order state and POS field operation state.

```
[Platform Order / Payment / Table Context]
                   |
                   v
    [POS Gateway Field Operation Sync Layer]
                   |
         --------------------------
         |                        |
         v                        v
    [POS Business Day]       [POS Table State]
         |                        |
         v                        v
    [Settlement Date]        [Store Execution State]
```

The Gateway must preserve both platform context and provider execution context.

## 5. Non-Negotiable Rules

### 5.1 Business Date Explicitness Rule

Every POS-connected order must record the relevant date contexts explicitly.

At minimum:

* Platform order date
* Platform payment date
* Store local date
* POS business date
* POS receipt date
* Settlement date, when known
* Accounting date, when assigned

The system must not rely on one timestamp to infer all business dates.

### 5.2 POS Close Event Must Be Audited Rule

If a provider exposes business day open or close events, the Gateway must capture and audit them.

If a provider does not expose them, the integration must be marked as limited and must use a documented fallback rule.

### 5.3 Table Mapping Required Rule

Customer-facing table identity must be mapped to POS-facing table identity through a controlled mapping layer.

The system must not assume that visible table number and POS table ID are the same.

### 5.4 Table Movement Must Not Lose Order Context Rule

If a table is moved, merged, split, or reassigned, the platform must preserve the original table context and the current table context.

Kitchen, hall, payment, and audit state must remain traceable.

### 5.5 Store-Side Manual Operation Must Be Classified Rule

If store staff changes order, table, payment, or cancellation state directly in POS, the Gateway must classify the event as field operation mutation, not as ordinary platform state.

## 6. Date Contexts

The system must distinguish the following date contexts.

### 6.1 Platform Order Date

The date when the platform created the order intent.

This is based on platform clock and customer flow.

### 6.2 Platform Payment Date

The date when payment was approved, voided, refunded, or captured through platform payment flow.

### 6.3 Store Local Date

The calendar date in the store’s local timezone.

### 6.4 POS Business Date

The business date assigned by the POS.

This may differ from calendar date, especially for:

* Late-night stores
* Bars
* 24-hour stores
* Stores that close after midnight
* Stores that delay day-end closing
* Stores that reopen without proper close

### 6.5 POS Receipt Date

The timestamp recorded on the POS receipt or sales record.

### 6.6 Settlement Date

The date used for PG, franchise, or accounting settlement.

### 6.7 Accounting Date

The date assigned by finance or accounting policy.

This may follow POS business date, platform payment date, or settlement rule.

## 7. Business Day State Classification

The Gateway must normalize business day states.

Allowed states include:

```
BUSINESS_DAY_UNKNOWN
BUSINESS_DAY_OPEN
BUSINESS_DAY_CLOSING
BUSINESS_DAY_CLOSED
BUSINESS_DAY_REOPENED
BUSINESS_DAY_ROLLED_OVER
BUSINESS_DAY_CLOSE_DELAYED
BUSINESS_DAY_PROVIDER_UNSUPPORTED
BUSINESS_DAY_MANUAL_CONFIRMATION_REQUIRED
```

These states must be visible in audit and readiness evidence.

## 8. Business Day Close Handling

When a POS business day close occurs, the Gateway must determine:

* Which orders belong to the closing business day
* Which orders are still pending
* Which orders are payment-approved but POS-unaccepted
* Which refunds or voids remain unresolved
* Which queued jobs should stop replaying
* Which orders must move to manual review
* Which reconciliation batch should include the orders

Business day close must not silently invalidate pending order state.

## 9. After-Midnight Order Handling

After-midnight orders require explicit policy.

Example:

```
Customer orders at 01:30 on June 16.
POS still treats the sale as June 15 business day.
PG approval date is June 16.
Accounting may need June 15 or June 16 depending on policy.
```

The Gateway must record all date contexts.

The settlement and reconciliation policy must decide how to aggregate the order.

## 10. Provider Capability For Business Day

Each provider capability profile must declare whether the provider supports:

* Business day query
* Business day open event
* Business day close event
* Business date in receipt
* Manual close detection
* Business date override
* Day-end sales summary
* Reconciliation export
* Store local timezone

If unsupported, the integration must define a fallback rule and risk classification.

## 11. Table Identity Boundary

The system must distinguish:

* Customer-visible table label
* Platform table ID
* POS table ID
* POS table section
* Physical table marker
* Waiting session ID
* Seating session ID
* Merged table group ID
* Split bill group ID

A table number shown to the customer is not sufficient as a stable integration identity.

## 12. Table Mapping Registry

The table mapping registry should include:

```
table_mapping_id
store_id
platform_table_id
customer_visible_label
pos_provider_id
pos_table_id
pos_section_id
physical_zone
seating_capacity
active_flag
effective_from
effective_until
mapping_version
created_by
approved_by
approved_at
```

The mapping registry must support versioning and store-specific mapping.

## 13. Table State Classification

The Gateway must normalize table states.

Allowed states include:

```
TABLE_UNKNOWN
TABLE_AVAILABLE
TABLE_RESERVED
TABLE_WAITING_ASSIGNED
TABLE_OCCUPIED
TABLE_ORDERING
TABLE_SERVING
TABLE_PAYMENT_PENDING
TABLE_CLOSED
TABLE_MOVED
TABLE_MERGED
TABLE_SPLIT
TABLE_PROVIDER_UNSUPPORTED
TABLE_MANUAL_CONFIRMATION_REQUIRED
```

These states must be mapped carefully to provider-specific table states.

## 14. Table Move Handling

A table move occurs when an order or party moves from one table to another.

The Gateway must preserve:

* Original table
* New table
* Move reason
* Move actor
* Move time
* POS move reference, if available
* Platform move reference, if platform-initiated
* Kitchen notice status
* Hall notice status
* Payment impact
* Audit event

The platform must not lose order context during table move.

## 15. Table Merge Handling

A table merge occurs when two or more physical or logical tables become one serving group.

The Gateway must preserve:

* Original table IDs
* Merged table group ID
* POS merged table reference
* Orders included
* Payments included
* Split bill impact
* Kitchen routing impact
* Staff actor
* Timestamp
* Audit event

Merged tables must not cause duplicate orders, lost orders, or settlement ambiguity.

## 16. Table Split Handling

A table split occurs when one serving group becomes separate groups or bills.

The Gateway must preserve:

* Original table group
* New table or bill groups
* Order line allocation
* Payment allocation
* POS split reference
* Staff actor
* Customer impact
* Audit event

Table split is especially risky when split payment, partial refund, or table order continuation is involved.

## 17. Waiting-To-Table Handoff

For waiting-to-order handoff flows, the Gateway must connect:

* Waiting session
* Preorder cart
* Customer identity or session identity
* Assigned table
* POS table ID
* Order submission timing
* Payment state
* Kitchen state

If a waiting customer is seated at a different table than originally expected, the Gateway must update the table context before POS submission or preserve a table move event after submission.

## 18. Store-Side Manual POS Mutation

Store staff may directly mutate the order in POS.

Manual POS mutations may include:

* Add item
* Remove item
* Change option
* Apply discount
* Move table
* Merge table
* Split table
* Cancel order
* Void receipt
* Reprint ticket
* Change business day
* Mark sold-out
* Change payment method
* Close check

If the provider exposes mutation events, the Gateway must ingest, schema-validate, classify, and audit them.

If not exposed, reconciliation must detect mismatches later.

## 19. Manual Mutation Categories

The Gateway must classify manual POS mutations.

Allowed categories include:

```
MANUAL_ITEM_ADD
MANUAL_ITEM_REMOVE
MANUAL_OPTION_CHANGE
MANUAL_DISCOUNT_APPLIED
MANUAL_TABLE_MOVE
MANUAL_TABLE_MERGE
MANUAL_TABLE_SPLIT
MANUAL_ORDER_CANCEL
MANUAL_PAYMENT_CHANGE
MANUAL_RECEIPT_VOID
MANUAL_REPRINT
MANUAL_BUSINESS_DAY_CLOSE
MANUAL_SOLD_OUT_CHANGE
UNKNOWN_POS_MANUAL_MUTATION
```

Each category must map to a reconciliation and audit handling rule.

## 20. Sync Direction Policy

Business day and table state may sync in different directions.

### 20.1 POS-To-Platform Sync

Used when POS is operational source for table and business day.

Examples:

* POS table move
* POS table merge
* POS close event
* POS payment complete
* POS cancellation

### 20.2 Platform-To-POS Sync

Used when platform controls customer order context.

Examples:

* Waiting session assigned to table
* Table order submitted
* Customer request updates order context
* Platform cancels pending preorder

### 20.3 Bidirectional Sync

Used only when conflict handling is well-defined.

Bidirectional sync requires:

* Conflict policy
* Versioning
* Idempotency
* Actor attribution
* Audit events
* Operator review path

Bidirectional sync without conflict handling is prohibited.

## 21. Conflict Handling

Conflicts may occur between platform and POS state.

Examples:

* Platform thinks table is available, POS says occupied
* Platform assigned table 7, POS moved order to table 5
* Platform order pending, POS order canceled
* Platform payment approved, POS business day closed
* Platform queue wants replay, POS table no longer exists
* Platform sees waiting handoff, POS has manual order already entered

The Gateway must classify and resolve conflicts through controlled policy.

Allowed outcomes include:

```
ACCEPT_POS_STATE
ACCEPT_PLATFORM_STATE
REQUIRE_OPERATOR_CONFIRMATION
HOLD_ORDER
CANCEL_OR_REFUND
UPDATE_TABLE_CONTEXT
MARK_RECONCILIATION_REQUIRED
BLOCK_REPLAY
ESCALATE_SUPPORT
```

## 22. Queue And Replay Interaction

Queued orders must revalidate business day and table state before replay.

Replay must be blocked or reviewed when:

* POS business day closed
* Table moved
* Table merged
* Table no longer exists
* Order was manually entered
* Payment was refunded
* Customer was reassigned
* Store switched to manual operation
* Local agent was offline too long

The queue policy must not replay stale table or business day context blindly.

## 23. Payment And Settlement Interaction

Business day and table changes may affect payment and settlement.

The Gateway must preserve:

* Payment time
* POS receipt time
* POS business date
* Table at order time
* Table at payment time
* Discount or manual adjustment
* Split payment relationship
* Day-end reconciliation batch

Payment reconciliation must not assume that table state and business date are unchanged.

## 24. Kitchen And Hall Notification

Table changes may require kitchen or hall notification.

Examples:

* Table moved after kitchen ticket printed
* Table merged after order submitted
* Table split before payment
* Waiting order seated at new table
* Cancel notice after table move

If platform controls kitchen printing, it may generate table move or cancel notices.

If POS controls kitchen printing, the Gateway must record that notification is provider-delegated or operator-managed.

## 25. Operator Console Requirements

The operator console must show:

* Current POS business day state
* Platform order date
* POS business date
* Business day close warnings
* Table mapping status
* Table state conflicts
* Table move events
* Table merge events
* Table split events
* Manual POS mutation events
* Pending queue jobs affected by table or business day state
* Reconciliation-required orders

Allowed operator actions may include:

```
CONFIRM_BUSINESS_DAY
OVERRIDE_BUSINESS_DATE_WITH_REASON
MAP_TABLE
CONFIRM_TABLE_MOVE
CONFIRM_TABLE_MERGE
CONFIRM_TABLE_SPLIT
ACCEPT_POS_TABLE_STATE
ACCEPT_PLATFORM_TABLE_STATE
MARK_MANUAL_POS_MUTATION
BLOCK_QUEUE_REPLAY
SEND_TABLE_MOVE_NOTICE
ESCALATE_RECONCILIATION
```

All operator actions must be audited.

## 26. Customer-Facing Messaging

Customer-facing messages must be simple and non-technical.

Examples:

```
Your table has been updated.
The store is confirming your table.
The store is preparing your order at the assigned table.
This table is no longer available.
The store needs to confirm this order again.
```

Customer-facing messages must not expose POS business day internals, provider table IDs, reconciliation state, or raw POS events.

## 27. Audit Requirements

Every business day, table, and field operation sync event must preserve:

* Platform order ID, if applicable
* Store ID
* Provider ID
* Platform order date
* Store local date
* POS business date
* POS receipt date
* Settlement date, if known
* Platform table ID
* Customer-visible table label
* POS table ID
* Table mapping version
* Previous table state
* New table state
* Field operation category
* Actor
* Source system
* Provider event reference
* Platform event reference
* Conflict category
* Decision outcome
* Operator action, if any
* Trace ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive values must be redacted, tokenized, or encrypted according to the security runtime policy.

## 28. Test Requirements

Each provider integration must test:

* Business day open
* Business day close
* Provider does not expose business day
* After-midnight order
* Payment date differs from POS business date
* Table direct mapping
* Table ID mismatch
* Table move
* Table merge
* Table split
* Waiting session assigned to table
* Table changed after POS submission
* Manual POS cancellation
* Manual POS discount
* Manual table mutation
* Queue replay after business day close
* Queue replay after table move
* Reconciliation date mismatch
* Audit preservation for all field operation events

A provider cannot be production-ready for dine-in or table flow without business day and table operation test evidence.

## 29. Anti-Patterns

The following are prohibited:

* Assuming calendar date equals POS business date
* Assuming table label equals POS table ID
* Losing original table context after table move
* Treating table merge as a simple table rename
* Replaying queued orders after business day close without validation
* Ignoring manual POS mutations
* Treating all POS-side changes as platform-initiated
* Running bidirectional table sync without conflict policy
* Hiding table conflicts from operators
* Reconciling payments without POS business date
* Using provider table IDs directly as customer-facing identity

## 30. Relationship With Other Documents

This policy depends on and supports:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05320 POS Menu Hierarchy Option Transformer Policy
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Business day and table operation synchronization is the bridge between platform order state and real store execution state.

## 31. Final Rule

The POS Gateway must always be able to explain which business day, table context, and field operation state applied to an order at the time it was created, submitted, moved, paid, canceled, fulfilled, or reconciled.

If the system cannot distinguish platform date from POS business date, customer table label from POS table ID, or platform action from store-side manual POS mutation, the field operation synchronization boundary has failed.
