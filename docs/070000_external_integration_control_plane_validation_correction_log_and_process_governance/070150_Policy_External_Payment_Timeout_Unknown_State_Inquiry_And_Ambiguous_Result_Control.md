# 070150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md

## 1. Purpose

This policy defines how yoonsul_wait_order_handoff shall control external payment timeout, unknown payment state, inquiry recovery, and ambiguous payment result handling across POS, VAN, PG, simple payment, card acquirer, and cross-border payment integrations.

The purpose of this policy is to prevent money accidents caused by treating communication failure as payment failure. A timeout does not prove that payment failed. It only proves that the local system did not receive a reliable final result within the expected time window.

## 2. Scope

This policy applies to all external payment integrations under the 70000 External Integration Control Plane, including but not limited to:

- POS payment RPC
- VAN approval and cancel response
- PG authorization, confirm, cancel, and webhook response
- simple payment approval through QR, barcode, app-to-app, or wallet token
- Alipay, WeChat Pay, and other cross-border payment response flows
- card acquirer approval and cancellation result
- settlement file discrepancy related to missing or ambiguous approval records
- external payment provider inquiry, last transaction lookup, and reversal control

This policy does not replace sandbox isolation policies. Sandbox isolation prevents external POS or vendor systems from contaminating the internal runtime. This policy controls financial state integrity after payment communication begins.

## 3. Core Principle

The system shall never convert an external payment timeout directly into final payment failure.

Timeout shall be treated as an unknown financial state until resolved by inquiry, reconciliation, reversal, provider confirmation, or authorized manual review.

Required principle:

```text
Timeout is not failure.
Missing response is not decline.
External success is not internal confirmation.
External failure is not final until inquiry confirms no financial movement.
```

## 4. State Authority Rule

External providers may produce payment events, but they do not own final internal state authority.

Final payment state authority belongs to the internal Payment Integrity Control Plane after the following checks are complete:

1. request ledger exists;
2. response or inquiry result is recorded;
3. canonical field mapping is complete;
4. amount, order, store, terminal, and trace validation pass;
5. duplicate approval and duplicate cancellation checks pass;
6. required evidence is stored;
7. ambiguity state is resolved.

## 5. Required Payment Unknown States

The system shall support at minimum the following unknown or ambiguous states:

| State | Meaning | Final Order Allowed |
|---|---|---|
| `TIMEOUT_UNKNOWN` | Request was sent but reliable final response was not received | No |
| `RESPONSE_LOST_UNKNOWN` | Provider may have approved or declined, but response was lost | No |
| `INQUIRY_PENDING` | System is checking external provider state | No |
| `AMBIGUOUS_APPROVAL` | Evidence indicates possible approval but not enough to confirm | No |
| `AMBIGUOUS_CANCEL` | Cancel/reversal result is not confirmed | No |
| `MISMATCHED_RESPONSE` | External response conflicts with internal request ledger | No |
| `REVERSAL_PENDING` | Payment may need cancellation or reversal | No |
| `MANUAL_REVIEW_REQUIRED` | Automated resolution failed or is unsafe | No |
| `RECONCILIATION_EXCEPTION` | Later settlement or batch data conflicts with internal state | No |

No unknown state may be displayed to the customer or store operator as simple success or failure unless the UX text clearly indicates that verification is in progress.

## 6. Timeout Classification

Timeouts shall be classified by where the interruption occurred.

| Timeout Class | Example | Required Action |
|---|---|---|
| Client-to-Core timeout | app/kiosk loses connection to our backend | preserve payment intent and query backend state |
| Core-to-POS timeout | backend called POS adapter but got no response | mark `TIMEOUT_UNKNOWN`, trigger inquiry |
| POS-to-VAN timeout | POS reports communication error after send | mark `TIMEOUT_UNKNOWN`, require provider inquiry |
| VAN/PG response timeout | provider may have approved but callback failed | mark `RESPONSE_LOST_UNKNOWN`, query by trace key |
| Cancel timeout | cancellation request sent but result unknown | mark `AMBIGUOUS_CANCEL`, trigger cancel inquiry |
| Webhook timeout | provider callback delayed or duplicated | store idempotently, do not override confirmed state without validation |
| Settlement mismatch | settlement file shows transaction not in internal ledger | create reconciliation exception and freeze financial finalization |

## 7. Mandatory Inquiry Capability

Before a provider integration may be certified for production, the provider contract or technical interface shall support a safe recovery path for ambiguous payment state.

At minimum, the integration readiness checklist shall verify whether the provider supports:

- approval inquiry by external transaction ID;
- approval inquiry by approval number;
- approval inquiry by terminal ID, amount, and time window;
- last transaction inquiry;
- cancel inquiry;
- receipt or slip reprint/fetch;
- settlement file export;
- merchant/store/terminal scoped transaction search;
- response code dictionary;
- trace ID or provider reference ID;
- provider support escalation path for unresolved ambiguity.

If inquiry capability is absent, the provider shall be classified as high-risk and may only be used under limited pilot scope or manual operation control.

## 8. Timeout Handling Process

When a payment request times out, the system shall execute the following process.

```text
1. Do not mark payment as failed.
2. Store request ledger and timeout event.
3. Set payment state to TIMEOUT_UNKNOWN.
4. Prevent duplicate automatic retry unless idempotency is guaranteed.
5. Trigger inquiry using available provider keys.
6. If inquiry confirms approval, validate amount/order/store/terminal/trace.
7. If validation passes, confirm payment.
8. If inquiry confirms no approval, mark declined or failed safely.
9. If inquiry is unavailable or conflicting, move to MANUAL_REVIEW_REQUIRED.
10. If approval exists but order confirmation failed, execute compensation process.
```

