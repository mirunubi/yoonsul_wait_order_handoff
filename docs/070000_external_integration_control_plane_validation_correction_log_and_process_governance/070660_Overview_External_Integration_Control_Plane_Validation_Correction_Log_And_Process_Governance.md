# 070660_Overview_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md

## 1. Document Purpose

This document opens the `70000 External Integration Control Plane` lane for `yoonsul_wait_order_handoff`.

The purpose of this lane is to define the process layer that receives, validates, corrects, logs, reconciles, and recovers all data moving between the Yoonsul/Catch & Order platform and external providers.

This lane is not a simple POS Gateway implementation lane. It is the external integration integrity control lane.

The system must assume that every external system may return delayed, duplicated, incomplete, inconsistent, reversed, corrected, or provider-specific data. Therefore, the platform must not directly trust external responses. Every external request, response, callback, settlement file, status inquiry, and correction event must pass through a controlled validation and evidence process before it can affect the internal order, payment, customer, membership, settlement, accounting, or audit ledger.

## 2. Core Separation Principle

The platform separates two different defense lines.

### 2.1 POS Sandbox Defense

The POS sandbox exists to prevent technical contamination.

It controls:

- external process isolation
- local daemon containment
- POS adapter permission limitation
- malicious or unstable vendor module containment
- infection propagation prevention
- unauthorized local resource access prevention
- uncontrolled external SDK behavior blocking

The POS sandbox protects the system from being technically polluted by external POS, VAN daemon, kiosk, payment module, or vendor runtime behavior.

### 2.2 External Integrity Control Defense

The External Integration Control Plane exists to prevent financial, operational, settlement, and customer-impacting data accidents.

It controls:

- request and response separation
- inbound response validation
- raw payload preservation
- response field registry
- amount, tax, discount, service charge, currency, and order matching
- timeout and unknown-state handling
- inquiry-based recovery
- cancellation, reversal, refund, and compensation flow
- settlement and deposit reconciliation
- webhook and callback idempotency
- delivery app order-state correction
- external membership and coupon validation
- tax/accounting file integrity
- customer claim evidence
- vendor responsibility boundary
- audit trail immutability

The sandbox prevents infection. The External Integration Control Plane prevents money, order, settlement, customer, and accounting accidents.

## 3. External Integration Scope

The `70000` lane covers every external system whose data can affect internal state.

### 3.1 Payment And Financial Providers

- POS providers
- VAN providers
- PG providers
- card companies
- acquiring companies
- simple payment providers
- Alipay
- WeChat Pay
- global payment gateways
- cross-border payment settlement partners
- bank transfer providers
- virtual account providers
- refund and cancellation processors
- settlement file providers
- fee calculation providers

### 3.2 Store Operation Providers

- kiosk vendors
- mini kiosk vendors
- KDS vendors
- kitchen printer vendors
- order display providers
- table-order device providers
- waiting display providers
- store operation device vendors

### 3.3 Order And Channel Providers

- external order apps
- delivery apps
- pickup order apps
- reservation platforms
- waiting platforms
- marketplace order channels
- franchise channel aggregators

### 3.4 Customer And Commercial Providers

- external membership providers
- coupon providers
- point providers
- gift-card providers
- voucher providers
- promotion platforms
- CRM providers
- customer identity or phone-verification providers

### 3.5 Accounting, Tax, And Backoffice Providers

- tax invoice systems
- cash receipt providers
- accounting systems
- ERP systems
- payroll-linked sales allocation systems
- franchise royalty settlement systems
- revenue share processors
- bank deposit reconciliation feeds
- tax agency export processors

## 4. External Integration Control Plane Mission

The mission of this lane is to ensure that every external integration event is processed through the following mandatory chain.

```text
1. External request intent creation
2. Outbound request registration
3. Provider adapter transmission
4. Inbound response or callback capture
5. Raw payload preservation
6. Field normalization
7. Validation against internal source of truth
8. State transition decision
9. Correction, compensation, inquiry, or manual review when needed
10. Evidence log creation
11. Reconciliation against provider settlement or channel files
12. Audit trail retention and closeout
```

No external response may directly update a final internal ledger without passing through this chain.

## 5. Internal Source Of Truth Rule

External providers are not the source of truth for internal business meaning.

The platform must treat external data as evidence, not as an immediate command.

The internal source of truth remains:

