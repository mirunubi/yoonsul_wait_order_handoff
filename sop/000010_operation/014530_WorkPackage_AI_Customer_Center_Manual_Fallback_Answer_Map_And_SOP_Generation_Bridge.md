# 014530_WorkPackage_AI_Customer_Center_Manual_Fallback_Answer_Map_And_SOP_Generation_Bridge.md

## 1. Purpose

This work package defines the bridge between first-store manual fallback operation, support answer maps, AI customer center responses, unknown-question capture, and digital SOP generation.

It starts after first-store next-scope and automation handoff.

The purpose is to ensure that AI customer center support does not invent operational answers, but instead uses approved answer maps, escalation rules, evidence boundaries, and SOP candidate queues.

## 2. Core Principle

AI customer center must answer only within approved operational truth.

If the system does not know whether POS entry, payment, kitchen handoff, cancellation, refund, or fulfillment is complete, AI must not claim completion.

Unknown or repeated questions must become structured candidates for:

- support answer update
- SOP update
- escalation rule update
- staff training update
- product/UX update
- provider dependency review

## 3. Scope

This work package covers:

- approved answer map usage
- unknown-question capture
- repeated-question detection
- SOP candidate generation
- human approval gate
- AI answer safety rules
- escalation mapping
- digital SOP handoff

This does not define LLM provider selection, model training, or production AI implementation.

## 4. Input Sources

| Source | Purpose |
|---|---|
| 14380 support answer map | approved staff/customer wording |
| 14370 mismatch escalation runbook | escalation and unsafe state handling |
| 14310 payment/order separation policy | payment and order state boundaries |
| 14410 daily issue queue | repeated operating issues |
| 14460 recurring issue register | root cause and control actions |
| 14500 automation candidate register | AI/support suggestion candidates |
| support tickets/chats | unknown customer/staff questions |
| daily reconciliation logs | evidence for repeated issues |

## 5. Answer Types

| Answer Type | Meaning |
|---|---|
| APPROVED_STATIC | Approved fixed answer |
| APPROVED_CONDITIONAL | Answer depends on known state/evidence |
| ESCALATE_ONLY | AI must not answer beyond escalation |
| STAFF_ONLY | For internal staff, not customer-facing |
| DRAFT_CANDIDATE | Proposed answer requiring approval |
| SOP_CANDIDATE | Question reveals missing/unclear SOP |
| BLOCKED | Unsafe to answer automatically |

## 6. AI Answer Guardrails

AI customer center must:

1. Use approved answer map first.
2. Check whether state evidence exists.
3. Use conservative wording when state is unknown.
4. Escalate payment/refund/cancel ambiguity.
5. Escalate duplicate order risk.
6. Escalate customer harm or complaint risk.
7. Never mark payment/refund/cancel complete without evidence.
8. Never infer kitchen handoff from POS entry.
9. Never infer POS entry from order intent.
10. Never invent provider integration status.
11. Log unknown or repeated questions.
12. Create SOP/answer-map candidates only through approval queue.

## 7. Unknown Question Flow

1. Customer or staff asks a question.
2. AI checks approved answer map.
3. If no approved answer exists, AI uses safe fallback wording.
4. AI routes to support owner or shift lead.
5. Question is logged as unknown.
6. Repetition count is tracked.
7. If repeated, create answer-map candidate.
8. If operational procedure is missing, create SOP candidate.
9. Human owner approves or rejects candidate.
10. Approved answer/SOP becomes available for future use.

## 8. Safe Fallback Answer

If no approved answer exists:

```text
현재 해당 상태는 매장에서 확인이 필요합니다.
정확한 처리를 위해 담당자가 주문, 결제, 주방 전달 상태를 확인한 뒤 안내드리겠습니다.
```

For staff-facing use:

```text
승인된 답변 또는 SOP가 없는 상황입니다.
상태를 임의로 확정하지 말고 shift lead 또는 support owner에게 escalation하고, unknown question으로 기록하세요.
```

## 9. Question Classification

| Class | Example | Default Handling |
|---|---|---|
| ORDER_STATE | 주문이 접수됐나요? | approved conditional answer |
| POS_STATE | POS에 들어갔나요? | evidence required |
| PAYMENT_STATE | 결제됐나요? | evidence required / escalate |
| REFUND_CANCEL | 취소/환불됐나요? | evidence required / escalate |
| KITCHEN_STATE | 주방에 전달됐나요? | evidence required |
| DELAY | 왜 늦나요? | safe delay wording |
| SOLD_OUT | 품절이면 어떻게 되나요? | approved sold-out answer |
| DUPLICATE | 중복 주문인가요? | escalate |
| CORRECTION | 주문 수정됐나요? | evidence required |
| PROVIDER | POS/결제사 문제인가요? | do not speculate |
| UNKNOWN | not mapped | safe fallback + log |

## 10. SOP Candidate Trigger

Create SOP candidate when:

- same unknown question repeats,
- support answer requires operational procedure,
- staff has no documented action,
- daily issue queue shows repeated gap,
- customer-facing wording is unclear,
- payment/refund/cancel handling lacks procedure,
- provider dependency affects support response,
- manual workaround becomes common.

## 11. Candidate Approval Gate

No generated answer or SOP candidate becomes active until approved by:

| Candidate Type | Required Owner |
|---|---|
| customer-facing answer | support owner + product owner |
| payment/refund/cancel answer | support owner + payment/finance owner |
| staff operational answer | operations owner |
| SOP update | operations owner + document owner |
| provider-dependent answer | technical/provider owner |
| AI customer center answer | support owner + AI/customer center owner |

## 12. Digital SOP Generation Boundary

AI may assist in drafting SOP candidates.

AI must not:

- auto-publish SOP,
- auto-change production policy,
- auto-approve customer-facing answer,
- create payment/refund obligations,
- create provider integration claims,
- bypass human review.

## 13. Evidence Requirements

Every candidate must link to:

- source question,
- frequency count,
- affected order/support cases if any,
- current approved answer if any,
- related SOP/policy/runbook,
- proposed answer or SOP change,
- owner decision,
- approval status.

## 14. Required Outputs

This work package should produce:

- unknown question and SOP candidate queue
- approved answer map and escalation rule template
- candidate approval process
- AI guardrail checklist
- digital SOP handoff report

## 15. Recommended Next Documents

| No. | Document |
|---:|---|
| 14540_Register_AI_Customer_Center_Unknown_Question_And_SOP_Candidate_Queue.md |
| 14550_Template_AI_Customer_Center_Approved_Answer_Map_And_Escalation_Rule.md |
| 14560_Report_AI_Customer_Center_Answer_Map_Closeout_And_Digital_SOP_Handoff.md |
| 14570_Index_AI_Customer_Center_Manual_Fallback_Knowledge_Closeout_And_Handoff.md |

## 16. Non-Goals

This work package does not define:

- AI model vendor,
- vector database implementation,
- prompt engineering details,
- production chatbot architecture,
- legal customer compensation policy,
- payment gateway implementation.

It defines the operational bridge from support questions to approved answers and SOP candidates.

## 17. Related Documents

- 14520_Index_First_Store_Next_Scope_Expansion_And_Automation_Handoff.md
- 14500_Register_First_Store_Automation_Candidate_Backlog_And_Safety_Gate.md
- 14380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md
- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14410_Register_First_Store_Daily_Issue_Training_Gap_And_SOP_Update_Queue.md
- 08000_ai_customer_center
