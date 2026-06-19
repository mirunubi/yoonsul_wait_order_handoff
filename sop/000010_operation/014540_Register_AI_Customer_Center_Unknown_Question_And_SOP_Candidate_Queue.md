# 014540_Register_AI_Customer_Center_Unknown_Question_And_SOP_Candidate_Queue.md

## 1. Purpose

This register tracks unknown questions, repeated customer/staff questions, answer-map update candidates, SOP candidate items, escalation-only cases, and approval status for the AI customer center.

It is used when Catch & Order operates under manual fallback, semi-manual POS/KDS mode, or limited provider integration.

The purpose is to ensure that AI customer center learning becomes controlled operational knowledge rather than unapproved improvisation.

## 2. Core Rule

Unknown questions must be logged, classified, and routed.

AI customer center must not invent answers outside approved answer maps, SOPs, policies, or escalation rules.

## 3. Unknown Question Register

| Question ID | Date | Audience | Question | Class | Frequency | Default Handling | Owner | Status |
|---|---|---|---|---|---:|---|---|---|
| UQ-001 |  | customer / staff |  |  |  | Safe fallback + escalation |  | Open |

## 4. Question Classes

| Class | Meaning | Default Handling |
|---|---|---|
| ORDER_STATE | order received / order status | approved conditional answer |
| POS_STATE | POS entry state | evidence required |
| PAYMENT_STATE | payment approval/unknown | evidence required + escalation |
| REFUND_CANCEL | cancellation/refund | evidence required + escalation |
| KITCHEN_STATE | kitchen handoff/ready/served | evidence required |
| DELAY | delay or waiting time | safe delay wording |
| SOLD_OUT | unavailable menu/substitution | approved sold-out flow |
| DUPLICATE | possible duplicate order | shift lead escalation |
| CORRECTION | changed/wrong order | evidence required |
| PROVIDER | POS/payment provider issue | do not speculate |
| STAFF_OPERATION | staff asks what to do | staff SOP or escalation |
| POLICY_GAP | answer requires missing policy | SOP/policy candidate |
| UNKNOWN | not mapped | safe fallback + log |

## 5. Candidate Type

| Candidate Type | Meaning |
|---|---|
| ANSWER_UPDATE | approved answer map needs new or revised answer |
| SOP_CANDIDATE | operational procedure is missing or unclear |
| ESCALATION_RULE | escalation owner/path must be updated |
| TRAINING_UPDATE | staff training must be refreshed |
| UI_COPY_UPDATE | customer/staff wording should change |
| UI_FLOW_UPDATE | screen/workflow change is needed |
| PROVIDER_FACT_NEEDED | provider information is blocking answer |
| PAYMENT_REVIEW | payment/refund/cancel answer needs finance/security review |
| BLOCKED | unsafe to answer automatically |

## 6. SOP Candidate Queue

| Candidate ID | Source Question ID | Candidate Type | Proposed Title | Related Document | Owner | Approval Status | Next Action |
|---|---|---|---|---|---|---|---|
| SOPC-001 |  |  |  |  |  | Draft |  |

## 7. Frequency Rule

| Frequency | Action |
|---:|---|
| 1 occurrence | log only unless high-risk |
| 2 occurrences | review for answer update |
| 3 occurrences | create candidate |
| high-risk single occurrence | create escalation candidate immediately |
| payment/refund/cancel unknown | create payment review candidate immediately |
| duplicate risk unknown | create escalation/training candidate immediately |

## 8. Approval Status

| Status | Meaning |
|---|---|
| Draft | candidate created |
| Needs Evidence | more cases needed |
| Needs Owner Review | waiting owner review |
| Needs Ops Review | operational approval required |
| Needs Support Review | support wording approval required |
| Needs Payment Review | payment/finance review required |
| Needs Security Review | sensitive/provider/payment data review required |
| Approved | can be added to answer map/SOP backlog |
| Rejected | not valid or unsafe |
| Deferred | not current phase |
| Published | approved and added to controlled document |
| Retired | no longer used |

## 9. Required Evidence

Each candidate must include:

| Evidence | Required |
|---|---|
| source question text | Yes |
| question count | Yes |
| audience | Yes |
| affected order/support case if applicable | If available |
| current answer used | If any |
| related SOP/policy/runbook | If any |
| risk if answered wrongly | Yes |
| proposed handling | Yes |
| owner decision | Yes before publication |

## 10. High-Risk Question Handling

High-risk questions include:

- Did payment complete?
- Was I refunded?
- Did the cancellation go through?
- Was the order sent to POS?
- Did the kitchen receive the order?
- Is this a duplicate order?
- Why was I charged twice?
- Can I ignore the POS record?
- Should I refund manually?
- Is the provider system down?

These must not receive invented answers.

They require evidence or escalation.

## 11. Safe Fallback Responses

### Customer-facing safe fallback

```text
현재 해당 상태는 매장에서 확인이 필요합니다.
정확한 처리를 위해 담당자가 주문, 결제, 주방 전달 상태를 확인한 뒤 안내드리겠습니다.
```

### Staff-facing safe fallback

```text
승인된 답변 또는 SOP가 없는 상황입니다.
상태를 임의로 확정하지 말고 shift lead 또는 support owner에게 escalation하고 unknown question으로 기록하세요.
```

## 12. Publication Rule

A candidate can be published only when:

1. owner approves,
2. risk class is reviewed,
3. evidence exists,
4. related SOP/policy is updated if needed,
5. customer-facing wording is approved,
6. escalation path is defined,
7. AI guardrail is updated if relevant.

## 13. Output Mapping

| Candidate Type | Output |
|---|---|
| ANSWER_UPDATE | 14550 answer map update |
| SOP_CANDIDATE | SOP update backlog |
| ESCALATION_RULE | escalation rule update |
| TRAINING_UPDATE | training queue |
| UI_COPY_UPDATE | UI copy backlog |
| UI_FLOW_UPDATE | product/UX backlog |
| PROVIDER_FACT_NEEDED | provider blocker/follow-up |
| PAYMENT_REVIEW | payment/security/finance review |
| BLOCKED | blocked answer list |

## 14. Weekly Review

| Week | New Unknown Questions | Candidates Created | Approved | Rejected | Open High-Risk |
|---|---:|---:|---:|---:|---:|
| Week 1 |  |  |  |  |  |
| Week 2 |  |  |  |  |  |
| Week 3 |  |  |  |  |  |
| Week 4 |  |  |  |  |  |

## 15. Non-Goals

This register does not define:

- AI model implementation,
- prompt engineering,
- vector database,
- production chatbot deployment,
- legal customer compensation policy,
- payment gateway behavior.

It only tracks unknown questions and controlled SOP/answer candidates.

## 16. Related Documents

- 14530_WorkPackage_AI_Customer_Center_Manual_Fallback_Answer_Map_And_SOP_Generation_Bridge.md
- 14550_Template_AI_Customer_Center_Approved_Answer_Map_And_Escalation_Rule.md
- 14560_Report_AI_Customer_Center_Answer_Map_Closeout_And_Digital_SOP_Handoff.md
- 14380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md
- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 08000_ai_customer_center
