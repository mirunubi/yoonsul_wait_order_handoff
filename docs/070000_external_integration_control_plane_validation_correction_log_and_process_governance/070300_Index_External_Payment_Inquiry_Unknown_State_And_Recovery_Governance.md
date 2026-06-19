# 070300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md

## 1. Document Purpose

This document opens the 70300 External Payment Inquiry, Unknown State, and Recovery Governance lane for the yoonsul_wait_order_handoff project.

The 70300 lane defines how the system must handle external payment states that cannot be safely classified as success or failure at the moment of the initial RPC, API, POS agent, VAN, PG, simple payment, card acquirer, or webhook interaction.

The purpose is to prevent financial accidents caused by prematurely treating timeout, missing response, delayed response, duplicate callback, partial cancel, or provider-side processing delay as a final business state.

In this lane, `UNKNOWN` is not an error label. It is a protected financial state requiring inquiry, evidence capture, reconciliation, and controlled recovery.

## 2. Parent And Related Documents

- Parent root index: `70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md`
- Generation rule: `70005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md`
- Payment integration parent: `70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md`
- Payment integration closeout: `70190_Index_POS_VAN_PG_External_Payment_Integration_Closeout_And_Handoff.md`
- RPC/API/Webhook parent: `70200_Index_External_RPC_API_Webhook_Response_Contract_And_Event_Control.md`
- RPC/API/Webhook closeout: `70290_Index_External_RPC_API_Webhook_Response_Contract_Closeout_And_Handoff.md`
- Payment integrity architecture root: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 3. Scope

This lane covers the following external payment uncertainty cases:

1. POS or kiosk payment request timeout.
2. VAN agent response loss after possible approval.
3. PG confirm request timeout.
4. Simple payment response delay or callback mismatch.
5. Cross-border payment approval delay or currency settlement uncertainty.
6. Cancel or refund request timeout.
7. Reversal request accepted but not confirmed.
8. Webhook success received before synchronous response.
9. Synchronous response success but webhook failure or missing callback.
10. External provider inquiry API unavailable or degraded.
11. Same payment intent mapped to multiple external transaction identifiers.
12. External transaction found without internal order confirmation.
13. Internal order confirmed without external payment confirmation.
14. Store operator claim that payment succeeded while system state is failed or unknown.
15. Customer claim with mobile banking, card app, simple payment app, or receipt evidence.

## 4. Non-Scope

This lane does not define general POS adapter implementation, device sandboxing, or hardware driver security. Those belong to POS gateway and local hardware lanes.

This lane does not define the complete distributed transaction architecture. Idempotency, delayed net cancel, Saga orchestration, transactional outbox, CDC, and double-entry ledger controls are governed by the 75000 Payment Integrity Architecture lane.

This lane does not allow direct manual modification of payment ledger records. Manual action may only create controlled recovery events, evidence records, inquiry requests, reversal requests, or manager review tasks.

## 5. Core Principle

A payment timeout is never equivalent to payment failure.

A missing response is never equivalent to no approval.

A customer app claim is never equivalent to verified settlement.

An external provider success response is never equivalent to internal order completion until validation, state authority, and reconciliation rules are satisfied.

Therefore, every uncertain payment must enter a protected state machine and remain blocked from unsafe business completion until inquiry or reconciliation resolves it.

## 6. Protected Unknown State Model

The following states are mandatory for external payment recovery processing.

