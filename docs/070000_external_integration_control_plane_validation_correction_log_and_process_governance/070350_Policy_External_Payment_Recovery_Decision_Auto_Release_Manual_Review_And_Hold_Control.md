# 070350_Policy_External_Payment_Recovery_Decision_Auto_Release_Manual_Review_And_Hold_Control.md

## 1. Purpose

This policy defines how yoonsul_wait_order_handoff decides the recovery outcome for an external payment that entered `UNKNOWN`, `AMBIGUOUS`, `INQUIRY_PENDING`, `RECOVERY_PENDING`, or `RECONCILIATION_EXCEPTION` state.

The purpose is to prevent external POS, VAN, PG, easy-payment, card-acquirer, or settlement responses from directly releasing a payment state without internal validation, evidence review, and controlled decision routing.

This document belongs to the 70300 External Payment Inquiry, Unknown State, And Recovery Governance lane.

## 2. Scope

This policy applies to recovery decisions for:

- POS payment request timeout
- VAN approval response loss
- PG confirm timeout
- webhook delay or duplicate delivery
- approval success with order creation failure
- order success with payment failure
- cancel or refund timeout
- reversal pending state
- receipt evidence mismatch
- inquiry response mismatch
- settlement file mismatch
- provider-side transaction visibility delay
- store manager manual confirmation request

This policy does not define the full Saga, Outbox, Net Cancel, or Double Entry Ledger architecture. Those are governed under the 75000 Payment Integrity Architecture lane.

## 3. Parent And Related Documents

