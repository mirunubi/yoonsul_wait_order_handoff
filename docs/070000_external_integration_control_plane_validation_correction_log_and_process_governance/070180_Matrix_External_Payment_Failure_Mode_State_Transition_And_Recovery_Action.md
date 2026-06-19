# 070180_Matrix_External_Payment_Failure_Mode_State_Transition_And_Recovery_Action.md

## 1. Purpose

This matrix defines the controlled failure-mode handling model for external payment integrations in `yoonsul_wait_order_handoff`.

External payment providers, including POS, VAN, PG, simple-pay networks, card acquirers, global QR payment gateways, settlement file providers, webhook emitters, delivery apps, kiosk vendors, KDS vendors, membership/coupon providers, and tax/accounting systems, may return delayed, duplicated, incomplete, inconsistent, or provider-specific responses.

This document prevents financial accidents by defining:

- failure mode classification;
- internal canonical payment states;
- allowed and prohibited transitions;
- inquiry and compensation requirements;
- manager and support actions;
- evidence and audit requirements;
- reconciliation handoff rules.

This matrix belongs to the `70000 External Integration Control Plane` lane and closes the first failure-mode control layer for the `70100 POS/VAN/PG and external payment integration governance` bundle.

## 2. Core Principle

External integration failure must never be simplified into a binary success/failure result.

A payment event must be treated as a controlled financial state machine:

```text
REQUESTED
→ SENT_TO_EXTERNAL
→ RESPONSE_RECEIVED / TIMEOUT_UNKNOWN / PROVIDER_ERROR
→ VALIDATION_PENDING
→ CONFIRMED / DECLINED / AMBIGUOUS / MISMATCHED
→ INQUIRY_PENDING / REVERSAL_PENDING / MANUAL_REVIEW
→ RECONCILED / CANCELLED / REFUNDED / DISPUTE_OPEN
```

The following rules are mandatory:

1. A timeout is not a failure.
2. A provider success response is not final confirmation.
3. A provider failure response may require inquiry before final rejection.
4. A payment cannot be confirmed without internal validation.
5. A payment cannot be retried without idempotency protection.
6. A payment cannot be compensated without evidence capture.
7. A store operator cannot manually override financial state without audit trail.
8. Reconciliation exceptions must remain visible until resolved.

## 3. Scope

This matrix applies to external payment and payment-adjacent integrations, including:

- POS payment RPC;
- VAN authorization and cancellation responses;
- PG authorization, confirm, cancel, refund, webhook, and settlement flows;
- simple-pay providers such as KakaoPay, NaverPay, TossPay, Samsung Pay routing, etc.;
- Alipay / WeChat Pay / cross-border QR payment flows;
- card issuer / acquirer / merchant settlement feeds;
- payment settlement batch files;
- delivery app payment handoff flows;
- kiosk payment modules;
- external membership and coupon discount providers when they affect payable amount;
- tax/accounting exports when they affect confirmed revenue.

## 4. Canonical State Definitions

| State | Meaning | Financial Risk | Final? |
|---|---|---:|---:|
| `REQUESTED` | Internal payment intent created | Low | No |
| `SENT_TO_EXTERNAL` | Request sent to POS/VAN/PG/provider | Medium | No |
| `RESPONSE_RECEIVED` | External response received but not validated | Medium | No |
| `VALIDATION_PENDING` | Response awaits canonical validation | Medium | No |
| `CONFIRMED` | Payment is internally validated and accepted | Low | Conditional |
| `DECLINED` | Provider rejection validated | Low | Yes |
| `TIMEOUT_UNKNOWN` | No definitive response after request | High | No |
| `AMBIGUOUS` | Conflicting or incomplete evidence | High | No |
| `MISMATCHED` | Amount/order/provider identifiers do not match | Critical | No |
| `INQUIRY_PENDING` | Status inquiry required or in progress | High | No |
| `REVERSAL_PENDING` | Cancellation/reversal required or in progress | High | No |
| `MANUAL_REVIEW` | Operator/backoffice intervention required | High | No |
| `CANCELLED` | Authorized payment cancelled | Low | Conditional |
| `REFUNDED` | Captured payment refunded | Low | Conditional |
| `RECONCILED` | Matched with provider settlement/reconciliation data | Low | Yes |
| `DISPUTE_OPEN` | Customer/provider/accounting dispute exists | Critical | No |

## 5. Failure Mode Matrix