- internal order ledger
- internal payment intent ledger
- internal customer action ledger
- internal store operation ledger
- internal membership and coupon decision ledger
- internal settlement ledger
- internal accounting handoff ledger
- internal audit ledger

External provider data becomes authoritative only after it is validated, matched, normalized, and recorded as accepted evidence.

## 6. Required Ledger Separation

Every external integration must separate at least the following ledgers.

| Ledger | Purpose |
|---|---|
| Intent Ledger | Records what the platform intended to request before calling an external provider. |
| Outbound Request Ledger | Records what was actually sent to the provider or adapter. |
| Inbound Raw Response Ledger | Records what was returned by the provider before interpretation. |
| Normalized Response Ledger | Records provider-specific fields converted into internal canonical fields. |
| Validation Result Ledger | Records pass, fail, mismatch, ambiguous, duplicate, stale, or manual-review result. |
| State Transition Ledger | Records the approved internal state change caused by the validated event. |
| Correction Ledger | Records inquiry, reversal, refund, re-sync, replay, or manual correction action. |
| Reconciliation Ledger | Records comparison against settlement, deposit, order-channel, or accounting files. |
| Audit Evidence Ledger | Records immutable evidence, hashes, operator actions, and legal/audit retention metadata. |

This separation is mandatory because a single external API result cannot be trusted to represent the final business state.

## 7. Canonical External Event States

All external integration events must be classified into canonical states.

```text
INTENT_CREATED
REQUEST_REGISTERED
REQUEST_SENT
PROVIDER_ACCEPTED
RESPONSE_RECEIVED
CALLBACK_RECEIVED
RAW_PAYLOAD_CAPTURED
NORMALIZATION_PENDING
VALIDATION_PENDING
VALIDATED_ACCEPTED
VALIDATED_REJECTED
MISMATCH_DETECTED
DUPLICATE_DETECTED
STALE_RESPONSE_DETECTED
TIMEOUT_UNKNOWN
INQUIRY_REQUIRED
INQUIRY_SENT
INQUIRY_CONFIRMED
INQUIRY_UNRESOLVED
COMPENSATION_REQUIRED
REVERSAL_PENDING
CANCEL_PENDING
REFUND_PENDING
MANUAL_REVIEW_REQUIRED
MANUAL_OVERRIDE_APPLIED
RECONCILIATION_PENDING
RECONCILIATION_EXCEPTION
RECONCILED
AUDIT_CLOSED
```

The system must not collapse timeout, no-response, rejected response, provider delay, duplicate callback, and validation mismatch into a single failure state.

Unknown state is a formal state, not an error message.

## 8. Validation Categories

Each integration category must define its own validation rules. However, all providers must pass the following common gates.

### 8.1 Identity Validation

- provider identity
- provider environment
- merchant identity
- store identity
- terminal identity
- channel identity
- customer identity where applicable
- order identity
- payment intent identity
- external transaction identity
- callback signature identity

### 8.2 Amount And Commercial Validation

- order amount
- payment amount
- tax amount
- discount amount
- service charge
- tip amount where applicable
- delivery fee
- packaging fee
- coupon amount
- membership point amount
- refund amount
- cancellation amount
- currency
- exchange-rate metadata for cross-border payment

### 8.3 State Validation

- allowed previous state
- allowed next state
- duplicate transition prevention
- stale response prevention
- out-of-order event prevention
- provider retry event classification
- internal order lifecycle compatibility
- settlement lifecycle compatibility

### 8.4 Technical Validation

- idempotency key
- request hash
- response hash
- raw payload hash
- signature
- timestamp
- nonce where applicable
- retry count
- correlation id
- trace id
- adapter version
- schema version

### 8.5 Evidence Validation

- approval number
- cancellation number
- receipt number
- slip text or receipt URL
- VAN trace id
- PG transaction id
- card/acquirer metadata
- provider status code
- provider response message
- settlement batch id
- deposit reference id
- operator action id

## 9. Process Pattern For Payment Providers

Payment providers must use a strict intent-response-confirmation model.

```text
1. Create payment intent internally.
2. Register outbound payment request.
3. Send request to POS, VAN, PG, or simple-payment adapter.
4. Capture raw response or callback.
5. Normalize provider-specific fields.
6. Validate amount, order, store, terminal, approval number, response code, and trace id.
7. If valid, confirm internal payment state.
8. If timeout or unclear, move to TIMEOUT_UNKNOWN and perform inquiry.
9. If mismatch, move to MISMATCH_DETECTED and block order finalization.
10. If payment succeeded but order failed, initiate compensation or manual recovery.
11. Reconcile against settlement and deposit data.
12. Close audit only after reconciliation.
```

