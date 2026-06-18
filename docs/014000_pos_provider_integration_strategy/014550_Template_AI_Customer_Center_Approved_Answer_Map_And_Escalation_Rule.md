# 014550_Template_AI_Customer_Center_Approved_Answer_Map_And_Escalation_Rule.md

## 1. Purpose

This template defines the approved answer map and escalation rules for the AI customer center under Catch & Order manual fallback or semi-manual operation.

It is used after unknown questions and SOP candidates are reviewed.

The purpose is to ensure that AI customer center answers remain evidence-based, approved, conservative, and escalation-safe.

## 2. Core Rule

AI customer center may answer only from approved answer map entries.

If no approved answer exists, AI must use safe fallback wording and escalate.

AI must not infer POS entry, payment completion, kitchen handoff, cancellation, refund, or fulfillment from unrelated state.

## 3. Answer Map Entry Template

| Field | Value |
|---|---|
| answer_id |  |
| scenario |  |
| audience | customer / staff / support |
| answer_type | APPROVED_STATIC / APPROVED_CONDITIONAL / ESCALATE_ONLY / STAFF_ONLY |
| allowed_when |  |
| required_evidence |  |
| approved_answer |  |
| prohibited_phrases |  |
| escalation_required_when |  |
| related_SOP_policy |  |
| owner |  |
| approval_status | Draft / Approved / Retired |
| last_review_date |  |

## 4. Core Approved Customer Answers

### ANS-ORDER-001 — Order Received

| Field | Value |
|---|---|
| answer_type | APPROVED_CONDITIONAL |
| allowed_when | Catch & Order order intent exists |
| required_evidence | order id |
| approved_answer | 주문 요청은 접수되었습니다. 현재 매장에서 주문 내용을 확인 중입니다. 매장 확인이 완료되면 다음 상태로 안내드리겠습니다. |
| prohibited_phrases | 주문 완료, POS 접수 완료, 결제 완료 |

### ANS-POS-001 — POS Entry Pending

| Field | Value |
|---|---|
| answer_type | APPROVED_CONDITIONAL |
| allowed_when | order exists but POS entry evidence is not yet confirmed |
| required_evidence | order id; no POS reference yet |
| approved_answer | 매장 POS 입력 여부를 확인 중입니다. 중복 처리를 막기 위해 상태를 신중하게 확인하고 있습니다. |
| prohibited_phrases | POS 접수 완료, 주문 처리 완료 |

### ANS-POS-002 — POS Entry Confirmed

| Field | Value |
|---|---|
| answer_type | APPROVED_CONDITIONAL |
| allowed_when | staff confirmed POS entry or POS reference exists |
| required_evidence | staff confirmation or POS reference |
| approved_answer | 매장에서 주문 입력을 확인했습니다. 이후 주방 전달 및 준비 상태를 확인해 안내드리겠습니다. |
| prohibited_phrases | 결제 완료, 조리 완료 |

### ANS-KITCHEN-001 — Kitchen Handoff Pending

| Field | Value |
|---|---|
| answer_type | APPROVED_CONDITIONAL |
| allowed_when | POS entry or order confirmation exists, but kitchen handoff evidence missing |
| required_evidence | order id; no kitchen handoff reference |
| approved_answer | 주방 전달 여부를 확인 중입니다. 주방 전달이 확인되면 준비 상태로 안내드리겠습니다. |
| prohibited_phrases | 주방 접수 완료, 조리 중 |

### ANS-KITCHEN-002 — Kitchen Handoff Confirmed

| Field | Value |
|---|---|
| answer_type | APPROVED_CONDITIONAL |
| allowed_when | KDS, printer, or manual note handoff confirmation exists |
| required_evidence | kitchen handoff reference or staff confirmation |
| approved_answer | 주방 전달이 확인되었습니다. 조리 상황은 매장 확인 후 안내드리겠습니다. |
| prohibited_phrases | 조리 완료, 픽업 가능 |

### ANS-PAY-001 — Payment Unknown

| Field | Value |
|---|---|
| answer_type | ESCALATE_ONLY |
| allowed_when | payment evidence is missing or unclear |
| required_evidence | none or incomplete |
| approved_answer | 결제 상태는 매장 POS 또는 결제 단말 기준으로 확인이 필요합니다. 현재 결제 내역을 확인 중이며, 확인되는 대로 안내드리겠습니다. |
| prohibited_phrases | 결제 완료, 결제 실패, 환불 완료 |
| escalation_required_when | always if customer asks for confirmed payment/refund/cancel state |

### ANS-REFUND-001 — Refund Requested

| Field | Value |
|---|---|
| answer_type | ESCALATE_ONLY |
| allowed_when | refund request exists but refund evidence missing |
| required_evidence | refund request note |
| approved_answer | 환불 요청은 확인 중입니다. 환불은 결제 단말 또는 결제 기록 기준으로 확인이 필요하며, 처리 증적이 확인되면 안내드리겠습니다. |
| prohibited_phrases | 환불 완료, 곧 입금됩니다 |
| escalation_required_when | always |

### ANS-CANCEL-001 — Cancellation Checking