| ID | Failure Mode | Detection Signal | Immediate State | Prohibited Action | Required Recovery Action | Required Evidence |
|---|---|---|---|---|---|---|
| FM-001 | Request timeout after external payment request | No response before timeout window | `TIMEOUT_UNKNOWN` | Mark as failed and ask customer to pay again | Run payment inquiry by provider transaction key, terminal ID, amount, and time window | request payload, timeout log, idempotency key |
| FM-002 | Provider success but internal validation not completed | success response received | `VALIDATION_PENDING` | Mark order complete immediately | Validate amount, order ID, store ID, terminal ID, response code, approval number, trace ID | raw response, parsed fields, validation result |
| FM-003 | Provider success but amount mismatch | approved amount differs from expected amount | `MISMATCHED` | Fulfill order or auto-adjust amount | Block order completion, open manual review, evaluate reversal | request amount, approved amount, tax/discount snapshot |
| FM-004 | Provider success but order ID missing or mismatched | provider response cannot bind to payment intent | `AMBIGUOUS` | Attach response to nearest order | Use trace lookup, terminal/time/amount inquiry, manager review | raw response, candidate match list, reviewer note |
| FM-005 | Provider success but approval number missing | success-like code with no approval number | `AMBIGUOUS` | Print success receipt or complete order | Run inquiry; require approval identifier before confirmation | response code, provider message, inquiry result |
| FM-006 | Provider failure but authorization may have succeeded | error/timeout after provider-side submit | `INQUIRY_PENDING` | Retry same payment blindly | Inquiry first; retry only after no approval confirmed | retry lock, inquiry payload, provider result |
| FM-007 | Duplicate response received | same trace/idempotency/approval key repeated | prior canonical state retained | Create duplicate payment record | Deduplicate by canonical transaction identity | duplicate hash, first-seen timestamp |
| FM-008 | Duplicate authorization detected | same order has multiple approvals | `MANUAL_REVIEW` or `REVERSAL_PENDING` | Fulfill twice or ignore second approval | Keep one canonical confirmation, reverse extra authorization | approval numbers, amounts, reversal request |
| FM-009 | Order confirmed but payment not confirmed | order state advanced before payment confirmation | `MANUAL_REVIEW` | Send to kitchen as paid order | Freeze fulfillment or mark unpaid pending manager decision | order event log, payment state log |
| FM-010 | Payment confirmed but order failed | payment success, order creation/update failed | `REVERSAL_PENDING` or `MANUAL_REVIEW` | Leave customer charged with no order | Recreate order from immutable cart snapshot or reverse payment | cart snapshot, approval data, recovery decision |
| FM-011 | Cancel request timeout | no cancel response | `REVERSAL_PENDING` | Tell customer cancellation is complete | Run cancel inquiry; retry cancel only if not cancelled | cancel request, timeout log, inquiry result |
| FM-012 | Cancel success but internal order not reversed | provider cancelled but order remains paid | `MANUAL_REVIEW` | Keep paid fulfillment active | Reverse internal order/payment state after evidence check | cancel approval, order reversal event |
| FM-013 | Internal cancel success but provider cancel failed | internal state cancelled, provider still approved | `DISPUTE_OPEN` or `REVERSAL_PENDING` | Hide from reconciliation | Reopen financial state, attempt reversal, notify finance/support | internal cancel event, provider rejection |
| FM-014 | Provider code unknown | unmapped response code | `AMBIGUOUS` | Treat as success/failure by text message | Map provider code through registry update and review | response code, provider documentation link/reference |
| FM-015 | Receipt/slip data missing | no receipt metadata after success | `VALIDATION_PENDING` or `MANUAL_REVIEW` | Close evidence packet | Fetch/reprint receipt data or preserve provider response as substitute | receipt fetch log, raw payload |
| FM-016 | Terminal/store mismatch | response terminal/store differs from request | `MISMATCHED` | Confirm payment | Block confirmation, raise security/integration incident | terminal ID, merchant ID, store mapping snapshot |
| FM-017 | Late response after timeout | response arrives after state moved to unknown/retry | `AMBIGUOUS` | Auto-merge without check | Compare with retry status and prevent duplicate confirmation | late response timestamp, state before arrival |
| FM-018 | Webhook duplicates prior RPC response | async webhook repeats known result | current canonical state retained | Create second state transition | Deduplicate by provider event ID and transaction key | webhook payload, event ID, hash |
| FM-019 | Webhook conflicts with RPC response | webhook says success, RPC says fail or vice versa | `AMBIGUOUS` | Choose latest blindly | Inquiry and provider reconciliation required | RPC payload, webhook payload, inquiry result |
| FM-020 | Settlement file differs from confirmed ledger | settlement amount/count mismatch | `RECONCILIATION_EXCEPTION` | Close business day as balanced | Investigate by transaction, fee, cancellation, deposit line | settlement file, ledger export, diff report |
| FM-021 | Membership/coupon discount changed after payment intent | external benefit state changed mid-flow | `MISMATCHED` | Recalculate after authorization | Reject or reverse; require immutable discount snapshot | benefit snapshot, external coupon response |
| FM-022 | Delivery app paid order conflicts with in-store payment | duplicate external channel payment/order | `MANUAL_REVIEW` | Fulfill both without review | Match channel order ID, customer, amount, time, fulfillment status | delivery payload, POS/payment records |
| FM-023 | Cross-border QR payment FX ambiguity | KRW requested, foreign currency confirmation incomplete | `AMBIGUOUS` | Confirm without KRW settlement basis | Validate KRW approval amount and provider settlement reference | KRW amount, FX metadata, global gateway trace |
| FM-024 | Provider outage during business peak | repeated errors from same provider | `PROVIDER_DEGRADED` or `INQUIRY_PENDING` | Infinite retries | Open circuit breaker, switch fallback mode, queue inquiries | outage log, provider status, circuit breaker event |
| FM-025 | Provider sends corrected/cancelled event after closeout | post-closeout adjustment received | `DISPUTE_OPEN` or `RECONCILIATION_EXCEPTION` | Overwrite closed ledger silently | Append adjustment event; finance review required | original ledger, adjustment event, reviewer approval |

