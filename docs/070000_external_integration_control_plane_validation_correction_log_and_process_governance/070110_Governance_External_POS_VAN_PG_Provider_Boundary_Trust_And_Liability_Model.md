# 070110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md

## 1. Purpose

This document defines the governance model for external POS, VAN, PG, simple payment, card acquirer, settlement, and payment-related provider boundaries within the Yoonsul Wait Order Handoff external integration control plane.

The purpose is to ensure that external payment and transaction providers are never treated as fully trusted internal systems. They are treated as external financial event sources whose requests, responses, callbacks, files, and operational claims must be validated, corrected, logged, reconciled, and preserved as evidence before the Yoonsul core ledger accepts any final state.

This document belongs under the 70000 External Integration Control Plane band and is linked from:

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`

## 2. Scope

This governance applies to all external payment-facing and transaction-facing providers, including but not limited to:

- POS providers
- VAN providers
- PG providers
- simple payment providers
- Alipay / WeChat Pay / cross-border payment providers
- card companies and acquirers
- settlement file providers
- webhook and callback providers
- external order apps
- delivery apps
- kiosk vendors
- KDS vendors
- external membership and coupon providers
- tax and accounting integration providers

This document focuses on boundary, trust, liability, and evidence control. It does not replace provider-specific API specs or operational runbooks.

## 3. Core Principle

External integration is divided into two separate defensive layers.

```text
Layer 1: Sandbox / Adapter Boundary
- Prevents external POS or vendor software from contaminating the Yoonsul core.
- Limits process, network, credential, file, and runtime authority.
- Treats external software as potentially unstable or compromised.

