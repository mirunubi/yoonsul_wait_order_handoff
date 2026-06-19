# 070400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md

## Document Control

- Document Number: 70400
- Document Type: Index
- Domain: External Integration Control Plane
- Parent Index: 70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md
- Previous: 70390_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Closeout_And_Handoff.md
- Next: 70410_Policy_External_Response_Validation_Gate_And_Canonical_Acceptance_Control.md
- Status: Draft
- Owner: External Integration Governance Owner
- Reviewers: Payment Integrity Owner, POS Gateway Owner, Audit Ledger Owner, Store Operations Owner

## 1. Purpose

This index opens the External Response Validation, Correction, and Canonical Mapping control lane.

The purpose of this lane is to ensure that responses received from external systems are not used directly as internal truth. Every response from POS, VAN, PG, simple payment providers, card/acquirer networks, delivery apps, membership providers, kiosk vendors, KDS vendors, webhook providers, settlement file providers, and accounting/tax integrations must pass through validation, canonical mapping, correction eligibility checks, quarantine control, and audit evidence capture before it can influence internal state.

This lane exists because external providers often use different field names, status codes, timing models, retry behavior, cancellation semantics, settlement semantics, and error classifications. Without a controlled mapping and validation layer, provider-specific ambiguity can leak into the internal order, payment, settlement, membership, and accounting ledgers.

## 2. Core Principle

External response data is evidence, not authority.

Internal authority is granted only after:

1. the raw response is preserved,
2. the response envelope is validated,
3. required identifiers are matched,
4. provider-specific codes are mapped to canonical codes,
5. amount and state consistency checks pass,
6. correction rules are applied only where allowed,
7. unsupported or unsafe responses are quarantined,
8. the resulting state transition is written with audit evidence.

## 3. Scope

This lane covers response validation and canonical mapping for the following external sources:

- POS RPC responses
- VAN payment and cancellation responses
- PG approval, cancel, refund, escrow, and virtual account responses
- simple payment providers including domestic wallet and QR payment providers
- Alipay, WeChat Pay, and cross-border payment gateways
- card company and acquirer response data
- settlement files and deposit files
- delivery app order, cancel, payout, and claim events
- external order app and table-order provider events
- kiosk vendor callback and status responses
- KDS vendor ticket, ready, complete, remake, and failure responses
- membership, coupon, point, voucher, and benefit provider responses
- accounting, tax, ERP, and cashflow integration responses
- webhook and callback events that carry state-changing claims

## 4. Out of Scope

This lane does not define the full payment self-healing architecture. Idempotency, delayed net cancel, Saga orchestration, transactional outbox, CDC, double-entry ledger, and local hardware watchdog architecture are governed under the 75000 Payment Integrity Architecture lane.

This lane also does not replace provider onboarding or legal contract review. Provider capability, SLA, evidence duty, and contractual responsibility are governed by provider onboarding and contract readiness lanes.

## 5. Required Control Layers

### 5.1 Raw Response Preservation

Every response must be stored before transformation. The raw payload must be retained with:

- provider id
- channel id
- integration type
- received timestamp
- raw body
- raw headers where available
- remote address or source metadata where available
- request correlation id
- provider transaction id where available
- hash of the raw payload
- parser version
- mapping version

### 5.2 Envelope Validation

Every response must be wrapped into a canonical envelope before processing. The envelope must include:

- external_event_id
- provider_event_id
- source_provider
- source_channel
- event_type
- event_version
- event_time
- received_time
- correlation_id
- idempotency_key
- signature_status
- replay_status
- raw_payload_hash
- canonical_mapping_version

### 5.3 Identifier Matching

No response may update an internal state unless it is matched to an internal intent, request, order, payment, settlement, membership, or device record.

Matching may use one or more of the following identifiers:

- internal order id
- payment intent id
- provider transaction id
- approval number
- cancellation number
- merchant id
- terminal id
- store id
- table id
- receipt number
- settlement batch id
- webhook event id
- delivery order id
- membership transaction id
- voucher id
- external device id

If matching is incomplete, the response must enter UNMATCHED or REVIEW_REQUIRED status.

### 5.4 Canonical Code Mapping

Provider-specific status codes must be mapped to internal canonical codes. A provider code must never be used directly in the internal state machine.

Canonical categories include:

- APPROVED
- DECLINED
- CANCELLED
- REFUNDED
- PARTIALLY_CANCELLED
- PENDING
- UNKNOWN
- AMBIGUOUS
- DUPLICATE
- RETRYABLE_FAILURE
- NON_RETRYABLE_FAILURE
- PROVIDER_ERROR
- VALIDATION_FAILED
- QUARANTINED
- MANUAL_REVIEW_REQUIRED

### 5.5 Correction Eligibility

Some external responses may be corrected or normalized. Correction is allowed only when the correction is deterministic, reversible, logged, and does not change financial meaning.

Allowed examples:

- whitespace trimming
- date/time format normalization
- currency code normalization
- provider enum normalization
- missing optional display label recovery from registry
- decimal formatting normalization where amount value is unchanged

Forbidden examples:

- changing amount values
- inventing approval numbers
- inventing cancellation numbers
- changing failure to success
- changing unknown to success without inquiry evidence
- changing provider identity
- changing terminal/store identity
- suppressing provider error codes
- removing evidence of mismatch

### 5.6 Quarantine

A response must be quarantined when:

- signature validation fails
- replay is detected
- provider identity is unknown
- required identifiers are missing
- amount mismatch is detected
- order/payment/store/terminal match fails
- status transition would move backward
- response contradicts prior approved evidence
- cancellation response conflicts with payment approval evidence
- settlement response conflicts with ledger expectation
- mapping version is missing or unsupported
- parsing fails in a way that may affect financial meaning

