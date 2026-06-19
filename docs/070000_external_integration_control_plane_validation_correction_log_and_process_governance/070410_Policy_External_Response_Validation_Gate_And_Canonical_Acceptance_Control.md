# 070410_Policy_External_Response_Validation_Gate_And_Canonical_Acceptance_Control.md

## Document Control

- Project: yoonsul_wait_order_handoff
- Number: 70410
- DocumentType: Policy
- Domain: External Integration Control Plane
- Parent Index: 70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md
- Previous: 70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md
- Next: 70420_Spec_External_Response_Canonical_Code_Field_And_Provider_Mapping_Registry.md
- Related:
  - 70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md
  - 70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md
  - 70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md
  - 70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md
  - 70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md
  - 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md
- Status: Draft
- Owner: External Integration / Payment Integrity Governance

---

## 1. Purpose

This policy defines the **External Response Validation Gate** for all inbound responses, callbacks, inquiry results, settlement events, and provider-originated state messages received from external systems.

The purpose is to prevent external systems from directly changing internal business state without validation.

External responses are treated as **evidence inputs**, not final authority.

Only responses that pass the canonical validation gate may be used to update internal order, payment, membership, coupon, settlement, accounting, kitchen, or customer-facing states.

---

## 2. Scope

This policy applies to external responses from:

- POS providers
- VAN providers
- PG providers
- card acquirers / issuers / settlement intermediaries
- simple payment providers
- Alipay / WeChat Pay / cross-border payment gateways
- external order apps
- delivery apps
- kiosk vendors
- KDS vendors
- membership / coupon / point vendors
- tax / accounting / ERP integrations
- webhook and callback providers
- settlement file providers
- bank deposit and payout data sources

---

## 3. Core Principle

The system shall not apply this pattern:

```text
external_response.success = true
→ internal_state = completed
```

The system shall apply this pattern:

```text
external response received
→ raw response stored
→ provider identity verified
→ envelope validated
→ signature / timestamp / replay checked
→ provider fields mapped to canonical fields
→ business identifiers matched
→ amount / tax / discount / settlement values validated
→ state transition authority evaluated
→ accepted / corrected / quarantined / rejected / escalated
```

---

## 4. Validation Gate Position

The validation gate must sit between the inbound event store and any internal state mutation.

```text
External Provider
  → Inbound Receiver
  → Raw Log Store
  → Envelope Parser
  → Validation Gate
  → Canonical Mapping
  → State Authority Layer
  → Internal Ledger / Order / Payment / Settlement State
```

No provider payload may bypass this gate.

---

## 5. Mandatory Validation Layers

Every external response must pass the following layers before canonical acceptance.

| Layer | Required Control | Failure Result |
|---|---|---|
| Provider Identity | provider_id, endpoint, credential, contract profile | quarantine |
| Transport Security | TLS, source allowlist where applicable | reject or quarantine |
| Signature | HMAC, public key, provider signature, webhook secret | quarantine |
| Timestamp | allowed clock skew and event age window | quarantine |
| Replay Detection | event_id, trace_id, idempotency key, hash | duplicate / replay quarantine |
| Raw Payload Preservation | immutable raw payload and hash | reject processing if missing |
| Schema Validation | required fields, type, enum, length | reject or correction pending |
| Canonical Mapping | provider field to internal field map | mapping pending |
| Business Match | order/payment/store/terminal/customer references | manual review |
| Amount Match | amount, tax, discount, fee, service charge | mismatch hold |
| State Machine Match | allowed transition only | blocked transition |
| Evidence Completeness | approval no, cancel no, receipt, inquiry result | evidence pending |

---

## 6. Canonical Acceptance Criteria

A response may be accepted only when all mandatory criteria are satisfied.

```text
ACCEPTED_CANONICAL_RESPONSE requires:
- provider identity is known
- response source is authorized
- raw payload is stored and hashed
- signature or equivalent integrity check passes
- timestamp is within the allowed window or explicitly approved
- replay and duplicate checks pass
- schema validates against provider profile
- all required canonical fields are mapped
- business identifiers match an existing internal intent or ledger entry
- amount and currency match expected values or an approved tolerance rule
- state transition is allowed
- required evidence is complete
```

If any required condition is missing, the response must not directly update internal final state.

---

## 7. Response Classification

Each inbound response must be assigned one canonical processing class.

| Class | Meaning | Allowed Action |
|---|---|---|
| ACCEPTED | Fully valid and state-applicable | State mutation allowed |
| ACCEPTED_WITH_CORRECTION | Minor safe correction applied | State mutation allowed with correction log |
| CORRECTION_PENDING | Correctable but not yet resolved | No final state mutation |
| MAPPING_PENDING | Provider field mapping missing | No final state mutation |
| EVIDENCE_PENDING | Result plausible but evidence incomplete | Hold / inquiry |
| MISMATCHED | Business, amount, or state conflict | Hold / manual review |
| DUPLICATE | Already processed equivalent event | Return prior result / ignore mutation |
| REPLAY_SUSPECTED | Potential malicious or unsafe replay | Quarantine |
| SIGNATURE_FAILED | Integrity check failed | Quarantine / security alert |
| REJECTED | Invalid, unsupported, or unsafe | No mutation |

---

## 8. Correction Boundary

Correction is allowed only for non-financial, non-authoritative normalization.

Allowed examples:

