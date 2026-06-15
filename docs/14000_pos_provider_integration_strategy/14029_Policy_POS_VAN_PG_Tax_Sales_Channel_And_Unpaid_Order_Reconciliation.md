# 14029_Policy_POS_VAN_PG_Tax_Sales_Channel_And_Unpaid_Order_Reconciliation

## 1. Purpose

This policy defines how the POS Gateway must handle reconciliation between platform PG payments, store VAN payments, POS sales records, tax reporting, sales channel classification, unpaid orders, service orders, house accounts, and manual payment adjustments.

The purpose is to prevent duplicate sales reporting, missing sales records, incorrect VAT classification, settlement mismatch, unpaid order loss, and tax confusion when platform payment and store-side POS/VAN payment coexist.

In F&B operations, payment and sales evidence may be created by different systems. The POS Gateway must preserve which system collected money, which system recorded sales, which channel produced the order, and how the transaction should be reconciled for store, franchise, tax, settlement, and audit purposes.

## 2. Scope

This policy applies to:

* Platform PG payment
* Store VAN card payment
* POS sales receipt
* Smart order sales channel
* In-store card sales
* Cash sales
* Coupon sales
* Point usage
* Service order
* Unpaid order
* House account
* Manual adjustment
* POS sales channel mapping
* Tax and VAT classification
* Card sales aggregation
* Duplicate sales prevention
* Settlement reconciliation
* PG/VAN/POS mismatch
* Daily closing reconciliation
* Audit evidence for all sales and payment channels

This policy applies to all order flows where platform-side payment, POS-side payment, or unpaid POS completion may affect store sales, tax reporting, settlement, accounting, and audit state.

## 3. Core Principle

Payment channel, sales channel, and tax reporting channel must be explicitly separated.

The platform must not assume that a POS receipt, PG approval, VAN approval, and taxable sales record all represent the same thing.

The Gateway must distinguish:

* Who accepted the order
* Who collected the money
* Which system recorded the sale
* Which channel the sale belongs to
* Which date the sale belongs to
* Which tax category applies
* Whether the sale is paid, unpaid, serviced, voided, refunded, or externally settled

If these identities are collapsed, duplicate taxation, missing revenue, and settlement disputes become inevitable.

## 4. Reconciliation Boundary

Money and sales data may flow through different systems.

```
[Customer Order]
      |
      v
[Platform / Catch Menu]
      |
  -------------------------
  |                       |
  v                       v
[Platform PG]          [POS Gateway]
                          |
                -----------------------
                |                     |
                v                     v
          [POS Sales Record]     [Store VAN / Cash / Other]
```

The Gateway must correlate these systems without double-counting.

## 5. Non-Negotiable Rules

### 5.1 Sales Channel Must Be Explicit Rule

Every POS-connected order must have a sales channel classification.

The system must distinguish:

* Platform prepaid smart order
* In-store POS order
* Table order
* Waiting preorder
* Manual POS entry
* Service order
* Unpaid order
* House account
* External delivery or third-party channel, if applicable

### 5.2 Payment Collector Must Be Explicit Rule

Every payment component must identify who collected the money.

Possible collectors include:

* Platform PG
* Store VAN
* Store cash
* Store coupon
* Store point system
* Franchise account
* Manual house account
* No payment collected

### 5.3 No Duplicate Sales Reporting Rule

The same customer payment must not be counted once as platform PG sales and again as store VAN/POS card sales unless it truly represents separate payment components.

The Gateway must preserve channel and payment component identity.

### 5.4 Unpaid Normal Order Rule

An order without immediate payment may still be a valid operational order.

The system must not treat every unpaid POS order as an error.

Unpaid order types must be explicitly classified and reconciled.

### 5.5 Tax Evidence Rule

Sales, refunds, discounts, coupons, points, service orders, and unpaid orders must preserve enough evidence for later tax and accounting classification.

The Gateway must not rely only on display totals.

## 6. Sales Channel Classification

Allowed sales channel categories include:

```
PLATFORM_PREPAID
PLATFORM_POSTPAID
WAITING_PREORDER
TABLE_ORDER
IN_STORE_POS
MANUAL_POS_ENTRY
SERVICE_ORDER
HOUSE_ACCOUNT
UNPAID_ORDER
STAFF_MEAL
OWNER_COMP
CUSTOMER_COMPENSATION
FRANCHISE_PROMOTION
THIRD_PARTY_CHANNEL
UNKNOWN_CHANNEL
```

Each provider integration must map POS-native channel codes into normalized channel categories.