Layer 2: Financial Integrity Boundary
- Prevents money-state corruption.
- Validates payment, cancellation, refund, settlement, and fee data.
- Preserves raw payloads and trace evidence.
- Resolves unknown, mismatched, duplicated, delayed, and disputed states.
```

The sandbox prevents infection. The financial integrity boundary prevents money accidents.

These two layers must never be merged into one control.

## 4. Trust Classification

External providers are classified by trust level.

| Trust Class | Description | Treatment |
|---|---|---|
| Class A: Certified Financial Provider | Registered VAN, PG, card acquirer, or regulated payment provider | Technically integrated but still validated against internal ledger |
| Class B: Certified Operational Provider | POS, kiosk, KDS, delivery, or membership provider with formal contract and test certification | Allowed through adapter with field-level validation |
| Class C: Limited Integration Provider | Provider with partial API, partial callback, or weak inquiry capability | Restricted scope, manual review path required |
| Class D: Unverified Provider | No formal certification, no stable trace, no inquiry, no settlement evidence | Not allowed for production money flow |
| Class E: Prohibited Provider | Unregistered PG, tax evasion terminal, undocumented payment broker, or provider encouraging illegal rebate/tax evasion | Blocked and escalated to legal/compliance review |

No external provider may write directly to the canonical order, payment, settlement, or accounting ledger.

## 5. Boundary Rule

Every external provider must pass through the External Integration Control Plane.

```text
External Provider
→ Provider Adapter
→ Sandbox Boundary
→ Inbound Normalization
→ Raw Payload Evidence Store
→ Validation Gate
→ State Authority Decision
→ Internal Ledger Event
→ Reconciliation / Audit / Recovery
```

The following shortcuts are prohibited:

```text
External Provider → Core Order Ledger
External Provider → Core Payment Ledger
External Provider → Settlement Ledger
External Provider → Accounting Ledger
External Provider → Store UI Final State Without Validation
External Provider → Customer Notification Without State Authority
```

## 6. State Authority Model

External providers may report events. They do not hold final state authority inside Yoonsul.

| State Area | External Provider Role | Yoonsul Role |
|---|---|---|
| Payment request | Receives and processes request | Creates payment intent and expected value |
| Approval result | Reports approval or decline | Validates amount, order, terminal, trace, and response code |
| Cancellation | Processes cancel request | Confirms cancel state and updates internal ledger only after verification |
| Refund | Reports refund result | Validates refund reference, amount, and original approval mapping |
| Settlement | Provides settlement file or report | Reconciles against approved/cancelled/refunded ledger |
| Fee | Reports fee deduction | Verifies fee policy, provider contract, and accounting category |
| Customer notification | May notify customer externally | Yoonsul must not rely on external notification as internal final state |

The internal canonical state is determined only after validation and ledger posting.

## 7. Provider Liability Model

Provider responsibility must be defined before production integration.

| Liability Area | Required Definition |
|---|---|
| Request acceptance | When provider considers a request received |
| Response finality | Which response codes are final, temporary, retryable, or ambiguous |
| Timeout handling | Whether timeout may still result in successful external approval |
| Inquiry support | Which keys can be used to query state after failure |
| Duplicate handling | Provider behavior for repeated idempotency keys or repeated requests |
| Cancellation guarantee | Whether cancellation is immediate, asynchronous, or settlement-adjusted |
| Settlement correction | How provider issues corrected files or adjustment entries |
| Dispute support | What evidence provider supplies for customer/store disputes |
| Data retention | Minimum retention period for approval, cancel, refund, and settlement evidence |
| Incident SLA | Provider response time for payment-state ambiguity and money-impacting defects |

A provider that cannot define timeout, inquiry, duplicate, and settlement correction behavior must not be promoted to production-critical status.

## 8. Mandatory Provider Capabilities

For money-impacting integration, the provider must support the following capabilities or have an approved exception.

```text
1. Payment request
2. Payment response with trace metadata
3. Payment inquiry
4. Last transaction inquiry or equivalent fallback
5. Cancellation request
6. Cancellation inquiry
7. Refund or reversal support, where applicable
8. Receipt or slip evidence retrieval
9. Settlement report or settlement file
10. Error code registry
11. Retry and duplicate behavior documentation
12. Test/sandbox environment
13. Production credential separation
14. Incident contact and escalation channel
15. Data retention and evidence export support
```

If inquiry is not available, timeout cannot be treated as failure. It must enter manual review or provider escalation.

## 9. Required Evidence From External Providers

Every provider integration must capture and preserve evidence.

| Evidence Type | Examples |
|---|---|
| Request evidence | request id, idempotency key, order id, expected amount, terminal id |
| Response evidence | raw payload, response code, approval number, approval timestamp |
| Trace evidence | provider transaction id, VAN trace id, PG key, terminal trace, merchant id |
| Receipt evidence | slip text, receipt number, receipt URL, print data |
| Cancellation evidence | cancel id, original approval reference, cancel response code |
| Settlement evidence | settlement date, settlement file, deposit amount, fee, adjustment |
| Inquiry evidence | inquiry request, inquiry response, time of inquiry, result mapping |
| Operator evidence | manager action, override reason, customer claim reference |
| Audit evidence | hash, signature, storage location, retention class |

Raw payload must be stored before normalization or interpretation.

## 10. Validation Responsibility

Yoonsul owns the validation responsibility even when the provider is regulated or certified.

Validation must include:

```text
- order id match
- store id match
- terminal id match
- expected amount match
- tax/discount/service charge match
- currency match
- response code interpretation
- approval number presence
- provider trace id uniqueness
- duplicate transaction check
- request hash match
- time-window validity
- cancellation/refund reference match
- settlement mapping
```

A provider success response is not enough to finalize internal payment state.

## 11. Ambiguous State Governance

Any state that cannot be proven must be treated as ambiguous.

Examples:

```text
- request timeout
- response timeout
- socket disconnect after external approval
- provider returns success without approval number
- provider returns unknown response code
- duplicate approval numbers
- same order with multiple external transaction ids
- amount mismatch
- cancel timeout
- refund pending without inquiry result
- settlement file missing transaction
- settlement file includes unknown transaction
```

Ambiguous state must not be collapsed into success or failure.

Required handling:

```text
1. Freeze final customer/order state if money impact is possible.
2. Create ambiguity event.
3. Run provider inquiry if available.
4. Compare with internal intent and response ledger.
5. Escalate to manager/provider if inquiry is inconclusive.
6. Record manual decision with reason and evidence.
7. Reconcile again at day close and settlement close.
```

## 12. Contract Requirements

Provider contracts must include technical and operational clauses for:

- API specification and versioning
- response code registry
- timeout and retry behavior
- inquiry support
- cancellation and refund behavior
- duplicate prevention behavior
- settlement file format
- incident escalation SLA
- data retention period
- audit evidence provision
- security responsibility boundary
- production credential handling
- personal information and payment information handling
- subcontractor disclosure, where applicable
- legal compliance and registration status
- prohibition of illegal rebate, tax evasion, or unregistered payment processing

External provider onboarding must not proceed only on sales or commercial terms.

## 13. Provider Onboarding Gate

Before production use, every provider must pass the following gate.

| Gate | Required Result |
|---|---|
| Legal/registration check | Provider is legally usable for intended transaction type |
| Contract review | Liability, evidence, SLA, and settlement terms are documented |
| API/spec review | Request, response, inquiry, cancel, refund, settlement specs reviewed |
| Sandbox test | Success, failure, timeout, duplicate, cancel, refund, and inquiry tested |
| Field registry | Required fields mapped into Yoonsul canonical fields |
| Error registry | Provider response codes mapped into standard state classes |
| Recovery drill | Timeout/unknown/double approval/cancel failure drill completed |
| Settlement drill | Day-close and settlement reconciliation test completed |
| Operator drill | Store operator response path tested |
| Audit drill | Raw payload, hash, and evidence export verified |

Failure in payment inquiry, ambiguous state recovery, or settlement evidence must block production unless formally waived.

## 14. Provider Runtime Monitoring

Runtime monitoring must track:

```text
- request count
- success count
- decline count
- timeout count
- ambiguous count
- duplicate response count
- inquiry count
- inquiry failure count
- cancellation count
- cancellation failure count
- settlement mismatch count
- response latency
- provider error code distribution
- terminal/provider/store specific anomaly
```

Provider-specific thresholds must trigger incident workflow.

## 15. Separation From Internal Implementation WorkPackage

The 06000 POS Gateway implementation band may define internal adapter, queue, retry, idempotency, and implementation work.

The 70000 External Integration Control Plane defines cross-provider governance:

```text
06000 band = how we build the internal gateway machinery
70000 band = how we control external provider truth, money state, evidence, correction, and liability
```

The 70000 band has authority over external integration acceptance, validation, recovery, and closeout rules.

## 16. Related Documents

Upstream:

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`

Downstream candidates:

- `70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md`
- `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`
- `70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md`
- `70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md`
- `70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md`
- `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`
- `70180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md`
- `70190_Index_POS_VAN_PG_External_Payment_Integration_Closeout_And_Handoff.md`

## 17. Closeout Rule

This document is complete when the project accepts the following governance rule:

```text
External providers may originate financial events, but they do not own final Yoonsul money state.
Final state requires internal intent, external response, validation, evidence, and reconciliation.
```
