# 070420_Spec_External_Response_Canonical_Code_Field_And_Provider_Mapping_Registry.md

## Document Control

- Document ID: 70420
- Document Type: Spec
- Domain: External Integration Control Plane
- Parent Index: 70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md
- Previous: 70410_Policy_External_Response_Validation_Gate_And_Canonical_Acceptance_Control.md
- Next: 70430_Policy_External_Response_Correction_Normalization_And_Quarantine_Control.md
- Related:
  - 70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md
  - 70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md
  - 70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md
  - 70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md
  - 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md
- Status: Draft
- Owner: External Integration / Payment Integrity Governance

---

## 1. Purpose

This specification defines the canonical code, canonical field, and provider mapping registry used by the External Integration Control Plane.

External providers may return different field names, response codes, approval identifiers, cancellation codes, timestamps, receipt payloads, and settlement references. This document ensures that provider-specific values are preserved as raw evidence while all internal decision logic uses controlled canonical values.

The core rule is:

> External provider values are evidence, not authority. Internal state decisions must be made only through canonical mapping and validation.

---

## 2. Scope

This specification applies to inbound and outbound response mapping from:

- POS providers
- VAN providers
- PG providers
- Simple payment providers
- Alipay / WeChat Pay / cross-border payment providers
- Card issuers and acquirers
- Settlement file providers
- Webhook and callback providers
- External order apps
- Delivery apps
- Kiosk vendors
- KDS vendors
- External membership, coupon, point, and voucher providers
- Tax, accounting, and ERP integrations

This document covers:

- Canonical response code registry
- Canonical status field registry
- Provider response field mapping
- Approval, cancel, refund, settlement, and receipt metadata mapping
- Raw value preservation
- Unknown and unmapped value handling
- Mapping version control
- Mapping evidence and audit requirements

---

## 3. Non-Negotiable Principles

1. Raw provider payload must be stored before mapping.
2. Provider-specific response codes must not directly update internal business state.
3. Every provider response must be mapped into a canonical response class before validation.
4. Mapping failure must not be silently treated as success or failure.
5. Unmapped values must be quarantined or classified as `MAPPING_UNKNOWN`.
6. Mapping changes must be versioned and auditable.
7. Historical decisions must preserve the mapping version used at the time of decision.
8. Provider documentation gaps must be registered as open issues.
9. Canonical values must be stable across providers.
10. Provider raw values must remain queryable for dispute, audit, and vendor escalation.

---

## 4. Canonical Response Classes

| Canonical Class | Meaning | Internal Authority |
|---|---|---|
| `APPROVED` | External provider claims the transaction was approved | Requires validation before confirmation |
| `DECLINED` | External provider clearly rejected the transaction | May release to declined if identifiers match |
| `CANCELLED` | External provider claims cancellation is complete | Requires cancel evidence validation |
| `REFUNDED` | External provider claims refund is complete | Requires refund evidence validation |
| `PENDING` | External provider indicates processing is not complete | Must remain pending or inquiry-required |
| `UNKNOWN` | Provider result cannot establish final state | Must enter unknown handling |
| `TIMEOUT` | Response was not received within the expected window | Must not be treated as failed |
| `DUPLICATE` | Provider indicates duplicate request or duplicate event | Requires idempotency resolution |
| `NOT_FOUND` | Provider cannot find transaction | May require delayed inquiry or reconciliation |
| `MISMATCHED` | Provider response conflicts with internal request | Must be quarantined |
| `ERROR_RETRYABLE` | Provider returned recoverable error | Retry policy applies |
| `ERROR_FINAL` | Provider returned final non-retryable error | Requires classification and evidence |
| `MAPPING_UNKNOWN` | Provider value is not mapped | Must be quarantined until mapped |
| `SECURITY_REJECTED` | Signature, timestamp, or trust validation failed | Must not update business state |

---

## 5. Canonical Field Registry

### 5.1 Common Envelope Fields

| Canonical Field | Required | Description |
|---|---:|---|
| `provider_type` | Yes | POS, VAN, PG, delivery_app, membership, accounting, etc. |
| `provider_id` | Yes | Internal registered provider identifier |
| `provider_name` | Yes | Human-readable provider name |
| `provider_event_id` | Conditional | Provider-side unique event or transaction id |
| `provider_trace_id` | Conditional | Trace id, request id, or transmission id |
| `raw_payload_hash` | Yes | Hash of raw payload before mapping |
| `raw_payload_storage_ref` | Yes | Storage reference for original payload |
| `received_at` | Yes | Internal receipt timestamp |
| `provider_created_at` | Conditional | Provider-side event timestamp |
| `mapping_version` | Yes | Canonical mapping version applied |
| `canonical_response_class` | Yes | Internal canonical response class |