## 7. Payment Collector Classification

Allowed payment collector categories include:

```
PLATFORM_PG
STORE_VAN
STORE_CASH
STORE_SIMPLE_PAY
STORE_COUPON
STORE_POINT
PLATFORM_POINT
PLATFORM_COUPON
FRANCHISE_CREDIT
HOUSE_ACCOUNT_LEDGER
NO_PAYMENT
MANUAL_ADJUSTMENT
UNKNOWN_COLLECTOR
```

Each payment component must preserve collector identity.

## 8. Payment Method Classification

Allowed payment method categories include:

```
CARD
CASH
SIMPLE_PAY
PLATFORM_WALLET
POINT
COUPON
VOUCHER
GIFT_CARD
HOUSE_ACCOUNT
SERVICE
ZERO_AMOUNT
MIXED_PAYMENT
UNKNOWN_METHOD
```

Payment method is not the same as payment collector.

For example, card payment may be collected through platform PG or store VAN.

## 9. Sales Record Types

The POS Gateway must distinguish sales record types.

Allowed record types include:

```
SALES_RECEIPT
PAYMENT_APPROVAL
PAYMENT_CAPTURE
VAN_APPROVAL
PG_APPROVAL
CASH_RECEIPT
VOID_RECEIPT
REFUND_RECEIPT
UNPAID_RECEIPT
SERVICE_RECEIPT
HOUSE_ACCOUNT_RECEIPT
MANUAL_ADJUSTMENT_RECEIPT
TAX_REPORTING_RECORD
SETTLEMENT_RECORD
```

Different record types may refer to the same customer order but must not be merged without policy.

## 10. Platform PG And POS Sales Mapping

For platform prepaid orders, the platform PG may collect money while POS records the sale for store operations.

The Gateway must preserve:

* Platform payment ID
* PG approval ID
* POS order ID
* POS receipt ID
* POS sales channel
* Payment collector
* Taxable sales amount
* Non-taxable amount
* Store settlement impact
* Franchise settlement impact

If the POS records a platform-paid order as ordinary store card sales, duplicate sales or tax confusion may occur.

The Gateway must map platform-paid orders to the correct POS sales channel where provider supports it.

## 11. Store VAN And Platform Order Mapping

For store-side payment, the POS/VAN may collect money while platform tracks the order journey.

The Gateway must preserve:

* Platform order ID
* POS receipt ID
* VAN approval ID
* POS payment method
* Store collector identity
* Platform order channel
* Settlement responsibility
* Reconciliation status

The platform must not claim PG payment for store VAN-collected orders.

## 12. Mixed PG And VAN Payment

A single order may include both platform PG payment and store VAN payment.

Examples:

* Prepaid deposit plus in-store balance
* Platform coupon plus store card payment
* Platform points plus POS card payment
* Waiting preorder paid partially online and completed at table
* Customer adds items after prepaid order and pays difference at POS

Mixed payment requires component-level reconciliation.

A mixed payment record should include:

```
payment_group_id
platform_order_id
component_id
component_collector
component_method
component_amount
component_tax_basis
approval_reference
receipt_reference
settlement_reference
refundable_flag
created_at
```

The system must avoid double-counting either component.

## 13. VAT And Tax Classification

Tax classification must distinguish:

* Taxable sales
* Tax-exempt sales
* VAT-inclusive amount
* VAT-exclusive amount
* VAT amount
* Discount before tax
* Discount after tax
* Coupon treatment
* Point treatment
* Service order treatment
* House account treatment
* Refund tax reversal
* Partial refund tax adjustment

Provider and tax rules may differ.

The Gateway must preserve source calculation and normalized classification.

## 14. Duplicate Taxation Risk

Duplicate taxation risk may occur when:

* Platform PG sale is also recorded as normal POS card sale
* POS receipt does not distinguish smart order channel
* VAN settlement includes store card payments but PG settlement is also counted
* Platform-paid orders are manually reentered as POS card sales
* Refund occurs in platform but not reflected in POS
* POS void occurs but PG payment remains captured
* Mixed payments are aggregated as full amount in both systems

The Gateway must classify and surface duplicate taxation risk.

Allowed risk states include:

```
NO_DUPLICATE_TAX_RISK
POSSIBLE_DUPLICATE_CHANNEL
POS_CHANNEL_UNMAPPED
PG_AND_VAN_BOTH_CAPTURED
REFUND_NOT_REFLECTED_IN_POS
POS_VOID_NOT_REFLECTED_IN_PG
MANUAL_REENTRY_TAX_RISK
MIXED_PAYMENT_RECONCILIATION_REQUIRED
TAX_REVIEW_REQUIRED
```

