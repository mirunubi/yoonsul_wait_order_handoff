# 070430_Policy_External_Response_Correction_Normalization_And_Quarantine_Control.md

## 1. Purpose

This policy defines how external response data from POS, VAN, PG, payment providers, webhook providers, delivery channels, membership providers, kiosk vendors, KDS vendors, tax/accounting systems, and settlement file providers is corrected, normalized, or quarantined before it is allowed to affect internal operational, payment, order, settlement, or audit ledgers.

External responses are not treated as authoritative internal state. They are treated as externally sourced evidence that must pass canonical validation, controlled normalization, and quarantine release gates.

## 2. Scope

This policy applies to all inbound external responses and events handled under the 70000 External Integration Control Plane, including:

- POS payment responses
- VAN approval, cancel, inquiry, and settlement responses
- PG approval, confirm, cancel, refund, virtual account, and webhook responses
- simple payment and wallet provider responses
- cross-border payment responses such as Alipay and WeChat Pay
- delivery app order, cancellation, menu, and settlement events
- external membership, coupon, point, and voucher events
- kiosk vendor and KDS vendor operational events
- external tax, accounting, ERP, and deposit reconciliation files
- all webhook, callback, batch, CSV, Excel, API, RPC, and file-based inbound payloads

## 3. Parent And Related Documents