### 5.2 Payment Response Fields

| Canonical Field | Required | Description |
|---|---:|---|
| `payment_intent_id` | Yes | Internal payment intent id |
| `order_id` | Yes | Internal order id |
| `store_id` | Yes | Store identifier |
| `terminal_id` | Conditional | Physical or logical terminal id |
| `merchant_id` | Conditional | Provider/acquirer merchant identifier |
| `approval_no` | Conditional | Approval number from provider/acquirer/card network |
| `approved_amount` | Conditional | Amount approved by external provider |
| `expected_amount` | Yes | Amount expected by internal payment intent |
| `currency` | Yes | Currency code |
| `tax_amount` | Conditional | Tax amount |
| `discount_amount` | Conditional | Discount amount |
| `service_charge_amount` | Conditional | Service charge or tip amount |
| `card_company` | Conditional | Card company or issuer label |
| `acquirer` | Conditional | Acquirer or merchant service provider |
| `receipt_no` | Conditional | Receipt or slip identifier |
| `receipt_payload_ref` | Conditional | Receipt payload storage reference |

### 5.3 Cancellation / Refund Fields

| Canonical Field | Required | Description |
|---|---:|---|
| `original_payment_intent_id` | Yes | Original payment intent |
| `original_approval_no` | Conditional | Original approval number |
| `cancel_id` | Conditional | Provider cancel identifier |
| `refund_id` | Conditional | Provider refund identifier |
| `cancel_amount` | Conditional | Cancelled amount |
| `refund_amount` | Conditional | Refunded amount |
| `cancelled_at` | Conditional | Provider cancellation timestamp |
| `refunded_at` | Conditional | Provider refund timestamp |
| `cancel_reason_code` | Conditional | Canonical cancel reason |
| `refund_route` | Conditional | API cancel, manual refund, bank transfer, set-off, etc. |

### 5.4 Settlement / Accounting Fields

| Canonical Field | Required | Description |
|---|---:|---|
| `settlement_batch_id` | Conditional | Provider settlement batch id |
| `settlement_date` | Conditional | Expected or actual settlement date |
| `gross_amount` | Conditional | Gross approved amount |
| `fee_amount` | Conditional | Provider fee |
| `vat_on_fee` | Conditional | VAT on provider fee |
| `net_deposit_amount` | Conditional | Expected or actual deposit amount |
| `deposit_reference` | Conditional | Bank deposit reference or memo |
| `setoff_amount` | Conditional | Set-off or clawback amount |
| `reconciliation_status` | Conditional | Canonical reconciliation result |

---

## 6. Provider Mapping Table Structure

Each provider mapping entry must follow this structure.

| Field | Description |
|---|---|
| `mapping_id` | Unique mapping record id |
| `provider_id` | Registered provider id |
| `provider_type` | POS, VAN, PG, delivery_app, etc. |
| `provider_api_name` | API, webhook, file, or RPC name |
| `provider_field_path` | JSON path, XML path, CSV column, or protocol offset |
| `provider_raw_value` | Raw value or pattern |
| `canonical_field` | Internal canonical field name |
| `canonical_value` | Internal canonical value |
| `canonical_response_class` | Internal response class if applicable |
| `mapping_version` | Version of mapping rule |
| `effective_from` | Start timestamp |
| `effective_to` | End timestamp if deprecated |
| `confidence_level` | confirmed, provisional, vendor_pending, deprecated |
| `evidence_ref` | Provider document, test result, certification packet, or audit evidence |
| `owner` | Integration owner |
| `review_cycle` | Review cadence |

---

## 7. Mapping Confidence Levels

| Confidence Level | Meaning | Allowed Use |
|---|---|---|
| `CONFIRMED` | Verified by provider documentation and test evidence | Production allowed |
| `CERTIFIED` | Verified during provider certification or pilot | Production allowed |
| `PROVISIONAL` | Inferred from test or vendor communication, not fully documented | Pilot only unless approved |
| `VENDOR_PENDING` | Awaiting provider confirmation | Quarantine or manual review only |
| `DEPRECATED` | No longer valid | Must not be used for new decisions |
| `BLOCKED` | Known unsafe or contradictory mapping | Must reject or quarantine |

---

## 8. Canonical Mapping Rules

### 8.1 Success Mapping

A provider success value may map to `APPROVED` only when:

