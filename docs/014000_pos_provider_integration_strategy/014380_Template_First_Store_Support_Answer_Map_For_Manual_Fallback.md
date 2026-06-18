# 014380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md

## 1. Purpose

This template defines the first-store support answer map for Catch & Order manual fallback operation.

It is used by staff support, customer support, and future AI customer center flows when POS/KDS/payment integration is manual, limited, degraded, or unverified.

The purpose is to provide safe, evidence-based wording that does not overstate POS entry, kitchen handoff, payment completion, cancellation, refund, or fulfillment state.

## 2. Core Rule

Support answers must never claim a state that the store has not confirmed with evidence.

Do not say:

- payment is complete
- refund is complete
- POS accepted the order
- kitchen received the order
- order is ready
- cancellation is complete

unless the corresponding evidence exists.

## 3. Answer Map Status

| Status | Meaning |
|---|---|
| Draft | Not yet approved |
| Approved For Staff | Internal staff may use |
| Approved For Customer | Customer-facing use allowed |
| Approved For AI Customer Center | AI/customer center may use |
| Needs Review | Legal/payment/ops wording review required |
| Retired | No longer used |

## 4. Common State Wording

| Internal State | Customer-Safe Answer |
|---|---|
| Order intent received | 주문 요청이 접수되었고, 매장에서 내용을 확인 중입니다. |
| Staff reviewing | 매장 직원이 주문 내용을 확인하고 있습니다. |
| POS entry pending | 매장 POS 입력 여부를 확인 중입니다. |
| POS entry confirmed | 매장에서 주문 입력을 확인했습니다. |
| Kitchen handoff pending | 주방 전달 여부를 확인 중입니다. |
| Kitchen handoff confirmed | 주방 전달이 확인되었습니다. |
| Payment pending | 결제 상태를 확인 중입니다. |
| Payment unknown | 매장에서 결제 내역을 확인 중입니다. 잠시만 기다려 주세요. |
| Refund requested | 환불 요청이 접수되었고, 매장에서 처리 가능 여부를 확인 중입니다. |
| Refund confirmed | 환불 처리 증적이 확인되었습니다. |
| Delay | 조리 또는 매장 처리 상황을 확인 중입니다. |
| Manual correction | 주문 내용에 수정 사항이 있어 매장에서 확인 중입니다. |

## 5. Staff-Facing Answer Map

| Issue | Staff Answer / Guidance |
|---|---|
| Order appears in Catch & Order but not POS | POS 입력 전 상태일 수 있습니다. 중복 여부를 확인한 뒤 수동 입력하고 POS reference를 기록하세요. |
| POS has order but Catch & Order does not | 외부 POS 주문일 수 있습니다. 임의로 고객 상태를 만들지 말고 daily reconciliation에 POS-only로 기록하세요. |
| Kitchen did not receive order | POS entry와 kitchen handoff evidence를 확인하고, 누락이면 manual kitchen note로 전달하세요. |
| Payment state unknown | 결제 완료로 표시하지 말고 POS/payment terminal evidence를 확인하세요. |
| Customer asks if paid | 결제 증적 확인 전에는 “결제 상태를 확인 중입니다”라고 안내하세요. |
| Refund requested | 환불 완료로 말하지 말고 POS/payment terminal refund evidence를 확인하세요. |
| Duplicate suspected | 추가 POS 입력을 멈추고 shift lead에게 escalation하세요. |
| Sold-out after order | 고객/지원 flow에 따라 replacement/cancel을 확인하고 correction evidence를 기록하세요. |
| Wrong option entered | kitchen start 여부를 확인하고 correction log에 before/after를 기록하세요. |
| KDS/printer failure | manual kitchen note fallback을 사용하고 failure evidence를 기록하세요. |

## 6. Customer-Facing FAQ Drafts

### 6.1 주문이 접수됐나요?

```text
주문 요청은 접수되었습니다. 현재 매장에서 주문 내용을 확인 중입니다.
매장 확인이 완료되면 다음 상태로 안내드리겠습니다.
```

### 6.2 주문이 POS에 들어갔나요?

```text
매장 POS 입력 여부를 확인 중입니다.
확인 전에는 중복 처리를 막기 위해 상태를 신중하게 확인하고 있습니다.
```

### 6.3 결제가 완료됐나요?

