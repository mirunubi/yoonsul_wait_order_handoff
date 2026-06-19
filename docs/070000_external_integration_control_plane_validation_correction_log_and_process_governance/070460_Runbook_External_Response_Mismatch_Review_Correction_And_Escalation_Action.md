# 070460_Runbook_External_Response_Mismatch_Review_Correction_And_Escalation_Action.md

## 1. Purpose

This runbook defines the operational procedure for reviewing, correcting, quarantining, and escalating external response mismatches detected by the External Integration Control Plane.

External responses from POS, VAN, PG, simple payment providers, card acquirers, delivery channels, kiosk vendors, KDS vendors, membership providers, coupon providers, and accounting or tax integrations must not directly update internal authoritative ledgers when a mismatch is detected.

The purpose of this document is to ensure that every mismatch is handled through a controlled process with evidence, approval, replay safety, and auditability.

## 2. Scope

This runbook applies to mismatches detected in:

- payment approval responses
- payment cancellation responses
- refund responses
- settlement responses
- webhook callbacks
- delivery order status callbacks
- external membership point events
- coupon issuance or redemption responses
- kiosk or KDS device acknowledgements
- accounting, tax, or ERP integration responses
- external provider inquiry results
- replayed or manually corrected external events

This runbook does not authorize direct database editing, direct ledger mutation, or blind correction without evidence.

## 3. Parent And Related Documents