- Parent index: `70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md`
- Previous: `70420_Spec_External_Response_Canonical_Code_Field_And_Provider_Mapping_Registry.md`
- Next: `70440_Policy_External_Response_Field_Mismatch_Conflict_And_Manual_Review_Control.md`
- Related root: `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- Related generation rule: `70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md`
- Related payment integrity root: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

External response correction is allowed only for representation-level normalization. It must never alter the financial meaning, order meaning, provider meaning, approval meaning, cancellation meaning, or settlement meaning of the external event.

Allowed correction converts data into an internal canonical form.

Forbidden correction changes the substance of the event.

## 5. Correction Classes

| Class | Meaning | Example | Internal Action |
|---|---|---|---|
| Normalization | Safe formatting conversion | trimming whitespace, converting `SUCCESS` to `APPROVED` canonical code | allowed automatically |
| Type conversion | Safe type adaptation | string amount `"10000"` to integer minor unit `10000` | allowed if lossless |
| Provider mapping | Provider-specific code to canonical code | `00` to `APPROVED`, `51` to `DECLINED_INSUFFICIENT_FUNDS` | allowed through registry only |
| Derived enrichment | Adding internal context from verified ledgers | attaching order_id from payment_intent_id | allowed if deterministic |
| Ambiguous correction | Conflicting or incomplete interpretation | success code exists but approval_no missing | quarantine |
| Substantive alteration | Changing business meaning | changing approved amount to expected amount | forbidden |
| Evidence repair | Reconstructing missing payload | manually entering approval number without provider evidence | forbidden unless manual evidence packet approved |

## 6. Automatic Normalization Rules

Automatic normalization may be performed only when all of the following are true:

1. The raw payload is preserved before normalization.
2. The provider mapping rule exists in the canonical mapping registry.
3. The conversion is deterministic and repeatable.
4. No financial amount, tax amount, discount amount, settlement amount, approval status, cancel status, refund status, or order state is changed by judgment.
5. The normalized value can be traced back to the raw source field.
6. The normalization process writes a normalization log.

## 7. Forbidden Corrections

The system must not automatically correct or infer the following:

- missing approval number for a successful payment
- missing cancel approval number for a successful cancellation
- approved amount that differs from expected amount
- tax amount that differs from internal tax calculation
- discount or coupon amount that differs from internal order ledger
- terminal ID mismatch
- merchant ID mismatch
- provider transaction ID mismatch
- duplicated approval response
- success response with failure code in a secondary field
- cancellation success without original approval linkage
- settlement amount mismatch
- delivery order cancellation without external cancellation trace
- membership point usage mismatch
- coupon redemption mismatch

These cases must be quarantined or moved to manual review.

## 8. Quarantine Entry Conditions

An external response must enter quarantine when any of the following conditions exist:

- required canonical field is missing
- provider mapping rule is absent
- signature or timestamp validation failed
- replay or duplicate event is suspected
- event sequence is out of order and cannot be deterministically resolved
- raw response contradicts previously accepted canonical state
- amount, tax, discount, service charge, tip, or settlement value mismatch exists
- approval/cancel/refund state is ambiguous
- provider response is partial, truncated, corrupted, or malformed
- provider result conflicts with inquiry result
- provider result conflicts with settlement file
- operator-entered correction lacks evidence

## 9. Quarantine State Model

| State | Meaning | Release Condition |
|---|---|---|
| `QUARANTINED_RAW_INVALID` | Payload cannot be parsed safely | provider reissue or manual evidence packet |
| `QUARANTINED_MAPPING_MISSING` | No canonical mapping exists | registry update and re-validation |
| `QUARANTINED_SIGNATURE_FAILED` | signature/timestamp validation failed | security review only |
| `QUARANTINED_AMOUNT_MISMATCH` | money values mismatch | inquiry + ledger verification |
| `QUARANTINED_STATE_CONFLICT` | external state conflicts with internal state | recovery decision approval |
| `QUARANTINED_DUPLICATE_OR_REPLAY` | duplicate/replay suspected | idempotency verification |
| `QUARANTINED_EVIDENCE_INSUFFICIENT` | evidence does not support release | manager and audit approval |

## 10. Correction Workflow

```text
1. Receive external response
2. Store raw payload and raw hash
3. Validate envelope, signature, timestamp, provider, and trace metadata
4. Map provider fields to canonical fields
5. Apply allowed normalization only
6. Validate canonical acceptance rules
7. If accepted, emit canonical response event
8. If not accepted, place in quarantine
9. If correction is needed, create correction request
10. Validate correction evidence
11. Approve or reject correction
12. Replay corrected canonical event only through controlled replay path
13. Write audit evidence
```

## 11. Correction Request Requirements

Every correction request must include:

- correction request ID
- raw event ID
- provider name
- provider transaction ID or trace ID
- affected order ID or payment intent ID
- raw value
- proposed canonical value
- correction class
- reason code
- supporting evidence
- requester ID
- approver ID if required
- created_at and approved_at
- replay decision
- audit packet reference

## 12. Manual Correction Approval

Manual correction requires approval when:

- money fields are affected
- order fulfillment state is affected
- customer-visible payment status is affected
- refund, cancellation, or reversal state is affected
- settlement or deposit ledger is affected
- external provider liability may be disputed
- customer claim may result
- accounting or tax evidence may change

Manual correction must not overwrite raw payload. It creates a new canonical correction event linked to the original event.

## 13. Raw Payload Preservation

Raw payloads must be preserved unchanged. The following are mandatory:

- raw payload body
- raw headers when available
- received timestamp
- provider IP or source metadata when available
- signature header
- timestamp header
- trace ID
- raw payload hash
- canonical mapping version
- normalization version
- correction history

## 14. Canonical Mapping Version Control

Canonical mapping rules must be versioned. A response accepted under mapping version `v1` must remain auditable even after mapping version `v2` is introduced.

Mapping changes must not retroactively mutate accepted events. Historical events may be reprocessed only through an explicit replay process with audit evidence.

## 15. Reprocessing And Replay Control

Quarantined or corrected events may be replayed only when:

1. The raw event is preserved.
2. The correction or mapping rule is approved.
3. The target aggregate is not in a terminal conflicting state.
4. Idempotency key and event sequence are checked.
5. Replay action is written to audit log.
6. Resulting state transition is validated by the state machine.

## 16. Operator Prohibitions

Operators must not:

- edit raw external payloads
- mark payment as confirmed without approval evidence
- force release a quarantined money event without inquiry or provider proof
- adjust amount to match internal expectation
- create cancellation success without provider cancel evidence
- delete duplicate events to hide the duplicate condition
- bypass audit log for customer claim handling
- treat provider screen capture alone as final evidence unless policy allows it

## 17. Evidence Packet

A correction or quarantine release evidence packet must include:

- original raw response
- normalized response
- mapping version
- validation failure reason
- correction reason
- inquiry result if applicable
- provider communication record if applicable
- manager approval if applicable
- before/after state transition
- customer communication record if applicable
- final audit hash

## 18. Downstream Effects

A corrected canonical event may affect:

- payment ledger
- order ledger
- fulfillment state
- customer receipt state
- cancellation/refund ledger
- settlement expectation ledger
- reconciliation exception register
- customer claim register
- provider dispute packet

Each downstream update must be emitted as a separate auditable event. Correction must not silently mutate downstream ledgers.

## 19. Acceptance Criteria

This policy is satisfied when:

- all external responses are stored raw before correction
- all provider-specific values are mapped through versioned canonical registry
- safe normalization is separated from substantive correction
- forbidden corrections are blocked
- quarantine states are explicit
- manual correction creates new evidence, not payload mutation
- replay is controlled and auditable
- downstream ledgers are updated through explicit events

## 20. Handoff

This policy hands off to:

- `70440_Policy_External_Response_Field_Mismatch_Conflict_And_Manual_Review_Control.md` for field mismatch and conflict review
- `70450_Runbook_External_Response_Correction_Quarantine_Release_And_Replay_Action.md` for operator procedures
- `70460_Audit_External_Response_Correction_Evidence_Mapping_Version_And_Trace_Log.md` for correction audit evidence
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md` for payment integrity architecture integration