```text
결제 상태는 매장 POS 또는 결제 단말 기준으로 확인이 필요합니다.
현재 결제 내역을 확인 중이며, 확인되는 대로 안내드리겠습니다.
```

### 6.4 주방에 전달됐나요?

```text
주방 전달 여부를 확인 중입니다.
주방 전달이 확인되면 준비 상태로 안내드리겠습니다.
```

### 6.5 주문이 왜 늦나요?

```text
현재 매장에서 주문 처리 또는 조리 상황을 확인 중입니다.
확인되는 즉시 안내드리겠습니다.
```

### 6.6 메뉴가 품절이라고 하나요?

```text
일부 메뉴가 매장 상황에 따라 품절될 수 있습니다.
매장에서 대체 가능 여부 또는 취소 가능 여부를 확인 중입니다.
```

### 6.7 취소가 됐나요?

```text
취소 요청은 확인 중입니다.
POS 입력, 주방 전달, 결제 여부에 따라 처리 단계가 달라질 수 있어 매장에서 상태를 확인한 뒤 안내드리겠습니다.
```

### 6.8 환불이 됐나요?

```text
환불은 결제 단말 또는 결제 기록 기준으로 확인이 필요합니다.
환불 처리 증적이 확인되면 안내드리겠습니다.
```

### 6.9 주문 내용이 잘못 들어갔어요

```text
주문 내용을 매장에서 확인하고 있습니다.
필요한 경우 수정 내역을 기록한 뒤 처리 상태를 안내드리겠습니다.
```

### 6.10 중복 주문된 것 같아요

```text
중복 주문 가능성이 있어 매장에서 주문 기록을 확인 중입니다.
중복 처리를 막기 위해 추가 처리 전에 상태를 먼저 확인하겠습니다.
```

## 7. AI Customer Center Guardrails

Future AI customer center must follow these rules:

1. Do not infer payment from order.
2. Do not infer POS entry from order intent.
3. Do not infer kitchen receipt from POS entry.
4. Do not infer refund from refund request.
5. Do not promise exact completion time unless store confirms.
6. Escalate payment/refund/cancel mismatch to staff.
7. Escalate duplicate risk to shift lead.
8. Use conservative wording when evidence is missing.
9. Record unknown question types as SOP/answer-map candidates.
10. Do not generate new operational promises without approval.

## 8. Escalation Answer Map

| Trigger | Escalate To | Support Wording |
|---|---|---|
| payment/order mismatch | manager/payment owner | 결제와 주문 상태를 매장에서 확인 중입니다. |
| duplicate risk | shift lead | 중복 처리 방지를 위해 매장에서 주문 기록을 확인 중입니다. |
| refund unclear | manager/payment owner | 환불 처리 증적을 확인 중입니다. |
| kitchen delay | shift lead/kitchen lead | 조리 상황을 확인 중입니다. |
| item unavailable | shift lead | 메뉴 가능 여부를 매장에서 확인 중입니다. |
| wrong customer status | support owner | 표시 상태를 확인하고 정정 중입니다. |
| evidence missing | reconciliation owner | 기록 확인 후 안내드리겠습니다. |

## 9. Answer Approval Table

| Answer ID | Scenario | Audience | Status | Owner | Last Review |
|---|---|---|---|---|---|
| ANS-001 | order received | customer | Draft |  |  |
| ANS-002 | POS entry pending | customer | Draft |  |  |
| ANS-003 | payment unknown | customer | Draft |  |  |
| ANS-004 | kitchen handoff pending | customer | Draft |  |  |
| ANS-005 | refund requested | customer | Draft |  |  |
| ANS-006 | duplicate suspected | customer/staff | Draft |  |  |

## 10. Unknown Question Handling

If support or AI customer center receives a question not covered here:

1. Do not invent a new operational promise.
2. Use safe general wording.
3. Escalate to support owner or shift lead.
4. Record unknown question.
5. If repeated, create answer-map candidate.
6. If operational gap exists, create SOP update candidate.

## 11. Non-Goals

This template does not define:

- legal refund policy
- full customer service policy
- provider API status messaging
- marketing copy
- complaint compensation
- franchise-wide support script

It only defines safe first-store support answers for manual fallback operation.

## 12. Related Documents

- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
- 14360_Runbook_First_Store_Day_Zero_Activation_And_Manual_Fallback_Operation.md
- 14350_Checklist_First_Store_Catch_Order_Opening_Readiness_Gate.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md
- 08000_ai_customer_center