- Parent: `70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md`
- Previous: `70450_Matrix_External_Response_Mismatch_Type_Severity_Action_And_Escalation_Map.md`
- Next: `70470_Audit_External_Response_Correction_Evidence_Manager_Approval_And_Replay_Log.md`
- Related: `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- Related: `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`
- Related: `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md`
- Related: `70360_Matrix_External_Payment_Recovery_Decision_State_Evidence_And_Action_Map.md`
- Related: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

A mismatch is not a formatting inconvenience.

A mismatch is a controlled exception that may indicate one of the following:

- provider mapping drift
- stale provider documentation
- replayed external event
- late-arriving response
- duplicate external transaction
- wrong terminal, store, or merchant mapping
- amount, tax, discount, fee, or settlement difference
- cancellation or refund state conflict
- malicious or malformed payload
- provider-side operational incident
- internal canonical mapping defect

The operator must preserve the original evidence, identify the mismatch class, determine the allowed action, and apply only the approved recovery path.

## 5. Roles

| Role | Responsibility |
|---|---|
| Store Operator | Observe customer-facing symptom and avoid unsupported confirmation. |
| Store Manager | Approve store-level hold, recheck, or customer guidance when allowed. |
| Integration Operator | Review mismatch queue, classify mismatch, attach evidence, and execute allowed runbook action. |
| Payment Integrity Owner | Approve financial-state correction, reversal, refund, or ledger release. |
| Provider Manager | Escalate provider-side defect, missing inquiry, missing settlement file, or mapping drift. |
| Audit Owner | Verify evidence packet completeness and tamper-check chain. |
| Engineering Owner | Fix parser, canonical mapping, field registry, or validation bug. |

## 6. Mismatch Intake

Every mismatch must enter the mismatch review queue with the following minimum fields:

```yaml
mismatch_case_id: required
source_provider: required
source_channel: required
external_event_id: required_if_available
internal_correlation_id: required
order_id: required_if_available
payment_intent_id: required_if_available
store_id: required_if_available
terminal_id: required_if_available
raw_payload_hash: required
canonical_mapping_version: required
mismatch_type: required
severity: required
current_internal_state: required
external_claimed_state: required
received_at: required
detected_at: required
assigned_owner: required
```

If these fields are unavailable, the case must remain in `EVIDENCE_INCOMPLETE` and must not be released into automatic correction.

## 7. First Response Procedure

When a mismatch is detected, the operator must perform the following steps:

1. Confirm that the raw payload is stored.
2. Confirm that the raw payload hash is generated.
3. Confirm that the provider, store, terminal, order, and transaction identifiers are captured.
4. Check whether the mismatch is already covered by `70450` severity mapping.
5. Assign the case to the correct owner.
6. Prevent direct state mutation while review is open.
7. Place the affected order, payment, settlement, or external event into the appropriate hold state.
8. Attach customer-facing notes only if customer communication is required.
9. Create or link the audit evidence packet.

## 8. Severity-Based Action

| Severity | Default Action | Auto Correction Allowed | Manager Approval Required | Provider Escalation Required |
|---|---|---:|---:|---:|
| S0 Informational | Record and monitor | Yes, if rule exists | No | No |
| S1 Low | Normalize and log | Yes, if non-financial | No | No |
| S2 Medium | Review and controlled correction | Conditional | Sometimes | Sometimes |
| S3 High | Quarantine and manual review | No | Yes | Usually |
| S4 Critical | Freeze state and escalate | No | Yes | Yes |
| S5 Financial Incident | Incident workflow | No | Yes | Yes |

## 9. Allowed Correction Types

The following corrections may be allowed when the required evidence exists:

| Correction Type | Allowed Condition |
|---|---|
| formatting normalization | Whitespace, casing, date format, or provider-specific code format only. |
| canonical code mapping | Mapping exists in approved registry version. |
| missing optional display field fill | Field is non-authoritative and derived from trusted source. |
| delayed event reorder | State machine confirms event is valid but late. |
| duplicate event suppression | Idempotency key, event id, or provider trace proves duplicate. |
| non-financial metadata correction | Does not change amount, approval, cancellation, refund, settlement, or accounting state. |

## 10. Prohibited Correction Types

The following actions are prohibited without Payment Integrity Owner approval and audit evidence:

- changing approved amount
- changing tax amount
- changing discount amount
- changing service charge
- changing approval number
- changing cancellation approval number
- changing refund state
- changing settlement amount
- changing deposit amount
- changing fee or VAT amount
- assigning a response to a different order
- assigning a response to a different store
- assigning a response to a different terminal
- deleting the original payload
- overwriting raw response with normalized response
- manually marking UNKNOWN as CONFIRMED without inquiry evidence
- replaying a quarantined event without approval

## 11. Review Procedure By Mismatch Type

### 11.1 Amount Mismatch

1. Compare internal expected amount with external approved amount.
2. Compare tax, discount, coupon, point, service charge, and rounding basis.
3. Check whether currency or exchange-rate mapping exists.
4. Check whether partial cancellation or refund has already occurred.
5. If any 1 KRW financial difference remains unexplained, keep the case in `FINANCIAL_REVIEW_HOLD`.
6. Do not release order, payment, or settlement finality until approved.

### 11.2 Identifier Mismatch

1. Compare order id, payment intent id, provider transaction id, approval number, terminal id, merchant id, and store id.
2. Check whether the response is a late-arriving response for an earlier request.
3. Check whether provider returned a reused or duplicate transaction id.
4. If mapping cannot be proven, quarantine the response.
5. Escalate to provider if provider trace id is ambiguous or missing.

### 11.3 State Conflict

1. Compare internal state and external claimed state.
2. Check whether the transition is allowed by the state machine.
3. Check whether the event is late, replayed, duplicated, or out of order.
4. If state transition would reverse a finalized state, manual review is required.
5. If the event is valid but late, use controlled replay with audit evidence.

### 11.4 Signature Or Payload Integrity Mismatch

1. Verify signature, timestamp, nonce, and replay window.
2. Confirm whether the provider recently rotated keys.
3. Confirm whether payload was transformed by gateway or proxy.
4. If signature cannot be validated, keep payload quarantined.
5. Do not use the payload for state authority.

### 11.5 Provider Mapping Drift

1. Compare current response with approved provider mapping registry.
2. Check recent provider release notes or contract notices.
3. Add gap record if new field or response code is detected.
4. Use temporary mapping only after owner approval.
5. Open engineering task for permanent mapping update.

## 12. Correction Execution Procedure

A correction must follow this sequence:

```text
1. Open mismatch case
2. Attach raw payload and hash
3. Classify mismatch type and severity
4. Identify allowed correction path
5. Obtain required approval
6. Apply canonical correction event
7. Preserve original payload unchanged
8. Record correction reason and mapping version
9. Replay only if required and approved
10. Verify resulting state
11. Link case to audit packet
12. Close or escalate
```

Corrections must be appended as new correction events. They must not overwrite the original inbound event.

## 13. Replay Control

Replay is allowed only when:

- original raw payload exists
- hash verification passes
- replay reason is recorded
- affected state machine permits replay
- duplicate suppression is active
- approval exists for quarantined or financial-impacting replay
- replay result is logged

Replay is prohibited when:

- raw payload is missing
- signature failed and no provider evidence exists
- event identity cannot be proven
- replay would create duplicate approval, duplicate cancellation, duplicate refund, or duplicate order
- provider inquiry contradicts the event

## 14. Escalation Rules

| Condition | Escalation Target |
|---|---|
| financial mismatch remains unresolved | Payment Integrity Owner |
| provider trace id missing or ambiguous | Provider Manager |
| parser or mapping defect suspected | Engineering Owner |
| customer claim exists | Store Manager + Customer Support Owner |
| settlement or deposit mismatch | Accounting Owner |
| possible tamper or replay attack | Security Owner + Audit Owner |
| repeated mismatch from same provider | Provider Manager + Incident Owner |

## 15. Customer Communication Guardrail

When a mismatch affects customer-facing payment state, operators must not say:

- “결제 실패입니다” when the state is UNKNOWN.
- “결제 완료입니다” when validation has not passed.
- “취소 완료입니다” when cancellation inquiry is not confirmed.
- “환불되었습니다” when refund settlement or provider confirmation is missing.

Allowed wording must reflect the actual controlled state:

```text
현재 결제망 확인 중입니다. 중복 결제나 미처리 상태가 발생하지 않도록 확인 후 안내드리겠습니다.
```

## 16. Evidence Requirements

Each correction or escalation case must include:

- raw payload
- raw payload hash
- canonical normalized payload
- mismatch detection log
- mapping version
- operator id
- approval id, if required
- before/after state snapshot
- replay log, if replayed
- provider inquiry result, if used
- customer communication record, if applicable
- settlement follow-up record, if financial impact exists

## 17. Closure Criteria

A mismatch case may be closed only when one of the following is true:

- mismatch is corrected using an approved non-financial correction path
- mismatch is proven to be a duplicate and suppressed
- mismatch is quarantined and linked to provider incident
- mismatch is escalated to financial incident workflow
- mismatch is resolved through inquiry and state release
- mismatch is transferred to reconciliation exception workflow
- mismatch is documented as provider mapping gap with approved workaround

## 18. Non-Negotiable Controls

- Raw payload must never be overwritten.
- External response must never bypass validation gate.
- Financial mismatch must never be auto-corrected without policy permission.
- UNKNOWN state must never be forcibly released without evidence.
- Replay must never occur without idempotency and audit log.
- Provider mapping drift must be registered as a gap.
- Manual correction must be append-only and approval-linked.

## 19. Handoff

This runbook hands off to:

- `70470_Audit_External_Response_Correction_Evidence_Manager_Approval_And_Replay_Log.md` for correction evidence and approval audit logging.
- `70480_Register_External_Response_Mapping_Gap_Provider_Drift_And_Open_Issue.md` for unresolved mapping drift and provider gaps.
- `70490_Index_External_Response_Validation_Correction_And_Canonical_Mapping_Closeout_And_Handoff.md` for closeout of the 70400 document group.