1. The provider value is present in the confirmed mapping registry.
2. The response includes the required transaction identifier set.
3. The amount and currency are available or derivable.
4. The provider timestamp is valid or the internal receipt timestamp is sufficient for the provider class.
5. The response passes signature, timestamp, replay, and trust-boundary validation.
6. The mapping version is active at the time of receipt.

### 8.2 Failure Mapping

A provider failure value may map to `DECLINED` or `ERROR_FINAL` only when:

1. The failure code is provider-confirmed.
2. The failure applies to the correct payment intent or transaction.
3. The provider explicitly indicates no approval occurred.
4. The failure is not merely a timeout, not-found, or unknown processing state.

### 8.3 Timeout Mapping

Timeout must map to `TIMEOUT` or `UNKNOWN`, not to `DECLINED`.

Timeout becomes final only after:

1. Inquiry confirms no approval, or
2. Reconciliation confirms no settlement/approval record, or
3. Provider supplies final no-transaction evidence accepted by policy.

### 8.4 Not Found Mapping

`NOT_FOUND` is not automatically final.

A provider may return not-found before a delayed transaction is materialized. Therefore:

- Immediate not-found after timeout must remain inquiry-pending.
- Repeated not-found may still require delay window handling.
- Final not-found requires provider-specific inquiry rules.

### 8.5 Duplicate Mapping

Duplicate provider responses must map to `DUPLICATE` and be resolved through idempotency and event order controls.

A duplicate event must not generate a second approval, cancellation, refund, order, point deduction, coupon redemption, or ledger posting.

---

## 9. Unmapped Value Handling

If a provider response contains an unmapped value:

1. Preserve raw payload.
2. Create `MAPPING_UNKNOWN` event.
3. Block automatic state transition.
4. Route to mapping review queue.
5. Link to provider documentation request or test evidence.
6. Require mapping approval before replay.
7. Preserve the original decision gap in audit log.

Unmapped values must never be guessed as success or failure.

---

## 10. Mapping Version Control

Mapping changes must be version-controlled.

Required controls:

- Mapping version id
- Effective start time
- Effective end time if superseded
- Change reason
- Provider evidence reference
- Test evidence reference
- Approver id
- Rollback procedure
- Impacted historical events query

Historical events must retain the mapping version used at the time of their original validation. Reprocessing with a new mapping version requires explicit replay authorization.

---

## 11. Provider Documentation Gap Rules

Provider documentation gaps must be registered when:

- A response code is observed but undocumented.
- A field changes format without notice.
- A success code arrives without approval number.
- A cancellation code does not indicate finality.
- A webhook payload differs from API inquiry payload.
- Settlement file values do not match API response values.
- Provider cannot explain retry, duplicate, or delayed event behavior.

Each gap must be linked to:

- Open issue id
- Provider contact or escalation channel
- Affected store/provider/payment method
- Risk classification
- Temporary handling rule
- Required follow-up document

---

## 12. Audit Requirements

Every mapped response must be auditable with:

- Raw payload hash
- Raw payload storage reference
- Provider raw code/value
- Canonical mapped value
- Mapping version
- Mapping confidence level
- Validation gate result
- State transition result
- Operator or automated decision id
- Replay history if applicable

Audit evidence must allow reconstruction of:

1. What external value arrived.
2. How it was mapped.
3. Which version of mapping was used.
4. Why the internal state changed or did not change.
5. Who or what approved any replay or manual override.

---

## 13. Prohibited Practices

The following are prohibited:

- Directly using provider `success`, `ok`, `0000`, or equivalent values to confirm internal payment state.
- Treating timeout as failure.
- Treating not-found as final without provider-specific inquiry rules.
- Updating order/payment/settlement ledgers before canonical mapping.
- Overwriting raw provider values with normalized values.
- Reusing a mapping rule after deprecation.
- Applying a new mapping version to historical events without replay approval.
- Allowing Cursor or automated generation tools to invent provider mapping rules.
- Treating undocumented provider codes as production-confirmed.

---

## 14. Acceptance Criteria

This specification is accepted when:

- Canonical response classes are defined.
- Required canonical fields are documented.
- Provider mapping table structure is fixed.
- Mapping confidence levels are defined.
- Unknown and unmapped value handling is defined.
- Mapping version control is required.
- Audit requirements are defined.
- Prohibited direct provider-state authority is clearly blocked.

---

## 15. Handoff

This document hands off to:

- `70430_Policy_External_Response_Correction_Normalization_And_Quarantine_Control.md`
- `70440_Runbook_External_Response_Mapping_Exception_Review_And_Provider_Escalation.md`
- `70450_Audit_External_Response_Mapping_Version_Evidence_And_Change_Control.md`