## 6. State Transition Rules

### 6.1 Allowed High-Level Transitions

```text
REQUESTED → SENT_TO_EXTERNAL
SENT_TO_EXTERNAL → RESPONSE_RECEIVED
SENT_TO_EXTERNAL → TIMEOUT_UNKNOWN
RESPONSE_RECEIVED → VALIDATION_PENDING
VALIDATION_PENDING → CONFIRMED
VALIDATION_PENDING → DECLINED
VALIDATION_PENDING → AMBIGUOUS
VALIDATION_PENDING → MISMATCHED
TIMEOUT_UNKNOWN → INQUIRY_PENDING
INQUIRY_PENDING → CONFIRMED
INQUIRY_PENDING → DECLINED
INQUIRY_PENDING → REVERSAL_PENDING
INQUIRY_PENDING → MANUAL_REVIEW
MISMATCHED → REVERSAL_PENDING
MISMATCHED → MANUAL_REVIEW
REVERSAL_PENDING → CANCELLED
REVERSAL_PENDING → DISPUTE_OPEN
CONFIRMED → RECONCILED
CANCELLED → RECONCILED
REFUNDED → RECONCILED
```

### 6.2 Prohibited Transitions

The following transitions are prohibited:

```text
TIMEOUT_UNKNOWN → DECLINED
TIMEOUT_UNKNOWN → CONFIRMED
AMBIGUOUS → CONFIRMED without inquiry evidence
MISMATCHED → CONFIRMED
RESPONSE_RECEIVED → CONFIRMED without validation
PROVIDER_ERROR → retry without idempotency lock
CANCEL_TIMEOUT → CANCELLED without cancel inquiry evidence
SETTLEMENT_MISMATCH → RECONCILED without exception closure
```

## 7. Recovery Action Classes

| Recovery Class | Purpose | Owner | Evidence Required |
|---|---|---|---|
| `INQUIRY` | Determine actual provider-side state | Integration service / payment ops | inquiry request/response, timestamp, provider trace |
| `RETRY` | Re-attempt safe request | Integration service | idempotency key, retry count, backoff log |
| `REVERSAL` | Cancel accidental or orphaned authorization | Payment service / manager | approval no, cancel request, cancel response |
| `ORDER_REPAIR` | Recreate/repair order after payment success | Store runtime / manager | cart snapshot, payment confirmation, repair event |
| `CUSTOMER_GUIDANCE` | Inform customer without false financial claim | Store operator/support | customer notice log, manager note |
| `MANUAL_REVIEW` | Resolve complex mismatch | Manager / finance / support | reviewer ID, decision reason, attached evidence |
| `RECONCILIATION` | Match with settlement/deposit/accounting data | Finance/audit | settlement diff, ledger export, closure approval |
| `DISPUTE` | Open formal claim or provider escalation | Finance/support/legal | provider ticket, customer claim, evidence packet |