| State | Meaning | Allowed Next Actions | Prohibited Actions |
| --- | --- | --- | --- |
| `PAYMENT_SENT_TO_PROVIDER` | Payment request left the internal boundary | Wait for response, receive callback, start timeout clock | Mark order complete without response or validation |
| `PAYMENT_RESPONSE_MISSING` | Provider response not received | Create inquiry task, retain request evidence | Mark as failed immediately |
| `PAYMENT_TIMEOUT_UNKNOWN` | Timeout occurred and external approval status is unknown | Query provider, hold order, show safe message | Ask customer to pay again without duplicate guard |
| `PAYMENT_INQUIRY_PENDING` | Provider inquiry is scheduled or in progress | Retry inquiry under policy, escalate if overdue | Cancel order without checking provider state |
| `PAYMENT_PROVIDER_APPROVED_INTERNAL_PENDING` | Provider approval found, but internal order not yet confirmed | Validate amount/order/store/terminal, complete or compensate | Recreate payment intent |
| `PAYMENT_PROVIDER_NOT_FOUND` | Inquiry found no provider transaction yet | Continue delayed inquiry window or prepare reversal decision | Treat as permanent no-payment before inquiry window ends |
| `PAYMENT_AMBIGUOUS` | Conflicting signals exist | Quarantine, manager review, reconciliation | Auto-complete, auto-refund, or delete evidence |
| `REVERSAL_PENDING` | Cancel/reversal request is required or sent but unconfirmed | Query cancel status, retry under control | Tell customer refund is complete without confirmation |
| `RECOVERY_MANUAL_REVIEW` | Automated recovery cannot safely decide | Manager review with evidence packet | Direct DB update |
| `RECOVERED_CONFIRMED` | Payment/order state is safely aligned | Close recovery case, include in audit | Reopen without new evidence |
| `RECOVERED_REVERSED` | Payment was reversed/cancelled and confirmed | Close recovery case, include in audit | Reuse same payment intent for new charge |

## 7. Inquiry Governance

Every provider used by the system must be evaluated for inquiry capability before production activation.

Required inquiry capability checklist:

| Inquiry Type | Required | Purpose |
| --- | --- | --- |
| Payment approval inquiry | Mandatory | Determine whether timeout resulted in approval |
| Cancel/refund inquiry | Mandatory | Determine whether reversal/cancel completed |
| Last transaction inquiry | Strongly required for POS/VAN | Recover local device or terminal uncertainty |
| Provider transaction ID inquiry | Mandatory when provider returns transaction ID | Resolve mapped payment states |
| Merchant order ID inquiry | Mandatory for PG/app payments | Resolve missing or duplicate callback cases |
| Terminal ID + time window inquiry | Required for offline POS/VAN | Resolve unmatched terminal approvals |
| Settlement file matching | Mandatory | Confirm final financial result after provider-side processing |

A provider lacking inquiry capability must be classified as high-risk and may require pilot-only scope, manual settlement audit, stronger operator SOP, or exclusion from production payment flows.

## 8. Recovery Decision Authority

The system must separate the following roles:

| Role | Authority |
| --- | --- |
| External provider | Emits external transaction facts and inquiry responses |
| External Integration Control Plane | Receives, logs, validates, normalizes, and quarantines external facts |
| Payment Integrity Control Plane | Decides whether money/order/ledger state can advance |
| Store manager | Executes approved operational actions using system-generated evidence |
| Finance/admin reviewer | Resolves reconciliation exceptions and settlement disputes |
| Developer/operator | May repair integration defects but may not directly rewrite financial truth |

No external system may directly mutate the canonical order, payment, refund, or settlement state.

## 9. Inquiry And Recovery Pipeline

All uncertain payment cases must follow this minimum pipeline:

```text
1. Detect uncertainty
2. Freeze unsafe business transition
3. Persist request, response, timeout, and raw evidence
4. Create recovery case
5. Schedule provider inquiry
6. Compare provider result with internal payment intent
7. Decide: confirm, reverse, continue inquiry, quarantine, or manual review
8. Write recovery event to audit ledger
9. Notify store/operator/customer only with safe wording
10. Include case in end-of-day reconciliation
```

## 10. Store-Facing Safe Messaging

When payment is uncertain, the system must not display wording that implies final failure or final success before validation.

Allowed examples:

```text
결제 확인 중입니다. 같은 주문으로 다시 결제하지 마세요. 직원이 결제 상태를 확인하고 있습니다.
```

```text
통신 상태로 인해 결제 결과 확인이 지연되고 있습니다. 승인 여부 조회 후 주문 처리 또는 취소 안내를 진행합니다.
```