Payment success is not final until validation and reconciliation requirements are satisfied according to the risk level of the payment method.

## 10. Process Pattern For Delivery And External Order Apps

External order apps must use an order-event normalization and correction model.

```text
1. Capture inbound external order event.
2. Preserve raw order payload.
3. Normalize menu, option, quantity, price, delivery fee, promotion, and customer request fields.
4. Match external store and internal store.
5. Match external menu and internal menu catalog.
6. Validate payable amount and fulfillment capability.
7. Create internal order only after validation.
8. If mapping fails, move to MANUAL_REVIEW_REQUIRED.
9. If external app sends cancellation, delay, sold-out, or change event, validate allowed transition.
10. Reconcile external app daily order report against internal order ledger.
```

External order channels must not directly create final kitchen or settlement state without normalization and validation.

## 11. Process Pattern For Membership, Coupon, And Point Providers

External commercial-benefit providers must use a benefit-authority model.

```text
1. Create benefit validation intent.
2. Request coupon, membership, point, or voucher validation from provider.
3. Capture raw response.
4. Validate benefit owner, expiration, store eligibility, order eligibility, duplicate use, and amount.
5. Lock or reserve benefit when required.
6. Apply discount only after accepted validation.
7. On order cancellation or payment failure, release or reverse benefit.
8. Reconcile used benefits against provider usage report.
```

No external coupon, point, or membership response may directly reduce the internal payable amount without a validation record.

## 12. Process Pattern For Tax, Accounting, And Settlement Providers

Accounting and tax providers must use an export-import reconciliation model.

```text
1. Generate internal settlement or accounting export intent.
2. Produce controlled export file or API request.
3. Preserve export hash and schema version.
4. Receive provider acknowledgment or processing result.
5. Capture raw response or result file.
6. Validate totals, tax categories, payment methods, refund amounts, fees, deposits, and date boundaries.
7. Register reconciliation result.
8. Block accounting closeout when mismatches remain unresolved.
9. Preserve audit evidence for legal retention.
```

Accounting closeout must not depend only on a successful file upload or API response.

## 13. Timeout And Unknown-State Rule

Timeout must never be treated as final failure.

Timeout means the platform does not know whether the provider received, processed, approved, rejected, delayed, or reversed the request.

For every timeout, the platform must do one of the following:

- provider transaction inquiry
- last transaction inquiry
- callback wait with deadline
- duplicate-safe retry
- compensation request
- manager review
- reconciliation hold

A timeout must be mapped to `TIMEOUT_UNKNOWN` unless a reliable provider inquiry confirms the final result.

## 14. Correction And Compensation Rule

Every integration must define compensation actions before production use.

Examples:

| Failure Situation | Required Compensation |
|---|---|
| Payment approved but order creation failed | Recreate order or cancel payment. |
| Order accepted but payment failed | Hold order and request repayment or manager decision. |
| Payment timeout with later approval | Confirm after inquiry or cancel if business state cannot continue. |
| Duplicate approval | Keep one valid approval and reverse duplicate approval. |
| Coupon applied but order cancelled | Release coupon or reverse usage. |
| Delivery app order cancelled after kitchen acceptance | Trigger store/operator exception process. |
| Settlement deposit mismatch | Hold closeout and register reconciliation exception. |
| Accounting export accepted but totals mismatch | Block accounting closeout and create correction file. |

Compensation must be idempotent. A repeated compensation request must not create duplicate cancellation, refund, benefit release, or accounting adjustment.

## 15. Logging And Evidence Requirements

Every external integration event must leave enough evidence to answer the following questions.

```text
Who initiated the event?
Which provider was called?
Which adapter version was used?
What exact payload was sent?
What exact payload was received?
How was the provider response normalized?
Which validation rules passed or failed?
What internal state changed?
Who approved a manual override?
Which reconciliation file later confirmed or contradicted the event?
Which audit evidence proves the final decision?
```

Required evidence fields include:

- internal event id
- external event id
- correlation id
- trace id
- idempotency key
- provider name
- provider environment
- adapter version
- schema version
- raw request payload hash
- raw response payload hash
- normalized payload hash
- validation result
- decision result
- operator id when applicable
- evidence packet id
- audit retention class