| Field | Value |
|---|---|
| answer_type | ESCALATE_ONLY |
| allowed_when | cancellation requested but affected state not fully confirmed |
| required_evidence | cancellation request note |
| approved_answer | 취소 요청은 확인 중입니다. POS 입력, 주방 전달, 결제 여부에 따라 처리 단계가 달라질 수 있어 매장에서 상태를 확인한 뒤 안내드리겠습니다. |
| prohibited_phrases | 취소 완료, 환불 완료 |
| escalation_required_when | if POS entry, kitchen handoff, or payment may already exist |

### ANS-DELAY-001 — Delay Checking

| Field | Value |
|---|---|
| answer_type | APPROVED_STATIC |
| allowed_when | order processing or kitchen timing is unclear |
| required_evidence | order id |
| approved_answer | 현재 매장에서 주문 처리 또는 조리 상황을 확인 중입니다. 확인되는 즉시 안내드리겠습니다. |
| prohibited_phrases | 정확히 몇 분, 이미 조리 완료 |

### ANS-SOLDOUT-001 — Sold-Out Checking

| Field | Value |
|---|---|
| answer_type | APPROVED_CONDITIONAL |
| allowed_when | item availability is uncertain or sold-out is reported |
| required_evidence | item/order reference |
| approved_answer | 일부 메뉴가 매장 상황에 따라 품절될 수 있습니다. 매장에서 대체 가능 여부 또는 취소 가능 여부를 확인 중입니다. |
| prohibited_phrases | 자동 취소, 자동 환불 |

### ANS-DUP-001 — Duplicate Suspected

| Field | Value |
|---|---|
| answer_type | ESCALATE_ONLY |
| allowed_when | duplicate order or duplicate POS entry risk is suspected |
| required_evidence | affected order ids or duplicate indicator |
| approved_answer | 중복 주문 가능성이 있어 매장에서 주문 기록을 확인 중입니다. 중복 처리를 막기 위해 추가 처리 전에 상태를 먼저 확인하겠습니다. |
| prohibited_phrases | 중복 아닙니다, 자동 취소했습니다 |
| escalation_required_when | always |

## 5. Staff-Only Answers

| Answer ID | Scenario | Staff Guidance |
|---|---|---|
| STAFF-POS-001 | order exists but POS missing | 중복 여부를 확인한 뒤 수동 입력하고 POS reference를 기록하세요. |
| STAFF-KDS-001 | kitchen handoff missing | KDS/프린터/수동노트 중 가능한 방식으로 주방 전달하고 handoff time을 기록하세요. |
| STAFF-PAY-001 | payment unknown | 결제 완료로 표시하지 말고 POS/payment terminal evidence를 확인하세요. |
| STAFF-REFUND-001 | refund unclear | 환불 완료로 말하지 말고 manager/payment owner에게 escalation하세요. |
| STAFF-DUP-001 | duplicate suspected | 추가 POS 입력을 멈추고 shift lead에게 escalation하세요. |

## 6. Escalation Rule Map

| Trigger | Escalate To | AI Behavior |
|---|---|---|
| payment state unknown | manager/payment owner | safe answer only |
| refund requested | manager/payment owner | safe answer only |
| cancellation after POS/kitchen/payment | shift lead + manager | safe answer only |
| duplicate suspected | shift lead | safe answer only |
| kitchen handoff missing | shift lead/kitchen receiver | safe answer only |
| customer complaint | support owner | safe answer + escalation |
| provider/system issue | support/technical owner | do not speculate |
| no approved answer | support owner | safe fallback + log unknown question |

## 7. Prohibited Phrase List

AI/customer center must not use:

- 결제 완료
- 환불 완료
- 취소 완료
- POS 접수 완료
- 주방 접수 완료
- 조리 완료
- 곧 입금됩니다
- 자동으로 처리됩니다
- 문제 없습니다
- 확정입니다
- provider/POS 문제입니다

unless specifically allowed by evidence-backed approved answer.

## 8. Evidence Requirement Matrix

| State Claim | Required Evidence |
|---|---|
| order received | Catch & Order order id |
| POS entered | POS reference or staff confirmation |
| kitchen received | KDS/printer/manual note confirmation |
| payment complete | POS/payment terminal/VAN/PG evidence |
| cancellation complete | affected state cancellation evidence |
| refund complete | payment refund evidence |
| order ready | kitchen/store confirmation |
| served/picked up | staff fulfillment confirmation |

## 9. Unknown Question Handling

If question cannot be answered from approved map:

1. Use safe fallback answer.
2. Escalate to support owner or shift lead.
3. Log unknown question in 14540.
4. Track frequency.
5. Create answer/SOP candidate if repeated or high-risk.

## 10. Approval And Review

| Review Type | Cadence |
|---|---|
| high-risk answer review | immediate |
| payment/refund/cancel answer review | payment/finance required |
| customer-facing answer review | support + product |
| staff-only answer review | operations |
| AI answer map review | weekly during pilot / monthly after stable |

## 11. Non-Goals

This template does not define:

- AI model prompts,
- model vendor,
- vector database,
- production chatbot deployment,
- legal compensation policy,
- payment gateway behavior.

It only defines approved answer map and escalation rules.

## 12. Related Documents

- 14540_Register_AI_Customer_Center_Unknown_Question_And_SOP_Candidate_Queue.md
- 14530_WorkPackage_AI_Customer_Center_Manual_Fallback_Answer_Map_And_SOP_Generation_Bridge.md
- 14380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md
- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 08000_ai_customer_center