## 15. Unpaid Order Types

Unpaid orders must be classified.

Allowed unpaid categories include:

```
HOUSE_ACCOUNT
OWNER_APPROVED_CREDIT
STAFF_MEAL
SERVICE_RECOVERY
CUSTOMER_COMPENSATION
PROMOTIONAL_GIVEAWAY
PAY_LATER
CORPORATE_ACCOUNT
DELIVERY_PARTNER_SETTLED
FRANCHISE_INTERNAL_ACCOUNT
UNKNOWN_UNPAID
```

An unpaid order may be operationally valid.

But it must not be treated as paid, settled, or tax-cleared without policy.

## 16. Service And Zero-Amount Orders

Service or zero-amount orders may occur when:

* Owner gives free item
* Staff meal is recorded
* Customer complaint compensation
* Promotion gives full discount
* Test order
* Training order
* Waste or sample item
* Franchise event

The Gateway must distinguish operational kitchen execution from revenue collection.

A zero-amount order can still require kitchen, inventory, and audit handling.

## 17. House Account Handling

House account or ledger orders require explicit tracking.

A house account record should include:

```
house_account_id
customer_or_account_reference
store_id
platform_order_id
pos_receipt_id
amount
due_status
due_date
approved_by
reason_code
later_payment_reference
settlement_status
created_at
```

House account orders must not be lost because payment is not immediate.

## 18. Cash Receipt And Tax Evidence

In some flows, cash receipt or tax receipt issuance may matter.

The Gateway must preserve whether:

* Cash receipt was requested
* Cash receipt was issued
* Tax invoice or receipt applies
* POS generated tax evidence
* Platform generated tax evidence
* No tax evidence was required
* Tax evidence is pending

The exact legal/tax handling may require separate jurisdiction-specific policy, but the Gateway must preserve evidence.

## 19. Refund And Void Channel Alignment

Refund or void must occur in the correct system.

Examples:

* PG payment must be voided or refunded through PG
* Store VAN payment must be voided or refunded through POS/VAN
* Cash refund must be recorded manually
* Coupon or point restoration must happen in the correct ledger
* House account reversal must reduce outstanding balance

The Gateway must not mark a payment component reversed unless the correct collector or ledger reflects it.

## 20. Daily Reconciliation Dimensions

Daily reconciliation must compare:

* Platform order total by channel
* Platform PG payment total
* Platform PG refund total
* Store POS sales total
* Store POS smart order channel total
* Store VAN card total
* Store cash total
* Store unpaid total
* Store service total
* POS void total
* POS refund total
* Taxable sales total
* Tax amount
* Discount total
* Coupon total
* Point total
* House account balance movement
* Duplicate risk count
* Unmatched payment count

Totals alone are insufficient.

Mismatch cause classification is required.

## 21. Reconciliation Result Classification

Allowed reconciliation results include:

```
RECONCILED
RECONCILED_WITH_TOLERANCE
CHANNEL_MISMATCH
COLLECTOR_MISMATCH
TAX_MISMATCH
PG_MISSING_POS_RECEIPT
POS_MISSING_PG_PAYMENT
VAN_MISSING_PLATFORM_ORDER
UNPAID_ORDER_UNCLASSIFIED
SERVICE_ORDER_UNCLASSIFIED
DUPLICATE_SALES_RISK
REFUND_MISMATCH
VOID_MISMATCH
BUSINESS_DAY_MISMATCH
MANUAL_REVIEW_REQUIRED
UNKNOWN_RECONCILIATION_FAILURE
```

Each result must map to operator or finance review action.

## 22. Business Day And Settlement Date

Reconciliation must preserve multiple dates.

Required date contexts include:

```
platform_order_date
platform_payment_date
pos_business_date
pos_receipt_date
van_approval_date
pg_approval_date
pg_settlement_date
store_close_date
accounting_date
```

A late-night order may belong to different dates depending on channel.

The system must not aggregate solely by calendar date.

## 23. Provider Sales Channel Mapping

Each provider capability profile must declare whether POS supports:

* Sales channel code
* Smart order channel
* External order ID
* Payment collector distinction
* Unpaid order code
* Service order code
* House account
* Discount reason
* Tax breakdown
* Refund linkage
* VAN approval linkage
* Business day export
* Sales summary export

If unsupported, the provider must be marked with reconciliation limitations.

## 24. Manual Mapping And Operator Override

If provider channel mapping is incomplete, operator or finance users may need manual classification.

