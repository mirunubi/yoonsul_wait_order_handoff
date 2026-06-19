# 070140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md

## 1. Purpose

This policy defines the mandatory validation process for matching external payment approval responses against the internal order, pricing, tax, discount, service charge, and payment intent records.

The purpose of this document is to prevent financial integrity failures where an external POS, VAN, PG, quick payment provider, card acquirer, or payment adapter returns a successful payment response that does not exactly match the internally authorized order state.

External payment success alone is not sufficient to confirm an order or payment. A payment may only be confirmed after the internal validation gate verifies that the external response matches the internal canonical payment intent.

## 2. Scope

This policy applies to all external payment integrations under the 70000 External Integration Control Plane, including:

- POS payment responses
- VAN approval and cancellation responses
- PG confirm and webhook responses
- simple payment providers such as KakaoPay, NaverPay, TossPay, Samsung Pay routing responses, Alipay, and WeChat Pay
- card company or acquirer approval data
- refund, reversal, and cancellation responses
- settlement and deposit reconciliation files when they are used to validate prior approvals
- kiosk vendor payment handoff responses
- external order app payment confirmation callbacks

This policy does not replace provider-specific adapter implementation documents. Provider-specific adapters must map their payloads into the canonical fields defined by `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`.

## 3. Governance Position

External payment systems are treated as external event sources, not final state authorities.

The system shall separate:

1. the internal payment intent,
2. the external payment request,
3. the raw external response,
4. the canonical interpreted response,
5. the internal validation decision,
6. the final order/payment state transition.

The final payment state authority belongs to the internal Payment Integrity Control Plane, not to POS, VAN, PG, kiosk software, or any external provider response flag.

## 4. Core Principle

A payment response may be marked as confirmed only when all required match conditions pass.

The following shortcut is prohibited:

```text
external_response.success = true
→ order.status = PAID
```

The required flow is:

```text
payment_intent created
→ external payment request sent
→ external response received
→ raw response preserved
→ canonical response mapped
→ amount/tax/discount/service/order validation executed
→ validation decision recorded
→ payment state transition approved or blocked
```

## 5. Canonical Records Used for Validation

The validation gate shall compare the external response against the following internal canonical records:

| Record | Role |
|---|---|
| Order Ledger | Canonical ordered items, quantities, options, table, customer group, and order ownership |
| Pricing Snapshot | Price values frozen at payment intent creation time |
| Tax Snapshot | VAT, tax-exempt amount, taxable amount, and rounding state |
| Discount Snapshot | Coupon, membership, promotion, manager discount, and split discount application |
| Service Charge Snapshot | service fee, tip, table charge, packaging fee, delivery fee, or other applied charges |
| Payment Intent Ledger | expected payment amount, provider route, terminal, store, currency, idempotency key |
| External Response Ledger | raw payload, approval number, response code, trace ID, approved amount, receipt data |
| Validation Decision Ledger | pass/fail/hold reason, rule version, validator identity, timestamp |

## 6. Mandatory Match Dimensions

The validation gate shall check at least the following dimensions before payment confirmation.

### 6.1 Order Match

The external response must match the internal order context.

Required checks:

- order ID or mapped external order reference matches the payment intent
- store ID matches the payment intent
- table ID or service channel matches where applicable
- payment intent ID or idempotency key matches the original request
- terminal ID matches an allowed terminal for the store
- POS provider and VAN/PG route match the selected payment route
- response time falls within the allowed request window unless recovered by inquiry

If the response cannot be linked to a valid payment intent, it shall be classified as `UNMATCHED_EXTERNAL_PAYMENT_RESPONSE`.

### 6.2 Amount Match

The approved amount from the external response must match the expected payable amount from the payment intent.

Required checks:

- gross order amount
- item subtotal
- discount total
- tax amount
- service charge amount
- delivery or packaging charge where applicable
- final payable amount
- split payment amount if the order is divided
- currency code
- rounding policy

The default tolerance for KRW payment confirmation is zero won.

