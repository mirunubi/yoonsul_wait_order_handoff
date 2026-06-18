# 014010_Policy_POS_Payment_Tax_Discount_And_Reconciliation_Mismatch

## 1. Purpose

This policy defines how the POS Gateway must handle payment, tax, discount, promotion, service charge, refund, void, and reconciliation mismatches between the platform, payment gateway, and external POS provider.

The purpose is to prevent money-related inconsistencies from contaminating the core order, payment, settlement, accounting, and audit domains.

The POS Gateway must treat payment and reconciliation mismatch as a controlled exception category, not as a generic POS error.

## 2. Scope

This policy applies to:

* Platform-calculated order amount
* POS-calculated order amount
* PG-approved payment amount
* Split payment
* Prepaid and on-site payment combination
* POS-side discount
* Platform-side promotion
* Coupon and point usage
* Tax and VAT rounding
* Service charge and tip handling
* Order cancellation
* Payment void
* Refund
* Partial refund
* Daily sales reconciliation
* Provider settlement mismatch
* Audit evidence for all money transitions

This policy applies to all POS-connected payment flows, including direct payment, preorder payment, table order payment, manual-assisted payment, and degraded POS integration paths.

## 3. Core Principle

Money state must be reconciled before it is trusted.

The platform must not assume that its calculated amount, the POS calculated amount, and the PG approved amount are automatically identical.

The POS Gateway must explicitly compare, classify, and preserve evidence for every money-related mismatch.

No payment mismatch may be silently corrected without audit evidence and policy authorization.

## 4. Money State Boundary

Payment-related facts may exist in multiple systems.

```
[Platform Order And Payment Domain]
               |
               v
[POS Gateway Payment Validation Layer]
               |
    -------------------------------
    |                             |
    v                             v
[Payment Gateway]            [External POS Provider]
```

Each system may calculate or record:

* Item amount
* Option amount
* Discount amount
* Coupon amount
* Point amount
* Tax amount
* Service charge
* Tip
* Payment approval amount
* Refund amount
* Sales receipt amount
* Settlement amount

The Gateway must not collapse these into one assumed truth without reconciliation.

## 5. Non-Negotiable Rules

### 5.1 Payment Must Not Approve Unsafe Amount Rule

If the platform amount and POS validation amount differ beyond the allowed tolerance, payment approval must be blocked or moved to a controlled exception flow.

The Gateway must not approve a payment simply because the customer clicked pay.

### 5.2 PG Amount Must Match Authorized Order Rule

The amount sent to the payment gateway must match the authorized platform order amount.

If the POS requires a different amount, the order must be recalculated, revalidated, confirmed, or blocked before approval.

### 5.3 No Silent Discount Absorption Rule

If a POS-side discount or promotion changes the final amount, the platform must not silently absorb the difference.

The system must classify whether the POS discount is:

* Allowed
* Store-authorized
* Platform-authorized
* Unknown
* Prohibited
* Manual adjustment

### 5.4 Split Payment Explicitness Rule

Split payment must be modeled explicitly.

The platform must not treat prepaid amount, on-site POS payment amount, points, coupons, and manual cash/card adjustments as one ambiguous payment.

### 5.5 Reconciliation Evidence Rule

Every monetary transition must leave enough evidence to reconstruct:

* Who calculated the amount
* Which system approved the amount
* Which system recorded the sale
* Which system settled the payment
* Why any mismatch was accepted, blocked, adjusted, voided, or refunded

## 6. Payment Actors

The policy recognizes the following payment actors:

* Platform core order domain
* POS Gateway
* External POS provider
* Payment gateway
* Store operator
* Customer
* Settlement system
* Accounting system
* Audit system

Each actor may generate different financial facts.

The Gateway must preserve actor identity in financial audit events.

## 7. Amount Components

The Gateway must compare amount components where available.

Required components include:

* Base item amount
* Option amount
* Quantity amount
* Subtotal
* Platform discount
* POS discount
* Coupon amount
* Point amount
* Taxable amount
* Tax amount
* Tax-exempt amount
* Service charge
* Tip
* Final payable amount
* Approved PG amount
* POS receipt amount
* Refund amount
* Void amount

If a provider cannot expose component-level detail, the provider capability profile must mark this limitation.

## 8. Payment Flow Types

### 8.1 Full Prepayment Flow

The customer pays through the platform before the order is submitted to the POS.

Required safeguards:

* Menu and price validation before payment
* Sold-out validation before payment, where available
* PG approval amount equals platform authorized amount
* POS submission amount equals approved amount
* POS receipt amount reconciles with PG amount

### 8.2 Postpaid POS Payment Flow

The order is submitted to POS and payment is completed at the store.

Required safeguards:

* Platform order amount is treated as expected amount
* POS final payment is treated as store-side execution amount
* Differences must be reconciled after payment
* Platform must not claim PG payment if no PG approval exists

### 8.3 Split Payment Flow

Part of the order is paid through the platform and the rest is paid at the store.