- Parent Index: `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md`
- Previous: `70340_Policy_External_Payment_Inquiry_Result_Validation_And_State_Release_Control.md`
- Next: `70360_Matrix_External_Payment_Recovery_Decision_State_Evidence_And_Action_Map.md`
- Root External Index: `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- Generation Rule: `70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md`
- Related Payment Integrity Root: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

External inquiry result is not the final recovery decision.

The system must decide recovery only after comparing:

1. internal payment intent,
2. internal order ledger,
3. raw external response,
4. inquiry response,
5. receipt or approval evidence,
6. cancel or reversal evidence,
7. settlement or deposit evidence where available.

No recovery decision may be based on a single external success flag.

## 5. Recovery Decision Types

| Decision Type | Meaning | State Outcome |
|---|---|---|
| Auto Release To Confirmed | Evidence is complete and internally consistent | `PAYMENT_CONFIRMED` |
| Auto Release To Declined | Evidence clearly proves no approval occurred | `PAYMENT_DECLINED` |
| Auto Release To Cancelled | Cancel evidence is complete and matched | `PAYMENT_CANCELLED` |
| Reversal Required | Approval exists but internal order cannot be completed | `REVERSAL_PENDING` |
| Manual Review Required | Evidence exists but cannot be safely interpreted | `MANUAL_REVIEW` |
| Hold Required | Money/order/settlement risk remains unresolved | `PAYMENT_HOLD` |
| Vendor Escalation Required | Provider response is missing, contradictory, or unverifiable | `PROVIDER_ESCALATION` |
| Reconciliation Exception | Real-time decision cannot close; settlement comparison required | `RECONCILIATION_EXCEPTION` |

## 6. Auto Release Eligibility

A payment may be automatically released only when all required checks pass.

### 6.1 Auto Confirm Conditions

Auto confirm is allowed only when:

- inquiry result confirms approval,
- approval number exists,
- external transaction id exists where provider supports it,
- approved amount equals expected amount,
- currency matches,
- store id or merchant id matches,
- terminal id or provider channel matches,
- order id or payment intent id mapping is valid,
- response timestamp is inside the accepted transaction window,
- duplicate approval is not detected,
- no pending cancel, reversal, chargeback, or settlement hold exists,
- raw payload hash and inquiry evidence are stored.

### 6.2 Auto Decline Conditions

Auto decline is allowed only when:

- inquiry confirms no approval,
- no approval number exists,
- provider confirms decline or no transaction found within the accepted query window,
- no delayed webhook or settlement evidence contradicts the result,
- customer-facing message does not imply that money was captured.

### 6.3 Auto Cancel Conditions

Auto cancel is allowed only when:

- cancel inquiry confirms cancellation,
- original approval is matched,
- cancel amount matches the intended cancel amount,
- cancel timestamp is valid,
- cancel approval or cancel transaction id exists where supported,
- no later settlement file shows captured amount remaining unpaid back to the customer.

## 7. Manual Review Triggers

The system must route the case to manual review when any of the following occurs:

- approval exists but order record is missing,
- order exists but approval record is missing,
- amount mismatch is detected,
- tax, discount, service charge, coupon, or point component does not match,
- merchant id or terminal id mismatch occurs,
- provider returns ambiguous response code,
- approval number is missing in a success-like response,
- duplicate approval candidates exist,
- cancel result is unknown,
- inquiry result conflicts with webhook result,
- inquiry result conflicts with raw response,
- inquiry result conflicts with settlement file,
- external provider states that transaction visibility may be delayed,
- customer presents receipt evidence not found in internal ledger,
- store operator confirms terminal-side success but server ledger is unresolved.

## 8. Hold Control

Payment hold is used when money risk remains open.

Hold may apply to:

- order fulfillment,
- refund issuance,
- settlement recognition,
- revenue recognition,
- point accrual,
- coupon consumption,
- customer claim closure,
- store daily closeout.

A hold must include:

- hold reason code,
- affected payment intent id,
- affected order id,
- amount at risk,
- responsible owner,
- next required action,
- evidence packet link,
- release condition,
- escalation deadline.

## 9. Forbidden Actions

The following actions are prohibited:

- marking `UNKNOWN` as failed without inquiry,
- marking `UNKNOWN` as confirmed based only on POS UI success,
- marking order as fulfilled while payment is under unresolved hold,
- issuing refund without checking whether approval actually exists,
- retrying approval with a new idempotency key for the same order before resolving the prior attempt,
- deleting raw payload or inquiry evidence after manual correction,
- manually editing amount, approval number, or provider trace id in the canonical ledger,
- closing customer claim before payment state is released or formally held,
- using settlement revenue recognition before unresolved payment exceptions are cleared.

## 10. Recovery Decision Workflow

```text
UNKNOWN or AMBIGUOUS state detected
→ inquiry request created
→ inquiry result received
→ inquiry result validated
→ recovery decision evaluated
→ auto release, manual review, hold, reversal, escalation, or reconciliation exception
→ evidence packet sealed
→ state transition recorded
→ downstream order, customer, store, settlement, and accounting actions triggered
```

## 11. Evidence Requirements

Every recovery decision must preserve:

- original payment intent,
- original external request payload,
- raw response payload if any,
- inquiry request payload,
- inquiry response payload,
- signature or hash evidence,
- approval or cancel number where available,
- provider trace id,
- decision reason code,
- actor or system job id,
- timestamp of decision,
- resulting state transition,
- downstream actions triggered.

## 12. State Authority

Only the internal Payment State Authority may release a recovery state.

External providers, POS adapters, webhook handlers, store operators, customer center agents, and admin UI screens may submit evidence, but they may not directly finalize payment state.

## 13. Manager Override Boundary

Manager override is allowed only for operational continuity, not financial truth mutation.

A manager may:

- mark customer service handling as pending,
- allow kitchen fulfillment under controlled risk,
- request vendor escalation,
- attach receipt evidence,
- request manual refund review.

A manager may not:

- fabricate approval confirmation,
- erase UNKNOWN state,
- alter approved amount,
- bypass inquiry requirement,
- close reconciliation exception without audit evidence.

## 14. Downstream Release Rules

| Downstream Domain | Release Condition |
|---|---|
| Order fulfillment | payment confirmed or manager-approved controlled risk path |
| Kitchen/KDS | payment confirmed, pay-later policy, or explicitly approved store override |
| Customer notification | must reflect actual state: confirmed, pending, failed, refund pending, or review |
| Point accrual | payment confirmed and not under cancel/reversal hold |
| Coupon burn | payment confirmed or policy-defined reservation state |
| Revenue recognition | settlement-eligible confirmation or accounting-approved exception |
| Refund | approval existence and refund path validated |
| Daily close | unresolved exceptions listed separately |

## 15. Audit And Review

Recovery decisions must be reviewed through:

- real-time exception dashboard,
- store daily closeout exception list,
- provider reconciliation report,
- settlement file comparison,
- monthly payment integrity audit,
- customer claim sample review.

High-risk recovery decisions must be sampled and reviewed by operations, finance, and system governance owners.

## 16. Exit Criteria

This policy is complete when:

- recovery decision types are defined,
- auto release conditions are explicit,
- manual review triggers are explicit,
- hold control fields are defined,
- forbidden actions are documented,
- downstream release rules are mapped,
- evidence requirements are listed,
- next matrix document can translate this policy into a state/evidence/action table.
