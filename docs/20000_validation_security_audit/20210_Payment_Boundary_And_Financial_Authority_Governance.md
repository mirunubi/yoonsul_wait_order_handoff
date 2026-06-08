# 20210 Payment Boundary And Financial Authority Governance

## 1 Purpose

Define payment-adjacent boundaries and financial authority limitations for the handoff system.

Handoff operational state must not be confused with payment or refund authority.

This document defines governance only.
It does not create payment APIs, refund runtime, or settlement logic.

## 2 Scope

In scope:

- Payment-adjacent data the handoff system may reference.
- Financial authority boundaries for store, HQ, and platform.
- What handoff may track vs must not decide.
- Refund/cancellation pressure scenarios.
- POS/payment provider boundary.
- Required audit evidence.

Out of scope:

- PG integration implementation.
- Tax, VAT, and accounting treatment.
- Chargeback dispute resolution runtime.
- Platform payment product activation.

Aligns with `docs/11000_integration_boundary/11040_Payment_And_Financial_Truth_Boundary.md` at integration boundary level.

## 3 Payment-Adjacent Data

| data type | handoff may track | handoff must not claim |
| --- | --- | --- |
| payment pending marker | Customer or store-visible pending posture. | Paid or settled status. |
| store POS payment reference | Link to POS-confirmed marker when authority exists. | Financial truth without POS authority. |
| refund/cancel pressure signal | Operational dispute or recovery context. | Refund approval or execution. |
| order value display | Menu or cart display for handoff intent. | Invoice, receipt, or tax authority. |
| platform payment future flag | Placeholder visibility per MVP boundary. | Active platform payment runtime. |

## 4 Financial Authority Boundaries

- handoff state is not payment authority.
- staff confirmation is operational confirmation, not financial truth.
- platform flags do not decide financial liability.
- final payment/refund decisions must remain with authorized systems and authorized humans.
- store POS remains default payment posture for MVP.

## 5 What the Handoff System May Track

- order candidate and preorder intent.
- staff-confirmed operational order state.
- payment-pending visibility where policy allows.
- manual POS input needed/completed markers.
- POS API attempt/success/failure posture per integration boundary.
- recovery items linked to payment-adjacent disputes.

## 6 What the Handoff System Must Not Decide

- whether payment succeeded without proper POS/payment authority.
- refund amount, eligibility, or execution.
- settlement, payout, or revenue recognition.
- tax calculation or receipt issuance.
- chargeback outcome or financial penalty.
- wallet, point, or membership ledger mutation.

## 7 Refund/Cancellation Pressure Scenarios

- customer or staff pressure expressed through handoff must route to review, not auto-refund.
- waiting/order preparation status must not directly force refunds.
- repeated cancel/refund language is a signal, not a financial decision.
- escalation to HQ or platform requires audit lineage per `20160`.
- payment provider remains authority for executed refund where integrated.

## 8 POS/Payment Provider Boundary

- POS API success does not necessarily equal payment completion.
- handoff does not replace POS or PG as financial system of record.
- payment profile and integration profile are separate governance domains.
- platform payment future requires separate domain review before activation.

## 9 Store/HQ/Platform Responsibility Separation

| role | financial governance scope |
| --- | --- |
| store | Operational confirmation, manual POS markers, store POS payment posture visibility. |
| HQ/tenant | Policy review, dispute escalation within tenant; not automatic refund execution. |
| platform | Policy boundary, support review, isolation; not default revenue ownership. |

## 10 Required Audit Evidence

- payment-pending state changes with actor and reason.
- manual POS input completed markers with staff context.
- POS API attempt/success/failure lineage.
- refund/cancel pressure signal and review outcome.
- escalation involving payment-adjacent dispute.
- platform or HQ action touching payment-adjacent visibility.

## 11 Non-Implementation Boundary

- no PG integration.
- no refund API.
- no settlement logic.
- no SQL, migrations, or schema.
- no wallet or point payment.
- no receipt or tax engine.

## 12 Cross-References

- `docs/11000_integration_boundary/11040_Payment_And_Financial_Truth_Boundary.md`
- `docs/20000_validation_security_audit/20150_Runtime_Misuse_And_Abuse_Prevention_Governance.md`
- `docs/09000_data_model_state_machine/09090_Order_Candidate_And_Confirmation_State_Refinement.md`

## 13 Open Decisions

- payment status customer visibility at MVP.
- refund pressure review owner.
- platform payment activation conditions.
- seller-of-record model.
- reconciliation with POS evidence.

## 14 Current Status

Status: active payment boundary and financial authority governance. Not implementation approval.
