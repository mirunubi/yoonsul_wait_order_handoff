# 070360_Matrix_External_Payment_Recovery_Decision_State_Evidence_And_Action_Map.md

## 1. Document Control

| Field | Value |
|---|---|
| Document ID | 70360 |
| Document Type | Matrix |
| Domain | External Integration Control Plane |
| Lane | External Payment Inquiry, Unknown State, and Recovery Governance |
| Status | Draft |
| Owner | Payment Integrity Owner / External Integration Owner |
| Parent Index | 70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md |
| Previous Document | 70350_Policy_External_Payment_Recovery_Decision_Auto_Release_Manual_Review_And_Hold_Control.md |
| Next Document | 70370_Audit_External_Payment_Inquiry_Recovery_Evidence_And_Manager_Decision_Log.md |
| Related Root | 70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md |
| Related Architecture | 75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md |

## 2. Purpose

This matrix defines how the system maps external payment recovery conditions to required evidence, allowed state transitions, prohibited actions, automatic recovery actions, manual review actions, and audit obligations.

The purpose is to prevent a timeout, delayed response, duplicate response, provider inquiry result, or partial evidence from being treated as a final payment state without sufficient proof.

## 3. Scope

This matrix applies to external payment integrations involving POS, VAN, PG, simple payment providers, cross-border payment providers, card acquirers, settlement file providers, webhook providers, and external order or membership systems when payment state is affected.

This matrix covers:

- Unknown payment state classification
- Inquiry result interpretation
- Recovery decision routing
- Evidence sufficiency checks
- Automatic release criteria
- Manual review routing
- Hold and escalation criteria
- Reversal and compensation triggers
- Audit log requirements

## 4. Core Rule

External inquiry results are not final by themselves.

A recovery decision is valid only when the inquiry result, original request ledger, raw response ledger, amount expectation, approval or cancel evidence, trace metadata, and state transition rule all agree.

If any required proof is missing, the transaction remains in hold, manual review, or reconciliation exception state.

## 5. Canonical Recovery States

| State | Meaning | State Authority |
|---|---|---|
| REQUESTED | Payment intent was created internally | Internal request ledger |
| SENT_TO_EXTERNAL | Payment request was transmitted to external provider | External gateway adapter |
| RESPONSE_MISSING | No valid response was received | Recovery controller |
| TIMEOUT_UNKNOWN | Request timed out and final external state is unknown | Recovery controller |
| INQUIRY_PENDING | Inquiry has been requested but not yet validated | Recovery controller |
| INQUIRY_RECEIVED | Inquiry response was received but not yet validated | Validation gate |
| CONFIRMED | Payment was proven approved and matched | Payment state authority |
| DECLINED | Payment was proven declined or not approved | Payment state authority |
| CANCELLED | Payment was proven cancelled | Payment state authority |
| REVERSAL_PENDING | Approved external payment must be reversed or net-cancelled | Reversal controller |
| MANUAL_REVIEW | Evidence is insufficient or conflicting | Manager / payment operations |
| HOLD | Customer/order/settlement action is blocked until proof is complete | Payment integrity owner |
| RECONCILIATION_EXCEPTION | Real-time recovery failed and settlement/audit reconciliation is required | Reconciliation owner |

## 6. Recovery Decision Matrix

| Condition | Required Evidence | Allowed Transition | Prohibited Action | Recovery Action | Audit Requirement |
|---|---|---|---|---|---|
| Timeout after payment request, no response | payment_intent_id, request_hash, sent_at, provider timeout log | SENT_TO_EXTERNAL → TIMEOUT_UNKNOWN → INQUIRY_PENDING | Mark as FAILED or ask customer to pay again immediately | Submit approval inquiry after controlled delay | Store timeout event, request payload hash, retry counter |
| Inquiry confirms approval and amount matches | approval_no, approved_amount, provider_trace_id, terminal_id, approved_at | INQUIRY_RECEIVED → CONFIRMED | Manual override without amount check | Confirm payment and release order flow | Store inquiry raw payload, approval evidence, state transition log |
| Inquiry confirms approval but amount mismatch | approval_no, approved_amount, expected_amount, order_id | INQUIRY_RECEIVED → MANUAL_REVIEW or HOLD | Confirm order or auto-refund without review | Block order finalization, escalate to payment integrity owner | Store mismatch evidence packet |
| Inquiry confirms no transaction found, but original request was sent | inquiry_raw_payload, provider_not_found_code, request_trace | INQUIRY_RECEIVED → HOLD or RECONCILIATION_EXCEPTION | Mark as DECLINED on first not-found response | Repeat inquiry according to retry policy; escalate if still not found | Store provider not-found result and retry attempts |
| Inquiry confirms declined | provider_decline_code, decline_reason, trace_id | INQUIRY_RECEIVED → DECLINED | Treat as customer cancellation without reason code | Release unpaid order hold or request alternate payment | Store decline code and customer-facing message key |
| Approval response received late after timeout | late_raw_response, approval_no, original intent match | TIMEOUT_UNKNOWN → INQUIRY_RECEIVED → CONFIRMED or REVERSAL_PENDING | Apply late response directly to closed order | Validate order lifecycle and determine confirm or reversal | Store late arrival evidence and decision reason |
| Duplicate approval for same order | multiple approval_no, same order_id, same amount or near time window | CONFIRMED → MANUAL_REVIEW / REVERSAL_PENDING for duplicate | Keep both approvals as valid sales | Keep first valid approval, reverse duplicate if provider supports | Store duplicate approval packet and reversal trace |
| Cancel request timeout | cancel_request_hash, original approval_no, timeout log | CANCEL_REQUESTED → CANCEL_UNKNOWN → CANCEL_INQUIRY_PENDING | Tell customer refund is complete | Submit cancel inquiry and hold refund completion notice | Store cancel timeout and inquiry evidence |
| Inquiry confirms cancellation completed | cancel_approval_no, cancel_amount, cancelled_at, original approval_no | CANCEL_INQUIRY_RECEIVED → CANCELLED | Keep order in paid state | Release cancellation and customer notification | Store cancel confirmation evidence |
| Inquiry shows payment approved but internal order creation failed | approval_no, order_creation_error, inventory state, payment intent | TIMEOUT_UNKNOWN or CONFIRMED → REVERSAL_PENDING or MANUAL_REVIEW | Generate order silently without stock/menu validation | Choose order reconstruction or reversal based on business rule | Store order failure and compensation decision |
| Internal order exists but external payment declined | order_id, decline evidence, no approval_no | ORDER_PENDING_PAYMENT → DECLINED / HOLD | Send order to KDS as paid | Block fulfillment or request alternate payment | Store unpaid order hold event |
| Provider inquiry unavailable | provider incident ID or outage log | INQUIRY_PENDING → HOLD / VENDOR_ESCALATION | Close transaction as success/failure by guess | Escalate to provider and schedule reconciliation | Store outage evidence and vendor ticket |
| Signature invalid on inquiry/webhook result | raw_payload, signature_check_failed, timestamp | ANY → QUARANTINED | Process event for state change | Quarantine event and request trusted channel inquiry | Store signature failure and quarantine log |
| Provider response lacks required trace ID | raw_payload, missing field list | INQUIRY_RECEIVED → MANUAL_REVIEW | Confirm using partial payload alone | Request provider supplemental evidence | Store missing field evidence |
| Settlement file later contradicts real-time state | settlement_record, internal state, approval_no | RECONCILED → RECONCILIATION_EXCEPTION | Alter historical state without adjustment event | Open reconciliation exception and accounting correction | Store settlement mismatch packet |