## 8. Store Operator Action Matrix

| Store-Facing Symptom | Staff Must Say | Staff Must Not Say | Required Action |
|---|---|---|---|
| Payment screen froze after card/QR scan | “결제 상태를 확인 중입니다.” | “실패했으니 다시 결제하세요.” | Check payment status screen / call manager |
| Customer says money was deducted but order missing | “승인 여부와 주문 상태를 확인하겠습니다.” | “저희 쪽에는 없으니 카드사에 문의하세요.” | Manager opens payment inquiry case |
| Receipt not printed but app/card shows paid | “영수증과 승인 상태를 재확인하겠습니다.” | “영수증 없으면 결제 안 된 겁니다.” | Fetch/reprint receipt or evidence packet |
| Cancel button timed out | “취소 완료 여부를 확인 중입니다.” | “취소됐습니다.” | Run cancel inquiry before customer assurance |
| Duplicate payment suspected | “중복 승인 여부를 확인하고 조치하겠습니다.” | “하나는 자동으로 없어질 겁니다.” | Lock order, open duplicate approval review |

## 9. Evidence Packet Requirements

Every failure-mode case must produce an evidence packet containing:

- payment intent ID;
- order ID;
- store ID;
- terminal ID;
- provider ID;
- request payload hash;
- raw response payload hash;
- parsed canonical fields;
- response code mapping result;
- idempotency key;
- retry count;
- inquiry request and response;
- reversal/cancel request and response, if any;
- manager action log, if any;
- customer guidance log, if any;
- reconciliation closure result.

No financial exception may be closed without an evidence packet.

## 10. Provider Contract Requirements

External providers must support or document the following capabilities before production activation:

- transaction inquiry;
- cancellation inquiry;
- last transaction inquiry when applicable;
- provider transaction ID or trace ID;
- approval number / cancel number semantics;
- response code dictionary;
- duplicate event behavior;
- retry safety rule;
- receipt/slip retrieval or reprint support;
- settlement file export;
- outage notification channel;
- support escalation channel;
- test/sandbox certification evidence.

If a provider cannot support inquiry or traceability, the provider must be classified as high risk and cannot be used for unattended payment-critical flows without manual fallback.

## 11. Reconciliation Handoff

Failure-mode cases must be handed to reconciliation in the following categories:

| Category | Trigger | Handoff Target |
|---|---|---|
| `OPEN_UNKNOWN` | unresolved timeout or ambiguous state | payment ops |
| `OPEN_REVERSAL` | cancellation/reversal pending | payment ops / finance |
| `SETTLEMENT_DIFF` | settlement file mismatch | finance / audit |
| `CUSTOMER_CLAIM` | customer reports deduction/refund issue | support / manager |
| `PROVIDER_ESCALATION` | provider code/trace cannot be resolved | vendor manager |
| `LEGAL_RISK` | unresolved charge, tax, or settlement dispute | legal / executive approval |

## 12. Closeout Criteria

A failure-mode case may be closed only when all applicable criteria are satisfied:

1. canonical final state is assigned;
2. provider-side state is known or formally disputed;
3. internal order/payment ledger is consistent;
4. customer-facing status is corrected;
5. reversal/refund is completed if required;
6. settlement/reconciliation status is updated;
7. evidence packet is complete;
8. manager/finance approval is recorded for manual cases.

## 13. Related Documents

- `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`
- `70110_Governance_External_POS_VAN_PG_Provider_Boundary_Trust_And_Liability_Model.md`
- `70120_Policy_External_Payment_Request_Response_Separation_And_State_Authority.md`
- `70130_Spec_External_Payment_Response_Field_Registry_Approval_Cancel_Receipt_And_Trace_Metadata.md`
- `70140_Policy_External_Payment_Amount_Tax_Discount_Service_Charge_And_Order_Match_Validation.md`
- `70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md`
- `70160_Runbook_External_Payment_Communication_Error_Recovery_Reversal_And_Manager_Action.md`
- `70170_Audit_External_Payment_Response_Evidence_Raw_Payload_Hash_And_Tamper_Check.md`

## 14. Handoff

This matrix hands off to:

- external payment closeout index;
- provider onboarding certification;
- settlement reconciliation;
- store operator SOP;
- customer claim handling;
- audit ledger retention;
- future delivery app, membership, coupon, tax, and accounting external integration matrices.

The next document should close the first POS/VAN/PG external payment governance bundle:

`70190_Index_POS_VAN_PG_External_Payment_Integration_Closeout_And_Handoff.md`