Any amount mismatch shall block automatic confirmation unless a formally approved provider-specific rounding exception exists.

### 6.3 Tax Match

The external response and internal order shall not create tax ambiguity.

Required checks:

- taxable amount
- VAT amount
- tax-exempt amount
- zero-rated or exempt category where applicable
- provider-provided tax value, if available
- receipt tax breakdown, if available

If the provider does not return tax details, the system shall preserve the internal tax snapshot and mark the response as `TAX_DETAIL_NOT_PROVIDED_BY_PROVIDER` while still requiring final amount match.

### 6.4 Discount Match

Discounts must be frozen before payment intent creation.

Required checks:

- coupon ID and coupon amount
- membership discount amount
- promotion campaign ID
- staff or manager discount approval ID
- external membership discount provider reference
- per-item discount distribution, if relevant to tax calculation
- duplicate discount prevention

Any post-intent discount mutation shall require payment intent cancellation and recreation unless explicitly handled by a controlled adjustment workflow.

### 6.5 Service Charge Match

Service charge and additional fees must be included in the expected amount and must be validated separately from item price.

Required checks:

- table service charge
- tip
- packaging fee
- delivery fee
- platform fee
- late-night or special operation charge
- foreign payment surcharge, if applicable and legally allowed

Service charge mismatch shall be treated as an amount mismatch and shall block automatic payment confirmation.

### 6.6 Split Payment Match

For 1/N payment, group payment, partial payment, roulette payment, or multiple payer flows, the validation gate shall validate each payment segment.

Required checks:

- payer segment ID
- expected segment amount
- approved segment amount
- remaining unpaid amount
- duplicate segment payment prevention
- segment cancellation or refund status
- final group order payment completion condition

An order shall not become fully paid until all required payment segments are confirmed or a manager-approved exception is recorded.

### 6.7 Cancellation and Refund Match

Cancellation and refund responses shall be validated against the original approval.

Required checks:

- original approval number
- original payment transaction ID
- cancellation amount
- partial cancellation amount
- remaining approved balance
- cancellation response code
- cancellation trace ID
- cancellation receipt or slip data
- cancellation time

A cancellation timeout shall not be treated as cancellation failure or success without inquiry. It shall be moved to `CANCEL_UNKNOWN` or `REVERSAL_PENDING` until verified.

## 7. Validation Decision Codes

The system shall record an explicit validation decision for every external payment response.

| Decision Code | Meaning | Default Action |
|---|---|---|
| `VALIDATION_PASSED` | All mandatory checks passed | Allow confirmation |
| `AMOUNT_MISMATCH` | Approved amount differs from expected amount | Block confirmation |
| `ORDER_MISMATCH` | Response does not match expected order/payment intent | Block confirmation |
| `STORE_OR_TERMINAL_MISMATCH` | Store, terminal, or provider route does not match | Block and raise security/operation alert |
| `TAX_MISMATCH` | Tax values conflict with internal tax snapshot | Block or hold depending on severity |
| `DISCOUNT_MISMATCH` | Discount state differs from frozen payment intent | Block confirmation |
| `SERVICE_CHARGE_MISMATCH` | Additional charge values differ | Block confirmation |
| `DUPLICATE_APPROVAL_DETECTED` | Duplicate approval exists for same order or payment segment | Block and initiate duplicate handling |
| `LATE_RESPONSE_RECEIVED` | Response arrived outside normal time window | Hold and perform inquiry/reconciliation |
| `UNMATCHED_EXTERNAL_PAYMENT_RESPONSE` | Response cannot be mapped to payment intent | Hold and escalate |
| `PROVIDER_FIELD_MISSING` | Required provider field is missing | Hold or block depending on field |
| `RAW_PAYLOAD_PARSE_ERROR` | Response cannot be safely mapped | Hold and preserve raw payload |
| `VALIDATION_RULE_EXCEPTION_APPROVED` | Exception approved by governed rule | Allow only with audit evidence |