Examples:

* Prepaid deposit plus on-site balance
* Platform points plus store card payment
* Platform coupon plus POS payment
* Group order partial payer split

Required safeguards:

* Each payment component must have its own payment identity
* POS receipt must reflect the correct payment composition where supported
* Settlement must avoid double counting
* Refund must know which component to reverse

### 8.4 Manual-Assisted Payment Flow

The store operator manually enters or adjusts payment in POS.

This mode is degraded.

Required safeguards:

* Manual operator identity
* Reason code
* Amount before adjustment
* Amount after adjustment
* Customer impact
* Audit event
* Reconciliation review flag

### 8.5 Failed Or Reversed Payment Flow

If payment is approved but POS submission fails, or POS accepts then cancellation occurs, the Gateway must route the case through void, refund, retry, or manual review according to controlled policy.

## 9. Discount And Promotion Conflict

Discounts may originate from:

* Platform coupon
* Platform membership benefit
* Platform campaign
* Store POS discount button
* POS set menu discount
* Staff manual discount
* Franchise promotion
* Third-party voucher
* Point redemption
* Service recovery compensation

The Gateway must classify discount authority.

Allowed classifications:

```
PLATFORM_AUTHORIZED
STORE_AUTHORIZED
POS_NATIVE
FRANCHISE_AUTHORIZED
MANUAL_RECOVERY
CUSTOMER_COMPENSATION
UNKNOWN_DISCOUNT
PROHIBITED_DISCOUNT
```

Unknown or prohibited discount must not silently alter settlement records.

## 10. Tax And VAT Rounding Policy

Different systems may calculate VAT differently.

Examples:

* Item-level rounding
* Order-level rounding
* Taxable subtotal rounding
* Inclusive VAT calculation
* Exclusive VAT calculation
* Discount-before-tax
* Discount-after-tax
* Service-charge-taxable
* Service-charge-nontaxable

The Gateway must record the tax calculation method when available.

Minor differences caused by documented rounding rules may be classified as allowed tolerance.

Undocumented or repeated tax mismatch must be classified as reconciliation risk.

## 11. Tolerance Policy

The Gateway must define tolerance levels.

Example tolerance categories:

```
EXACT_MATCH
ROUNDING_TOLERANCE
SMALL_TAX_DIFFERENCE
PROVIDER_DOCUMENTED_TOLERANCE
STORE_MANUAL_ADJUSTMENT
MATERIAL_MISMATCH
BLOCKING_MISMATCH
```

Tolerance must be configured by provider, store, and payment type where necessary.

A tolerance allowance must never become a blanket permission to ignore mismatch.

## 12. Payment Mismatch Categories

The Gateway must classify payment mismatches.

Categories include:

```
ITEM_PRICE_MISMATCH
OPTION_PRICE_MISMATCH
DISCOUNT_MISMATCH
COUPON_MISMATCH
POINT_MISMATCH
TAX_MISMATCH
SERVICE_CHARGE_MISMATCH
TIP_MISMATCH
SPLIT_PAYMENT_MISMATCH
PG_APPROVAL_MISMATCH
POS_RECEIPT_MISMATCH
REFUND_MISMATCH
VOID_MISMATCH
SETTLEMENT_MISMATCH
UNKNOWN_MONEY_MISMATCH
```

Each category must map to a decision outcome.

## 13. Decision Outcomes

The Gateway may choose one of the following outcomes:

```
ALLOW
ALLOW_WITH_AUDIT_TOLERANCE
BLOCK_PAYMENT
REQUIRE_RECALCULATION
REQUIRE_CUSTOMER_CONFIRMATION
REQUIRE_OPERATOR_CONFIRMATION
QUEUE_FOR_REVIEW
VOID_PAYMENT
REFUND_PAYMENT
PARTIAL_REFUND
RECONCILE_AT_DAY_END
MARK_PROVIDER_RISK
ESCALATE_TO_FINANCE_REVIEW
```

The decision must be visible in audit and, where relevant, operator console.

## 14. Pre-Approval Amount Validation

Before PG approval, the Gateway must validate:

* Core calculated amount
* POS validated amount, if available
* Coupon and point usage
* Tax calculation
* Discount authority
* Final payable amount
* Idempotency key
* Customer confirmation amount

If validation fails, PG approval must not be requested.

## 15. Post-Approval POS Submission Mismatch

If PG approval succeeds but POS submission returns a different amount or rejects the order, the Gateway must not mark the order as safely completed.

Allowed actions include:

* Void PG payment before capture, if possible
* Refund payment
* Retry POS submission if safe
* Queue for manual review
* Notify store operator
* Notify customer
* Mark order as payment-approved but POS-unaccepted
* Prevent kitchen fulfillment until resolved

## 16. POS-Side Discount After Submission

If store staff applies a POS discount after the platform order is submitted, the Gateway must classify the event.

Possible outcomes:

* Accept as store-authorized adjustment
* Require manager approval
* Mark as reconciliation difference
* Adjust platform settlement record with audit
* Reject if provider supports blocking
* Escalate to finance review

The platform must avoid double-counting the original amount and discounted POS amount.

## 17. Split Payment Handling

Split payment must preserve component identities.

A split payment record should include:

```
payment_group_id
platform_order_id
component_type
payment_method
amount
actor
approval_reference
provider_receipt_reference
settlement_reference
refundable_flag
created_at
```

Component types may include:

```
PLATFORM_CARD
PLATFORM_SIMPLE_PAY
PLATFORM_POINT
PLATFORM_COUPON
POS_CARD
POS_CASH
POS_VOUCHER
POS_POINT
MANUAL_ADJUSTMENT
```

The system must know exactly which component should be voided or refunded.

## 18. Refund And Void Rules

Refund and void rules must consider:

* Whether PG payment was approved
* Whether PG payment was captured
* Whether POS receipt was created
* Whether kitchen fulfillment started
* Whether customer received goods
* Whether payment was split
* Whether coupon or point was used
* Whether provider supports refund sync
* Whether manual store action is required

Refund evidence must include:

* Original payment reference
* Refund request reference
* Refund approval reference
* POS refund or void reference
* Actor
* Reason code
* Amount
* Timestamp
* Customer notification status

## 19. Daily Reconciliation

At day end, the system must reconcile:

* Platform order total
* Platform payment total
* PG approval total
* PG capture total
* PG refund total
* POS sales total
* POS discount total
* POS tax total
* POS void total
* POS refund total
* Expected settlement amount
* Actual settlement amount

Reconciliation differences must be classified by cause, not merely counted.

## 20. Business Day Relationship

Payment reconciliation must respect POS business day boundaries.

For stores operating after midnight, the order date, payment approval date, POS business date, and settlement date may differ.

The Gateway must preserve all relevant dates:

```
platform_order_date
platform_payment_date
pos_business_date
pos_receipt_date
pg_settlement_date
accounting_date
```

The platform must not assume calendar date equals POS business date.

## 21. Audit Requirements

Every payment and reconciliation decision must preserve:

* Platform order ID
* Payment ID
* Payment group ID, if split
* Store ID
* Provider ID
* Customer-facing amount
* Platform calculated amount
* POS calculated amount
* PG approved amount
* POS receipt amount
* Discount details
* Tax details
* Coupon and point details
* Mismatch category
* Tolerance category
* Decision outcome
* Actor
* Reason code
* Provider payload reference
* PG payload reference
* Trace ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive payment data must be redacted, tokenized, or encrypted according to the security runtime policy.

## 22. Operator Console Requirements

The operator console must distinguish:

* Payment blocked before approval
* POS amount mismatch
* PG approval mismatch
* POS receipt mismatch
* Split payment mismatch
* Discount authority problem
* Tax rounding difference
* Refund pending
* Void pending
* Finance review required
* Day-end reconciliation mismatch

The console must show what action is allowed and who is authorized to perform it.

## 23. Customer-Facing Messaging

Customer-facing messages must be clear and non-technical.

Examples:

```
The final amount changed and needs confirmation.
This payment was not completed.
The store could not confirm this order. Your payment will be canceled.
A refund is being processed for this order.
The store is reviewing this payment.
```

Customer-facing messages must not expose POS provider errors, internal audit data, raw payloads, or tax calculation internals.

## 24. Test Requirements

Each provider integration must test:

* Exact amount match
* Minor rounding tolerance
* Blocking amount mismatch
* POS price changed before payment
* POS discount after submission
* Platform coupon applied
* Platform point used
* Split payment
* PG approval then POS rejection
* POS acceptance then refund
* Partial refund
* Void before capture
* Tax rounding mismatch
* Day-end reconciliation mismatch
* Business day crossing midnight
* Manual operator adjustment
* Audit preservation for all money states

A provider cannot be production-ready without money mismatch test evidence.

## 25. Anti-Patterns

The following are prohibited:

* Approving payment before required amount validation
* Treating POS amount and platform amount as automatically identical
* Silently changing platform amount to match POS
* Silently changing POS amount to match platform
* Double-counting prepaid and POS-paid amounts
* Losing component identity in split payment
* Treating all tax differences as harmless
* Ignoring POS-side manual discounts
* Marking payment complete when POS order was rejected
* Refunding without linking to the original payment component
* Reconciling only totals without mismatch cause classification

## 26. Relationship With Other Documents

This policy depends on and supports:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05320 POS Menu Hierarchy Option Transformer Policy
05330 POS Master Data Sync And Precheck Validation Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Payment mismatch handling is one of the highest-risk boundaries in POS integration.

## 27. Final Rule

The POS Gateway must be able to explain every won of difference between platform amount, POS amount, PG amount, refund amount, and settlement amount.

If the system cannot reconstruct why money moved, who approved it, which system recorded it, and how it was reconciled, the payment integrity boundary has failed.