Manual override must record:

* Original classification
* New classification
* Reason code
* Actor
* Approval level
* Affected amount
* Affected tax category
* Related evidence
* Timestamp

Manual override must not delete original provider evidence.

## 25. Operator And Finance Console Requirements

The console must show:

* Channel mismatch
* Collector mismatch
* Duplicate taxation risk
* PG payment without POS receipt
* POS receipt without PG payment
* VAN payment without platform order
* Unclassified unpaid order
* Unclassified service order
* Refund mismatch
* Business day mismatch
* Tax mismatch
* Manual review queue
* Required evidence

Allowed actions may include:

```
CLASSIFY_UNPAID_ORDER
CLASSIFY_SERVICE_ORDER
MAP_SALES_CHANNEL
CONFIRM_PLATFORM_PG_SALE
CONFIRM_STORE_VAN_SALE
LINK_POS_RECEIPT
LINK_PG_PAYMENT
LINK_VAN_APPROVAL
MARK_DUPLICATE_RISK_RESOLVED
REQUEST_STORE_REVIEW
ESCALATE_FINANCE_REVIEW
APPLY_MANUAL_RECONCILIATION_WITH_REASON
```

All actions must be audited.

## 26. Customer-Facing Messaging

Customer-facing messages should remain payment-result oriented.

Examples:

```
Your payment has been completed.
Your payment was completed at the store.
This order will be paid at the store.
Your refund is being processed.
This order was handled by the store.
```

Customers must not see internal tax channel, VAN, PG, POS, or reconciliation classifications unless legally required in a receipt or transaction notice.

## 27. Audit Requirements

Every VAN, PG, sales channel, unpaid order, and reconciliation decision must preserve:

* Platform order ID
* Payment group ID
* Payment component ID
* Store ID
* Provider ID
* Sales channel
* Payment collector
* Payment method
* POS receipt ID
* PG approval reference
* VAN approval reference
* Cash receipt reference, if applicable
* House account reference, if applicable
* Amount
* Taxable amount
* Tax amount
* Discount amount
* Coupon amount
* Point amount
* Refund amount
* Void amount
* POS business date
* PG settlement date
* VAN approval date
* Reconciliation result
* Duplicate tax risk state
* Manual classification, if any
* Operator action, if any
* Finance review reference, if any
* Trace ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive payment and customer data must be redacted, tokenized, or encrypted according to the security runtime policy.

## 28. Test Requirements

Each provider and payment integration must test:

* Platform PG prepaid order mapped to POS smart order channel
* Store VAN payment linked to platform order
* Mixed PG and VAN payment
* Platform coupon plus POS payment
* Platform point plus POS payment
* POS receipt without PG payment
* PG payment without POS receipt
* Duplicate sales risk
* POS smart order channel unsupported
* VAT mismatch
* Refund through PG
* Refund through VAN/POS
* POS void without PG refund
* PG refund without POS void
* Unpaid order
* House account order
* Service order
* Staff meal or owner comp
* Business day mismatch
* Day-end reconciliation mismatch
* Manual finance classification
* Audit preservation for all channel and collector states

A provider cannot be production-ready without VAN, PG, sales channel, and unpaid order reconciliation test evidence.

## 29. Anti-Patterns

The following are prohibited:

* Treating PG payment and POS/VAN payment as the same collector
* Counting the same payment twice in sales totals
* Treating every unpaid POS order as error
* Treating every zero-amount order as canceled
* Losing house account orders because payment is not immediate
* Recording platform prepaid orders as ordinary store VAN card sales without channel mapping
* Refunding in one system while marking all systems refunded
* Reconciling only total amount without channel and collector identity
* Aggregating by calendar date only
* Deleting original provider evidence after manual finance override
* Hiding duplicate tax risk from finance review

## 30. Relationship With Other Documents

This policy depends on and supports:

```
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
05410 POS Waiting Entry NoShow And Prepaid Cancel Sync Policy
05430 POS Inventory Race Condition And Stock Hold Buffer Policy
```

This policy extends payment mismatch handling into real settlement, tax, VAN, PG, POS, unpaid, and service-order reconciliation.

## 31. Final Rule

The POS Gateway must always be able to explain who collected the money, which system recorded the sale, which channel the order belongs to, which tax basis applies, whether the order was paid or unpaid, and whether the transaction was reconciled without duplicate counting.

If platform PG sales, store VAN sales, POS receipts, unpaid orders, and tax records cannot be separated and reconciled, the sales channel and settlement integrity boundary has failed.