### 5.7 Audit Evidence

Every validation result and mapping result must be auditable. The audit record must include:

- raw payload hash
- canonical payload hash
- validation result
- validation rule version
- mapping result
- mapping table version
- correction result
- correction rule version
- quarantine decision if any
- reviewer id if manual review was required
- state transition id if released
- linked order/payment/settlement/member/device record

## 6. Document Set

This 70400 lane is organized as follows:

| Number | Document | Purpose |
|---:|---|---|
| 70400 | Index_External_Response_Validation_Correction_And_Canonical_Mapping | Opens this lane and defines its control scope |
| 70410 | Policy_External_Response_Validation_Gate_And_Canonical_Acceptance_Control | Defines the validation gate and acceptance criteria |
| 70420 | Spec_External_Response_Canonical_Status_Code_And_Error_Code_Mapping_Registry | Defines canonical status/error code mapping |
| 70430 | Policy_External_Response_Correction_Eligibility_Normalization_And_Forbidden_Rewrite_Control | Defines allowed corrections and forbidden rewrites |
| 70440 | Policy_External_Response_Unmatched_Mismatch_And_Quarantine_Control | Defines mismatch and quarantine rules |
| 70450 | Matrix_External_Response_Provider_Code_To_Canonical_State_And_Action_Map | Maps provider codes to canonical state and recovery actions |
| 70460 | Runbook_External_Response_Mapping_Exception_Review_Release_And_Escalation_Action | Defines operational review and release actions |
| 70470 | Audit_External_Response_Validation_Correction_Mapping_And_Release_Evidence_Log | Defines audit evidence and release logs |
| 70480 | Register_External_Response_Mapping_Gap_Provider_Exception_And_Open_Issue | Tracks mapping gaps and unresolved provider differences |
| 70490 | Index_External_Response_Validation_Correction_And_Canonical_Mapping_Closeout_And_Handoff | Closes this lane and hands off to cancellation/refund/reversal control |

## 7. Required State Outcomes

Every external response must end in one of the following processing outcomes:

| Outcome | Meaning | Next Action |
|---|---|---|
| ACCEPTED_CANONICAL | Response passed validation and canonical mapping | Eligible for controlled state transition |
| ACCEPTED_WITH_NORMALIZATION | Deterministic non-financial normalization applied | Eligible with correction audit |
| UNMATCHED | Cannot match to internal record | Hold and manual/inquiry review |
| MISMATCHED | Matched record exists but values conflict | Quarantine and escalation |
| UNSUPPORTED_CODE | Provider code has no mapping | Mapping gap register |
| SIGNATURE_FAILED | Signature or authenticity failed | Security quarantine |
| REPLAY_DETECTED | Duplicate/replay outside allowed idempotency behavior | Quarantine and replay audit |
| AMBIGUOUS | Provider response does not establish clear state | Inquiry/recovery process |
| REJECTED | Response is invalid and cannot be used | Preserve evidence, do not transition |
| MANUAL_REVIEW_REQUIRED | Automated release is unsafe | Manager/audit review |

## 8. Relationship to 70300 Lane

The 70300 lane governs UNKNOWN detection, inquiry, recovery, and release control. This 70400 lane consumes inquiry results and validates whether the resulting provider response can be canonicalized and released.

A payment may not leave UNKNOWN, AMBIGUOUS, or INQUIRY_PENDING solely because an external inquiry response exists. The inquiry response must pass this 70400 validation and mapping lane before release.

## 9. Relationship to 70500 Lane

The 70500 lane governs cancellation, refund, reversal, and compensation control. This 70400 lane determines whether cancellation/refund/reversal provider responses are valid, canonical, and safe to use.

If a response maps to CANCEL_PENDING, REVERSAL_PENDING, REFUND_FAILED, or PARTIAL_CANCEL_UNSUPPORTED, the 70500 lane must own the next recovery decision.

## 10. Relationship to 75000 Lane

The 75000 Payment Integrity Architecture lane governs systemic financial integrity patterns such as:

- idempotency
- duplicate payment prevention
- delayed net cancel
- Saga orchestration
- compensating transactions
- transactional outbox
- CDC/event relay integrity
- double-entry ledger
- settlement reconciliation
- local hardware agent and watchdog integrity

This 70400 lane provides canonicalized and validated response facts to the 75000 lane. It must not independently define distributed transaction architecture.

## 11. Completion Criteria

This lane is complete when:

1. all external response types have a canonical envelope,
2. all required provider response codes have mapping entries,
3. correction eligibility rules are documented,
4. forbidden rewrites are documented,
5. mismatch and quarantine rules are documented,
6. provider code to canonical state matrix exists,
7. review/release runbook exists,
8. validation and mapping audit logs are defined,
9. mapping gaps are tracked in a register,
10. closeout handoff to 70500 is complete.

## 12. Non-Negotiable Rules

- Never let a provider-specific status code directly mutate internal order, payment, settlement, membership, or accounting state.
- Never treat a parsed response as authoritative if the raw payload was not preserved.
- Never release a response with amount, store, terminal, order, or payment mismatch.
- Never correct financial meaning through normalization.
- Never convert UNKNOWN to SUCCESS without inquiry evidence and validation evidence.
- Never discard an unsupported provider code.
- Never replay quarantined events without approval evidence.
- Never suppress provider error metadata in audit logs.

## 13. Handoff

After this index, proceed to:

- 70410_Policy_External_Response_Validation_Gate_And_Canonical_Acceptance_Control.md

This next document defines the validation gate that every external response must pass before canonical acceptance.
