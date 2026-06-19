# 070440_Policy_External_Response_Field_Mismatch_Conflict_And_Manual_Review_Control.md

## 1. Purpose

This policy defines how yoonsul_wait_order_handoff handles field mismatch, conflicting values, ambiguous provider responses, and manual review escalation for external integration events.

External responses from POS, VAN, PG, simple payment providers, acquirers, delivery apps, kiosk vendors, KDS vendors, membership providers, coupon providers, tax/accounting systems, and webhook sources must not be trusted as direct internal state authority when field values conflict with internal canonical records.

The purpose of this document is to prevent money accidents, order inconsistency, incorrect settlement, duplicate fulfillment, incorrect customer notification, and irreversible accounting distortion caused by blind acceptance of external fields.

## 2. Scope

This policy applies to all inbound external response records that fail or partially fail canonical validation due to mismatch, conflict, ambiguity, missing fields, duplicated fields, late-arriving fields, malformed fields, unsupported provider codes, or inconsistent business state.

Covered response types include:

- Payment approval responses
- Payment cancel responses
- Refund responses
- Reversal responses
- Inquiry responses
- Webhook callbacks
- POS RPC responses
- VAN daemon responses
- PG API responses
- External order app callbacks
- Delivery app order/cancel events
- Membership point adjustment responses
- Coupon/voucher redemption responses
- Kiosk/KDS vendor status callbacks
- Tax/accounting export/import acknowledgements
- Settlement and deposit file records

## 3. Parent And Related Documents

- Parent index: `70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md`
- Previous: `70430_Policy_External_Response_Correction_Normalization_And_Quarantine_Control.md`
- Next: `70450_Matrix_External_Response_Mismatch_Type_Severity_Action_And_Escalation_Map.md`
- Related: `70410_Policy_External_Response_Validation_Gate_And_Canonical_Acceptance_Control.md`
- Related: `70420_Spec_External_Response_Canonical_Code_Field_And_Provider_Mapping_Registry.md`
- Related: `70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md`
- Related: `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md`
- Related: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

An external field mismatch is not a formatting inconvenience. It is a potential integrity incident.

The system must distinguish between:

1. Safe normalization
2. Correctable mismatch
3. Review-required conflict
4. Quarantine-required conflict
5. Security or fraud-suspected conflict
6. Accounting or settlement exception

Only safe normalization and explicitly approved correction classes may be processed automatically. Money-bearing, fulfillment-bearing, identity-bearing, settlement-bearing, and legal-evidence-bearing conflicts must be escalated to manual review or quarantine.

## 5. Definitions

| Term | Definition |
|---|---|
| Mismatch | A field value differs from the expected internal canonical value but may be explainable. |
| Conflict | A mismatch that changes payment, order, fulfillment, customer, settlement, or legal meaning. |
| Safe normalization | Format-only correction that does not alter business meaning. |
| Manual review | Human or authorized operations review required before state release. |
| Quarantine | Isolation of an event from internal state mutation until evidence is complete. |
| Canonical record | Internal authoritative representation used for downstream decisions. |
| Raw response | Original provider payload preserved without mutation. |
| Evidence packet | Collection of raw payload, hash, trace, inquiry result, operator action, and decision log. |

## 6. Mismatch Classification

### 6.1 Format-Only Mismatch

Examples:

- Date format difference
- Case difference in provider code
- Extra whitespace
- Currency symbol included in numeric field
- Receipt text line ending difference
- Provider-specific padding characters

Allowed action:

- Normalize automatically only if registry rule exists.
- Preserve raw value.
- Store normalized value with correction reason.

Forbidden action:

- Do not infer missing money-bearing values.
- Do not modify raw payload.

### 6.2 Identity Mismatch

Examples:

- `store_id` mismatch
- `terminal_id` mismatch
- merchant ID mismatch
- provider ID mismatch
- order ID mismatch
- payment intent ID mismatch
- customer account mismatch

Allowed action:

- Quarantine by default.
- Require trace review.
- Require inquiry or provider confirmation if payment-related.

Forbidden action:

- Do not attach the response to the nearest order by amount/time only.
- Do not release payment state based on partial identity match.

### 6.3 Amount Mismatch

Examples:

- Approved amount differs from expected amount
- Tax amount differs
- Discount amount differs
- Service charge differs
- Tip amount differs
- Refund amount differs
- Partial cancel amount differs
- Settlement net amount differs

Allowed action:

- Quarantine or manual review depending on severity.
- Recalculate expected values from immutable order snapshot.
- Trigger inquiry for payment/cancel/refund responses.

Forbidden action:

- Do not auto-adjust order amount to match provider response.
- Do not confirm payment when amount differs by even 1 unit unless an explicit rounding policy exists for that provider and currency.

### 6.4 State Mismatch

Examples:

- Provider says approved, internal state says cancelled
- Provider says cancelled, internal state says fulfilled
- Provider sends refund success before approval is confirmed
- Late webhook attempts to reverse a newer state
- Inquiry result conflicts with raw response

Allowed action:

- Apply state machine validation.
- Hold state release.
- Route to recovery or reconciliation exception.

Forbidden action:

- Do not allow late events to move state backward.
- Do not overwrite confirmed internal state without compensation workflow.

### 6.5 Evidence Mismatch

Examples:

- Success response without approval number
- Cancel success without original approval reference
- Receipt data missing
- Trace ID missing
- Hash mismatch
- Signature mismatch
- Timestamp outside allowed window

Allowed action:

- Quarantine if evidence is required for legal, settlement, or dispute defense.
- Request inquiry or provider evidence.