## 16. Provider Onboarding Requirements

No external provider may be onboarded without checking the following readiness items.

```text
1. API or file interface specification received
2. Sandbox or test environment confirmed
3. Provider identity and contract boundary confirmed
4. Request and response field registry created
5. Error code registry created
6. Timeout and retry behavior confirmed
7. Inquiry API or equivalent recovery path confirmed
8. Cancellation/refund/reversal path confirmed
9. Settlement or usage report format confirmed
10. Webhook/callback signature and idempotency behavior confirmed
11. Data retention and audit evidence requirement confirmed
12. Legal, tax, privacy, and liability boundary reviewed
13. Pilot test evidence collected
14. Production cutover approval completed
```

If inquiry or equivalent recovery is not available, the provider must be classified as high risk and may require manual settlement hold or restricted scope.

## 17. 70000 Lane Document Map

The following document family is reserved for this lane.

```text
70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md
70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md
70200_Index_External_RPC_Response_Contract_Field_Registry_And_Normalization_Governance.md
70300_Index_External_State_Inquiry_Timeout_Ambiguous_Result_And_Recovery_Governance.md
70400_Index_External_Response_Validation_Integrity_Check_And_Exception_Control.md
70500_Index_External_Cancel_Refund_Reversal_Compensation_And_Manual_Recovery_Governance.md
70600_Index_External_Settlement_Deposit_Fee_Reconciliation_And_Accounting_Audit_Governance.md
70700_Index_External_Webhook_Callback_Event_Idempotency_And_Replay_Governance.md
70800_Index_External_Provider_Onboarding_Certification_Contract_And_Liability_Governance.md
70900_Index_External_Incident_Dispute_Customer_Claim_And_Evidence_Recovery_Governance.md
71000_Index_External_Order_App_Delivery_App_Channel_And_Menu_Mapping_Governance.md
71100_Index_External_Membership_Coupon_Point_Giftcard_And_Benefit_Validation_Governance.md
71200_Index_External_Kiosk_KDS_Device_Vendor_And_Store_Runtime_Interface_Governance.md
71300_Index_External_Tax_Accounting_ERP_And_Backoffice_Export_Reconciliation_Governance.md
71900_Index_External_Integration_Control_Plane_Closeout_And_Handoff.md
```

Additional subdocuments may be added as provider-specific or failure-mode-specific issues emerge.

## 18. First Implementation Priority

The first implementation sequence should focus on the money accident surface before convenience integrations.

```text
1. POS/VAN/PG payment response validation
2. Timeout and ambiguous payment recovery
3. Payment inquiry and reversal control
4. Raw payload and receipt evidence capture
5. Settlement and deposit reconciliation
6. Webhook and callback idempotency
7. Delivery app external order normalization
8. Membership/coupon/point validation
9. Tax/accounting export reconciliation
10. Kiosk/KDS/device vendor interface governance
```

Payment and settlement integrity must precede external convenience-channel expansion.

## 19. Cross-References

This lane must cross-reference the following existing lanes.

```text
06000 POS Gateway WorkPackage lane
07000 Admin Console lane
08000 AI Customer Center lane
09000 Data Model State Machine lane
10000 Runtime Foundation And Cross-Room Architecture lane
14580~14620 Digital SOP Generation, Approval, Publication, And Closeout lane
50000+ System SOP lane
```

The `70000` lane becomes the external process evidence source that later digital SOP, AI customer center, admin recovery console, and financial audit workflows must reference.

## 20. Closeout Criteria

This lane is not considered ready until the following conditions are met.

- all external provider categories are registered
- provider-specific field registries exist
- error-code registries exist
- timeout and unknown-state rules exist
- inquiry and recovery paths exist
- compensation actions exist
- raw payload logging and hash retention exist
- reconciliation files or reports are mapped
- operator recovery SOPs exist
- customer claim evidence packets exist
- admin console review workflows exist
- audit retention classes exist
- production onboarding checklist exists

External integration without validation, correction, logging, reconciliation, and audit evidence is not allowed for production use.

## 21. Handoff

This document opens the 70000 external integration control lane.

The next document should define the first concrete payment-focused index.

```text
70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md
```

The 70100 family should begin with POS, VAN, PG, simple payment, card/acquirer, approval, cancellation, refund, inquiry, response validation, and settlement reconciliation before expanding into delivery apps, external membership, and accounting systems.