## 8. Payment State Transition Rules

The following transition rule is mandatory:

```text
External success response
+ validation passed
= payment may transition to CONFIRMED
```

The following transitions are prohibited:

```text
External success response
+ amount mismatch
= CONFIRMED
```

```text
External timeout
= FAILED
```

```text
Provider response code unknown
= CONFIRMED
```

Ambiguous states shall move to controlled states such as:

- `TIMEOUT_UNKNOWN`
- `PAYMENT_AMBIGUOUS`
- `VALIDATION_HOLD`
- `MANUAL_REVIEW_REQUIRED`
- `INQUIRY_REQUIRED`
- `REVERSAL_PENDING`
- `RECONCILIATION_EXCEPTION`

## 9. Inquiry Requirement

When validation cannot determine payment status, the system shall attempt provider inquiry before final classification whenever the provider contract supports it.

Inquiry targets may include:

- transaction ID
- approval number
- terminal ID
- merchant ID
- order reference
- payment intent ID
- trace ID
- request time window
- amount
- last transaction lookup

If provider inquiry is unavailable, that limitation shall be recorded as a vendor readiness risk and may block production approval for high-risk payment routes.

## 10. Correction and Compensation

When mismatch is detected, correction shall not be performed by silently editing the order or payment amount.

Allowed correction patterns include:

- inquiry-based confirmation
- order regeneration with preserved payment evidence
- approval cancellation
- partial cancellation
- refund workflow
- manager-approved exception
- customer claim workflow
- reconciliation exception handling
- accounting adjustment with audit approval

The original raw response and original internal intent shall remain immutable. Corrections shall be appended as separate ledger events.

## 11. Logging and Evidence Requirements

Every validation attempt shall preserve the following:

- payment intent ID
- external provider route
- raw request hash
- raw response hash
- canonical response mapping version
- validation rule version
- compared expected amount
- compared approved amount
- tax comparison result
- discount comparison result
- service charge comparison result
- order match result
- terminal and store match result
- final validation decision
- validator service identity
- created timestamp
- exception approver, if any
- inquiry result, if any
- compensation action, if any

Logs must be tamper-evident and linked to audit and reconciliation documents under the 70000 External Integration Control Plane.

## 12. Operator and Manager Handling

Store operators shall not manually mark a payment as paid solely because a customer shows a banking app, card notification, or simple payment app success screen.

Allowed operator actions:

- check internal payment status
- request payment inquiry through manager console
- reprint or fetch provider receipt when supported
- place order in payment review hold
- call manager for override workflow
- issue customer-facing pending-status explanation

Manager override requires:

- role authorization
- reason code
- evidence attachment
- customer claim record if applicable
- linkage to reconciliation follow-up
- automatic audit event generation

## 13. Provider Certification Requirement

External providers shall be evaluated for their ability to support this validation policy.

Required provider capabilities:

- stable transaction identifier
- approval number or equivalent reference
- response code table
- cancellation reference
- inquiry API or operational lookup process
- receipt/slip evidence retrieval
- settlement export
- test sandbox or certification environment
- documented timeout behavior
- documented duplicate request handling
- documented reversal/cancel behavior

A provider that cannot support sufficient validation or inquiry shall be classified as restricted, pilot-only, or not approved for production depending on payment risk.

## 14. Relationship to Other Documents

This policy depends on:

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`
- `70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md`
- `70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md`
- `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`

This policy hands off to:

- `70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md`
- `70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md`
- `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`
- `70180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md`

## 15. Closeout Criteria

This policy is complete when:

- payment intent and external response records are separated;
- external success responses cannot directly confirm payment without validation;
- amount, tax, discount, service charge, order, store, terminal, and trace validation are defined;
- mismatch states and validation decision codes are defined;
- ambiguous outcomes are routed to inquiry or manual review;
- correction is append-only and audit-linked;
- provider certification requirements include field, inquiry, receipt, and settlement support;
- downstream timeout, recovery, audit, and failure-mode documents are linked.