- provider code casing normalization
- whitespace trimming
- date format conversion
- known provider enum alias mapping
- locale-specific message normalization
- missing optional description defaulting

Correction is not allowed for:

- amount
- tax
- discount
- service charge
- currency
- approval number
- cancel number
- terminal id
- merchant id
- provider transaction id
- customer payment state
- settlement amount
- deposit date
- fee amount
- state transition code

Financial or state-bearing mismatches must be handled as hold, inquiry, reconciliation exception, or manual review.

---

## 9. Provider Mapping Registry Requirement

Every provider must have a mapping profile before production traffic is accepted.

The profile must include:

```text
provider_id
provider_name
provider_type
supported_event_types
supported_response_codes
success_code_mapping
failure_code_mapping
pending_code_mapping
cancel_code_mapping
refund_code_mapping
settlement_code_mapping
required_fields_by_event_type
optional_fields_by_event_type
signature_scheme
timestamp_scheme
idempotency_key_source
trace_id_source
amount_fields
currency_fields
terminal_fields
merchant_fields
receipt_fields
inquiry_fields
known_provider_quirks
unsupported_cases
gap_register_link
```

If a provider response code is unknown, it must not be interpreted as success.

---

## 10. State Authority Rule

External response status is not the same as internal state authority.

| External Response | Internal Action |
|---|---|
| Provider says success | Validate before confirmation |
| Provider says failed | Check whether failure is final or unknown |
| Provider times out | Mark UNKNOWN, not FAILED |
| Provider sends duplicate webhook | Deduplicate, do not mutate twice |
| Provider sends late event | Check state machine before applying |
| Provider sends cancel success | Validate cancel identity and original approval |
| Provider sends settlement value | Reconcile against internal ledger and expected fee |

The State Authority Layer owns final internal state.

---

## 11. Financial Validation Requirements

For payment-related responses, the validation gate must compare:

- expected order amount
- approved amount
- cancelled amount
- refunded amount
- tax amount
- discount amount
- coupon amount
- point amount
- service charge
- delivery fee where applicable
- currency
- provider fee where applicable
- settlement expected amount
- deposit amount

Any 1 KRW discrepancy must be treated as a controlled mismatch unless an explicitly documented tolerance rule exists.

---

## 12. Evidence Requirements

Accepted payment responses must preserve evidence sufficient for later dispute, audit, and reconciliation.

Minimum evidence:

```text
raw_payload
payload_hash
provider_id
event_type
received_at
provider_event_at
request_id
trace_id
idempotency_key
order_id
payment_intent_id
provider_transaction_id
approval_no or cancel_no where applicable
terminal_id
merchant_id
amount
currency
response_code
canonical_response_code
validation_result
state_transition_result
operator_override_id if any
```

---

## 13. Failure Handling

When validation fails, the system must not silently discard the response.

The response must be routed to one of:

```text
quarantine_queue
correction_queue
mapping_gap_register
manual_review_queue
inquiry_required_queue
reconciliation_exception_queue
security_incident_queue
provider_escalation_queue
```

The route must be recorded with reason code and evidence hash.

---

## 14. Prohibited Practices

The following are prohibited:

- treating provider success as internal completion without validation
- overwriting internal state with provider fields directly
- correcting financial values manually without audit trail
- ignoring unknown response codes
- dropping invalid webhook events without raw log
- applying late events without state machine check
- accepting unsigned webhook payloads where signature is contractually required
- allowing provider-specific enum values to leak into core state
- reprocessing duplicate events as new events
- releasing UNKNOWN state without inquiry or reconciliation evidence

---

## 15. Required Logs

Every validation attempt must emit a structured validation log.

```text
validation_log_id
raw_event_id
provider_id
event_type
validation_started_at
validation_finished_at
schema_result
signature_result
timestamp_result
replay_result
mapping_result
business_match_result
amount_match_result
state_machine_result
evidence_result
final_validation_class
failure_reason_code
next_queue
hash_before
hash_after
```

---

## 16. Relationship To 75000 Payment Integrity Architecture

This policy controls whether an external response may enter internal state flow.

The 75000 Payment Integrity Architecture controls how accepted or uncertain financial events are handled across:

- idempotency
- duplicate prevention
- timeout unknown
- delayed net cancel
- reversal
- Saga compensation
- transactional outbox
- CDC / event relay
- double-entry ledger
- reconciliation

If a response is financially meaningful and uncertain, it must be handed to the 75000 architecture rather than being locally resolved inside the external integration layer.

---

## 17. Acceptance Checklist

A provider integration cannot be marked production-ready unless:

- [ ] Provider mapping profile exists
- [ ] Required fields are defined by event type
- [ ] Success/failure/pending/cancel/refund codes are mapped
- [ ] Unknown codes are routed to mapping gap register
- [ ] Signature and replay control are implemented
- [ ] Raw payload and hash are stored
- [ ] Amount validation is implemented
- [ ] State machine validation is implemented
- [ ] Duplicate and late event handling is implemented
- [ ] Quarantine and manual review queues exist
- [ ] Inquiry or reconciliation fallback exists for financial events
- [ ] Audit logs are generated

---

## 18. Handoff

This policy hands off to:

- 70420 for canonical code, field, and provider mapping registry specification
- 70430 for provider response code normalization rules
- 70440 for correction boundary and safe normalization policy
- 70450 for mismatched response quarantine and manual review control
- 75000 series for payment integrity, idempotency, Saga, outbox, ledger, and reconciliation governance