## 9. Inquiry Resolution Rules

| Inquiry Result | Internal Action |
|---|---|
| approval exists and validation passes | mark `CONFIRMED` |
| approval exists but amount/order mismatch | mark `MISMATCHED_RESPONSE` and require review |
| approval exists but order failed | mark `REVERSAL_PENDING` or recreate order by approved evidence |
| no approval exists | mark `DECLINED` or `FAILED_NO_FINANCIAL_MOVEMENT` |
| provider returns uncertain response | remain `AMBIGUOUS_APPROVAL` |
| inquiry API unavailable | escalate to manual review and provider support |
| duplicate approvals found | confirm one canonical payment, cancel/reverse duplicates |
| cancellation confirmed | mark `CANCELLED` |
| cancellation not found | retry cancellation under controlled idempotency or escalate |

## 10. Duplicate Retry Control

Automatic retry after timeout is prohibited unless all below conditions are satisfied:

1. idempotency key is supported end-to-end;
2. provider guarantees duplicate suppression;
3. original request trace ID is reused or linked;
4. retry count is bounded;
5. retry result is tied to the original payment intent;
6. duplicate approval detection runs before internal confirmation.

If these conditions are not satisfied, the system shall perform inquiry first rather than retrying payment.

## 11. Customer And Store UX Rule

For unknown payment states, the system shall avoid misleading messages.

Forbidden messages:

```text
결제 실패했습니다. 다시 결제해주세요.
결제가 완료되었습니다.
```

Allowed controlled messages:

```text
결제 결과를 확인 중입니다. 중복 결제를 방지하기 위해 잠시만 기다려 주세요.
결제망 응답이 지연되고 있습니다. 직원 확인 후 안내드리겠습니다.
결제 승인 여부를 확인 중입니다. 다시 결제하지 마세요.
```

Store operator screen shall show:

- order ID;
- payment intent ID;
- expected amount;
- provider;
- terminal ID;
- current unknown state;
- inquiry status;
- recommended action;
- prohibited action;
- manager override requirement.

## 12. Manual Review Entry Criteria

Manual review shall be required when:

- inquiry result conflicts with response payload;
- amount mismatch exists;
- approval exists without matching order;
- order exists without reliable payment result;
- cancel result is unknown after retry limit;
- duplicate approvals are detected;
- provider trace ID is missing;
- settlement file later reveals unmatched transaction;
- provider support confirmation is needed;
- customer claim is filed before state resolution.

Manual review actions must be logged with actor, timestamp, reason, evidence, before/after state, and manager approval reference.

## 13. Evidence Requirements

Every unknown or ambiguous payment state shall preserve the following evidence when available:

- payment intent ledger record;
- external request payload hash;
- external response raw payload;
- timeout event log;
- POS adapter log;
- provider trace ID;
- approval number;
- cancel number;
- receipt/slip data;
- inquiry request and response;
- operator action log;
- customer-facing message log;
- reconciliation batch reference;
- provider support ticket reference.

Evidence shall be immutable after finalization except by controlled correction event. Correction shall never overwrite original evidence.

## 14. Compensation Control

When inquiry confirms that money moved but internal order state did not finalize, the system shall select one of the following compensation paths:

| Condition | Compensation Path |
|---|---|
| payment approved, order can be safely restored | recreate or confirm order from payment evidence |
| payment approved, order cannot be fulfilled | execute cancellation/reversal |
| duplicate payment approved | preserve canonical approval and cancel duplicate approval |
| cancel timeout | perform cancel inquiry before customer notification |
| customer left store before resolution | create customer claim packet and manager follow-up task |

Compensation shall not be executed by blind retry. It must be tied to payment intent, external trace, and approval evidence.

## 15. Reconciliation Backstop

Even after real-time inquiry resolves a timeout, the transaction shall be rechecked during:

1. store day-close reconciliation;
2. provider settlement batch reconciliation;
3. deposit reconciliation;
4. fee and commission reconciliation;
5. monthly accounting close.

If any later source contradicts the resolved state, the system shall reopen the payment as `RECONCILIATION_EXCEPTION` without deleting the previous resolution history.

## 16. Prohibited Practices

The following practices are prohibited:

- treating timeout as final failure;
- asking customer to retry before inquiry or duplicate check;
- overwriting unknown state with success based only on POS display;
- confirming order without amount validation;
- cancelling payment without checking whether cancellation already succeeded;
- discarding raw response payload;
- allowing store operator to manually mark payment confirmed without evidence;
- using provider integrations that lack inquiry capability in production without risk acceptance;
- merging request and response ledgers into a single mutable row without audit history.

## 17. Required Links

This policy shall be linked from:

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`
- `70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md`
- `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`
- `70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md`
- `70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md`
- `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`
- `70180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md`

## 18. Closeout Rule

A payment timeout or ambiguous result may be closed only when one of the following is true:

1. provider inquiry confirms no financial movement;
2. provider inquiry confirms approval and internal validation passes;
3. duplicate or erroneous approval is cancelled and cancellation is verified;
4. settlement reconciliation confirms final state;
5. authorized manual review closes the case with evidence and risk acceptance.

No timeout case may be closed by assumption.

## 19. Next Document

Next document:

`70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md`