## 7. Evidence Sufficiency Levels

| Level | Description | May Auto Release? |
|---|---|---|
| E0 | No external evidence | No |
| E1 | External response exists but lacks approval/cancel proof | No |
| E2 | Provider inquiry response exists but has missing metadata | No |
| E3 | Inquiry response includes approval/cancel proof and amount match | Yes, if no conflict |
| E4 | Inquiry response plus raw payload hash, trace ID, terminal/provider identity, and ledger match | Yes |
| E5 | E4 plus settlement or batch evidence | Yes, final reconciliation eligible |

## 8. Automatic Release Criteria

A payment state may be automatically released only when all criteria below are true:

1. The payment intent exists in the internal request ledger.
2. The external inquiry or response maps to the same payment intent.
3. The amount, currency, tax, discount, and service charge match expected values.
4. The store, terminal, provider, and merchant identifiers match registered values.
5. Approval or cancellation proof is present where required.
6. There is no duplicate approval, duplicate cancel, late conflict, signature failure, or replay suspicion.
7. The state transition is allowed by the canonical state machine.
8. Raw payload, hash, timestamp, actor, and decision reason are recorded.

## 9. Manual Review Triggers

Manual review is mandatory when any of the following occurs:

- Amount mismatch
- Missing approval number for a success-like response
- Missing cancel proof for a cancellation-like response
- Unknown provider response code
- Provider not-found result after a sent payment request
- Late approval after customer/order flow was already closed
- Duplicate approval or duplicate cancellation
- Store, terminal, merchant, or provider identifier mismatch
- Signature failure, timestamp window violation, or replay suspicion
- Provider inquiry unavailable or contradictory
- Settlement file contradiction

## 10. Prohibited Actions

The following actions are prohibited:

- Marking timeout as failure without inquiry
- Asking the customer to pay again while the prior payment is TIMEOUT_UNKNOWN
- Sending paid order to KDS without confirmed payment state, unless an explicit manager override policy allows unpaid fulfillment
- Processing late events directly against a closed order without state-machine validation
- Reversing or refunding without original approval evidence
- Closing manual review without evidence packet
- Editing historical payment records without correction events
- Using provider raw response as final internal state without canonical validation

## 11. Manager Action Map

| Manager Situation | Allowed Action | Required Log |
|---|---|---|
| Customer claims payment was charged but order not found | Search by approval_no, card masked value if allowed, time window, terminal_id, amount | Customer claim log, search criteria, result |
| Inquiry confirms approval but order failed | Choose order reconstruction or reversal according to recovery policy | Manager decision reason, evidence packet |
| Inquiry unavailable during provider outage | Keep HOLD and issue customer-facing pending notice | Outage record, notice message key |
| Duplicate approval confirmed | Request duplicate reversal or escalate to provider | Duplicate approval evidence, reversal ticket |
| Settlement mismatch found after daily close | Open reconciliation exception | Settlement file reference, internal ledger reference |

## 12. Handoff Requirements

This matrix hands off to:

- 70370 for inquiry and recovery audit evidence
- 70380 for reconciliation exception escalation
- 70390 for 70300 lane closeout and handoff
- 70500 cancellation, refund, reversal, and compensation control
- 70600 settlement, deposit, fee, and ledger audit
- 75000 payment integrity architecture for idempotency, net cancel, Saga, Outbox, and ledger design

## 13. Completion Criteria

This matrix is complete when:

- Every UNKNOWN recovery condition has an allowed state transition.
- Every auto-release condition has required evidence.
- Every manual-review condition has a routing owner.
- Every prohibited action is explicit.
- Every recovery decision produces an immutable audit trail.
- Related policies and runbooks reference this matrix as the decision map.