Forbidden action:

- Do not treat provider success string alone as sufficient evidence.

### 6.6 Settlement Mismatch

Examples:

- Approval exists but settlement file missing
- Settlement file includes transaction absent from internal ledger
- Fee differs from expected contract rate
- Deposit amount differs from expected net amount
- Refund offset appears in different settlement date

Allowed action:

- Create reconciliation exception.
- Hold accounting close if material.
- Preserve provider file and internal calculation evidence.

Forbidden action:

- Do not manually edit accounting ledger to force match.

## 7. Automatic Correction Eligibility

Automatic correction is allowed only when all conditions below are met:

1. The mismatch is format-only or registry-approved.
2. Raw payload is preserved.
3. Correction rule is versioned.
4. Correction does not alter payment amount, order identity, customer identity, store identity, settlement amount, approval status, cancel status, refund status, or legal evidence meaning.
5. Correction result is logged with before/after value.
6. The provider is listed in the canonical mapping registry.

If any condition is not met, the event must not be automatically corrected.

## 8. Manual Review Required Conditions

Manual review is mandatory when any of the following occur:

- Money-bearing field mismatch
- Order identity mismatch
- Store or terminal mismatch
- Missing approval number in success response
- Cancel/refund status conflict
- Inquiry result contradicts original response
- Replay event attempts to alter state
- Provider-specific response code is unknown
- Duplicate approval is detected
- Duplicate cancel or refund is detected
- Settlement file does not match internal ledger
- Provider response cannot be mapped to canonical code
- Any event has security signature anomaly

## 9. Quarantine Required Conditions

The event must be quarantined immediately when:

- Signature verification fails
- Timestamp window is invalid
- Replay attack is suspected
- Provider identity is not registered
- Terminal or merchant identity conflicts
- Raw payload hash validation fails
- The event attempts to mutate a closed or reconciled state
- The event contains conflicting approval and cancel indicators
- The event is associated with a payment already in dispute
- The event is associated with legal hold

## 10. Manual Review Workflow

1. Receive mismatch event.
2. Preserve raw payload and generate hash.
3. Assign mismatch classification.
4. Block automatic state mutation.
5. Create review case.
6. Attach internal expected record snapshot.
7. Attach provider raw response.
8. Attach canonical mapping result.
9. Attach inquiry result when applicable.
10. Assign responsible owner.
11. Decide one of the following outcomes:
    - Accept canonical value
    - Reject external response
    - Request provider inquiry
    - Trigger reversal or compensation
    - Mark reconciliation exception
    - Escalate to legal/compliance
    - Keep hold pending evidence
12. Record manager decision log.
13. Emit audit event.

## 11. Forbidden Manual Actions

Operators and managers must not:

- Edit raw payload.
- Delete mismatch evidence.
- Force payment confirmation without evidence.
- Force cancel confirmation without cancel evidence.
- Change money amounts directly in order ledger.
- Reassign provider response to a different order by guess.
- Close customer claim before inquiry evidence is attached.
- Suppress reconciliation exception to complete daily close.
- Override a quarantined event without authorization.

## 12. State Release Rules

A mismatched event may be released only when:

- The canonical mapping result is deterministic.
- Required identifiers match.
- Required evidence exists.
- Any inquiry result confirms the intended state.
- The release action is logged.
- If manual review was required, manager approval is attached.
- Reconciliation dependency is either cleared or explicitly held.

## 13. Evidence Requirements

Each mismatch case must preserve:

- Raw provider payload
- Payload hash
- Received timestamp
- Provider identifier
- Store identifier
- Terminal identifier if applicable
- Internal expected record snapshot
- Canonical mapping output
- Mismatch classification
- Inquiry request and response if applicable
- Operator notes
- Manager approval or rejection
- Final state release decision
- Reconciliation follow-up reference

## 14. Severity Model

| Severity | Description | Default Action |
|---|---|---|
| S0 | Format-only mismatch | Auto-normalize if registry rule exists |
| S1 | Non-money metadata mismatch | Manual review if not registry-approved |
| S2 | Identity, amount, approval, cancel, refund, or fulfillment mismatch | Hold and manual review |
| S3 | Settlement, accounting, dispute, or legal evidence mismatch | Reconciliation exception and compliance review |
| S4 | Signature, tamper, replay, unknown provider, or fraud-suspected mismatch | Quarantine and security escalation |

## 15. Relationship To Payment Integrity Architecture

This policy is part of the 70000 External Integration Control Plane. When mismatch involves money, order fulfillment, inventory, point, coupon, settlement, accounting, or event delivery integrity, the case must also be linked to the 75000 Payment Integrity Architecture lane.

Examples:

- Duplicate approval -> Idempotency and duplicate prevention lane
- Timeout with provider approval -> Net cancel and recovery lane
- Payment success/order failure -> Saga compensation lane
- DB commit/event publish mismatch -> Transactional Outbox lane
- Settlement imbalance -> Double-entry ledger lane

## 16. Closeout Criteria

This policy is complete only when:

- Mismatch classes are defined.
- Auto-correction eligibility is constrained.
- Manual review and quarantine conditions are defined.
- Forbidden actions are documented.
- Evidence requirements are defined.
- State release rules are defined.
- Linkage to 75000 payment integrity lane is established.

## 17. Open Gaps

- Provider-specific mismatch examples must be added per integration partner.
- Detailed UI requirements for review console are deferred.
- Detailed authorization levels for manual override are deferred.
- Accounting exception workflow is delegated to the settlement/reconciliation lane.
- Security incident escalation details are delegated to the external integration security lane.