Prohibited examples:

```text
결제 실패. 다시 결제하세요.
```

```text
환불 완료.
```

```text
승인 없음.
```

unless provider inquiry and internal validation have already confirmed those results.

## 11. Evidence Requirements

Each unknown or recovery case must preserve:

| Evidence | Requirement |
| --- | --- |
| Internal payment intent | Mandatory |
| Idempotency key | Mandatory if generated |
| External request payload hash | Mandatory |
| External raw response, if any | Mandatory |
| Timeout timestamp and duration | Mandatory |
| Provider inquiry request and response | Mandatory |
| Callback/webhook raw log | Mandatory if received |
| Terminal ID / store ID / merchant ID | Mandatory where applicable |
| Approval number / transaction ID | Mandatory if present |
| Operator action record | Mandatory if store action occurred |
| Customer claim attachment reference | Required when customer provides proof |
| Recovery decision reason | Mandatory |
| Final reconciliation result | Mandatory before financial closeout |

## 12. Relationship To 75000 Payment Integrity Architecture

The 70300 lane identifies and governs uncertain external payment states.

The 75000 lane provides the deeper architecture for safely resolving those states:

- idempotency and duplicate prevention,
- delayed net cancel,
- reversal and compensation,
- Saga orchestration,
- transactional outbox,
- event relay and CDC,
- double-entry ledger,
- reconciliation and accounting integrity,
- local device and agent recovery.

Any recovery flow that changes money, points, coupon, inventory, order, or settlement state must reference the 75000 lane.

## 13. Required Document Set For This Lane

The 70300 lane should contain at minimum:

```text
70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md
70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md
70320_Spec_External_Payment_Inquiry_Request_Response_Field_Registry.md
70330_Policy_External_Payment_Inquiry_Retry_Window_Backoff_And_Timeout_Control.md
70340_Policy_External_Payment_Provider_Not_Found_Delayed_Approval_And_Net_Cancel_Precondition.md
70350_Runbook_External_Payment_Unknown_State_Store_Manager_And_Customer_Action.md
70360_Matrix_External_Payment_Inquiry_Result_State_Transition_And_Recovery_Action.md
70370_Audit_External_Payment_Inquiry_Evidence_Case_Log_And_Reconciliation_Linkage.md
70380_Governance_External_Payment_Inquiry_Provider_Capability_Certification_And_Gap_Register.md
70390_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Closeout_And_Handoff.md
```

## 14. Mandatory Controls

The following controls are mandatory:

1. Timeout must enter `PAYMENT_TIMEOUT_UNKNOWN`.
2. Unknown state must block duplicate payment unless a new payment intent is explicitly generated and linked to the unresolved case.
3. Provider inquiry must be attempted before customer-facing failure confirmation.
4. Cancel/refund completion must be verified by provider response or settlement reconciliation.
5. Store manager override must create an event, not mutate the payment record directly.
6. Raw logs must be immutable after ingestion.
7. Inquiry results must be mapped to canonical recovery states.
8. Late callbacks must be processed through 70200 event order controls.
9. Reversal and compensation must hand off to the 75000 lane.
10. All unresolved unknown states must be included in daily closeout.

## 15. Completion Criteria

This lane is considered complete only when:

1. All supported providers have documented inquiry capabilities.
2. Every unknown state has a defined recovery path.
3. Operator-facing unknown payment messages are standardized.
4. Manual manager action is restricted to approved recovery workflows.
5. Inquiry result field registry exists.
6. Recovery state transition matrix exists.
7. Audit and reconciliation linkage is mandatory.
8. Unknown states cannot be closed without evidence.
9. Provider gaps are registered and risk-rated.
10. Handoff to 75000 Payment Integrity Architecture is complete.

## 16. Handoff

Previous document:

- `70290_Index_External_RPC_API_Webhook_Response_Contract_Closeout_And_Handoff.md`

Current document:

- `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md`

Next document:

- `70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md`
